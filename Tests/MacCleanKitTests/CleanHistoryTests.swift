import XCTest
@testable import MacCleanKit

final class CleanHistoryTests: XCTestCase {
    private let item = CleanHistoryItem(
        id: UUID(),
        originalPath: "/Users/me/Library/Caches/com.foo",
        trashPath: "/Users/me/.Trash/com.foo",
        bytes: 10
    )

    func testRestorePlanMovesBackOnlyWhenTrashRemainsAndOriginalIsFree() {
        XCTAssertEqual(
            CleanHistoryRestore.plan(item: item, trashExists: true, originalExists: false, isSafe: true),
            .restore(fromTrash: item.trashPath, to: item.originalPath)
        )
        XCTAssertEqual(
            CleanHistoryRestore.plan(item: item, trashExists: false, originalExists: false, isSafe: true),
            .skippedEmptied(originalPath: item.originalPath)
        )
        XCTAssertEqual(
            CleanHistoryRestore.plan(item: item, trashExists: true, originalExists: true, isSafe: true),
            .skippedReappeared(originalPath: item.originalPath)
        )
    }

    func testUnsafeEntryIsNeverRestored() {
        XCTAssertEqual(
            CleanHistoryRestore.plan(item: item, trashExists: true, originalExists: false, isSafe: false),
            .skippedUnsafe(originalPath: item.originalPath)
        )
    }

    func testTrashPathMustLiveInsideATrash() {
        let root = "/Users/me/.Trash"
        XCTAssertTrue(CleanHistoryRestore.isInsideTrash("/Users/me/.Trash/com.foo", trashRoot: root, uid: 501))
        XCTAssertTrue(CleanHistoryRestore.isInsideTrash("/Volumes/Ext/.Trashes/501/a.mov", trashRoot: root, uid: 501))
        XCTAssertFalse(CleanHistoryRestore.isInsideTrash("/Users/me/.Trash", trashRoot: root, uid: 501))
        XCTAssertFalse(CleanHistoryRestore.isInsideTrash("/Users/me/Documents/taxes.pdf", trashRoot: root, uid: 501))
        XCTAssertFalse(CleanHistoryRestore.isInsideTrash("/Users/me/.Trash/../Documents/x", trashRoot: root, uid: 501))
        XCTAssertFalse(CleanHistoryRestore.isInsideTrash("/Users/me/.TrashEvil/x", trashRoot: root, uid: 501))
        XCTAssertFalse(CleanHistoryRestore.isInsideTrash("/Volumes/Ext/.Trashes/502/a.mov", trashRoot: root, uid: 501))
        XCTAssertFalse(CleanHistoryRestore.isInsideTrash("relative/.Trash/x", trashRoot: root, uid: 501))
    }

    func testDestinationMustBeNormalizedAndOutsideTrash() {
        let root = "/Users/me/.Trash"
        XCTAssertTrue(CleanHistoryRestore.isRestorableDestination("/Users/me/Library/Caches/a", trashRoot: root, uid: 501))
        XCTAssertFalse(CleanHistoryRestore.isRestorableDestination("/Users/me/Library/../../../etc/x", trashRoot: root, uid: 501))
        XCTAssertFalse(CleanHistoryRestore.isRestorableDestination("/Users/me/.Trash/a", trashRoot: root, uid: 501))
        XCTAssertFalse(CleanHistoryRestore.isRestorableDestination("a/b", trashRoot: root, uid: 501))
    }

