import XCTest
import AppKit
@testable import MacClean
import MacCleanKit

/// Guards the reason FileTableView exists: scan results can reach tens of
/// thousands of rows, and the table must stay responsive at that scale
/// (SwiftUI's List did not — it re-diffed every row on each update).
@MainActor
final class FileTableViewTests: XCTestCase {

    private func makeRows(_ n: Int) -> [FileListRow] {
        var rows: [FileListRow] = []
        rows.append(.header(FileListHeader(
            category: .userCaches, totalSize: 123, fileCount: n,
            selectedSize: 0, selectedCount: 0, isExpanded: true
        )))
        for i in 0..<n {
            rows.append(.item(
                FileItem(
                    url: URL(filePath: "/tmp/cache/file\(i).cache"),
                    name: "file\(i).cache",
                    size: UInt64(i),
                    allocatedSize: UInt64(i),
                    isDirectory: false
                ),
                isSelected: i.isMultiple(of: 2),
                appRunning: false
            ))
        }
        return rows
    }

    private func makeTable(coordinator: FileTableView.Coordinator) -> NSTableView {
        let table = NSTableView()
        let column = NSTableColumn(identifier: .init("main"))
        column.width = 600
        table.addTableColumn(column)
        table.headerView = nil
        table.usesAutomaticRowHeights = false
        table.dataSource = coordinator
        table.delegate = coordinator
        coordinator.tableView = table
        let scroll = NSScrollView(frame: NSRect(x: 0, y: 0, width: 600, height: 400))
        scroll.documentView = table
        return table
    }

    func testHundredThousandRowsReloadIsFast() {
        let coordinator = FileTableView.Coordinator()
        coordinator.rows = makeRows(100_000)
        let table = makeTable(coordinator: coordinator)

        let clock = ContinuousClock()
        let elapsed = clock.measure {
            table.reloadData()
            table.layoutSubtreeIfNeeded()
        }

        XCTAssertEqual(table.numberOfRows, 100_001)
        // Sub-second at 100k rows; the old SwiftUI List took multiple seconds
        // (and re-paid that cost on every interaction). Generous bound so CI
        // machines don't flake.
        XCTAssertLessThan(elapsed, .seconds(2), "reload must not scale with row count")
    }

    func testCellsMaterializeForHeaderAndItemRows() {
        let coordinator = FileTableView.Coordinator()
        coordinator.rows = makeRows(50)
        let table = makeTable(coordinator: coordinator)
        table.reloadData()

        let headerCell = table.view(atColumn: 0, row: 0, makeIfNecessary: true)
        let itemCell = table.view(atColumn: 0, row: 1, makeIfNecessary: true)
        XCTAssertNotNil(headerCell, "header row must produce a cell")
        XCTAssertNotNil(itemCell, "item row must produce a cell")
        XCTAssertNotEqual(
            headerCell?.identifier, itemCell?.identifier,
            "header and item rows use distinct reusable cell types"
        )
    }

    /// A category header truncates its name and explanation to one line each,
    /// so the tooltip is the only way to read them in full. Assert the cell the
    /// table actually materializes carries it.
    func testHeaderCellExposesTheCategoryTooltip() {
        let coordinator = FileTableView.Coordinator()
        coordinator.rows = makeRows(2)
        let table = makeTable(coordinator: coordinator)
        table.reloadData()

        let headerCell = table.view(atColumn: 0, row: 0, makeIfNecessary: true)
        XCTAssertEqual(headerCell?.toolTip, ScanCategory.userCaches.tooltip)
    }

