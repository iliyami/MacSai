import XCTest
import Foundation
@testable import MacCleanKit

final class XProtectDatabaseTests: XCTestCase {

    private let shaA = String(repeating: "a", count: 64)
    private let shaB = String(repeating: "b", count: 64)
    private let shaC = String(repeating: "c", count: 64)
    private let shaD = String(repeating: "d", count: 64)

    // MARK: - XProtect.yara

    /// Mirrors the real rule shapes in XProtect.yara: sized, size-less inside
    /// a `filesize <` guard, `(0, N)` pinned to `filesize == N`, and a
    /// private helper rule with no hashes.
    private var yaraFixture: String {
        """
        import "hash"

        private rule Macho
        {
            meta:
                description = "private rule to match Mach-O binaries"
            condition:
                uint32(0) == 0xfeedfacf
        }

        rule XProtect_MACOS_sized
        {
            meta:
                description = "MACOS.Sized"
            condition:
                Macho and filesize == 753024 and hash.sha256 ( 0 , filesize ) == "\(shaA.uppercased())"
        }

        rule XProtect_MACOS_unsized
        {
            meta:
                description = "MACOS.Unsized"
            condition:
                filesize < 20MB and ( ( hash.sha256 ( 0 , filesize ) == "\(shaB)" ) )
        }

        rule XProtect_MACOS_literal
        {
            condition:
                ( filesize == 361889 and hash.sha256 ( 0 , 361889 ) == "\(shaC)" ) or
                ( hash.sha256 ( 0 , 100 ) == "\(shaD)" )
        }
        """
    }

    func testParsesWholeFileHashesWithFamilyAndSize() {
        let hashes = XProtectDatabase.parseYaraHashRules(yaraFixture)
        let byDigest = Dictionary(uniqueKeysWithValues: hashes.map { ($0.digest, $0) })

        XCTAssertEqual(byDigest[shaA]?.fileSize, 753024)
        XCTAssertEqual(byDigest[shaA]?.family, "MACOS.Sized")
        XCTAssertEqual(byDigest[shaA]?.algorithm, .sha256)
        XCTAssertEqual(byDigest[shaA]?.source, .xprotect)

        XCTAssertNil(byDigest[shaB]?.fileSize, "a `filesize <` guard is not an exact size")
        XCTAssertEqual(byDigest[shaB]?.family, "MACOS.Unsized")

        XCTAssertEqual(byDigest[shaC]?.fileSize, 361889, "(0, N) with filesize == N is a whole-file hash")
        XCTAssertEqual(byDigest[shaC]?.family, "XProtect_MACOS_literal", "falls back to the rule name")
    }

    func testDigestsAreLowercased() {
        let hashes = XProtectDatabase.parseYaraHashRules(yaraFixture)
        XCTAssertTrue(hashes.contains { $0.digest == shaA })
        XCTAssertFalse(hashes.contains { $0.digest == shaA.uppercased() })
    }

    func testPrefixHashIsNotTreatedAsWholeFile() {
        let hashes = XProtectDatabase.parseYaraHashRules(yaraFixture)
        XCTAssertFalse(hashes.contains { $0.digest == shaD },
                       "hash.sha256(0, 100) without filesize == 100 hashes a prefix, never a whole file")
        XCTAssertEqual(hashes.count, 3)
    }

    func testRulesWithoutHashesContributeNothing() {
        let text = """
        rule XProtect_strings_only
        {
            meta:
                description = "MACOS.Strings"
            strings:
                $a = "evil"
            condition:
                all of them
        }
        """
        XCTAssertTrue(XProtectDatabase.parseYaraHashRules(text).isEmpty)
        XCTAssertTrue(XProtectDatabase.parseYaraHashRules("").isEmpty)
    }

    // MARK: - XProtect.plist

    private func plistData(_ object: Any) throws -> Data {
        try PropertyListSerialization.data(fromPropertyList: object, format: .xml, options: 0)
    }

