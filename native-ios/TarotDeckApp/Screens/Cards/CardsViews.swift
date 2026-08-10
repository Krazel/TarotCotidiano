import SwiftUI

enum TarotCardFilter: String, CaseIterable, Hashable {
    case all = "All"
    case major = "Major"
    case wands = "Wands"
    case cups = "Cups"
    case swords = "Swords"
    case pentacles = "Pentacles"

    func includes(_ card: TarotCardRecord) -> Bool {
        switch self {
        case .all: return true
        case .major: return card.arcana == "major"
        case .wands: return card.suit == "wands"
        case .cups: return card.suit == "cups"
        case .swords: return card.suit == "swords"
        case .pentacles: return card.suit == "pentacles"
        }
    }
}

struct CardsLibraryView: View {
    let content: TarotContent

    @State private var selectedFilter: TarotCardFilter = .all
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var columns: [GridItem] {
        let count = dynamicTypeSize.isAccessibilitySize ? 1 : 2
        return Array(
            repeating: GridItem(.flexible(minimum: 0), spacing: 14, alignment: .top),
            count: count
        )
    }

    private var filteredCards: [TarotCardRecord] {
        content.cards.filter(selectedFilter.includes)
    }

    var body: some View {
        ZStack {
            CeremonialBackdrop()

            ScrollView {
                LazyVStack(spacing: 20) {
                    titleBlock
                    filters

                    LazyVGrid(columns: columns, spacing: 22) {
                        ForEach(filteredCards) { card in
                            NavigationLink {
                                CardLibraryDetailView(
                                    cards: filteredCards,
                                    initialCardID: card.id,
                                    meaningsByCardID: content.meaningsByCardID
                                )
                            } label: {
                                libraryCard(card)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 22)
                .padding(.bottom, 30)
            }
            .scrollIndicators(.hidden)
        }
        .foregroundStyle(CeremonialObsidianTheme.parchment)
        .toolbar(.hidden, for: .navigationBar)
        .navigationTitle("Cards")
    }

    private var titleBlock: some View {
        VStack(spacing: 7) {
            Text("Cards")
                .font(.system(.largeTitle, design: .serif, weight: .semibold))
                .accessibilityAddTraits(.isHeader)

            Text("Explore all 78 cards")
                .font(.system(.title3, design: .serif))
                .foregroundStyle(CeremonialObsidianTheme.brightGold)
        }
    }

    private var filters: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 9) {
                ForEach(TarotCardFilter.allCases, id: \.self) { filter in
                    Button {
                        selectedFilter = filter
                    } label: {
                        Text(filter.rawValue)
                            .font(.system(.body, design: .serif, weight: .medium))
                            .padding(.horizontal, 15)
                            .frame(minHeight: 44)
                            .background {
                                Capsule()
                                    .fill(CeremonialObsidianTheme.cardSurface)
                                    .overlay {
                                        Capsule()
                                            .stroke(
                                                filter == selectedFilter
                                                    ? CeremonialObsidianTheme.brightGold
                                                    : CeremonialObsidianTheme.cardEdge,
                                                lineWidth: filter == selectedFilter ? 1.5 : 1
                                            )
                                    }
                            }
                            .foregroundStyle(
                                filter == selectedFilter
                                    ? CeremonialObsidianTheme.brightGold
                                    : CeremonialObsidianTheme.parchment
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(filter.rawValue), \(filter == selectedFilter ? "selected" : "filter")")
                }
            }
            .padding(.horizontal, 1)
        }
        .scrollIndicators(.hidden)
        .accessibilityLabel("Card filters")
    }

    private func libraryCard(_ card: TarotCardRecord) -> some View {
        let meaning = content.meaning(for: card)
        let artwork = TarotArtworkView(
            card: card,
            artworkDescription: meaning?.artworkDescription
        )
        return VStack(spacing: 8) {
            artwork

            Text(card.name)
                .font(.system(.caption, design: .serif, weight: .medium))
                .foregroundStyle(CeremonialObsidianTheme.parchment)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(minHeight: 44, alignment: .top)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(card.name)
        .accessibilityValue(artwork.accessibilitySummary)
        .accessibilityHint("Opens the upright meaning")
    }
}

struct CardLibraryDetailView: View {
    let cards: [TarotCardRecord]
    let meaningsByCardID: [String: TarotCardMeaning]

    @State private var selectedIndex: Int

    init(
        cards: [TarotCardRecord],
        initialCardID: String,
        meaningsByCardID: [String: TarotCardMeaning]
    ) {
        self.cards = cards
        self.meaningsByCardID = meaningsByCardID
        _selectedIndex = State(initialValue: cards.firstIndex { $0.id == initialCardID } ?? 0)
    }

    var body: some View {
        let card = cards[selectedIndex]
        if let meaning = meaningsByCardID[card.id] {
            CardMeaningView(
                card: card,
                meaning: meaning,
                context: .library,
                positionText: "\(selectedIndex + 1) of \(cards.count)",
                canMovePrevious: selectedIndex > 0,
                canMoveNext: selectedIndex + 1 < cards.count,
                movePrevious: { selectedIndex -= 1 },
                moveNext: { selectedIndex += 1 }
            )
            .id(card.id)
        } else {
            TarotContentFailureView(message: "Missing meaning for \(card.name).")
        }
    }
}

enum CardMeaningContext: Equatable {
    case reading
    case library
}

struct CardMeaningView: View {
    let card: TarotCardRecord
    let meaning: TarotCardMeaning
    let context: CardMeaningContext
    let positionText: String?
    let canMovePrevious: Bool
    let canMoveNext: Bool
    let movePrevious: (() -> Void)?
    let moveNext: (() -> Void)?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        ZStack {
            CeremonialBackdrop()

            ScrollView {
                VStack(spacing: 18) {
                    heading

                    TarotArtworkView(
                        card: card,
                        artworkDescription: meaning.artworkDescription
                    )
                        .frame(maxWidth: 310)

                    Text(meaning.keywords.map { $0.uppercased() }.joined(separator: "  ·  "))
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .tracking(1.4)
                        .foregroundStyle(CeremonialObsidianTheme.brightGold)
                        .multilineTextAlignment(.center)
                        .accessibilityLabel("Keywords: \(meaning.keywords.joined(separator: ", "))")

                    meaningSection(title: "Meaning", body: meaning.uprightMeaning)
                    meaningSection(title: "In a reading", body: meaning.inAReading)

                    Label("Upright", systemImage: "sparkles")
                        .font(.system(.body, design: .serif, weight: .medium))
                        .foregroundStyle(CeremonialObsidianTheme.brightGold)
                        .padding(.horizontal, 18)
                        .frame(minHeight: 44)
                        .background(Capsule().stroke(CeremonialObsidianTheme.gold.opacity(0.55)))

                    controls
                }
                .frame(maxWidth: 680)
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 30)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
        }
        .foregroundStyle(CeremonialObsidianTheme.parchment)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private var heading: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 10) {
                backButton
                headingText
            }
        } else {
            ZStack(alignment: .leading) {
                backButton
                headingText
                    .padding(.horizontal, context == .library ? 80 : 52)
            }
        }
    }

    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            if context == .library {
                Label("Cards", systemImage: "chevron.left")
                    .frame(minWidth: 44, minHeight: 44)
            } else {
                Image(systemName: "chevron.left")
                    .frame(width: 44, height: 44)
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(CeremonialObsidianTheme.parchment)
        .accessibilityHint(context == .library ? "Returns to the card library" : "Returns to the reading")
    }

