import Foundation

/// Members who back Mac Sai and asked to be listed, shown under Settings >
/// About. Compiled into each release, so showing them never touches the
/// network. Names only, with no links or logos, so the app stays free of
/// ads. Keep in step with SUPPORTERS.md; a test checks every name here is
/// there too.
public enum Supporters {
    public static let names: [String] = []
}

/// Copy for the Supporters row and the support link in Settings > About.
public enum SupporterStrings {
    public static var title: String {
        L10n.tr("支持者", "Supporters", "Поддержавшие проект")
    }

    /// Every listed name, or an invitation while nobody is listed.
    public static func caption(for names: [String]) -> String {
        guard !names.isEmpty else { return emptyCaption }
        return L10n.tr(
            "感谢你们让 Mac Sai 保持免费：{names}。",
            "Thank you for keeping Mac Sai free: {names}.",
            "Спасибо всем, кто помогает Mac Sai оставаться бесплатным: {names}."
        )
        .replacingOccurrences(of: "{names}", with: names.joined(separator: ", "))
    }

    public static var emptyCaption: String {
        L10n.tr(
            "支持 Mac Sai 的会员会列在这里。来做第一个吧。",
            "Members who keep Mac Sai free are listed here. Be the first.",
            "Здесь будут участники, которые поддерживают Mac Sai. Станьте первым."
        )
    }

    public static var supportCaption: String {
        L10n.tr("成为会员，或请开发者喝杯咖啡", "Become a member or buy a coffee", "Стать участником или угостить кофе")
    }
}
