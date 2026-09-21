import XCTest
import Foundation
@testable import MacCleanKit

final class DuplicateDetectionTests: XCTestCase {

    private func makeFile(
        _ name: String,
        size: UInt64,
        inode: UInt64 = 0,
        deviceID: Int32 = 0
    ) -> FileItem {
        FileItem(
            url: URL(filePath: "/tmp/\(name)"),
            name: name, size: size, allocatedSize: size,
            isDirectory: false, inode: inode, deviceID: deviceID
        )
    }

    // MARK: - sizeGroups

    func testSizeGroupsSkipsHugeFiles() {
        let huge = makeFile("huge", size: 600 * 1024 * 1024) // > 500 MB
        let normal1 = makeFile("a", size: 1024)
        let normal2 = makeFile("b", size: 1024)
        let groups = DuplicateDetection.sizeGroups([huge, normal1, normal2])
        // huge files dropped, normal files grouped
        XCTAssertEqual(groups.count, 1)
        XCTAssertEqual(groups[0].count, 2)
    }

    func testSizeGroupsKeepsOnlyMultiples() {
        let files = [
            makeFile("uniq", size: 100),  // unique size
            makeFile("a", size: 200),
            makeFile("b", size: 200),     // duplicate size with a
            makeFile("c", size: 300),
            makeFile("d", size: 300),     // duplicate size with c
        ]
        let groups = DuplicateDetection.sizeGroups(files)
        XCTAssertEqual(groups.count, 2)
        XCTAssertTrue(groups.allSatisfy { $0.count == 2 })
    }

    func testSizeGroupsEmpty() {
        XCTAssertTrue(DuplicateDetection.sizeGroups([]).isEmpty)
    }

    func testSizeGroupsAllUnique() {
        let files = (0..<5).map { makeFile("f\($0)", size: UInt64($0) * 100 + 1) }
        XCTAssertTrue(DuplicateDetection.sizeGroups(files).isEmpty)
    }

    // MARK: - partialGroups / fullGroups

    func testPartialGroupsKeepsOnlyMatchingKeys() {
        let a = makeFile("a", size: 100, inode: 1)
        let b = makeFile("b", size: 100, inode: 2)
        let c = makeFile("c", size: 100, inode: 3)
        let pairs: [(key: String, item: FileItem)] = [
            ("100-AAA", a), ("100-AAA", b),
            ("100-BBB", c),
        ]
        let groups = DuplicateDetection.partialGroups(pairs)
        XCTAssertEqual(groups.count, 1)
        XCTAssertEqual(groups[0].count, 2)
    }

    // MARK: - dedupHardLinks

    func testDedupHardLinksKeepsOnePerInode() {
        let a = makeFile("a", size: 100, inode: 42)
        let b = makeFile("b", size: 100, inode: 42) // same inode = hard link
        let c = makeFile("c", size: 100, inode: 43)
        let result = DuplicateDetection.dedupHardLinks([a, b, c])
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(Set(result.map(\.inode)), [42, 43])
    }

    func testDedupHardLinksZeroInodeAlwaysKept() {
        let a = makeFile("a", size: 100, inode: 0)
        let b = makeFile("b", size: 100, inode: 0)
        let result = DuplicateDetection.dedupHardLinks([a, b])
        XCTAssertEqual(result.count, 2, "inode == 0 means 'unknown' and should always be kept")
    }

    func testDedupHardLinksKeepsMatchingInodesFromDifferentDevices() {
        let a = makeFile("a", size: 100, inode: 42, deviceID: 1)
        let b = makeFile("b", size: 100, inode: 42, deviceID: 2)
        let result = DuplicateDetection.dedupHardLinks([a, b])
        XCTAssertEqual(result.count, 2, "inode identity is only unique within one device")
    }

    // MARK: - extractDeletableDuplicates

    func testExtractDeletableDuplicates() {
        let group1 = [makeFile("a", size: 100), makeFile("b", size: 100), makeFile("c", size: 100)]
        let group2 = [makeFile("x", size: 200), makeFile("y", size: 200)]
        let deletable = DuplicateDetection.extractDeletableDuplicates([group1, group2])
        // group1: keep "a", delete "b" and "c". group2: keep "x", delete "y".
        XCTAssertEqual(deletable.count, 3)
        let names = Set(deletable.map(\.name))
        XCTAssertEqual(names, ["b", "c", "y"])
    }

    func testExtractEmptyGroups() {
        XCTAssertTrue(DuplicateDetection.extractDeletableDuplicates([]).isEmpty)
    }

    // MARK: - End-to-end pipeline simulation

    func testFullGroupsAndDedupHardLinks() {
        let a = makeFile("a", size: 100, inode: 1)
        let b = makeFile("b", size: 100, inode: 2)
        let c = makeFile("c", size: 100, inode: 2) // hard link to b
        let pairs: [(key: String, item: FileItem)] = [
            ("hash-XYZ", a), ("hash-XYZ", b), ("hash-XYZ", c),
        ]
        let groups = DuplicateDetection.fullGroupsAndDedupHardLinks(pairs)
        XCTAssertEqual(groups.count, 1)
        // c is hard-link of b → dropped
        XCTAssertEqual(groups[0].count, 2)
    }

    func testFullGroupsSkipsSingletonsAfterDedup() {
        // Two files marked as same content, but they're hard links to each
        // other → after dedup there's only 1 file left, so no duplicate group.
        let a = makeFile("a", size: 100, inode: 5)
        let b = makeFile("b", size: 100, inode: 5)
        let pairs: [(key: String, item: FileItem)] = [
            ("hash-XYZ", a), ("hash-XYZ", b),
        ]
        let groups = DuplicateDetection.fullGroupsAndDedupHardLinks(pairs)
        XCTAssertTrue(groups.isEmpty, "Group of hard-link siblings shouldn't survive dedup")
    }
}