    private var headingText: some View {
        VStack(spacing: 5) {
            Text(card.name)
                .font(.system(.largeTitle, design: .serif, weight: .semibold))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            Text(card.arcanaDescription)
                .font(.system(.title3, design: .serif))
                .foregroundStyle(CeremonialObsidianTheme.brightGold)
                .multilineTextAlignment(.center)

            if let positionText {
                Text(positionText)
                    .font(.caption)
                    .foregroundStyle(CeremonialObsidianTheme.secondaryText)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func meaningSection(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 12) {
                Image(systemName: "sparkle")
                    .foregroundStyle(CeremonialObsidianTheme.brightGold)
                    .accessibilityHidden(true)
                Text(title)
                    .font(.system(.title2, design: .serif, weight: .semibold))
                    .accessibilityAddTraits(.isHeader)
                Rectangle()
                    .fill(CeremonialObsidianTheme.gold.opacity(0.4))
                    .frame(height: 1)
            }

            Text(body)
                .font(.body)
                .foregroundStyle(CeremonialObsidianTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, dynamicTypeSize.isAccessibilitySize ? 0 : 40)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var controls: some View {
        if context == .reading {
            Button("Done") {
                dismiss()
            }
            .buttonStyle(CeremonialPrimaryButtonStyle())
            .accessibilityHint("Returns to the exact reading state")
        } else if let movePrevious, let moveNext {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(spacing: 12) {
                    previousButton(action: movePrevious)
                    nextButton(action: moveNext)
                }
            } else {
                HStack(spacing: 12) {
                    previousButton(action: movePrevious)
                    nextButton(action: moveNext)
                }
            }
        }
    }

    private func previousButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label("Previous", systemImage: "chevron.left")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(CeremonialPrimaryButtonStyle())
        .disabled(!canMovePrevious)
        .opacity(canMovePrevious ? 1 : 0.35)
    }

    private func nextButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label("Next", systemImage: "chevron.right")
                .labelStyle(.titleAndIcon)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(CeremonialPrimaryButtonStyle())
        .disabled(!canMoveNext)
        .opacity(canMoveNext ? 1 : 0.35)
    }
}
