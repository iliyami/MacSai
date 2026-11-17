import XCTest
@testable import MacClean
import MacCleanKit
import MacCleanTestSupport

final class ClipboardArchivesIntegrationTests: XCTestCase {
    func testScanFindsLocalArchivesOfAllAgesAndLeavesFilesUntouched() async throws {
        try await TestFixtures.withTempDir { tmp in
            let root = tmp.appending(path: "shared-pasteboard/archives")
            let old = root.appending(path: UUID().uuidString)
            let recent = root.appending(path: UUID().uuidString)
            let metadata = root.appending(path: "metadata.plist")
            let nested = root.appending(path: "nested/\(UUID().uuidString)")
            let incoming = tmp.appending(path: "shared-pasteboard/items/\(UUID().uuidString)")
            let oldDate = Date().addingTimeInterval(-2 * 86400)
            for url in [old, metadata, nested, incoming] {
                try TestFixtures.writeFile(at: url, size: 1024, modificationDate: oldDate)
            }
            try TestFixtures.writeFile(at: recent, size: 512)
            let link = root.appending(path: UUID().uuidString)
            try FileManager.default.createSymbolicLink(at: link, withDestinationURL: incoming)

            let category = ClipboardArchivesCategory(archivesRoot: root)
            let scanned = await TargetedScanner().scan(targets: category.targets)
            let archives = category.filterArchives(scanned)
            XCTAssertEqual(Set(archives.map { $0.url.resolvingSymlinksInPath() }),
                           Set([old, recent].map { $0.resolvingSymlinksInPath() }))
            XCTAssertEqual(archives.reduce(0) { $0 + $1.size }, 1536)
            for url in [old, recent, metadata, nested, incoming, link] {
                XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
            }
        }
    }

    func testSystemJunkReportsDeniedArchiveRootInsteadOfAnEmptyCategory() async throws {
        try await TestFixtures.withTempDir { tmp in
            let parent = tmp.appending(path: "protected")
            let root = parent.appending(path: "archives")
            try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
            try FileManager.default.setAttributes([.posixPermissions: 0], ofItemAtPath: parent.path)
            defer { try? FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: parent.path) }
            let outcome = await SystemJunkModule().scanReportingPermissions(
                categories: [ClipboardArchivesCategory(archivesRoot: root)]
            )
            XCTAssertTrue(outcome.results.isEmpty)
            XCTAssertEqual(outcome.permissionDeniedPaths, [root])
        }
    }

    func testMissingArchiveRootDoesNotClaimPermissionFailure() async {
        let root = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        let outcome = await SystemJunkModule().scanReportingPermissions(
            categories: [ClipboardArchivesCategory(archivesRoot: root)]
        )
        XCTAssertTrue(outcome.results.isEmpty)
        XCTAssertTrue(outcome.permissionDeniedPaths.isEmpty)
    }
}
