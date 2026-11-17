import SwiftUI

/// A vertical ScrollView that keeps right-to-left content in place.
///
/// On macOS, SwiftUI's ScrollView under a right-to-left layout shifts its
/// content sideways by the width of the sidebar, so Farsi rows slid under the
/// sidebar. The scroll view itself is laid out left to right and only its
/// content takes the surrounding direction.
struct DirectionalScrollView<Content: View>: View {
    @Environment(\.layoutDirection) private var layoutDirection
    private let axes: Axis.Set
    private let showsIndicators: Bool
    private let content: Content

    init(_ axes: Axis.Set = .vertical, showsIndicators: Bool = true, @ViewBuilder content: () -> Content) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.content = content()
    }

    var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            content.environment(\.layoutDirection, layoutDirection)
        }
        .environment(\.layoutDirection, .leftToRight)
    }
}
