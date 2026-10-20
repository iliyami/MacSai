import Foundation

/// Reads Apple's XProtect signatures straight from the bundle macOS ships and
/// silently updates on every Mac.
///
/// Why this source: it is public, maintained by Apple's threat team, updated
/// in the background by macOS, and already on disk, so using it needs no
/// network call and no database of our own to keep fresh.
///
/// What we evaluate, and what we deliberately don't:
/// - Exact-hash rules in `XProtect.yara` (`hash.sha256(0, filesize) == …`),
///   each with the size and file-type guard its own rule puts on it, and
///   SHA-1 `Identity` entries in `XProtect.plist` that stand on their own.
///   A hash match can't misfire on a legitimate file, so these hits are safe
///   to pre-select.
/// - The Safari extension blocklist in `XProtect.meta.plist`.
/// - NOT the YARA string/byte-pattern rules or the plist hex patterns. Those
///   need a full YARA engine to evaluate faithfully; a partial one would
///   produce false positives in a tool whose action is deletion. macOS
///   already runs those rules itself at launch time.
public enum XProtectDatabase {
    /// Where macOS keeps XProtect. On macOS 15+ updates land in the second
    /// location; the first is the copy that shipped with the OS. Both are
    /// read and the higher `Version` wins.
    public static let defaultBundles = [
        URL(filePath: "/Library/Apple/System/Library/CoreServices/XProtect.bundle"),
        URL(filePath: "/private/var/protected/xprotect/XProtect.bundle"),
    ]

    /// Sized hashes whose rule puts no file-type guard on them describe tiny
    /// package components (MacDefender.B lists 46 to 461 byte files). Content
    /// that small can be generic, so those are not used on their own.
    public static let minimumUnguardedSize: UInt64 = 1024

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

    /// Loads every bundle in `bundles` and keeps the one with the highest
    /// version. `readData` is injected so tests feed fixtures instead of the
    /// live system bundles.
    public static func loadNewest(
        bundles: [URL] = defaultBundles,
        readData: (URL) -> Data?
    ) -> Snapshot {
        var best: Snapshot?
        for bundle in bundles {
            let snapshot = load(bundle: bundle, readData: readData)
            guard snapshot.version != nil || !snapshot.hashes.isEmpty else { continue }
            if let current = best, (current.version ?? .min) >= (snapshot.version ?? .min) { continue }
            best = snapshot
        }
        return best ?? .empty
    }

