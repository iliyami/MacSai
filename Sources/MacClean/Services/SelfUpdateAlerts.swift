import AppKit
import MacCleanKit

/// Nonblocking alerts also work after the main window has been closed. The
/// coordinator disables new operations while a Quit choice is outstanding.
@MainActor
final class SelfUpdateAlerts: NSObject, NSWindowDelegate {
    private var alert: NSAlert?
    private var completion: ((Bool) -> Void)?

    func chooseWait() async -> Bool {
        await withCheckedContinuation { continuation in
            present(
                title: L10n.tr("更新已准备就绪", "An update is ready to install", "Обновление готово к установке"),
                message: L10n.tr(
                    "Mac Sai 仍在完成当前操作。您可以等待操作完成后退出并安装更新，或留在应用中。",
                    "Mac Sai is still finishing an operation. You can wait, then quit and install the update, or stay in the app.",
                    "Mac Sai ещё выполняет операцию. Можно дождаться её завершения, выйти и установить обновление или остаться в приложении."),
                primary: L10n.tr("等待并退出", "Wait and Quit", "Дождаться и выйти"),
                secondary: L10n.tr("留在应用中", "Stay in App", "Остаться в приложении"),
                completion: { continuation.resume(returning: $0) })
        }
    }

    func showHelperFailure(_ message: String) {
        present(title: L10n.tr("暂时无法退出", "Unable to quit yet", "Пока не удалось выйти"),
                message: message, primary: L10n.tr("好", "OK", "ОК"), secondary: nil) { _ in }
    }

    private func present(title: String, message: String, primary: String,
                         secondary: String?, completion: @escaping (Bool) -> Void) {
        dismiss()
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = title
        alert.informativeText = message
        let first = alert.addButton(withTitle: primary)
        first.target = self
        first.action = #selector(accept)
        first.keyEquivalent = "\r"
        if let secondary {
            let second = alert.addButton(withTitle: secondary)
            second.target = self
            second.action = #selector(decline)
            second.keyEquivalent = "\u{1b}"
        }
        self.alert = alert
        self.completion = completion
        alert.layout()
        alert.window.delegate = self
        alert.window.level = .modalPanel
        alert.window.center()
        alert.window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func accept() { finish(true) }
    @objc private func decline() { finish(false) }
    func dismiss() { finish(false) }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        finish(false)
        return false
    }

    private func finish(_ accepted: Bool) {
        let callback = completion
        completion = nil
        let currentAlert = alert
        alert = nil
        currentAlert?.window.orderOut(nil)
        callback?(accepted)
    }
}
