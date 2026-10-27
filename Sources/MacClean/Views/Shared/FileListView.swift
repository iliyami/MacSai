import SwiftUI
import AppKit
import MacCleanKit

func fileListResultsSignature(sort: FileListSort, results: [ScanResult]) -> String {
    sort.rawValue + "#" + results.map {
        let generation = $0.items.first?.id.uuidString ?? "empty"
        return "\($0.category.rawValue):\($0.items.count):\(generation)"
    }
        .joined(separator: ",")
}

/// Scan-results list: a sort control over an AppKit-backed table.
///
/// The table is `NSTableView` (see `FileTableView`) because SwiftUI's `List`
/// re-diffs every row on each view update, which froze the UI once scans
/// produced tens of thousands of items. Sorting runs off the main thread into
/// `displayResults`; the render path never sorts.
public struct FileListView: View {
    let results: [ScanResult]
    let showsBulkSelection: Bool
    @Binding var selectedItems: Set<URL>
    @State private var expansion = FileListExpansion()
    @State private var sort: FileListSort = .default
    /// Bundle ids of apps running right now, so item rows can show an "App open"
    /// badge. Snapshotted on appear; the set rarely changes during a review.
    @State private var runningBundleIDs: Set<String> = []
    /// Item URLs whose owning app is running. Precomputed off the render path
    /// (the path→bundle-id work is expensive) so selection toggles stay snappy.
    @State private var appRunningURLs: Set<URL> = []
    /// Results with each category's items already sorted, computed off-main
    /// in the `.task` below. Seeded unsorted so content shows immediately.
    @State private var displayResults: [ScanResult]
    /// Memoized flattened rows. Rebuilt only when `rowsKey` changes, NOT on
    /// every body evaluation: ContentView keeps this view alive and re-renders
    /// it on every sidebar switch, and re-flattening tens of thousands of rows
    /// each time (plus the table's O(n) diff) caused a multi-second stall when
    /// switching away from a finished junk scan and back.
    @State private var rows: [FileListRow] = []

    public init(results: [ScanResult], selectedItems: Binding<Set<URL>>, showsBulkSelection: Bool = false) {
        self.results = results
        self.showsBulkSelection = showsBulkSelection
        self._selectedItems = selectedItems
        self._displayResults = State(initialValue: results)
    }

    public var body: some View {
        VStack(spacing: 0) {
            sortBar

            FileTableView(
                rows: rows,
                onToggleItem: { toggle($0) },
                onToggleAll: { toggleAll($0) },
                onToggleExpand: { expansion.toggle($0) }
            )
        }
        .onAppear {
            runningBundleIDs = Set(NSWorkspace.shared.runningApplications.compactMap(\.bundleIdentifier))
        }
        // Rebuild the flattened rows only when something they depend on actually
        // changes (displayed result generation, selection, expansion, running
        // apps). A
        // sidebar switch changes none of these, so it does no work here.
        .onChange(of: rowsKey, initial: true) { _, _ in
            rows = FileListRows.flatten(
                results: displayResults,
                isExpanded: { expansion.isExpanded($0) },
                selectedItems: selectedItems,
                appRunningURLs: appRunningURLs
            )
        }
        .onChange(of: selectedItems) { _, _ in
            rows = FileListRows.flatten(
                results: displayResults,
                isExpanded: { expansion.isExpanded($0) },
                selectedItems: selectedItems,
                appRunningURLs: appRunningURLs
            )
        }
        // Recompute "app open" URLs only when the results or running apps change,
        // off the main thread — never on a selection toggle.
        .task(id: "\(sortSignature)#\(runningBundleIDs.count)") {
            let snapshot = results
            let running = runningBundleIDs
            appRunningURLs = await Task.detached(priority: .utility) {
                AppCacheOwnership.runningOwnedURLs(in: snapshot, runningBundleIDs: running)
            }.value
        }
        // Re-sort off the main thread whenever the sort or the result set
        // changes. Keyed on a cheap per-category generation signature so
        // same-count rescans refresh without re-running on selection toggles.
        .task(id: sortSignature) {
            let snapshot = results
            let order = sort
            let sorted = await Task.detached(priority: .userInitiated) {
                order.sorted(snapshot)
            }.value
            displayResults = sorted
        }
    }

