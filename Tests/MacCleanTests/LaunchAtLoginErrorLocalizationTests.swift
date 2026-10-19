import XCTest
import MacCleanKit
@testable import MacClean

/// The launch-at-login error used to splice a translated verb into the
/// English sentence ("Couldn't aktivieren launch at login") because the full
/// sentence, built by interpolation, could never match a dictionary key.
final class LaunchAtLoginErrorLocalizationTests: EnglishAppLanguageTestCase {
    private func describe(enabling: Bool, in language: AppLanguage) -> String? {
        AppLanguage.current = language
        return LaunchAtLoginManager.LaunchAtLoginError
            .updateFailed(enabling: enabling, message: "MSG")
            .errorDescription
    }

    func testErrorIsFullyTranslatedInEveryLanguage() {
        let expected: [(AppLanguage, String, String)] = [
            (.en, "Couldn't turn on launch at login: MSG", "Couldn't turn off launch at login: MSG"),
            (.de, "„Beim Anmelden starten“ konnte nicht aktiviert werden: MSG",
             "„Beim Anmelden starten“ konnte nicht deaktiviert werden: MSG"),
            (.fr, "Impossible d'activer le lancement au démarrage : MSG",
             "Impossible de désactiver le lancement au démarrage : MSG"),
            (.it, "Impossibile attivare l'apertura al login: MSG", "Impossibile disattivare l'apertura al login: MSG"),
            (.ru, "Не удалось включить запуск при входе: MSG", "Не удалось отключить запуск при входе: MSG"),
            (.zhHans, "无法开启登录时启动：MSG", "无法关闭登录时启动：MSG"),
            (.zhHant, "無法開啟登入時啟動：MSG", "無法關閉登入時啟動：MSG"),
        ]
        for (language, on, off) in expected {
            XCTAssertEqual(describe(enabling: true, in: language), on, "\(language)")
            XCTAssertEqual(describe(enabling: false, in: language), off, "\(language)")
        }
    }
}
