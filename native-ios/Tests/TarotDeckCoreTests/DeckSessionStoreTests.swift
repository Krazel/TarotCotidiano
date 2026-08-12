import Foundation
import XCTest
@testable import TarotDeckCore

final class DeckSessionStoreTests: XCTestCase {
    func testCodableRoundTripPreservesCompleteSessionState() throws {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let engine = DeckEngine(shuffler: StoreIdentityShuffler())
        var session = try engine.startSession(at: date)
        let drawn = try engine.draw(from: &session, at: date.addingTimeInterval(1))
        try engine.reveal(
            cardID: drawn.id,
            in: &session,
            at: date.addingTimeInterval(2)
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(session)
        let restored = try JSONDecoder().decode(DeckSession.self, from: data)

        try restored.validate()
        XCTAssertEqual(restored, session)
    }

    func testAtomicJSONStoreSavesReplacesLoadsAndClearsOneSession() throws {
        let directoryURL = makeTemporaryDirectoryURL()
        defer { try? FileManager.default.removeItem(at: directoryURL) }

        let store = JSONDeckSessionStore(
            fileURL: directoryURL.appendingPathComponent("active-session.json")
        )
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let engine = DeckEngine(shuffler: StoreIdentityShuffler())
        var session = try engine.startSession(at: date)

        XCTAssertNil(try store.load())

        try store.save(session)
        XCTAssertEqual(try store.load(), Optional(session))

        let drawn = try engine.draw(from: &session, at: date.addingTimeInterval(1))
        try engine.reveal(
            cardID: drawn.id,
            in: &session,
            at: date.addingTimeInterval(2)
        )
        try store.save(session)
        XCTAssertEqual(try store.load(), Optional(session))

        try store.clear()
        XCTAssertNil(try store.load())
        XCTAssertNoThrow(try store.clear())
    }

    func testSchemaOneSessionMigratesSequentialPositionsWithoutChangingCards() throws {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let engine = DeckEngine(shuffler: StoreIdentityShuffler())
        var session = try engine.startSession(at: date)
        _ = try engine.draw(into: 0, from: &session, at: date.addingTimeInterval(1))
        let second = try engine.draw(into: 1, from: &session, at: date.addingTimeInterval(2))
        _ = try engine.reveal(cardID: second.id, in: &session, at: date.addingTimeInterval(3))

        let encoder = JSONEncoder()
        let encoded = try encoder.encode(session)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        object["schemaVersion"] = 1
        var legacyCards = try XCTUnwrap(object["drawnCards"] as? [[String: Any]])
        for index in legacyCards.indices {
            legacyCards[index].removeValue(forKey: "positionIndex")
        }
        object["drawnCards"] = legacyCards
        let legacyData = try JSONSerialization.data(withJSONObject: object)

        let restored = try JSONDecoder().decode(DeckSession.self, from: legacyData)
        try restored.validate()

        XCTAssertEqual(restored.schemaVersion, DeckSession.currentSchemaVersion)
        XCTAssertEqual(restored.drawnCards.map(\.id), session.drawnCards.map(\.id))
        XCTAssertEqual(restored.drawnCards.map(\.isRevealed), session.drawnCards.map(\.isRevealed))
        XCTAssertEqual(restored.drawnCards.map(\.positionIndex), [0, 1])
        XCTAssertEqual(restored.shuffledCardIDs, session.shuffledCardIDs)
    }

    func testStoreRejectsCorruptJSON() throws {
        let directoryURL = makeTemporaryDirectoryURL()
        defer { try? FileManager.default.removeItem(at: directoryURL) }

        let fileURL = directoryURL.appendingPathComponent("active-session.json")
        try FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )
        try Data("not-json".utf8).write(to: fileURL, options: .atomic)

        let store = JSONDeckSessionStore(fileURL: fileURL)
        XCTAssertThrowsError(try store.load())
    }

    func testStoreRejectsUnsupportedSchemaVersion() throws {
        let directoryURL = makeTemporaryDirectoryURL()
        defer { try? FileManager.default.removeItem(at: directoryURL) }

        let fileURL = directoryURL.appendingPathComponent("active-session.json")
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let engine = DeckEngine(shuffler: StoreIdentityShuffler())
        let session = try engine.startSession(at: date)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let validData = try encoder.encode(session)

        var object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: validData) as? [String: Any]
        )
        object["schemaVersion"] = 999
        let unsupportedData = try JSONSerialization.data(withJSONObject: object)
        try FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )
        try unsupportedData.write(to: fileURL, options: .atomic)

        let store = JSONDeckSessionStore(fileURL: fileURL)
        XCTAssertThrowsError(try store.load()) { error in
            XCTAssertEqual(
                error as? DeckSessionValidationError,
                .unsupportedSchemaVersion(999)
            )
        }
    }

    private func makeTemporaryDirectoryURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("TarotDeckCoreTests")
            .appendingPathComponent(UUID().uuidString)
    }
}

private struct StoreIdentityShuffler: DeckShuffling {
    func shuffled(_ cardIDs: [TarotCardID]) -> [TarotCardID] {
        cardIDs
    }
}
