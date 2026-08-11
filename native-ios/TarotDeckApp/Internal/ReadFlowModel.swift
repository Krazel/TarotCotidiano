import Combine
import Foundation
import TarotDeckCore

enum ReadingLayout: String, Codable, CaseIterable, Equatable, Sendable {
    case oneCard
    case threeCards

    var title: String {
        switch self {
        case .oneCard: return AppLocalization.text("One Card")
        case .threeCards: return AppLocalization.text("Three Cards")
        }
    }

    var cardLimit: Int {
        switch self {
        case .oneCard: return 1
        case .threeCards: return 3
        }
    }
}

enum ThreeCardSpread: String, Codable, CaseIterable, Equatable, Sendable {
    case pastPresentFuture
    case situationChallengeAdvice
    case relationship
    case open
    case freeform

    static var namedCases: [Self] {
        [.pastPresentFuture, .situationChallengeAdvice, .relationship, .open, .freeform]
    }

    var title: String {
        switch self {
        case .pastPresentFuture:
            return AppLocalization.text("Past · Present · Future")
        case .situationChallengeAdvice:
            return AppLocalization.text("Situation · Challenge · Advice")
        case .relationship:
            return AppLocalization.text("You · The other person · Connection")
        case .open:
            return AppLocalization.text("Yes or No")
        case .freeform:
            return AppLocalization.text("Freeform")
        }
    }

    var summary: String {
        switch self {
        case .pastPresentFuture:
            return AppLocalization.text("Origins, the present moment, and a possible direction.")
        case .situationChallengeAdvice:
            return AppLocalization.text("What is happening, what complicates it, and what may help.")
        case .relationship:
            return AppLocalization.text("Two perspectives and the connection between them.")
        case .open:
            return AppLocalization.text("For, against, and destiny.")
        case .freeform:
            return AppLocalization.text("Three cards without assigned positions.")
        }
    }

    func positionTitle(at index: Int) -> String {
        let titles: [String]
        switch self {
        case .pastPresentFuture:
            titles = ["Past", "Present", "Possible future"]
        case .situationChallengeAdvice:
            titles = ["Situation", "Challenge", "Advice"]
        case .relationship:
            titles = ["You", "The other person", "Connection"]
        case .open:
            titles = ["For", "Against", "Destiny"]
        case .freeform:
            titles = ["Card 1", "Card 2", "Card 3"]
        }
        guard titles.indices.contains(index) else { return "" }
        return AppLocalization.text(titles[index])
    }
}

enum ReadingPreset: String, CaseIterable, Equatable, Identifiable, Sendable {
    case oneCard
    case pastPresentFuture
    case situationChallengeAdvice
    case relationship
    case open
    case freeform

    var id: String { rawValue }

    var layout: ReadingLayout {
        self == .oneCard ? .oneCard : .threeCards
    }

    var spread: ThreeCardSpread? {
        switch self {
        case .oneCard: return nil
        case .pastPresentFuture: return .pastPresentFuture
        case .situationChallengeAdvice: return .situationChallengeAdvice
        case .relationship: return .relationship
        case .open: return .open
        case .freeform: return .freeform
        }
    }

    var title: String {
        switch self {
        case .oneCard: return AppLocalization.text("One Card")
        case .pastPresentFuture: return ThreeCardSpread.pastPresentFuture.title
        case .situationChallengeAdvice: return ThreeCardSpread.situationChallengeAdvice.title
        case .relationship: return ThreeCardSpread.relationship.title
        case .open: return ThreeCardSpread.open.title
        case .freeform: return ThreeCardSpread.freeform.title
        }
    }

    var selectorHeading: String {
        layout.title
    }

    var selectorDetail: String {
        switch self {
        case .oneCard: return AppLocalization.text("One clear focus")
        case .open: return ThreeCardSpread.open.summary
        default: return title
        }
    }

    var tutorialArticleID: String {
        switch self {
        case .oneCard: return "one-card-focus"
        case .pastPresentFuture: return "past-present-possible-direction"
        case .situationChallengeAdvice: return "situation-challenge-guidance"
        case .relationship: return "you-other-person-connection"
        case .open: return "yes-or-no-with-context"
        case .freeform: return "freeform-reading"
        }
    }

