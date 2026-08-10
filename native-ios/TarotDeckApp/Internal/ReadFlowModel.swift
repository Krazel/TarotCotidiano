#if DEBUG
import Combine
import Foundation
import TarotDeckCore

enum ReadingLayout: String, Codable, CaseIterable, Equatable, Sendable {
    case oneCard
    case threeCards

    var title: String {
        switch self {
        case .oneCard: return "One Card"
        case .threeCards: return "Three Cards"
        }
    }

    var cardLimit: Int {
        switch self {
        case .oneCard: return 1
        case .threeCards: return 3
        }
    }
}

private struct ReadingContinuityRecord: Codable, Equatable {
    enum Phase: String, Codable {
        case readyToShuffle
        case active
    }

    let phase: Phase
    let layout: ReadingLayout
    let sessionID: UUID?

    var isStructurallyValid: Bool {
        switch phase {
        case .readyToShuffle: return sessionID == nil
        case .active: return sessionID != nil
        }
    }

    static func ready(_ layout: ReadingLayout) -> Self {
        Self(phase: .readyToShuffle, layout: layout, sessionID: nil)
    }

    static func active(sessionID: UUID, layout: ReadingLayout) -> Self {
        Self(phase: .active, layout: layout, sessionID: sessionID)
    }
}

private struct ReadingContinuityStore {
    let fileURL: URL

    func load() throws -> ReadingContinuityRecord? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(ReadingContinuityRecord.self, from: data)
    }

    func save(_ record: ReadingContinuityRecord) throws {
        let directoryURL = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        try encoder.encode(record).write(to: fileURL, options: .atomic)
    }

    func clear() throws {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        try FileManager.default.removeItem(at: fileURL)
    }
}

private enum ReadFlowInvariantError: Error {
    case invalidSession
}

@MainActor
final class ReadFlowModel: ObservableObject {
    enum Surface: Equatable {
        case restoring
        case home
        case layoutChoice
        case table
    }

    private enum RetryAction {
        case restore
        case selectLayout(ReadingLayout)
        case shuffle
        case draw
        case reveal(position: Int)
        case conceal(position: Int)
        case leaveReady
        case replace
        case end
    }

    private struct Issue {
        let title: String
        let message: String
        let retry: RetryAction?
    }

    @Published private(set) var surface: Surface = .restoring
    @Published private(set) var session: DeckSession?
    @Published private(set) var layout: ReadingLayout?
    @Published private(set) var isBusy = false
    @Published var showsReplaceReadingAlert = false
    @Published var showsEndReadingAlert = false
    @Published var showsIssueAlert = false

    private let coordinator: DeckSessionCoordinator<SystemDeckShuffler, JSONDeckSessionStore>
    private let continuityStore: ReadingContinuityStore
    private let knownCardIDs: Set<TarotCardID>
    private let canonicalCardIDs = Set(StandardTarotDeck.cardIDs)
    private var issue: Issue?
    private var hasRestored = false
    private var pendingReplacementLayout: ReadingLayout?

    init(
        coordinator: DeckSessionCoordinator<SystemDeckShuffler, JSONDeckSessionStore>,
        knownCardIDs: Set<TarotCardID> = Set(StandardTarotDeck.cardIDs),
        continuityURL: URL
    ) {
        self.coordinator = coordinator
        self.knownCardIDs = knownCardIDs
        self.continuityStore = ReadingContinuityStore(fileURL: continuityURL)
    }

    var issueTitle: String { issue?.title ?? "Reading unavailable" }
    var issueMessage: String { issue?.message ?? "Please try again." }
    var canRetryIssue: Bool { issue?.retry != nil }
    var showsRestorationProgress: Bool {
        surface == .restoring && (isBusy || !hasRestored)
    }
    var canRetryRestoration: Bool {
        surface == .restoring && !isBusy
    }

    var isReadyToShuffle: Bool {
        surface == .table && session == nil && layout != nil
    }

    var hasActiveReading: Bool {
        guard let session, let layout else { return false }
        return isCanonicalSession(session, for: layout)
    }

    var canDraw: Bool {
        guard let session, let layout, isCanonicalSession(session, for: layout) else {
            return false
        }
        return session.drawnCards.count < layout.cardLimit
    }

