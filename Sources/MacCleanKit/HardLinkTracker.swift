import Foundation

/// Counts each physical file once when a scan sums sizes over a tree.
///
/// A hard-linked file has several paths but one inode and one set of data
/// blocks, yet `URLResourceValues` reports the full allocated size at every
/// path. Summing per path counts it once per link, the way `du -l` does:
/// `~/Library/Metadata/CoreSpotlight` measured 28 GB that way against 5.1 GB
/// from plain `du`, which counts each inode once. A walk keeps one tracker for
/// the whole scan and asks `shouldCount` before adding a file's size.
///
/// Only files with a link count above 1 are stat'ed and remembered, so the
/// common case costs nothing beyond reading `.linkCountKey`, which callers
/// prefetch alongside their size keys.
public struct HardLinkTracker: Sendable {
    public struct Identity: Hashable, Sendable {
        public let device: UInt64
        public let inode: UInt64

        public init(device: UInt64, inode: UInt64) {
            self.device = device
            self.inode = inode
        }
    }

    private var seen: Set<Identity> = []

    public init() {}

    /// Number of multi-link files remembered so far.
    public var trackedCount: Int { seen.count }

    /// True the first time an identity is offered, false for every later link.
    public mutating func firstSighting(of identity: Identity) -> Bool {
        seen.insert(identity).inserted
    }

    /// True when `url`'s size should be added to the running total. Files with
    /// a single link (or an unknown count) always count. Directories always
    /// count too: their link count tracks subdirectories, not shared data. If
    /// `lstat` fails the file counts, so a race never hides real bytes.
    public mutating func shouldCount(_ url: URL, linkCount: Int?) -> Bool {
        guard let linkCount, linkCount > 1 else { return true }
        var info = stat()
        guard lstat(url.path(percentEncoded: false), &info) == 0,
              info.st_mode & S_IFMT != S_IFDIR else { return true }
        return firstSighting(of: Identity(device: UInt64(UInt32(bitPattern: info.st_dev)),
                                          inode: UInt64(info.st_ino)))
    }
}