    static func resolved(layout: ReadingLayout, spread: ThreeCardSpread?) -> Self {
        guard layout == .threeCards else { return .oneCard }
        switch spread ?? .freeform {
        case .pastPresentFuture: return .pastPresentFuture
        case .situationChallengeAdvice: return .situationChallengeAdvice
        case .relationship: return .relationship
        case .open: return .open
        case .freeform: return .freeform
        }
    }
}

private struct ReadingContinuityRecord: Codable, Equatable {
    enum Phase: String, Codable {
        case readyToShuffle
        case active
        case resetting
    }

    let phase: Phase
    let layout: ReadingLayout
    let spread: ThreeCardSpread?
    let sessionID: UUID?

    var resolvedSpread: ThreeCardSpread? {
        layout == .threeCards ? (spread ?? .freeform) : nil
    }

    var isStructurallyValid: Bool {
        guard layout == .threeCards || spread == nil else { return false }
        switch phase {
        case .readyToShuffle: return sessionID == nil
        case .active, .resetting: return sessionID != nil
        }
    }

    static func ready(_ layout: ReadingLayout, spread: ThreeCardSpread?) -> Self {
        Self(phase: .readyToShuffle, layout: layout, spread: spread, sessionID: nil)
    }

    static func active(sessionID: UUID, layout: ReadingLayout, spread: ThreeCardSpread?) -> Self {
        Self(phase: .active, layout: layout, spread: spread, sessionID: sessionID)
    }

