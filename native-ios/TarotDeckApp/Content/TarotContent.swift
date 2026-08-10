import Foundation

struct TarotCardRecord: Decodable, Identifiable, Hashable {
    let id: String
    let order: Int
    let name: String
    let arcana: String
    let suit: String?
    let rank: String?
    let majorNumber: Int?
    let artworkAsset: String
    let artworkStatus: String
    let accessibilityLabel: String
    let provenanceID: String

    var arcanaDescription: String {
        if let majorNumber {
            return AppLocalization.format("Major Arcana · %@", Self.romanNumeral(majorNumber))
        }

        if let suit {
            return AppLocalization.format("Minor Arcana · %@", Self.localizedSuit(suit))
        }

        return AppLocalization.text("Minor Arcana")
    }

    func localized(name: String, accessibilityLabel: String) -> Self {
        Self(
            id: id,
            order: order,
            name: name,
            arcana: arcana,
            suit: suit,
            rank: rank,
            majorNumber: majorNumber,
            artworkAsset: artworkAsset,
            artworkStatus: artworkStatus,
            accessibilityLabel: accessibilityLabel,
            provenanceID: provenanceID
        )
    }

    private static func localizedSuit(_ suit: String) -> String {
        switch suit {
        case "wands": return AppLocalization.text("Wands")
        case "cups": return AppLocalization.text("Cups")
        case "swords": return AppLocalization.text("Swords")
        case "pentacles": return AppLocalization.text("Pentacles")
        default: return suit.capitalized
        }
    }

    private static func romanNumeral(_ value: Int) -> String {
        if value == 0 { return "0" }

        let symbols = [
            (10, "X"), (9, "IX"), (5, "V"), (4, "IV"), (1, "I")
        ]
        var remainder = value
        var result = ""
        for (number, symbol) in symbols {
            while remainder >= number {
                result += symbol
                remainder -= number
            }
        }
        return result
    }
}

struct TarotCardMeaning: Decodable, Hashable {
    let cardID: String
    let canonicalName: String
    let artworkDescription: String
    let keywords: [String]
    let uprightMeaning: String
    let inAReading: String
}

extension TarotCardMeaning {
    func artworkAccessibilityDescription(for card: TarotCardRecord) -> String {
        let description = artworkDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        if description.isEmpty {
            return AppLocalization.format(
                "Artwork description is not yet available for %@.",
                card.name
            )
        }
        return description
    }
}

struct TarotGuideArticle: Decodable, Identifiable, Hashable {
    struct Section: Decodable, Hashable {
        let heading: String
        let body: String
    }

    let id: String
    let order: Int
    let title: String
    let summary: String
    let sections: [Section]
}

struct TarotContent: Equatable {
    let cards: [TarotCardRecord]
    let meaningsByCardID: [String: TarotCardMeaning]
    let guideTitle: String
    let guideIntroduction: String
    let guideArticles: [TarotGuideArticle]

    func meaning(for card: TarotCardRecord) -> TarotCardMeaning? {
        meaningsByCardID[card.id]
    }

    func card(withID id: String) -> TarotCardRecord? {
        cards.first { $0.id == id }
    }
}

enum TarotContentLoadError: LocalizedError {
    case missingResource(String)
    case invalidDeckCount(Int)
    case invalidMeaningCount(Int)
    case missingArtworkDescriptions
    case invalidGuideCount(Int)
    case mismatchedCardIDs
    case invalidLocalizedContent

    var errorDescription: String? {
        switch self {
        case .missingResource(let name):
            return AppLocalization.format("Missing bundled content resource: %@.", name)
        case .invalidDeckCount(let count):
            return AppLocalization.format("Expected 78 cards, found %d.", count)
        case .invalidMeaningCount(let count):
            return AppLocalization.format("Expected 78 card meanings, found %d.", count)
        case .missingArtworkDescriptions:
            return AppLocalization.text("Every card meaning requires an artwork description.")
        case .invalidGuideCount(let count):
            return AppLocalization.format("Expected 6 guide articles, found %d.", count)
        case .mismatchedCardIDs:
            return AppLocalization.text("The deck and meaning card identifiers do not match.")
        case .invalidLocalizedContent:
            return AppLocalization.text("The selected language content is incomplete or inconsistent.")
        }
    }
}

enum TarotContentLoader {
    private struct DeckDocument: Decodable {
        let cards: [TarotCardRecord]
    }

    private struct MeaningsDocument: Decodable {
        let cards: [TarotCardMeaning]
    }

    private struct GuideDocument: Decodable {
        let title: String
        let introduction: String
        let articles: [TarotGuideArticle]
    }

