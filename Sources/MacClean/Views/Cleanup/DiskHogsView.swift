import SwiftUI
import MacCleanKit

struct DiskHogsView: View {
    @AppStorage("removeBackgroundColors") private var removeBackgroundColors = false
    @State private var dockerState: DiskHogsClient.DockerState = .notInstalled
    @State private var dockerDiskImageSize: UInt64?
    @State private var selectedDocker: Set<DockerDiskCategory> = DockerPrune.defaultSelection
    @State private var devices: [SimulatorDevice] = []
    @State private var runtimes: [SimulatorRuntime] = []
    @State private var selectedSim: Set<String> = SimulatorInventory.defaultSelection
    @State private var isLoading = true
    @State private var isWorking = false
    @State private var statusLines: [String] = []
    @State private var confirmingPrune = false
    @State private var confirmingDelete = false
    @State private var workTask: Task<Void, Never>?
    private let client = DiskHogsClient()

    private var dockerRows: [DockerDiskRow] {
        if case .rows(let rows) = dockerState { return rows }
        return []
    }

    private var selectedDevices: [SimulatorDevice] { devices.filter { selectedSim.contains($0.udid) } }
    private var selectedRuntimes: [SimulatorRuntime] { runtimes.filter { selectedSim.contains($0.identifier) } }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(DiskHogsText.title)
                        .font(.system(size: 22, weight: .bold))
                    Text(DiskHogsText.subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(.primary.opacity(0.6))
                }
                Spacer()
                Button {
                    startWork { await reload() }
                } label: {
                    Label(DiskHogsText.refresh, systemImage: "arrow.clockwise")
                }
                .disabled(isLoading || isWorking)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)

            Group {
                if isLoading {
                    VStack {
                        Spacer()
                        ProgressView().controlSize(.large)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        dockerSection
                        simulatorSection

                        if dockerState == .notInstalled && dockerDiskImageSize == nil && devices.isEmpty && runtimes.isEmpty {
                            Text(DiskHogsText.nothingFound)
                                .foregroundStyle(.secondary)
                        }

                        if !statusLines.isEmpty {
                            VStack(alignment: .leading, spacing: 2) {
                                ForEach(Array(statusLines.enumerated()), id: \.offset) { _, line in
                                    Text(line)
                                }
                            }
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                        }
                    }
                    .listStyle(.inset)
                }
            }
            .background {
                if removeBackgroundColors { Color.clear }
                else { Rectangle().fill(.ultraThinMaterial) }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .task { await reload() }
        .onDisappear {
            workTask?.cancel()
            workTask = nil
        }
        .respondsToModuleShortcuts(onScan: { startWork { await reload() } }, canScan: !isLoading && !isWorking)
        .confirmationDialog(DiskHogsText.pruneConfirmTitle, isPresented: $confirmingPrune, titleVisibility: .visible) {
            Button(DiskHogsText.pruneConfirmButton, role: .destructive) {
                let selection = selectedDocker
                startWork { await pruneDocker(selection) }
            }
            Button(DiskHogsText.cancel, role: .cancel) {}
        } message: {
            Text(pruneConfirmMessage)
        }
        .confirmationDialog(DiskHogsText.deleteConfirmTitle, isPresented: $confirmingDelete, titleVisibility: .visible) {
            Button(DiskHogsText.deleteConfirmButton, role: .destructive) {
                let devices = selectedDevices
                let runtimes = selectedRuntimes
                startWork { await deleteSims(devices: devices, runtimes: runtimes) }
            }
            Button(DiskHogsText.cancel, role: .cancel) {}
        } message: {
            Text(deleteConfirmMessage)
        }
    }

    // MARK: - Sections

    @ViewBuilder private var dockerSection: some View {
        if dockerState != .notInstalled || dockerDiskImageSize != nil {
            Section {
                // The disk image itself: information only, never selectable.
                if let bytes = dockerDiskImageSize {
                    lockedRow(infoLabel(
                        title: DiskHogsText.dockerDiskImage + "  ·  " + DiskHogsText.size + " "
                            + ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: .file),
                        note: DiskHogsText.dockerDiskImageNote
                    ))
                }
                switch dockerState {
                case .notInstalled:
                    EmptyView()
                case .notResponding:
                    Text(DiskHogsText.dockerNotResponding)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                case .rows(let rows):
                    ForEach(rows) { row in
                        if row.category.isPrunable {
                            Toggle(isOn: Binding(
                                get: { selectedDocker.contains(row.category) },
                                set: { on in
                                    if on { selectedDocker.insert(row.category) }
                                    else { selectedDocker.remove(row.category) }
                                }
                            )) {
                                dockerRowLabel(row)
                            }
                        } else {
                            // Volumes: information only, never selectable.
                            lockedRow(dockerRowLabel(row))
                        }
                    }
                    Button(DiskHogsText.pruneButton) { confirmingPrune = true }
                        .disabled(selectedDocker.isEmpty || isWorking)
                }
            } header: {
                Text(verbatim: "Docker")
            }
        }
    }

    private func dockerRowLabel(_ row: DockerDiskRow) -> some View {
        infoLabel(title: row.category.label + "  ·  " + DiskHogsText.size + " " + row.size,
                  note: row.category.pruneNote)
    }

    private func infoLabel(title: String, note: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
            Text(note)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func lockedRow(_ label: some View) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "lock.fill")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .padding(.top, 2)
            label
        }
    }

    @ViewBuilder private var simulatorSection: some View {
        if !devices.isEmpty || !runtimes.isEmpty {
            Section(DiskHogsText.xcodeSection) {
                ForEach(devices) { device in
                    simToggle(id: device.udid, title: device.name,
                              detail: DiskHogsText.unavailableSimulator + "  ·  " + device.runtimeDisplayName)
                }
                ForEach(runtimes) { runtime in
                    simToggle(id: runtime.identifier, title: runtime.name,
                              detail: runtimeDetail(runtime))
                }
                Button(DiskHogsText.deleteButton) { confirmingDelete = true }
                    .disabled(selectedSim.isEmpty || isWorking)
            }
        }
    }

    private func simToggle(id: String, title: String, detail: String) -> some View {
        Toggle(isOn: Binding(
            get: { selectedSim.contains(id) },
            set: { on in
                if on { selectedSim.insert(id) }
                else { selectedSim.remove(id) }
            }
        )) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                Text(detail)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func runtimeDetail(_ runtime: SimulatorRuntime) -> String {
        guard let bytes = runtime.sizeBytes, bytes > 0 else { return DiskHogsText.olderRuntime }
        return DiskHogsText.olderRuntime + "  ·  " + ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }

    // MARK: - Confirmation copy

    private var pruneConfirmMessage: String {
        let lines = DockerPrune.commands(for: selectedDocker).map { "• \($0.category.label): \($0.category.pruneNote)" }
        return (lines + ["", DiskHogsText.permanentNote]).joined(separator: "\n")
    }

    private var deleteConfirmMessage: String {
        var lines = selectedDevices.map { "• \($0.name) (\(DiskHogsText.unavailableSimulator))" }
        lines += selectedRuntimes.map { "• \($0.name) (\(runtimeDetail($0)))" }
        if !selectedRuntimes.isEmpty { lines += ["", DiskHogsText.runtimeShutdownNote] }
        return (lines + ["", DiskHogsText.permanentNote]).joined(separator: "\n")
    }

    // MARK: - Work

    /// One piece of work at a time, cancelled if the user leaves the screen.
    private func startWork(_ work: @escaping @MainActor () async -> Void) {
        workTask?.cancel()
        workTask = Task { await work() }
    }

    private func reload() async {
        isLoading = true
        async let docker = client.dockerState()
        async let sims = client.simulators()
        let (state, simulators) = await (docker, sims)
        if Task.isCancelled { return }
        dockerState = state
        dockerDiskImageSize = client.dockerDiskImageSize()
        devices = simulators.devices
        runtimes = simulators.runtimes
        selectedDocker = DockerPrune.defaultSelection
        selectedSim = SimulatorInventory.defaultSelection
        isLoading = false
    }

    private func pruneDocker(_ selection: Set<DockerDiskCategory>) async {
        isWorking = true
        defer { isWorking = false }
        let results = await client.pruneDocker(selection: selection)
        statusLines = results.map { DiskHogsText.statusLine(name: $0.name, outcome: $0.outcome, success: DiskHogsText.pruned) }
        selectedDocker = []
        if Task.isCancelled { return }
        dockerState = await client.dockerState()
        dockerDiskImageSize = client.dockerDiskImageSize()
    }

    private func deleteSims(devices: [SimulatorDevice], runtimes: [SimulatorRuntime]) async {
        isWorking = true
        defer { isWorking = false }
        let results = await client.deleteSimulators(devices: devices, runtimes: runtimes)
        statusLines = results.map { DiskHogsText.statusLine(name: $0.name, outcome: $0.outcome, success: DiskHogsText.deleted) }
        selectedSim = []
        if Task.isCancelled { return }
        let refreshed = await client.simulators()
        self.devices = refreshed.devices
        self.runtimes = refreshed.runtimes
    }
}
