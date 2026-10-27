import Foundation
import MacCleanKit

/// Persists whole-clean sessions so the user can Restore in one click.
public enum CleanHistoryRecorder {
    /// Override in tests. Under XCTest it defaults to a temp file so the
    /// suite's real trash cleans never land in the developer's own history.
    nonisolated(unsafe) public static var fileURL: URL = NSClassFromString("XCTestCase") != nil
        ? FileManager.default.temporaryDirectory
            .appending(path: "macsai-test-clean-history-\(ProcessInfo.processInfo.processIdentifier).json")
        : MCConstants.cleanHistoryFile
    /// Override in tests; the user's Trash in production.
    nonisolated(unsafe) public static var trashRoot: URL = MCConstants.userTrash

    /// Serializes load-modify-save so two cleans finishing together can't
    /// drop each other's session.
    private static let lock = NSLock()

    public static func load() -> [CleanHistorySession] {
        lock.withLock { unlockedLoad() }
    }

    private static func unlockedLoad(now: Date = Date()) -> [CleanHistorySession] {
        guard let data = try? Data(contentsOf: fileURL),
              let sessions = try? CleanHistoryStore.decode(data)
        else { return [] }
        return CleanHistoryStore.pruned(sessions, now: now)
    }

    public static func record(
        trashedItems: [CleaningEngine.TrashedItem],
        now: Date = Date()
    ) {
        guard !trashedItems.isEmpty else { return }
        let kept = trashedItems.prefix(CleanHistoryStore.maxItemsPerSession)
        let omitted = trashedItems.count - kept.count
        let session = CleanHistorySession(
            id: UUID(),
            date: now,
            items: kept.map {
                let trashPath = $0.trashURL.path(percentEncoded: false)
                // Directory URLs can carry a terminal '/' marker. Store a
                // normalized original path so Restore's strict path policy
                // accepts the now-missing directory without changing guards.
                let rawOriginalPath = $0.originalURL.path(percentEncoded: false)
                let originalPath = rawOriginalPath.count > 1 && rawOriginalPath.hasSuffix("/")
                    ? String(rawOriginalPath.dropLast()) : rawOriginalPath
                return CleanHistoryItem(
                    id: UUID(),
                    originalPath: originalPath,
                    trashPath: trashPath,
                    bytes: $0.bytes,
                    trashFileID: fileID(atPath: trashPath)
                )
            },
            omittedCount: omitted > 0 ? omitted : nil
        )
        lock.withLock {
            unlockedSave(CleanHistoryStore.adding(session, to: unlockedLoad(now: now), now: now))
        }
    }

    public static func save(_ sessions: [CleanHistorySession]) {
        lock.withLock { unlockedSave(sessions) }
    }

    /// Forgets every session. Files already in the Trash are not touched.
    public static func clear() {
        lock.withLock { try? FileManager.default.removeItem(at: fileURL) }
    }

    /// Writes owner-only (0600, the file lists cleaned paths) and atomically:
    /// the data goes to a temp file created with those permissions, which is
    /// then renamed over the old history.
    private static func unlockedSave(_ sessions: [CleanHistorySession]) {
        let url = fileURL
        let dir = url.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        guard let data = try? CleanHistoryStore.encode(sessions) else { return }
        let tmp = dir.appending(path: ".\(url.lastPathComponent).\(UUID().uuidString).tmp")
            .path(percentEncoded: false)
        let fd = open(tmp, O_WRONLY | O_CREAT | O_EXCL, 0o600)
        guard fd >= 0 else { return }
        let written = data.withUnsafeBytes { write(fd, $0.baseAddress, $0.count) }
        close(fd)
        if written != data.count || rename(tmp, url.path(percentEncoded: false)) != 0 {
            unlink(tmp)
        }
    }

    /// Puts a session's items back where they were. Each item is validated
    /// first, never overwrites anything (`moveItem` fails on an existing
    /// destination), and only items that actually moved are counted and
    /// dropped from the history. Blocking: call off the main thread.
    @discardableResult
    public static func restore(_ session: CleanHistorySession) -> CleanHistoryRestoreSummary {
        let fm = FileManager.default
        let root = trashRoot.path(percentEncoded: false)
        let uid = getuid()
        var summary = CleanHistoryRestoreSummary()

        for item in session.items {
            let recordedID = item.trashFileID
            let isSafe = CleanHistoryRestore.isInsideTrash(item.trashPath, trashRoot: root, uid: uid)
                && CleanHistoryRestore.isRestorableDestination(item.originalPath, trashRoot: root, uid: uid)
                && recordedID != nil && fileID(atPath: item.trashPath) == recordedID
                && (try? SafetyGuard().validatePath(URL(filePath: item.originalPath), excludedFolders: [])) != nil
            let action = CleanHistoryRestore.plan(
                item: item,
                trashExists: fileID(atPath: item.trashPath) != nil,
                originalExists: fileID(atPath: item.originalPath) != nil,
                isSafe: isSafe
            )
            switch action {
            case .skippedEmptied:
                summary.emptied += 1
            case .skippedReappeared:
                summary.reappeared += 1
            case .skippedUnsafe:
                summary.failed += 1
            case .restore(let from, let to):
                let destination = URL(filePath: to)
                do {
                    try fm.createDirectory(
                        at: destination.deletingLastPathComponent(), withIntermediateDirectories: true)
                    try fm.moveItem(at: URL(filePath: from), to: destination)
                    summary.restored += 1
                    summary.restoredItemIDs.insert(item.id)
                } catch {
                    summary.failed += 1
                }
            }
        }

        if !summary.restoredItemIDs.isEmpty {
            lock.withLock {
                unlockedSave(CleanHistoryStore.removing(itemIDs: summary.restoredItemIDs, from: unlockedLoad()))
            }
        }
        return summary
    }

    /// Inode of the item at `path` without following a final symlink, or nil
    /// when nothing is there.
    static func fileID(atPath path: String) -> UInt64? {
        var info = stat()
        guard lstat(path, &info) == 0 else { return nil }
        return UInt64(info.st_ino)
    }
}
