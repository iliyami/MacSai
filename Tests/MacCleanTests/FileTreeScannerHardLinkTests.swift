import XCTest
import Foundation
@testable import MacClean
@testable import MacCleanKit
import MacCleanTestSupport

/// Space Lens and the directory-size walkers must count a hard-linked file once
/// per inode, like `du`, not once per path, like `du -l`.
final class FileTreeScannerHardLinkTests: XCTestCase {
    private let blobSize = 400_000

    /// dir/a/blob.bin, plus hard links dir/a/blob-link.bin and dir/b/blob.bin.
    private func makeLinkedTree(in dir: URL) throws -> URL {
        let a = dir.appending(path: "a")
        let b = dir.appending(path: "b")
        try FileManager.default.createDirectory(at: a, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: b, withIntermediateDirectories: true)
        let blob = a.appending(path: "blob.bin")
        try Data(count: blobSize).write(to: blob)
        try FileManager.default.linkItem(at: blob, to: a.appending(path: "blob-link.bin"))
        try FileManager.default.linkItem(at: blob, to: b.appending(path: "blob.bin"))
        return blob
    }

    private func allocated(_ url: URL) throws -> UInt64 {
        UInt64(try url.resourceValues(forKeys: [.fileAllocatedSizeKey]).fileAllocatedSize ?? 0)
    }

    func testTopLevelSizesCountsLinkedFileOnce() async throws {
        try await TestFixtures.withTempDir { dir in
            let blob = try makeLinkedTree(in: dir)
            let one = try allocated(blob)

            let nodes = await FileTreeScanner().topLevelSizes(root: dir)
            let total = nodes.reduce(0) { $0 + $1.totalSize }
            XCTAssertEqual(total, one, "three paths to one inode must count once across the scan")
            let a = try XCTUnwrap(nodes.first { $0.name == "a" })
            XCTAssertEqual(a.totalSize, one, "the link inside the same folder is not added again")
        }
    }

    func testTopLevelSizesCountsLinkedTopLevelFileOnce() async throws {
        try await TestFixtures.withTempDir { dir in
            let file = dir.appending(path: "x.bin")
            try Data(count: blobSize).write(to: file)
            try FileManager.default.linkItem(at: file, to: dir.appending(path: "y.bin"))

            let nodes = await FileTreeScanner().topLevelSizes(root: dir)
            XCTAssertEqual(nodes.reduce(0) { $0 + $1.totalSize }, try allocated(file))
        }
    }

    func testAggregationCountsLinkedFileOnce() async throws {
        try await TestFixtures.withTempDir { dir in
            let blob = try makeLinkedTree(in: dir)
            let root = await FileTreeScanner().scanWithSizeAggregation(root: dir)
            XCTAssertEqual(root.totalSize, try allocated(blob))
        }
    }

    func testDistinctFilesStillAddUp() async throws {
        try await TestFixtures.withTempDir { dir in
            let x = dir.appending(path: "x.bin")
            let y = dir.appending(path: "y.bin")
            try Data(count: blobSize).write(to: x)
            try Data(count: blobSize).write(to: y)
            let nodes = await FileTreeScanner().topLevelSizes(root: dir)
            XCTAssertEqual(nodes.reduce(0) { $0 + $1.totalSize }, try allocated(x) + allocated(y))
        }
    }

    func testProjectJunkDirectoryBytesCountsLinkedFileOnce() throws {
        try TestFixtures.withTempDir { dir in
            let blob = try makeLinkedTree(in: dir)
            XCTAssertEqual(ProjectJunkScanner.directoryBytes(dir), try allocated(blob))
        }
    }
}
