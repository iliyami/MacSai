import XCTest
@testable import MacClean
@testable import MacCleanKit
import MacCleanTestSupport

final class CleanHistoryRecorderTests: XCTestCase {
    private var dir: URL!
    private var fakeTrash: URL!
    private var savedFileURL: URL!
    private var savedTrashRoot: URL!

    override func setUpWithError() throws {
        dir = FileManager.default.temporaryDirectory.appending(path: "clean-history-\(UUID().uuidString)")
        fakeTrash = dir.appending(path: "Trash")
        try FileManager.default.createDirectory(at: fakeTrash, withIntermediateDirectories: true)
        savedFileURL = CleanHistoryRecorder.fileURL
        savedTrashRoot = CleanHistoryRecorder.trashRoot
        CleanHistoryRecorder.fileURL = dir.appending(path: "clean-history.json")
        CleanHistoryRecorder.trashRoot = fakeTrash
    }

    override func tearDown() {
        CleanHistoryRecorder.fileURL = savedFileURL
        CleanHistoryRecorder.trashRoot = savedTrashRoot
        try? FileManager.default.removeItem(at: dir)
    }

    /// Simulates `trashItem`: moves `original` into the fake Trash.
    private func fakeTrashItem(_ original: URL, as name: String? = nil) throws -> CleaningEngine.TrashedItem {
        let trashed = fakeTrash.appending(path: name ?? original.lastPathComponent)
        try FileManager.default.moveItem(at: original, to: trashed)
        return .init(originalURL: original, trashURL: trashed, bytes: 7)
    }

