import SwiftUI

/// Approved S03.3 only: the first of three cards is drawn and remains face down.
///
/// Drawing the next card and revealing the placed card are callback boundaries. This view never
/// materializes a second-card state or S03.4, whose final presentation remains visually gated.
struct ReadingTableFirstDrawnFaceDownView: View {
    let onBack: () -> Void
    let onDrawNextCard: () -> Void
    let onRevealFirstCard: () -> Void
    let onEndReading: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(
        onBack: @escaping () -> Void = {},
        onDrawNextCard: @escaping () -> Void = {},
        onRevealFirstCard: @escaping () -> Void = {},
        onEndReading: @escaping () -> Void = {}
    ) {
        self.onBack = onBack
        self.onDrawNextCard = onDrawNextCard
        self.onRevealFirstCard = onRevealFirstCard
        self.onEndReading = onEndReading
    }

    var body: some View {
        GeometryReader { proxy in
            let useLandscapeComposition = proxy.size.width > proxy.size.height
                && !dynamicTypeSize.isAccessibilitySize

            ZStack {
                CeremonialBackdrop()

                if useLandscapeComposition {
                    landscapeContent
                } else {
                    portraitContent
                }
            }
        }
        .foregroundStyle(CeremonialObsidianTheme.parchment)
        .preferredColorScheme(.dark)
    }

    private var portraitContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                header
                    .padding(.bottom, 22)

                readingPositions
                    .frame(maxWidth: 520)
                    .padding(.horizontal, 22)

                deckAndActions(maxDeckWidth: 196, maximumActionWidth: 360)
                    .padding(.top, 22)
                    .padding(.horizontal, 28)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
            .padding(.bottom, 18)
        }
        .scrollIndicators(.hidden)
    }

    private var landscapeContent: some View {
        ZStack(alignment: .topLeading) {
            HStack(alignment: .center, spacing: 28) {
                deckAndActions(maxDeckWidth: 120, maximumActionWidth: 250, spacing: 10)
                    .frame(maxWidth: 270)

                VStack(spacing: 10) {
                    titleBlock

                    readingPositions
                        .frame(maxWidth: 610, maxHeight: 280)
                }
            }
            .frame(maxWidth: 940)
            .padding(.horizontal, 32)

            backButton
                .padding(.leading, 22)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(.top, 4)
        .padding(.bottom, 14)
    }

    private var header: some View {
        ZStack(alignment: .leading) {
            backButton
            titleBlock
        }
        .padding(.horizontal, 22)
        .frame(minHeight: 62)
    }

    private var backButton: some View {
        Button(action: onBack) {
            Image(systemName: "chevron.left")
                .font(.system(size: 25, weight: .semibold))
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(CeremonialObsidianTheme.parchment)
        .accessibilityLabel("Back")
        .accessibilityHint("Returns to the previous screen")
    }

    private var titleBlock: some View {
        VStack(spacing: 3) {
            Text("Three Cards")
                .font(.system(.title, design: .serif, weight: .semibold))
                .foregroundStyle(CeremonialObsidianTheme.parchment)

            Text("1 of 3 drawn")
                .font(.subheadline)
                .foregroundStyle(CeremonialObsidianTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    private var readingPositions: some View {
        HStack(spacing: 14) {
            FaceDownReadingPosition(
                position: 1,
                total: 3,
                onReveal: onRevealFirstCard
            )

            EmptyReadingPosition(position: 2, total: 3)
            EmptyReadingPosition(position: 3, total: 3)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Three card positions, one card drawn face down")
    }

    private func deckAndActions(
        maxDeckWidth: CGFloat,
        maximumActionWidth: CGFloat,
        spacing: CGFloat = 14
    ) -> some View {
        VStack(spacing: spacing) {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: CeremonialObsidianTheme.cardCornerRadius + 2)
                    .fill(CeremonialObsidianTheme.gold.opacity(0.46))
                    .frame(maxWidth: maxDeckWidth)
                    .aspectRatio(CeremonialObsidianTheme.deckAspectRatio, contentMode: .fit)
                    .offset(y: 10)

                CeremonialCardBack(spokenLabel: "Deck with 77 cards remaining")
                    .frame(maxWidth: maxDeckWidth)
            }
            .padding(.bottom, 10)

            Text("Tap the card to reveal it.")
                .font(.body)
                .foregroundStyle(CeremonialObsidianTheme.secondaryText)
                .multilineTextAlignment(.center)

            Button("Draw Next Card", action: onDrawNextCard)
                .buttonStyle(CeremonialPrimaryButtonStyle())
                .frame(maxWidth: maximumActionWidth)
                .accessibilityHint("Requests the next card for position two")

            Button("End Reading", action: onEndReading)
                .font(.system(.body, design: .rounded, weight: .medium))
                .foregroundStyle(CeremonialObsidianTheme.brightGold)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
                .buttonStyle(.plain)
                .accessibilityHint("Opens confirmation before ending this reading")
        }
    }
}

#Preview("S03.3 Portrait") {
    ReadingTableFirstDrawnFaceDownView()
}
.previewDevice("iPhone 15 Pro")

#Preview("S03.3 Landscape") {
    ReadingTableFirstDrawnFaceDownView()
}
.previewDevice("iPhone 15 Pro Max")
.previewInterfaceOrientation(.landscapeLeft)
