import Foundation

/// A stable identifier supplied to the deck engine by the content layer.
///
/// IDs deliberately contain no artwork or display-copy dependency. A future
/// visual deck can therefore replace every image while saved sessions continue
/// to refer to the same canonical card identities.
public struct TarotCardID: RawRepresentable, Codable, Hashable, Sendable, Comparable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.rawValue = try container.decode(String.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    public static func < (lhs: TarotCardID, rhs: TarotCardID) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

/// Canonical external IDs for the conventional 78-card tarot structure.
///
/// This type owns identity only. English names, artwork, provenance and
/// accessibility descriptions belong to a separate content layer.
public enum StandardTarotDeck {
    public static let cardIDs: [TarotCardID] = {
        let majorArcana = [
            "major-00-the-fool",
            "major-01-the-magician",
            "major-02-the-high-priestess",
            "major-03-the-empress",
            "major-04-the-emperor",
            "major-05-the-hierophant",
            "major-06-the-lovers",
            "major-07-the-chariot",
            "major-08-strength",
            "major-09-the-hermit",
            "major-10-wheel-of-fortune",
            "major-11-justice",
            "major-12-the-hanged-man",
            "major-13-death",
            "major-14-temperance",
            "major-15-the-devil",
            "major-16-the-tower",
            "major-17-the-star",
            "major-18-the-moon",
            "major-19-the-sun",
            "major-20-judgement",
            "major-21-the-world"
        ].map { TarotCardID(rawValue: $0) }

        let suits = ["wands", "cups", "swords", "pentacles"]
        let ranks = [
            "ace", "two", "three", "four", "five", "six", "seven",
            "eight", "nine", "ten", "page", "knight", "queen", "king"
        ]

        let minorArcana = suits.flatMap { suit in
            ranks.map { rank in
                TarotCardID(rawValue: "minor-\(suit)-\(rank)")
            }
        }

        return majorArcana + minorArcana
    }()
}
