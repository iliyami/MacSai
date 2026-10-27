import Foundation
import XCTest
@testable import MacCleanKit

final class CleanupSelectionPolicyTests: XCTestCase {
    private func result(_ category: ScanCategory, autoSelect: Bool = true, size: UInt64 = 1) -> ScanResult {
        let url = URL(filePath: "/fixture/\(category.rawValue)")
        return ScanResult(category: category, items: [
            FileItem(url: url, name: category.rawValue, size: size, allocatedSize: size, isDirectory: false)
        ], autoSelect: autoSelect)
    }

    func testSafeSelectionExcludesPersonalDataAndIrreversibleActionsEvenWhenModuleOptsIn() {
        let results = ScanCategory.allCases.map { result($0) }
        let selected = CleanupSelectionPolicy.safeURLs(in: results)
        XCTAssertEqual(selected, Set([ScanCategory.userCaches, .systemCaches, .userLogs, .systemLogs,
                                      .brokenPreferences, .brokenLoginItems, .brokenDownloads,
                                      .incompleteDownloads, .oldUpdates]
            .map { URL(filePath: "/fixture/\($0.rawValue)") }))
    }

    func testSafeSelectionHonorsAnExplicitModuleOptOut() {
        XCTAssertTrue(CleanupSelectionPolicy.safeURLs(in: [result(.userCaches, autoSelect: false)]).isEmpty)
    }

    func testSelectAllIncludesReviewItemsOnlyThroughExplicitActionAndDeduplicatesURLs() {
        let cache = result(.userCaches)
        let trash = result(.trashBins)
        let binary = result(.universalBinaries, autoSelect: false)
        let results = [cache, cache, trash, binary]
        let all = CleanupSelectionPolicy.allURLs(in: results)
        XCTAssertEqual(all.count, 3)
        XCTAssertTrue(all.contains(trash.items[0].url))
        XCTAssertTrue(all.contains(binary.items[0].url))
        XCTAssertTrue(CleanupSelectionPolicy.requiresReview(in: results, selection: all))
        XCTAssertFalse(CleanupSelectionPolicy.requiresReview(in: results, selection: CleanupSelectionPolicy.safeURLs(in: results)))
    }

    func testSelectingSafeItemsReplacesAnEqualCountRiskySelectionAndUpdatesItsSize() {
        let cache = result(.userCaches, size: 100)
        let log = result(.userLogs, size: 200)
        let backup = result(.iosDeviceBackups, size: 10_000)
        let trash = result(.trashBins, size: 20_000)
        let results = [cache, log, backup, trash]
        let sizes = Dictionary(uniqueKeysWithValues: results.flatMap(\.items).map { ($0.url, $0.size) })
        let previous: Set<URL> = [backup.items[0].url, trash.items[0].url]
        let safe = CleanupSelectionPolicy.safeURLs(in: results)
        XCTAssertEqual(previous.count, safe.count)
        XCTAssertTrue(previous.isDisjoint(with: safe))
        XCTAssertEqual(CleanupSelectionPolicy.selectedSize(previous, sizesByURL: sizes), 30_000)
        XCTAssertEqual(CleanupSelectionPolicy.selectedSize(safe, sizesByURL: sizes), 300)
        XCTAssertEqual(CleanupSelectionPolicy.selectedCategories(in: results, selection: safe), [.userCaches, .userLogs])
    }
}
