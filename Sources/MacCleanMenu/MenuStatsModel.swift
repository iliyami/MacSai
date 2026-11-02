import SwiftUI
import AppKit
import OSLog
import MacCleanKit

/// Owns the menu-bar widget's live data and polls for it **continuously from
/// app launch**, independent of the popover.
///
/// The previous design started polling from the popover content's `.onAppear`
/// and stopped it on `.onDisappear`. For `MenuBarExtra(.window)` that hook only
/// fires when the popover is opened, and on some setups (e.g. Intel / macOS
/// 14.x) it doesn't fire reliably even then — so collection never started and
/// the panel was stuck on its loading spinner forever. Driving the loop from
/// `applicationDidFinishLaunching` instead removes that dependency entirely:
/// stats are gathered the moment the app launches, the popover shows data the
/// instant it opens, and the menu-bar label is populated from the start.
@MainActor
@Observable
final class MenuStatsModel {
    static let shared = MenuStatsModel()

    private(set) var stats: SystemStatsCollector.SystemStats?
    private(set) var networkSpeed: NetworkSpeedMonitor.NetworkSpeed?
    private(set) var devices: ConnectedDevices?
    private(set) var protection: SharedAppState.ProtectionStatus?
    private(set) var tips: [TipsEngine.Tip] = []

    private let statsCollector = SystemStatsCollector()
    private let networkMonitor = NetworkSpeedMonitor()
    private let devicesCollector = ConnectedDevicesCollector()
    private let tipsEngine = TipsEngine()
    private let healthMonitor = HealthMonitor()

    private var pollingTask: Task<Void, Never>?
    private var tickCount = 0

    private static let log = Logger(subsystem: MCConstants.menuBundleIdentifier, category: "SystemStats")

    private init() {}

    /// Begin the continuous polling loop. Idempotent: safe to call more than
    /// once (e.g. if relaunch lifecycle fires twice).
    func start() {
        guard pollingTask == nil else { return }
        Self.log.info("stats polling started")
        pollingTask = Task { await self.run() }
    }

    func dismissTip(id: String) {
        SharedAppState.dismissTip(id: id)
        tips.removeAll { $0.id == id }
    }

    private func run() async {
        while !Task.isCancelled {
            // Assign each metric the moment it's ready, each fenced with a
            // timeout so one wedged syscall can't blank the panel: the loop
            // keeps going and the last-known value stays on screen.
            if let s = await timed("stats", budget: .seconds(2), { await self.statsCollector.collect() }) {
                stats = s
                FanControlModel.shared.update(fans: s.fans)
                await healthMonitor.evaluate(stats: s)
            }
            if let n = await timed("network", budget: .seconds(2), { await self.networkMonitor.measure() }) {
                networkSpeed = n
            }
            protection = SharedAppState.protectionStatus
            tickCount += 1
            if tickCount % 10 == 1 {
                if let d = await timed("devices", budget: .seconds(3), { await self.devicesCollector.collect() }) {
                    devices = d
                }
                if let t = await timed("tips", budget: .seconds(3), { await self.tipsEngine.generateTips() }) {
                    tips = t
                }
            }
            try? await Task.sleep(for: .seconds(3))
        }
    }

    /// Run one collector step under a timeout, returning nil if it overruns its
    /// budget so the loop keeps going. Slow / timed-out steps are logged so a
    /// hang can be pinned to a specific collector from a user's Console.
    private func timed<T: Sendable>(
        _ label: String,
        budget: Duration,
        _ op: @escaping @Sendable () async -> T
    ) async -> T? {
        let start = ContinuousClock.now
        do {
            let value = try await withTimeout(budget) { await op() }
            let elapsed = ContinuousClock.now - start
            if elapsed > .milliseconds(500) {
                Self.log.warning("stats step '\(label, privacy: .public)' slow: \(elapsed.description, privacy: .public)")
            }
            return value
        } catch {
            Self.log.error("stats step '\(label, privacy: .public)' exceeded its budget; skipping this tick")
            return nil
        }
    }
}

/// Starts continuous stats polling at launch via the AppKit lifecycle, which
/// (unlike the SwiftUI `MenuBarExtra` view hooks) fires reliably regardless of
/// whether the popover is ever opened. `@preconcurrency` keeps the conformance
/// building on CI's older SDK, where the delegate protocol isn't yet annotated
/// `@MainActor`.
@MainActor
final class MenuAppDelegate: NSObject, @preconcurrency NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        MenuStatsModel.shared.start()
    }

    func applicationWillTerminate(_ notification: Notification) {
        FanControlModel.shared.restoreBeforeQuit()
    }
}
