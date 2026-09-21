import Foundation

/// Pure logic for the progressive duplicate-detection pipeline.
///
/// The MacClean target wraps this with actual SHA-256 hashing via CryptoKit
/// and parallel `TaskGroup` execution. The decisions ABOUT which candidates
/// to keep, which to drop, and how to deduplicate by inode all live here
/// so they can be unit-tested without disk I/O.
public enum DuplicateDetection {

    private struct FileIdentity: Hashable {
        let deviceID: Int32
        let inode: UInt64
    }

    /// Files larger than this are skipped to avoid hour-long hashes.
    public static let maxHashableFileSize: UInt64 = 500 * 1024 * 1024

    /// Stage 1: group by size. Files with a unique size CANNOT be duplicates.
    /// Files larger than `maxHashableFileSize` are dropped entirely.
    ///
    /// - Returns: groups of size > 1, ready for partial hashing.
    public static func sizeGroups(_ files: [FileItem]) -> [[FileItem]] {
        let hashable = files.filter { $0.size <= maxHashableFileSize }
        let grouped = Dictionary(grouping: hashable) { $0.size }
        return grouped.values.filter { $0.count > 1 }
    }

    /// Stage 2 → stage 3 transition: given a collection of (key, FileItem)
    /// pairs from the partial-hash stage, group by key and keep only buckets
    /// with > 1 candidate. The key is typically `"<size>-<partialHash>"`.
    public static func partialGroups(
        _ pairs: [(key: String, item: FileItem)]
    ) -> [[FileItem]] {
        let grouped = Dictionary(grouping: pairs, by: \.key)
            .mapValues { $0.map(\.item) }
        return grouped.values.filter { $0.count > 1 }
    }

    /// Stage 3 → stage 4 transition: same as above, but the key is the full
    /// hash. Hard-link deduplication (Stage 4) is then applied to each group.
    public static func fullGroupsAndDedupHardLinks(
        _ pairs: [(key: String, item: FileItem)]
    ) -> [[FileItem]] {
        let grouped = Dictionary(grouping: pairs, by: \.key)
            .mapValues { $0.map(\.item) }
        return grouped.values
            .filter { $0.count > 1 }
            .map(dedupHardLinks)
            .filter { $0.count > 1 }
    }

    /// Stage 4 (in isolation): drop files that share a device and inode with
    /// one already kept. Files with `inode == 0` are treated as unknown and
    /// always kept.
    public static func dedupHardLinks(_ group: [FileItem]) -> [FileItem] {
        var seen: Set<FileIdentity> = []
        return group.filter { item in
            if item.inode == 0 { return true }
            return seen.insert(FileIdentity(deviceID: item.deviceID, inode: item.inode)).inserted
        }
    }

    /// From the final groups of true duplicates, pick the "items to delete":
    /// keep ONE original in each group (chosen by `chooseOriginal`) and mark
    /// the rest as deletable. The original is never included in the result, so
    /// every duplicate set always keeps at least one copy on disk — the user
    /// can never wipe the last copy, even by selecting everything.
    public static func extractDeletableDuplicates(_ groups: [[FileItem]]) -> [FileItem] {
        groups.flatMap { group -> [FileItem] in
            guard group.count > 1 else { return [] }
            let original = chooseOriginal(group)
            return group.filter { $0.url != original.url }
        }
    }

    // MARK: - Choosing which copy to keep

    /// Path fragments that mark a copy as a throwaway/derived duplicate rather
    /// than the canonical original. Matched case-insensitively against the full
    /// path. When a set has both a "plain" copy and a backup/`copy`/numbered
    /// copy, we keep the plain one and offer the rest for removal — so users
    /// don't lose the file they actually work from.
    private static let backupMarkers: [String] = [
        "backup", "/.trash/", " copy", "(copy", " 2.", " (1)", " (2)", " (3)",
    ]

    /// Heuristic: does this path look like a backup / duplicated copy rather
    /// than an original? Used only to *prefer keeping* the non-backup; it never
    /// causes deletion on its own.
    public static func isLikelyBackupCopy(_ url: URL) -> Bool {
        let path = url.path(percentEncoded: false).lowercased()
        return backupMarkers.contains { path.contains($0) }
    }

    /// Pick the single copy to KEEP from a duplicate set. Preference order,
    /// each tier breaking ties for the next:
    ///   1. Not a backup/copy-looking path (keep the real one).
    ///   2. Shallowest path (originals usually live in a primary location;
    ///      copies get buried deeper, e.g. `…/Desktop/old/…`).
    ///   3. Oldest (the original predates the copies made from it).
    ///   4. Lexicographically smallest path — a deterministic final tiebreak
    ///      so results are stable across runs and across machines.
    ///
    /// `group` must be non-empty (callers only pass sets of size > 1).
    public static func chooseOriginal(_ group: [FileItem]) -> FileItem {
        group.min(by: isMoreOriginal) ?? group[0]
    }

    /// Strict ordering used by `chooseOriginal`: returns true when `a` is a
    /// better "keep this one" candidate than `b`.
    private static func isMoreOriginal(_ a: FileItem, _ b: FileItem) -> Bool {
        let aBackup = isLikelyBackupCopy(a.url)
        let bBackup = isLikelyBackupCopy(b.url)
        if aBackup != bBackup { return !aBackup }   // non-backup wins

        let aDepth = pathDepth(a.url)
        let bDepth = pathDepth(b.url)
        if aDepth != bDepth { return aDepth < bDepth }   // shallower wins

        let aDate = a.creationDate ?? a.modificationDate ?? .distantFuture
        let bDate = b.creationDate ?? b.modificationDate ?? .distantFuture
        if aDate != bDate { return aDate < bDate }   // older wins

        return a.url.path(percentEncoded: false) < b.url.path(percentEncoded: false)
    }

    private static func pathDepth(_ url: URL) -> Int {
        url.path(percentEncoded: false).split(separator: "/").count
    }

    /// Turn raw duplicate sets into display groups: one kept original plus the
    /// removable extras, sorted so the biggest space wins are first. Sets that
    /// collapse to a single file (nothing to remove) are dropped.
    public static func displayGroups(_ groups: [[FileItem]]) -> [DuplicateDisplayGroup] {
        groups.compactMap { group -> DuplicateDisplayGroup? in
            guard group.count > 1 else { return nil }
            let original = chooseOriginal(group)
            let duplicates = group.filter { $0.url != original.url }
            guard !duplicates.isEmpty else { return nil }
            return DuplicateDisplayGroup(original: original, duplicates: duplicates)
        }
        .sorted { $0.wastedSpace > $1.wastedSpace }
    }
}

/// One set of identical files, split into the copy we keep (`original`) and
/// the redundant copies the user can remove (`duplicates`). Only `duplicates`
/// is ever eligible for deletion — `original` exists purely so the UI can show
/// what's being preserved.
public struct DuplicateDisplayGroup: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let original: FileItem
    public let duplicates: [FileItem]

    public init(id: UUID = UUID(), original: FileItem, duplicates: [FileItem]) {
        self.id = id
        self.original = original
        self.duplicates = duplicates
    }

    /// original + every removable copy, original first.
    public var allFiles: [FileItem] { [original] + duplicates }

    /// Total copies in the set, including the kept original.
    public var copyCount: Int { duplicates.count + 1 }

    /// Bytes reclaimable by removing the extras (every copy is the same size).
    public var wastedSpace: UInt64 { original.size * UInt64(duplicates.count) }

    public var formattedWastedSpace: String {
        ByteCountFormatter.string(fromByteCount: Int64(wastedSpace), countStyle: .file)
    }
}
