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
    private(set) var isPreparingInstallation = false
    private(set) var automaticChecks = true
    private(set) var automaticDownloads = false
    private(set) var lastCheckDate: Date?
    private(set) var lastError: String?
    private(set) var canRetryInstallation = false

    var installedVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? MCConstants.appVersion
    }

    var usesInAppUpdates: Bool { isConfigured && !isHomebrew }

    @ObservationIgnored private let configuration: SelfUpdateConfiguration?
    @ObservationIgnored private var controller: SPUStandardUpdaterController?
    @ObservationIgnored private var observations: [NSKeyValueObservation] = []
    @ObservationIgnored private let preparation = SelfUpdatePreparation()
    @ObservationIgnored private var started = false
    @ObservationIgnored private var pendingInstallHandler: (() -> Void)?
    @ObservationIgnored private var installationState = SelfUpdateInstallationState()
    @ObservationIgnored private var readyToTerminate = false

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
        let controller = SPUStandardUpdaterController(
            startingUpdater: false, updaterDelegate: self, userDriverDelegate: nil)
        self.controller = controller
        let updater = controller.updater
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
        controller.startUpdater()
        updater.sendsSystemProfile = false
        refreshState()
    }

    func checkForUpdates() {
        start()
        guard canCheckForUpdates else { return }
        lastError = nil
        controller?.checkForUpdates(nil)
    }

    func setAutomaticChecks(_ enabled: Bool) {
        controller?.updater.automaticallyChecksForUpdates = enabled
        UserDefaults.standard.set(enabled, forKey: "automaticUpdateChecks")
        refreshState()
    }

    func setAutomaticDownloads(_ enabled: Bool) {
        controller?.updater.automaticallyDownloadsUpdates = enabled
        refreshState()
    }

    private func refreshState() {
        guard let updater = controller?.updater else { return }
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
        guard !preparation.isRunning else { return true }
        pendingInstallHandler = installHandler
        retryInstallation()
        return true
    }

    func retryInstallation() {
        guard !preparation.isRunning, let installHandler = pendingInstallHandler else { return }
        lastError = nil
        canRetryInstallation = false
        isPreparingInstallation = true
        preparation.start(prepare: { await self.prepareUpdatePrerequisites() }) { [self] result in
            switch result {
            case .cancelled:
                return
            case .unavailable:
                isPreparingInstallation = false
                canRetryInstallation = true
                AppOperationActivity.shared.cancelUpdate()
                MenuBarLauncher.shared.resumeAfterCancelledApplicationUpdate()
                lastError = L10n.tr(
                    "请关闭菜单栏监视器后重试更新。", "Quit the menu bar monitor and try the update again.",
                    "Завершите работу виджета в строке меню и повторите обновление.")
                return
            case .ready:
                readyToTerminate = true
                pendingInstallHandler = nil
                installHandler()
            }
        }
    }

    private func prepareUpdatePrerequisites() async -> Bool {
        guard await AppOperationActivity.shared.prepareForUpdate(), !Task.isCancelled else { return false }
        return await MenuBarLauncher.shared.prepareForApplicationUpdate()
    }

    func updater(_ updater: SPUUpdater, didExtractUpdate item: SUAppcastItem) {
        // Manual downloads can be deferred at the ready-to-install screen too;
        // their installer then waits for a normal Quit, just like auto updates.
        installationState.prepared()
    }

    func updater(_ updater: SPUUpdater, willInstallUpdateOnQuit item: SUAppcastItem,
                 immediateInstallationBlock immediateInstallHandler: @escaping () -> Void) -> Bool {
        installationState.prepared()
        return false // Sparkle continues scheduling and owns installation on Quit.
    }

    /// Also covers automatic installation on normal Quit (no relaunch callback).
    func prepareForTermination(_ application: NSApplication) -> NSApplication.TerminateReply {
        guard installationState.hasPreparedUpdate, !readyToTerminate else { return .terminateNow }
        // A manual retry may already own the helper wait and install handler.
        // Do not replace its task with a second preparation for Command-Q.
        guard !preparation.isRunning else { return .terminateCancel }
        isPreparingInstallation = true
        preparation.start(prepare: { await self.prepareUpdatePrerequisites() }) { [self] result in
            switch result {
            case .cancelled:
                application.reply(toApplicationShouldTerminate: false)
            case .unavailable:
                cancelInstallationPreparation()
                application.reply(toApplicationShouldTerminate: false)
            case .ready:
                readyToTerminate = true
                application.reply(toApplicationShouldTerminate: true)
            }
        }
        return .terminateLater
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
        installationState.aborted(installationFailed:
            failure.domain == SUSparkleErrorDomain && installerErrors.contains(failure.code))
        cancelInstallationPreparation()
        refreshState()
    }

    func updater(_ updater: SPUUpdater, didFinishUpdateCycleFor updateCheck: SPUUpdateCheck,
                 error: (any Error)?) {
        refreshState()
    }

    private func cancelInstallationPreparation() {
        preparation.cancel()
        isPreparingInstallation = false
        canRetryInstallation = false
        readyToTerminate = false
        pendingInstallHandler = nil
        AppOperationActivity.shared.cancelUpdate()
        MenuBarLauncher.shared.resumeAfterCancelledApplicationUpdate()
    }
}
