import XCTest
@testable import MacCleanKit

final class BatchCleanupLocalizationTests: AppLanguageTestCase {
    func testPermissionsAndCleanupResultsDoNotFallBackToEnglishOrSimplifiedChinese() {
        let keys = [
            "清理权限",
            "允许 Mac Sai 扫描邮件、浏览器数据和其他受保护的文件夹。在系统设置中添加 Mac Sai 并开启权限，然后重新启动应用并重新扫描。",
            "打开完全磁盘访问设置",
            "管理员确认",
            "移动受保护的项目时，macOS 可能仍会要求密码或触控 ID。完全磁盘访问权限不能代替管理员确认。Mac Sai 不保存您的密码，也不能提前批准所有操作。",
            "批量移到废纸篓",
            "清理会将选中的项目分组交给 macOS，减少逐项请求。系统决定是否需要再次确认。取消后，当前组会先完成；已移动的项目仍会显示在清理历史中。",
            "权限",
            "另一项清理仍在进行中。",
            "准备清理时文件已更改，请重新扫描。",
            "无法确认项目在废纸篓中的位置，请检查访达。",
            "macOS 未将此项目移到废纸篓。请检查权限并重新扫描。",
            "符号链接改变了清理路径。请在访达中检查。",
            "符号链接已跳过。",
            "取消后会先完成当前一组。",
            "清理已停止",
            "已处理",
            "选中的文件夹与其内容计为一项。已经消失的文件会被跳过。",
            "部分项目未能清理",
            "以上仅显示已完成的操作。移到废纸篓的项目可从清理历史恢复。请重新扫描以查看剩余或重新生成的文件。",
            "完全磁盘访问权限",
            "完成",
            "清理完成",
            "查看日志",
        ]
        // These phrases are written identically in both Chinese scripts.
        let sameInTraditional: Set<String> = ["清理已停止", "完成", "清理完成"]
        for language in [AppLanguage.de, .fr, .it, .zhHant] {
            AppLanguage.current = language
            for key in keys {
                let value = L10n.tr(key, "MISSING_CLEANUP_TRANSLATION", "RU")
                XCTAssertNotEqual(value, "MISSING_CLEANUP_TRANSLATION", "\(language): \(key)")
                XCTAssertFalse(value.isEmpty, "\(language): \(key)")
                if language == .zhHant && !sameInTraditional.contains(key) {
                    XCTAssertNotEqual(value, key, "Missing Traditional Chinese: \(key)")
                }
            }
        }
    }
}
