import SwiftUI

struct CeremonialPrimaryButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.title3, design: .serif, weight: .semibold))
            .foregroundStyle(Color.black.opacity(0.86))
            .frame(maxWidth: .infinity, minHeight: 54)
            .padding(.horizontal, 20)
            .background {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                CeremonialObsidianTheme.brightGold,
                                CeremonialObsidianTheme.gold
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        Capsule()
                            .stroke(Color.white.opacity(0.28), lineWidth: 1)
                    }
                    .shadow(
                        color: CeremonialObsidianTheme.gold.opacity(0.18),
                        radius: 12,
                        y: 5
                    )
            }
            .scaleEffect(
                reduceMotion || voiceOverEnabled ? 1 : (configuration.isPressed ? 0.985 : 1)
            )
            .opacity(configuration.isPressed ? 0.90 : 1)
            .animation(
                reduceMotion || voiceOverEnabled
                    ? CeremonialMotion.reduced
                    : .easeOut(duration: 0.09),
                value: configuration.isPressed
            )
    }
}
