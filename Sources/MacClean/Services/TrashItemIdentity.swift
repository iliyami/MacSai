import Darwin
import Foundation
import MacCleanKit

/// A second snapshot immediately before dispatch catches items or parents
/// replaced while the batch was being prepared. NSWorkspace owns the actual
/// move; this is not a claim that a path-based API eliminates every race.
struct TrashItemIdentity: Sendable, Equatable {
    let device: Int32
    let inode: UInt64
    let parentDevice: Int32
    let parentInode: UInt64
    let resolvedPath: String

    static func read(_ url: URL) throws -> TrashItemIdentity {
        let path = withoutTrailingSlash(url.path(percentEncoded: false))
        guard url.isFileURL, url.host == nil || url.host == "" || url.host == "localhost",
              path.hasPrefix("/"), path != "/", !path.contains("\0"),
              canonical(url.standardizedFileURL.path(percentEncoded: false)) == canonical(path) else {
            throw CocoaError(.fileReadInvalidFileName)
        }
        let resolved = url.resolvingSymlinksInPath().path(percentEncoded: false)
        // Accept the standard /var, /tmp and /etc macOS aliases, but do not
        // follow user-controlled symlinks into an unselected subtree.
        guard canonical(path) == canonical(resolved) else {
            throw CocoaError(.fileReadNoPermission, userInfo: [
                NSLocalizedDescriptionKey: L10n.tr(
                    "符号链接改变了清理路径。请在访达中检查。",
                    "A symbolic link changed this cleanup path. Review it in Finder.",
                    "Символическая ссылка изменяет путь очистки. Проверьте объект в Finder.")
            ])
        }
        var item = stat()
        var parent = stat()
        guard lstat(path, &item) == 0 else { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
        // Dangling or self-referential links may resolve to the same text.
        // Never treat a link itself as a movable regular file or directory.
        guard item.st_mode & S_IFMT != S_IFLNK else {
            throw CocoaError(.fileReadNoPermission)
        }
        guard lstat(url.deletingLastPathComponent().path(percentEncoded: false), &parent) == 0 else {
            throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO)
        }
        return TrashItemIdentity(device: item.st_dev, inode: item.st_ino,
                                 parentDevice: parent.st_dev, parentInode: parent.st_ino,
                                 resolvedPath: resolved)
    }

    /// A selected link is a benign skip only when its parent path has not
    /// been redirected. This does not follow the final link or accept paths
    /// with traversal, remote hosts, or a user-controlled parent symlink.
    static func isDirectSymbolicLink(_ url: URL) -> Bool {
        let path = withoutTrailingSlash(url.path(percentEncoded: false))
        guard url.isFileURL, url.host == nil || url.host == "" || url.host == "localhost",
              path.hasPrefix("/"), path != "/", !path.contains("\0") else { return false }
        let parts = path.split(separator: "/", omittingEmptySubsequences: false)
        guard parts.dropFirst().allSatisfy({ !$0.isEmpty && $0 != "." && $0 != ".." }) else { return false }
        var info = stat()
        guard lstat(path, &info) == 0, info.st_mode & S_IFMT == S_IFLNK else { return false }
        let parent = url.deletingLastPathComponent()
        return canonical(parent.path(percentEncoded: false))
            == canonical(parent.resolvingSymlinksInPath().path(percentEncoded: false))
    }

    private static func canonical(_ path: String) -> String {
        let path = withoutTrailingSlash(path)
        for alias in ["var", "tmp", "etc"] {
            let prefix = "/private/\(alias)"
            if path == prefix || path.hasPrefix(prefix + "/") {
                return String(path.dropFirst("/private".count))
            }
        }
        return path
    }

    private static func withoutTrailingSlash(_ path: String) -> String {
        path.count > 1 && path.hasSuffix("/") ? String(path.dropLast()) : path
    }
}
