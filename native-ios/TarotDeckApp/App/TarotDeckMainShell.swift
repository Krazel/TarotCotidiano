import SwiftUI

enum TarotPrimaryDestination: Hashable {
    case read
    case learn
    case cards
}

struct TarotDeckMainShell<ReadContent: View>: View {
    let content: TarotContent
    let startThreeCardReading: () -> Void
    let readContent: (@escaping (String) -> Void) -> ReadContent

    @State private var selectedDestination: TarotPrimaryDestination = .read
    @State private var readingMeaningCardID: String?

    init(
        content: TarotContent,
        startThreeCardReading: @escaping () -> Void,
        @ViewBuilder readContent: @escaping (@escaping (String) -> Void) -> ReadContent
    ) {
        self.content = content
        self.startThreeCardReading = startThreeCardReading
        self.readContent = readContent
    }

    var body: some View {
        TabView(selection: $selectedDestination) {
            NavigationStack {
                readContent { cardID in
                    guard content.meaningsByCardID[cardID] != nil else { return }
                    readingMeaningCardID = cardID
                }
            }
            .tag(TarotPrimaryDestination.read)
            .tabItem {
                Label("Read", systemImage: "moon.stars")
            }

            NavigationStack {
                LearnIndexView(
                    content: content,
                    startThreeCardReading: {
                        startThreeCardReading()
                        selectedDestination = .read
                    }
                )
            }
            .tag(TarotPrimaryDestination.learn)
            .tabItem {
                Label("Learn", systemImage: "sparkles")
            }

            NavigationStack {
                CardsLibraryView(content: content)
            }
            .tag(TarotPrimaryDestination.cards)
            .tabItem {
                Label("Cards", systemImage: "rectangle.on.rectangle")
            }
        }
        .tint(CeremonialObsidianTheme.brightGold)
        .toolbarBackground(CeremonialObsidianTheme.background, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .sheet(
            isPresented: Binding(
                get: { readingMeaningCardID != nil },
                set: { if !$0 { readingMeaningCardID = nil } }
            )
        ) {
            if let cardID = readingMeaningCardID,
               let card = content.card(withID: cardID),
               let meaning = content.meaning(for: card) {
                NavigationStack {
                    CardMeaningView(
                        card: card,
                        meaning: meaning,
                        context: .reading,
                        positionText: nil,
                        canMovePrevious: false,
                        canMoveNext: false,
                        movePrevious: nil,
                        moveNext: nil
                    )
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct TarotContentFailureView: View {
    let message: String

    var body: some View {
        ZStack {
            CeremonialBackdrop()
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                    .foregroundStyle(CeremonialObsidianTheme.brightGold)
                Text("Content Integrity Error")
                    .font(.system(.title2, design: .serif, weight: .semibold))
                Text(message)
                    .font(.body)
                    .foregroundStyle(CeremonialObsidianTheme.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(28)
        }
        .foregroundStyle(CeremonialObsidianTheme.parchment)
    }
}
