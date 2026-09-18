import XCTest
import Foundation
@testable import MacClean
import MacCleanKit

final class RescanStaleFileListTests: XCTestCase {
    private func viewsRoot() -> URL {
        URL(filePath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appending(path: "Sources/MacClean/Views")
    }

    private func source(at relativePath: String) throws -> String {
        try String(
            contentsOf: viewsRoot().appending(path: relativePath),
            encoding: .utf8
        )
    }

    private func item(_ path: String) -> FileItem {
        FileItem(
            url: URL(filePath: path),
            name: URL(filePath: path).lastPathComponent,
            size: 1,
            allocatedSize: 1,
            isDirectory: false
        )
    }

    func testModuleContainerShowsScanningBeforeExistingResults() throws {
        let source = try source(at: "Shared/ModuleContainerView.swift")
        let scanning = try XCTUnwrap(source.range(of: "} else if isScanning {"))
        let results = try XCTUnwrap(source.range(of: "} else if !results.isEmpty {"))

        XCTAssertLessThan(
            scanning.lowerBound,
            results.lowerBound,
            "An in-flight rescan must replace stale results with scanning progress"
        )
    }

    func testAffectedModulesClearResultsAndSelectionAtScanStart() throws {
        let paths = [
            "Files/LargeOldFilesView.swift",
            "Protection/PrivacyView.swift",
            "Protection/MalwareView.swift",
            "Cleanup/TrashBinsView.swift",
            "Cleanup/MailAttachmentsView.swift",
        ]

        for path in paths {
            let source = try source(at: path)
            let scanStart = try XCTUnwrap(source.range(of: "private func scan()"))
            let cleanStart = try XCTUnwrap(
                source.range(of: "private func clean()", range: scanStart.upperBound..<source.endIndex)
            )
            let scanBody = source[scanStart.lowerBound..<cleanStart.lowerBound]

            XCTAssertTrue(scanBody.contains("results = []"), "\(path) must discard stale results")
            XCTAssertTrue(scanBody.contains("selectedItems = []"), "\(path) must discard stale selection")
        }
    }

    func testFileListSignatureChangesForSameCountRescanWithDifferentURLs() {
        let first = [
            ScanResult(category: .userCaches, items: [item("/tmp/first.cache")]),
        ]
        let second = [
            ScanResult(category: .userCaches, items: [item("/tmp/second.cache")]),
        ]

        XCTAssertNotEqual(
            fileListResultsSignature(sort: .sizeDescending, results: first),
            fileListResultsSignature(sort: .sizeDescending, results: second)
        )
    }

    func testRowsRebuildAfterAsynchronousDisplayResultsUpdate() throws {
        let source = try source(at: "Shared/FileListView.swift")
        let rowsKeyStart = try XCTUnwrap(source.range(of: "private var rowsKey"))
        let sortBarStart = try XCTUnwrap(
            source.range(of: "private var sortBar", range: rowsKeyStart.upperBound..<source.endIndex)
        )
        let rowsKey = source[rowsKeyStart.lowerBound..<sortBarStart.lowerBound]

        XCTAssertTrue(
            rowsKey.contains("displayedResultsSignature"),
            "Rows must be keyed from asynchronously updated displayResults, not stale input results"
        )
    }
}
