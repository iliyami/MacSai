import Foundation
import XCTest
import MacCleanTestSupport
@testable import MacClean
@testable import MacCleanKit

final class BatchTrashTests: XCTestCase {
    private func item(_ url: URL, size: UInt64 = 17) -> FileItem {
        FileItem(url: url, name: url.lastPathComponent, size: size, allocatedSize: size, isDirectory: false)
    }

    func testMovesFixtureBatchAndKeepsExactRestoreLocations() async throws {
        try await TestFixtures.withTempDir { root in
            let trash = root.appending(path: "trash")
            try FileManager.default.createDirectory(at: trash, withIntermediateDirectories: true)
            let files = [root.appending(path: "one"), root.appending(path: "two")]
            for file in files { try TestFixtures.writeFile(at: file, size: 17) }
            let recorder = RecyclerRecorder(trash: trash)
            let engine = CleaningEngine(trashService: .init(recycle: { await recorder.move($0) }), trashRoot: trash.path)

            let result = await engine.clean(items: files.map { item($0) })

            let calls = await recorder.calls
            XCTAssertEqual(calls, [files])
            XCTAssertEqual(result.removedCount, 2)
            XCTAssertEqual(result.freedBytes, 34)
            XCTAssertEqual(result.removedURLs, Set(files))
            XCTAssertTrue(result.errors.isEmpty)
            XCTAssertFalse(result.wasCancelled)
            XCTAssertEqual(result.trashedItems.count, 2)
            for moved in result.trashedItems {
                XCTAssertFalse(FileManager.default.fileExists(atPath: moved.originalURL.path))
                XCTAssertEqual(try Data(contentsOf: moved.trashURL).count, 17)
                try FileManager.default.moveItem(at: moved.trashURL, to: moved.originalURL)
                XCTAssertEqual(try Data(contentsOf: moved.originalURL).count, 17)
            }
        }
    }

    func testSystemPrivateVarAliasReachesBatchWithSameFileIdentity() async throws {
        try await TestFixtures.withTempDir { root in
            let file = root.appending(path: "fixture.cache")
            try TestFixtures.writeFile(at: file, size: 17)
            let path = file.path(percentEncoded: false)
            let publicPath = path.hasPrefix("/private/var/") ? String(path.dropFirst("/private".count)) : path
            try XCTSkipUnless(publicPath.hasPrefix("/var/"), "Fixture needs macOS's standard /var alias")
            let alias = URL(filePath: "/private" + publicPath)
            let ordinary = try TrashItemIdentity.read(URL(filePath: publicPath))
            let aliased = try TrashItemIdentity.read(alias)
            XCTAssertEqual(aliased.device, ordinary.device)
            XCTAssertEqual(aliased.inode, ordinary.inode)
            XCTAssertEqual(aliased.parentDevice, ordinary.parentDevice)
            XCTAssertEqual(aliased.parentInode, ordinary.parentInode)

            let trash = root.appending(path: "trash")
            let recorder = RecyclerRecorder(trash: trash)
            let engine = CleaningEngine(trashService: .init(recycle: { await recorder.move($0) }),
                                       trashRoot: trash.path)
            let result = await engine.clean(items: [item(alias)])
            XCTAssertTrue(result.errors.isEmpty)
            XCTAssertEqual(result.removedCount, 1)
            let calls = await recorder.calls
            XCTAssertEqual(calls, [[alias]])
            XCTAssertFalse(FileManager.default.fileExists(atPath: publicPath))
            XCTAssertEqual(try Data(contentsOf: trash.appending(path: "fixture.cache")).count, 17)
        }
    }

    func testPartialSystemFailureCountsMovedFileAndReportsOtherFile() async throws {
        try await TestFixtures.withTempDir { root in
            let first = root.appending(path: "a")
            let second = root.appending(path: "b")
            for file in [first, second] { try TestFixtures.writeFile(at: file, size: 17) }
            let trash = root.appending(path: "trash")
            try FileManager.default.createDirectory(at: trash, withIntermediateDirectories: true)
            let service = BatchTrashService { urls in
                let target = trash.appending(path: "a")
                do { try FileManager.default.moveItem(at: urls[0], to: target) }
                catch { return BatchTrashReceipt(relocated: [:], errorMessage: error.localizedDescription) }
                return BatchTrashReceipt(relocated: [urls[0]: target], errorMessage: "Permission denied")
            }
            let result = await CleaningEngine(trashService: service, trashRoot: trash.path)
                .clean(items: [item(first), item(second)])
            XCTAssertEqual(result.removedURLs, [first])
            XCTAssertEqual(result.freedBytes, 17)
            XCTAssertEqual(result.errors.map(\.path), [second.path])
            XCTAssertEqual(result.errors.first?.error, "Permission denied")
            XCTAssertTrue(FileManager.default.fileExists(atPath: second.path))
        }
    }

