import SwiftUI

public struct SuperEllipse: Shape {
    let cornerRadius: CGFloat

    public init(cornerRadius: CGFloat = 20) {
        self.cornerRadius = cornerRadius
    }

    public func path(in rect: CGRect) -> Path {
        let minDimension = min(rect.width, rect.height)
        let radius = min(cornerRadius, minDimension / 2)

        let n: CGFloat = 4
        let centerX = rect.midX
        let centerY = rect.midY
        let a = rect.width / 2
        let b = rect.height / 2

        var path = Path()
        let steps = 360
        let blendFactor = radius / (minDimension / 2)

        for i in 0...steps {
            let angle = CGFloat(i) * .pi * 2 / CGFloat(steps)

            let cosA = cos(angle)
            let sinA = sin(angle)

            let superX = pow(abs(cosA), 2.0 / n) * a * (cosA >= 0 ? 1 : -1)
            let superY = pow(abs(sinA), 2.0 / n) * b * (sinA >= 0 ? 1 : -1)

            let ellipseX = a * cosA
            let ellipseY = b * sinA

            let x = centerX + ellipseX + (superX - ellipseX) * blendFactor
            let y = centerY + ellipseY + (superY - ellipseY) * blendFactor

            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        path.closeSubpath()
        return path
    }
}

public struct SuperEllipseButtonStyle: ButtonStyle {
    let gradient: LinearGradient
    let size: CGSize

    public init(gradient: LinearGradient, size: CGSize = CGSize(width: 160, height: 160)) {
        self.gradient = gradient
        self.size = size
    }

    public func makeBody(configuration: Configuration) -> some View {
        // Hug the label with `size` as a *minimum* rather than a fixed frame:
        // a fixed width truncates longer localized labels (e.g. Russian "Run
        // Safe Tasks" / "Check for Updates" / "Scan" overflow the English-sized
        // pills). Short labels still render at the design width; longer ones
        // grow instead of clipping. The large square scan buttons keep their
        // shape because their content is narrower than the 160pt minimum.
        let isPill = size.height <= 60
        return configuration.label
            .font(.system(size: isPill ? 14 : 18, weight: .semibold))
            .foregroundStyle(.white)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, isPill ? 16 : 0)
            .frame(minWidth: size.width, minHeight: size.height)
            .background {
                ZStack {
                    gradient
                    Color.white.opacity(0.08)
                }
            }
            .clipShape(SuperEllipse(cornerRadius: size.width * 0.28))
            .shadow(color: .black.opacity(0.25), radius: 16, y: 8)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}