    /// Cheap key for `.task(id:)`: the sort plus each category's count and the
    /// first item's scan-unique identity. A rescan constructs fresh FileItems,
    /// so same-count result sets still start new sorting and ownership tasks.
    /// Computed per render but only O(number of categories).
    private var sortSignature: String {
        fileListResultsSignature(sort: sort, results: results)
    }

    /// Use the asynchronously sorted results here, not the incoming results.
    /// This guarantees the row rebuild happens after `displayResults` receives
    /// the new scan generation.
    private var displayedResultsSignature: String {
        fileListResultsSignature(sort: sort, results: displayResults)
    }

    /// Selection is observed separately: bulk actions can replace the URLs
    /// without changing their count. This key covers the displayed rows only.
    private var rowsKey: String {
        "\(displayedResultsSignature)|exp:\(expansion.signature)|run:\(appRunningURLs.count)"
    }

    /// Compact sort control above the list. Defaults to largest-first; lets the
    /// user flip to smallest-first or name order.
    private var sortBar: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 12) {
                if showsBulkSelection { selectionControls }
                Spacer(minLength: 8)
                sortControl
            }
            VStack(alignment: .leading, spacing: 8) {
                if showsBulkSelection { selectionControls }
                HStack { Spacer(); sortControl }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var selectionControls: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 12) {
                selectAllButton
                selectSafeButton
                deselectAllButton
            }
            .fixedSize(horizontal: true, vertical: false)
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) { selectAllButton; selectSafeButton }
                deselectAllButton
            }
        }
        .buttonStyle(.borderless)
        .font(.caption)
        .disabled(results.isEmpty)
    }

    private var selectAllButton: some View {
        Button(L10n.tr("全选", "Select All", "Выбрать всё")) {
            selectedItems = CleanupSelectionPolicy.allURLs(in: results)
        }
    }

    private var selectSafeButton: some View {
        Button(L10n.tr("选择安全项目", "Select Safe Items", "Выбрать безопасные")) {
            selectedItems = CleanupSelectionPolicy.safeURLs(in: results)
        }
        .help(L10n.tr(
            "仅保留安全的临时文件、缓存、日志和残留文件。不选择个人数据、废纸篓或应用修改。",
            "Keeps safe temporary files, caches, logs and leftovers selected. Excludes personal data, Trash and application changes.",
            "Оставляет безопасные временные файлы, кэш, журналы и остатки. Личные данные, Корзина и изменения приложений не выбираются."))
    }

    private var deselectAllButton: some View {
        Button(L10n.tr("取消全选", "Deselect All", "Снять всё")) {
            selectedItems.removeAll()
        }
        .disabled(selectedItems.isEmpty)
    }

    private var sortControl: some View {
        HStack(spacing: 6) {
            Image(systemName: "arrow.up.arrow.down")
                .font(.caption2)
                .foregroundStyle(.tertiary)
            Menu {
                Picker(L10n.tr("排序方式", "Sort by", "Сортировать по"), selection: $sort) {
                    ForEach(FileListSort.allCases, id: \.self) { option in
                        Text(option.label).tag(option)
                    }
                }
                .pickerStyle(.inline)
            } label: {
                Text(sort.label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
        }
    }

    /// Toggle selection of a single file by URL.
    private func toggle(_ url: URL) {
        if selectedItems.contains(url) {
            selectedItems.remove(url)
        } else {
            selectedItems.insert(url)
        }
    }

    /// Select-all / deselect-all for a category: if every item is already
    /// selected, deselect them; otherwise select them all.
    private func toggleAll(_ category: ScanCategory) {
        guard let result = results.first(where: { $0.category == category }) else { return }
        let urls = Set(result.items.map(\.url))
        if urls.isSubset(of: selectedItems) {
            selectedItems.subtract(urls)
        } else {
            selectedItems.formUnion(urls)
        }
    }
}