    func testNilErrorWithoutReceiptDoesNotClaimSuccess() async throws {
        try await TestFixtures.withTempDir { root in
            let file = root.appending(path: "a")
            try TestFixtures.writeFile(at: file, size: 17)
            let service = BatchTrashService { _ in BatchTrashReceipt(relocated: [:], errorMessage: nil) }
            let result = await CleaningEngine(trashService: service).clean(items: [item(file)])
            XCTAssertEqual(result.removedCount, 0)
            XCTAssertEqual(result.errors.count, 1)
            XCTAssertTrue(result.trashedItems.isEmpty)
            XCTAssertTrue(FileManager.default.fileExists(atPath: file.path))
        }
    }

    func testUnsafeAndRedirectedPathsNeverReachSystemBatch() async throws {
        try await TestFixtures.withTempDir { root in
            let target = root.appending(path: "target")
            let link = root.appending(path: "link")
            try TestFixtures.writeFile(at: target, size: 17)
            try FileManager.default.createSymbolicLink(at: link, withDestinationURL: target)
            let recorder = RecyclerRecorder(trash: root.appending(path: "trash"))
            let engine = CleaningEngine(trashService: .init(recycle: { await recorder.move($0) }))
            let result = await engine.clean(items: [item(URL(filePath: "/System/Library/test")), item(link),
                                                  item(URL(filePath: "/")),
                                                  item(URL(string: "file://example.com/Users/test/a")!)])
            let calls = await recorder.calls
            XCTAssertTrue(calls.isEmpty)
            XCTAssertEqual(result.removedCount, 0)
            XCTAssertEqual(result.errors.count, 3, "The link itself is skipped; unsafe paths remain errors")
            XCTAssertEqual(result.skippedCount, 4)
            XCTAssertTrue(FileManager.default.fileExists(atPath: target.path))
        }
    }

    func testLeafSymbolicLinksAreSkippedWithoutFollowingTargets() async throws {
        try await TestFixtures.withTempDir { root in
            let target = root.appending(path: "target")
            try TestFixtures.writeFile(at: target, size: 17)
            let regular = root.appending(path: "link")
            let dangling = root.appending(path: "dangling")
            let circular = root.appending(path: "circular")
            let protected = root.appending(path: "protected")
            try FileManager.default.createSymbolicLink(at: regular, withDestinationURL: target)
            try FileManager.default.createSymbolicLink(at: dangling, withDestinationURL: root.appending(path: "missing"))
            try FileManager.default.createSymbolicLink(at: circular, withDestinationURL: circular)
            try FileManager.default.createSymbolicLink(at: protected, withDestinationURL: URL(filePath: "/System"))
            let links = [regular, dangling, circular, protected]
            let recorder = RecyclerRecorder(trash: root.appending(path: "trash"))
            let result = await CleaningEngine(trashService: .init(recycle: { await recorder.move($0) }))
                .clean(items: links.map { item($0) })

            XCTAssertTrue(result.errors.isEmpty)
            XCTAssertEqual(result.skippedCount, links.count)
            XCTAssertEqual(result.removedCount, 0)
            XCTAssertEqual(result.freedBytes, 0)
            let calls = await recorder.calls
            XCTAssertTrue(calls.isEmpty)
            XCTAssertEqual(try Data(contentsOf: target).count, 17)
            for link in links {
                XCTAssertNoThrow(try FileManager.default.destinationOfSymbolicLink(atPath: link.path))
            }
        }
    }

