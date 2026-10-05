import SwiftUI
import MacCleanKit

struct EmptyFoldersView: View {
    @Environment(AppState.self) private var appState
    @State private var results: [ScanResult] = []
    @State private var selectedItems: Set<URL> = []
    @State private var isScanning = false
    @State private var scanProgress: Double = 0
    @State private var scanPhase = ""
    @State private var scanComplete = false
    @State private var completion: CleanSummary?
    @State private var cleaning: CleaningEngine.Progress?
    @State private var cleanTask: Task<Void, Never>?

    var body: some View {
        ModuleContainerView(
            title: L10n.tr("空文件夹", "Empty Folders", "Пустые папки"),
            subtitle: L10n.tr("查找并清理没有任何内容的文件夹", "Find and remove folders that contain nothing", "Поиск и удаление пустых папок"),
            theme: .files,
            emptyMessage: L10n.tr("未找到空文件夹", "No empty folders found", "Пустые папки не найдены"),
            results: results,
            selectedItems: $selectedItems,
            isScanning: isScanning,
            scanProgress: scanProgress,
            scanPhase: scanPhase,
            scanComplete: scanComplete,
            completion: completion,
            cleaning: cleaning,
            onScan: scan,
            onClean: clean,
            onCancelClean: { cleanTask?.cancel() },
            onReset: reset
        )
        .onAppear {
            if let e = appState.scanResultsStore.entry(for: .emptyFolders) {
                results = e.results
                selectedItems = e.selection
                scanComplete = e.scanComplete
            }
        }
        .onDisappear {
            appState.scanResultsStore.save(
                results: results,
                selection: selectedItems,
                scanComplete: scanComplete,
                for: .emptyFolders
            )
        }
    }

    private func scan() {
        isScanning = true
        scanComplete = false
        scanProgress = 0
        results = []
        selectedItems = []
        Task {
            let scanStart = Date()

            scanPhase = L10n.tr("正在扫描个人目录...", "Scanning home directory...", "Сканирование домашней папки...")
            scanProgress = 0.2
            try? await Task.sleep(for: .milliseconds(500))

            scanPhase = L10n.tr("正在查找空文件夹...", "Finding empty folders...", "Поиск пустых папок...")
            scanProgress = 0.45

            let module = EmptyFoldersModule()
            async let scanTask = module.scan()

            results = await scanTask

            scanPhase = L10n.tr("正在整理结果...", "Grouping results...", "Группировка результатов...")
            scanProgress = 0.9

            let elapsed = Date().timeIntervalSince(scanStart)
            if elapsed < 2.0 {
                try? await Task.sleep(for: .milliseconds(Int((2.0 - elapsed) * 1000)))
            }
            scanProgress = 1.0

            isScanning = false
            scanComplete = true
        }
    }

    private func clean() {
        let preCleanSelectedCount = selectedItems.count
        cleaning = CleaningEngine.Progress(
            totalItems: preCleanSelectedCount,
            processedItems: 0, removedSoFar: 0, freedBytesSoFar: 0
        )
        cleanTask = Task {
            let result = await CleanActions.executeUserClean(
                results: results,
                selectedItems: selectedItems,
                engine: appState.cleaningEngine,
                onProgress: { progress in
                    Task { @MainActor in cleaning = progress }
                }
            )
            cleaning = nil
            completion = CleanSummary(
                selectedCount: preCleanSelectedCount,
                removedCount: result.removedCount,
                freedBytes: result.freedBytes,
                errorMessages: result.errors.map(\.error)
            )
        }
    }

    private func reset() {
        results = []; selectedItems = []; completion = nil; cleaning = nil; cleanTask = nil; scanComplete = false
    }
}
