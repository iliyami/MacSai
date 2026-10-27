import XCTest
import Foundation
@testable import MacClean
@testable import MacCleanKit
import MacCleanTestSupport

/// **Wire-test** for the production Clean code path.
///
/// These tests are the regression-net for the May 2026 "scan finds junk but
/// nothing gets deleted" bug. Where `CleaningEngineTests` proves the *engine*
/// behaves correctly when given `.trash`, these tests prove the *view layer*
/// invokes the engine such that files actually move to Trash.
///
/// Methodology:
///   - Create real files under `~/Library/Caches/MacCleanTest-<uuid>/`
///     (an allowed safe-path so SafetyGuard permits operations).
///   - Build the exact `ScanResult` / `selectedItems` shape that a view
///     would assemble.
///   - Call `CleanActions.executeUserClean` — the same code path every
///     production Clean button uses.
///   - Assert the files are GONE from disk.
///
/// If anyone ever reintroduces `.dryRun` into `CleanActions`, these tests
/// fail immediately.
final class CleanActionsTests: XCTestCase {

    private var testDir: URL!
    /// Files this test placed directly in the real ~/.Trash. Removed in
    /// tearDown by exact path so a failing run never leaves litter behind.
    private var trashTestArtifacts: [URL] = []

    override func setUpWithError() throws {
        // Each test gets its own subdir of user caches.
        testDir = MCConstants.userCaches
            .appending(path: "MacCleanCleanActionsTest-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: testDir, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: testDir)
        for url in trashTestArtifacts {
            try? FileManager.default.removeItem(at: url)
        }
        trashTestArtifacts = []
    }

    // MARK: - Helpers

    /// Writes a real file of the given size; returns a FileItem describing it.
    private func writeReal(_ name: String, size: UInt64 = 100) throws -> (url: URL, item: FileItem) {
        let url = testDir.appending(path: name)
        try Data(count: Int(size)).write(to: url)
        let item = FileItem(
            url: url, name: name,
            size: size, allocatedSize: size,
            isDirectory: false
        )
        return (url, item)
    }

    private func exists(_ url: URL) -> Bool {
        FileManager.default.fileExists(atPath: url.path(percentEncoded: false))
    }

    private func writeUniversalApp(
        _ name: String
    ) throws -> (bundle: URL, binary: URL, item: FileItem) {
        let bundle = testDir.appending(path: "\(name).app")
        let binary = bundle.appending(path: "Contents/MacOS/\(name)")
        let built = try UniversalBinaryFixture.build(at: binary)
        try XCTSkipUnless(built, "cc not available")
        let item = FileItem(
            url: bundle,
            name: "\(name).app",
            size: 0,
            allocatedSize: 0,
            isDirectory: true
        )
        return (bundle, binary, item)
    }

    // MARK: - The big one: files actually leave the filesystem

    func testProductionPath_actuallyMovesSelectedFilesToTrash() async throws {
        let (urlA, itemA) = try writeReal("a.cache", size: 100)
        let (urlB, itemB) = try writeReal("b.cache", size: 200)
        let (urlC, itemC) = try writeReal("c.cache", size: 300)

        // Sanity: all three exist before
        XCTAssertTrue(exists(urlA))
        XCTAssertTrue(exists(urlB))
        XCTAssertTrue(exists(urlC))

        let results = [ScanResult(category: .userCaches, items: [itemA, itemB, itemC])]
        let selected: Set<URL> = [urlA, urlB, urlC]

        let result = await CleanActions.executeUserClean(
            results: results,
            selectedItems: selected,
            engine: CleaningEngine()
        )

        // The bug condition: dryRun would report 3 removed but files still exist.
        // Real trash: files are gone from the original path AND the report is accurate.
        XCTAssertFalse(exists(urlA), "a.cache should be gone from \(urlA.path(percentEncoded: false)) — if this fails, Clean is in dry-run mode")
        XCTAssertFalse(exists(urlB), "b.cache should be gone")
        XCTAssertFalse(exists(urlC), "c.cache should be gone")
        XCTAssertEqual(result.removedCount, 3)
        XCTAssertEqual(result.freedBytes, 600)
        XCTAssertTrue(result.errors.isEmpty)
    }

    // MARK: - Trash Bins: emptying must PERMANENTLY delete, not re-trash
    //
    // Bug (June 2026): TrashBins scan items already live in ~/.Trash.
    // Routing them through `.trash` mode calls FileManager.trashItem on a
    // file that's ALREADY in the Trash — a silent no-op that SUCCEEDS (so
    // removedCount increments and the UI reports "cleaned N items, freed
    // X bytes") while leaving the file exactly where it was. A rescan
    // re-finds everything; the Trash is never actually emptied.
    //
    // SPEC: `.trashBins` items must be permanently removed (engine
    // `.permanent` mode), so the file is genuinely gone from ~/.Trash.

    func testTrashBins_permanentlyDeletesItemsAlreadyInTheTrash() async throws {
        let trash = MCConstants.userTrash
        try FileManager.default.createDirectory(at: trash, withIntermediateDirectories: true)

        let name = "macclean-trashbins-test-\(UUID().uuidString).bin"
        let url = trash.appending(path: name)
        try Data(count: 256).write(to: url)
        trashTestArtifacts.append(url)

        XCTAssertTrue(exists(url), "precondition: throwaway file should be in ~/.Trash")

        let item = FileItem(url: url, name: name, size: 256, allocatedSize: 256, isDirectory: false)
        let results = [ScanResult(category: .trashBins, items: [item])]

        let result = await CleanActions.executeUserClean(
            results: results,
            selectedItems: [url],
            engine: CleaningEngine()
        )

        XCTAssertFalse(
            exists(url),
            "Emptying the Trash must PERMANENTLY remove the item from ~/.Trash. " +
            "If this fails, TrashBins items are being re-trashed (a no-op) instead of deleted."
        )
        XCTAssertEqual(result.removedCount, 1)
        XCTAssertTrue(result.errors.isEmpty, "unexpected errors: \(result.errors.map(\.error))")
    }

    // MARK: - Selection filtering: deselected items stay

    func testProductionPath_onlyDeletesSelectedItems() async throws {
        let (urlKeep, itemKeep) = try writeReal("keep.cache", size: 100)
        let (urlDelete, itemDelete) = try writeReal("delete.cache", size: 100)

        let results = [ScanResult(category: .userCaches, items: [itemKeep, itemDelete])]
        let selected: Set<URL> = [urlDelete] // only delete one

        let result = await CleanActions.executeUserClean(
            results: results, selectedItems: selected,
            engine: CleaningEngine()
        )

        XCTAssertTrue(exists(urlKeep), "unselected file must NOT be deleted")
        XCTAssertFalse(exists(urlDelete), "selected file must be deleted")
        XCTAssertEqual(result.removedCount, 1)
    }

    // MARK: - Empty selection is a no-op

    func testProductionPath_emptySelectionDoesNothing() async throws {
        let (url, item) = try writeReal("x.cache", size: 100)

        let results = [ScanResult(category: .userCaches, items: [item])]
        let result = await CleanActions.executeUserClean(
            results: results, selectedItems: [], // nothing selected
            engine: CleaningEngine()
        )

        XCTAssertTrue(exists(url), "file must still exist when nothing is selected")
        XCTAssertEqual(result.removedCount, 0)
        XCTAssertEqual(result.freedBytes, 0)
    }

    // MARK: - Cross-category aggregation

    func testProductionPath_aggregatesAcrossScanResultCategories() async throws {
        // A view might display multiple scan categories. The user selects items
        // from more than one. Engine must process all selected, regardless of
        // which category they came from.
        let (cacheURL, cacheItem) = try writeReal("from-caches.tmp")
        let (logURL, logItem) = try writeReal("from-logs.tmp")

        let results = [
            ScanResult(category: .userCaches, items: [cacheItem]),
            ScanResult(category: .userLogs, items: [logItem]),
        ]
        let result = await CleanActions.executeUserClean(
            results: results,
            selectedItems: [cacheURL, logURL],
            engine: CleaningEngine()
        )

        XCTAssertFalse(exists(cacheURL))
        XCTAssertFalse(exists(logURL))
        XCTAssertEqual(result.removedCount, 2)
    }

    // MARK: - Cancellation between clean phases

    func testCancellationAfterTrashSkipsPermanentDeleteAndThinning() async throws {
        let (cacheURL, cacheItem) = try writeReal("cancel-after-trash.cache")

        let trash = MCConstants.userTrash
        try FileManager.default.createDirectory(at: trash, withIntermediateDirectories: true)
        let trashURL = trash.appending(path: "macclean-cancel-test-\(UUID().uuidString).bin")
        try Data(count: 128).write(to: trashURL)
        trashTestArtifacts.append(trashURL)
        let trashItem = FileItem(
            url: trashURL,
            name: trashURL.lastPathComponent,
            size: 128,
            allocatedSize: 128,
            isDirectory: false
        )

        let app = try writeUniversalApp("CancelAfterTrash")
        let results = [
            ScanResult(category: .userCaches, items: [cacheItem]),
            ScanResult(category: .trashBins, items: [trashItem]),
            ScanResult(category: .universalBinaries, items: [app.item]),
        ]

        let result = await CleanActions.executeUserClean(
            results: results,
            selectedItems: [cacheURL, trashURL, app.bundle],
            engine: CleaningEngine(),
            onProgress: { _ in
                withUnsafeCurrentTask { $0?.cancel() }
            }
        )

        XCTAssertFalse(exists(cacheURL), "trash phase should return its completed work")
        XCTAssertTrue(exists(trashURL), "cancellation must skip the permanent-delete phase")
        XCTAssertEqual(
            Set(UniversalBinaryFixture.architectures(of: app.binary)),
            Set(["x86_64", "arm64"]),
            "cancellation must skip thinning"
        )
        XCTAssertEqual(result.removedCount, 1, "result should contain only completed trash work")
    }

    func testCancellationAfterPermanentDeleteSkipsThinning() async throws {
        let trash = MCConstants.userTrash
        try FileManager.default.createDirectory(at: trash, withIntermediateDirectories: true)
        let trashURL = trash.appending(path: "macclean-cancel-test-\(UUID().uuidString).bin")
        try Data(count: 128).write(to: trashURL)
        trashTestArtifacts.append(trashURL)
        let trashItem = FileItem(
            url: trashURL,
            name: trashURL.lastPathComponent,
            size: 128,
            allocatedSize: 128,
            isDirectory: false
        )

        let app = try writeUniversalApp("CancelAfterPermanent")
        let results = [
            ScanResult(category: .trashBins, items: [trashItem]),
            ScanResult(category: .universalBinaries, items: [app.item]),
        ]

        let result = await CleanActions.executeUserClean(
            results: results,
            selectedItems: [trashURL, app.bundle],
            engine: CleaningEngine(),
            onProgress: { _ in
                withUnsafeCurrentTask { $0?.cancel() }
            }
        )

        XCTAssertFalse(exists(trashURL), "permanent-delete phase should return its completed work")
        XCTAssertEqual(
            Set(UniversalBinaryFixture.architectures(of: app.binary)),
            Set(["x86_64", "arm64"]),
            "cancellation must skip thinning"
        )
        XCTAssertEqual(result.removedCount, 1, "result should contain only completed permanent-delete work")
    }

    func testAlreadyCancelledTaskSkipsEveryUniversalBinaryBundle() async throws {
        let first = try writeUniversalApp("CancelledFirst")
        let second = try writeUniversalApp("CancelledSecond")
        let results = [
            ScanResult(category: .universalBinaries, items: [first.item, second.item])
        ]

        let result = await Task {
            withUnsafeCurrentTask { $0?.cancel() }
            return await CleanActions.executeUserClean(
                results: results,
                selectedItems: [first.bundle, second.bundle],
                engine: CleaningEngine()
            )
        }.value

        for binary in [first.binary, second.binary] {
            XCTAssertEqual(
                Set(UniversalBinaryFixture.architectures(of: binary)),
                Set(["x86_64", "arm64"]),
                "the thinning loop must stop before processing a bundle when cancelled"
            )
        }
        XCTAssertEqual(result.removedCount, 0)
        XCTAssertEqual(result.freedBytes, 0)
    }

    // MARK: - Universal binary result accuracy

    func testThinningDoesNotCountBundleWhenNoBinaryWasThinned() async throws {
        let app = try writeUniversalApp("AllBinariesFail")
        let executableDirectory = app.binary.deletingLastPathComponent()
        try FileManager.default.setAttributes(
            [.posixPermissions: NSNumber(value: Int16(0o555))],
            ofItemAtPath: executableDirectory.path(percentEncoded: false)
        )
        defer {
            try? FileManager.default.setAttributes(
                [.posixPermissions: NSNumber(value: Int16(0o755))],
                ofItemAtPath: executableDirectory.path(percentEncoded: false)
            )
        }

        let result = await CleanActions.executeUserClean(
            results: [ScanResult(category: .universalBinaries, items: [app.item])],
            selectedItems: [app.bundle],
            engine: CleaningEngine()
        )

        XCTAssertEqual(result.removedCount, 0, "a bundle with zero successful thins is not removed")
        XCTAssertEqual(result.freedBytes, 0)
        XCTAssertFalse(result.errors.isEmpty, "per-binary failures must still be reported")
        XCTAssertEqual(
            Set(UniversalBinaryFixture.architectures(of: app.binary)),
            Set(["x86_64", "arm64"])
        )
    }

    // MARK: - Uninstaller variant (flat item list)

    func testProductionPath_uninstallerVariantDeletes() async throws {
        let (url1, item1) = try writeReal("app-leftover-1.cache", size: 50)
        let (url2, item2) = try writeReal("app-leftover-2.cache", size: 75)

        let result = await CleanActions.executeUserClean(
            items: [item1, item2],
            selectedItems: [url1, url2],
            engine: CleaningEngine()
        )

        XCTAssertFalse(exists(url1))
        XCTAssertFalse(exists(url2))
        XCTAssertEqual(result.removedCount, 2)
        XCTAssertEqual(result.freedBytes, 125)
    }

    func testProductionPath_uninstallerRespectsSelection() async throws {
        let (keepURL, keep) = try writeReal("keep-leftover.cache", size: 50)
        let (deleteURL, delete) = try writeReal("delete-leftover.cache", size: 50)

        let result = await CleanActions.executeUserClean(
            items: [keep, delete],
            selectedItems: [deleteURL],
            engine: CleaningEngine()
        )

        XCTAssertTrue(exists(keepURL))
        XCTAssertFalse(exists(deleteURL))
        XCTAssertEqual(result.removedCount, 1)
    }

    // MARK: - Safety: protected paths still blocked

    func testProductionPath_refusesProtectedSystemPath() async throws {
        // Build a ScanResult containing /System/Library — SafetyGuard should
        // reject the entire batch, no matter how the view assembled it.
        let unsafeItem = FileItem(
            url: URL(filePath: "/System/Library/CoreServices/Finder.app"),
            name: "Finder.app",
            size: 100, allocatedSize: 100,
            isDirectory: true
        )
        let results = [ScanResult(category: .userCaches, items: [unsafeItem])]

        let result = await CleanActions.executeUserClean(
            results: results,
            selectedItems: [unsafeItem.url],
            engine: CleaningEngine()
        )

        XCTAssertEqual(result.removedCount, 0, "Protected path must never be removed")
        XCTAssertFalse(result.errors.isEmpty, "Engine must report the validation failure")
    }

    // MARK: - Behavior contract: result counts match reality

    func testProductionPath_resultCountsMatchFilesystemReality() async throws {
        // The bug we caught was "reports success but did nothing." Verify the
        // engine's report matches what's actually on disk after.
        var urls: [URL] = []
        var items: [FileItem] = []
        for i in 0..<5 {
            let (u, it) = try writeReal("file-\(i).cache", size: UInt64(i + 1) * 100)
            urls.append(u)
            items.append(it)
        }
        let expectedBytes: UInt64 = items.reduce(0) { $0 + $1.size }

        let result = await CleanActions.executeUserClean(
            results: [ScanResult(category: .userCaches, items: items)],
            selectedItems: Set(urls),
            engine: CleaningEngine()
        )

        // Count matches files actually removed
        let stillExisting = urls.filter { exists($0) }
        XCTAssertEqual(stillExisting.count, 0, "All selected files should be gone")
        XCTAssertEqual(result.removedCount, urls.count)
        XCTAssertEqual(result.freedBytes, expectedBytes)
    }

    // MARK: - Spec: ancestor/descendant dedup
    //
    // The scanner returns both directories AND their descendants as
    // separate items. Without dedup, the engine processes the directory
    // first (trashing the whole subtree in one move), then loops through
    // each descendant — each of which now points at a path that no
    // longer exists. Result: thousands of "no such file" errors and
    // freedBytes massively undercounted because the directory entry
    // itself reports size 0 (totalFileAllocatedSize doesn't recurse
    // into dirs).
    //
    // SPEC: when both a parent dir and its descendant are selected,
    // only the parent dir should be sent to the engine. Trashing the
    // parent takes the descendants with it.

    func testCleanActions_dedupsDescendantsOfSelectedDirectories() async throws {
        try await TestFixtures.withTempDir { home in
            // Layout:
            //   parent/
            //     child1.txt
            //     sub/
            //       child2.txt
            //   standalone.txt
            let parent = home.appending(path: "parent")
            let child1 = parent.appending(path: "child1.txt")
            let sub = parent.appending(path: "sub")
            let child2 = sub.appending(path: "child2.txt")
            let standalone = home.appending(path: "standalone.txt")

            try FileManager.default.createDirectory(at: sub, withIntermediateDirectories: true)
            try Data("c1".utf8).write(to: child1)
            try Data("c2".utf8).write(to: child2)
            try Data("st".utf8).write(to: standalone)

            // Build items as the scanner would — parent dir + every
            // descendant + the standalone file. ALL selected.
            let items = [
                FileItem(url: parent, name: "parent", size: 0, allocatedSize: 0, isDirectory: true),
                FileItem(url: child1, name: "child1.txt", size: 2, allocatedSize: 2, isDirectory: false),
                FileItem(url: sub, name: "sub", size: 0, allocatedSize: 0, isDirectory: true),
                FileItem(url: child2, name: "child2.txt", size: 2, allocatedSize: 2, isDirectory: false),
                FileItem(url: standalone, name: "standalone.txt", size: 2, allocatedSize: 2, isDirectory: false),
            ]
            let result = await CleanActions.executeUserClean(
                results: [ScanResult(category: .userCaches, items: items)],
                selectedItems: Set(items.map(\.url)),
                engine: CleaningEngine()
            )

            // SPEC: zero errors. The descendants of `parent` and `sub`
            // never reach the engine, so no "no such file" failures
            // from the parent-already-trashed race.
            XCTAssertTrue(result.errors.isEmpty,
                "dedup should eliminate the parent-trashed-before-child race; got: \(result.errors.map(\.error))")

            // Filesystem reality: everything is gone.
            for url in [parent, child1, sub, child2, standalone] {
                XCTAssertFalse(
                    FileManager.default.fileExists(atPath: url.path(percentEncoded: false)),
                    "expected \(url.lastPathComponent) to be trashed"
                )
            }

            // SPEC: removedCount reflects the post-dedup count (2 ops:
            // trash parent, trash standalone), not the inflated pre-dedup
            // count of 5. UI should show users an honest number.
            XCTAssertEqual(result.removedCount, 2,
                "expected 2 trash operations (parent + standalone); descendants ride along with parent")
        }
    }
}
