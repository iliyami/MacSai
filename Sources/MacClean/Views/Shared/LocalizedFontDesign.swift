import SwiftUI
import MacCleanKit

extension Font.Design {
    /// SF Mono has no Arabic-script glyphs, so Farsi set in it falls back to
    /// unjoined letters. Text that can be translated keeps the regular design
    /// in right-to-left languages.
    static var monospacedUnlessRightToLeft: Font.Design {
        AppLanguage.current.isRightToLeft ? .default : .monospaced
    }
}
