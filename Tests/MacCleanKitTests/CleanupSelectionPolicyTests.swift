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

    func testSelectAllHonorsBothOptOutsAndDeduplicatesEligibleURLs() {
        let cache = result(.userCaches)
        let resultOptOut = result(.userLogs, autoSelect: false)
        let categoryOptOut = result(.universalBinaries)
        let all = CleanupSelectionPolicy.allURLs(in: [cache, cache, resultOptOut, categoryOptOut])
        XCTAssertEqual(all, [cache.items[0].url])
    }

    func testPossibleAndCommunityReportedThreatsNeverEnterGlobalSelection() {
        // MalwareBazaar/community reports and blocklist detections share
        // possibleThreats on main. Even a mistaken scanner opt-in stays out.
        let possible = result(.possibleThreats)
        let reported = ScanResult(category: .possibleThreats, items: [
            FileItem(url: URL(filePath: "/fixture/community-report"), name: "report",
                     size: 1, allocatedSize: 1, isDirectory: false)
        ], autoSelect: false)
        let confirmed = result(.malware)
        let results = [possible, reported, confirmed]
        XCTAssertEqual(CleanupSelectionPolicy.allURLs(in: results), [confirmed.items[0].url])
        XCTAssertTrue(CleanupSelectionPolicy.safeURLs(in: results).isEmpty)
    }

    func testOptOutCannotBeBypassedByDuplicateURLInAnEligibleResult() {
        let cache = result(.userCaches)
        for reviewOnly in [
            ScanResult(category: .userLogs, items: cache.items, autoSelect: false),
            ScanResult(category: .possibleThreats, items: cache.items),
            ScanResult(category: .deletedUsers, items: cache.items),
        ] {
            let results = [cache, reviewOnly]
            XCTAssertTrue(CleanupSelectionPolicy.allURLs(in: results).isEmpty)
            XCTAssertTrue(CleanupSelectionPolicy.safeURLs(in: results).isEmpty)
        }
    }

    func testInitialSelectionPreservesAllScannerAndCategoryOptIns() {
        let results = ScanCategory.allCases.map { result($0) }
        let expected = Set(results.filter { $0.autoSelect && $0.category.autoSelect }
            .flatMap { $0.items.map(\.url) })
        let initial = CleanupSelectionPolicy.initialURLs(in: results)
        XCTAssertEqual(initial, expected)
        // These categories request review but historically start selected.
        // Their initial state must not inherit the explicit Safe Items filter.
        for category in [ScanCategory.malware, .trashBins, .iosDeviceBackups, .languageFiles] {
            XCTAssertTrue(initial.contains(URL(filePath: "/fixture/\(category.rawValue)")))
        }
        XCTAssertTrue(CleanupSelectionPolicy.initialURLs(in: [result(.malware, autoSelect: false)]).isEmpty)
        XCTAssertTrue(CleanupSelectionPolicy.initialURLs(in: [result(.deletedUsers)]).isEmpty)
    }

    func testManualCategorySelectionStillAllowsReviewOnlyResults() {
        for category in [ScanCategory.possibleThreats, .deletedUsers, .universalBinaries] {
            let review = result(category, autoSelect: false)
            let selection = CleanupSelectionPolicy.togglingCategory(category, in: [review], selection: [])
            XCTAssertEqual(selection, [review.items[0].url])
            XCTAssertTrue(CleanupSelectionPolicy.requiresReview(in: [review], selection: selection))
            XCTAssertTrue(CleanupSelectionPolicy.togglingCategory(category, in: [review], selection: selection).isEmpty)
        }
    }

    func testCollapsedReviewCategoriesRemainUncheckedAfterSelectAll() {
        let results = [result(.userCaches), result(.deletedUsers), result(.possibleThreats)]
        let selected = CleanupSelectionPolicy.allURLs(in: results)
        let rows = FileListRows.flatten(results: results, isExpanded: { _ in false }, selectedItems: selected)
        XCTAssertEqual(rows.count, 3)
        for row in rows {
            guard case .header(let header) = row else { return XCTFail("collapsed categories show headers only") }
            XCTAssertFalse(header.isExpanded)
            XCTAssertEqual(header.selection, header.category == .userCaches ? .all : .none)
        }
        let expanded = FileListRows.flatten(results: results, isExpanded: { _ in true }, selectedItems: selected)
        let selectedURLs = expanded.compactMap { row -> URL? in
            guard case .item(let item, let selected, _) = row, selected else { return nil }
            return item.url
        }
        XCTAssertEqual(Set(selectedURLs), [results[0].items[0].url])
    }

    func testExplicitSafeSelectionRemovesReviewFirstDefaults() {
        let cache = result(.userCaches)
        let trash = result(.trashBins)
        let confirmed = result(.malware)
        let results = [cache, trash, confirmed]
        let initial = CleanupSelectionPolicy.initialURLs(in: results)
        XCTAssertEqual(initial.count, 3)
        XCTAssertTrue(CleanupSelectionPolicy.requiresReview(in: results, selection: initial))
        let safe = CleanupSelectionPolicy.safeURLs(in: results)
        XCTAssertEqual(safe, [cache.items[0].url])
        XCTAssertFalse(CleanupSelectionPolicy.requiresReview(in: results, selection: safe))
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
