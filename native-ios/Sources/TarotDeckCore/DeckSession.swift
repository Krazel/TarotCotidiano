import Foundation

public enum CardOrientation: String, Codable, Equatable, Sendable {
    case upright
}

public struct DrawnCard: Codable, Equatable, Identifiable, Sendable {
    public let id: TarotCardID
    public internal(set) var isRevealed: Bool
    public let orientation: CardOrientation
    public internal(set) var positionIndex: Int

    internal init(
        id: TarotCardID,
        isRevealed: Bool = false,
        orientation: CardOrientation = .upright,
        positionIndex: Int
    ) {
        self.id = id
        self.isRevealed = isRevealed
        self.orientation = orientation
        self.positionIndex = positionIndex
    }

    private enum CodingKeys: String, CodingKey {
        case id, isRevealed, orientation, positionIndex
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(TarotCardID.self, forKey: .id)
        isRevealed = try container.decode(Bool.self, forKey: .isRevealed)
        orientation = try container.decode(CardOrientation.self, forKey: .orientation)
        positionIndex = try container.decodeIfPresent(Int.self, forKey: .positionIndex) ?? -1
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(isRevealed, forKey: .isRevealed)
        try container.encode(orientation, forKey: .orientation)
        try container.encode(positionIndex, forKey: .positionIndex)
    }
}

public struct DeckSession: Codable, Equatable, Identifiable, Sendable {
    public static let currentSchemaVersion = 2

    public let id: UUID
    public let schemaVersion: Int
    public internal(set) var shuffledCardIDs: [TarotCardID]
    public internal(set) var nextDrawIndex: Int
    public internal(set) var drawnCards: [DrawnCard]
    public let createdAt: Date
    public internal(set) var updatedAt: Date

    internal init(
        id: UUID = UUID(),
        shuffledCardIDs: [TarotCardID],
        createdAt: Date
    ) {
        self.id = id
        self.schemaVersion = Self.currentSchemaVersion
        self.shuffledCardIDs = shuffledCardIDs
        self.nextDrawIndex = 0
        self.drawnCards = []
        self.createdAt = createdAt
        self.updatedAt = createdAt
    }

    public var remainingCardCount: Int {
        shuffledCardIDs.count - nextDrawIndex
    }

    public var isExhausted: Bool {
        nextDrawIndex == shuffledCardIDs.count
    }

    public func drawnCard(withID cardID: TarotCardID) -> DrawnCard? {
        drawnCards.first { $0.id == cardID }
    }

    public func drawnCard(atPosition positionIndex: Int) -> DrawnCard? {
        drawnCards.first { $0.positionIndex == positionIndex }
    }

    private enum CodingKeys: String, CodingKey {
        case id, schemaVersion, shuffledCardIDs, nextDrawIndex, drawnCards, createdAt, updatedAt
    }

    /// Migrates historical sequential sessions in memory. Version 1 did not store
    /// positions because every card was dealt left-to-right; that exact state maps
    /// losslessly to positions `0..<drawnCards.count`.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let storedSchemaVersion = try container.decode(Int.self, forKey: .schemaVersion)
        guard storedSchemaVersion == 1 || storedSchemaVersion == Self.currentSchemaVersion else {
            throw DeckSessionValidationError.unsupportedSchemaVersion(storedSchemaVersion)
        }

        id = try container.decode(UUID.self, forKey: .id)
        schemaVersion = Self.currentSchemaVersion
        shuffledCardIDs = try container.decode([TarotCardID].self, forKey: .shuffledCardIDs)
        nextDrawIndex = try container.decode(Int.self, forKey: .nextDrawIndex)
        var restoredCards = try container.decode([DrawnCard].self, forKey: .drawnCards)
        if storedSchemaVersion == 1 {
            for index in restoredCards.indices {
                restoredCards[index].positionIndex = index
            }
        }
        drawnCards = restoredCards
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(schemaVersion, forKey: .schemaVersion)
        try container.encode(shuffledCardIDs, forKey: .shuffledCardIDs)
        try container.encode(nextDrawIndex, forKey: .nextDrawIndex)
        try container.encode(drawnCards, forKey: .drawnCards)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }

    /// Verifies invariants after decoding untrusted local storage and before a
    /// state transition is committed.
    public func validate() throws {
        guard schemaVersion == Self.currentSchemaVersion else {
            throw DeckSessionValidationError.unsupportedSchemaVersion(schemaVersion)
        }

        guard !shuffledCardIDs.isEmpty else {
            throw DeckSessionValidationError.emptyDeck
        }

        for (index, cardID) in shuffledCardIDs.enumerated() {
            guard !cardID.rawValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw DeckSessionValidationError.emptyCardID(index: index)
            }
        }

        guard Set(shuffledCardIDs).count == shuffledCardIDs.count else {
            throw DeckSessionValidationError.duplicateDeckCardIDs
        }

        guard nextDrawIndex >= 0, nextDrawIndex <= shuffledCardIDs.count else {
            throw DeckSessionValidationError.invalidNextDrawIndex(nextDrawIndex)
        }

        guard nextDrawIndex == drawnCards.count else {
            throw DeckSessionValidationError.drawIndexMismatch(
                index: nextDrawIndex,
                drawnCount: drawnCards.count
            )
        }

        let expectedDrawnIDs = Array(shuffledCardIDs.prefix(nextDrawIndex))
        let actualDrawnIDs = drawnCards.map(\.id)
        guard expectedDrawnIDs == actualDrawnIDs else {
            throw DeckSessionValidationError.drawnCardsAreNotDeckPrefix
        }

        guard drawnCards.allSatisfy({ $0.orientation == .upright }) else {
            throw DeckSessionValidationError.unsupportedOrientation
        }

        guard drawnCards.allSatisfy({ $0.positionIndex >= 0 }) else {
            throw DeckSessionValidationError.invalidPositionIndex
        }

        guard Set(drawnCards.map(\.positionIndex)).count == drawnCards.count else {
            throw DeckSessionValidationError.duplicatePositionIndices
        }

        guard updatedAt >= createdAt else {
            throw DeckSessionValidationError.invalidTimestamps
        }
    }
}

public enum DeckSessionValidationError: Error, Equatable, Sendable {
    case unsupportedSchemaVersion(Int)
    case emptyDeck
    case emptyCardID(index: Int)
    case duplicateDeckCardIDs
    case invalidNextDrawIndex(Int)
    case drawIndexMismatch(index: Int, drawnCount: Int)
    case drawnCardsAreNotDeckPrefix
    case unsupportedOrientation
    case invalidPositionIndex
    case duplicatePositionIndices
    case invalidTimestamps
}
