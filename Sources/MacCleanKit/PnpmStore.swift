import Foundation

/// pnpm's content-addressable store keeps one folder per store layout version
/// (`store/v3`, `store/v10`, ...). Upgrading pnpm starts a new folder and
/// leaves the old one behind, so older versions are dead weight, and each
/// one can hold hundreds of thousands of files. They are listed as whole
/// folders, one row per version, rather than file by file.
public enum PnpmStore {
    public struct Version: Equatable, Sendable {
        public let url: URL
        public let number: Int
        /// The newest version found across every store root: the one the
        /// installed pnpm uses. Removing it is safe but costs a re-download.
        public let isCurrent: Bool

        public init(url: URL, number: Int, isCurrent: Bool) {
            self.url = url
            self.number = number
            self.isCurrent = isCurrent
        }

        /// "pnpm store v3 · Older version, no longer used"
        public var displayName: String {
            "pnpm store v\(number) · " + (isCurrent ? PnpmStore.currentNote : PnpmStore.staleNote)
        }
    }

    /// Layout version of a store folder name: "v10" is 10. Nil for anything
    /// else, so stray files and tmp folders in the store root are never listed.
    public static func versionNumber(ofFolderNamed name: String) -> Int? {
        guard name.count > 1, name.first == "v",
              name.dropFirst().allSatisfy({ $0.isASCII && $0.isNumber }),
              let number = Int(name.dropFirst()), number > 0 else { return nil }
        return number
    }

    /// The version folders among `folders` (each a direct child of a store
    /// root), newest first. Only the highest version counts as current, even
    /// when it appears under more than one root.
    public static func versions(in folders: [URL]) -> [Version] {
        let found = folders.compactMap { url in
            versionNumber(ofFolderNamed: url.lastPathComponent).map { (url, $0) }
        }
        guard let newest = found.map({ $0.1 }).max() else { return [] }
        return found
            .map { Version(url: $0.0, number: $0.1, isCurrent: $0.1 == newest) }
            .sorted { $0.number > $1.number }
    }

    public static var staleNote: String {
        L10n.tr("旧版本，已不再使用", "Older version, no longer used", "Старая версия, больше не используется")
    }

    public static var currentNote: String {
        L10n.tr("当前版本，删除后会重新下载", "Current version, re-downloaded after removal", "Текущая версия, после удаления скачивается заново")
    }
}
