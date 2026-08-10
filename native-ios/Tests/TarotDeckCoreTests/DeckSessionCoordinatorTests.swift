import Foundation
import XCTest
@testable import TarotDeckCore

final class DeckSessionCoordinatorTests: XCTestCase {
    private let startDate = Date(timeIntervalSince1970: 1_700_000_000)

    func testConcurrentDrawCommandsAreSerializedWithoutDuplicates() async throws {
        let store = ControlledSessionStore()
        let startDate = self.startDate
        let coordinator = DeckSessionCoordinator(
            shuffler: CoordinatorIdentityShuffler(),
            store: store
        )
        try await coordinator.startSession(at: startDate)

        let attempts = await withTaskGroup(of: DrawAttempt.self) { group in
            for offset in 0..<100 {
                group.addTask {
                    do {
                        let card = try await coordinator.draw(
                            at: startDate.addingTimeInterval(TimeInterval(offset + 1))
                        )
                        return .success(card.id)
                    } catch {
                        return .failure
                    }
                }
            }

            var results: [DrawAttempt] = []
            for await result in group {
                results.append(result)
            }
            return results
        }

        let successfulIDs = attempts.compactMap { attempt -> TarotCardID? in
            guard case let .success(cardID) = attempt else { return nil }
            return cardID
        }
        let failures = attempts.filter {
            if case .failure = $0 { return true }
            return false
        }
        let currentSession = await coordinator.currentSession()
        let finalSession = try XCTUnwrap(currentSession)

        XCTAssertEqual(successfulIDs.count, 78)
        XCTAssertEqual(Set(successfulIDs).count, 78)
        XCTAssertEqual(failures.count, 22)
        XCTAssertEqual(finalSession.nextDrawIndex, 78)
        XCTAssertTrue(finalSession.isExhausted)
        XCTAssertEqual(store.saveCount, 79) // start plus 78 successful draws
    }

    func testRepeatedConcurrentRevealIsIdempotent() async throws {
        let store = ControlledSessionStore()
        let startDate = self.startDate
        let coordinator = DeckSessionCoordinator(
            shuffler: CoordinatorIdentityShuffler(),
            store: store
        )
        try await coordinator.startSession(at: startDate)
        let drawn = try await coordinator.draw(at: startDate.addingTimeInterval(1))

        let revealSucceeded = await withTaskGroup(of: Bool.self) { group in
            for offset in 0..<20 {
                group.addTask {
                    do {
                        let result = try await coordinator.reveal(
                            cardID: drawn.id,
                            at: startDate.addingTimeInterval(TimeInterval(offset + 2))
                        )
                        return result.isRevealed
                    } catch {
                        return false
                    }
                }
            }

            var results: [Bool] = []
            for await result in group {
                results.append(result)
            }
            return results
        }

        let currentSession = await coordinator.currentSession()
        let finalSession = try XCTUnwrap(currentSession)
        XCTAssertEqual(revealSucceeded.count, 20)
        XCTAssertTrue(revealSucceeded.allSatisfy { $0 })
        XCTAssertEqual(finalSession.drawnCards.count, 1)
        XCTAssertEqual(finalSession.drawnCards.first?.isRevealed, true)
        XCTAssertEqual(finalSession.drawnCards.first?.orientation, .upright)
        XCTAssertEqual(store.saveCount, 3) // start, draw, first effective reveal
    }

    func testFailedSaveDoesNotPublishCandidateToMemoryOrStorage() async throws {
        let store = ControlledSessionStore()
        let coordinator = DeckSessionCoordinator(
            shuffler: CoordinatorIdentityShuffler(),
            store: store
        )
        let initialSession = try await coordinator.startSession(at: startDate)
        store.failNextSave()

        do {
            _ = try await coordinator.draw(at: startDate.addingTimeInterval(1))
            XCTFail("Expected the injected store failure")
        } catch {
            XCTAssertEqual(error as? ControlledStoreError, .saveFailed)
        }

        let currentSession = await coordinator.currentSession()
        XCTAssertEqual(currentSession, initialSession)
        XCTAssertEqual(store.storedSession, initialSession)
        XCTAssertEqual(store.saveCount, 1)
    }