    func testLeafLinkUnderRedirectedParentRemainsAnError() async throws {
        try await TestFixtures.withTempDir { root in
            let realParent = root.appending(path: "real")
            let aliasParent = root.appending(path: "redirected")
            let target = realParent.appending(path: "target")
            try FileManager.default.createDirectory(at: realParent, withIntermediateDirectories: true)
            try TestFixtures.writeFile(at: target, size: 17)
            let leaf = realParent.appending(path: "link")
            try FileManager.default.createSymbolicLink(at: leaf, withDestinationURL: target)
            try FileManager.default.createSymbolicLink(at: aliasParent, withDestinationURL: realParent)
            let recorder = RecyclerRecorder(trash: root.appending(path: "trash"))
            let result = await CleaningEngine(trashService: .init(recycle: { await recorder.move($0) }))
                .clean(items: [item(aliasParent.appending(path: "link"))])

            XCTAssertEqual(result.errors.count, 1)
            XCTAssertEqual(result.skippedCount, 1)
            XCTAssertEqual(result.removedCount, 0)
            let calls = await recorder.calls
            XCTAssertTrue(calls.isEmpty)
            XCTAssertNoThrow(try FileManager.default.destinationOfSymbolicLink(atPath: leaf.path))
            XCTAssertEqual(try Data(contentsOf: target).count, 17)
        }
    }

    func testLeafLinkSkipDoesNotHideTraversalOrRemoteURLs() async throws {
        try await TestFixtures.withTempDir { root in
            let target = root.appending(path: "target")
            let link = root.appending(path: "link")
            try TestFixtures.writeFile(at: target, size: 17)
            try FileManager.default.createSymbolicLink(at: link, withDestinationURL: target)
            try FileManager.default.createDirectory(at: root.appending(path: "nested"), withIntermediateDirectories: true)
            let traversal = root.appending(path: "nested/../link")
            var remoteParts = try XCTUnwrap(URLComponents(url: link, resolvingAgainstBaseURL: false))
            remoteParts.host = "example.com"
            let remote = try XCTUnwrap(remoteParts.url)
            XCTAssertFalse(TrashItemIdentity.isDirectSymbolicLink(traversal))
            XCTAssertFalse(TrashItemIdentity.isDirectSymbolicLink(remote))
            let recorder = RecyclerRecorder(trash: root.appending(path: "trash"))
            let result = await CleaningEngine(trashService: .init(recycle: { await recorder.move($0) }))
                .clean(items: [item(traversal), item(remote)])

            XCTAssertEqual(result.errors.count, 2)
            XCTAssertEqual(result.removedCount, 0)
            let calls = await recorder.calls
            XCTAssertTrue(calls.isEmpty)
            XCTAssertNoThrow(try FileManager.default.destinationOfSymbolicLink(atPath: link.path))
            XCTAssertEqual(try Data(contentsOf: target).count, 17)
        }
    }

    func testRegularFileReplacedByLinkDuringPreparationRemainsAnError() async throws {
        try await TestFixtures.withTempDir { root in
            let selected = root.appending(path: "selected")
            let target = root.appending(path: "unselected")
            for file in [selected, target] { try TestFixtures.writeFile(at: file, size: 17) }
            let reader = SymlinkReplacingIdentityReader(target: target)
            let recorder = RecyclerRecorder(trash: root.appending(path: "trash"))
            let engine = CleaningEngine(trashService: .init(recycle: { await recorder.move($0) }),
                                        readIdentity: { try reader.read($0) })
            let result = await engine.clean(items: [item(selected)])

            XCTAssertEqual(result.errors.count, 1)
            XCTAssertEqual(result.removedCount, 0)
            let calls = await recorder.calls
            XCTAssertTrue(calls.isEmpty)
            XCTAssertEqual(try Data(contentsOf: target).count, 17)
            XCTAssertNoThrow(try FileManager.default.destinationOfSymbolicLink(atPath: selected.path))
        }
    }

    func testSharedEngineRefusesConcurrentCleanupWithoutDispatchingSecondSelection() async throws {
        try await TestFixtures.withTempDir { root in
            let first = root.appending(path: "first")
            let second = root.appending(path: "second")
            for file in [first, second] { try TestFixtures.writeFile(at: file, size: 17) }
            let trash = root.appending(path: "trash")
            try FileManager.default.createDirectory(at: trash, withIntermediateDirectories: true)
            let controlled = ControlledRecycler()
            let engine = CleaningEngine(trashService: .init(recycle: { await controlled.recycle($0) }),
                                        trashRoot: trash.path)
            let firstItem = item(first)
            let firstTask = Task { await engine.clean(items: [firstItem]) }
            await controlled.waitForCall()

            let rejected = await engine.clean(items: [item(second)])
            XCTAssertEqual(rejected.removedCount, 0)
            XCTAssertEqual(rejected.errors.map(\.path), ["cleanup"])
            XCTAssertEqual(rejected.skippedCount, 1)
            XCTAssertTrue(FileManager.default.fileExists(atPath: second.path))

            let destination = trash.appending(path: "first")
            try FileManager.default.moveItem(at: first, to: destination)
            await controlled.finish(BatchTrashReceipt(relocated: [first: destination], errorMessage: nil))
            let completed = await firstTask.value
            XCTAssertEqual(completed.removedCount, 1)
            let calls = await controlled.calls
            XCTAssertEqual(calls, [[first]])
        }
    }

