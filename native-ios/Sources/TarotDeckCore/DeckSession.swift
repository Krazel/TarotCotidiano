import Foundation

public enum CardOrientation: String, Codable, Equatable, Sendable {
    case upright
}

public struct DrawnCard: Codable, Equatable, Identifiable, Sendable {
    public let id: TarotCardID
    public internal(set) var isRevealed: Bool
    public let orientation: CardOrientation

    internal init(
        id: TarotCardID,
        isRevealed: Bool = false,
        orientation: CardOrientation = .upright
    ) {
        self.id = id
        self.isRevealed = isRevealed
        self.orientation = orientation
    }
}

public struct DeckSession: Codable, Equatable, Identifiable, Sendable {
    public static let currentSchemaVersion = 1

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
    case invalidTimestamps
}
