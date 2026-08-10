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
            return "Major Arcana · \(Self.romanNumeral(majorNumber))"
        }

        if let suit {
            return "Minor Arcana · \(suit.capitalized)"
        }

        return "Minor Arcana"
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
            return "Artwork description is not yet available for \(card.name)."
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

    var errorDescription: String? {
        switch self {
        case .missingResource(let name):
            return "Missing bundled content resource: \(name)."
        case .invalidDeckCount(let count):
            return "Expected 78 cards, found \(count)."
        case .invalidMeaningCount(let count):
            return "Expected 78 card meanings, found \(count)."
        case .missingArtworkDescriptions:
            return "Every card meaning requires an artwork description."
        case .invalidGuideCount(let count):
            return "Expected 6 guide articles, found \(count)."
        case .mismatchedCardIDs:
            return "The deck and meaning card identifiers do not match."
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

    static func load(bundle: Bundle = .main) throws -> TarotContent {
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

        let orderedCards = deck.cards.sorted { $0.order < $1.order }
        let orderedArticles = guide.articles.sorted { $0.order < $1.order }
        let meaningMap = Dictionary(uniqueKeysWithValues: meanings.cards.map { ($0.cardID, $0) })
        guard Set(orderedCards.map(\.id)) == Set(meaningMap.keys) else {
            throw TarotContentLoadError.mismatchedCardIDs
        }

        return TarotContent(
            cards: orderedCards,
            meaningsByCardID: meaningMap,
            guideTitle: guide.title,
            guideIntroduction: guide.introduction,
            guideArticles: orderedArticles
        )
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
