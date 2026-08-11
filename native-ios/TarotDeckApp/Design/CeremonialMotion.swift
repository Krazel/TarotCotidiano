import SwiftUI
import UIKit

/// The motion language for Ceremonial Obsidian.
///
/// Motion is deliberately short and tactile. It clarifies a durable state change; it never
/// delays one, loops in the background, or exposes a face-down card's identity.
enum CeremonialMotion {
    static let screen = Animation.easeOut(duration: 0.22)
    static let press = Animation.easeOut(duration: 0.08)
    static let pressRelease = Animation.easeOut(duration: 0.10)
    static let cut = Animation.easeInOut(duration: 0.18)
    static let interleave = Animation.easeInOut(duration: 0.24)
    static let riffle = Animation.timingCurve(0.30, 0.00, 0.20, 1.00, duration: 0.24)
    static let shuffleSettleDuration: TimeInterval = 0.20
    static let shuffleSettle = Animation.timingCurve(
        0.20,
        0.72,
        0.18,
        1.00,
        duration: shuffleSettleDuration
    )
    static let deal = Animation.timingCurve(0.20, 0.72, 0.18, 1.00, duration: 0.38)
    static let reveal = Animation.easeInOut(duration: 0.32)
    static let conceal = Animation.easeInOut(duration: 0.32)
    static let reduced = Animation.easeOut(duration: 0.15)
}

/// Interpolates the entire source-to-slot route, including its restrained perpendicular arc.
/// Computing the route inside `effectValue` ensures SwiftUI samples the curve for every frame
/// instead of merely interpolating between two precomputed positions.
struct CeremonialDealGeometryEffect: GeometryEffect {
    var progress: CGFloat
    let start: CGPoint
    let end: CGPoint
    let arcHeight: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let boundedProgress = min(max(progress, 0), 1)
        let dx = end.x - start.x
        let dy = end.y - start.y
        let distance = max(sqrt(dx * dx + dy * dy), 1)
        let arc = sin(.pi * boundedProgress) * arcHeight
        let center = CGPoint(
            x: start.x + dx * boundedProgress - (dy / distance) * arc,
            y: start.y + dy * boundedProgress + (dx / distance) * arc
        )
        return ProjectionTransform(
            CGAffineTransform(
                translationX: center.x - start.x,
                y: center.y - start.y
            )
        )
    }
}

enum CeremonialFlipFace: Equatable {
    case back
    case front
}

/// Drives each physical face from one animatable progress value. The destination face remains
/// absent until the turn reaches its edge at the midpoint, so card art never leaks early.
struct CeremonialFlipFaceModifier: AnimatableModifier {
    var progress: CGFloat
    let face: CeremonialFlipFace
    let revealing: Bool
    let reduceMotion: Bool

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        let boundedProgress = min(max(progress, 0), 1)
        let firstHalf = min(boundedProgress * 2, 1)
        let secondHalf = max((boundedProgress - 0.5) * 2, 0)
        let isDestination = (revealing && face == .front) || (!revealing && face == .back)
        let angle: Double
        let opacity: Double

        if reduceMotion {
            angle = 0
            opacity = Double(isDestination ? secondHalf : 1 - secondHalf)
        } else if isDestination {
            angle = Double(-90 + secondHalf * 90)
            opacity = boundedProgress >= 0.5 ? 1 : 0
        } else {
            angle = Double(firstHalf * 90)
            opacity = boundedProgress < 0.5 ? 1 : 0
        }

        return content
            .rotation3DEffect(
                .degrees(angle),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.72
            )
            .opacity(opacity)
    }
}

struct CeremonialDeckButtonStyle: ButtonStyle {
    let usesReducedMotion: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(usesReducedMotion || !configuration.isPressed ? 1 : 0.985)
            .opacity(configuration.isPressed ? (usesReducedMotion ? 0.92 : 0.94) : 1)
            .animation(
                configuration.isPressed ? CeremonialMotion.press : CeremonialMotion.pressRelease,
                value: configuration.isPressed
            )
    }
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

/// A tactile split, interleave, riffle and square treatment for a face-down deck.
struct CeremonialShufflingDeck: View {
    let phase: Int
    let reduceMotion: Bool
    let spokenLabel: String

    var body: some View {
        ZStack {
            if !reduceMotion {
                ForEach(0..<3, id: \.self) { layer in
                    CeremonialCardBack(spokenLabel: "")
                        .offset(
                            x: leftOffsetX,
                            y: CGFloat(layer) * 2 + splitLift
                        )
                        .rotationEffect(.degrees(leftRotation))
                        .opacity(splitOpacity)
                        .accessibilityHidden(true)

                    CeremonialCardBack(spokenLabel: "")
                        .offset(
                            x: rightOffsetX,
                            y: CGFloat(layer) * 2 - splitLift
                        )
                        .rotationEffect(.degrees(rightRotation))
                        .opacity(splitOpacity)
                        .accessibilityHidden(true)
                }
            }

            CeremonialCardBack(spokenLabel: "")
                .scaleEffect(phase == 1 ? 0.965 : (phase == 5 ? 1.012 : 1))
                .offset(y: phase == 1 ? 3 : 0)
                .opacity(!reduceMotion && (2...4).contains(phase) ? 0 : 1)
                .opacity(reduceMotion && phase != 0 ? 0.72 : 1)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenLabel)
    }

    private var splitOpacity: Double {
        (2...4).contains(phase) ? 1 : 0
    }

    private var leftOffsetX: CGFloat {
        switch phase {
        case 2: return -20
        case 3: return -8
        case 4: return -2
        default: return 0
        }
    }

    private var rightOffsetX: CGFloat {
        switch phase {
        case 2: return 20
        case 3: return 8
        case 4: return 2
        default: return 0
        }
    }

    private var splitLift: CGFloat {
        phase == 4 ? 5 : 0
    }

    private var leftRotation: Double {
        switch phase {
        case 2: return -2.4
        case 3: return 4.5
        case 4: return 1.2
        default: return 0
        }
    }

    private var rightRotation: Double {
        switch phase {
        case 2: return 2.4
        case 3: return -4.5
        case 4: return -1.2
        default: return 0
        }
    }
}
