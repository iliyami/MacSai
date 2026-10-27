import SwiftUI
import MacCleanKit

struct SmartScanView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.moduleIsSelected) private var moduleIsSelected
    @AppStorage("removeBackgroundColors") private var removeBackgroundColors = false
    @State private var scanState: SmartScanState = .idle
    @State private var completedModules: [CompletedModule] = []
    @State private var currentModuleName: String = ""
    @State private var selectedItems: Set<URL> = []
    @State private var cleanResults: [ScanResult] = []
    @State private var askForSupport = false
    @State private var showCleanConfirm = false
    @State private var showActivityLog = false
    @State private var cleanTask: Task<Void, Never>?
    /// Watches `ScanCoordinator` while a Smart Scan runs. Cancelled by
    /// `cancelScan()` so we stop polling and return to idle promptly (#3).
    @State private var scanWatchTask: Task<Void, Never>?
    /// Cached selected-size total + a url -> size index backing it, so the
    /// footer reads an O(1) value instead of an O(all-items) sum on every body
    /// pass (the sidebar-switch beachball on large Smart Scans).
    @State private var selectedCleanSize: UInt64 = 0
    @State private var cleanSizeIndex: [URL: UInt64] = [:]

    struct CompletedModule: Identifiable {
        let id = UUID()
        let name: String
        let icon: String
        let fileCount: Int
        let size: UInt64
    }

    enum SmartScanState {
        case idle
        case scanning(phase: String, progress: Double, filesFound: Int, sizeFound: UInt64)
        case results(cleanup: UInt64, protection: Int, performance: Int, totalSize: UInt64, moduleResults: [ModuleScanResult])
        case empty
        case cleaning(progress: Double)
        case done(summary: CleanSummary, breakdown: [SmartScanCleanup.RecentlyCleanedRow])
    }

    private static var moduleOrder: [(id: String, name: String, icon: String, group: String)] {
        [
            ("systemJunk", L10n.tr("系统垃圾", "System Junk", "Системный мусор"), "trash.circle.fill", L10n.tr("清理", "Cleanup", "Очистка")),
            ("mailAttachments", L10n.tr("邮件附件", "Mail Attachments", "Почтовые вложения"), "paperclip.circle.fill", L10n.tr("清理", "Cleanup", "Очистка")),
            ("trashBins", L10n.tr("废纸篓", "Trash Bins", "Корзины"), "trash.fill", L10n.tr("清理", "Cleanup", "Очистка")),
            ("malware", L10n.tr("恶意软件清理", "Malware Removal", "Удаление угроз"), "shield.lefthalf.filled", L10n.tr("防护", "Protection", "Защита")),
            ("privacy", L10n.tr("隐私清理", "Privacy", "Конфиденциальность"), "hand.raised.fill", L10n.tr("防护", "Protection", "Защита")),
            ("optimization", L10n.tr("优化", "Optimization", "Оптимизация"), "gauge.with.dots.needle.67percent", L10n.tr("加速", "Speed", "Ускорение")),
            ("maintenance", L10n.tr("维护", "Maintenance", "Обслуживание"), "wrench.and.screwdriver", L10n.tr("加速", "Speed", "Ускорение")),
            ("uninstaller", L10n.tr("卸载器", "Uninstaller", "Удаление приложений"), "xmark.app.fill", L10n.tr("应用", "Apps", "Приложения")),
            ("updater", L10n.tr("应用更新", "Updater", "Обновления"), "arrow.triangle.2.circlepath", L10n.tr("应用", "Apps", "Приложения")),
            ("largeOldFiles", L10n.tr("大文件与旧文件", "Large & Old Files", "Большие и старые файлы"), "doc.richtext.fill", L10n.tr("文件", "Files", "Файлы")),
        ]
    }

    var body: some View {
        Group {
            switch scanState {
            case .idle:
                idleView
            case .scanning(let phase, let progress, let filesFound, let sizeFound):
                scanningView(phase: phase, progress: progress, filesFound: filesFound, sizeFound: sizeFound)
            case .results(_, _, _, let totalSize, _):
                resultsView(totalSize: totalSize)
            case .empty:
                emptyView
            case .cleaning(let progress):
                cleaningView(progress: progress)
            case .done(let summary, let breakdown):
                doneView(summary: summary, breakdown: breakdown)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar {
            if moduleIsSelected {
                ToolbarItem { CleanupPermissionsButton() }
            }
        }
        .sheet(isPresented: $showActivityLog) { LogViewerView() }
        // Recompute the selected-size total only when the results or selection
        // actually change, NOT on every body pass. The footer reads
        // `selectedCleanSize`, and SwiftUI re-evaluates this body during the
        // layout pass on every sidebar switch; recomputing an O(all-items) sum
        // (with a FileItem copy per item) there froze the switch for seconds on
        // a large Smart Scan (confirmed by a main-thread sample).
        .onChange(of: cleanResultsSignature, initial: true) { _, _ in
            rebuildCleanSizeIndex()
            recomputeSelectedCleanSize()
        }
        .onChange(of: selectedItems) { _, _ in
            recomputeSelectedCleanSize()
        }
        .respondsToModuleShortcuts(
            onScan: startScan,
            onClean: { showCleanConfirm = true },
            canScan: {
                switch scanState {
                case .idle, .empty, .done, .results: true
                case .scanning, .cleaning: false
                }
            }(),
            canClean: {
                if case .results = scanState { return !selectedItems.isEmpty }
                return false
            }()
        )
    }

    // MARK: - Idle

    private var idleView: some View {
        VStack(spacing: 28) {
            Spacer()

            VStack(spacing: 8) {
                Text(L10n.tr("智能扫描", "Smart Scan", "Умное сканирование"))
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.primary)
                Text(L10n.tr("扫描 Mac 中的垃圾文件、恶意威胁\n和性能问题", "Scan your Mac for junk files, malware threats,\nand performance issues", "Поиск на Mac мусора, вредоносных программ\nи проблем с производительностью"))
                    .font(.system(size: 14))
                    .foregroundStyle(.primary.opacity(0.65))
                    .multilineTextAlignment(.center)
            }

            ScanButton(
                title: L10n.tr("扫描", "Scan", "Сканировать"),
                subtitle: L10n.tr("一键清理", "One-click cleanup", "Очистка одним нажатием"),
                theme: .smartScan,
                action: startScan
            )

            Spacer()
        }
        .padding(.horizontal, 40)
    }

    // MARK: - Scanning (redesigned)

    private func scanningView(phase: String, progress: Double, filesFound: Int, sizeFound: UInt64) -> some View {
        VStack(spacing: 0) {
            // Top stats bar
            HStack(spacing: 24) {
                statBadge(label: L10n.tr("进度"), value: "\(Int(progress * 100))%")
                statBadge(label: L10n.tr("已发现文件", "Files Found", "Найдено файлов"), value: filesFound.formatted())
                statBadge(label: L10n.tr("大小", "Size", "Размер"), value: FileSizeFormatter.format(sizeFound))
            }
            .padding(.horizontal, 30)
            .padding(.top, 16)
            .padding(.bottom, 12)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(.primary.opacity(0.12))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(.primary)
                        .frame(width: geo.size.width * progress, height: 6)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 6)
            .padding(.horizontal, 30)
            .padding(.bottom, 16)

            // Module checklist
            ScrollView {
                VStack(spacing: 2) {
                    ForEach(Array(Self.moduleOrder.enumerated()), id: \.offset) { index, module in
                        moduleRow(module: module, currentPhase: phase)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
            .background {
                if removeBackgroundColors { Color.clear }
                else { Rectangle().fill(.ultraThinMaterial.opacity(0.5)) }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 20)

            Button(L10n.tr("取消", "Cancel", "Отмена")) { cancelScan() }
                .buttonStyle(.bordered)
                .tint(.primary)
                .controlSize(.large)
                .padding(.bottom, 20)
        }
    }

    private func moduleRow(module: (id: String, name: String, icon: String, group: String), currentPhase: String) -> some View {
        let isActive = currentPhase == module.name
        let completed = completedModules.contains { $0.name == module.name }
        let completedInfo = completedModules.first { $0.name == module.name }

        return HStack(spacing: 10) {
            // Status icon
            ZStack {
                if isActive {
                    ProgressView()
                        .controlSize(.small)
                        .tint(.primary)
                } else if completed {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.green)
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 16))
                        .foregroundStyle(.primary.opacity(0.2))
                }
            }
            .frame(width: 20)

            // Module icon
            Image(systemName: module.icon)
                .font(.system(size: 14))
                .foregroundStyle(isActive ? Color.primary : Color.primary.opacity(completed ? 0.6 : 0.25))
                .frame(width: 20)

            // Module name
            Text(module.name)
                .font(.system(size: 13, weight: isActive ? .semibold : .regular))
                .foregroundStyle(isActive ? Color.primary : Color.primary.opacity(completed ? 0.7 : 0.3))

            Spacer()

            // Results for completed modules
            if let info = completedInfo, info.fileCount > 0 {
                Text(L10n.tr("\(info.fileCount) 项", "\(info.fileCount) items", "\(info.fileCount) \(L10n.russianPlural(info.fileCount, one: "объект", few: "объекта", many: "объектов"))"))
                    .font(.system(size: 11))
                    .foregroundStyle(.primary.opacity(0.5))
                Text(FileSizeFormatter.format(info.size))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.primary.opacity(0.6))
            } else if completedInfo != nil {
                Text(L10n.tr("干净", "Clean", "Чисто"))
                    .font(.system(size: 11))
                    .foregroundStyle(.green.opacity(0.7))
            }

            // Group tag
            Text(module.group)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.primary.opacity(0.4))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.primary.opacity(0.08))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isActive ? Color.primary.opacity(0.1) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func statBadge(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.2), value: value)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.primary.opacity(0.5))
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Results

    private func resultsView(totalSize: UInt64) -> some View {
        VStack(spacing: 20) {
            SizeDisplay(size: totalSize, label: L10n.tr("发现的垃圾", "of junk found", "найдено мусора"))
                .foregroundStyle(.primary)
                .padding(.top, 24)

            HStack(spacing: 24) {
                if case .results(let cleanup, _, _, _, _) = scanState {
                    resultPill(icon: "trash.circle.fill", label: L10n.tr("清理", "Cleanup", "Очистка"), value: FileSizeFormatter.format(cleanup))
                }
                if case .results(_, let threats, _, _, _) = scanState {
                    resultPill(icon: "shield.lefthalf.filled", label: L10n.tr("防护", "Protection", "Защита"), value: L10n.tr("\(threats) 个威胁", "\(threats) threats", "\(threats) \(L10n.russianPlural(threats, one: "угроза", few: "угрозы", many: "угроз"))"))
                }
                if case .results(_, _, let perf, _, _) = scanState {
                    resultPill(icon: "gauge.with.dots.needle.67percent", label: L10n.tr("加速", "Speed", "Ускорение"), value: L10n.tr("\(perf) 项", "\(perf) items", "\(perf) \(L10n.russianPlural(perf, one: "объект", few: "объекта", many: "объектов"))"))
                }
            }

            // Fill the remaining height so the list is tall enough to review
            // comfortably (issue #85), instead of a short fixed box.
            FileListView(results: cleanResults, selectedItems: $selectedItems, showsBulkSelection: true)
                .frame(maxHeight: .infinity)
                .background {
                    if removeBackgroundColors { Color.clear }
                    else { Rectangle().fill(.ultraThinMaterial) }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 20)

            CleanupActionBar(
                selectedCount: selectedItems.count,
                totalCount: totalCleanItems,
                selectedSize: selectedCleanSize,
                gradient: ModuleTheme.smartScan.buttonGradient,
                action: { showCleanConfirm = true }
            )
                .alert(L10n.tr("清理 \(selectedItems.count) 项？", "Clean \(selectedItems.count) item\(selectedItems.count == 1 ? "" : "s")?", "Очистить \(selectedItems.count) \(L10n.russianPlural(selectedItems.count, one: "объект", few: "объекта", many: "объектов"))?"), isPresented: $showCleanConfirm) {
                    Button(L10n.tr("取消", "Cancel", "Отмена"), role: .cancel) { }
                    Button(L10n.tr("清理", "Clean", "Очистить"), role: .destructive) { runCleanup() }
                } message: {
                    Text(cleanupConfirmationMessage(for: CleanupSelectionPolicy.selectedCategories(
                        in: cleanResults, selection: selectedItems)))
                }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 20)
    }

    /// Total number of cleanable items found (across all categories).
    private var totalCleanItems: Int {
        cleanSizeIndex.count
    }

    /// Include the scan generation so a same-count rescan refreshes sizes.
    private var cleanResultsSignature: String {
        fileListResultsSignature(sort: .default, results: cleanResults)
    }

    /// Rebuild the url -> size lookup so recomputing the selected total is
    /// O(selected) instead of O(all items) with a FileItem copy each pass.
    private func rebuildCleanSizeIndex() {
        var map = [URL: UInt64](minimumCapacity: cleanResults.reduce(0) { $0 + $1.items.count })
        for result in cleanResults {
            for item in result.items { map[item.url] = item.size }
        }
        cleanSizeIndex = map
    }

    /// Observe the URLs themselves: selecting only safe items may replace a
    /// selection with different URLs but the same item count.
    private func recomputeSelectedCleanSize() {
        selectedCleanSize = CleanupSelectionPolicy.selectedSize(selectedItems, sizesByURL: cleanSizeIndex)
    }

    // MARK: - Empty / Done / Cleaning

    private var emptyView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 52))
                .foregroundStyle(.primary.opacity(0.9))
            Text(L10n.tr("你的 Mac 很干净！", "Your Mac is clean!", "Ваш Mac чист!"))
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.primary)
            Text(L10n.tr("未发现垃圾、威胁或性能问题", "No junk, threats, or performance issues found", "Мусор, угрозы и проблемы с производительностью не обнаружены"))
                .font(.system(size: 14))
                .foregroundStyle(.primary.opacity(0.6))
            Button(L10n.tr("完成", "Done", "Готово")) { resetScan() }
                .buttonStyle(.bordered)
                .tint(.primary)
                .controlSize(.large)
            Spacer()
        }
    }

    private func cleaningView(progress: Double) -> some View {
        VStack(spacing: 20) {
            Spacer()
            ScanProgressRing(progress: progress, phase: L10n.tr("正在清理你的 Mac...", "Cleaning your Mac...", "Очистка Mac..."), theme: .smartScan)
            // Cancel mid-clean — consistent with the per-module views: just
            // cancel the task and let it land on .done with whatever was
            // already freed (the CleaningEngine checks Task.isCancelled at
            // each chunk boundary). We do NOT reset to .idle here, because
            // the in-flight task would race that back to .done.
            Button(L10n.tr("取消", "Cancel", "Отмена")) { cleanTask?.cancel() }
                .buttonStyle(.bordered)
                .tint(.primary)
                .controlSize(.large)
            Text(L10n.tr("取消后会先完成当前一组。", "Cancelling finishes the current group first.", "При отмене текущая группа сначала завершится."))
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    /// Scrolls when taller than the window (support card on a small window)
    /// instead of overflowing the pane.
    private func doneView(summary: CleanSummary, breakdown: [SmartScanCleanup.RecentlyCleanedRow]) -> some View {
        FitOrScroll { doneContent(summary: summary, breakdown: breakdown) }
    }

    private func doneContent(summary: CleanSummary, breakdown: [SmartScanCleanup.RecentlyCleanedRow]) -> some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: summary.wasCancelled ? "pause.circle.fill" : (summary.errorCount > 0 ? "exclamationmark.triangle.fill" : "checkmark.circle.fill"))
                .font(.system(size: 52))
                .foregroundStyle(summary.errorCount > 0 || summary.wasCancelled ? Color.orange : Color.primary)
            Text(summary.wasCancelled
                 ? L10n.tr("清理已停止", "Cleanup stopped", "Очистка остановлена")
                 : (summary.errorCount > 0
                    ? L10n.tr("部分项目未能清理", "Some items could not be cleaned", "Часть объектов не удалось очистить")
                    : L10n.tr("清理完成", "Cleanup finished", "Очистка завершена")))
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.primary)
            SizeDisplay(size: summary.freedBytes, label: L10n.tr("已处理", "processed", "обработано"))
                .foregroundStyle(.primary)

            if !breakdown.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.tr("最近清理", "Recently cleaned", "Недавно очищено"))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.primary.opacity(0.55))
                        .textCase(.uppercase)
                    ForEach(breakdown, id: \.moduleID) { row in
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(.green)
                            Text(row.moduleName)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                            Spacer(minLength: 8)
                            Text(recentlyCleanedDetail(row))
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundStyle(.primary.opacity(0.7))
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }
                .padding(16)
                .frame(maxWidth: 420)
                .background(.primary.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            if summary.errorCount > 0 {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(summary.topErrorGroups, id: \.message) { group in
                        Text("\(group.count)× \(group.message)")
                            .font(.callout)
                            .textSelection(.enabled)
                    }
                    Button(L10n.tr("查看日志", "View Log", "Журнал")) { showActivityLog = true }
                        .buttonStyle(.bordered)
                }
                .frame(maxWidth: 420, alignment: .leading)
            }
            Text(L10n.tr(
                "以上仅显示已完成的操作。移到废纸篓的项目可从清理历史恢复。请重新扫描以查看剩余或重新生成的文件。",
                "Only completed operations are shown above. Items moved to Trash can be restored from cleanup history. Scan again to review remaining or regenerated files.",
                "Выше показаны только выполненные операции. Объекты в Корзине можно восстановить из истории очистки. Повторите сканирование, чтобы проверить оставшиеся или заново созданные файлы."))
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 420)
            if askForSupport { SupportCard() }
            Button(L10n.tr("完成", "Done", "Готово")) { resetScan() }
                .buttonStyle(.bordered)
                .tint(.primary)
                .controlSize(.large)
            Spacer()
        }
        .padding(.horizontal, 40)
    }

    private func recentlyCleanedDetail(_ row: SmartScanCleanup.RecentlyCleanedRow) -> String {
        // The engine measures directories recursively at cleanup time, while
        // scan metadata may contain only the directory entry's size. Keep the
        // factual total above; don't present stale per-module scan estimates
        // as a breakdown of that total.
        return L10n.tr(
            "\(row.itemCount.formatted()) 项",
            "\(row.itemCount.formatted()) items",
            "\(row.itemCount.formatted()) \(L10n.russianPlural(row.itemCount, one: "объект", few: "объекта", many: "объектов"))"
        )
    }

    private func resetScan() {
        cleanTask?.cancel()
        cleanTask = nil
        scanWatchTask?.cancel()
        scanWatchTask = nil
        selectedItems = []
        cleanResults = []
        askForSupport = false
        completedModules = []
        currentModuleName = ""
        scanState = .idle
    }

    /// Abort an in-flight Smart Scan and return to the idle screen (#3).
    private func cancelScan() {
        appState.scanCoordinator.cancel()
        scanWatchTask?.cancel()
        scanWatchTask = nil
        completedModules = []
        currentModuleName = ""
        scanState = .idle
    }

    // MARK: - Components

    private func resultPill(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 22))
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .opacity(0.7)
            Text(value)
                .font(.system(size: 13, weight: .semibold))
        }
        .foregroundStyle(.primary)
        .frame(width: 110, height: 90)
        .background(.primary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Actions

    private func startScan() {
        completedModules = []
        currentModuleName = ""
        scanWatchTask?.cancel()

        scanWatchTask = Task {
            scanState = .scanning(phase: L10n.tr("正在分析系统...", "Analyzing system...", "Анализ системы..."), progress: 0, filesFound: 0, sizeFound: 0)
            appState.scanCoordinator.scanAll()

            var previousModule = ""
            var previousFiles = 0
            var previousSize: UInt64 = 0

            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(80))
                if Task.isCancelled { return }

                switch appState.scanCoordinator.state {
                case .scanning(let progress, let module, let files, let size):
                    // Detect module transitions
                    if module != previousModule && !previousModule.isEmpty {
                        let filesInModule = files - previousFiles
                        let sizeInModule = size - previousSize

                        let icon = Self.moduleOrder.first { $0.name == previousModule }?.icon ?? "circle"
                        completedModules.append(CompletedModule(
                            name: previousModule,
                            icon: icon,
                            fileCount: filesInModule,
                            size: sizeInModule
                        ))

                        previousFiles = files
                        previousSize = size
                    }
                    previousModule = module
                    currentModuleName = module
                    scanState = .scanning(phase: module, progress: progress, filesFound: files, sizeFound: size)

                case .completed(let results):
                    // Mark last module as completed
                    if !previousModule.isEmpty {
                        let totalFiles = results.reduce(0) { $0 + $1.totalFileCount }
                        let totalSize = results.reduce(0 as UInt64) { $0 + $1.totalSize }
                        let filesInModule = totalFiles - previousFiles
                        let sizeInModule = totalSize - previousSize
                        let icon = Self.moduleOrder.first { $0.name == previousModule }?.icon ?? "circle"
                        completedModules.append(CompletedModule(
                            name: previousModule,
                            icon: icon,
                            fileCount: filesInModule,
                            size: sizeInModule
                        ))
                    }

                    let totalSize = results.reduce(0 as UInt64) { $0 + $1.totalSize }
                    if totalSize == 0 && results.allSatisfy({ $0.totalFileCount == 0 }) {
                        scanState = .empty
                    } else {
                        cleanResults = SmartScanCleanup.allResults(from: results)
                        selectedItems = SmartScanCleanup.defaultSelection(from: results)
                        scanState = .results(
                            cleanup: totalSize,
                            protection: 0,
                            performance: 0,
                            totalSize: totalSize,
                            moduleResults: results
                        )
                    }
                    return

                case .failed:
                    scanState = .idle
                    return

                case .idle:
                    // Coordinator starts idle briefly, then moves to .scanning.
                    // After Cancel it stays idle — exit so we don't spin forever.
                    continue
                }
            }
        }
    }

    private func runCleanup() {
        // Snapshot the inputs up-front so the background task can't observe
        // later selection or scan-state mutations.
        let modules: [ModuleScanResult]
        if case .results(_, _, _, _, let moduleResults) = scanState {
            modules = moduleResults
        } else {
            modules = []
        }
        let results = cleanResults
        let selection = selectedItems
        scanState = .cleaning(progress: 0)
        cleanTask = Task {
            let result = await CleanActions.executeUserClean(
                results: results,
                selectedItems: selection,
                engine: appState.cleaningEngine,
                onProgress: { p in Task { @MainActor in
                    // Ignore late progress that lands after we've left the
                    // cleaning phase (cancel/done), so it can't resurrect
                    // a stale .cleaning state.
                    if case .cleaning = scanState {
                        scanState = .cleaning(progress: p.fraction)
                    }
                } }
            )
            let breakdown = SmartScanCleanup.recentlyCleanedBreakdown(
                from: modules,
                selectedItems: result.removedURLs
            )
            let summary = CleanSummary(
                selectedCount: selection.count,
                removedCount: result.removedCount,
                freedBytes: result.freedBytes,
                errorMessages: result.errors.map(\.error),
                wasCancelled: result.wasCancelled
            )
            askForSupport = !summary.wasCancelled && SupportAskLedger.shared.shouldAsk(for: summary)
            scanState = .done(summary: summary, breakdown: breakdown)
        }
    }
}
