import Foundation
import XCTest
@testable import TarotDeckCore

final class DeckEngineTests: XCTestCase {
    private let startDate = Date(timeIntervalSince1970: 1_700_000_000)

    func testInjectedShufflerMakesSessionsDeterministic() throws {
        let engine = DeckEngine(shuffler: ReverseShuffler())

        let first = try engine.startSession(at: startDate)
        let second = try engine.startSession(at: startDate)

        XCTAssertEqual(first.shuffledCardIDs, Array(StandardTarotDeck.cardIDs.reversed()))
        XCTAssertEqual(first.shuffledCardIDs, second.shuffledCardIDs)
        XCTAssertNotEqual(first.id, second.id)
    }

    func testInvalidShuffleOutputIsRejected() {
        let engine = DeckEngine(shuffler: DroppingShuffler())

        XCTAssertThrowsError(try engine.startSession(at: startDate)) { error in
            XCTAssertEqual(error as? DeckEngineError, .invalidShuffleOutput)
        }
    }

    func testDuplicateSourceIDsAreRejectedBeforeShuffle() {
        let engine = DeckEngine(shuffler: IdentityShuffler())
        let duplicateID = TarotCardID(rawValue: "duplicate")

        XCTAssertThrowsError(
            try engine.startSession(
                cardIDs: [duplicateID, duplicateID],
                at: startDate
            )
        ) { error in
            XCTAssertEqual(error as? DeckEngineError, .duplicateCardIDs)
        }
    }

    func testAllSeventyEightCardsDrawExactlyOnceThenDeckIsExhausted() throws {
        let engine = DeckEngine(shuffler: IdentityShuffler())
        var session = try engine.startSession(at: startDate)
        var drawnIDs: [TarotCardID] = []

        for offset in 0..<78 {
            let card = try engine.draw(
                from: &session,
                at: startDate.addingTimeInterval(TimeInterval(offset + 1))
            )
            drawnIDs.append(card.id)
            XCTAssertFalse(card.isRevealed)
            XCTAssertEqual(card.orientation, .upright)
        }

        XCTAssertEqual(drawnIDs, StandardTarotDeck.cardIDs)
        XCTAssertEqual(Set(drawnIDs).count, 78)
        XCTAssertEqual(session.remainingCardCount, 0)
        XCTAssertTrue(session.isExhausted)

        XCTAssertThrowsError(try engine.draw(from: &session)) { error in
            XCTAssertEqual(error as? DeckEngineError, .deckExhausted)
        }
    }

    func testRevealAndConcealAffectOnlyTheSelectedDrawnCard() throws {
        let engine = DeckEngine(shuffler: IdentityShuffler())
        var session = try engine.startSession(at: startDate)
        let first = try engine.draw(from: &session, at: startDate.addingTimeInterval(1))
        let second = try engine.draw(from: &session, at: startDate.addingTimeInterval(2))

        let revealed = try engine.reveal(
            cardID: first.id,
            in: &session,
            at: startDate.addingTimeInterval(3)
        )

        XCTAssertTrue(revealed.isRevealed)
        XCTAssertEqual(revealed.orientation, .upright)
        XCTAssertEqual(session.drawnCard(withID: second.id)?.isRevealed, false)
        XCTAssertEqual(session.nextDrawIndex, 2)

        let concealed = try engine.conceal(
            cardID: first.id,
            in: &session,
            at: startDate.addingTimeInterval(4)
        )

        XCTAssertFalse(concealed.isRevealed)
        XCTAssertEqual(concealed.orientation, .upright)
        XCTAssertEqual(session.nextDrawIndex, 2)
    }

    func testUndrawnCardCannotBeRevealed() throws {
        let engine = DeckEngine(shuffler: IdentityShuffler())
        var session = try engine.startSession(at: startDate)
        let undrawnID = StandardTarotDeck.cardIDs[10]

        XCTAssertThrowsError(
            try engine.reveal(cardID: undrawnID, in: &session)
        ) { error in
            XCTAssertEqual(error as? DeckEngineError, .cardHasNotBeenDrawn(undrawnID))
        }
    }

    func testResetReplacesSessionAndClearsDrawAndRevealState() throws {
        let engine = DeckEngine(shuffler: ReverseShuffler())
        var session = try engine.startSession(at: startDate)
        let originalSessionID = session.id
        let drawn = try engine.draw(from: &session, at: startDate.addingTimeInterval(1))
        try engine.reveal(
            cardID: drawn.id,
            in: &session,
            at: startDate.addingTimeInterval(2)
        )

        try engine.reset(&session, at: startDate.addingTimeInterval(3))

        XCTAssertNotEqual(session.id, originalSessionID)
        XCTAssertEqual(session.shuffledCardIDs.count, 78)
        XCTAssertEqual(Set(session.shuffledCardIDs), Set(StandardTarotDeck.cardIDs))
        XCTAssertEqual(session.nextDrawIndex, 0)
        XCTAssertTrue(session.drawnCards.isEmpty)
        XCTAssertEqual(session.remainingCardCount, 78)
    }
}

private struct IdentityShuffler: DeckShuffling {
    func shuffled(_ cardIDs: [TarotCardID]) -> [TarotCardID] {
        cardIDs
    }
}

private struct ReverseShuffler: DeckShuffling {
    func shuffled(_ cardIDs: [TarotCardID]) -> [TarotCardID] {
        Array(cardIDs.reversed())
    }
}

private struct DroppingShuffler: DeckShuffling {
    func shuffled(_ cardIDs: [TarotCardID]) -> [TarotCardID] {
        Array(cardIDs.dropLast())
    }
}
