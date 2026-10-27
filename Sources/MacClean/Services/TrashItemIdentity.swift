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
              withoutTrailingSlash(url.standardizedFileURL.path(percentEncoded: false)) == path else {
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
        guard lstat(url.deletingLastPathComponent().path(percentEncoded: false), &parent) == 0 else {
            throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO)
        }
        return TrashItemIdentity(device: item.st_dev, inode: item.st_ino,
                                 parentDevice: parent.st_dev, parentInode: parent.st_ino,
                                 resolvedPath: resolved)
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