    func restoreIfNeeded() async {
        guard !hasRestored, !isBusy else { return }
        hasRestored = true
        isBusy = true
        surface = .restoring
        defer { isBusy = false }

        let restoration: DeckSessionRestoration
        do {
            restoration = try await coordinator.restore()
        } catch {
            presentIssue(
                title: "Reading unavailable",
                message: "We couldn't access the saved reading. Your on-screen state has not been changed.",
                retry: .restore
            )
            return
        }

        let continuity: ReadingContinuityRecord?
        do {
            continuity = try continuityStore.load()
        } catch {
            // Corrupt companion metadata is never kept. A restored session without reliable
            // layout metadata cannot be represented without guessing, so it is cleared next.
            await discardRestoration(
                restoration,
                recoveryMessage: "The saved reading details were damaged and have been safely cleared."
            )
            return
        }

        await reconcile(restoration: restoration, continuity: continuity)
    }

    func retryRestoration() {
        guard canRetryRestoration else { return }
        hasRestored = false
        Task { @MainActor in
            await restoreIfNeeded()
        }
    }

    func requestNewReading() {
        if session != nil && !hasActiveReading {
            discardInvalidPublishedSession()
            return
        }
        if hasActiveReading {
            pendingReplacementLayout = nil
            showsReplaceReadingAlert = true
        } else if surface != .restoring {
            surface = .layoutChoice
        }
    }

    func confirmReplaceReading() {
        let requestedLayout = pendingReplacementLayout
        perform(
            retry: .replace,
            failureMessage: "We couldn't clear the current reading. It remains unchanged."
        ) {
            // The durable session is removed first. UI and companion metadata change only after
            // that commit succeeds, so a failed clear never publishes an empty home.
            try await self.coordinator.clearSession()
            do {
                try self.continuityStore.clear()
            } catch {
                self.resetToHome()
                self.presentIssue(
                    title: "Reading cleanup paused",
                    message: "The reading ended, but its recovery marker still needs to be cleared.",
                    retry: .restore
                )
                return
            }

            if let requestedLayout {
                do {
                    try self.continuityStore.save(.ready(requestedLayout))
                } catch {
                    self.resetToHome()
                    self.presentIssue(
                        title: "Couldn't start reading",
                        message: "The previous reading was cleared, but the new layout couldn't be saved.",
                        retry: .selectLayout(requestedLayout)
                    )
                    return
                }
            }

            self.session = nil
            self.pendingReplacementLayout = nil
            if let requestedLayout {
                self.layout = requestedLayout
                self.surface = .table
            } else {
                self.layout = nil
                self.surface = .layoutChoice
            }
        }
    }

    func cancelReplaceReading() {
        showsReplaceReadingAlert = false
        pendingReplacementLayout = nil
    }

    func cancelLayoutChoice() {
        surface = .home
    }

    func selectLayout(_ selectedLayout: ReadingLayout) {
        guard !isBusy, !hasActiveReading, surface != .restoring else { return }
        do {
            // Ready metadata is the write-ahead record for the shuffle commit.
            try continuityStore.save(.ready(selectedLayout))
            layout = selectedLayout
            session = nil
            surface = .table
        } catch {
            presentIssue(
                title: "Couldn't start reading",
                message: "We couldn't save the selected layout. Nothing was changed.",
                retry: .selectLayout(selectedLayout)
            )
        }
    }

    func requestThreeCardReadingFromLearn() {
        guard !isBusy else { return }
        if session != nil && !hasActiveReading {
            discardInvalidPublishedSession()
            return
        }
        if hasActiveReading, layout == .threeCards {
            surface = .table
        } else if hasActiveReading {
            surface = .table
            pendingReplacementLayout = .threeCards
            showsReplaceReadingAlert = true
        } else if surface != .restoring {
            selectLayout(.threeCards)
        }
    }

    func resumeReading() {
        guard hasActiveReading else { return }
        surface = .table
    }

    func leaveTable() {
        if session != nil && !hasActiveReading {
            discardInvalidPublishedSession()
            return
        }
        if hasActiveReading {
            surface = .home
        } else {
            do {
                try continuityStore.clear()
                layout = nil
                surface = .layoutChoice
            } catch {
                presentIssue(
                    title: "Couldn't leave reading",
                    message: "We couldn't clear the unshuffled layout. Nothing was changed.",
                    retry: .leaveReady
                )
            }
        }
    }

    func shuffleDeck() {
        guard isReadyToShuffle, let layout else { return }
        perform(
            retry: .shuffle,
            failureMessage: "We couldn't finish shuffling. The previous reading state remains available."
        ) {
            // Reassert the write-ahead record before touching the durable deck session.
            try self.continuityStore.save(.ready(layout))

            let started: DeckSession
            if let existing = await self.coordinator.currentSession() {
                if existing.drawnCards.isEmpty,
                   self.isCanonicalSession(existing, for: layout) {
                    started = existing
                } else {
                    try await self.coordinator.clearSession()
                    started = try await self.coordinator.startSession()
                    guard self.isCanonicalSession(started, for: layout) else {
                        throw ReadFlowInvariantError.invalidSession
                    }
                }
            } else {
                started = try await self.coordinator.startSession()
                guard self.isCanonicalSession(started, for: layout) else {
                    throw ReadFlowInvariantError.invalidSession
                }
            }

            // A crash between startSession and this save restores as ready+canonical zero-draw
            // session; reconcile() promotes that exact pair instead of discarding it.
            try self.continuityStore.save(.active(sessionID: started.id, layout: layout))
            self.session = started
        }
    }

