import SwiftUI

struct CeremonialBackdrop: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    CeremonialObsidianTheme.backgroundLifted,
                    CeremonialObsidianTheme.background,
                    .black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Canvas { context, size in
                let center = CGPoint(x: size.width * 0.52, y: size.height * 0.48)
                let maximumRadius = max(size.width, size.height) * 0.92
                let gold = CeremonialObsidianTheme.gold.opacity(0.12)

                for index in 1...6 {
                    let radius = maximumRadius * CGFloat(index) / 6
                    let rect = CGRect(
                        x: center.x - radius,
                        y: center.y - radius,
                        width: radius * 2,
                        height: radius * 2
                    )
                    context.stroke(Path(ellipseIn: rect), with: .color(gold), lineWidth: 0.7)
                }

                for index in 0..<24 {
                    let angle = (Double(index) / 24.0) * Double.pi * 2
                    var ray = Path()
                    ray.move(to: center)
                    ray.addLine(to: CGPoint(
                        x: center.x + CGFloat(cos(angle)) * maximumRadius,
                        y: center.y + CGFloat(sin(angle)) * maximumRadius
                    ))
                    context.stroke(ray, with: .color(gold), lineWidth: 0.6)
                }

                let starPoints: [(CGFloat, CGFloat)] = [
                    (0.10, 0.20), (0.18, 0.71), (0.29, 0.12), (0.38, 0.82),
                    (0.52, 0.22), (0.64, 0.69), (0.75, 0.15), (0.88, 0.40),
                    (0.93, 0.76), (0.12, 0.89), (0.70, 0.91)
                ]

                for (x, y) in starPoints {
                    let point = CGPoint(x: size.width * x, y: size.height * y)
                    var star = Path()
                    star.move(to: CGPoint(x: point.x - 2.5, y: point.y))
                    star.addLine(to: CGPoint(x: point.x + 2.5, y: point.y))
                    star.move(to: CGPoint(x: point.x, y: point.y - 2.5))
                    star.addLine(to: CGPoint(x: point.x, y: point.y + 2.5))
                    context.stroke(
                        star,
                        with: .color(CeremonialObsidianTheme.brightGold.opacity(0.30)),
                        lineWidth: 0.8
                    )
                }
            }
            .accessibilityHidden(true)

            RadialGradient(
                colors: [.clear, .black.opacity(0.48)],
                center: .center,
                startRadius: 40,
                endRadius: 620
            )
            .accessibilityHidden(true)
        }
        .ignoresSafeArea()
    }
}