    func testFileReplacedDuringPreparationNeverReachesSystemBatch() async throws {
        try await TestFixtures.withTempDir { root in
            let file = root.appending(path: "a")
            try TestFixtures.writeFile(at: file, size: 17)
            let reader = ReplacingIdentityReader()
            let recorder = RecyclerRecorder(trash: root.appending(path: "trash"))
            let engine = CleaningEngine(trashService: .init(recycle: { await recorder.move($0) }),
                                       readIdentity: { try reader.read($0) })
            let result = await engine.clean(items: [item(file)])
            let calls = await recorder.calls
            XCTAssertTrue(calls.isEmpty)
            XCTAssertEqual(result.errors.count, 1)
            XCTAssertEqual(result.removedCount, 0)
        }
    }

    func testMissingAndDuplicateInputsDoNotCauseExtraRequests() async throws {
        try await TestFixtures.withTempDir { root in
            let file = root.appending(path: "a")
            let missing = root.appending(path: "missing")
            try TestFixtures.writeFile(at: file, size: 17)
            let recorder = RecyclerRecorder(trash: root.appending(path: "trash"))
            let engine = CleaningEngine(trashService: .init(recycle: { await recorder.move($0) }),
                                       trashRoot: root.appending(path: "trash").path)
            let result = await engine.clean(items: [item(file), item(file), item(missing)])
            let calls = await recorder.calls
            XCTAssertEqual(calls, [[file]])
            XCTAssertEqual(result.removedCount, 1)
            XCTAssertEqual(result.skippedCount, 1)
            XCTAssertTrue(result.errors.isEmpty)
        }
    }

    func testSystemCancellationStopsLaterBatchesAndPermanentStage() async throws {
        try await TestFixtures.withTempDir { root in
            let files = [root.appending(path: "a"), root.appending(path: "b"), root.appending(path: "permanent")]
            for file in files { try TestFixtures.writeFile(at: file, size: 17) }
            let cancelled = CancelledRecycler()
            let engine = CleaningEngine(trashService: .init(recycle: { await cancelled.recycle($0) }), batchSize: 1)
            let results = [ScanResult(category: .userCaches, items: [item(files[0]), item(files[1])]),
                           ScanResult(category: .trashBins, items: [item(files[2])])]
            let result = await CleanActions.executeUserClean(results: results, selectedItems: Set(files), engine: engine)
            let calls = await cancelled.calls
            XCTAssertEqual(calls.count, 1)
            XCTAssertTrue(result.wasCancelled)
            XCTAssertEqual(result.removedCount, 0)
            for file in files { XCTAssertTrue(FileManager.default.fileExists(atPath: file.path)) }
        }
    }

    func testTaskCancellationWaitsForCurrentReceiptAndDoesNotSubmitNextBatch() async throws {
        try await TestFixtures.withTempDir { root in
            let files = [root.appending(path: "a"), root.appending(path: "b")]
            for file in files { try TestFixtures.writeFile(at: file, size: 17) }
            let trash = root.appending(path: "trash")
            try FileManager.default.createDirectory(at: trash, withIntermediateDirectories: true)
            let controlled = ControlledRecycler()
            let engine = CleaningEngine(trashService: .init(recycle: { await controlled.recycle($0) }),
                                       trashRoot: trash.path, batchSize: 1)
            let items = files.map { item($0) }
            let task = Task { await engine.clean(items: items) }
            await controlled.waitForCall()
            task.cancel()
            let destination = trash.appending(path: "a")
            try FileManager.default.moveItem(at: files[0], to: destination)
            await controlled.finish(BatchTrashReceipt(relocated: [files[0]: destination], errorMessage: nil))
            let result = await task.value
            let calls = await controlled.calls
            XCTAssertEqual(calls, [[files[0]]])
            XCTAssertTrue(result.wasCancelled)
            XCTAssertEqual(result.removedURLs, [files[0]])
            XCTAssertEqual(result.trashedItems.first?.trashURL, destination)
            XCTAssertTrue(FileManager.default.fileExists(atPath: files[1].path))
        }
    }