    /// Loads one bundle. Missing files simply contribute nothing.
    public static func load(bundle: URL, readData: (URL) -> Data?) -> Snapshot {
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
    /// Each rule's `condition:` is parsed, and a hash is kept only when the
    /// `and`-chain around it holds nothing but constraints we understand: an
    /// exact `filesize ==`, a `filesize <` bound, or a file-type guard
    /// (`Macho`, `uint8(0) == 0x23`, …). A hash combined with anything else
    /// (a string match, another rule) isn't a standalone signature and is
    /// skipped. `hash.sha256(0, N)` only counts when the chain pins
    /// `filesize == N`; otherwise it hashes a prefix.
    public static func parseYaraHashRules(_ text: String) -> [KnownMalwareHash] {
        var hashes: [KnownMalwareHash] = []
        for rule in YaraRuleSplitter.rules(in: text) where !rule.isPrivate {
            guard let condition = YaraConditionParser.parse(rule.condition) else { continue }
            for signature in YaraConditionParser.hashSignatures(in: condition) {
                if signature.requiredKind == nil,
                   let size = signature.fileSize, size < minimumUnguardedSize { continue }
                hashes.append(KnownMalwareHash(
                    algorithm: .sha256,
                    digest: signature.digest,
                    fileSize: signature.fileSize,
                    requiredKind: signature.requiredKind,
                    family: rule.description ?? rule.name,
                    source: .xprotect
                ))
            }
        }
        return hashes
    }

    // MARK: - XProtect.plist

    /// SHA-1 `Identity` digests that identify malware on their own: at the
    /// top level of an entry, or as one alternative of a `MatchAny`. An
    /// identity under `MatchAll` only means malware together with its
    /// siblings (e.g. MacDefender.B's `Description.plist` + `Archive.sizes`),
    /// so it's skipped.
    ///
    /// `NSURLFileSizeKey` is not used as an exact size: its values (200000,
    /// 300000, 50000, …) are shared by many hashes and act as limits.
    public static func parsePlistIdentities(_ data: Data) -> [KnownMalwareHash] {
        guard let entries = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [[String: Any]]
        else { return [] }
        var hashes: [KnownMalwareHash] = []
        func walk(_ matches: [[String: Any]], family: String) {
            for match in matches {
                if let identity = match["Identity"] as? Data, identity.count == 20 {
                    hashes.append(KnownMalwareHash(
                        algorithm: .sha1,
                        digest: identity.map { String(format: "%02x", $0) }.joined(),
                        fileSize: nil,
                        family: family,
                        source: .xprotect
                    ))
                }
                if let nested = match["Matches"] as? [[String: Any]],
                   (match["MatchType"] as? String) != "MatchAll" {
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

// MARK: - YARA rule splitting

/// Cuts a YARA file into rules: name, `private` flag, `description` meta and
/// the raw `condition:` text. Only what hash extraction needs.
enum YaraRuleSplitter {
    struct Rule {
        let name: String
        let isPrivate: Bool
        let description: String?
        let condition: String
    }

    static func rules(in text: String) -> [Rule] {
        guard let header = try? NSRegularExpression(pattern: #"(?m)^\s*(private\s+)?rule\s+([A-Za-z0-9_]+)"#),
              let description = try? NSRegularExpression(pattern: #"description\s*=\s*"([^"]+)""#)
        else { return [] }
        let ns = text as NSString
        let headers = header.matches(in: text, range: NSRange(location: 0, length: ns.length))
        var rules: [Rule] = []
        for (index, match) in headers.enumerated() {
            let start = match.range.location
            let end = index + 1 < headers.count ? headers[index + 1].range.location : ns.length
            let block = ns.substring(with: NSRange(location: start, length: end - start))
            let blockNS = block as NSString
            let desc = description.firstMatch(in: block, range: NSRange(location: 0, length: blockNS.length))
                .map { blockNS.substring(with: $0.range(at: 1)) }
            guard let conditionStart = block.range(of: "condition:"),
                  let closing = block.range(of: "}", options: .backwards),
                  conditionStart.upperBound <= closing.lowerBound else { continue }
            rules.append(Rule(
                name: ns.substring(with: match.range(at: 2)),
                isPrivate: match.range(at: 1).location != NSNotFound,
                description: desc,
                condition: String(block[conditionStart.upperBound..<closing.lowerBound])
            ))
        }
        return rules
    }
}

// MARK: - YARA condition parsing (hash extraction only)

/// A deliberately small parser: `and` / `or` / `not` / parentheses over
/// atoms. Atoms it recognises (`filesize` comparisons, `hash.sha256(...)`,
/// file-type guards) are typed; everything else is opaque, and an opaque
/// atom in a hash's `and`-chain disqualifies that hash.
enum YaraConditionParser {
    indirect enum Node: Equatable {
        case and([Node])
        case or([Node])
        case atom(Atom)
    }

    enum Atom: Equatable {
        case exactSize(UInt64)
        /// `filesize <`/`<=` bound: implied by any exact hash match.
        case sizeBound
        case kind(MalwareFileKind)
        /// `hash.sha256(0, length) == digest`; `length` nil means `filesize`.
        case sha256(length: UInt64?, digest: String)
        case opaque
    }

    struct HashSignature: Equatable {
        let digest: String
        let fileSize: UInt64?
        let requiredKind: MalwareFileKind?
    }

    // MARK: Tokens

    static func tokenize(_ text: String) -> [String] {
        var tokens: [String] = []
        var current = ""
        var iterator = Array(text).makeIterator()
        var pending: Character?
        func flush() {
            if !current.isEmpty { tokens.append(current); current = "" }
        }
        while let ch = pending ?? iterator.next() {
            pending = nil
            switch ch {
            case "\"":
                flush()
                var literal = "\""
                while let next = iterator.next() {
                    literal.append(next)
                    if next == "\\", let escaped = iterator.next() { literal.append(escaped); continue }
                    if next == "\"" { break }
                }
                tokens.append(literal)
            case "(", ")", ",":
                flush()
                tokens.append(String(ch))
            case "=", "<", ">", "!":
                flush()
                if let next = iterator.next() {
                    if next == "=" { tokens.append(String(ch) + "=") } else { tokens.append(String(ch)); pending = next }
                } else {
                    tokens.append(String(ch))
                }
            case _ where ch.isWhitespace:
                flush()
            default:
                current.append(ch)
            }
        }
        flush()
        return tokens
    }

    // MARK: Grammar

    static func parse(_ text: String) -> Node? {
        var parser = Parser(tokens: tokenize(text))
        guard let node = parser.parseOr(), parser.index == parser.tokens.count else { return nil }
        return node
    }

    private struct Parser {
        let tokens: [String]
        var index = 0

        mutating func parseOr() -> Node? {
            guard var first = parseAnd() else { return nil }
            var children = [first]
            while index < tokens.count, tokens[index] == "or" {
                index += 1
                guard let next = parseAnd() else { return nil }
                children.append(next)
            }
            if children.count > 1 { first = .or(children) }
            return first
        }

        mutating func parseAnd() -> Node? {
            guard var first = parseUnary() else { return nil }
            var children = [first]
            while index < tokens.count, tokens[index] == "and" {
                index += 1
                guard let next = parseUnary() else { return nil }
                children.append(next)
            }
            if children.count > 1 { first = .and(children) }
            return first
        }

        mutating func parseUnary() -> Node? {
            guard index < tokens.count else { return nil }
            if tokens[index] == "not" {
                index += 1
                // Whatever is negated, the result is opaque for extraction.
                guard parseUnary() != nil else { return nil }
                return .atom(.opaque)
            }
            if tokens[index] == "(" {
                index += 1
                guard let inner = parseOr(), index < tokens.count, tokens[index] == ")" else { return nil }
                index += 1
                return inner
            }
            return parseAtom()
        }

        /// Collects tokens up to the next `and` / `or` / unmatched `)`,
        /// keeping parentheses that belong to the atom (function calls,
        /// `N of ( $a* )`).
        mutating func parseAtom() -> Node? {
            var atomTokens: [String] = []
            var depth = 0
            while index < tokens.count {
                let token = tokens[index]
                if depth == 0, token == "and" || token == "or" || token == ")" { break }
                if token == "(" { depth += 1 }
                if token == ")" { depth -= 1 }
                atomTokens.append(token)
                index += 1
            }
            guard !atomTokens.isEmpty, depth == 0 else { return nil }
            return .atom(YaraConditionParser.classify(atomTokens))
        }
    }

    // MARK: Atoms

    private static let machOMagics: Set<UInt64> = [0xFEEDFACE, 0xCEFAEDFE, 0xFEEDFACF, 0xCFFAEDFE, 0xCAFEBABE, 0xBEBAFECA]

    static func classify(_ tokens: [String]) -> Atom {
        switch tokens {
        case ["Macho"], ["Dylib"]:
            return .kind(.machO)
        case ["Shebang"]:
            return .kind(.script)
        case let t where t.count == 3 && t[0] == "filesize" && t[1] == "==":
            return number(t[2]).map(Atom.exactSize) ?? .opaque
        case let t where t.count == 3 && t[0] == "filesize" && (t[1] == "<" || t[1] == "<="):
            return number(t[2]) != nil ? .sizeBound : .opaque
        case let t where t.count == 8 && t[0] == "hash.sha256" && t[1] == "(" && t[2] == "0" && t[3] == ","
            && t[5] == ")" && t[6] == "==":
            guard let digest = hexDigest(t[7]) else { return .opaque }
            if t[4] == "filesize" { return .sha256(length: nil, digest: digest) }
            guard let length = number(t[4]) else { return .opaque }
            return .sha256(length: length, digest: digest)
        case let t where t.count == 6 && t[1] == "(" && t[2] == "0" && t[3] == ")" && t[4] == "==":
            // uint8(0) == 0x23 ('#'), uint16(0) == 0x2123 ("#!" little
            // endian), uint32/uint32be(0) == a Mach-O magic.
            guard let value = number(t[5]) else { return .opaque }
            switch t[0] {
            case "uint8" where value == 0x23, "uint16" where value == 0x2123, "uint16be" where value == 0x2321:
                return .kind(.script)
            case "uint32", "uint32be":
                return machOMagics.contains(value) ? .kind(.machO) : .opaque
            default:
                return .opaque
            }
        default:
            return .opaque
        }
    }

    /// Decimal, `0x` hex, or a decimal with a `KB` / `MB` suffix.
    static func number(_ token: String) -> UInt64? {
        let lower = token.lowercased()
        if lower.hasPrefix("0x") { return UInt64(lower.dropFirst(2), radix: 16) }
        if lower.hasSuffix("kb") { return UInt64(lower.dropLast(2)).map { $0 * 1024 } }
        if lower.hasSuffix("mb") { return UInt64(lower.dropLast(2)).map { $0 * 1024 * 1024 } }
        return UInt64(lower)
    }

    private static func hexDigest(_ token: String) -> String? {
        guard token.count == 66, token.hasPrefix("\""), token.hasSuffix("\"") else { return nil }
        let digest = token.dropFirst().dropLast().lowercased()
        guard digest.allSatisfy({ ("0"..."9").contains($0) || ("a"..."f").contains($0) }) else { return nil }
        return String(digest)
    }

    // MARK: Extraction

    private struct Context {
        var size: UInt64?
        var kind: MalwareFileKind?
        var opaque = false
        var contradictory = false
    }

    static func hashSignatures(in node: Node) -> [HashSignature] {
        signatures(in: node, context: Context())
    }

    private static func signatures(in node: Node, context: Context) -> [HashSignature] {
        switch node {
        case .or(let children):
            return children.flatMap { signatures(in: $0, context: context) }
        case .atom(let atom):
            return signatures(in: .and([.atom(atom)]), context: context)
        case .and(let children):
            var context = context
            var hashAtoms: [(UInt64?, String)] = []
            var composites: [Node] = []
            for child in children {
                switch child {
                case .atom(.exactSize(let size)):
                    if let existing = context.size, existing != size { context.contradictory = true }
                    context.size = size
                case .atom(.sizeBound):
                    break
                case .atom(.kind(let kind)):
                    if let existing = context.kind, existing != kind { context.contradictory = true }
                    context.kind = kind
                case .atom(.sha256(let length, let digest)):
                    hashAtoms.append((length, digest))
                case .atom(.opaque):
                    context.opaque = true
                case .and, .or:
                    composites.append(child)
                }
            }
            if context.opaque || context.contradictory { return [] }
            // Two different hashes in one chain can't both hold for a file.
            if hashAtoms.count > 1 { return [] }
            if hashAtoms.count == 1, !composites.isEmpty { return [] }
            var result: [HashSignature] = []
            if let (length, digest) = hashAtoms.first {
                if let length, length != context.size { return [] }
                result.append(HashSignature(digest: digest, fileSize: context.size, requiredKind: context.kind))
            }
            for composite in composites {
                result += signatures(in: composite, context: context)
            }
            return result
        }
    }
}
