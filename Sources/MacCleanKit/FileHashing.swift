import Foundation
import CryptoKit

/// Streaming SHA256 of a file's contents as a lowercase hex string.
/// Lives in MacCleanKit so both DuplicatesModule and FileConsolidator can hash
/// without depending on the app module. Returns nil if the file cannot be opened.
public enum FileHashing {
    public static func sha256(_ url: URL) -> String? {
        digests(of: url, algorithms: [.sha256])[.sha256]
    }

    /// Streaming SHA-1. Only used to match Apple's XProtect identities, which
    /// are published as SHA-1 digests; never use it for anything security-
    /// sensitive of our own.
    public static func sha1(_ url: URL) -> String? {
        digests(of: url, algorithms: [.sha1])[.sha1]
    }

    /// Every requested digest from a single read of the file, so asking for
    /// both SHA-1 and SHA-256 costs one pass over the bytes, not two. Empty
    /// if the file can't be opened.
    public static func digests(of url: URL, algorithms: Set<MalwareHashAlgorithm>) -> [MalwareHashAlgorithm: String] {
        guard !algorithms.isEmpty, let handle = try? FileHandle(forReadingFrom: url) else { return [:] }
        defer { try? handle.close() }
        var sha1 = algorithms.contains(.sha1) ? Insecure.SHA1() : nil
        var sha256 = algorithms.contains(.sha256) ? SHA256() : nil
        while true {
            let chunk = handle.readData(ofLength: 65536)
            if chunk.isEmpty { break }
            sha1?.update(data: chunk)
            sha256?.update(data: chunk)
        }
        var result: [MalwareHashAlgorithm: String] = [:]
        if let sha1 { result[.sha1] = hex(sha1.finalize()) }
        if let sha256 { result[.sha256] = hex(sha256.finalize()) }
        return result
    }

    private static func hex<D: Sequence>(_ digest: D) -> String where D.Element == UInt8 {
        digest.map { String(format: "%02x", $0) }.joined()
    }
}
