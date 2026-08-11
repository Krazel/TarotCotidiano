import SwiftUI

enum TarotCardFilter: String, CaseIterable, Hashable {
    case favorites = "Favorites"
    case all = "All"
    case major = "Major"
    case wands = "Wands"
    case cups = "Cups"
    case swords = "Swords"
    case pentacles = "Pentacles"

    var localizedTitle: String {
        AppLocalization.text(rawValue)
    }

    func includes(_ card: TarotCardRecord, favoriteIDs: Set<String>) -> Bool {
        switch self {
        case .favorites: return favoriteIDs.contains(card.id)
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
    @ObservedObject var favoriteStore: FavoriteCardsStore

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
        content.cards.filter {
            selectedFilter.includes($0, favoriteIDs: favoriteStore.cardIDs)
        }
    }

    var body: some View {
        ZStack {
            CeremonialBackdrop()

            ScrollView {
                LazyVStack(spacing: 20) {
                    titleBlock
                    filters

                    if selectedFilter == .favorites && filteredCards.isEmpty {
                        favoritesEmptyState
                    } else {
                        LazyVGrid(columns: columns, spacing: 22) {
                            ForEach(filteredCards.indices, id: \.self) { index in
                                let card = filteredCards[index]
                                NavigationLink {
                                    CardLibraryDetailView(
                                        cards: filteredCards,
                                        initialCardID: card.id,
                                        meaningsByCardID: content.meaningsByCardID,
                                        favoriteStore: favoriteStore,
                                        dismissWhenRemovedFromFavorites: selectedFilter == .favorites
                                    )
                                } label: {
                                    libraryCard(
                                        card,
                                        position: index + 1,
                                        total: filteredCards.count
                                    )
                                }
                                .buttonStyle(.plain)
                            }
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

    private var favoritesEmptyState: some View {
        VStack(spacing: 18) {
            Image(systemName: "heart")
                .font(.system(size: 72, weight: .light))
                .foregroundStyle(CeremonialObsidianTheme.brightGold)
                .accessibilityHidden(true)

            Text("No favorites yet")
                .font(.system(.title, design: .serif, weight: .semibold))
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            Text("Open a card and tap the heart to save it here.")
                .font(.system(.title3, design: .serif))
                .foregroundStyle(CeremonialObsidianTheme.brightGold)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: 390, minHeight: 420)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
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
                        HStack(spacing: 7) {
                            if filter == .favorites {
                                Image(systemName: "heart")
                                    .accessibilityHidden(true)
                            }
                            Text(filter.localizedTitle)
                        }
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
                    .accessibilityLabel(filter.localizedTitle)
                    .accessibilityValue(
                        filter == selectedFilter ? AppLocalization.text("Selected filter") : ""
                    )
                    .accessibilityAddTraits(filter == selectedFilter ? .isSelected : [])
                }
            }
            .padding(.horizontal, 1)
        }
        .scrollIndicators(.hidden)
        .accessibilityLabel("Card filters")
    }

    private func libraryCard(_ card: TarotCardRecord, position: Int, total: Int) -> some View {
        let meaning = content.meaning(for: card)
        let isFavorite = favoriteStore.contains(card.id)
        let artwork = TarotArtworkView(
            card: card,
            artworkDescription: meaning?.artworkDescription
        )
        return VStack(spacing: 8) {
            artwork
                .overlay(alignment: .topTrailing) {
                    if isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.system(.body, weight: .semibold))
                            .foregroundStyle(CeremonialObsidianTheme.brightGold)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(CeremonialObsidianTheme.background.opacity(0.88)))
                            .overlay(Circle().stroke(CeremonialObsidianTheme.gold.opacity(0.75)))
                            .padding(7)
                            .accessibilityHidden(true)
                    }
                }

            Text(card.name)
                .font(.system(.caption, design: .serif, weight: .medium))
                .foregroundStyle(CeremonialObsidianTheme.parchment)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(minHeight: 44, alignment: .top)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(card.name), \(position) \(AppLocalization.text("of")) \(total), "
                + AppLocalization.text(isFavorite ? "Favorite" : "Not favorite")
        )
        .accessibilityValue(artwork.accessibilitySummary)
        .accessibilityHint("Opens the upright meaning")
    }
}

struct CardLibraryDetailView: View {
    let meaningsByCardID: [String: TarotCardMeaning]
    @ObservedObject var favoriteStore: FavoriteCardsStore
    let dismissWhenRemovedFromFavorites: Bool