    static func resetting(sessionID: UUID, layout: ReadingLayout, spread: ThreeCardSpread?) -> Self {
        Self(phase: .resetting, layout: layout, spread: spread, sessionID: sessionID)
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
    private static let presetPreferenceKey = "tarot.readingPreset.v1"
    private static let fallbackPreset: ReadingPreset = .pastPresentFuture

    enum Surface: Hashable {
        case restoring
        case home
        case table
    }

    private enum RetryAction {
        case restore
        case startPreset(ReadingPreset)
        case learnPreset(ReadingPreset)
        case shuffle
        case draw
        case reveal(position: Int)
        case conceal(position: Int)
        case leave
        case reset
    }

    private struct Issue {
        let title: String
        let message: String
        let retry: RetryAction?
    }

    @Published private(set) var surface: Surface = .restoring
    @Published private(set) var session: DeckSession?
    @Published private(set) var layout: ReadingLayout?
    @Published private(set) var spread: ThreeCardSpread?
    @Published private(set) var selectedPreset: ReadingPreset = .pastPresentFuture
    @Published private(set) var isBusy = false
    @Published var showsIssueAlert = false

    private let coordinator: DeckSessionCoordinator<SystemDeckShuffler, JSONDeckSessionStore>
    private let continuityStore: ReadingContinuityStore
    private let preferences: UserDefaults
    private let knownCardIDs: Set<TarotCardID>
    private let canonicalCardIDs = Set(StandardTarotDeck.cardIDs)
    private var homePresetPreference: ReadingPreset
    private var issue: Issue?
    private var hasRestored = false

    init(
        coordinator: DeckSessionCoordinator<SystemDeckShuffler, JSONDeckSessionStore>,
        knownCardIDs: Set<TarotCardID> = Set(StandardTarotDeck.cardIDs),
        continuityURL: URL,
        preferences: UserDefaults = .standard
    ) {
        let homePresetPreference = Self.loadHomePresetPreference(from: preferences)
        self.coordinator = coordinator
        self.knownCardIDs = knownCardIDs
        self.continuityStore = ReadingContinuityStore(fileURL: continuityURL)
        self.preferences = preferences
        self.homePresetPreference = homePresetPreference
        self.selectedPreset = homePresetPreference
    }

    var issueTitle: String { issue?.title ?? AppLocalization.text("Reading unavailable") }
    var issueMessage: String { issue?.message ?? AppLocalization.text("Please try again.") }
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

    var readingTitle: String {
        guard let layout else { return selectedPreset.title }
        return ReadingPreset.resolved(layout: layout, spread: spread).title
    }

    var canPrepareAnotherReading: Bool {
        guard let session, let layout, isCanonicalSession(session, for: layout),
              session.drawnCards.count == layout.cardLimit else { return false }
        return session.drawnCards.allSatisfy(\.isRevealed)
    }

    func selectPreset(_ preset: ReadingPreset) {
        guard !isBusy, surface == .home, layout == nil, session == nil else { return }
        preferences.set(preset.rawValue, forKey: Self.presetPreferenceKey)
        homePresetPreference = preset
        selectedPreset = preset
    }

    func startSelectedPreset() {
        startPreset(selectedPreset)
    }

    func requestReadingFromLearn(_ preset: ReadingPreset) {
        guard !isBusy, surface != .restoring else { return }
        if session != nil {
            surface = .table
        } else if layout == nil {
            selectedPreset = preset
            surface = .home
        } else {
            prepareLearnPreset(preset)
        }
    }

    private func prepareLearnPreset(_ preset: ReadingPreset) {
        perform(
            retry: .learnPreset(preset),
            failureMessage: "We couldn't save the selected reading. Nothing was changed."
        ) {
            try self.continuityStore.save(.ready(preset.layout, spread: preset.spread))
            self.selectedPreset = preset
            self.layout = preset.layout
            self.spread = preset.spread
            self.session = nil
            self.surface = .table
        }
    }

    func leaveTable() {
        guard surface == .table, layout != nil else { return }
        if session != nil && !hasActiveReading {
            discardInvalidPublishedSession()
            return
        }

        perform(
            retry: .leave,
            failureMessage: "We couldn't leave the reading. It remains unchanged."
        ) {
            if self.session != nil {
                try await self.coordinator.clearSession()
            }
            do {
                try self.continuityStore.clear()
                self.resetToHome()
            } catch {
                // The deck session is already durably absent. A stale companion marker is safe:
                // restoration will clear it rather than reconstructing a reading without cards.
                self.resetToHome()
                self.presentIssue(
                    title: "Reading cleanup paused",
                    message: "The reading ended, but its recovery marker still needs to be cleared.",
                    retry: .restore
                )
            }
        }
    }

    func resetReading() {
        guard surface == .table, let layout else { return }
        let currentSpread = spread
        let currentSession = session

        perform(
            retry: .reset,
            failureMessage: "We couldn't reset the reading. It remains unchanged."
        ) {
            if let currentSession {
                try self.continuityStore.save(
                    .resetting(
                        sessionID: currentSession.id,
                        layout: layout,
                        spread: currentSpread
                    )
                )
                do {
                    try await self.coordinator.clearSession()
                } catch {
                    // Roll back the intent marker when possible. If that write also fails,
                    // reconcile() treats resetting+session as the original exact table.
                    try? self.continuityStore.save(
                        .active(
                            sessionID: currentSession.id,
                            layout: layout,
                            spread: currentSpread
                        )
                    )
                    throw error
                }
            }

            do {
                try self.continuityStore.save(.ready(layout, spread: currentSpread))
            } catch where currentSession != nil {
                // The durable reset intent plus an absent deck session is recoverable as ready.
                // Publish that truthful result; the next shuffle reasserts the ready marker.
            }
            self.session = nil
            self.selectedPreset = ReadingPreset.resolved(layout: layout, spread: currentSpread)
            self.surface = .table
        }
    }

    private func startPreset(_ preset: ReadingPreset) {
        guard !isBusy, surface == .home, layout == nil, session == nil else { return }
        perform(
            retry: .startPreset(preset),
            failureMessage: "We couldn't save the selected reading. Nothing was changed."
        ) {
            try self.continuityStore.save(.ready(preset.layout, spread: preset.spread))
            self.selectedPreset = preset
            self.layout = preset.layout
            self.spread = preset.spread
            self.session = nil
            self.surface = .table
        }
    }

    func shuffleDeck() {
        guard isReadyToShuffle, let layout else { return }
        perform(
            retry: .shuffle,
            failureMessage: "We couldn't finish shuffling. The previous reading state remains available."
        ) {
            // Reassert the write-ahead record before touching the durable deck session.
            try self.continuityStore.save(.ready(layout, spread: self.spread))

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
            try self.continuityStore.save(
                .active(sessionID: started.id, layout: layout, spread: self.spread)
            )
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
        case .startPreset(let preset): startPreset(preset)
        case .learnPreset(let preset): prepareLearnPreset(preset)
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
        case .leave: leaveTable()
        case .reset: resetReading()
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
            spread = record.resolvedSpread
            selectedPreset = ReadingPreset.resolved(layout: record.layout, spread: record.resolvedSpread)
            session = nil
            surface = .table

        case (.noSavedSession, .some(let record))
            where record.isStructurallyValid && record.phase == .resetting:
            do {
                try continuityStore.save(.ready(record.layout, spread: record.resolvedSpread))
                layout = record.layout
                spread = record.resolvedSpread
                selectedPreset = ReadingPreset.resolved(
                    layout: record.layout,
                    spread: record.resolvedSpread
                )
                session = nil
                surface = .table
                presentRecovery("Your reset reading was recovered safely.")
            } catch {
                presentIssue(
                    title: "Reading recovery paused",
                    message: "The reset reading is safe, but its recovery marker couldn't be updated.",
                    retry: .restore
                )
            }

        case (.restored(let restored), .some(let record))
            where record.isStructurallyValid
                && record.phase == .active
                && record.sessionID == restored.id
                && isCanonicalSession(restored, for: record.layout):
            layout = record.layout
            spread = record.resolvedSpread
            selectedPreset = ReadingPreset.resolved(layout: record.layout, spread: record.resolvedSpread)
            session = restored
            surface = .table

        case (.restored(let restored), .some(let record))
            where record.isStructurallyValid
                && record.phase == .resetting
                && record.sessionID == restored.id
                && isCanonicalSession(restored, for: record.layout):
            do {
                try continuityStore.save(
                    .active(
                        sessionID: restored.id,
                        layout: record.layout,
                        spread: record.resolvedSpread
                    )
                )
                layout = record.layout
                spread = record.resolvedSpread
                selectedPreset = ReadingPreset.resolved(
                    layout: record.layout,
                    spread: record.resolvedSpread
                )
                session = restored
                surface = .table
                presentRecovery("The previous reading was restored because reset did not finish.")
            } catch {
                presentIssue(
                    title: "Reading recovery paused",
                    message: "We found the saved reading but couldn't finish restoring it.",
                    retry: .restore
                )
            }

        case (.restored(let restored), .some(let record))
            where record.isStructurallyValid
                && record.phase == .readyToShuffle
                && restored.drawnCards.isEmpty
                && isCanonicalSession(restored, for: record.layout):
            do {
                try continuityStore.save(
                    .active(
                        sessionID: restored.id,
                        layout: record.layout,
                        spread: record.resolvedSpread
                    )
                )
                layout = record.layout
                spread = record.resolvedSpread
                selectedPreset = ReadingPreset.resolved(
                    layout: record.layout,
                    spread: record.resolvedSpread
                )
                session = restored
                surface = .table
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
        selectedPreset = homePresetPreference
        layout = nil
        spread = nil
        session = nil
        surface = .home
    }

    private static func loadHomePresetPreference(from preferences: UserDefaults) -> ReadingPreset {
        guard let storedValue = preferences.object(forKey: presetPreferenceKey) else {
            return fallbackPreset
        }
        guard let rawValue = storedValue as? String,
              let preset = ReadingPreset(rawValue: rawValue) else {
            preferences.removeObject(forKey: presetPreferenceKey)
            return fallbackPreset
        }
        return preset
    }

    private func presentRecovery(_ message: String) {
        presentIssue(title: "Reading recovered", message: message, retry: nil)
    }

    private func presentIssue(title: String, message: String, retry: RetryAction?) {
        issue = Issue(
            title: AppLocalization.text(title),
            message: AppLocalization.text(message),
            retry: retry
        )
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