    func testFailedResetSavePreservesPreviousMemoryAndStoredSession() async throws {
        let store = ControlledSessionStore()
        let coordinator = DeckSessionCoordinator(
            shuffler: CoordinatorIdentityShuffler(),
            store: store
        )
        try await coordinator.startSession(at: startDate)
        let drawn = try await coordinator.draw(at: startDate.addingTimeInterval(1))
        try await coordinator.reveal(
            cardID: drawn.id,
            at: startDate.addingTimeInterval(2)
        )
        let previousSessionValue = await coordinator.currentSession()
        let previousSession = try XCTUnwrap(previousSessionValue)
        store.failNextSave()

        do {
            _ = try await coordinator.reset(at: startDate.addingTimeInterval(3))
            XCTFail("Expected the injected reset save failure")
        } catch {
            XCTAssertEqual(error as? ControlledStoreError, .saveFailed)
        }

        let currentSession = await coordinator.currentSession()
        XCTAssertEqual(currentSession, previousSession)
        XCTAssertEqual(store.storedSession, previousSession)
        XCTAssertEqual(store.saveCount, 3) // start, draw and reveal only
    }

    func testFailedClearDoesNotPublishEmptyMemoryState() async throws {
        let store = ControlledSessionStore()
        let coordinator = DeckSessionCoordinator(
            shuffler: CoordinatorIdentityShuffler(),
            store: store
        )
        let initialSession = try await coordinator.startSession(at: startDate)
        store.failNextClear()

        do {
            try await coordinator.clearSession()
            XCTFail("Expected the injected clear failure")
        } catch {
            XCTAssertEqual(error as? ControlledStoreError, .clearFailed)
        }

        let currentSession = await coordinator.currentSession()
        XCTAssertEqual(currentSession, initialSession)
        XCTAssertEqual(store.storedSession, initialSession)
    }

    func testUnexpectedLoadFailurePreservesPublishedMemory() async throws {
        let store = ControlledSessionStore()
        let coordinator = DeckSessionCoordinator(
            shuffler: CoordinatorIdentityShuffler(),
            store: store
        )
        let initialSession = try await coordinator.startSession(at: startDate)
        store.failNextLoad()

        do {
            _ = try await coordinator.restore()
            XCTFail("Expected the injected load failure")
        } catch {
            XCTAssertEqual(error as? ControlledStoreError, .loadFailed)
        }

        let currentSession = await coordinator.currentSession()
        XCTAssertEqual(currentSession, initialSession)
        XCTAssertEqual(store.storedSession, initialSession)
    }

    func testMissingFileRestoresSafeEmptyState() async throws {
        let directoryURL = makeTemporaryDirectoryURL()
        defer { try? FileManager.default.removeItem(at: directoryURL) }

        let coordinator = DeckSessionCoordinator(
            shuffler: CoordinatorIdentityShuffler(),
            store: JSONDeckSessionStore(
                fileURL: directoryURL.appendingPathComponent("active-session.json")
            )
        )

        let outcome = try await coordinator.restore()
        let currentSession = await coordinator.currentSession()

        XCTAssertEqual(outcome, .noSavedSession)
        XCTAssertNil(currentSession)
    }

    func testCorruptFileIsDiscardedAndRestoresSafeEmptyState() async throws {
        let directoryURL = makeTemporaryDirectoryURL()
        defer { try? FileManager.default.removeItem(at: directoryURL) }

        let fileURL = directoryURL.appendingPathComponent("active-session.json")
        try FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )
        try Data("not-json".utf8).write(to: fileURL, options: .atomic)
        let coordinator = DeckSessionCoordinator(
            shuffler: CoordinatorIdentityShuffler(),
            store: JSONDeckSessionStore(fileURL: fileURL)
        )

        let outcome = try await coordinator.restore()
        let currentSession = await coordinator.currentSession()

