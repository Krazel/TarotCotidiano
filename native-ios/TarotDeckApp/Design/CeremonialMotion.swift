import SwiftUI
import UIKit

/// The motion language for Ceremonial Obsidian.
///
/// Motion is deliberately short and tactile. It clarifies a durable state change; it never
/// delays one, loops in the background, or exposes a face-down card's identity.
enum CeremonialMotion {
    static let screen = Animation.easeOut(duration: 0.22)
    static let shuffle = Animation.easeInOut(duration: 0.16)
    static let draw = Animation.spring(response: 0.38, dampingFraction: 0.88, blendDuration: 0)
    static let reveal = Animation.easeInOut(duration: 0.32)
    static let conceal = Animation.easeInOut(duration: 0.28)
    static let reduced = Animation.easeOut(duration: 0.15)
}

@MainActor
enum CeremonialHaptics {
    static func shuffled() {
        impact(.soft, intensity: 0.65)
    }

    static func drawn() {
        impact(.medium, intensity: 0.72)
    }

    static func revealed() {
        impact(.light, intensity: 0.70)
    }

    static func concealed() {
        impact(.soft, intensity: 0.50)
    }

    static func favoriteChanged(isFavorite: Bool) {
        impact(isFavorite ? .light : .soft, intensity: isFavorite ? 0.72 : 0.52)
    }

    private static func impact(
        _ style: UIImpactFeedbackGenerator.FeedbackStyle,
        intensity: CGFloat
    ) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred(intensity: intensity)
    }
}

/// A restrained cut-and-settle treatment for a face-down deck.
struct CeremonialShufflingDeck: View {
    let phase: Int
    let reduceMotion: Bool
    let spokenLabel: String

    private var xOffset: CGFloat {
        guard !reduceMotion else { return 0 }
        switch phase {
        case 1: return -10
        case 2: return 9
        default: return 0
        }
    }

    private var rotation: Double {
        guard !reduceMotion else { return 0 }
        switch phase {
        case 1: return -2
        case 2: return 1.8
        default: return 0
        }
    }

    var body: some View {
        ZStack {
            if !reduceMotion {
                CeremonialCardBack(spokenLabel: "")
                    .offset(x: -5, y: 3)
                    .rotationEffect(.degrees(-0.8))
                    .opacity(phase == 0 ? 0 : 0.42)
                    .accessibilityHidden(true)

                CeremonialCardBack(spokenLabel: "")
                    .offset(x: 5, y: 2)
                    .rotationEffect(.degrees(0.8))
                    .opacity(phase == 0 ? 0 : 0.34)
                    .accessibilityHidden(true)
            }

            CeremonialCardBack(spokenLabel: spokenLabel)
                .offset(x: xOffset)
                .rotationEffect(.degrees(rotation))
                .scaleEffect(reduceMotion ? 1 : (phase == 0 ? 1 : 0.985))
                .opacity(reduceMotion && phase != 0 ? 0.78 : 1)
        }
        .animation(reduceMotion ? CeremonialMotion.reduced : CeremonialMotion.shuffle, value: phase)
    }
}

private struct CeremonialFlipModifier: ViewModifier {
    let degrees: Double
    let opacity: Double

    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(degrees),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.72
            )
            .opacity(opacity)
    }
}

extension AnyTransition {
    static var ceremonialCardReveal: AnyTransition {
        .modifier(
            active: CeremonialFlipModifier(degrees: -88, opacity: 0),
            identity: CeremonialFlipModifier(degrees: 0, opacity: 1)
        )
    }
}
