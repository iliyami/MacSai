import XCTest
import Foundation
@testable import MacClean
@testable import MacCleanKit

final class SmartScanCleanupTests: XCTestCase {
    private func item(_ path: String, _ size: UInt64) -> FileItem {
        FileItem(url: URL(filePath: path), name: (path as NSString).lastPathComponent,
                 size: size, allocatedSize: size, isDirectory: false)
    }

    func testFlattensModuleResultsAcrossCategories() {
        let modules = [
            ModuleScanResult(moduleID: "systemJunk", moduleName: "System Junk",
                categories: [ScanResult(category: .userCaches, items: [item("/c/a", 100)])],
                scanDuration: 0),
            ModuleScanResult(moduleID: "trashBins", moduleName: "Trash Bins",
                categories: [ScanResult(category: .trashBins, items: [item("/t/b", 200)])],
                scanDuration: 0),
        ]
        let flat = SmartScanCleanup.allResults(from: modules)
        XCTAssertEqual(flat.count, 2)
        XCTAssertEqual(Set(flat.map(\.category)), [.userCaches, .trashBins])
    }

    func testFiltersEmptyCategories() {
        let modules = [
            ModuleScanResult(moduleID: "m", moduleName: "M",
                categories: [ScanResult(category: .userCaches, items: []),
                             ScanResult(category: .userLogs, items: [item("/l/x", 50)])],
                scanDuration: 0),
        ]
        let flat = SmartScanCleanup.allResults(from: modules)
        XCTAssertEqual(flat.map(\.category), [.userLogs])
    }

    func testDefaultSelectionIsEveryItemFromAutoSelectCategories() {
        let modules = [
            ModuleScanResult(moduleID: "systemJunk", moduleName: "System Junk",
                categories: [ScanResult(category: .userCaches,
                    items: [item("/c/a", 100), item("/c/b", 100)], autoSelect: true)],
                scanDuration: 0),
        ]
        let urls = SmartScanCleanup.defaultSelection(from: modules)
        XCTAssertEqual(urls, Set([URL(filePath: "/c/a"), URL(filePath: "/c/b")]))
    }

    func testDefaultSelectionPreservesConfirmedXProtectAndOtherReviewFirstOptIns() {
        let confirmed = item("/confirmed-xprotect", 10)
        let trash = item("/trash", 20)
        let backup = item("/backup", 30)
        let possible = item("/possible", 40)
        let reported = item("/community-report", 50)
        let optedOut = item("/scanner-opt-out", 60)
        let categoryOptOut = item("/manual-home-folder", 70)
        let modules = [ModuleScanResult(moduleID: "fixtures", moduleName: "Fixtures", categories: [
            ScanResult(category: .malware, items: [confirmed]),
            ScanResult(category: .trashBins, items: [trash]),
            ScanResult(category: .iosDeviceBackups, items: [backup]),
            ScanResult(category: .possibleThreats, items: [possible]),
            ScanResult(category: .possibleThreats, items: [reported], autoSelect: false),
            ScanResult(category: .userCaches, items: [optedOut], autoSelect: false),
            ScanResult(category: .deletedUsers, items: [categoryOptOut]),
        ], scanDuration: 0)]
        XCTAssertEqual(SmartScanCleanup.defaultSelection(from: modules), [confirmed.url, trash.url, backup.url])
        XCTAssertTrue(CleanupSelectionPolicy.safeURLs(in: SmartScanCleanup.allResults(from: modules)).isEmpty)
    }

