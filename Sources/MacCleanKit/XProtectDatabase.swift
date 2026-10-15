import Foundation

/// Reads Apple's XProtect signatures straight from the bundle macOS ships and
/// silently updates on every Mac:
/// `/Library/Apple/System/Library/CoreServices/XProtect.bundle`.
///
/// Why this source: it is public, maintained by Apple's threat team, updated
/// in the background by `softwareupdate`, and already on disk, so using it
/// needs no network call and no database of our own to keep fresh.
///
/// What we evaluate, and what we deliberately don't:
/// - Exact-hash rules in `XProtect.yara` (`hash.sha256(0, filesize) == …`)
///   and SHA-1 `Identity` entries in `XProtect.plist`. A hash match can't
///   misfire on a legitimate file, so these hits are safe to pre-select.
/// - The Safari extension blocklist in `XProtect.meta.plist`.
/// - NOT the YARA string/byte-pattern rules or the plist hex patterns. Those
///   need a full YARA engine to evaluate faithfully; a partial one would
///   produce false positives in a tool whose action is deletion. macOS
///   already runs those rules itself at launch time.
public enum XProtectDatabase {
    public static let defaultBundle = URL(
        filePath: "/Library/Apple/System/Library/CoreServices/XProtect.bundle"
    )

    public struct BlockedSafariExtension: Hashable, Sendable {
        public let bundleIdentifier: String
        public let teamIdentifier: String

        public init(bundleIdentifier: String, teamIdentifier: String) {
            self.bundleIdentifier = bundleIdentifier
            self.teamIdentifier = teamIdentifier
        }
    }

    public struct Snapshot: Sendable {
        /// `XProtect.meta.plist` → `Version`, e.g. 5367. Nil when unreadable.
        public let version: Int?
        public let hashes: [KnownMalwareHash]
        public let blockedSafariExtensions: Set<BlockedSafariExtension>

        public init(version: Int?, hashes: [KnownMalwareHash], blockedSafariExtensions: Set<BlockedSafariExtension>) {
            self.version = version
            self.hashes = hashes
            self.blockedSafariExtensions = blockedSafariExtensions
        }

        public static let empty = Snapshot(version: nil, hashes: [], blockedSafariExtensions: [])

        /// True if Apple blocklists this exact extension (bundle id AND team
        /// id, the pairing Apple uses, so a lookalike id from another
        /// developer never matches).
        public func isBlocked(bundleIdentifier: String, teamIdentifier: String?) -> Bool {
            guard let teamIdentifier else { return false }
            return blockedSafariExtensions.contains(
                BlockedSafariExtension(bundleIdentifier: bundleIdentifier, teamIdentifier: teamIdentifier)
            )
        }
    }

