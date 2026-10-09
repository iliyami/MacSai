import SwiftUI

/// Hosts a full-pane screen (Spacer-centered VStack) so it stays centered when
/// it fits and scrolls when it does not. Without this, a post-clean screen
/// taller than the window (e.g. with the support card on a small window)
/// overflowed the detail pane, pushed the title off the top, and blanked
/// the sidebar.
struct FitOrScroll<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical) {
                content
                    .frame(maxWidth: .infinity, minHeight: proxy.size.height)
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.automatic)
        }
    }
}