    func testParsesNestedIdentitiesAsSHA1() throws {
        let identity = Data((0..<20).map { UInt8($0) })
        let nested = Data(repeating: 0xAB, count: 20)
        let data = try plistData([
            [
                "Description": "OSX.Proton.B",
                "Matches": [
                    ["Identity": identity, "MatchType": "Match",
                     "MatchFile": ["NSURLTypeIdentifierKey": "public.unix-executable"]],
                ],
            ],
            [
                "Description": "OSX.Nested.A",
                "Matches": [
                    ["MatchType": "MatchAny", "Matches": [
                        ["Identity": nested, "MatchType": "Match",
                         "MatchFile": ["NSURLFileSizeKey": 50000]],
                        ["Pattern": "414243", "MatchType": "Match"],
                    ]],
                ],
            ],
        ])

        let hashes = XProtectDatabase.parsePlistIdentities(data)
        XCTAssertEqual(hashes.count, 2, "hex Pattern entries are not hashes and are skipped")
        let proton = hashes.first { $0.family == "OSX.Proton.B" }
        XCTAssertEqual(proton?.algorithm, .sha1)
        XCTAssertEqual(proton?.digest, "000102030405060708090a0b0c0d0e0f10111213")
        XCTAssertNil(proton?.fileSize)
        let nestedHash = hashes.first { $0.family == "OSX.Nested.A" }
        XCTAssertEqual(nestedHash?.digest, String(repeating: "ab", count: 20))
        XCTAssertEqual(nestedHash?.fileSize, 50000)
    }

    func testMalformedPlistYieldsNothing() {
        XCTAssertTrue(XProtectDatabase.parsePlistIdentities(Data("not a plist".utf8)).isEmpty)
    }

    // MARK: - XProtect.meta.plist

    private func metaData() throws -> Data {
        try plistData([
            "Version": 5367,
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
        let blocked = XProtectDatabase.parseExtensionBlocklist(data)
        XCTAssertEqual(blocked.count, 2, "entries without a team id can't be matched safely and are dropped")
    }

    func testBlocklistNeedsBothBundleAndTeamIdentifier() throws {
        let snapshot = XProtectDatabase.Snapshot(
            version: 1,
            hashes: [],
            blockedSafariExtensions: XProtectDatabase.parseExtensionBlocklist(try metaData())
        )
        XCTAssertTrue(snapshot.isBlocked(bundleIdentifier: "com.searchnt.safari", teamIdentifier: "6ERPEMNB65"))
        XCTAssertFalse(snapshot.isBlocked(bundleIdentifier: "com.searchnt.safari", teamIdentifier: "AAAAAAAAAA"),
                       "same id from another developer is a different extension")
        XCTAssertFalse(snapshot.isBlocked(bundleIdentifier: "com.searchnt.safari", teamIdentifier: nil),
                       "unsigned code can't prove which developer it is")
        XCTAssertFalse(snapshot.isBlocked(bundleIdentifier: "com.example.fine", teamIdentifier: "6ERPEMNB65"))
    }

    // MARK: - load(bundle:readData:)

    func testLoadCombinesAllThreeFiles() throws {
        let bundle = URL(filePath: "/fixture/XProtect.bundle")
        let resources = bundle.appending(path: "Contents/Resources")
        let files: [String: Data] = [
            resources.appending(path: "XProtect.yara").path: Data(yaraFixture.utf8),
            resources.appending(path: "XProtect.plist").path: try plistData([
                ["Description": "OSX.Id", "Matches": [["Identity": Data(count: 20), "MatchType": "Match"]]],
            ]),
            resources.appending(path: "XProtect.meta.plist").path: try metaData(),
        ]
        let snapshot = XProtectDatabase.load(bundle: bundle) { files[$0.path] }
        XCTAssertEqual(snapshot.version, 5367)
        XCTAssertEqual(snapshot.hashes.count, 4)
        XCTAssertEqual(snapshot.hashes.filter { $0.algorithm == .sha1 }.count, 1)
        XCTAssertEqual(snapshot.blockedSafariExtensions.count, 2)
    }

    func testLoadWithMissingBundleIsEmpty() {
        let snapshot = XProtectDatabase.load(bundle: URL(filePath: "/nope")) { _ in nil }
        XCTAssertNil(snapshot.version)
        XCTAssertTrue(snapshot.hashes.isEmpty)
        XCTAssertTrue(snapshot.blockedSafariExtensions.isEmpty)
    }

    /// Guards against Apple changing the file format under us: the real
    /// bundle on this Mac must still yield hash signatures.
    func testParsesTheLiveXProtectBundle() throws {
        let yara = XProtectDatabase.defaultBundle.appending(path: "Contents/Resources/XProtect.yara")
        guard FileManager.default.isReadableFile(atPath: yara.path(percentEncoded: false)) else {
            throw XCTSkip("XProtect bundle not present on this machine")
        }
        let snapshot = XProtectDatabase.load { try? Data(contentsOf: $0) }
        XCTAssertNotNil(snapshot.version)
        XCTAssertGreaterThan(snapshot.hashes.filter { $0.algorithm == .sha256 }.count, 0)
        XCTAssertTrue(snapshot.hashes.allSatisfy { $0.digest.count == ($0.algorithm == .sha256 ? 64 : 40) })
    }
}