    private struct CardCopyDocument: Decodable {
        struct Card: Decodable {
            let cardID: String
            let name: String
            let accessibilityLabel: String
        }

        let language: String
        let cards: [Card]
    }

    static func load(bundle: Bundle = .main) throws -> TarotContent {
        let language = AppLanguage(rawValue: AppLocalization.contentLanguageCode(bundle: bundle))
            ?? .english
        return try load(language: language, bundle: bundle)
    }

    static func load(language: AppLanguage, bundle: Bundle = .main) throws -> TarotContent {
        let decoder = JSONDecoder()
        let deck: DeckDocument = try decode("tarot-deck.v1", bundle: bundle, decoder: decoder)
        let meanings: MeaningsDocument = try decode("card-meanings.v1", bundle: bundle, decoder: decoder)
        let guide: GuideDocument = try decode("beginner-guide.v1", bundle: bundle, decoder: decoder)

        guard deck.cards.count == 78 else {
            throw TarotContentLoadError.invalidDeckCount(deck.cards.count)
        }
        guard meanings.cards.count == 78 else {
            throw TarotContentLoadError.invalidMeaningCount(meanings.cards.count)
        }
        guard meanings.cards.allSatisfy({
            !$0.artworkDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }) else {
            throw TarotContentLoadError.missingArtworkDescriptions
        }
        guard guide.articles.count == 6 else {
            throw TarotContentLoadError.invalidGuideCount(guide.articles.count)
        }

        guard Set(deck.cards.map(\.id)).count == deck.cards.count,
              Set(meanings.cards.map(\.cardID)).count == meanings.cards.count else {
            throw TarotContentLoadError.mismatchedCardIDs
        }

        let englishCards = deck.cards.sorted { $0.order < $1.order }
        let orderedArticles = guide.articles.sorted { $0.order < $1.order }
        let meaningMap = Dictionary(uniqueKeysWithValues: meanings.cards.map { ($0.cardID, $0) })
        guard Set(englishCards.map(\.id)) == Set(meaningMap.keys) else {
            throw TarotContentLoadError.mismatchedCardIDs
        }

        let english = TarotContent(
            cards: englishCards,
            meaningsByCardID: meaningMap,
            guideTitle: guide.title,
            guideIntroduction: guide.introduction,
            guideArticles: orderedArticles
        )

        guard language == .spanish else { return english }

        // Spanish editorial content is loaded as one atomic set. If any file is absent or
        // inconsistent, loading fails instead of presenting a mixed-language product.
        do {
            let copy: CardCopyDocument = try decode(
                "card-copy.es.v1",
                bundle: bundle,
                decoder: decoder
            )
            let spanishMeanings: MeaningsDocument = try decode(
                "card-meanings.es.v1",
                bundle: bundle,
                decoder: decoder
            )
            let spanishGuide: GuideDocument = try decode(
                "beginner-guide.es.v1",
                bundle: bundle,
                decoder: decoder
            )

            guard copy.language == "es",
                  copy.cards.count == 78,
                  spanishMeanings.cards.count == 78,
                  spanishGuide.articles.count == 6 else {
                throw TarotContentLoadError.invalidLocalizedContent
            }

            let cardIDs = englishCards.map(\.id)
            guard copy.cards.map(\.cardID) == cardIDs,
                  spanishMeanings.cards.map(\.cardID) == cardIDs,
                  zip(spanishMeanings.cards, copy.cards).allSatisfy({ meaning, cardCopy in
                      meaning.cardID == cardCopy.cardID
                        && meaning.canonicalName == cardCopy.name
                  }),
                  spanishMeanings.cards.allSatisfy({
                      !$0.artworkDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                  }) else {
                throw TarotContentLoadError.invalidLocalizedContent
            }

            let localizedCards = zip(englishCards, copy.cards).map { card, copy in
                card.localized(name: copy.name, accessibilityLabel: copy.accessibilityLabel)
            }
            return TarotContent(
                cards: localizedCards,
                meaningsByCardID: Dictionary(
                    uniqueKeysWithValues: spanishMeanings.cards.map { ($0.cardID, $0) }
                ),
                guideTitle: spanishGuide.title,
                guideIntroduction: spanishGuide.introduction,
                guideArticles: spanishGuide.articles.sorted { $0.order < $1.order }
            )
        } catch {
            throw error
        }
    }

    private static func decode<T: Decodable>(
        _ name: String,
        bundle: Bundle,
        decoder: JSONDecoder
    ) throws -> T {
        guard let url = bundle.url(forResource: name, withExtension: "json") else {
            throw TarotContentLoadError.missingResource("\(name).json")
        }
        return try decoder.decode(T.self, from: Data(contentsOf: url))
    }
}