    func drawCard() {
        guard let session, let layout else { return }
        guard isCanonicalSession(session, for: layout) else {
            discardInvalidPublishedSession()
            return
        }
        guard session.drawnCards.count < layout.cardLimit else { return }

        perform(retry: .draw, failureMessage: "We couldn't draw the next card. Nothing was changed.") {
            _ = try await self.coordinator.draw()
            guard let updated = await self.coordinator.currentSession(),
                  self.isCanonicalSession(updated, for: layout) else {
                throw ReadFlowInvariantError.invalidSession
            }
            self.session = updated
        }
    }

    func reveal(_ cardID: TarotCardID) {
        guard let session, let layout else { return }
        guard isCanonicalSession(session, for: layout) else {
            discardInvalidPublishedSession()
            return
        }
        guard let position = session.drawnCards.firstIndex(where: { $0.id == cardID }),
              session.drawnCards[position].isRevealed == false else { return }

        perform(
            retry: .reveal(position: position),
            failureMessage: "We couldn't turn over that card. Nothing was changed."
        ) {
            _ = try await self.coordinator.reveal(cardID: cardID)
            guard let updated = await self.coordinator.currentSession(),
                  self.isCanonicalSession(updated, for: layout) else {
                throw ReadFlowInvariantError.invalidSession
            }
            self.session = updated
        }
    }

    func conceal(_ cardID: TarotCardID) {
        guard let session, let layout else { return }
        guard isCanonicalSession(session, for: layout) else {
            discardInvalidPublishedSession()
            return
        }
        guard let position = session.drawnCards.firstIndex(where: { $0.id == cardID }),
              session.drawnCards[position].isRevealed else { return }

        perform(
            retry: .conceal(position: position),
            failureMessage: "We couldn't turn that card face down. Nothing was changed."
        ) {
            _ = try await self.coordinator.conceal(cardID: cardID)
            guard let updated = await self.coordinator.currentSession(),
                  self.isCanonicalSession(updated, for: layout) else {
                throw ReadFlowInvariantError.invalidSession
            }
            self.session = updated
        }
    }

    func canInspect(_ cardID: TarotCardID) -> Bool {
        guard let session, let layout, isCanonicalSession(session, for: layout) else {
            return false
        }
        return session.drawnCard(withID: cardID)?.isRevealed == true
    }

    func requestEndReading() {
        guard layout != nil, surface != .restoring else { return }
        showsEndReadingAlert = true
    }

    func confirmEndReading() {
        perform(
            retry: .end,
            failureMessage: "We couldn't end the reading. It remains unchanged."
        ) {
            try await self.coordinator.clearSession()
            do {
                try self.continuityStore.clear()
                self.resetToHome()
            } catch {
                self.resetToHome()
                self.presentIssue(
                    title: "Reading cleanup paused",
                    message: "The reading ended, but its recovery marker still needs to be cleared.",
                    retry: .restore
                )
            }
        }
    }

    func cancelEndReading() {
        showsEndReadingAlert = false
    }

    func dismissIssue() {
        showsIssueAlert = false
        issue = nil
    }

    func retryIssue() {
        let retry = issue?.retry
        dismissIssue()

        switch retry {
        case .restore:
            hasRestored = false
            Task { @MainActor in await restoreIfNeeded() }
        case .selectLayout(let layout): selectLayout(layout)
        case .shuffle: shuffleDeck()
        case .draw: drawCard()
        case .reveal(let position):
            guard let session, session.drawnCards.indices.contains(position) else { return }
            let cardID = session.drawnCards[position].id
            reveal(cardID)
        case .conceal(let position):
            guard let session, session.drawnCards.indices.contains(position) else { return }
            let cardID = session.drawnCards[position].id
            conceal(cardID)
        case .leaveReady: leaveTable()
        case .replace: confirmReplaceReading()
        case .end: confirmEndReading()
        case nil: break
        }
    }

