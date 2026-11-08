import XCTest
@testable import MacClean
import MacCleanKit
import MacCleanTestSupport

final class ClipboardArchivesIntegrationTests: XCTestCase {
    func testScanFindsOnlyOldLocalArchivesAndLeavesFilesUntouched() async throws {
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
            XCTAssertEqual(archives.map { $0.url.resolvingSymlinksInPath() }, [old.resolvingSymlinksInPath()])
            XCTAssertEqual(archives.first?.size, 1024)
            for url in [old, recent, metadata, nested, incoming, link] {
                XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
            }
        }
    }

}