    @State private var cards: [TarotCardRecord]
    @State private var selectedIndex: Int
    @Environment(\.dismiss) private var dismiss

    init(
        cards: [TarotCardRecord],
        initialCardID: String,
        meaningsByCardID: [String: TarotCardMeaning],
        favoriteStore: FavoriteCardsStore,
        dismissWhenRemovedFromFavorites: Bool
    ) {
        self.meaningsByCardID = meaningsByCardID
        self.favoriteStore = favoriteStore
        self.dismissWhenRemovedFromFavorites = dismissWhenRemovedFromFavorites
        _cards = State(initialValue: cards)
        _selectedIndex = State(initialValue: cards.firstIndex { $0.id == initialCardID } ?? 0)
    }

    var body: some View {
        let card = cards[selectedIndex]
        if let meaning = meaningsByCardID[card.id] {
            CardMeaningView(
                card: card,
                meaning: meaning,
                favoriteStore: favoriteStore,
                context: .library,
                positionText: AppLocalization.format("%d of %d", selectedIndex + 1, cards.count),
                canMovePrevious: selectedIndex > 0,
                canMoveNext: selectedIndex + 1 < cards.count,
                movePrevious: { selectedIndex -= 1 },
                moveNext: { selectedIndex += 1 }
            )
            .id(card.id)
            .onChange(of: favoriteStore.cardIDs) { favoriteIDs in
                if dismissWhenRemovedFromFavorites,
                   !favoriteIDs.contains(card.id) {
                    dismiss()
                }
            }
        } else {
            TarotContentFailureView(
                message: AppLocalization.format("Missing meaning for %@.", card.name)
            )
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
    @ObservedObject var favoriteStore: FavoriteCardsStore
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
                        .accessibilityLabel(
                            AppLocalization.format(
                                "Keywords: %@",
                                meaning.keywords.joined(separator: ", ")
                            )
                        )

                    meaningSection(
                        title: AppLocalization.text("Meaning"),
                        body: meaning.uprightMeaning
                    )
                    meaningSection(title: AppLocalization.text("In a reading"), body: meaning.inAReading)

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
        .alert(
            AppLocalization.text("Favorites Unavailable"),
            isPresented: $favoriteStore.showsIssueAlert
        ) {
            Button("OK") {
                favoriteStore.dismissIssue()
            }
        } message: {
            Text(favoriteStore.issueMessage)
        }
    }

    @ViewBuilder
    private var heading: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    backButton
                    Spacer()
                    favoriteButton
                }
                headingText
            }
        } else {
            ZStack(alignment: .leading) {
                HStack {
                    backButton
                    Spacer()
                    favoriteButton
                }
                headingText
                    .padding(.horizontal, context == .library ? 80 : 52)
            }
        }
    }

    private var favoriteButton: some View {
        let isFavorite = favoriteStore.contains(card.id)
        return Button {
            let wasFavorite = isFavorite
            var didPersist = false
            withAnimation(CeremonialMotion.screen) {
                didPersist = favoriteStore.toggle(card.id)
            }
            guard didPersist else { return }
            CeremonialHaptics.favoriteChanged(isFavorite: !wasFavorite)
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.system(.title3, weight: .semibold))
                .foregroundStyle(CeremonialObsidianTheme.brightGold)
                .frame(width: 44, height: 44)
                .background(Circle().fill(CeremonialObsidianTheme.cardSurface))
                .overlay {
                    Circle().stroke(
                        isFavorite
                            ? CeremonialObsidianTheme.brightGold
                            : CeremonialObsidianTheme.cardEdge,
                        lineWidth: isFavorite ? 1.5 : 1
                    )
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            AppLocalization.format(
                isFavorite ? "Remove %@ from Favorites" : "Add %@ to Favorites",
                card.name
            )
        )
        .accessibilityValue(AppLocalization.text(isFavorite ? "Favorite" : "Not favorite"))
        .accessibilityAddTraits(isFavorite ? .isSelected : [])
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
        .accessibilityHint(
            AppLocalization.text(
                context == .library ? "Returns to the card library" : "Returns to the reading"
            )
        )
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
