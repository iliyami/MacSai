import AppKit
import MacCleanKit
import Observation
import Sparkle

/// Sparkle owns release notes, signature validation, download, replacement and
/// relaunch. This adapter owns Mac Sai preferences and its operation lifecycle.
@MainActor
@Observable
final class SelfUpdateController: NSObject, SPUUpdaterDelegate {
    static let shared = SelfUpdateController()

    let isConfigured: Bool
    let isHomebrew: Bool
    private(set) var canCheckForUpdates = false
    var isPreparingInstallation: Bool { installation.isPreparingInstallation }
    private(set) var automaticChecks = true
    private(set) var automaticDownloads = false
    private(set) var lastCheckDate: Date?
    private(set) var lastError: String?
    var canRetryInstallation: Bool { installation.canRetryInstallation }

    var installedVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? MCConstants.appVersion
    }

    var usesInAppUpdates: Bool { isConfigured && !isHomebrew }

    @ObservationIgnored private let configuration: SelfUpdateConfiguration?
    @ObservationIgnored private var updater: SPUUpdater?
    @ObservationIgnored private var observations: [NSKeyValueObservation] = []
    @ObservationIgnored private var started = false
    @ObservationIgnored private var installationState = SelfUpdateInstallationState()
    @ObservationIgnored private let alerts = SelfUpdateAlerts()
    @ObservationIgnored private lazy var installation = SelfUpdateInstallationCoordinator(
        activity: .shared,
        stopHelper: { await MenuBarLauncher.shared.prepareForApplicationUpdate() },
        resumeHelper: { MenuBarLauncher.shared.resumeAfterCancelledApplicationUpdate() },
        dismissPrompt: { [weak self] in self?.alerts.dismiss() },
        helperUnavailable: { [weak self] quitting in
            guard let self else { return }
            let message = L10n.tr(
                "请关闭菜单栏监视器后重试更新。", "Quit the menu bar monitor and try the update again.",
                "Завершите работу виджета в строке меню и повторите обновление.")
            self.lastError = message
            if quitting { self.alerts.showHelperFailure(message) }
        })

    private override init() {
        configuration = SelfUpdateConfiguration(infoDictionary: Bundle.main.infoDictionary ?? [:])
        isConfigured = configuration != nil
        isHomebrew = UpdateChecker.isHomebrewInstall()
        super.init()
    }

    func start() {
        guard !started, usesInAppUpdates else { return }
        started = true
        // Migrate the existing check preference once. Do not overwrite a
        // choice later made in Sparkle's own update window.
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "SUEnableAutomaticChecks") == nil,
           let existing = defaults.object(forKey: "automaticUpdateChecks") as? Bool {
            defaults.set(existing, forKey: "SUEnableAutomaticChecks")
        }
        let userDriver = SelfUpdateUserDriver(hostBundle: .main, delegate: nil)
        userDriver.updatePrepared = { [weak self] in self?.installationState.prepared() }
        let updater = SPUUpdater(hostBundle: .main, applicationBundle: .main,
                                 userDriver: userDriver, delegate: self)
        self.updater = updater
        observations = [
            updater.observe(\.canCheckForUpdates, options: [.initial, .new]) { @Sendable [weak self] _, _ in
                Task { @MainActor in self?.refreshState() }
            },
            updater.observe(\.automaticallyChecksForUpdates, options: [.new]) { @Sendable [weak self] _, _ in
                Task { @MainActor in self?.refreshState() }
            },
            updater.observe(\.automaticallyDownloadsUpdates, options: [.new]) { @Sendable [weak self] _, _ in
                Task { @MainActor in self?.refreshState() }
            },
        ]
        do {
            try updater.start()
        } catch {
            lastError = error.localizedDescription
        }
        updater.sendsSystemProfile = false
        refreshState()
    }

    func checkForUpdates() {
        start()
        guard canCheckForUpdates else { return }
        lastError = nil
        updater?.checkForUpdates()
    }

    func setAutomaticChecks(_ enabled: Bool) {
        updater?.automaticallyChecksForUpdates = enabled
        UserDefaults.standard.set(enabled, forKey: "automaticUpdateChecks")
        refreshState()
    }

    func setAutomaticDownloads(_ enabled: Bool) {
        updater?.automaticallyDownloadsUpdates = enabled
        refreshState()
    }

    private func refreshState() {
        guard let updater else { return }
        canCheckForUpdates = updater.canCheckForUpdates
        automaticChecks = updater.automaticallyChecksForUpdates
        automaticDownloads = updater.automaticallyDownloadsUpdates
        lastCheckDate = updater.lastUpdateCheckDate
    }

    // Pin to the feed sealed into this build, even if an earlier development
    // build left a SUFeedURL override in preferences.
    func feedURLString(for updater: SPUUpdater) -> String? {
        configuration?.feedURL.absoluteString
    }

    func allowedSystemProfileKeys(for updater: SPUUpdater) -> [String]? { [] }

    func updater(_ updater: SPUUpdater, mayPerform updateCheck: SPUUpdateCheck) throws {
        // Avoid a scheduled alert during file operations. Manual checks can
        // still show notes; the install gate below postpones replacement.
        if updateCheck != .updates, AppOperationActivity.shared.isBusy {
            throw NSError(domain: "com.macclean.update", code: 1, userInfo: [
                NSLocalizedDescriptionKey: L10n.tr(
                    "清理完成后将检查更新。", "Updates will be checked after cleanup finishes.",
                    "Проверка обновлений будет выполнена после завершения очистки.")
            ])
        }
    }

    func updater(_ updater: SPUUpdater, shouldPostponeRelaunchForUpdate item: SUAppcastItem,
                 untilInvokingBlock installHandler: @escaping () -> Void) -> Bool {
        installationState.prepared()
        lastError = nil
        installation.requestInstallation { installHandler() }
        return true
    }

    func retryInstallation() {
        lastError = nil
        installation.retryInstallation()
    }

    func updater(_ updater: SPUUpdater, willInstallUpdateOnQuit item: SUAppcastItem,
                 immediateInstallationBlock immediateInstallHandler: @escaping () -> Void) -> Bool {
        installationState.prepared()
        return false // Sparkle continues scheduling and owns installation on Quit.
    }

    /// Also covers automatic installation on normal Quit (no relaunch callback).
    func prepareForTermination(_ application: NSApplication) -> NSApplication.TerminateReply {
        switch installation.requestTermination(
            hasPreparedUpdate: installationState.hasPreparedUpdate,
            chooseWait: { [alerts] in await alerts.chooseWait() },
            reply: { ready in
                if ready { application.terminate(nil) }
            }
        ) {
        case .now: return .terminateNow
        case .cancel: return .terminateCancel
        // AppKit may terminate immediately on a second terminate() while a
        // NSTerminateLater request is pending, bypassing the delegate. Cancel
        // this request and issue a fresh Quit only after preparation succeeds.
        case .deferred: return .terminateCancel
        }
    }

    func updater(_ updater: SPUUpdater, userDidMake choice: SPUUserUpdateChoice,
                 forUpdate updateItem: SUAppcastItem, state: SPUUserUpdateState) {
        if choice == .skip {
            installationState.skipped()
            cancelInstallationPreparation()
        } else if state.stage == .installing {
            installationState.prepared()
        }
    }

    func updater(_ updater: SPUUpdater, didAbortWithError error: any Error) {
        lastError = error.localizedDescription
        let failure = error as NSError
        let installerErrors = Set([
            SUError.fileCopyFailure.rawValue, SUError.authenticationFailure.rawValue,
            SUError.missingUpdateError.rawValue, SUError.missingInstallerToolError.rawValue,
            SUError.relaunchError.rawValue, SUError.installationError.rawValue,
            SUError.downgradeError.rawValue, SUError.installationCanceledError.rawValue,
            SUError.notValidUpdateError.rawValue, SUError.agentInvalidationError.rawValue,
            SUError.installationWriteNoPermissionError.rawValue,
        ].map { Int($0) })
        let installationFailed = failure.domain == SUSparkleErrorDomain && installerErrors.contains(failure.code)
        installationState.aborted(installationFailed: installationFailed)
        // A later network/check error must not cancel a normal Quit that is
        // already waiting to install a previously prepared update.
        if installationFailed || !installationState.hasPreparedUpdate {
            cancelInstallationPreparation()
        }
        refreshState()
    }

    func updater(_ updater: SPUUpdater, didFinishUpdateCycleFor updateCheck: SPUUpdateCheck,
                 error: (any Error)?) {
        refreshState()
    }

    private func cancelInstallationPreparation() {
        installation.cancel()
    }
}