    func testPermanentAndDryRunNeverUseBatchTrashService() async throws {
        try await TestFixtures.withTempDir { root in
            let file = root.appending(path: "a")
            try TestFixtures.writeFile(at: file, size: 17)
            let cancelled = CancelledRecycler()
            let engine = CleaningEngine(trashService: .init(recycle: { await cancelled.recycle($0) }))
            let dryRun = await engine.clean(items: [item(file)], mode: .dryRun)
            XCTAssertEqual(dryRun.removedCount, 1)
            XCTAssertTrue(FileManager.default.fileExists(atPath: file.path))
            let permanent = await engine.clean(items: [item(file)], mode: .permanent)
            XCTAssertEqual(permanent.removedCount, 1)
            XCTAssertFalse(FileManager.default.fileExists(atPath: file.path))
            let calls = await cancelled.calls
            XCTAssertTrue(calls.isEmpty)
        }
    }

    func testSystemCancellationErrorsAreRecognizedWithoutStringMatching() {
        XCTAssertTrue(BatchTrashService.isCancellation(CocoaError(.userCancelled)))
        XCTAssertTrue(BatchTrashService.isCancellation(NSError(domain: NSOSStatusErrorDomain, code: -128)))
        XCTAssertTrue(BatchTrashService.isCancellation(NSError(domain: "wrapper", code: 1,
            userInfo: [NSUnderlyingErrorKey: CocoaError(.userCancelled)])))
        XCTAssertFalse(BatchTrashService.isCancellation(CocoaError(.fileWriteNoPermission)))
    }
}

private actor RecyclerRecorder {
    private let trash: URL
    private(set) var calls: [[URL]] = []
    init(trash: URL) { self.trash = trash }

    func move(_ urls: [URL]) -> BatchTrashReceipt {
        calls.append(urls)
        var map: [URL: URL] = [:]
        do {
            try FileManager.default.createDirectory(at: trash, withIntermediateDirectories: true)
            for url in urls {
                let destination = trash.appending(path: url.lastPathComponent)
                try FileManager.default.moveItem(at: url, to: destination)
                map[url] = destination
            }
            return BatchTrashReceipt(relocated: map, errorMessage: nil)
        } catch {
            return BatchTrashReceipt(relocated: map, errorMessage: error.localizedDescription)
        }
    }
}

private actor CancelledRecycler {
    private(set) var calls: [[URL]] = []
    func recycle(_ urls: [URL]) -> BatchTrashReceipt {
        calls.append(urls)
        return BatchTrashReceipt(relocated: [:], errorMessage: "Cancelled", wasCancelled: true)
    }
}

private actor ControlledRecycler {
    private(set) var calls: [[URL]] = []
    private var continuation: CheckedContinuation<BatchTrashReceipt, Never>?
    func recycle(_ urls: [URL]) async -> BatchTrashReceipt {
        calls.append(urls)
        return await withCheckedContinuation { continuation = $0 }
    }
    func waitForCall() async {
        while continuation == nil { await Task.yield() }
    }
    func finish(_ receipt: BatchTrashReceipt) {
        continuation?.resume(returning: receipt)
        continuation = nil
    }
}

private final class ReplacingIdentityReader: @unchecked Sendable {
    private let lock = NSLock()
    private var calls = 0
    func read(_ url: URL) throws -> TrashItemIdentity {
        try lock.withLock {
            calls += 1
            let identity = try TrashItemIdentity.read(url)
            guard calls > 1 else { return identity }
            return TrashItemIdentity(device: identity.device, inode: identity.inode + 1,
                                     parentDevice: identity.parentDevice, parentInode: identity.parentInode,
                                     resolvedPath: identity.resolvedPath)
        }
    }
}

private final class SymlinkReplacingIdentityReader: @unchecked Sendable {
    private let lock = NSLock()
    private let target: URL
    private var calls = 0
    init(target: URL) { self.target = target }

    func read(_ url: URL) throws -> TrashItemIdentity {
        try lock.withLock {
            calls += 1
            if calls == 2 {
                try FileManager.default.removeItem(at: url)
                try FileManager.default.createSymbolicLink(at: url, withDestinationURL: target)
            }
            return try TrashItemIdentity.read(url)
        }
    }
}
