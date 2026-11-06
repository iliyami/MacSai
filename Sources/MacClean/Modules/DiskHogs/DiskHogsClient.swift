import Foundation
import MacCleanKit

/// Runs the Docker and simctl probes and deletions behind the Disk Hogs
/// module. Every command goes through `BoundedProcess`, so a wedged Docker
/// daemon or simctl can't hang the screen, and leaving it stops the work.
public struct DiskHogsClient: Sendable {
    public enum DockerState: Equatable, Sendable {
        case notInstalled
        case notResponding
        case rows([DockerDiskRow])
    }

    /// Result of one prune or delete, for per-item reporting.
    public struct ItemResult: Equatable, Sendable {
        public let name: String
        public let outcome: BoundedProcess.Outcome
    }

    public init() {}

    private static let probeTimeout: Duration = .seconds(30)
    private static let pruneTimeout: Duration = .seconds(600)
    private static let deleteTimeout: Duration = .seconds(300)

    private static func dockerPath() -> String? {
        MaintenanceTask.resolveDockerPath(existing: { FileManager.default.isExecutableFile(atPath: $0) })
    }

    /// The real simctl inside the selected developer directory. Never the
    /// /usr/bin/xcrun shim: on a Mac without developer tools that shim pops
    /// the "install command line tools" dialog. `xcode-select -p` does not.
    private static func simctlPath() async -> String? {
        let outcome = await BoundedProcess.run("/usr/bin/xcode-select", ["-p"], timeout: .seconds(10))
        guard outcome.succeeded else { return nil }
        return SimulatorInventory.simctlPath(developerDirectory: outcome.stdoutText) {
            FileManager.default.isExecutableFile(atPath: $0)
        }
    }

    public func dockerState() async -> DockerState {
        guard let docker = Self.dockerPath() else { return .notInstalled }
        let outcome = await BoundedProcess.run(docker, DockerSystemDFParser.arguments, timeout: Self.probeTimeout)
        guard outcome.succeeded else { return .notResponding }
        return .rows(DockerSystemDFParser.parse(outcome.stdoutText))
    }

    /// Disk space Docker Desktop's virtual disk takes, nil when there is none.
    /// Read from the file, so it shows even while Docker is stopped. The
    /// image is sparse, so the allocated size is what it really costs.
    public func dockerDiskImageSize() -> UInt64? {
        let sizes = MCConstants.dockerDesktopDiskImages.compactMap { url -> UInt64? in
            guard let values = try? url.resourceValues(forKeys: [.totalFileAllocatedSizeKey, .fileAllocatedSizeKey])
            else { return nil }
            return UInt64(values.totalFileAllocatedSize ?? values.fileAllocatedSize ?? 0)
        }
        return sizes.isEmpty ? nil : sizes.reduce(0, +)
    }

    /// Unavailable devices and deletable older runtimes. Both empty when the
    /// Mac has no Xcode.
    public func simulators() async -> (devices: [SimulatorDevice], runtimes: [SimulatorRuntime]) {
        guard let simctl = await Self.simctlPath() else { return ([], []) }
        let devices = await BoundedProcess.run(simctl, ["list", "devices", "-j"], timeout: Self.probeTimeout)
        let runtimes = await BoundedProcess.run(simctl, ["runtime", "list", "-j"], timeout: Self.probeTimeout)
        return (
            devices.succeeded ? SimulatorInventory.parseDevices(devices.stdoutData) : [],
            runtimes.succeeded ? SimulatorInventory.parseRuntimes(runtimes.stdoutData) : []
        )
    }

    public func pruneDocker(selection: Set<DockerDiskCategory>) async -> [ItemResult] {
        let commands = DockerPrune.commands(for: selection)
        guard let docker = Self.dockerPath() else {
            return commands.map {
                ItemResult(name: $0.category.label, outcome: .launchFailed(
                    L10n.tr("未找到 Docker", "Docker not found", "Docker не найден")))
            }
        }
        var results: [ItemResult] = []
        for command in commands {
            if Task.isCancelled { break }
            let outcome = await BoundedProcess.run(docker, command.arguments, timeout: Self.pruneTimeout)
            results.append(ItemResult(name: command.category.label, outcome: outcome))
        }
        return results
    }

    public func deleteSimulators(devices: [SimulatorDevice], runtimes: [SimulatorRuntime]) async -> [ItemResult] {
        let jobs: [(name: String, arguments: [String]?)] =
            devices.map { ($0.name, SimulatorInventory.deleteArguments(deviceUDID: $0.udid)) }
            + runtimes.map { ($0.name, SimulatorInventory.deleteRuntimeArguments(identifier: $0.identifier)) }
        guard !jobs.isEmpty else { return [] }
        guard let simctl = await Self.simctlPath() else {
            return jobs.map { ItemResult(name: $0.name, outcome: .launchFailed("simctl")) }
        }
        var results: [ItemResult] = []
        for job in jobs {
            if Task.isCancelled { break }
            guard let arguments = job.arguments else {
                results.append(ItemResult(name: job.name, outcome: .launchFailed("invalid identifier")))
                continue
            }
            let outcome = await BoundedProcess.run(simctl, arguments, timeout: Self.deleteTimeout)
            results.append(ItemResult(name: job.name, outcome: outcome))
        }
        return results
    }
}
