import XCTest
import MacCleanKit
@testable import MacClean

final class CleanupConfirmationTests: EnglishAppLanguageTestCase {
    func testOrdinaryFilesOnlyPromiseTrashRecovery() {
        let message = cleanupConfirmationMessage(for: [.userCaches, .iosDeviceBackups])
        XCTAssertTrue(message.contains("moved to Trash"))
        XCTAssertFalse(message.contains("permanently deleted"))
        XCTAssertFalse(message.contains("reinstalling"))
    }

    func testTrashAndApplicationChangesDoNotPromiseTrashRecovery() {
        let message = cleanupConfirmationMessage(for: [.trashBins, .universalBinaries])
        XCTAssertTrue(message.contains("permanently deleted"))
        XCTAssertTrue(message.contains("reinstalling"))
        XCTAssertFalse(message.contains("moved to Trash"))
    }

    func testConfirmationReflectsOnlySelectedCategoriesAfterBulkAction() {
        func item(_ path: String) -> FileItem {
            FileItem(url: URL(filePath: path), name: path, size: 1, allocatedSize: 1, isDirectory: false)
        }
        let results = [
            ScanResult(category: .userCaches, items: [item("/cache")]),
            ScanResult(category: .trashBins, items: [item("/trash")], autoSelect: false),
            ScanResult(category: .universalBinaries, items: [item("/app")]),
        ]
        let selection = CleanupSelectionPolicy.allURLs(in: results)
        let message = cleanupConfirmationMessage(for: CleanupSelectionPolicy.selectedCategories(
            in: results, selection: selection))
        XCTAssertEqual(selection, [URL(filePath: "/cache")])
        XCTAssertTrue(message.contains("moved to Trash"))
        XCTAssertFalse(message.contains("permanently deleted"))
        XCTAssertFalse(message.contains("reinstalling"))
    }
}
