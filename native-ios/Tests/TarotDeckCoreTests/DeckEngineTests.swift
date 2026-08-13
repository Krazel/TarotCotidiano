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

    func testDealCommitsRequestedCardsTogetherInDeckOrder() throws {
        let engine = DeckEngine(shuffler: IdentityShuffler())
        var session = try engine.startSession(at: startDate)

        let dealt = try engine.deal(
            count: 3,
            from: &session,
            at: startDate.addingTimeInterval(1)
        )

        XCTAssertEqual(dealt.map(\.id), Array(StandardTarotDeck.cardIDs.prefix(3)))
        XCTAssertTrue(dealt.allSatisfy { !$0.isRevealed && $0.orientation == .upright })
        XCTAssertEqual(session.drawnCards, dealt)
        XCTAssertEqual(session.nextDrawIndex, 3)
    }

    func testDealSupportsEverySpreadSizeFromOneThroughTwelve() throws {
        let engine = DeckEngine(shuffler: IdentityShuffler())
        for count in 1...12 {
            var session = try engine.startSession(at: startDate)
            let dealt = try engine.deal(count: count, from: &session)
            XCTAssertEqual(dealt.map(\.id), Array(StandardTarotDeck.cardIDs.prefix(count)))
            XCTAssertEqual(session.drawnCards.count, count)
            XCTAssertEqual(session.drawnCards.map(\.positionIndex), Array(0..<count))
            XCTAssertEqual(session.nextDrawIndex, count)
        }
    }

    func testCardsCanBePlacedIntoArbitraryOpenPositionsInDeckOrder() throws {
        let engine = DeckEngine(shuffler: IdentityShuffler())
        var session = try engine.startSession(at: startDate)
        let requestedPositions = [2, 0, 1]

        for (drawIndex, positionIndex) in requestedPositions.enumerated() {
            let card = try engine.draw(
                into: positionIndex,
                from: &session,
                at: startDate.addingTimeInterval(TimeInterval(drawIndex + 1))
            )
            XCTAssertEqual(card.id, StandardTarotDeck.cardIDs[drawIndex])
            XCTAssertEqual(card.positionIndex, positionIndex)
            XCTAssertEqual(session.drawnCard(atPosition: positionIndex), card)
        }

        XCTAssertEqual(session.drawnCards.map(\.positionIndex), requestedPositions)
        XCTAssertEqual(session.drawnCards.map(\.id), Array(StandardTarotDeck.cardIDs.prefix(3)))
    }

    func testOneThroughTwelvePositionsCanBeFilledWithoutDuplicates() throws {
        let engine = DeckEngine(shuffler: IdentityShuffler())

        for count in 1...12 {
            var session = try engine.startSession(at: startDate)
            let positions = Array((0..<count).reversed())
            for positionIndex in positions {
                _ = try engine.draw(into: positionIndex, from: &session)
            }
            XCTAssertEqual(session.drawnCards.map(\.positionIndex), positions)
            XCTAssertEqual(Set(session.drawnCards.map(\.id)).count, count)
            XCTAssertNoThrow(try session.validate())
        }
    }

    func testInvalidOrOccupiedPositionLeavesSessionUnchanged() throws {
        let engine = DeckEngine(shuffler: IdentityShuffler())
        var session = try engine.startSession(at: startDate)
        let original = session

        XCTAssertThrowsError(try engine.draw(into: -1, from: &session)) { error in
            XCTAssertEqual(error as? DeckEngineError, .invalidPositionIndex(-1))
        }
        XCTAssertEqual(session, original)

        _ = try engine.draw(into: 2, from: &session)
        let placed = session
        XCTAssertThrowsError(try engine.draw(into: 2, from: &session)) { error in
            XCTAssertEqual(error as? DeckEngineError, .positionAlreadyOccupied(2))
        }
        XCTAssertEqual(session, placed)
    }

    func testInvalidDealLeavesSessionUnchanged() throws {
        let engine = DeckEngine(shuffler: IdentityShuffler())
        var session = try engine.startSession(at: startDate)
        let original = session

        XCTAssertThrowsError(try engine.deal(count: 0, from: &session)) { error in
            XCTAssertEqual(error as? DeckEngineError, .invalidDealCount(0))
        }
        XCTAssertEqual(session, original)

        XCTAssertThrowsError(try engine.deal(count: 79, from: &session)) { error in
            XCTAssertEqual(
                error as? DeckEngineError,
                .insufficientCardsForDeal(requested: 79, remaining: 78)
            )
        }
        XCTAssertEqual(session, original)
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

    func testDefaultDrawUsesFirstCanonicalEmptyPosition() throws {
        let engine = DeckEngine(shuffler: IdentityShuffler())
        var session = try engine.startSession(at: startDate)
        _ = try engine.draw(into: 2, from: &session, at: startDate.addingTimeInterval(1))

        let firstGap = try engine.draw(from: &session, at: startDate.addingTimeInterval(2))
        let secondGap = try engine.draw(from: &session, at: startDate.addingTimeInterval(3))

        XCTAssertEqual(firstGap.positionIndex, 0)
        XCTAssertEqual(secondGap.positionIndex, 1)
        XCTAssertEqual(session.drawnCards.map(\.positionIndex), [2, 0, 1])
    }

    func testReshuffleRemainingPreservesDrawnPrefixPositionsRevealAndSessionIdentity() throws {
        let engine = DeckEngine(shuffler: ReverseShuffler())
        var session = try engine.startSession(at: startDate)
        _ = try engine.draw(into: 2, from: &session, at: startDate.addingTimeInterval(1))
        let second = try engine.draw(into: 0, from: &session, at: startDate.addingTimeInterval(2))
        _ = try engine.reveal(
            cardID: second.id,
            in: &session,
            at: startDate.addingTimeInterval(3)
        )
        let before = session

        try engine.reshuffleRemaining(
            in: &session,
            at: startDate.addingTimeInterval(4)
        )

        XCTAssertEqual(session.id, before.id)
        XCTAssertEqual(session.createdAt, before.createdAt)
        XCTAssertEqual(session.nextDrawIndex, before.nextDrawIndex)
        XCTAssertEqual(session.drawnCards, before.drawnCards)
        XCTAssertEqual(
            Array(session.shuffledCardIDs.prefix(before.nextDrawIndex)),
            Array(before.shuffledCardIDs.prefix(before.nextDrawIndex))
        )
        XCTAssertEqual(
            Array(session.shuffledCardIDs.dropFirst(before.nextDrawIndex)),
            Array(before.shuffledCardIDs.dropFirst(before.nextDrawIndex).reversed())
        )
        XCTAssertNoThrow(try session.validate())
    }

    func testInvalidRemainingShuffleLeavesSessionUnchanged() throws {
        let engine = DeckEngine(shuffler: DroppingShuffler())
        var session = DeckSession(
            shuffledCardIDs: StandardTarotDeck.cardIDs,
            createdAt: startDate
        )
        let original = session

        XCTAssertThrowsError(try engine.reshuffleRemaining(in: &session)) { error in
            XCTAssertEqual(error as? DeckEngineError, .invalidShuffleOutput)
        }
        XCTAssertEqual(session, original)
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
