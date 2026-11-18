import Foundation

/// Local copies prepared for Universal Clipboard, not the user's originals.
/// Detection does not imply a transfer is finished; always require review.
public struct ClipboardArchivesCategory: JunkCategory {
    public let scanCategory = ScanCategory.clipboardArchives
    public let archivesRoot: URL

    public init(archivesRoot: URL = MCConstants.userLibrary.appending(
        path: "Group Containers/group.com.apple.coreservices.useractivityd/shared-pasteboard/archives"
    )) {
        self.archivesRoot = archivesRoot
    }

    public var targets: [ScanTarget] {
        // Never recurse into the container or touch its metadata / incoming items.
        [ScanTarget(path: archivesRoot, recursive: false)]
    }

    public func filterArchives(_ items: [FileItem]) -> [FileItem] {
        items.filter { item in
            // Only the known UUID-named, non-directory archive format. Fail
            // closed for unknown formats, symlinks, or unexpected paths.
            !item.isDirectory && !item.isSymlink && !item.isPackage
                && UUID(uuidString: item.url.lastPathComponent) != nil
                && item.url.deletingLastPathComponent().standardizedFileURL.pathComponents
                    == archivesRoot.standardizedFileURL.pathComponents
        }
    }
}
