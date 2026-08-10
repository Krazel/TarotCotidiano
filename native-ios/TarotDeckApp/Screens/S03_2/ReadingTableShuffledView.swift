import SwiftUI

/// Approved S03.2 only: three-card reading, shuffled, before any card is drawn.
///
/// Navigation and deck mutations are supplied by the eventual composition root so this view
/// cannot silently implement S03.1 or S03.3.
struct ReadingTableShuffledView: View {
    let onBack: () -> Void
    let onDrawCard: () -> Void
    let onEndReading: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(
        onBack: @escaping () -> Void = {},
        onDrawCard: @escaping () -> Void = {},
        onEndReading: @escaping () -> Void = {}
    ) {
        self.onBack = onBack
        self.onDrawCard = onDrawCard
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

            Text("Deck shuffled")
                .font(.subheadline)
                .foregroundStyle(CeremonialObsidianTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    private var readingPositions: some View {
        HStack(spacing: 14) {
            ForEach(1...3, id: \.self) { position in
                EmptyReadingPosition(position: position, total: 3)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Three empty card positions")
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

                CeremonialCardBack()
                    .frame(maxWidth: maxDeckWidth)
            }
            .padding(.bottom, 10)

            Text("Draw when you’re ready.")
                .font(.body)
                .foregroundStyle(CeremonialObsidianTheme.secondaryText)
                .multilineTextAlignment(.center)

            Button("Draw Card", action: onDrawCard)
                .buttonStyle(CeremonialPrimaryButtonStyle())
                .frame(maxWidth: maximumActionWidth)
                .accessibilityHint("Draws the first card into position one")

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

#Preview("S03.2 Portrait") {
    ReadingTableShuffledView()
}
.previewDevice("iPhone 15 Pro")

#Preview("S03.2 Landscape") {
    ReadingTableShuffledView()
}
.previewDevice("iPhone 15 Pro Max")
.previewInterfaceOrientation(.landscapeLeft)
