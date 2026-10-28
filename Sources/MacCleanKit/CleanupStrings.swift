import Foundation

/// Dynamic cleanup copy uses every supported language instead of looking up
/// already-interpolated strings in the static localization dictionaries.
public enum CleanupStrings {
    public static func selectionSummary(selected: Int, total: Int) -> String {
        let selectedText = selected.formatted()
        let totalText = total.formatted()
        switch AppLanguage.current.resolved {
        case .system, .en: return "\(selectedText) of \(totalText) item\(total == 1 ? "" : "s") selected"
        case .de: return "\(selectedText) von \(totalText) \(total == 1 ? "Objekt" : "Objekten") ausgewählt"
        case .fr: return "\(selectedText) \(selected == 1 ? "élément sélectionné" : "éléments sélectionnés") sur \(totalText)"
        case .it: return "\(selectedText) \(selected == 1 ? "elemento selezionato" : "elementi selezionati") su \(totalText)"
        case .ru:
            return "Выбрано \(selectedText) из \(totalText) \(L10n.russianPlural(total, one: "объекта", few: "объектов", many: "объектов"))"
        case .zhHans: return "已选择 \(selectedText) / \(totalText) 项"
        case .zhHant: return "已選擇 \(selectedText) / \(totalText) 項"
        }
    }

    public static func confirmationTitle(count: Int) -> String {
        let number = count.formatted()
        switch AppLanguage.current.resolved {
        case .system, .en: return "Clean \(number) item\(count == 1 ? "" : "s")?"
        case .de: return "\(number) Objekt\(count == 1 ? "" : "e") bereinigen?"
        case .fr: return "Nettoyer \(number) élément\(count == 1 ? "" : "s") ?"
        case .it: return "Pulire \(number) \(count == 1 ? "elemento" : "elementi")?"
        case .ru:
            return "Очистить \(number) \(L10n.russianPlural(count, one: "объект", few: "объекта", many: "объектов"))?"
        case .zhHans: return "清理 \(number) 项？"
        case .zhHant: return "清理 \(number) 項？"
        }
    }

    public static func itemCount(_ count: Int) -> String {
        let number = count.formatted()
        switch AppLanguage.current.resolved {
        case .system, .en: return "\(number) item\(count == 1 ? "" : "s")"
        case .de: return "\(number) Objekt\(count == 1 ? "" : "e")"
        case .fr: return "\(number) élément\(count == 1 ? "" : "s")"
        case .it: return "\(number) \(count == 1 ? "elemento" : "elementi")"
        case .ru:
            return "\(number) \(L10n.russianPlural(count, one: "объект", few: "объекта", many: "объектов"))"
        case .zhHans: return "\(number) 项"
        case .zhHant: return "\(number) 項"
        }
    }
}
