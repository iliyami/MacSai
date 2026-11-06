import XCTest
@testable import MacClean
import MacCleanKit

final class PnpmStoreScannerTests: XCTestCase {
    private var root: URL!

    override func setUpWithError() throws {
        root = FileManager.default.temporaryDirectory
            .appending(path: "PnpmStore-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: root)
    }

    private func makeFile(_ relativePath: String, bytes: Int) throws {
        let url = root.appending(path: relativePath)
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data(count: bytes).write(to: url)
    }

    func testListsEachVersionFolderAsOneSizedItem() throws {
        try makeFile("store/v3/files/00/a", bytes: 4096)
        try makeFile("store/v10/files/00/a", bytes: 4096)
        try makeFile("store/v10/files/01/b", bytes: 4096)
        try makeFile("store/tmp/x", bytes: 4096)      // not a version folder
        try makeFile("store/v11.lock", bytes: 4096)   // a file, not a folder
        try makeFile("bin/pnpm", bytes: 4096)         // outside the store root

        let items = PnpmStoreScanner.scan(roots: [root.appending(path: "store")])

        XCTAssertEqual(items.map(\.url.lastPathComponent), ["v10", "v3"])
        XCTAssertTrue(items.allSatisfy(\.isDirectory))
        XCTAssertTrue(items[0].name.hasPrefix("pnpm store v10 · "))
        XCTAssertEqual(items[0].name, "pnpm store v10 · " + PnpmStore.currentNote)
        XCTAssertEqual(items[1].name, "pnpm store v3 · " + PnpmStore.staleNote)
        XCTAssertGreaterThan(items[0].size, items[1].size)
    }

    func testMissingRootsAndEmptyVersionsAreSkipped() throws {
        try FileManager.default.createDirectory(at: root.appending(path: "store/v10"), withIntermediateDirectories: true)
        let items = PnpmStoreScanner.scan(roots: [root.appending(path: "store"), root.appending(path: "missing")])
        XCTAssertTrue(items.isEmpty)
    }
}
