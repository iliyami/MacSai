import Foundation

public struct CleanHistoryItem: Equatable, Codable, Sendable, Identifiable {
    public let id: UUID
    public let originalPath: String
    public let trashPath: String
    public let bytes: UInt64
    /// Inode of the item at `trashPath` right after it was trashed. macOS
    /// reuses a Trash name once the first item is gone, so without this an old
    /// session could "restore" a different, later-trashed file into the old
    /// location. Entries without it are never restored.
    public let trashFileID: UInt64?

    public init(id: UUID, originalPath: String, trashPath: String, bytes: UInt64, trashFileID: UInt64? = nil) {
        self.id = id
        self.originalPath = originalPath
        self.trashPath = trashPath
        self.bytes = bytes
        self.trashFileID = trashFileID
    }
}

public struct CleanHistorySession: Equatable, Codable, Sendable, Identifiable {
    public let id: UUID
    public let date: Date
    public let items: [CleanHistoryItem]
    /// Items the clean trashed beyond `CleanHistoryStore.maxItemsPerSession`.
    /// They are still in the Trash but Restore can't put them back, and the
    /// UI says so instead of offering a silently partial restore.
    public let omittedCount: Int?

    public init(id: UUID, date: Date, items: [CleanHistoryItem], omittedCount: Int? = nil) {
        self.id = id
        self.date = date
        self.items = items
        self.omittedCount = omittedCount
    }

    public var isPartial: Bool { (omittedCount ?? 0) > 0 }

    public var totalBytes: UInt64 {
        items.reduce(0) { $0 &+ $1.bytes }
    }
}

public enum CleanHistoryRestoreAction: Equatable, Sendable {
    case restore(fromTrash: String, to: String)
    case skippedEmptied(originalPath: String)
    case skippedReappeared(originalPath: String)
    /// The entry failed validation: the Trash path is not inside a Trash, a
    /// different file now holds that Trash name, or the destination is not a
    /// normal place to put a file back.
    case skippedUnsafe(originalPath: String)
}

public struct CleanHistoryRestoreSummary: Equatable, Sendable {
    public var restored = 0
    public var emptied = 0
    public var reappeared = 0
    /// Unsafe entries plus moves that failed at the filesystem level.
    public var failed = 0
    /// Items that were actually put back, so the caller can drop them.
    public var restoredItemIDs: Set<UUID> = []

    public init() {}
}

public enum CleanHistoryRestore {
    public static func plan(
        item: CleanHistoryItem,
        trashExists: Bool,
        originalExists: Bool,
        isSafe: Bool
    ) -> CleanHistoryRestoreAction {
        if !trashExists {
            return .skippedEmptied(originalPath: item.originalPath)
        }
        if !isSafe {
            return .skippedUnsafe(originalPath: item.originalPath)
        }
        if originalExists {
            return .skippedReappeared(originalPath: item.originalPath)
        }
        return .restore(fromTrash: item.trashPath, to: item.originalPath)
    }

    /// True when `path` is an item inside the user's Trash (`trashRoot`) or a
    /// volume Trash (`/Volumes/<name>/.Trashes/<uid>/...`). Anything else, or
    /// a path with `..`, is rejected, so a corrupted or edited history file
    /// can never turn Restore into "move any file anywhere".
    public static func isInsideTrash(_ path: String, trashRoot: String, uid: UInt32) -> Bool {
        guard isNormalizedAbsolute(path) else { return false }
        let root = trashRoot.hasSuffix("/") ? trashRoot : trashRoot + "/"
        if path.hasPrefix(root) && path.count > root.count { return true }
        let parts = URL(filePath: path).pathComponents
        return parts.count >= 6 && parts[0] == "/" && parts[1] == "Volumes"
            && parts[3] == ".Trashes" && parts[4] == String(uid)
    }

    /// True when `path` is a plausible place to put an item back: absolute,
    /// already normalized, and not itself inside a Trash.
    public static func isRestorableDestination(_ path: String, trashRoot: String, uid: UInt32) -> Bool {
        isNormalizedAbsolute(path) && !isInsideTrash(path, trashRoot: trashRoot, uid: uid)
    }

    private static func isNormalizedAbsolute(_ path: String) -> Bool {
        guard path.hasPrefix("/"), !path.contains("\0") else { return false }
        // On macOS 15 standardization adds a directory marker when the
        // item exists, even with a non-directory URL hint. Ignore only that
        // marker when comparing; traversal and non-normalized input still
        // differ and remain rejected.
        let normalized = URL(filePath: path).standardizedFileURL.path(percentEncoded: false)
        let comparable = normalized.count > 1 && normalized.hasSuffix("/")
            ? String(normalized.dropLast()) : normalized
        return comparable == path
    }
}

public enum CleanHistoryStore {
    public static let maxSessions = 20
    public static let maxItemsPerSession = 5_000
    public static let maxAge: TimeInterval = 30 * 24 * 60 * 60

    public static func adding(
        _ session: CleanHistorySession,
        to existing: [CleanHistorySession],
        now: Date = Date()
    ) -> [CleanHistorySession] {
        pruned([session] + existing, now: now)
    }

    /// Newest first, nothing older than `maxAge`, at most `maxSessions`.
    public static func pruned(_ sessions: [CleanHistorySession], now: Date = Date()) -> [CleanHistorySession] {
        let cutoff = now.addingTimeInterval(-maxAge)
        return sessions
            .filter { $0.date >= cutoff }
            .sorted { $0.date > $1.date }
            .prefix(maxSessions)
            .map { $0 }
    }

    /// Drops restored items, and sessions left with nothing to restore, so a
    /// session can't be restored twice.
    public static func removing(
        itemIDs: Set<UUID>,
        from sessions: [CleanHistorySession]
    ) -> [CleanHistorySession] {
        sessions.compactMap { session in
            let left = session.items.filter { !itemIDs.contains($0.id) }
            return left.isEmpty
                ? nil
                : CleanHistorySession(id: session.id, date: session.date, items: left, omittedCount: session.omittedCount)
        }
    }

    public static func encode(_ sessions: [CleanHistorySession]) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(sessions)
    }

    public static func decode(_ data: Data) throws -> [CleanHistorySession] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([CleanHistorySession].self, from: data)
            .sorted { $0.date > $1.date }
    }
}
