import Foundation
import Observation
import OSLog
import ServiceManagement
import MacCleanKit

/// Opt-in manual fan control through the privileged helper (issue #242).
///
/// Off by default. Turning it on registers the helper LaunchDaemon, which the
/// user must approve in System Settings. The chosen mode is not persisted: the
/// menu app always starts in Automatic, so a relaunch never resumes a pinned
/// speed. While Manual, the target is resent every stats tick; that renews
/// the helper's watchdog, which restores automatic if the app stops sending.
@MainActor
@Observable
final class FanControlModel {
    enum Mode: String, CaseIterable { case automatic, manual }

    static let shared = FanControlModel()
    static let enabledKey = "fanControlEnabled"
    static let manualFractionKey = "fanManualFraction"

    private(set) var isEnabled: Bool
    private(set) var mode: Mode = .automatic
    private(set) var status: SMAppService.Status = .notRegistered
    /// True after a refused or failed write; fans are automatic again then.
    private(set) var didFail = false
    var manualFraction: Double {
        didSet { SharedAppState.defaults.set(manualFraction, forKey: Self.manualFractionKey) }
    }

    private let service = SMAppService.daemon(plistName: FanHelperConstants.daemonPlistName)
    private var connection: NSXPCConnection?
    private var fans: [FanSpeed] = []
    private static let log = Logger(subsystem: MCConstants.menuBundleIdentifier, category: "FanControl")

    private init() {
        let defaults = SharedAppState.defaults
        isEnabled = defaults.bool(forKey: Self.enabledKey)
        manualFraction = defaults.object(forKey: Self.manualFractionKey) as? Double ?? 0.5
        status = service.status
    }

    var isReady: Bool { isEnabled && status == .enabled }

    func setEnabled(_ enabled: Bool) {
        if enabled {
            do {
                try service.register()
            } catch {
                Self.log.error("helper register failed: \(error.localizedDescription, privacy: .public)")
            }
            status = service.status
            if status == .requiresApproval { SMAppService.openSystemSettingsLoginItems() }
            isEnabled = status == .enabled || status == .requiresApproval
        } else {
            selectAutomatic()
            isEnabled = false
            // Unregistering stops the daemon with SIGTERM, which also restores
            // automatic control on its side.
            Task { try? await service.unregister(); status = service.status }
        }
        SharedAppState.defaults.set(isEnabled, forKey: Self.enabledKey)
    }

    func openApproval() {
        SMAppService.openSystemSettingsLoginItems()
    }

    func selectManual() {
        mode = .manual
        didFail = false
        applyManual()
    }

    /// One-click hand-back to macOS.
    func selectAutomatic() {
        mode = .automatic
        guard connection != nil || isReady else { return }
        proxy()?.setAutomatic { _ in }
    }

    /// Called every stats tick with the latest fan readings.
    func update(fans: [FanSpeed]) {
        self.fans = fans
        status = service.status
        if mode == .manual { applyManual() }
    }

    /// Restores automatic before the menu app quits. Waits briefly for the
    /// reply; the helper also restores on disconnect if this does not land.
    func restoreBeforeQuit() {
        guard mode == .manual, let connection else { return }
        let done = DispatchSemaphore(value: 0)
        let helper = connection.synchronousRemoteObjectProxyWithErrorHandler { _ in done.signal() } as? FanHelperProtocol
        helper?.setAutomatic { _ in done.signal() }
        _ = done.wait(timeout: .now() + 1)
    }

    private func applyManual() {
        guard isReady, mode == .manual else { return }
        for fan in fans {
            guard let rpm = FanControlPolicy.rpm(atFraction: manualFraction, for: fan) else { continue }
            proxy()?.setTargetRPM(rpm, forFan: fan.index) { applied, error in
                guard applied < 0 else { return }
                Task { @MainActor in FanControlModel.shared.handleFailure(error) }
            }
        }
    }

    private func handleFailure(_ error: String?) {
        Self.log.error("fan control failed: \(error ?? "unknown", privacy: .public)")
        didFail = true
        // Only resend from Manual, so an unreachable helper cannot loop here.
        if mode == .manual { selectAutomatic() }
    }

    private func proxy() -> FanHelperProtocol? {
        if connection == nil {
            let connection = NSXPCConnection(machServiceName: FanHelperConstants.machServiceName, options: .privileged)
            connection.remoteObjectInterface = NSXPCInterface(with: FanHelperProtocol.self)
            // Refuse to talk to anything but our Developer ID signed helper.
            connection.setCodeSigningRequirement(
                MCConstants.codeSigningRequirement(for: FanHelperConstants.machServiceName)
            )
            connection.invalidationHandler = {
                Task { @MainActor in FanControlModel.shared.connection = nil }
            }
            connection.resume()
            self.connection = connection
        }
        return connection?.remoteObjectProxyWithErrorHandler { error in
            Task { @MainActor in FanControlModel.shared.handleFailure(error.localizedDescription) }
        } as? FanHelperProtocol
    }
}
