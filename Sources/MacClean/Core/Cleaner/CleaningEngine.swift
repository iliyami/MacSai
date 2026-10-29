import Foundation
import Darwin
import MacCleanKit
import OSLog

public actor CleaningEngine {
    public enum CleanMode: Sendable, Equatable {
        case trash
        case permanent
        case dryRun
    }

    public struct TrashedItem: Sendable, Equatable {
        public let originalURL: URL
        public let trashURL: URL
        public let bytes: UInt64

        public init(originalURL: URL, trashURL: URL, bytes: UInt64) {
            self.originalURL = originalURL
            self.trashURL = trashURL
            self.bytes = bytes
        }
    }

    public struct CleanResult: Sendable {
        public let removedCount: Int
        public let freedBytes: UInt64
        public let removedURLs: Set<URL>
        public let errors: [CleanError]
        public let skippedCount: Int
        /// Items actually moved to the Trash (empty for dry-run / permanent).
        public let trashedItems: [TrashedItem]
        /// Cancellation in MacSai or in the system's authorization dialog.
        public let wasCancelled: Bool

        public init(
            removedCount: Int,
            freedBytes: UInt64,
            removedURLs: Set<URL>,
            errors: [CleanError],
            skippedCount: Int,
            trashedItems: [TrashedItem] = [],
            wasCancelled: Bool = false
        ) {
            self.removedCount = removedCount
            self.freedBytes = freedBytes
            self.removedURLs = removedURLs
            self.errors = errors
            self.skippedCount = skippedCount
            self.trashedItems = trashedItems
            self.wasCancelled = wasCancelled
        }
    }

    public struct CleanError: Sendable {
        public let path: String
        public let error: String
    }

    /// Per-chunk-boundary snapshot of an in-flight Clean operation.
    /// The engine emits one of these to `onProgress` after each chunk
    /// finishes processing — never per-item (would be the perf bottleneck
    /// for 100k-item runs). The View should treat it as eventually-
    /// consistent: a final emission with `processedItems == totalItems`
    /// is the "done" marker for UI purposes, though the actual
    /// CleanResult arrives via the async return.
    public struct Progress: Sendable, Equatable {
        public let totalItems: Int
        public let processedItems: Int
        public let removedSoFar: Int
        public let freedBytesSoFar: UInt64

        public var fraction: Double {
            totalItems > 0 ? Double(processedItems) / Double(totalItems) : 0
        }
    }

    private let safetyGuard = SafetyGuard()
    private let logger = Logger(subsystem: MCConstants.bundleIdentifier, category: "CleaningEngine")
    private let trashService: BatchTrashService
    private let trashRoot: String
    private let readIdentity: @Sendable (URL) throws -> TrashItemIdentity
    private let isMissing: @Sendable (URL) -> Bool
    private let trashBatchSize: Int
    private var isCleaning = false

    public init() {
        self.init(trashService: .live)
    }

    init(
        trashService: BatchTrashService,
        trashRoot: String = MCConstants.userTrash.path(percentEncoded: false),
        batchSize: Int = 500,
        readIdentity: @escaping @Sendable (URL) throws -> TrashItemIdentity = TrashItemIdentity.read,
        isMissing: @escaping @Sendable (URL) -> Bool = { url in
            var info = stat()
            return lstat(url.path(percentEncoded: false), &info) != 0 && errno == ENOENT
        }
    ) {
        self.trashService = trashService
        self.trashRoot = trashRoot
        self.trashBatchSize = min(max(1, batchSize), MCConstants.maxFilesPerOperation)
        self.readIdentity = readIdentity
        self.isMissing = isMissing
    }

    /// Trash / permanently delete / dry-run the given items.
    ///
    /// Large selections are processed in bounded batches. Trash batches are
    /// smaller to keep cancellation responsive while the system owns a move;
    /// permanent deletion and dry runs retain `MCConstants.cleanChunkSize`.
    /// Selections beyond `MCConstants.maxTotalItemsPerCleanOperation`
    /// (500k) are refused entirely as a runaway-protection — that's
    /// orders of magnitude above any realistic user scenario and signals
    /// a scanner bug rather than user intent.
    ///
    /// `onProgress` (optional): a Sendable callback invoked once per
    /// completed chunk with a Progress snapshot. Callers wiring this to
    /// a SwiftUI @State must hop to the main actor inside the closure
    /// (the engine runs on its own actor; calling @MainActor-isolated
    /// setters from the closure body without dispatching is unsafe).
    public func clean(
        items: [FileItem],
        mode: CleanMode = .trash,
        onProgress: (@Sendable (Progress) -> Void)? = nil
    ) async -> CleanResult {
        guard !isCleaning else {
            return CleanResult(removedCount: 0, freedBytes: 0, removedURLs: [],
                               errors: [CleanError(path: "cleanup", error: L10n.tr(
                                "另一项清理仍在进行中。", "Another cleanup is still running.", "Другая очистка ещё выполняется."))],
                               skippedCount: items.count)
        }
        isCleaning = true
        defer { isCleaning = false }
        // Upper bound: refuse genuinely runaway selections cleanly.
        if items.count > MCConstants.maxTotalItemsPerCleanOperation {
            let msg = L10n.tr("操作超过 \(MCConstants.maxTotalItemsPerCleanOperation) 项上限（尝试处理：\(items.count) 项）。这通常表示扫描器存在异常。", "Operation exceeds limit of \(MCConstants.maxTotalItemsPerCleanOperation) items (attempted: \(items.count)). This usually indicates a scanner bug.", "Операция превышает лимит в \(MCConstants.maxTotalItemsPerCleanOperation) \(L10n.russianPlural(MCConstants.maxTotalItemsPerCleanOperation, one: "объект", few: "объекта", many: "объектов")) (запрошено: \(items.count)). Обычно это указывает на ошибку сканера.")
            logger.error("\(msg, privacy: .public)")
            return CleanResult(
                removedCount: 0,
                freedBytes: 0,
                removedURLs: [],
                errors: [CleanError(path: "validation", error: msg)],
                skippedCount: items.count
            )
        }

        var removedCount = 0
        var freedBytes: UInt64 = 0
        var removedURLs = Set<URL>()
        var errors: [CleanError] = []
        var skippedCount = 0
        var trashedItems: [TrashedItem] = []
        var wasCancelled = false

        // Direct engine callers get the same no-double-move guarantee as
        // CleanActions. Keep the first URL's metadata.
        var seen = Set<URL>()
        let items = mode == .trash ? items.filter { seen.insert($0.url).inserted } : items

        // Bounded batches reduce per-file system prompts while allowing
        // cancellation between batches. AppKit controls authentication UI;
        // it does not promise a single prompt for an entire cleanup.
        let chunkSize = mode == .trash ? trashBatchSize : MCConstants.cleanChunkSize
        var startIndex = 0
        var processedSoFar = 0
        while startIndex < items.count {
            if Task.isCancelled { break }
            let endIndex = min(startIndex + chunkSize, items.count)
            let chunk = Array(items[startIndex..<endIndex])
            startIndex = endIndex

            if mode == .trash {
                let result = await processTrashChunk(chunk)
                removedCount += result.removedCount
                freedBytes += result.freedBytes
                removedURLs.formUnion(result.removedURLs)
                errors.append(contentsOf: result.errors)
                skippedCount += result.skippedCount
                trashedItems.append(contentsOf: result.trashedItems)
                wasCancelled = result.wasCancelled
            } else {
                processChunk(
                    chunk, mode: mode,
                    removedCount: &removedCount,
                    freedBytes: &freedBytes,
                    removedURLs: &removedURLs,
                    errors: &errors,
                    skippedCount: &skippedCount
                )
            }
            processedSoFar += chunk.count

            // Emit per-chunk progress so the UI can render an honest
            // progress bar on long runs. Per-item emission would itself
            // become the bottleneck.
            onProgress?(Progress(
                totalItems: items.count,
                processedItems: processedSoFar,
                removedSoFar: removedCount,
                freedBytesSoFar: freedBytes
            ))
            // A declined system prompt must not be immediately retried by
            // the next batch (nor by a later CleanActions stage).
            if wasCancelled { break }

            // Give the runloop room to breathe between chunks.
            await Task.yield()
        }

        logger.info("Cleaning complete: \(removedCount) removed, \(freedBytes) bytes freed, \(errors.count) errors")

        return CleanResult(
            removedCount: removedCount,
            freedBytes: freedBytes,
            removedURLs: removedURLs,
            errors: errors,
            skippedCount: skippedCount,
            trashedItems: trashedItems,
            wasCancelled: wasCancelled || Task.isCancelled
        )
    }

    private func processTrashChunk(_ items: [FileItem]) async -> CleanResult {
        var prepared: [(item: FileItem, bytes: UInt64, identity: TrashItemIdentity)] = []
        var errors: [CleanError] = []
        var skippedCount = 0
        for item in items {
            if Task.isCancelled { break }
            do {
                try safetyGuard.validatePath(item.url)
                let identity = try readIdentity(item.url)
                let bytes = item.isDirectory ? Self.recursiveAllocatedSize(of: item.url) : item.size
                prepared.append((item, bytes, identity))
            } catch {
                if TrashItemIdentity.isDirectSymbolicLink(item.url) {
                    skippedCount += 1
                    logSkip(path: item.url, reason: L10n.tr(
                        "符号链接已跳过。", "Symbolic link skipped.", "Символическая ссылка пропущена."))
                } else if Self.isBenignMissingFile(error as NSError) {
                    skippedCount += 1
                    logSkip(path: item.url, reason: L10n.tr("已不存在", "already gone", "уже удалён"))
                } else {
                    skippedCount += 1
                    errors.append(CleanError(path: item.url.path(percentEncoded: false), error: error.localizedDescription))
                    logError(path: item.url, reason: error.localizedDescription)
                }
            }
        }

        var ready: [(item: FileItem, bytes: UInt64)] = []
        // Revalidate after size enumeration and immediately before handing
        // this bounded selection to the system. Changed entries are skipped.
        for entry in prepared {
            if Task.isCancelled { break }
            do {
                try safetyGuard.validatePath(entry.item.url)
                guard try readIdentity(entry.item.url) == entry.identity else {
                    throw CocoaError(.fileWriteUnknown, userInfo: [NSLocalizedDescriptionKey: L10n.tr(
                        "准备清理时文件已更改，请重新扫描。",
                        "The item changed while cleanup was being prepared. Scan again.",
                        "Объект изменился во время подготовки очистки. Повторите сканирование.")])
                }
                ready.append((entry.item, entry.bytes))
            } catch {
                if Self.isBenignMissingFile(error as NSError) {
                    skippedCount += 1
                    logSkip(path: entry.item.url, reason: L10n.tr("已不存在", "already gone", "уже удалён"))
                } else {
                    skippedCount += 1
                    errors.append(CleanError(path: entry.item.url.path(percentEncoded: false), error: error.localizedDescription))
                    logError(path: entry.item.url, reason: error.localizedDescription)
                }
            }
        }
        guard !ready.isEmpty, !Task.isCancelled else {
            return CleanResult(removedCount: 0, freedBytes: 0, removedURLs: [], errors: errors,
                               skippedCount: skippedCount, wasCancelled: Task.isCancelled)
        }

        let urls = ready.map { $0.item.url }
        let receipt = await trashService.recycle(urls)
        let missing = Set(urls.filter { receipt.relocated[$0] == nil && isMissing($0) })
        let outcomes = BatchTrashPolicy.outcomes(requested: urls, relocated: receipt.relocated,
                                               missing: missing, trashRoot: trashRoot, uid: getuid())
        var trashedItems: [TrashedItem] = []
        var bytes: UInt64 = 0
        for entry in ready {
            let url = entry.item.url
            switch outcomes[url] {
            case .moved(let destination):
                trashedItems.append(TrashedItem(originalURL: url, trashURL: destination, bytes: entry.bytes))
                bytes += entry.bytes
                logOperation(path: url, size: entry.bytes, dryRun: false)
            case .missing:
                skippedCount += 1
                logSkip(path: url, reason: L10n.tr("已不存在", "already gone", "уже удалён"))
            case .invalidReceipt:
                let message = L10n.tr("无法确认项目在废纸篓中的位置，请检查访达。",
                                      "The item's Trash location could not be verified. Check Finder.",
                                      "Не удалось подтвердить расположение объекта в Корзине. Проверьте Finder.")
                errors.append(CleanError(path: url.path(percentEncoded: false), error: message))
                logError(path: url, reason: message)
            case .failed, .none:
                let message = receipt.errorMessage ?? L10n.tr(
                    "macOS 未将此项目移到废纸篓。请检查权限并重新扫描。",
                    "macOS did not move this item to the Trash. Check permissions and scan again.",
                    "macOS не переместила объект в Корзину. Проверьте разрешения и повторите сканирование.")
                errors.append(CleanError(path: url.path(percentEncoded: false), error: message))
                logError(path: url, reason: message)
            }
        }
        return CleanResult(removedCount: trashedItems.count, freedBytes: bytes,
                           removedURLs: Set(trashedItems.map(\.originalURL)), errors: errors,
                           skippedCount: skippedCount, trashedItems: trashedItems,
                           wasCancelled: receipt.wasCancelled || Task.isCancelled)
    }

    /// One chunk's worth of cleanup. Batch-validates the chunk's paths,
    /// then per-item processes if validation passed. On batch failure
    /// (typically a protected path slipping through scanner-side filtering),
    /// the whole chunk is skipped with a single error — partial
    /// processing of a malformed chunk isn't worth the surprise.
    private func processChunk(
        _ chunk: [FileItem],
        mode: CleanMode,
        removedCount: inout Int,
        freedBytes: inout UInt64,
        removedURLs: inout Set<URL>,
        errors: inout [CleanError],
        skippedCount: inout Int
    ) {
        let urls = chunk.map(\.url)
        do {
            try safetyGuard.validateDeletion(paths: urls)
        } catch SafetyGuard.SafetyError.tooManyFiles {
            // Genuine over-cap chunk: skip it wholesale. Structurally this can't
            // happen (chunks are <= cleanChunkSize < maxFilesPerOperation), but
            // keep the guard so raising the chunk size can't bypass the cap.
            logger.error("Chunk exceeds the \(MCConstants.maxFilesPerOperation)-file safety cap")
            errors.append(CleanError(
                path: "validation",
                error: SafetyGuard.SafetyError.tooManyFiles(chunk.count).localizedDescription
            ))
            skippedCount += chunk.count
            return
        } catch {
            // A single UNSAFE PATH failed batch validation. Do NOT skip the whole
            // chunk (issue #104: one printer-PPD symlink left everything
            // uncleaned). Fall through to the per-item loop below, which
            // re-validates each path and skips only the offending one(s).
            logger.notice("Chunk has an unsafe path; validating per-item instead of skipping all")
        }

        for item in chunk {
            if Task.isCancelled { break }

            do {
                try safetyGuard.validatePath(item.url)
            } catch {
                skippedCount += 1
                errors.append(CleanError(
                    path: item.url.path(percentEncoded: false),
                    error: error.localizedDescription
                ))
                logError(path: item.url, reason: error.localizedDescription)
                continue
            }

            // For directories, totalFileAllocatedSize doesn't recurse —
            // Apple's API returns 0 for dirs. Compute the real on-disk
            // size by walking the subtree BEFORE we trash it (after,
            // the path is gone). Without this, freedBytes massively
            // undercounts: trashing ~/Library/Caches/com.foo/ shows
            // "Zero KB freed" even when the dir held 200 MB.
            let realSize: UInt64 = item.isDirectory
                ? Self.recursiveAllocatedSize(of: item.url)
                : item.size

            switch mode {
            case .dryRun:
                removedCount += 1
                freedBytes += realSize
                removedURLs.insert(item.url)
                logOperation(path: item.url, size: realSize, dryRun: true)

            case .trash:
                // Routed to processTrashChunk before reaching this method.
                break

            case .permanent:
                do {
                    try FileManager.default.removeItem(at: item.url)
                    removedCount += 1
                    freedBytes += realSize
                    removedURLs.insert(item.url)
                    logOperation(path: item.url, size: realSize, dryRun: false)
                } catch let nsError as NSError where Self.isBenignMissingFile(nsError) {
                    skippedCount += 1
                    logSkip(path: item.url, reason: L10n.tr("已不存在", "already gone", "уже удалён"))
                } catch {
                    let msg = error.localizedDescription
                    errors.append(CleanError(
                        path: item.url.path(percentEncoded: false), error: msg
                    ))
                    logError(path: item.url, reason: msg)
                }
            }
        }
    }

    /// Walks `url` recursively (using FileManager.enumerator) and sums
    /// per-file allocated sizes. Returns 0 if the URL doesn't exist
    /// or the enumeration fails.
    private static func recursiveAllocatedSize(of url: URL) -> UInt64 {
        let fm = FileManager.default
        guard let enumerator = fm.enumerator(
            at: url,
            includingPropertiesForKeys: [.totalFileAllocatedSizeKey, .isRegularFileKey, .linkCountKey],
            options: []
        ) else { return 0 }

        var total: UInt64 = 0
        var hardLinks = HardLinkTracker()
        for case let fileURL as URL in enumerator {
            let values = try? fileURL.resourceValues(forKeys: [
                .totalFileAllocatedSizeKey, .isRegularFileKey, .linkCountKey,
            ])
            if values?.isRegularFile == true,
               hardLinks.shouldCount(fileURL, linkCount: values?.linkCount) {
                total += UInt64(values?.totalFileAllocatedSize ?? 0)
            }
        }
        return total
    }

    /// True if the error is "file doesn't exist" — benign because cache
    /// daemons regenerate constantly; a file the scanner saw 30s ago may
    /// already be gone, and that's not a "user-facing error."
    private static func isBenignMissingFile(_ error: NSError) -> Bool {
        if error.domain == NSCocoaErrorDomain &&
           (error.code == NSFileNoSuchFileError ||
            error.code == NSFileReadNoSuchFileError) {
            return true
        }
        if error.domain == NSPOSIXErrorDomain && error.code == Int(ENOENT) {
            return true
        }
        return false
    }

    private nonisolated func logOperation(path: URL, size: UInt64, dryRun: Bool) {
        let sizeStr = ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
        let prefix = dryRun ? "[DRY-RUN]" : "[REMOVED]"
        appendLogLine("\(prefix) \(path.path(percentEncoded: false)) (\(sizeStr))")
    }

    private nonisolated func logError(path: URL, reason: String) {
        appendLogLine("[ERROR] \(path.path(percentEncoded: false)) — \(reason)")
    }

    private nonisolated func logSkip(path: URL, reason: String) {
        appendLogLine("[SKIP] \(path.path(percentEncoded: false)) — \(reason)")
    }

    /// Appends a timestamped line to `operations.log`. Best-effort —
    /// any I/O failure here is silent because we never want logging to
    /// abort the cleanup it's narrating.
    private nonisolated func appendLogLine(_ body: String) {
        let fm = FileManager.default
        let logDir = MCConstants.operationLogDir
        let logFile = MCConstants.operationLogFile

        if !fm.fileExists(atPath: logDir.path(percentEncoded: false)) {
            try? fm.createDirectory(at: logDir, withIntermediateDirectories: true)
        }

        let timestamp = ISO8601DateFormatter().string(from: Date())
        let line = "\(timestamp) \(body)\n"

        guard let data = line.data(using: .utf8) else { return }
        if fm.fileExists(atPath: logFile.path(percentEncoded: false)) {
            if let handle = try? FileHandle(forWritingTo: logFile) {
                handle.seekToEndOfFile()
                handle.write(data)
                handle.closeFile()
            }
        } else {
            try? data.write(to: logFile)
        }
    }
}