    /// The review screen must say why a category is safe to clean (#180), not
    /// just what it contains: the header carries a badge with that rationale.
    func testHeaderCellShowsTheSafetyRationaleBadge() {
        let coordinator = FileTableView.Coordinator()
        coordinator.rows = makeRows(2)
        let table = makeTable(coordinator: coordinator)
        table.reloadData()

        let headerCell = table.view(atColumn: 0, row: 0, makeIfNecessary: true)
        let badge = headerCell?.subviews
            .compactMap { $0 as? NSButton }
            .first { $0.toolTip?.contains(ScanCategory.userCaches.safetyRationale) == true }
        XCTAssertNotNil(badge, "header must expose the category's safety rationale")
        XCTAssertEqual(badge?.accessibilityLabel(), ScanCategory.CleanupSafety.regenerates.label)
    }

    func testThreatGroupCheckboxIsDisabledUntilAnItemIsSelected() throws {
        let coordinator = FileTableView.Coordinator()
        coordinator.rows = [.header(FileListHeader(
            category: .possibleThreats, totalSize: 2, fileCount: 2,
            selectedSize: 0, selectedCount: 0, isExpanded: true
        ))]
        let table = makeTable(coordinator: coordinator)
        table.reloadData()
        let cell = try XCTUnwrap(table.view(atColumn: 0, row: 0, makeIfNecessary: true))
        let checkbox = try XCTUnwrap(cell.subviews.compactMap { $0 as? NSButton }
            .first { $0.allowsMixedState })
        XCTAssertFalse(checkbox.isEnabled)
        XCTAssertEqual(checkbox.toolTip, CleanupStrings.individualThreatSelectionHelp)
        XCTAssertEqual(checkbox.accessibilityHelp(), CleanupStrings.individualThreatSelectionHelp)
    }

    func testThreatGroupCheckboxClearsPartialSelectionAndIndividualCheckboxStillSelects() throws {
        let first = FileItem(url: URL(filePath: "/fixture/threat-a"), name: "a", size: 1,
                             allocatedSize: 1, isDirectory: false)
        let second = FileItem(url: URL(filePath: "/fixture/threat-b"), name: "b", size: 1,
                              allocatedSize: 1, isDirectory: false)
        let results = [ScanResult(category: .possibleThreats, items: [first, second], autoSelect: false)]
        var selection: Set<URL> = [first.url]
        let coordinator = FileTableView.Coordinator()
        coordinator.rows = FileListRows.flatten(results: results, isExpanded: { _ in true },
                                               selectedItems: selection)
        coordinator.onToggleAll = { category in
            selection = CleanupSelectionPolicy.togglingCategory(category, in: results, selection: selection)
        }
        coordinator.onToggleItem = { url in selection.insert(url) }
        let table = makeTable(coordinator: coordinator)
        table.reloadData()
        let header = try XCTUnwrap(table.view(atColumn: 0, row: 0, makeIfNecessary: true))
        let groupCheckbox = try XCTUnwrap(header.subviews.compactMap { $0 as? NSButton }
            .first { $0.allowsMixedState })
        XCTAssertTrue(groupCheckbox.isEnabled)
        XCTAssertEqual(groupCheckbox.state, .mixed)
        groupCheckbox.performClick(nil)
        XCTAssertTrue(selection.isEmpty, "group action must clear the partial selection, never select all threats")

        let item = try XCTUnwrap(table.view(atColumn: 0, row: 2, makeIfNecessary: true))
        let itemCheckbox = try XCTUnwrap(item.subviews.compactMap { $0 as? NSButton }
            .first { $0.action == NSSelectorFromString("checkboxClicked") })
        XCTAssertTrue(itemCheckbox.isEnabled)
        itemCheckbox.performClick(nil)
        XCTAssertEqual(selection, [second.url], "reviewed threats remain individually selectable")
    }

    func testRowHeightsAreFixedPerKind() {
        let coordinator = FileTableView.Coordinator()
        coordinator.rows = makeRows(2)
        let table = makeTable(coordinator: coordinator)

        let headerHeight = coordinator.tableView(table, heightOfRow: 0)
        let itemHeight = coordinator.tableView(table, heightOfRow: 1)
        XCTAssertGreaterThan(headerHeight, 0)
        XCTAssertGreaterThan(itemHeight, 0)
    }
}
