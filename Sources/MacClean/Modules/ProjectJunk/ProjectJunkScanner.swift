import Foundation
import MacCleanKit

/// Walks a user-chosen root and builds `ProjectTreeNode`s for the junk finder.
public struct ProjectJunkScanner: Sendable {
    public init() {}

    /// Junk folder names: listed when a project marker sits beside them, and
    /// never descended into (they can hold hundreds of thousands of files).
    static let junkNames: Set<String> = [
        "node_modules", "target", "build", "dist", ".next", "Pods", ".venv", "venv",
    ]
    /// Hidden folders that can be junk. Every other hidden folder (.git,
    /// .cache, ...) is skipped during the walk.
    private static let hiddenJunkNames: Set<String> = [".next", ".venv"]

    /// Share of the progress bar spent walking the folder tree; measuring the
    /// matched folders fills the rest.
    static let walkShare = 0.4

    /// `onProgress` gets 0...1: `walkShare` once the walk is done, then one
    /// step per matched folder as its size is measured.
    public func scan(
        root: URL,
        maxDepth: Int = 6,
        onProgress: (@Sendable (Double) -> Void)? = nil
    ) -> [ProjectJunkItem] {
        guard Self.isAllowedRoot(root) else { return [] }
        let nodes = collectNodes(root: root, maxDepth: maxDepth)
        let matches = ProjectJunkFinder.find(nodes: nodes)
        onProgress?(Self.walkShare)
        // Size only the matches, never every folder on the way down.
        var items: [ProjectJunkItem] = []
        for (index, item) in matches.enumerated() {
            if Task.isCancelled { return [] }
            items.append(ProjectJunkItem(
                path: item.path,
                projectPath: item.projectPath,
                kind: item.kind,
                bytes: Self.directoryBytes(URL(filePath: item.path, directoryHint: .isDirectory)),
                projectModified: item.projectModified
            ))
            onProgress?(Self.walkShare + (1 - Self.walkShare) * Double(index + 1) / Double(matches.count))
        }
        return items
    }

    /// Refuses roots where a "build" or "target" folder belongs to the OS or
    /// to apps rather than to the user's own projects.
    static func isAllowedRoot(_ root: URL) -> Bool {
        let path = normalized(root.resolvingSymlinksInPath())
        if path == "/" { return false }
        let home = normalized(FileManager.default.homeDirectoryForCurrentUser)
        let forbidden = ["/System", "/Library", "/Applications", "/usr", "/bin", "/sbin",
                         "/opt", home + "/Library"]
        return !forbidden.contains { path == $0 || path.hasPrefix($0 + "/") }
    }

    /// Paths without a trailing slash, so a child's `deletingLastPathComponent`
    /// matches its parent's key. Directory URLs from the enumerator end in "/".
    static func normalized(_ url: URL) -> String {
        var path = url.standardizedFileURL.path(percentEncoded: false)
        while path.count > 1 && path.hasSuffix("/") { path.removeLast() }
        return path
    }

    public func asScanResults(_ items: [ProjectJunkItem]) -> [ScanResult] {
        guard !items.isEmpty else { return [] }
        let files = items.map { item in
            FileItem(
                url: URL(filePath: item.path),
                name: (item.path as NSString).lastPathComponent,
                size: item.bytes,
                allocatedSize: item.bytes,
                isDirectory: true
            )
        }
        return [
            ScanResult(
                category: .projectJunk,
                items: files,
                autoSelect: false
            )
        ]
    }

    private func collectNodes(root: URL, maxDepth: Int) -> [ProjectTreeNode] {
        let fm = FileManager.default
        let home = Self.normalized(fm.homeDirectoryForCurrentUser)
        guard let enumerator = fm.enumerator(
            at: root,
            includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey, .contentModificationDateKey],
            options: [.skipsPackageDescendants]
        ) else { return [] }

        var nodes: [ProjectTreeNode] = []
        // Include the root itself so project markers at the top level work.
        nodes.append(node(path: Self.normalized(root), url: root, fm: fm))

        while let url = enumerator.nextObject() as? URL {
            if Task.isCancelled { return [] }
            let name = url.lastPathComponent
            let values = try? url.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey])
            // Symlinks are never followed or listed: trashing one would only
            // move the link, and following one could leave the chosen folder.
            guard values?.isDirectory == true, values?.isSymbolicLink != true else { continue }
            let path = Self.normalized(url)
            if path == home + "/Library" || (name.hasPrefix(".") && !Self.hiddenJunkNames.contains(name)) {
                enumerator.skipDescendants()
                continue
            }
            if enumerator.level > maxDepth {
                enumerator.skipDescendants()
                continue
            }
            nodes.append(node(path: path, url: url, fm: fm))
            if Self.junkNames.contains(name) {
                enumerator.skipDescendants()
            }
        }
        return nodes
    }

    private func node(path: String, url: URL, fm: FileManager) -> ProjectTreeNode {
        let children = (try? fm.contentsOfDirectory(atPath: path)) ?? []
        let modified = try? url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate
        return ProjectTreeNode(
            path: path,
            bytes: 0,
            modified: modified,
            childNames: children,
            gitignoreLines: children.contains(".gitignore") ? Self.gitignoreLines(in: path) : []
        )
    }

    /// Reads a folder's .gitignore, capped so a huge generated file can't
    /// stall the scan.
    private static func gitignoreLines(in directory: String) -> [String] {
        let path = (directory as NSString).appendingPathComponent(".gitignore")
        guard let handle = FileHandle(forReadingAtPath: path) else { return [] }
        defer { try? handle.close() }
        guard let data = try? handle.read(upToCount: 256 * 1024),
              let text = String(data: data, encoding: .utf8) else { return [] }
        return text.components(separatedBy: .newlines)
    }

    /// Counts hidden files too: pnpm keeps the whole store in node_modules/.pnpm.
    static func directoryBytes(_ url: URL) -> UInt64 {
        guard let enumerator = FileManager.default.enumerator(
            at: url,
            includingPropertiesForKeys: [.totalFileAllocatedSizeKey, .isRegularFileKey, .linkCountKey],
            options: []
        ) else { return 0 }
        var total: UInt64 = 0
        var hardLinks = HardLinkTracker()
        for case let fileURL as URL in enumerator {
            if Task.isCancelled { break }
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
}
