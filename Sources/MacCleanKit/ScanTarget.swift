import Foundation

/// A description of *what* to scan. Pure data — no filesystem interaction.
/// Consumed by scanners in the MacClean target to perform actual enumeration.
public struct ScanTarget: Sendable, Equatable {
    public let path: URL
    public let recursive: Bool
    public let maxDepth: Int?
    public let fileExtensions: Set<String>?
    public let minAge: TimeInterval?
    public let maxAge: TimeInterval?
    public let minSize: UInt64?
    public let excludePatterns: [String]
    /// When true, the scanner prunes any hidden (dot-prefixed) directory and
    /// skips hidden files. Those subtrees hold application and developer state
    /// — caches, editor extensions, tool configs — not user-facing documents,
    /// so a content-oriented scan (e.g. the duplicate finder) should stay out
    /// of them. Off by default to preserve existing modules' behavior.
    public let skipHiddenDirectories: Bool
    /// Subtrees the scanner skips entirely (matched by path, not by name).
    /// Used when a more specific category owns a folder that sits under this
    /// target's root.
    public let excludedPaths: [URL]

    public init(
        path: URL,
        recursive: Bool = true,
        maxDepth: Int? = nil,
        fileExtensions: Set<String>? = nil,
        minAge: TimeInterval? = nil,
        maxAge: TimeInterval? = nil,
        minSize: UInt64? = nil,
        excludePatterns: [String] = [],
        skipHiddenDirectories: Bool = false,
        excludedPaths: [URL] = []
    ) {
        self.path = path
        self.recursive = recursive
        self.maxDepth = maxDepth
        // Normalize extensions to lowercase so case-insensitive matching works.
        self.fileExtensions = fileExtensions.map { Set($0.map { $0.lowercased() }) }
        self.minAge = minAge
        self.maxAge = maxAge
        self.minSize = minSize
        self.excludePatterns = excludePatterns
        self.skipHiddenDirectories = skipHiddenDirectories
        self.excludedPaths = excludedPaths
    }

    /// True if `url` is one of `excludedPaths` or lies inside one.
    public func isExcludedPath(_ url: URL) -> Bool {
        let path = url.path(percentEncoded: false)
        return excludedPaths.contains {
            PathExclusion.isInside(path, root: $0.path(percentEncoded: false))
        }
    }

    /// True if `url`'s last path component is dot-prefixed (hidden on Unix).
    /// The scanner uses this to prune hidden subtrees when
    /// `skipHiddenDirectories` is set.
    public static func isHiddenEntry(_ url: URL) -> Bool {
        url.lastPathComponent.hasPrefix(".")
    }

    /// Returns true if the given URL passes the target's name/extension/exclude rules.
    /// Does NOT check size or age — those require resource values from the filesystem
    /// and live in the scanner.
    public func matchesByNameRules(_ url: URL) -> Bool {
        let name = url.lastPathComponent

        for pattern in excludePatterns {
            if name.localizedCaseInsensitiveContains(pattern) {
                return false
            }
        }

        if let extensions = fileExtensions, !extensions.isEmpty {
            let ext = url.pathExtension.lowercased()
            if !extensions.contains(ext) {
                return false
            }
        }

        return true
    }

    /// Returns true if `size` meets the target's `minSize` requirement.
    public func passesSizeFilter(_ size: UInt64) -> Bool {
        guard let minSize else { return true }
        return size >= minSize
    }

    /// Returns true if a file with the given modification date passes
    /// the target's age filters, evaluated relative to `now`.
    public func passesAgeFilters(modificationDate: Date?, now: Date = Date()) -> Bool {
        guard minAge != nil || maxAge != nil else { return true }
        guard let modDate = modificationDate else { return false }
        let age = now.timeIntervalSince(modDate)
        if let minAge, age < minAge { return false }
        if let maxAge, age > maxAge { return false }
        return true
    }
}
