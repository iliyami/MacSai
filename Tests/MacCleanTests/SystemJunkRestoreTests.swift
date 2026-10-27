import XCTest
@testable import MacClean
@testable import MacCleanKit

@MainActor
final class SystemJunkRestoreTests: XCTestCase {
    func testRestoreWithResultsShowsResults() {
        let vm = SystemJunkViewModel()
        let r = [ScanResult(category: .userCaches, items: [])]
        vm.restore(results: r, selection: [URL(filePath: "/a")], scanComplete: true)
        XCTAssertEqual(vm.results.count, 1)
        XCTAssertEqual(vm.selectedItems, [URL(filePath: "/a")])
        XCTAssertTrue(vm.isScanComplete)
        if case .results = vm.state {} else { XCTFail("expected .results") }
    }

    func testRestoreEmptyScanShowsEmpty() {
        let vm = SystemJunkViewModel()
        vm.restore(results: [], selection: [], scanComplete: true)
        if case .empty = vm.state {} else { XCTFail("expected .empty") }
    }

    func testRestoreNotScannedStaysIdle() {
        let vm = SystemJunkViewModel()
        vm.restore(results: [], selection: [], scanComplete: false)
        if case .idle = vm.state {} else { XCTFail("expected .idle") }
        XCTAssertFalse(vm.isScanComplete)
    }

    func testBulkSafeSelectionRefreshesSizeWhenSelectedCountDoesNotChange() {
        let cache = FileItem(url: URL(filePath: "/fixture/cache"), name: "cache", size: 10,
                             allocatedSize: 10, isDirectory: false)
        let backup = FileItem(url: URL(filePath: "/fixture/backup"), name: "backup", size: 1_000,
                              allocatedSize: 1_000, isDirectory: false)
        let vm = SystemJunkViewModel()
        vm.restore(results: [ScanResult(category: .userCaches, items: [cache]),
                             ScanResult(category: .systemCaches, items: [cache]),
                             ScanResult(category: .iosDeviceBackups, items: [backup])],
                   selection: [backup.url], scanComplete: true)
        XCTAssertEqual(vm.totalFileCount, 2, "Select All and its denominator must count each URL only once")
        XCTAssertEqual(vm.selectedCount, 1)
        XCTAssertEqual(vm.totalSelectedSize, 1_000)
        vm.selectedItems = CleanupSelectionPolicy.safeURLs(in: vm.results)
        XCTAssertEqual(vm.selectedCount, 1)
        XCTAssertEqual(vm.selectedItems, [cache.url])
        XCTAssertEqual(vm.totalSelectedSize, 10)
    }
}
