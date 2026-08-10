import SwiftUI
import UIKit

enum TarotDeckAssetName {
    static let ceremonialCardBack = "ceremonial-card-back"
}

struct EmptyReadingPosition: View {
    let position: Int
    let total: Int
    let positionName: String?

    init(position: Int, total: Int, positionName: String? = nil) {
        self.position = position
        self.total = total
        self.positionName = positionName
    }

    var body: some View {
        RoundedRectangle(cornerRadius: CeremonialObsidianTheme.cardCornerRadius)
            .fill(
                LinearGradient(
                    colors: [
                        CeremonialObsidianTheme.cardSurface,
                        Color.black.opacity(0.94)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                RoundedRectangle(cornerRadius: CeremonialObsidianTheme.cardCornerRadius)
                    .stroke(CeremonialObsidianTheme.cardEdge, lineWidth: 3)
            }
            .overlay {
                RoundedRectangle(cornerRadius: CeremonialObsidianTheme.cardCornerRadius - 3)
                    .inset(by: 5)
                    .stroke(CeremonialObsidianTheme.gold.opacity(0.88), lineWidth: 1)
            }
            .overlay {
                CeremonialCornerMarks()
                    .stroke(CeremonialObsidianTheme.brightGold.opacity(0.88), lineWidth: 1)
                    .padding(8)
            }
            .shadow(color: .black.opacity(0.72), radius: 9, y: 6)
            .aspectRatio(CeremonialObsidianTheme.cardAspectRatio, contentMode: .fit)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                positionName.map {
                    AppLocalization.format("%@, empty card position", $0)
                } ?? AppLocalization.format("Empty card position %d of %d", position, total)
            )
    }
}

struct CeremonialCardBack: View {
    let assetName: String
    let presentationAspectRatio: CGFloat
    let contentMode: ContentMode
    let spokenLabel: String

    init(
        assetName: String = TarotDeckAssetName.ceremonialCardBack,
        presentationAspectRatio: CGFloat = CeremonialObsidianTheme.deckAspectRatio,
        contentMode: ContentMode = .fit,
        spokenLabel: String? = nil
    ) {
        self.assetName = assetName
        self.presentationAspectRatio = presentationAspectRatio
        self.contentMode = contentMode
        self.spokenLabel = spokenLabel ?? AppLocalization.text("Shuffled deck, ready to draw")
    }

    var body: some View {
        Group {
            if let image = UIImage(named: assetName) {
                Image(uiImage: image)
                    .resizable()
                    .antialiased(true)
                    .aspectRatio(contentMode: contentMode)
                    .accessibilityHidden(true)
            } else {
                ProvisionalCeremonialCardBack()
            }
        }
        .aspectRatio(presentationAspectRatio, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: CeremonialObsidianTheme.cardCornerRadius))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenLabel)
    }
}

/// An already drawn card that remains face down in an approved reading position.
///
/// The button-equivalent action is required so VoiceOver never depends on the visual tap gesture.
struct FaceDownReadingPosition: View {
    let position: Int
    let total: Int
    let positionName: String?
    let onReveal: () -> Void

    init(
        position: Int,
        total: Int,
        positionName: String? = nil,
        onReveal: @escaping () -> Void
    ) {
        self.position = position
        self.total = total
        self.positionName = positionName
        self.onReveal = onReveal
    }

    var body: some View {
        Button(action: onReveal) {
            CeremonialCardBack(
                presentationAspectRatio: CeremonialObsidianTheme.cardAspectRatio,
                contentMode: .fill,
                spokenLabel: positionName.map {
                    AppLocalization.format("%@, face down", $0)
                } ?? AppLocalization.format("Card position %d of %d, face down", position, total)
            )
            .contentShape(RoundedRectangle(cornerRadius: CeremonialObsidianTheme.cardCornerRadius))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            positionName.map {
                AppLocalization.format("%@, face down", $0)
            } ?? AppLocalization.format("Card position %d of %d, face down", position, total)
        )
        .accessibilityHint("Reveals this card")
    }
}

/// A revealed card within the approved reading table.
///
/// The visual remains self-contained here. Inspecting or concealing the card is delegated to the
/// composition root so this component cannot materialize the unapproved focused-card state.
struct RevealedReadingPosition: View {
    let assetName: String
    let cardName: String
    let position: Int
    let total: Int
    let onInspect: () -> Void
    let onConceal: () -> Void

