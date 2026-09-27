import XCTest
import Foundation
@testable import MacClean
@testable import MacCleanKit
import MacCleanTestSupport

/// Space Lens only renders the immediate children of the scanned folder, so the
/// scanner aggregates each top-level child's whole subtree into one size instead
/// of allocating a node per file (issue #184: the old per-file tree could swap
/// and appear to hang, and progress was a fake static 50%).
final class FileTreeScannerTopLevelSizesTests: XCTestCase {

    func testTopLevelSizesReturnsOnlyImmediateChildren() async throws {
        try await TestFixtures.withTempDir { dir in
            // dir/big/nested/blob (large), dir/small/tiny (small), dir/loose.txt
            let big = dir.appending(path: "big")
            let bigNested = big.appending(path: "nested")
            let small = dir.appending(path: "small")
            try FileManager.default.createDirectory(at: bigNested, withIntermediateDirectories: true)
            try FileManager.default.createDirectory(at: small, withIntermediateDirectories: true)
            try Data(count: 200_000).write(to: bigNested.appending(path: "blob.bin"))
            try Data(count: 1_000).write(to: small.appending(path: "tiny.bin"))
            try Data(count: 5_000).write(to: dir.appending(path: "loose.txt"))

            let scanner = FileTreeScanner()
            let nodes = await scanner.topLevelSizes(root: dir)

            // Immediate children only, no deeper nodes leak into the result.
            XCTAssertEqual(Set(nodes.map(\.name)), ["big", "small", "loose.txt"])

            let bigNode = try XCTUnwrap(nodes.first { $0.name == "big" })
            let smallNode = try XCTUnwrap(nodes.first { $0.name == "small" })
            let looseNode = try XCTUnwrap(nodes.first { $0.name == "loose.txt" })

            // Directory totals aggregate the entire subtree (recursion into nested).
            XCTAssertTrue(bigNode.isDirectory)
            XCTAssertGreaterThan(bigNode.totalSize, smallNode.totalSize)
            XCTAssertGreaterThan(bigNode.totalSize, 150_000)

            // Files carry their own size and are not marked directories.
            XCTAssertFalse(looseNode.isDirectory)
            XCTAssertGreaterThan(looseNode.totalSize, 0)
        }
    }

    func testTopLevelSizesEmptyForMissingRoot() async throws {
        let missing = URL(filePath: "/nonexistent-\(UUID().uuidString)")
        let nodes = await FileTreeScanner().topLevelSizes(root: missing)
        XCTAssertTrue(nodes.isEmpty)
    }
}