    func testExistingDirectoryPathsRemainValidForRestore() throws {
        let temporary = FileManager.default.temporaryDirectory
            .appending(path: "MacCleanRestorePathTest-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: temporary) }
        let trash = temporary.appending(path: ".Trash")
        let directory = trash.appending(path: "folder")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let trashPath = trash.path(percentEncoded: false)
        let directoryPath = directory.path(percentEncoded: false)

        XCTAssertTrue(CleanHistoryRestore.isInsideTrash(directoryPath, trashRoot: trashPath, uid: 501))
        XCTAssertTrue(CleanHistoryRestore.isRestorableDestination(
            temporary.path(percentEncoded: false), trashRoot: trashPath, uid: 501))
        XCTAssertFalse(CleanHistoryRestore.isInsideTrash(directoryPath + "/..", trashRoot: trashPath, uid: 501))
        XCTAssertFalse(CleanHistoryRestore.isInsideTrash(directoryPath + "/.", trashRoot: trashPath, uid: 501))
    }

    func testRemovingRestoredItemsDropsEmptySessions() {
        let a = CleanHistoryItem(id: UUID(), originalPath: "/a", trashPath: "/t/a", bytes: 1)
        let b = CleanHistoryItem(id: UUID(), originalPath: "/b", trashPath: "/t/b", bytes: 1)
        let full = CleanHistorySession(id: UUID(), date: Date(timeIntervalSince1970: 2), items: [a])
        let partial = CleanHistorySession(id: UUID(), date: Date(timeIntervalSince1970: 1), items: [a, b])
        let left = CleanHistoryStore.removing(itemIDs: [a.id], from: [full, partial])
        XCTAssertEqual(left.map(\.id), [partial.id])
        XCTAssertEqual(left[0].items, [b])
    }

    func testSessionRoundTripAndNewestFirst() throws {
        let older = CleanHistorySession(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            date: Date(timeIntervalSince1970: 10),
            items: []
        )
        let newer = CleanHistorySession(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
            date: Date(timeIntervalSince1970: 20),
            items: [
                CleanHistoryItem(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
                    originalPath: "/a",
                    trashPath: "/Trash/a",
                    bytes: 4,
                    trashFileID: 42
                )
            ]
        )
        let stored = CleanHistoryStore.adding(newer, to: [older], now: Date(timeIntervalSince1970: 30))
        let decoded = try CleanHistoryStore.decode(CleanHistoryStore.encode(stored))
        XCTAssertEqual(decoded.map(\.id), [newer.id, older.id])
        XCTAssertEqual(decoded[0].items[0].trashFileID, 42)
    }

    func testPruningDropsSessionsOlderThan30DaysAndKeepsAtMost20() {
        let now = Date(timeIntervalSince1970: 100 * 86_400)
        let fresh = (0..<25).map {
            CleanHistorySession(id: UUID(), date: now.addingTimeInterval(TimeInterval(-$0 * 3_600)), items: [])
        }
        let stale = CleanHistorySession(id: UUID(), date: now.addingTimeInterval(-31 * 86_400), items: [])
        let kept = CleanHistoryStore.pruned(fresh + [stale], now: now)
        XCTAssertEqual(kept.count, CleanHistoryStore.maxSessions)
        XCTAssertEqual(kept.map(\.id), Array(fresh.prefix(20)).map(\.id), "newest first")
        XCTAssertFalse(kept.contains(stale))
        XCTAssertTrue(CleanHistoryStore.pruned([stale], now: now).isEmpty)
    }

    func testPartialFlagSurvivesRoundTripAndRemoval() throws {
        let a = CleanHistoryItem(id: UUID(), originalPath: "/a", trashPath: "/t/a", bytes: 1)
        let b = CleanHistoryItem(id: UUID(), originalPath: "/b", trashPath: "/t/b", bytes: 1)
        let session = CleanHistorySession(id: UUID(), date: Date(), items: [a, b], omittedCount: 9)
        let decoded = try CleanHistoryStore.decode(CleanHistoryStore.encode([session]))
        XCTAssertTrue(decoded[0].isPartial)
        XCTAssertEqual(CleanHistoryStore.removing(itemIDs: [a.id], from: decoded)[0].omittedCount, 9)
        XCTAssertFalse(CleanHistorySession(id: UUID(), date: Date(), items: [a]).isPartial)
    }

    func testCorruptHistoryThrowsInsteadOfCrashing() {
        XCTAssertThrowsError(try CleanHistoryStore.decode(Data("{not json".utf8)))
    }
}
