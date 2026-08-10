import Foundation

public enum DeckSessionRestoration: Equatable, Sendable {
    case noSavedSession
    case restored(DeckSession)
    case discardedInvalidSession
}

public enum DeckSessionCoordinatorError: Error, Equatable, Sendable {
    case noActiveSession
}

/// Serializes session commands and makes persistence the commit boundary.
///
/// Every mutating command is first applied to a local copy. The copy replaces
/// the actor's published state only after the complete session has been saved.
/// A failed save therefore leaves both the previous in-memory state and, for an
/// atomic store, the previous on-disk state available for retry.
public actor DeckSessionCoordinator<
    Shuffler: DeckShuffling,
    Store: DeckSessionStoring
> {
    private let engine: DeckEngine<Shuffler>
    private let store: Store
    private var activeSession: DeckSession?

    public init(shuffler: Shuffler, store: Store) {
        self.engine = DeckEngine(shuffler: shuffler)
        self.store = store
        self.activeSession = nil
    }

    public func currentSession() -> DeckSession? {
        activeSession
    }

    /// Restores a valid session, returns an empty state when no file exists, and
    /// removes storage that is provably corrupt or uses an unsupported schema.
    /// Unexpected I/O errors are rethrown and do not replace the current memory.
    public func restore() throws -> DeckSessionRestoration {
        do {
            guard let restoredSession = try store.load() else {
                activeSession = nil
                return .noSavedSession
            }

            try restoredSession.validate()
            activeSession = restoredSession
            return .restored(restoredSession)
        } catch {
            guard Self.isRecoverableInvalidStorage(error) else {
                throw error
            }

            // Clearing is the durable transition. If it fails, the actor keeps
            // its previously published memory and propagates the storage error.
            try store.clear()
            activeSession = nil
            return .discardedInvalidSession
        }
    }

    @discardableResult
    public func startSession(
        cardIDs: [TarotCardID] = StandardTarotDeck.cardIDs,
        at date: Date = Date()
    ) throws -> DeckSession {
        let candidate = try engine.startSession(cardIDs: cardIDs, at: date)
        try store.save(candidate)
        activeSession = candidate
        return candidate
    }

    @discardableResult
    public func draw(at date: Date = Date()) throws -> DrawnCard {
        var candidate = try activeSessionCopy()
        let drawnCard = try engine.draw(from: &candidate, at: date)
        try commit(candidate)
        return drawnCard
    }

    @discardableResult
    public func reveal(
        cardID: TarotCardID,
        at date: Date = Date()
    ) throws -> DrawnCard {
        let previous = try activeSessionCopy()
        var candidate = previous
        let drawnCard = try engine.reveal(cardID: cardID, in: &candidate, at: date)

        if candidate != previous {
            try commit(candidate)
        }
        return drawnCard
    }

    @discardableResult
    public func conceal(
        cardID: TarotCardID,
        at date: Date = Date()
    ) throws -> DrawnCard {
        let previous = try activeSessionCopy()
        var candidate = previous
        let drawnCard = try engine.conceal(cardID: cardID, in: &candidate, at: date)

        if candidate != previous {
            try commit(candidate)
        }
        return drawnCard
    }

    @discardableResult
    public func reset(at date: Date = Date()) throws -> DeckSession {
        var candidate = try activeSessionCopy()
        try engine.reset(&candidate, at: date)
        try commit(candidate)
        return candidate
    }

    public func clearSession() throws {
        try store.clear()
        activeSession = nil
    }

    private func activeSessionCopy() throws -> DeckSession {
        guard let activeSession else {
            throw DeckSessionCoordinatorError.noActiveSession
        }
        return activeSession
    }

    private func commit(_ candidate: DeckSession) throws {
        try candidate.validate()
        try store.save(candidate)
        activeSession = candidate
    }

    private static func isRecoverableInvalidStorage(_ error: Error) -> Bool {
        error is DecodingError || error is DeckSessionValidationError
    }
}
