import XCTest
import Foundation
@testable import MacCleanKit
import MacCleanTestSupport

/// Hard links share one inode, so a size walk must count them once. Without
/// this `~/Library/Metadata/CoreSpotlight` read 28 GB (`du -l`) instead of the
/// 5.1 GB actually on disk (`du`).
final class HardLinkTrackerTests: XCTestCase {

    func testSameIdentityCountsOnce() {
        var tracker = HardLinkTracker()
        let id = HardLinkTracker.Identity(device: 1, inode: 42)
        XCTAssertTrue(tracker.firstSighting(of: id))
        XCTAssertFalse(tracker.firstSighting(of: id))
        XCTAssertTrue(tracker.firstSighting(of: .init(device: 2, inode: 42)), "same inode on another volume is a different file")
        XCTAssertEqual(tracker.trackedCount, 2)
    }

    func testSingleLinkFilesAreNeverTracked() throws {
        try TestFixtures.withTempDir { dir in
            let file = dir.appending(path: "a.bin")
            try Data(count: 10).write(to: file)
            var tracker = HardLinkTracker()
            XCTAssertTrue(tracker.shouldCount(file, linkCount: 1))
            XCTAssertTrue(tracker.shouldCount(file, linkCount: 1))
            XCTAssertTrue(tracker.shouldCount(file, linkCount: nil))
            XCTAssertEqual(tracker.trackedCount, 0, "the seen-set only holds multi-link files")
        }
    }

    func testHardLinkedPathsCountOnce() throws {
        try TestFixtures.withTempDir { dir in
            let original = dir.appending(path: "original.bin")
            let link = dir.appending(path: "link.bin")
            try Data(count: 10).write(to: original)
            try FileManager.default.linkItem(at: original, to: link)
            let linkCount = try original.resourceValues(forKeys: [.linkCountKey]).linkCount
            XCTAssertEqual(linkCount, 2)

            var tracker = HardLinkTracker()
            XCTAssertTrue(tracker.shouldCount(original, linkCount: linkCount))
            XCTAssertFalse(tracker.shouldCount(link, linkCount: linkCount))
        }
    }

    func testDirectoriesAndMissingPathsAlwaysCount() throws {
        try TestFixtures.withTempDir { dir in
            var tracker = HardLinkTracker()
            XCTAssertTrue(tracker.shouldCount(dir, linkCount: 3))
            XCTAssertTrue(tracker.shouldCount(dir, linkCount: 3), "directory link counts track subdirectories, not shared data")
            let missing = dir.appending(path: "gone.bin")
            XCTAssertTrue(tracker.shouldCount(missing, linkCount: 2))
            XCTAssertEqual(tracker.trackedCount, 0)
        }
    }
}
