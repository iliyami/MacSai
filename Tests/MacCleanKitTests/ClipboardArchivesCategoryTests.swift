import XCTest
@testable import MacCleanKit

final class ClipboardArchivesCategoryTests: XCTestCase {
    private let root = URL(filePath: "/Users/test/Library/Group Containers/group.com.apple.coreservices.useractivityd/shared-pasteboard/archives")
    private let now = Date(timeIntervalSince1970: 2_000_000_000)

    private func item(
        name: String = "93EC0B00-4EBA-44CA-8FBD-E108F0744609",
        age: TimeInterval? = 172800,
        directory: Bool = false,
        symlink: Bool = false,
        parent: URL? = nil
    ) -> FileItem {
        FileItem(url: (parent ?? root).appending(path: name), name: name,
                 size: 50_340_000_000, allocatedSize: 50_340_000_000,
                 isDirectory: directory, isSymlink: symlink,
                 modificationDate: age.map { now.addingTimeInterval(-$0) })
    }

    func testListsOldArchiveWithItsFullSizeButNeverPreselectsIt() {
        let category = ClipboardArchivesCategory(archivesRoot: root)
        let items = category.filterArchives([item()], now: now)
        let result = ScanResult(category: category.scanCategory, items: items,
                                autoSelect: category.scanCategory.autoSelect)
        XCTAssertEqual(result.totalSize, 50_340_000_000)
        XCTAssertTrue([result].preselectedURLs.isEmpty)
        XCTAssertEqual(category.scanCategory.cleanupSafety, .reviewFirst)
    }

    func testRejectsRecentFutureAndUnknownDates() {
        let category = ClipboardArchivesCategory(archivesRoot: root)
        for age: TimeInterval? in [0, 86399, -3600, nil] {
            XCTAssertTrue(category.filterArchives([item(age: age)], now: now).isEmpty)
        }
        XCTAssertEqual(category.filterArchives([item(age: 86400)], now: now).count, 1)
    }

    func testRejectsDirectoriesSymlinksUnknownNamesAndOtherLocations() {
        let category = ClipboardArchivesCategory(archivesRoot: root)
        let unsafe = [
            item(directory: true), item(symlink: true), item(name: "metadata.plist"),
            item(parent: root.appending(path: "nested")),
            item(parent: root.deletingLastPathComponent().appending(path: "items")),
            item(parent: URL(filePath: "/Users/test/Documents")),
        ]
        XCTAssertTrue(category.filterArchives(unsafe, now: now).isEmpty)
    }

    func testScanStaysInsideArchivesWithoutRecursing() {
        let category = ClipboardArchivesCategory()
        XCTAssertEqual(category.targets.count, 1)
        XCTAssertEqual(category.targets[0].path, MCConstants.userLibrary.appending(
            path: "Group Containers/group.com.apple.coreservices.useractivityd/shared-pasteboard/archives"
        ))
        XCTAssertFalse(category.targets[0].recursive)
        XCTAssertEqual(category.targets[0].minAge, 86400)
    }
}