    private func write(_ text: String, to url: URL) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try text.write(to: url, atomically: true, encoding: .utf8)
    }

    private func contents(_ url: URL) -> String? { try? String(contentsOf: url, encoding: .utf8) }

    func testRestorePutsItemBackRecreatingParentAndDropsTheSession() throws {
        let original = dir.appending(path: "Caches/com.example/file.txt")
        try write("payload", to: original)
        CleanHistoryRecorder.record(trashedItems: [try fakeTrashItem(original)])
        try FileManager.default.removeItem(at: original.deletingLastPathComponent())

        let session = try XCTUnwrap(CleanHistoryRecorder.load().first)
        let summary = CleanHistoryRecorder.restore(session)

        XCTAssertEqual(summary.restored, 1)
        XCTAssertEqual(contents(original), "payload")
        XCTAssertTrue(CleanHistoryRecorder.load().isEmpty, "a restored session must not be offered again")
    }

    func testEngineHistoryRestoreRoundTripPreservesSystemPrivateVarAlias() async throws {
        let file = dir.appending(path: "fixture.cache")
        try write("payload", to: file)
        let path = file.path(percentEncoded: false)
        let publicPath = path.hasPrefix("/private/var/") ? String(path.dropFirst("/private".count)) : path
        try XCTSkipUnless(publicPath.hasPrefix("/var/"), "Fixture needs macOS's standard /var alias")
        let alias = URL(filePath: "/private" + publicPath)
        let trash = try XCTUnwrap(fakeTrash)
        let service = BatchTrashService { urls in
            var relocated: [URL: URL] = [:]
            do {
                for url in urls {
                    let target = trash.appending(path: url.lastPathComponent)
                    try FileManager.default.moveItem(at: url, to: target)
                    relocated[url] = target
                }
                return BatchTrashReceipt(relocated: relocated, errorMessage: nil)
            } catch {
                return BatchTrashReceipt(relocated: relocated, errorMessage: error.localizedDescription)
            }
        }
        let result = await CleaningEngine(trashService: service, trashRoot: trash.path)
            .clean(items: [FileItem(url: alias, name: alias.lastPathComponent, size: 7,
                                   allocatedSize: 7, isDirectory: false)])
        XCTAssertEqual(result.removedCount, 1)
        XCTAssertTrue(result.errors.isEmpty)
        CleanHistoryRecorder.record(trashedItems: result.trashedItems)
        let session = try XCTUnwrap(CleanHistoryRecorder.load().first)
        XCTAssertEqual(session.items.first?.originalPath, alias.path(percentEncoded: false))
        XCTAssertFalse(FileManager.default.fileExists(atPath: publicPath))

        let summary = CleanHistoryRecorder.restore(session)

        XCTAssertEqual(summary.restored, 1)
        XCTAssertEqual(summary.failed, 0)
        XCTAssertEqual(contents(file), "payload")
        XCTAssertEqual(contents(alias), "payload")
        XCTAssertTrue(CleanHistoryRecorder.load().isEmpty)
    }

    func testReappearedSystemAliasDestinationIsNotOverwritten() throws {
        let file = dir.appending(path: "fixture.cache")
        try write("old", to: file)
        let path = file.path(percentEncoded: false)
        let publicPath = path.hasPrefix("/private/var/") ? String(path.dropFirst("/private".count)) : path
        try XCTSkipUnless(publicPath.hasPrefix("/var/"), "Fixture needs macOS's standard /var alias")
        let alias = URL(filePath: "/private" + publicPath)
        CleanHistoryRecorder.record(trashedItems: [try fakeTrashItem(alias)])
        try write("new", to: file)

        let summary = CleanHistoryRecorder.restore(try XCTUnwrap(CleanHistoryRecorder.load().first))

        XCTAssertEqual(summary.restored, 0)
        XCTAssertTrue(summary.restoredItemIDs.isEmpty)
        XCTAssertEqual(contents(file), "new")
        XCTAssertEqual(contents(fakeTrash.appending(path: "fixture.cache")), "old")
        XCTAssertEqual(CleanHistoryRecorder.load().count, 1)
    }

    func testDirectoryURLHistoryRoundTripRestoresPayload() throws {
        let folder = URL(filePath: dir.appending(path: "Caches/folder").path(percentEncoded: false),
                         directoryHint: .isDirectory)
        let payload = folder.appending(path: "payload.cache")
        try write("payload", to: payload)
        CleanHistoryRecorder.record(trashedItems: [try fakeTrashItem(folder)])
        let session = try XCTUnwrap(CleanHistoryRecorder.load().first)
        XCTAssertFalse(try XCTUnwrap(session.items.first?.originalPath).hasSuffix("/"))

        let summary = CleanHistoryRecorder.restore(session)

        XCTAssertEqual(summary.restored, 1)
        XCTAssertEqual(summary.failed, 0)
        XCTAssertEqual(contents(payload), "payload")
        XCTAssertTrue(CleanHistoryRecorder.load().isEmpty)
    }

    func testNeverRestoresADifferentFileThatReusedTheTrashName() throws {
        let originalA = dir.appending(path: "AppA/Cache.db")
        try write("A", to: originalA)
        CleanHistoryRecorder.record(trashedItems: [try fakeTrashItem(originalA)])
        let session = try XCTUnwrap(CleanHistoryRecorder.load().first)

        // The user empties the Trash, then a later clean trashes another
        // Cache.db, which macOS gives the same Trash name.
        try FileManager.default.removeItem(at: fakeTrash.appending(path: "Cache.db"))
        let originalB = dir.appending(path: "AppB/Cache.db")
        try write("B", to: originalB)
        _ = try fakeTrashItem(originalB)

        let summary = CleanHistoryRecorder.restore(session)

        XCTAssertEqual(summary.restored, 0)
        XCTAssertEqual(summary.failed, 1)
        XCTAssertFalse(FileManager.default.fileExists(atPath: originalA.path(percentEncoded: false)))
        XCTAssertEqual(contents(fakeTrash.appending(path: "Cache.db")), "B")
    }

    func testTamperedTrashPathOutsideTheTrashIsRefused() throws {
        let victim = dir.appending(path: "Documents/taxes.pdf")
        try write("secret", to: victim)
        let elsewhere = dir.appending(path: "Public/taxes.pdf")
        let tampered = CleanHistorySession(id: UUID(), date: Date(), items: [
            CleanHistoryItem(
                id: UUID(),
                originalPath: elsewhere.path(percentEncoded: false),
                trashPath: victim.path(percentEncoded: false),
                bytes: 1,
                trashFileID: CleanHistoryRecorder.fileID(atPath: victim.path(percentEncoded: false))
            ),
        ])

        let summary = CleanHistoryRecorder.restore(tampered)

        XCTAssertEqual(summary.restored, 0)
        XCTAssertEqual(summary.failed, 1)
        XCTAssertEqual(contents(victim), "secret")
        XCTAssertFalse(FileManager.default.fileExists(atPath: elsewhere.path(percentEncoded: false)))
    }

    func testNeverOverwritesAFileThatReappeared() throws {
        let original = dir.appending(path: "Caches/settings.plist")
        try write("old", to: original)
        CleanHistoryRecorder.record(trashedItems: [try fakeTrashItem(original)])
        try write("new", to: original)

        let summary = CleanHistoryRecorder.restore(try XCTUnwrap(CleanHistoryRecorder.load().first))

        XCTAssertEqual(summary.reappeared, 1)
        XCTAssertEqual(contents(original), "new")
        XCTAssertEqual(contents(fakeTrash.appending(path: "settings.plist")), "old")
        XCTAssertEqual(CleanHistoryRecorder.load().count, 1, "unrestored items stay restorable")
    }

    func testConcurrentRecordsKeepEverySession() async {
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<20 {
                group.addTask {
                    CleanHistoryRecorder.record(trashedItems: [
                        .init(originalURL: URL(filePath: "/tmp/o\(i)"), trashURL: URL(filePath: "/tmp/t\(i)"), bytes: 1),
                    ])
                }
            }
        }
        XCTAssertEqual(CleanHistoryRecorder.load().count, 20)
    }

    func testHistoryFileIsOwnerOnlyAndLeavesNoTempFiles() throws {
        CleanHistoryRecorder.record(trashedItems: [
            .init(originalURL: URL(filePath: "/tmp/o"), trashURL: URL(filePath: "/tmp/t"), bytes: 1),
        ])
        CleanHistoryRecorder.record(trashedItems: [
            .init(originalURL: URL(filePath: "/tmp/o2"), trashURL: URL(filePath: "/tmp/t2"), bytes: 1),
        ])
        let attrs = try FileManager.default.attributesOfItem(atPath: CleanHistoryRecorder.fileURL.path(percentEncoded: false))
        XCTAssertEqual((attrs[.posixPermissions] as? NSNumber)?.intValue, 0o600)
        let leftovers = try FileManager.default.contentsOfDirectory(atPath: dir.path(percentEncoded: false))
            .filter { $0.hasSuffix(".tmp") }
        XCTAssertEqual(leftovers, [])
        XCTAssertEqual(CleanHistoryRecorder.load().count, 2)
    }

    func testOversizedCleanIsFlaggedPartialNotSilentlyTruncated() {
        let count = CleanHistoryStore.maxItemsPerSession + 7
        CleanHistoryRecorder.record(trashedItems: (0..<count).map {
            .init(originalURL: URL(filePath: "/tmp/o\($0)"), trashURL: URL(filePath: "/tmp/t\($0)"), bytes: 1)
        })
        let session = CleanHistoryRecorder.load().first
        XCTAssertEqual(session?.items.count, CleanHistoryStore.maxItemsPerSession)
        XCTAssertEqual(session?.omittedCount, 7)
        XCTAssertEqual(session?.isPartial, true)
    }

    func testSessionsOlderThan30DaysAreNotOffered() {
        CleanHistoryRecorder.record(
            trashedItems: [.init(originalURL: URL(filePath: "/tmp/o"), trashURL: URL(filePath: "/tmp/t"), bytes: 1)],
            now: Date().addingTimeInterval(-31 * 86_400)
        )
        XCTAssertTrue(CleanHistoryRecorder.load().isEmpty)
    }

    func testClearForgetsHistoryButLeavesTrashAlone() throws {
        let original = dir.appending(path: "Caches/keep.me")
        try write("still here", to: original)
        CleanHistoryRecorder.record(trashedItems: [try fakeTrashItem(original)])

        CleanHistoryRecorder.clear()

        XCTAssertTrue(CleanHistoryRecorder.load().isEmpty)
        XCTAssertEqual(contents(fakeTrash.appending(path: "keep.me")), "still here")
    }

    /// End to end through the real engine and the real Trash, like
    /// CleaningEngineTests: trash a temp file, then Restore it.
    func testEngineTrashThenRestoreRoundTrip() async throws {
        CleanHistoryRecorder.trashRoot = MCConstants.userTrash
        let cacheDir = MCConstants.userCaches.appending(path: "MacCleanTest-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: cacheDir) }
        let file = cacheDir.appending(path: "restore-me.cache")
        try TestFixtures.writeFile(at: file, size: 321)

        let result = await CleaningEngine().clean(
            items: [FileItem(url: file, name: file.lastPathComponent, size: 321, allocatedSize: 321, isDirectory: false)],
            mode: .trash
        )
        XCTAssertEqual(result.trashedItems.count, 1)
        CleanHistoryRecorder.record(trashedItems: result.trashedItems)
        XCTAssertFalse(FileManager.default.fileExists(atPath: file.path(percentEncoded: false)))

        let summary = CleanHistoryRecorder.restore(try XCTUnwrap(CleanHistoryRecorder.load().first))

        XCTAssertEqual(summary.restored, 1)
        XCTAssertTrue(FileManager.default.fileExists(atPath: file.path(percentEncoded: false)))
    }

    func testPermanentCleanRecordsNothingToRestore() async throws {
        let cacheDir = MCConstants.userCaches.appending(path: "MacCleanTest-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: cacheDir) }
        let file = cacheDir.appending(path: "gone.cache")
        try TestFixtures.writeFile(at: file, size: 10)

        let result = await CleaningEngine().clean(
            items: [FileItem(url: file, name: file.lastPathComponent, size: 10, allocatedSize: 10, isDirectory: false)],
            mode: .permanent
        )
        XCTAssertEqual(result.removedCount, 1)
        XCTAssertTrue(result.trashedItems.isEmpty)
    }
}
