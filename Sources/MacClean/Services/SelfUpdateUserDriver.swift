import Sparkle

/// Preserve Sparkle's standard UI while observing the point at which its
/// installer has actually validated and prepared the replacement. In Sparkle
/// 2.10.1 didExtractUpdate fires earlier, when the installer is only launched.
@MainActor
final class SelfUpdateUserDriver: SPUStandardUserDriver {
    var updatePrepared: (() -> Void)?

    override func showReadyToInstallAndRelaunch() async -> SPUUserUpdateChoice {
        updatePrepared?()
        return await super.showReadyToInstallAndRelaunch()
    }

    override func showUpdateFound(with appcastItem: SUAppcastItem, state: SPUUserUpdateState,
                                  reply: @escaping (SPUUserUpdateChoice) -> Void) {
        if state.stage == .installing { updatePrepared?() }
        super.showUpdateFound(with: appcastItem, state: state, reply: reply)
    }
}
