import Foundation

/// Pure, UI-independent state transitions for a physical-equivalent deck.
public struct DeckEngine<Shuffler: DeckShuffling>: Sendable {
    private let shuffler: Shuffler

    public init(shuffler: Shuffler) {
        self.shuffler = shuffler
    }

    public func startSession(
        cardIDs: [TarotCardID] = StandardTarotDeck.cardIDs,
        at date: Date = Date()
    ) throws -> DeckSession {
        try validateSourceCardIDs(cardIDs)

        let shuffledCardIDs = shuffler.shuffled(cardIDs)
        guard shuffledCardIDs.count == cardIDs.count,
              Set(shuffledCardIDs) == Set(cardIDs) else {
            throw DeckEngineError.invalidShuffleOutput
        }

        let session = DeckSession(
            shuffledCardIDs: shuffledCardIDs,
            createdAt: date
        )
        try session.validate()
        return session
    }

    @discardableResult
    public func draw(
        from session: inout DeckSession,
        at date: Date = Date()
    ) throws -> DrawnCard {
        try session.validate()
        guard !session.isExhausted else {
            throw DeckEngineError.deckExhausted
        }

        var candidate = session
        let cardID = candidate.shuffledCardIDs[candidate.nextDrawIndex]
        let drawnCard = DrawnCard(id: cardID)
        candidate.drawnCards.append(drawnCard)
        candidate.nextDrawIndex += 1
        candidate.updatedAt = normalizedUpdateDate(date, for: candidate)
        try candidate.validate()

        session = candidate
        return drawnCard
    }

    /// Draws a complete spread as one logical transition. Callers either receive
    /// every requested face-down card, in deck order, or the session is unchanged.
    @discardableResult
    public func deal(
        count: Int,
        from session: inout DeckSession,
        at date: Date = Date()
    ) throws -> [DrawnCard] {
        try session.validate()
        guard count > 0 else {
            throw DeckEngineError.invalidDealCount(count)
        }
        guard count <= session.remainingCardCount else {
            throw DeckEngineError.insufficientCardsForDeal(
                requested: count,
                remaining: session.remainingCardCount
            )
        }

        var candidate = session
        var dealtCards: [DrawnCard] = []
        dealtCards.reserveCapacity(count)
        for _ in 0..<count {
            dealtCards.append(try draw(from: &candidate, at: date))
        }

        session = candidate
        return dealtCards
    }

    @discardableResult
    public func reveal(
        cardID: TarotCardID,
        in session: inout DeckSession,
        at date: Date = Date()
    ) throws -> DrawnCard {
        try setRevealState(true, cardID: cardID, in: &session, at: date)
    }

    @discardableResult
    public func conceal(
        cardID: TarotCardID,
        in session: inout DeckSession,
        at date: Date = Date()
    ) throws -> DrawnCard {
        try setRevealState(false, cardID: cardID, in: &session, at: date)
    }

    public func reset(
        _ session: inout DeckSession,
        at date: Date = Date()
    ) throws {
        try session.validate()

        // Build the complete replacement before assigning it so reset is one
        // logical transaction for callers and persistence coordinators.
        let replacement = try startSession(
            cardIDs: session.shuffledCardIDs,
            at: date
        )
        session = replacement
    }

    private func setRevealState(
        _ isRevealed: Bool,
        cardID: TarotCardID,
        in session: inout DeckSession,
        at date: Date
    ) throws -> DrawnCard {
        try session.validate()
        guard let index = session.drawnCards.firstIndex(where: { $0.id == cardID }) else {
            throw DeckEngineError.cardHasNotBeenDrawn(cardID)
        }

        if session.drawnCards[index].isRevealed == isRevealed {
            return session.drawnCards[index]
        }

        var candidate = session
        candidate.drawnCards[index].isRevealed = isRevealed
        candidate.updatedAt = normalizedUpdateDate(date, for: candidate)
        try candidate.validate()

        session = candidate
        return candidate.drawnCards[index]
    }

    private func validateSourceCardIDs(_ cardIDs: [TarotCardID]) throws {
        guard !cardIDs.isEmpty else {
            throw DeckEngineError.emptyDeck
        }

        guard cardIDs.allSatisfy({
            !$0.rawValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }) else {
            throw DeckEngineError.emptyCardID
        }

        guard Set(cardIDs).count == cardIDs.count else {
            throw DeckEngineError.duplicateCardIDs
        }
    }

    private func normalizedUpdateDate(_ date: Date, for session: DeckSession) -> Date {
        max(date, session.updatedAt)
    }
}

public enum DeckEngineError: Error, Equatable, Sendable {
    case emptyDeck
    case emptyCardID
    case duplicateCardIDs
    case invalidShuffleOutput
    case deckExhausted
    case invalidDealCount(Int)
    case insufficientCardsForDeal(requested: Int, remaining: Int)
    case cardHasNotBeenDrawn(TarotCardID)
}
