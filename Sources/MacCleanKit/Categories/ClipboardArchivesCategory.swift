import Foundation

/// Local copies prepared for Universal Clipboard, not the user's originals.
/// Age is only a review heuristic, never evidence that a transfer is finished.
public struct ClipboardArchivesCategory: JunkCategory {
    public let scanCategory = ScanCategory.clipboardArchives
    public let archivesRoot: URL
    public static let minimumAge: TimeInterval = 24 * 3600

    public init(archivesRoot: URL = MCConstants.userLibrary.appending(
        path: "Group Containers/group.com.apple.coreservices.useractivityd/shared-pasteboard/archives"
    )) {
        self.archivesRoot = archivesRoot
    }

    public var targets: [ScanTarget] {
        // Never recurse into the container or touch its metadata / incoming items.
        [ScanTarget(path: archivesRoot, recursive: false, minAge: Self.minimumAge)]
    }

    public func filterArchives(_ items: [FileItem], now: Date = Date()) -> [FileItem] {
        items.filter { item in
            // Only the known UUID-named, non-directory archive format. Fail
            // closed for unknown formats, symlinks, or unavailable timestamps.
            !item.isDirectory && !item.isSymlink && !item.isPackage
                && UUID(uuidString: item.url.lastPathComponent) != nil
                && item.url.deletingLastPathComponent().standardizedFileURL.pathComponents
                    == archivesRoot.standardizedFileURL.pathComponents
                && targets[0].passesAgeFilters(modificationDate: item.modificationDate, now: now)
        }
    }
}
