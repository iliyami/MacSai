import XCTest
import Foundation
@testable import MacCleanKit

final class XProtectDatabaseTests: XCTestCase {

    private func sha(_ character: Character) -> String { String(repeating: character, count: 64) }

    private func rule(_ name: String, _ condition: String, description: String? = nil) -> String {
        """
        rule \(name)
        {
            meta:
        \(description.map { "        description = \"\($0)\"" } ?? "        uuid = \"x\"")
            condition:
                \(condition)
        }

        """
    }

    private func parse(_ condition: String) -> [KnownMalwareHash] {
        XProtectDatabase.parseYaraHashRules(rule("R", condition, description: "MACOS.R"))
    }

    // MARK: - Real-world condition shapes (taken from the live XProtect.yara)

    func testMachoGuardedSizedHash() {
        let hashes = parse(#"Macho and filesize == 753024 and hash.sha256 ( 0 , filesize ) == "\#(sha("A"))""#)
        XCTAssertEqual(hashes.count, 1)
        XCTAssertEqual(hashes.first?.digest, sha("a"), "digests are lowercased")
        XCTAssertEqual(hashes.first?.fileSize, 753024)
        XCTAssertEqual(hashes.first?.requiredKind, .machO)
        XCTAssertEqual(hashes.first?.family, "MACOS.R")
        XCTAssertEqual(hashes.first?.source, .xprotect)
    }

    /// PrxlA: one size in front of a parenthesised group of hashes.
    func testSizeInFrontOfAHashGroupAppliesToEveryHash() {
        let hashes = parse(#"Macho and filesize == 90000 and ( hash.sha256 ( 0 , filesize ) == "\#(sha("a"))" or hash.sha256 ( 0 , filesize ) == "\#(sha("b"))" )"#)
        XCTAssertEqual(hashes.map(\.digest).sorted(), [sha("a"), sha("b")])
        XCTAssertTrue(hashes.allSatisfy { $0.fileSize == 90000 && $0.requiredKind == .machO })
    }

    /// Machook / InstallImitator: guard in front of size-and-hash pairs.
    func testGuardInFrontOfSizedPairs() {
        let hashes = parse(#"Macho and ( ( filesize == 5000 and hash.sha256 ( 0 , filesize ) == "\#(sha("a"))" ) or ( filesize == 6000 and hash.sha256 ( 0 , filesize ) == "\#(sha("b"))" ) )"#)
        XCTAssertEqual(Set(hashes.map { "\($0.digest.prefix(1)):\($0.fileSize ?? 0)" }), ["a:5000", "b:6000"])
        XCTAssertTrue(hashes.allSatisfy { $0.requiredKind == .machO })
    }

    /// EIGER_SUNOTO: `filesize <` is a bound, not a size; the hashes stay size-less.
    func testSizeBoundLeavesHashesUnsized() {
        let hashes = parse(#"filesize < 20MB and ( ( hash.sha256 ( 0 , filesize ) == "\#(sha("a"))" ) or ( hash.sha256 ( 0 , filesize ) == "\#(sha("b"))" ) )"#)
        XCTAssertEqual(hashes.count, 2)
        XCTAssertTrue(hashes.allSatisfy { $0.fileSize == nil && $0.requiredKind == nil })
    }

    /// `uint8(0) == 0x23` (first byte `#`) guards a script.
    func testScriptGuard() {
        let hashes = parse(#"uint8 ( 0 ) == 0x23 and ( ( filesize == 2113 and hash.sha256 ( 0 , filesize ) == "\#(sha("c"))" ) )"#)
        XCTAssertEqual(hashes.first?.requiredKind, .script)
        XCTAssertEqual(hashes.first?.fileSize, 2113)
    }

    /// EleanorA: a Mach-O magic compare is a Mach-O guard; anything else is opaque.
    func testUint32MagicGuard() {
        let machO = parse(#"uint32 ( 0 ) == 0xfeedfacf and ( filesize == 4096 and hash.sha256 ( 0 , filesize ) == "\#(sha("d"))" )"#)
        XCTAssertEqual(machO.first?.requiredKind, .machO)
        let other = parse(#"uint32 ( 0 ) == 0x504b0304 and filesize == 4096 and hash.sha256 ( 0 , filesize ) == "\#(sha("d"))""#)
        XCTAssertTrue(other.isEmpty, "an unknown magic is a condition we can't vouch for")
    }

    /// EIGER_BA / MONCH_BA: `hash.sha256(0, N)` is a whole-file hash only
    /// when the same chain pins `filesize == N`.
    func testLiteralLengthMustEqualThePinnedSize() {
        let hashes = parse(#"( filesize == 361889 and hash.sha256 ( 0 , 361889 ) == "\#(sha("a"))" ) or ( hash.sha256 ( 0 , 100 ) == "\#(sha("b"))" ) or ( filesize == 5000 and hash.sha256 ( 0 , 100 ) == "\#(sha("c"))" )"#)
        XCTAssertEqual(hashes.map(\.digest), [sha("a")])
        XCTAssertEqual(hashes.first?.fileSize, 361889)
    }

    /// MacDefender.B / QHostWB: a branch mixing in a string match is not a
    /// standalone signature; the pure size-and-hash branches are, but tiny
    /// unguarded ones (package components) are dropped.
    func testStringBranchesAreIgnoredAndTinyUnguardedHashesDropped() {
        let hashes = parse(#"(filesize <= 1000000 and $a) or (filesize == 461 and hash.sha256(0, filesize) == "\#(sha("a"))") or (filesize == 46 and hash.sha256(0, filesize) == "\#(sha("b"))") or (filesize == 20000 and hash.sha256(0, filesize) == "\#(sha("c"))")"#)
        XCTAssertEqual(hashes.map(\.digest), [sha("c")])
        XCTAssertEqual(XProtectDatabase.minimumUnguardedSize, 1024)
    }

    func testTinyGuardedHashesAreKept() {
        let hashes = parse(#"uint8 ( 0 ) == 0x23 and filesize == 730 and hash.sha256 ( 0 , filesize ) == "\#(sha("e"))""#)
        XCTAssertEqual(hashes.count, 1, "the type guard gives a small script hash its context")
    }

    func testHashCombinedWithOtherConditionsIsNotStandalone() {
        XCTAssertTrue(parse(#"Macho and $a and hash.sha256 ( 0 , filesize ) == "\#(sha("a"))""#).isEmpty)
        XCTAssertTrue(parse(#"not hash.sha256 ( 0 , filesize ) == "\#(sha("a"))""#).isEmpty)
        XCTAssertTrue(parse(#"hash.sha256 ( 0 , filesize ) == "\#(sha("a"))" and hash.sha256 ( 0 , filesize ) == "\#(sha("b"))""#).isEmpty)
        XCTAssertTrue(parse(#"Macho and Shebang and hash.sha256 ( 0 , filesize ) == "\#(sha("a"))""#).isEmpty,
                      "contradictory guards can't match any file")
        XCTAssertTrue(parse(#"filesize == 9000 and filesize == 9001 and hash.sha256 ( 0 , filesize ) == "\#(sha("a"))""#).isEmpty)
    }

    func testBareHashRuleIsKeptUnsizedAndUnguarded() {
        let hashes = parse(#"( hash.sha256 ( 0 , filesize ) == "\#(sha("f"))" )"#)
        XCTAssertEqual(hashes.count, 1)
        XCTAssertNil(hashes.first?.fileSize)
        XCTAssertNil(hashes.first?.requiredKind)
    }

    func testPrivateRulesStringRulesAndMalformedConditionsContributeNothing() {
        let text = """
        private rule Macho
        {
            condition:
                uint32(0) == 0xfeedfacf
        }
        """ + rule("Strings", "all of them") + rule("Broken", #"( hash.sha256 ( 0 , filesize ) == "\#(sha("a"))""#)
        XCTAssertTrue(XProtectDatabase.parseYaraHashRules(text).isEmpty)
        XCTAssertTrue(XProtectDatabase.parseYaraHashRules("").isEmpty)
    }

    func testFamilyFallsBackToTheRuleName() {
        let hashes = XProtectDatabase.parseYaraHashRules(rule("XProtect_MACOS_X", #"Macho and filesize == 5000 and hash.sha256 ( 0 , filesize ) == "\#(sha("a"))""#))
        XCTAssertEqual(hashes.first?.family, "XProtect_MACOS_X")
    }

    // MARK: - XProtect.plist

    private func plistData(_ object: Any) throws -> Data {
        try PropertyListSerialization.data(fromPropertyList: object, format: .xml, options: 0)
    }

    func testIdentitiesAtTopLevelAndUnderMatchAnyCount() throws {
        let top = Data((0..<20).map { UInt8($0) })
        let any = Data(repeating: 0xAB, count: 20)
        let data = try plistData([
            ["Description": "OSX.Proton.B",
             "Matches": [["Identity": top, "MatchType": "Match",
                          "MatchFile": ["NSURLTypeIdentifierKey": "public.unix-executable"]]]],
            ["Description": "OSX.Eleanor.A",
             "Matches": [["MatchType": "MatchAny", "Matches": [
                ["Identity": any, "MatchType": "Match"],
                ["Pattern": "414243", "MatchType": "Match"],
             ]]]],
        ])
        let hashes = XProtectDatabase.parsePlistIdentities(data)
        XCTAssertEqual(hashes.count, 2, "hex Pattern entries are not hashes and are skipped")
        XCTAssertEqual(hashes.first { $0.family == "OSX.Proton.B" }?.digest, "000102030405060708090a0b0c0d0e0f10111213")
        XCTAssertEqual(hashes.first { $0.family == "OSX.Eleanor.A" }?.algorithm, .sha1)
    }

    /// MacDefender.B: identities under MatchAll only mean malware together.
    func testIdentitiesUnderMatchAllAreSkipped() throws {
        let data = try plistData([
            ["Description": "OSX.MacDefender.B",
             "Matches": [["MatchType": "MatchAny", "Matches": [
                ["MatchType": "MatchAll", "Matches": [
                    ["Identity": Data(repeating: 1, count: 20), "MatchType": "Match",
                     "MatchFile": ["NSURLNameKey": "Description.plist"]],
                    ["Identity": Data(repeating: 2, count: 20), "MatchType": "Match",
                     "MatchFile": ["NSURLNameKey": "Archive.sizes"]],
                ]],
             ]]]],
        ])
        XCTAssertTrue(XProtectDatabase.parsePlistIdentities(data).isEmpty)
    }

    /// NSURLFileSizeKey values are shared limits (200000, 300000, …), not sizes.
    func testFileSizeKeyIsNotTreatedAsAnExactSize() throws {
        let data = try plistData([
            ["Description": "OSX.FileAgent",
             "Matches": [["Identity": Data(repeating: 3, count: 20), "MatchType": "Match",
                          "MatchFile": ["NSURLFileSizeKey": 200000, "NSURLNameKey": "FileAgent"]]]],
        ])
        XCTAssertNil(XProtectDatabase.parsePlistIdentities(data).first?.fileSize)
    }

    func testMalformedPlistYieldsNothing() {
        XCTAssertTrue(XProtectDatabase.parsePlistIdentities(Data("not a plist".utf8)).isEmpty)
    }

    // MARK: - XProtect.meta.plist

    private func metaData(version: Int = 5367) throws -> Data {
        try plistData([
            "Version": version,
            "ExtensionBlacklist": [
                "Extensions": [
                    ["CFBundleIdentifier": "com.searchnt.safari", "Developer Identifier": "6ERPEMNB65"],
                    ["CFBundleIdentifier": "com.searchnt.safari", "Developer Identifier": "LUZSN84HYP"],
                    ["CFBundleIdentifier": "missing.team"],
                ],
            ],
        ])
    }

    func testParsesVersionAndBlocklist() throws {
        let data = try metaData()
        XCTAssertEqual(XProtectDatabase.parseMetaVersion(data), 5367)
        XCTAssertEqual(XProtectDatabase.parseExtensionBlocklist(data).count, 2,
                       "entries without a team id can't be matched safely and are dropped")
    }

    func testBlocklistNeedsBothBundleAndTeamIdentifier() throws {
        let snapshot = XProtectDatabase.Snapshot(
            version: 1, hashes: [], blockedSafariExtensions: XProtectDatabase.parseExtensionBlocklist(try metaData()))
        XCTAssertTrue(snapshot.isBlocked(bundleIdentifier: "com.searchnt.safari", teamIdentifier: "6ERPEMNB65"))
        XCTAssertFalse(snapshot.isBlocked(bundleIdentifier: "com.searchnt.safari", teamIdentifier: "AAAAAAAAAA"))
        XCTAssertFalse(snapshot.isBlocked(bundleIdentifier: "com.searchnt.safari", teamIdentifier: nil))
        XCTAssertFalse(snapshot.isBlocked(bundleIdentifier: "com.example.fine", teamIdentifier: "6ERPEMNB65"))
    }

    // MARK: - Loading

    private func bundleFiles(at bundle: URL, version: Int, digest: Character) throws -> [String: Data] {
        let resources = bundle.appending(path: "Contents/Resources")
        return [
            resources.appending(path: "XProtect.yara").path: Data(rule("R", #"Macho and filesize == 5000 and hash.sha256 ( 0 , filesize ) == "\#(sha(digest))""#).utf8),
            resources.appending(path: "XProtect.plist").path: try plistData([
                ["Description": "OSX.Id", "Matches": [["Identity": Data(count: 20), "MatchType": "Match"]]],
            ]),
            resources.appending(path: "XProtect.meta.plist").path: try metaData(version: version),
        ]
    }

    func testLoadCombinesAllThreeFiles() throws {
        let bundle = URL(filePath: "/fixture/XProtect.bundle")
        let files = try bundleFiles(at: bundle, version: 5367, digest: "a")
        let snapshot = XProtectDatabase.load(bundle: bundle) { files[$0.path] }
        XCTAssertEqual(snapshot.version, 5367)
        XCTAssertEqual(snapshot.hashes.count, 2)
        XCTAssertEqual(snapshot.blockedSafariExtensions.count, 2)
    }

    /// macOS 15+ updates land in /private/var/protected/xprotect; the higher
    /// version wins whichever location it's in.
    func testLoadNewestPicksTheHigherVersion() throws {
        let shipped = URL(filePath: "/a/XProtect.bundle")
        let updated = URL(filePath: "/b/XProtect.bundle")
        var files = try bundleFiles(at: shipped, version: 5300, digest: "a")
        files.merge(try bundleFiles(at: updated, version: 5367, digest: "b")) { $1 }

        let newest = XProtectDatabase.loadNewest(bundles: [shipped, updated]) { files[$0.path] }
        XCTAssertEqual(newest.version, 5367)
        XCTAssertTrue(newest.hashes.contains { $0.digest == sha("b") })
        XCTAssertEqual(XProtectDatabase.loadNewest(bundles: [updated, shipped]) { files[$0.path] }.version, 5367)

        let onlyShipped = XProtectDatabase.loadNewest(bundles: [shipped, URL(filePath: "/missing")]) { files[$0.path] }
        XCTAssertEqual(onlyShipped.version, 5300, "a missing location is skipped, not preferred")
        XCTAssertEqual(XProtectDatabase.defaultBundles.map(\.path), [
            "/Library/Apple/System/Library/CoreServices/XProtect.bundle",
            "/private/var/protected/xprotect/XProtect.bundle",
        ])
    }

    func testLoadWithNoBundlesIsEmpty() {
        let snapshot = XProtectDatabase.loadNewest(bundles: [URL(filePath: "/nope")]) { _ in nil }
        XCTAssertNil(snapshot.version)
        XCTAssertTrue(snapshot.hashes.isEmpty)
        XCTAssertTrue(snapshot.blockedSafariExtensions.isEmpty)
    }

    /// Guards against Apple changing the format: every hash rule in the live
    /// bundle must parse, and the result must hold the known shapes.
    func testParsesTheLiveXProtectBundle() throws {
        guard let bundle = XProtectDatabase.defaultBundles.first(where: {
            FileManager.default.isReadableFile(atPath: $0.appending(path: "Contents/Resources/XProtect.yara").path(percentEncoded: false))
        }) else { throw XCTSkip("XProtect bundle not present on this machine") }
        let yara = try String(contentsOf: bundle.appending(path: "Contents/Resources/XProtect.yara"), encoding: .utf8)
        let hashRules = YaraRuleSplitter.rules(in: yara).filter { $0.condition.contains("hash.sha256") }
        XCTAssertFalse(hashRules.isEmpty)
        for rule in hashRules {
            XCTAssertNotNil(YaraConditionParser.parse(rule.condition), "\(rule.name) failed to parse")
        }
        let snapshot = XProtectDatabase.loadNewest { try? Data(contentsOf: $0) }
        XCTAssertNotNil(snapshot.version)
        XCTAssertTrue(snapshot.hashes.contains { $0.requiredKind == .machO })
        XCTAssertTrue(snapshot.hashes.allSatisfy { $0.digest.count == ($0.algorithm == .sha256 ? 64 : 40) })
        XCTAssertTrue(snapshot.hashes.allSatisfy { $0.requiredKind != nil || ($0.fileSize ?? .max) >= XProtectDatabase.minimumUnguardedSize })
    }

    // MARK: - Tokenizer

    func testTokenizerSplitsCallsComparisonsAndStrings() {
        XCTAssertEqual(
            YaraConditionParser.tokenize(#"hash.sha256(0, filesize)=="ab\"c" and uint8(0)!=0x23"#),
            ["hash.sha256", "(", "0", ",", "filesize", ")", "==", #""ab\"c""#, "and", "uint8", "(", "0", ")", "!=", "0x23"]
        )
        XCTAssertEqual(YaraConditionParser.number("20MB"), 20 * 1024 * 1024)
        XCTAssertEqual(YaraConditionParser.number("512KB"), 512 * 1024)
        XCTAssertEqual(YaraConditionParser.number("0xfeedfacf"), 0xFEEDFACF)
        XCTAssertNil(YaraConditionParser.number("filesize"))
    }
}
