import SwiftUI
import MacCleanKit

/// The one place Mac Sai asks for support: an inline, dismissible card on the
/// post-clean screen, right after the app has visibly helped. It is never a
/// modal and never blocks anything. `SupportPrompt` decides whether it shows
/// (a big clean, not the first one, at most every 60 days, never after the
/// user opts out or follows the link); this view only renders the decision.
struct SupportCard: View {
    let freedBytes: UInt64

    private enum Phase { case hidden, asking, thanked }

    @State private var phase: Phase = .hidden
    @State private var evaluated = false
    @State private var cupBounce = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Buy Me a Coffee's brand yellow, with dark ink so it reads in both modes.
    private static let coffee = Color(red: 1.0, green: 0.867, blue: 0.0)
    private static let coffeeInk = Color(red: 0.11, green: 0.09, blue: 0.05)

    var body: some View {
        Group {
            switch phase {
            case .hidden:
                EmptyView()
            case .asking:
                askCard
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .offset(y: 14)),
                        removal: .opacity.combined(with: .scale(scale: 0.97))
                    ))
            case .thanked:
                thanks.transition(.opacity)
            }
        }
        .onAppear(perform: evaluate)
    }

    // MARK: - Ask

    private var askCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Self.coffee.opacity(0.22))
                        .frame(width: 38, height: 38)
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary.opacity(0.85))
                        .symbolEffect(.bounce, value: cupBounce)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(L10n.tr("这次清理，你没花一分钱。", "That cleanup cost you nothing.", "Эта очистка не стоила вам ни копейки."))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.primary)
                    Text(L10n.tr(
                        "没有订阅，没有广告，没有追踪。Mac Sai 是我和几位志愿者在业余时间做的。如果它帮你省下了买清理软件的钱，请我喝杯咖啡，让它对所有人继续免费。",
                        "No subscription, no ads, no tracking. I build Mac Sai on nights and weekends with a few volunteers. If it saved you from paying for a cleaner, a coffee keeps it free for everyone.",
                        "Без подписки, рекламы и слежки. Я делаю Mac Sai по вечерам и выходным вместе с несколькими добровольцами. Если он избавил вас от платной программы для очистки, чашка кофе поможет ему оставаться бесплатным для всех."
                    ))
                    .font(.system(size: 12.5))
                    .foregroundStyle(.primary.opacity(0.68))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                }
            }

            // Long translations (Russian) push "Don't ask again" onto its own line.
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 14) {
                    primaryActions
                    Spacer(minLength: 8)
                    optOutButton
                }
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 14) { primaryActions }
                    optOutButton
                }
            }
            .padding(.leading, 50)
        }
        .padding(16)
        .frame(maxWidth: 460, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(.primary.opacity(0.06)))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Self.coffee.opacity(0.45), lineWidth: 1)
        )
    }

    @ViewBuilder private var primaryActions: some View {
        Button(action: support) {
            Label(L10n.tr("请我喝杯咖啡", "Buy me a coffee", "Угостить кофе"), systemImage: "heart.fill")
        }
        .buttonStyle(CoffeeButtonStyle(fill: Self.coffee, ink: Self.coffeeInk))
        .help(MCConstants.supportURL.absoluteString)

        Button(L10n.tr("以后再说", "Maybe later", "Может, позже"), action: dismiss)
            .buttonStyle(.plain)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.primary.opacity(0.6))
            .fixedSize()
    }

    private var optOutButton: some View {
        Button(L10n.tr("不再提示", "Don't ask again", "Больше не спрашивать"), action: optOut)
            .buttonStyle(.plain)
            .font(.system(size: 11))
            .foregroundStyle(.primary.opacity(0.5))
            .fixedSize()
    }

    private var thanks: some View {
        HStack(spacing: 8) {
            Image(systemName: "heart.fill")
                .foregroundStyle(.pink)
                .symbolEffect(.bounce, value: cupBounce)
            Text(L10n.tr("谢谢你。正因为有你，它才能一直免费。", "Thank you. You're the reason it stays free.", "Спасибо. Благодаря вам он остаётся бесплатным."))
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.primary.opacity(0.8))
        }
    }

    // MARK: - Actions

    private func evaluate() {
        // Decide once per completion screen: re-renders must not count the
        // same clean twice or restart the cooldown.
        guard !evaluated else { return }
        evaluated = true
        guard SupportPrompt.registerClean(freedBytes: freedBytes) else { return }
        // Let the checkmark and the freed size land first; the card follows.
        Task { @MainActor in
            if !reduceMotion { try? await Task.sleep(for: .milliseconds(900)) }
            withAnimation(reduceMotion ? nil : .spring(response: 0.55, dampingFraction: 0.82)) {
                phase = .asking
            }
            if !reduceMotion {
                try? await Task.sleep(for: .milliseconds(450))
                cupBounce += 1
            }
        }
    }

    private func support() {
        NSWorkspace.shared.open(MCConstants.supportURL)
        SupportPrompt.optOut()
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.3)) { phase = .thanked }
        cupBounce += 1
    }

    private func dismiss() {
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) { phase = .hidden }
    }

    private func optOut() {
        SupportPrompt.optOut()
        dismiss()
    }
}

private struct CoffeeButtonStyle: ButtonStyle {
    let fill: Color
    let ink: Color

    func makeBody(configuration: Configuration) -> some View {
        CoffeeButtonBody(configuration: configuration, fill: fill, ink: ink)
    }
}

/// Separate view so the hover state lives on a real view, not the style.
private struct CoffeeButtonBody: View {
    let configuration: ButtonStyleConfiguration
    let fill: Color
    let ink: Color
    @State private var hovering = false

    var body: some View {
        configuration.label
            .font(.system(size: 13, weight: .semibold))
            .labelStyle(.titleAndIcon)
            .lineLimit(1)
            .fixedSize()
            .foregroundStyle(ink)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(Capsule().fill(fill.opacity(hovering ? 1 : 0.92)))
            .shadow(color: fill.opacity(hovering ? 0.45 : 0.2), radius: hovering ? 8 : 4, y: 2)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
            .animation(.easeOut(duration: 0.15), value: hovering)
            .onHover { hovering = $0 }
            .contentShape(Capsule())
    }
}