    func testRecentlyCleanedBreakdownGroupsSelectedItemsByModule() {
        let modules = [
            ModuleScanResult(
                moduleID: "systemJunk", moduleName: "System Junk",
                categories: [
                    ScanResult(category: .userCaches, items: [item("/c/a", 1_200_000_000)]),
                    ScanResult(category: .userLogs, items: [item("/l/a", 40_000_000)]),
                ],
                scanDuration: 0
            ),
            ModuleScanResult(
                moduleID: "malware", moduleName: "Malware Removal",
                categories: [
                    ScanResult(category: .malware, items: [
                        item("/m/1", 4_000_000),
                        item("/m/2", 4_000_000),
                        item("/m/3", 4_000_000),
                    ], autoSelect: false),
                ],
                scanDuration: 0
            ),
            ModuleScanResult(
                moduleID: "privacy", moduleName: "Privacy",
                categories: [
                    ScanResult(category: .browserPrivacy, items: [item("/p/a", 340_000_000)]),
                ],
                scanDuration: 0
            ),
        ]
        let selected: Set<URL> = [
            URL(filePath: "/c/a"),
            URL(filePath: "/m/1"), URL(filePath: "/m/2"), URL(filePath: "/m/3"),
            URL(filePath: "/p/a"),
            // intentionally omit /l/a
        ]
        let rows = SmartScanCleanup.recentlyCleanedBreakdown(from: modules, selectedItems: selected)
        XCTAssertEqual(rows.map(\.moduleName), ["System Junk", "Malware Removal", "Privacy"])
        XCTAssertEqual(rows[0].itemCount, 1)
        XCTAssertEqual(rows[0].size, 1_200_000_000)
        XCTAssertEqual(rows[1].itemCount, 3)
        XCTAssertEqual(rows[1].size, 12_000_000)
        XCTAssertEqual(rows[2].itemCount, 1)
        XCTAssertEqual(rows[2].size, 340_000_000)
    }

    func testRecentlyCleanedBreakdownSkipsModulesWithNoSelection() {
        let modules = [
            ModuleScanResult(moduleID: "systemJunk", moduleName: "System Junk",
                categories: [ScanResult(category: .userCaches, items: [item("/c/a", 100)])],
                scanDuration: 0),
            ModuleScanResult(moduleID: "privacy", moduleName: "Privacy",
                categories: [ScanResult(category: .browserPrivacy, items: [item("/p/a", 50)])],
                scanDuration: 0),
        ]
        let rows = SmartScanCleanup.recentlyCleanedBreakdown(
            from: modules,
            selectedItems: [URL(filePath: "/p/a")]
        )
        XCTAssertEqual(rows.map(\.moduleID), ["privacy"])
    }

    func testRecentlyCleanedBreakdownDedupesSameURLAcrossCategories() {
        let shared = item("/shared", 100)
        let modules = [
            ModuleScanResult(moduleID: "m", moduleName: "M",
                categories: [
                    ScanResult(category: .largeFiles, items: [shared]),
                    ScanResult(category: .oldFiles, items: [shared]),
                ],
                scanDuration: 0),
        ]
        let rows = SmartScanCleanup.recentlyCleanedBreakdown(
            from: modules,
            selectedItems: [URL(filePath: "/shared")]
        )
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows[0].itemCount, 1)
        XCTAssertEqual(rows[0].size, 100)
    }

    func testSmartScanBuildsRecentlyCleanedBreakdownFromRemovedURLs() throws {
        let viewURL = URL(filePath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appending(path: "Sources/MacClean/Views/SmartScan/SmartScanView.swift")
        let source = try String(contentsOf: viewURL, encoding: .utf8)

        let executeRange = try XCTUnwrap(
            source.range(of: "let result = await CleanActions.executeUserClean")
        )
        let breakdownRange = try XCTUnwrap(
            source.range(of: "let breakdown = SmartScanCleanup.recentlyCleanedBreakdown")
        )

        XCTAssertGreaterThan(
            breakdownRange.lowerBound,
            executeRange.lowerBound,
            "Recently cleaned must be derived after cleanup returns, not snapshotted before it"
        )
        XCTAssertTrue(
            source.contains("selectedItems: result.removedURLs"),
            "Recently cleaned must include only URLs the cleanup result reports as removed"
        )
    }
}