    var body: some View {
        Button(action: onInspect) {
            Group {
                if let image = UIImage(named: assetName) {
                    Image(uiImage: image)
                        .resizable()
                        .antialiased(true)
                        .scaledToFit()
                        .accessibilityHidden(true)
                } else {
                    MissingApprovedCardFace(cardName: cardName)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(CeremonialObsidianTheme.parchment.opacity(0.96))
            .clipShape(RoundedRectangle(cornerRadius: CeremonialObsidianTheme.cardCornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: CeremonialObsidianTheme.cardCornerRadius)
                    .stroke(CeremonialObsidianTheme.gold.opacity(0.64), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.72), radius: 9, y: 6)
            .aspectRatio(CeremonialObsidianTheme.cardAspectRatio, contentMode: .fit)
            .contentShape(RoundedRectangle(cornerRadius: CeremonialObsidianTheme.cardCornerRadius))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            AppLocalization.format(
                "%@, card position %d of %d, face up",
                cardName,
                position,
                total
            )
        )
        .accessibilityHint("Requests a closer look at this revealed card")
        .accessibilityAction(named: Text("Turn face down"), onConceal)
    }
}

private struct ProvisionalCeremonialCardBack: View {
    var body: some View {
        RoundedRectangle(cornerRadius: CeremonialObsidianTheme.cardCornerRadius)
            .fill(CeremonialObsidianTheme.cardSurface)
            .overlay {
                Canvas { context, size in
                    let center = CGPoint(x: size.width / 2, y: size.height * 0.48)
                    let radius = min(size.width, size.height) * 0.16
                    let gold = CeremonialObsidianTheme.brightGold.opacity(0.88)

                    for index in 0..<32 {
                        let angle = (Double(index) / 32.0) * Double.pi * 2
                        var ray = Path()
                        ray.move(to: center)
                        ray.addLine(to: CGPoint(
                            x: center.x + CGFloat(cos(angle)) * radius * 2.8,
                            y: center.y + CGFloat(sin(angle)) * radius * 2.8
                        ))
                        context.stroke(ray, with: .color(gold), lineWidth: 0.7)
                    }

                    context.fill(
                        Path(ellipseIn: CGRect(
                            x: center.x - radius,
                            y: center.y - radius,
                            width: radius * 2,
                            height: radius * 2
                        )),
                        with: .color(CeremonialObsidianTheme.gold.opacity(0.92))
                    )

                    var horizon = Path()
                    horizon.move(to: CGPoint(x: size.width * 0.15, y: size.height * 0.64))
                    horizon.addCurve(
                        to: CGPoint(x: size.width * 0.85, y: size.height * 0.64),
                        control1: CGPoint(x: size.width * 0.34, y: size.height * 0.53),
                        control2: CGPoint(x: size.width * 0.64, y: size.height * 0.72)
                    )
                    context.stroke(horizon, with: .color(gold), lineWidth: 1)
                }
                .padding(12)
                .accessibilityHidden(true)
            }
            .overlay {
                RoundedRectangle(cornerRadius: CeremonialObsidianTheme.cardCornerRadius - 2)
                    .inset(by: 7)
                    .stroke(CeremonialObsidianTheme.brightGold, lineWidth: 1.2)
            }
            .overlay(alignment: .bottom) {
                Text("PROVISIONAL ASSET")
                    .font(.system(size: 8, weight: .bold, design: .rounded))
                    .tracking(1.3)
                    .foregroundStyle(CeremonialObsidianTheme.parchment.opacity(0.72))
                    .padding(.bottom, 14)
                    .accessibilityHidden(true)
            }
    }
}

/// A conspicuous internal-only fallback. Missing approved face art is a release failure, not a
/// normal product state, so this must never be treated as shippable presentation.
private struct MissingApprovedCardFace: View {
    let cardName: String

    var body: some View {
        ZStack {
            CeremonialObsidianTheme.cardSurface

            VStack(spacing: 8) {
                Image(systemName: "photo.badge.exclamationmark")
                    .font(.title2)

                Text("MISSING APPROVED ASSET")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .tracking(1)

                Text(cardName)
                    .font(.system(.caption, design: .serif, weight: .semibold))
            }
            .multilineTextAlignment(.center)
            .foregroundStyle(CeremonialObsidianTheme.parchment)
            .padding(8)
            .accessibilityHidden(true)
        }
    }
}

private struct CeremonialCornerMarks: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let length = min(rect.width, rect.height) * 0.09

        path.move(to: CGPoint(x: rect.minX, y: rect.minY + length))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + length, y: rect.minY))

        path.move(to: CGPoint(x: rect.maxX - length, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + length))

        path.move(to: CGPoint(x: rect.minX, y: rect.maxY - length))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + length, y: rect.maxY))

        path.move(to: CGPoint(x: rect.maxX - length, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - length))

        return path
    }
}
