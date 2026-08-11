import SwiftUI
import UIKit

enum TarotPrimaryDestination: Hashable {
    case read
    case learn
    case cards
}

enum LearnRoute: Hashable {
    case tutorials
    case article(String)
}

struct TarotDeckMainShell<ReadContent: View>: View {
    let content: TarotContent
    @ObservedObject var languageStore: AppLanguageStore
    @ObservedObject var favoriteStore: FavoriteCardsStore
    let startReading: (String) -> Void
    let readContent: (
        @escaping (String) -> Void,
        @escaping (String?) -> Void
    ) -> ReadContent

    @State private var selectedDestination: TarotPrimaryDestination = .read
    @State private var readingMeaningCardID: String?
    @State private var learnPath: [LearnRoute] = []

    init(
        content: TarotContent,
        languageStore: AppLanguageStore,
        favoriteStore: FavoriteCardsStore,
        startReading: @escaping (String) -> Void,
        @ViewBuilder readContent: @escaping (
            @escaping (String) -> Void,
            @escaping (String?) -> Void
        ) -> ReadContent
    ) {
        self.content = content
        self.languageStore = languageStore
        self.favoriteStore = favoriteStore
        self.startReading = startReading
        self.readContent = readContent
        Self.configureTabBarAppearance()
    }

    var body: some View {
        TabView(selection: $selectedDestination) {
            NavigationStack {
                readContent(
                    { cardID in
                        guard content.meaningsByCardID[cardID] != nil else { return }
                        readingMeaningCardID = cardID
                    },
                    { articleID in
                        openReadingTutorial(articleID: articleID)
                    }
                )
            }
            .tag(TarotPrimaryDestination.read)
            .tabItem {
                Label("Read", systemImage: "moon.stars")
            }

            NavigationStack(path: $learnPath) {
                LearnIndexView(
                    content: content,
                    openArticle: { articleID in learnPath.append(.article(articleID)) },
                    openTutorials: { learnPath.append(.tutorials) }
                )
                .navigationDestination(for: LearnRoute.self) { route in
                    learnDestination(for: route)
                }
            }
            .id("learn-\(languageStore.language.rawValue)")
            .tag(TarotPrimaryDestination.learn)
            .tabItem {
                Label("Learn", systemImage: "sparkles")
            }

            NavigationStack {
                CardsLibraryView(content: content, favoriteStore: favoriteStore)
            }
            .id("cards-\(languageStore.language.rawValue)")
            .tag(TarotPrimaryDestination.cards)
            .tabItem {
                Label("Cards", systemImage: "rectangle.on.rectangle")
            }
        }
        .tint(CeremonialObsidianTheme.brightGold)
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
                        favoriteStore: favoriteStore,
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
        .preferredColorScheme(.dark)
        .environment(\.locale, languageStore.language.locale)
    }

    @ViewBuilder
    private func learnDestination(for route: LearnRoute) -> some View {
        switch route {
        case .tutorials:
            ReadingTutorialsView(
                articles: content.tutorialArticles,
                openArticle: { articleID in learnPath.append(.article(articleID)) }
            )
        case .article(let articleID):
            if let article = content.guideArticles.first(where: { $0.id == articleID }) {
                LearnArticleView(
                    article: article,
                    startReading: { presetID in
                        startReading(presetID)
                        selectedDestination = .read
                    }
                )
            } else {
                TarotContentFailureView(
                    message: AppLocalization.text("The selected tutorial is unavailable.")
                )
            }
        }
    }

    private func openReadingTutorial(articleID: String?) {
        if let articleID,
           content.tutorialArticles.contains(where: { $0.id == articleID }) {
            learnPath = [.tutorials, .article(articleID)]
        } else {
            learnPath = [.tutorials]
        }
        selectedDestination = .learn
    }

    private static func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemThinMaterialDark)
        appearance.backgroundColor = UIColor(CeremonialObsidianTheme.tabBarTint)
        appearance.shadowColor = UIColor(CeremonialObsidianTheme.brightGold.opacity(0.14))
        UITabBar.appearance().isTranslucent = true
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
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
