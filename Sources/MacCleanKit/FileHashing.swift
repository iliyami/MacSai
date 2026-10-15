import Foundation
import CryptoKit

/// Streaming SHA256 of a file's contents as a lowercase hex string.
/// Lives in MacCleanKit so both DuplicatesModule and FileConsolidator can hash
/// without depending on the app module. Returns nil if the file cannot be opened.
public enum FileHashing {
    public static func sha256(_ url: URL) -> String? {
        digest(of: url, using: SHA256())
    }

    /// Streaming SHA-1. Only used to match Apple's XProtect identities, which
    /// are published as SHA-1 digests; never use it for anything security-
    /// sensitive of our own.
    public static func sha1(_ url: URL) -> String? {
        digest(of: url, using: Insecure.SHA1())
    }

    private static func digest<H: HashFunction>(of url: URL, using initial: H) -> String? {
        guard let handle = try? FileHandle(forReadingFrom: url) else { return nil }
        defer { try? handle.close() }
        var hasher = initial
        while true {
            let chunk = handle.readData(ofLength: 65536)
            if chunk.isEmpty { break }
            hasher.update(data: chunk)
        }
        return hasher.finalize().map { String(format: "%02x", $0) }.joined()
    }
}