    private func reconcile(
        restoration: DeckSessionRestoration,
        continuity: ReadingContinuityRecord?
    ) async {
        switch (restoration, continuity) {
        case (.noSavedSession, nil):
            resetToHome()

        case (.noSavedSession, .some(let record))
            where record.isStructurallyValid && record.phase == .readyToShuffle:
            layout = record.layout
            session = nil
            surface = .table

        case (.restored(let restored), .some(let record))
            where record.isStructurallyValid
                && record.phase == .active
                && record.sessionID == restored.id
                && isCanonicalSession(restored, for: record.layout):
            layout = record.layout
            session = restored
            surface = .home

        case (.restored(let restored), .some(let record))
            where record.isStructurallyValid
                && record.phase == .readyToShuffle
                && restored.drawnCards.isEmpty
                && isCanonicalSession(restored, for: record.layout):
            do {
                try continuityStore.save(.active(sessionID: restored.id, layout: record.layout))
                layout = record.layout
                session = restored
                surface = .home
                presentRecovery("Your shuffled reading was recovered safely.")
            } catch {
                presentIssue(
                    title: "Reading recovery paused",
                    message: "We found the saved reading but couldn't finish restoring it.",
                    retry: .restore
                )
            }

        case (.discardedInvalidSession, _):
            do {
                try continuityStore.clear()
                resetToHome()
                presentRecovery("The saved reading was invalid and has been safely cleared.")
            } catch {
                presentIssue(
                    title: "Reading recovery paused",
                    message: "The invalid session was removed, but its recovery marker still needs to be cleared.",
                    retry: .restore
                )
            }

        case (.noSavedSession, .some):
            do {
                try continuityStore.clear()
                resetToHome()
                presentRecovery("The previous reading was incomplete and has been safely cleared.")
            } catch {
                presentIssue(
                    title: "Reading recovery paused",
                    message: "The stale recovery marker couldn't be cleared yet.",
                    retry: .restore
                )
            }

        default:
            await discardRestoration(
                restoration,
                recoveryMessage: "The saved reading couldn't be represented safely and has been cleared."
            )
        }
    }

    private func discardRestoration(
        _ restoration: DeckSessionRestoration,
        recoveryMessage: String
    ) async {
        do {
            // Removing the sidecar first makes any subsequent crash conservative: a surviving
            // session without layout metadata will be discarded rather than guessed.
            try continuityStore.clear()
            if case .restored = restoration {
                try await coordinator.clearSession()
            }
            resetToHome()
            presentRecovery(recoveryMessage)
        } catch {
            presentIssue(
                title: "Reading recovery paused",
                message: "We couldn't finish clearing the unreadable reading. Try again.",
                retry: .restore
            )
        }
    }

    private func discardInvalidPublishedSession() {
        perform(
            retry: .restore,
            failureMessage: "We found an invalid reading but couldn't clear it yet."
        ) {
            try await self.coordinator.clearSession()
            do {
                try self.continuityStore.clear()
                self.resetToHome()
                self.presentRecovery("The invalid reading was safely cleared.")
            } catch {
                self.resetToHome()
                self.presentIssue(
                    title: "Reading cleanup paused",
                    message: "The invalid session was removed, but its recovery marker still needs to be cleared.",
                    retry: .restore
                )
            }
        }
    }

    private func isCanonicalSession(_ candidate: DeckSession, for layout: ReadingLayout) -> Bool {
        do {
            try candidate.validate()
        } catch {
            return false
        }

        guard knownCardIDs == canonicalCardIDs,
              candidate.shuffledCardIDs.count == StandardTarotDeck.cardIDs.count,
              Set(candidate.shuffledCardIDs) == canonicalCardIDs,
              candidate.drawnCards.count <= layout.cardLimit,
              candidate.drawnCards.allSatisfy({ knownCardIDs.contains($0.id) }) else {
            return false
        }
        return true
    }

    private func resetToHome() {
        layout = nil
        session = nil
        pendingReplacementLayout = nil
        surface = .home
    }

    private func presentRecovery(_ message: String) {
        presentIssue(title: "Reading recovered", message: message, retry: nil)
    }

    private func presentIssue(title: String, message: String, retry: RetryAction?) {
        issue = Issue(title: title, message: message, retry: retry)
        showsIssueAlert = true
    }

    private func perform(
        retry: RetryAction,
        failureMessage: String,
        _ operation: @escaping @MainActor () async throws -> Void
    ) {
        guard !isBusy else { return }
        isBusy = true

        Task { @MainActor [weak self] in
            guard let self else { return }
            defer { self.isBusy = false }
            do {
                try await operation()
            } catch is ReadFlowInvariantError {
                self.presentIssue(
                    title: "Reading unavailable",
                    message: "The saved deck no longer matches the complete 78-card deck.",
                    retry: .restore
                )
            } catch {
                self.presentIssue(title: "Couldn't update reading", message: failureMessage, retry: retry)
            }
        }
    }
}
#endif
