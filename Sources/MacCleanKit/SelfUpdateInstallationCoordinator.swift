import Foundation
import Observation

/// Shares one preparation between a manual install and normal Quit. AppKit
/// prompts and helper control are injected; no files or processes are touched
/// by this coordinator itself.
@MainActor
@Observable
public final class SelfUpdateInstallationCoordinator {
    public enum TerminationReply: Equatable { case now, cancel, deferred }

    public private(set) var isPreparingInstallation = false
    public private(set) var canRetryInstallation = false
    public private(set) var readyToTerminate = false

    @ObservationIgnored private let activity: AppOperationActivity
    @ObservationIgnored private let stopHelper: @MainActor () async -> Bool
    @ObservationIgnored private let resumeHelper: @MainActor () -> Void
    @ObservationIgnored private let dismissPrompt: @MainActor () -> Void
    @ObservationIgnored private let helperUnavailable: @MainActor (_ quitting: Bool) -> Void
    @ObservationIgnored private let preparation = SelfUpdatePreparation()
    @ObservationIgnored private var pendingInstallHandler: (@MainActor () -> Void)?

    public init(
        activity: AppOperationActivity,
        stopHelper: @escaping @MainActor () async -> Bool,
        resumeHelper: @escaping @MainActor () -> Void,
        dismissPrompt: @escaping @MainActor () -> Void = {},
        helperUnavailable: @escaping @MainActor (_ quitting: Bool) -> Void = { _ in }
    ) {
        self.activity = activity
        self.stopHelper = stopHelper
        self.resumeHelper = resumeHelper
        self.dismissPrompt = dismissPrompt
        self.helperUnavailable = helperUnavailable
    }

    public func requestInstallation(_ install: @escaping @MainActor () -> Void) {
        // Sparkle can request an immediate install while normal Quit already
        // owns the preparation. Keep its callback and share that preparation;
        // Stay preserves it for an explicit retry instead of installing.
        if pendingInstallHandler == nil { pendingInstallHandler = install }
        guard !preparation.isRunning else { return }
        retryInstallation()
    }

    public func retryInstallation() {
        guard !preparation.isRunning, pendingInstallHandler != nil else { return }
        startPreparation(quitting: false, chooseWait: { true }, completion: { _ in })
    }

    public func requestTermination(
        hasPreparedUpdate: Bool,
        chooseWait: @escaping @MainActor @Sendable () async -> Bool,
        reply: @escaping @MainActor (Bool) -> Void
    ) -> TerminationReply {
        guard hasPreparedUpdate, !readyToTerminate else { return .now }
        // A duplicate Command-Q must not replace either a manual installation
        // callback or the pending Quit completion.
        guard !preparation.isRunning else { return .cancel }
        startPreparation(quitting: true, chooseWait: chooseWait, completion: reply)
        return .deferred
    }

    private func startPreparation(
        quitting: Bool,
        chooseWait: @escaping @MainActor @Sendable () async -> Bool,
        completion: @escaping @MainActor (Bool) -> Void
    ) {
        isPreparingInstallation = true
        canRetryInstallation = false
        var helperFailed = false
        preparation.start(prepare: { [self] in
            guard await activity.prepareForUpdate(confirmWhileBusy: { await chooseWait() }),
                  !Task.isCancelled else { return false }
            let stopped = await stopHelper()
            guard !Task.isCancelled else { return false }
            helperFailed = !stopped
            return stopped
        }) { [self] result in
            switch result {
            case .cancelled:
                completion(false)
            case .unavailable:
                isPreparingInstallation = false
                canRetryInstallation = pendingInstallHandler != nil
                activity.cancelUpdate()
                resumeHelper()
                if helperFailed { helperUnavailable(quitting) }
                completion(false)
            case .ready:
                readyToTerminate = true
                let install = pendingInstallHandler
                pendingInstallHandler = nil
                install?()
                completion(readyToTerminate)
            }
        }
    }

    public func cancel() {
        // Invalidate callback ownership before dismissing a prompt or waking
        // the old helper wait; either can otherwise complete synchronously.
        preparation.cancel { [self] in
            isPreparingInstallation = false
            canRetryInstallation = false
            readyToTerminate = false
            pendingInstallHandler = nil
            activity.cancelUpdate()
            resumeHelper()
            dismissPrompt()
        }
    }
}