    /// Loads everything from `bundle`. `readData` is injected so tests feed
    /// fixtures instead of the live system bundle. Missing files simply
    /// contribute nothing.
    public static func load(
        bundle: URL = defaultBundle,
        readData: (URL) -> Data?
    ) -> Snapshot {
        let resources = bundle.appending(path: "Contents/Resources")
        var hashes: [KnownMalwareHash] = []
        if let data = readData(resources.appending(path: "XProtect.yara")),
           let text = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) {
            hashes.append(contentsOf: parseYaraHashRules(text))
        }
        if let data = readData(resources.appending(path: "XProtect.plist")) {
            hashes.append(contentsOf: parsePlistIdentities(data))
        }
        var version: Int?
        var blocked: Set<BlockedSafariExtension> = []
        if let data = readData(resources.appending(path: "XProtect.meta.plist")) {
            version = parseMetaVersion(data)
            blocked = parseExtensionBlocklist(data)
        }
        return Snapshot(version: version, hashes: hashes, blockedSafariExtensions: blocked)
    }

    // MARK: - XProtect.yara

    /// Every whole-file SHA-256 in the rules, tagged with the rule's
    /// `description` (Apple's family name, e.g. "MACOS.644e18d").
    ///
    /// Matches `filesize == N and hash.sha256(0, filesize|N) == "…"`, with
    /// the size clause optional. A literal length is only a whole-file hash
    /// when it equals the asserted filesize; otherwise it hashes a prefix and
    /// is skipped.
    public static func parseYaraHashRules(_ text: String) -> [KnownMalwareHash] {
        // Built per call: NSRegularExpression isn't Sendable, and this runs
        // once per database load.
        guard let hashClause = try? NSRegularExpression(
                pattern: #"(?:filesize\s*==\s*(\d+)\s+and\s+)?hash\.sha256\s*\(\s*0\s*,\s*(filesize|\d+)\s*\)\s*==\s*"([0-9a-fA-F]{64})""#),
              let ruleHeader = try? NSRegularExpression(pattern: #"(?m)^\s*(private\s+)?rule\s+([A-Za-z0-9_]+)"#),
              let descriptionMeta = try? NSRegularExpression(pattern: #"description\s*=\s*"([^"]+)""#)
        else { return [] }
        let ns = text as NSString
        let headers = ruleHeader.matches(in: text, range: NSRange(location: 0, length: ns.length))
        var hashes: [KnownMalwareHash] = []
        for (index, header) in headers.enumerated() {
            let start = header.range.location
            let end = index + 1 < headers.count ? headers[index + 1].range.location : ns.length
            let blockRange = NSRange(location: start, length: end - start)
            let block = ns.substring(with: blockRange)
            let ruleName = ns.substring(with: header.range(at: 2))
            let blockNS = block as NSString
            let family = descriptionMeta.firstMatch(in: block, range: NSRange(location: 0, length: blockNS.length))
                .map { blockNS.substring(with: $0.range(at: 1)) } ?? ruleName

            for match in hashClause.matches(in: block, range: NSRange(location: 0, length: blockNS.length)) {
                let sizeText = match.range(at: 1).location == NSNotFound ? nil : blockNS.substring(with: match.range(at: 1))
                let lengthText = blockNS.substring(with: match.range(at: 2))
                let digest = blockNS.substring(with: match.range(at: 3))
                let assertedSize = sizeText.flatMap { UInt64($0) }
                if lengthText != "filesize" {
                    // Prefix hash unless the rule pins filesize to the same N.
                    guard let length = UInt64(lengthText), length == assertedSize else { continue }
                }
                hashes.append(KnownMalwareHash(
                    algorithm: .sha256,
                    digest: digest,
                    fileSize: assertedSize,
                    family: family,
                    source: .xprotect
                ))
            }
        }
        return hashes
    }

    // MARK: - XProtect.plist

    /// SHA-1 `Identity` digests anywhere in the (possibly nested) `Matches`.
    public static func parsePlistIdentities(_ data: Data) -> [KnownMalwareHash] {
        guard let entries = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [[String: Any]]
        else { return [] }
        var hashes: [KnownMalwareHash] = []
        func walk(_ matches: [[String: Any]], family: String) {
            for match in matches {
                if let identity = match["Identity"] as? Data, identity.count == 20 {
                    let size = ((match["MatchFile"] as? [String: Any])?["NSURLFileSizeKey"] as? NSNumber)?.uint64Value
                    hashes.append(KnownMalwareHash(
                        algorithm: .sha1,
                        digest: identity.map { String(format: "%02x", $0) }.joined(),
                        fileSize: size,
                        family: family,
                        source: .xprotect
                    ))
                }
                if let nested = match["Matches"] as? [[String: Any]] {
                    walk(nested, family: family)
                }
            }
        }
        for entry in entries {
            let family = entry["Description"] as? String ?? "XProtect"
            walk(entry["Matches"] as? [[String: Any]] ?? [], family: family)
        }
        return hashes
    }

    // MARK: - XProtect.meta.plist

    public static func parseMetaVersion(_ data: Data) -> Int? {
        guard let meta = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        else { return nil }
        return (meta["Version"] as? NSNumber)?.intValue
    }

    public static func parseExtensionBlocklist(_ data: Data) -> Set<BlockedSafariExtension> {
        guard let meta = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
              let list = (meta["ExtensionBlacklist"] as? [String: Any])?["Extensions"] as? [[String: Any]]
        else { return [] }
        var result: Set<BlockedSafariExtension> = []
        for entry in list {
            guard let bundleID = entry["CFBundleIdentifier"] as? String, !bundleID.isEmpty,
                  let team = entry["Developer Identifier"] as? String, !team.isEmpty else { continue }
            result.insert(BlockedSafariExtension(bundleIdentifier: bundleID, teamIdentifier: team))
        }
        return result
    }
}