        XCTAssertEqual(outcome, .discardedInvalidSession)
        XCTAssertNil(currentSession)
        XCTAssertFalse(FileManager.default.fileExists(atPath: fileURL.path))
    }

    func testUnsupportedSchemaIsDiscardedAndRestoresSafeEmptyState() async throws {
        let directoryURL = makeTemporaryDirectoryURL()
        defer { try? FileManager.default.removeItem(at: directoryURL) }

        let fileURL = directoryURL.appendingPathComponent("active-session.json")
        let store = JSONDeckSessionStore(fileURL: fileURL)
        let engine = DeckEngine(shuffler: CoordinatorIdentityShuffler())
        let session = try engine.startSession(at: startDate)
        try store.save(session)

        let validData = try Data(contentsOf: fileURL)
        var object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: validData) as? [String: Any]
        )
        object["schemaVersion"] = 999
        try JSONSerialization.data(withJSONObject: object)
            .write(to: fileURL, options: .atomic)

        let coordinator = DeckSessionCoordinator(
            shuffler: CoordinatorIdentityShuffler(),
            store: store
        )
        let outcome = try await coordinator.restore()
        let currentSession = await coordinator.currentSession()

        XCTAssertEqual(outcome, .discardedInvalidSession)
        XCTAssertNil(currentSession)
        XCTAssertFalse(FileManager.default.fileExists(atPath: fileURL.path))
    }

    func testValidSessionRestoresExactly() async throws {
        let store = ControlledSessionStore()
        let firstCoordinator = DeckSessionCoordinator(
            shuffler: CoordinatorIdentityShuffler(),
            store: store
        )
        try await firstCoordinator.startSession(at: startDate)
        let drawn = try await firstCoordinator.draw(at: startDate.addingTimeInterval(1))
        try await firstCoordinator.reveal(
            cardID: drawn.id,
            at: startDate.addingTimeInterval(2)
        )
        let expectedSession = await firstCoordinator.currentSession()
        let expected = try XCTUnwrap(expectedSession)

        let restoredCoordinator = DeckSessionCoordinator(
            shuffler: CoordinatorIdentityShuffler(),
            store: store
        )
        let outcome = try await restoredCoordinator.restore()
        let restoredSession = await restoredCoordinator.currentSession()

        XCTAssertEqual(outcome, .restored(expected))
        XCTAssertEqual(restoredSession, expected)
    }

    private func makeTemporaryDirectoryURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("TarotDeckCoordinatorTests")
            .appendingPathComponent(UUID().uuidString)
    }

}

private enum DrawAttempt: Sendable {
    case success(TarotCardID)
    case failure
}

private enum ControlledStoreError: Error, Equatable, Sendable {
    case saveFailed
    case clearFailed
    case loadFailed
}

private final class ControlledSessionStore: DeckSessionStoring, @unchecked Sendable {
    private let lock = NSLock()
    private var session: DeckSession?
    private var shouldFailNextSave = false
    private var shouldFailNextClear = false
    private var shouldFailNextLoad = false
    private var successfulSaveCount = 0

    var storedSession: DeckSession? {
        withLock { session }
    }

    var saveCount: Int {
        withLock { successfulSaveCount }
    }

    func failNextSave() {
        withLock {
            shouldFailNextSave = true
        }
    }

    func failNextClear() {
        withLock {
            shouldFailNextClear = true
        }
    }

    func failNextLoad() {
        withLock {
            shouldFailNextLoad = true
        }
    }

    func load() throws -> DeckSession? {
        try withLock {
            if shouldFailNextLoad {
                shouldFailNextLoad = false
                throw ControlledStoreError.loadFailed
            }

            if let session {
                try session.validate()
            }
            return session
        }
    }

    func save(_ session: DeckSession) throws {
        try withLock {
            if shouldFailNextSave {
                shouldFailNextSave = false
                throw ControlledStoreError.saveFailed
            }

            try session.validate()
            self.session = session
            successfulSaveCount += 1
        }
    }

    func clear() throws {
        try withLock {
            if shouldFailNextClear {
                shouldFailNextClear = false
                throw ControlledStoreError.clearFailed
            }

            session = nil
        }
    }

    private func withLock<T>(_ operation: () throws -> T) rethrows -> T {
        lock.lock()
        defer { lock.unlock() }
        return try operation()
    }
}

private struct CoordinatorIdentityShuffler: DeckShuffling {
    func shuffled(_ cardIDs: [TarotCardID]) -> [TarotCardID] {
        cardIDs
    }
}
