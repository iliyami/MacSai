import AppKit
import SwiftUI
import XCTest
@testable import MacClean

/// A post-clean screen with the support card can be taller than a small
/// window. Unscrollable, it overflowed the detail pane, pushed the title off
/// the top, and blanked the sidebar. It must scroll instead.
@MainActor
final class DoneScreenLayoutTests: XCTestCase {
    private var tallScreen: some View {
        VStack(spacing: 20) {
            Spacer()
            Color.clear.frame(height: 900)
            Spacer()
        }
    }

    func testUnscrollableTallScreenDemandsATallerWindow() {
        // The failure mode, measured: this is what the done screens did.
        let host = NSHostingView(rootView: tallScreen)
        XCTAssertGreaterThanOrEqual(host.fittingSize.height, 900)
    }

    func testDoneScreenScrollsInsteadOfOverflowing() {
        let host = NSHostingView(rootView: FitOrScroll { tallScreen })
        XCTAssertLessThan(host.fittingSize.height, 550, "550 is the window's minimum height")
    }
}
