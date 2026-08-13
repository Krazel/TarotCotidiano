import Combine
import Foundation
import TarotDeckCore

enum ReadingLayout: String, Codable, CaseIterable, Equatable, Sendable {
    case oneCard
    case threeCards
    case sixCards
    case customCards

    var title: String {
        switch self {
        case .oneCard: return AppLocalization.text("One Card")
        case .threeCards: return AppLocalization.text("Three Cards")
        case .sixCards: return AppLocalization.text("Six-Card Guidance")
        case .customCards: return AppLocalization.text("Custom Spread")
        }
    }

    var cardLimit: Int {
        switch self {
        case .oneCard: return 1
        case .threeCards: return 3
        case .sixCards: return 6
        case .customCards: return 0
        }
    }
}

enum ReadingSelection: Equatable, Sendable {
    case preset(ReadingPreset)
    case custom(UUID)
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
        AppLocalization.text(canonicalTitleKey)
    }

    var canonicalTitleKey: String {
        switch self {
        case .pastPresentFuture: return "Past · Present · Future"
        case .situationChallengeAdvice: return "Situation · Challenge · Advice"
        case .relationship: return "You · The other person · Connection"
        case .open: return "Yes or No"
        case .freeform: return "Freeform"
        }
    }

    var summary: String {
        switch self {
        case .pastPresentFuture:
            return AppLocalization.text("Origins, the present moment, and a possible direction.")
        case .situationChallengeAdvice:
            return AppLocalization.text("What is happening, the challenge to face, and what the cards advise next.")
        case .relationship:
            return AppLocalization.text("Two perspectives and the connection between them.")
        case .open:
            return AppLocalization.text("For, against, and destiny.")
        case .freeform:
            return AppLocalization.text("Three cards without assigned positions.")
        }
    }

    func positionTitle(at index: Int) -> String {
        guard canonicalPositionKeys.indices.contains(index) else { return "" }
        return AppLocalization.text(canonicalPositionKeys[index])
    }

    var canonicalPositionKeys: [String] {
        switch self {
        case .pastPresentFuture:
            return ["Past", "Present", "Possible future"]
        case .situationChallengeAdvice:
            return ["Situation", "Challenge", "Advice"]
        case .relationship:
            return ["You", "The other person", "Connection"]
        case .open:
            return ["For", "Against", "Destiny"]
        case .freeform:
            return ["Card 1", "Card 2", "Card 3"]
        }
    }
}

enum ReadingPreset: String, CaseIterable, Equatable, Identifiable, Sendable {
    case oneCard
    case pastPresentFuture
    case situationChallengeAdvice
    case relationship
    case open
    case freeform
    case sixCardGuidance

    var id: String { rawValue }

    var layout: ReadingLayout {
        switch self {
        case .oneCard: return .oneCard
        case .sixCardGuidance: return .sixCards
        default: return .threeCards
        }
    }

    var spread: ThreeCardSpread? {
        switch self {
        case .oneCard, .sixCardGuidance: return nil
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
        case .sixCardGuidance: return AppLocalization.text("Six-Card Guidance")
        }
    }

    var selectorHeading: String {
        layout.title
    }

    var selectorDetail: String {
        switch self {
        case .oneCard: return AppLocalization.text("One clear focus")
        case .sixCardGuidance: return AppLocalization.text("A practical six-position overview")
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
        case .sixCardGuidance: return "six-card-guidance"
        }
    }

    static func resolved(layout: ReadingLayout, spread: ThreeCardSpread?) -> Self {
        if layout == .oneCard { return .oneCard }
        if layout == .sixCards { return .sixCardGuidance }
        guard layout == .threeCards else { return .oneCard }
        switch spread ?? .freeform {
        case .pastPresentFuture: return .pastPresentFuture
        case .situationChallengeAdvice: return .situationChallengeAdvice
        case .relationship: return .relationship
        case .open: return .open
        case .freeform: return .freeform
        }
    }


    var builtInSnapshot: SpreadDefinitionSnapshot {
        let labels: [String]
        let points: [SpreadPoint]
        let canonicalName: String
        switch self {
        case .oneCard:
            canonicalName = "One Card"
            labels = ["Card 1"]
            points = [SpreadPoint(x: 0.5, y: 0.5)]
        case .sixCardGuidance:
            canonicalName = "Six-Card Guidance"
            labels = ["Self", "Support", "Issue", "Deeper issue", "Action", "Possible outcome"]
            points = [
                SpreadPoint(x: 0.18, y: 0.30), SpreadPoint(x: 0.50, y: 0.30),
                SpreadPoint(x: 0.82, y: 0.30), SpreadPoint(x: 0.18, y: 0.72),
                SpreadPoint(x: 0.50, y: 0.72), SpreadPoint(x: 0.82, y: 0.72)
            ]
        default:
            canonicalName = spread?.canonicalTitleKey ?? "Freeform"
            labels = spread?.canonicalPositionKeys ?? ["Card 1", "Card 2", "Card 3"]
            points = [SpreadPoint(x: 0.18, y: 0.5), SpreadPoint(x: 0.5, y: 0.5), SpreadPoint(x: 0.82, y: 0.5)]
        }
        let positions = labels.indices.map { index in
            SpreadPosition(order: index, label: labels[index], point: points[index])
        }
        return SpreadDefinitionSnapshot(sourceID: nil, name: canonicalName, positions: positions)
    }
}

private struct ReadingContinuityRecord: Codable, Equatable {
    enum Phase: String, Codable {
        case readyToShuffle
        case active
        case shuffling
        case reshuffling
        case resetting
    }

    let phase: Phase
    let layout: ReadingLayout
    let spread: ThreeCardSpread?
    let sessionID: UUID?
    let definition: SpreadDefinitionSnapshot?

    private enum CodingKeys: String, CodingKey {
        case phase, layout, spread, sessionID, definition
    }

    init(
        phase: Phase,
        layout: ReadingLayout,
        spread: ThreeCardSpread?,
        sessionID: UUID?,
        definition: SpreadDefinitionSnapshot?
    ) {
        self.phase = phase
        self.layout = layout
        self.spread = spread
        self.sessionID = sessionID
        self.definition = definition
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        phase = try container.decode(Phase.self, forKey: .phase)
        layout = try container.decode(ReadingLayout.self, forKey: .layout)
        spread = try container.decodeIfPresent(ThreeCardSpread.self, forKey: .spread)
        sessionID = try container.decodeIfPresent(UUID.self, forKey: .sessionID)
        definition = try container.decodeIfPresent(SpreadDefinitionSnapshot.self, forKey: .definition)
    }

    var resolvedSpread: ThreeCardSpread? {
        layout == .threeCards ? (spread ?? .freeform) : nil
    }

    var isStructurallyValid: Bool {
        guard layout == .threeCards || spread == nil else { return false }
        if let definition {
            guard (try? definition.validate()) != nil else { return false }
            switch layout {
            case .oneCard where definition.cardCount != 1: return false
            case .threeCards where definition.cardCount != 3: return false
            case .sixCards where definition.cardCount != 6: return false
            case .customCards where !(1...12).contains(definition.cardCount): return false
            default: break
            }
        } else if layout == .customCards {
            return false
        }
        switch phase {
        case .readyToShuffle: return sessionID == nil
        case .active, .shuffling, .reshuffling, .resetting: return sessionID != nil
        }
    }

    static func ready(_ layout: ReadingLayout, spread: ThreeCardSpread?, definition: SpreadDefinitionSnapshot? = nil) -> Self {
        Self(phase: .readyToShuffle, layout: layout, spread: spread, sessionID: nil, definition: definition)
    }

    static func active(sessionID: UUID, layout: ReadingLayout, spread: ThreeCardSpread?, definition: SpreadDefinitionSnapshot? = nil) -> Self {
        Self(phase: .active, layout: layout, spread: spread, sessionID: sessionID, definition: definition)
    }

    static func shuffling(sessionID: UUID, layout: ReadingLayout, spread: ThreeCardSpread?, definition: SpreadDefinitionSnapshot? = nil) -> Self {
        Self(phase: .shuffling, layout: layout, spread: spread, sessionID: sessionID, definition: definition)
    }

    static func reshuffling(sessionID: UUID, layout: ReadingLayout, spread: ThreeCardSpread?, definition: SpreadDefinitionSnapshot? = nil) -> Self {
        Self(phase: .reshuffling, layout: layout, spread: spread, sessionID: sessionID, definition: definition)
    }

    static func resetting(sessionID: UUID, layout: ReadingLayout, spread: ThreeCardSpread?, definition: SpreadDefinitionSnapshot? = nil) -> Self {
        Self(phase: .resetting, layout: layout, spread: spread, sessionID: sessionID, definition: definition)
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
    private static let selectionKindPreferenceKey = "tarot.readingSelection.kind.v2"
    private static let customSelectionPreferenceKey = "tarot.readingSelection.customID.v2"
    private static let fallbackPreset: ReadingPreset = .pastPresentFuture

    enum Surface: Hashable {
        case restoring
        case home
        case table
    }

    private enum RetryAction {
        case restore
        case startPreset(ReadingPreset)
        case startCustom(UUID)
        case learnPreset(ReadingPreset)
        case shuffle
        case placeNext
        case place(slot: Int)
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
    @Published private(set) var activeDefinition: SpreadDefinitionSnapshot?
    @Published private(set) var selectedPreset: ReadingPreset = .pastPresentFuture
    @Published private(set) var selectedCustomSpreadID: UUID?
    @Published private(set) var customSpreads: [SpreadDefinition] = []
    @Published private(set) var recoveredCustomDraft: SpreadDefinition?
    @Published private(set) var customLibraryAvailable = true
    @Published private(set) var customLibraryRequestCount = 0
    @Published private(set) var isBusy = false
    @Published private(set) var shufflePresentationGeneration = 0
    @Published var showsIssueAlert = false

    private let coordinator: DeckSessionCoordinator<SystemDeckShuffler, JSONDeckSessionStore>
    private let continuityStore: ReadingContinuityStore
    private let customSpreadStore: JSONCustomSpreadStore
    private let preferences: UserDefaults
    private let knownCardIDs: Set<TarotCardID>
    private let canonicalCardIDs = Set(StandardTarotDeck.cardIDs)
    private var homePresetPreference: ReadingPreset
    private var homeCustomSpreadPreference: UUID?
    private var issue: Issue?
    private var hasRestored = false

    init(
        coordinator: DeckSessionCoordinator<SystemDeckShuffler, JSONDeckSessionStore>,
        knownCardIDs: Set<TarotCardID> = Set(StandardTarotDeck.cardIDs),
        continuityURL: URL,
        customSpreadStore: JSONCustomSpreadStore,
        preferences: UserDefaults = .standard
    ) {
        let homePresetPreference = Self.loadHomePresetPreference(from: preferences)
        self.coordinator = coordinator
        self.knownCardIDs = knownCardIDs
        self.continuityStore = ReadingContinuityStore(fileURL: continuityURL)
        self.customSpreadStore = customSpreadStore
        self.preferences = preferences
        self.homePresetPreference = homePresetPreference
        let customSelection = Self.loadCustomSelectionPreference(from: preferences)
        let loadedLibrary: CustomSpreadLibrary
        do {
            loadedLibrary = try customSpreadStore.loadLibrary()
        } catch {
            loadedLibrary = CustomSpreadLibrary()
            self.customLibraryAvailable = false
        }
        self.customSpreads = loadedLibrary.spreads.sorted { $0.updatedAt > $1.updatedAt }
        do {
            self.recoveredCustomDraft = try customSpreadStore.loadDraft()
        } catch {
            self.recoveredCustomDraft = nil
            self.customLibraryAvailable = false
        }
        if let customSelection,
           loadedLibrary.spreads.contains(where: { $0.id == customSelection }) {
            self.homeCustomSpreadPreference = customSelection
            self.selectedCustomSpreadID = customSelection
        } else {
            self.homeCustomSpreadPreference = nil
            self.selectedPreset = homePresetPreference
        }
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

    var canShuffleDeck: Bool {
        guard surface == .table, let layout else { return false }
        if session == nil { return true }
        guard let session, isCanonicalSession(session, for: layout) else { return false }
        return !session.isExhausted
    }

    var hasActiveReading: Bool {
        guard let session, let layout else { return false }
        return isCanonicalSession(session, for: layout)
    }

    func canPlaceCard(at slotIndex: Int) -> Bool {
        guard let session, let layout, isCanonicalSession(session, for: layout) else {
            return false
        }
        return (0..<activeCardCount).contains(slotIndex)
            && session.drawnCards.count < activeCardCount
            && session.drawnCard(atPosition: slotIndex) == nil
    }

    func placedCard(at slotIndex: Int) -> DrawnCard? {
        session?.drawnCard(atPosition: slotIndex)
    }

    var hasEmptyPositions: Bool {
        guard let session, let layout, isCanonicalSession(session, for: layout) else {
            return false
        }
        return session.drawnCards.count < activeCardCount
    }

    func restoreIfNeeded() async {
        guard !hasRestored, !isBusy else { return }
        hasRestored = true
        isBusy = true
        surface = .restoring
        defer {
            isBusy = false
            // A brand-new table can become ready while restoration still owns the
            // busy lock. Re-check after releasing it; an active restored session
            // is ineligible and therefore never replays a shuffle.
            Task { @MainActor [weak self] in
                await Task.yield()
                self?.beginAutomaticShuffleIfNeeded()
            }
        }

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
        if layout == .customCards, let activeDefinition { return activeDefinition.name }
        if let selectedCustomSpread { return selectedCustomSpread.name }
        guard let layout else { return selectedPreset.title }
        return ReadingPreset.resolved(layout: layout, spread: spread).title
    }

    var selectedReadingTitle: String {
        selectedCustomSpread?.name ?? selectedPreset.title
    }

    var selectedReadingCardCount: Int {
        selectedCustomSpread?.cardCount ?? selectedPreset.layout.cardLimit
    }

    var selectedReading: ReadingSelection {
        if let selectedCustomSpreadID { return .custom(selectedCustomSpreadID) }
        return .preset(selectedPreset)
    }

    var selectedCustomSpread: SpreadDefinition? {
        guard let selectedCustomSpreadID else { return nil }
        return customSpreads.first { $0.id == selectedCustomSpreadID }
    }

    var activeCardCount: Int {
        activeDefinition?.cardCount ?? layout?.cardLimit ?? 0
    }

    var activeTutorialArticleID: String? {
        if layout == .customCards { return "create-custom-spread" }
        guard let layout else { return nil }
        return ReadingPreset.resolved(layout: layout, spread: spread).tutorialArticleID
    }

    func activePositionTitle(at index: Int) -> String {
        guard let layout else { return AppLocalization.format("Card %d", index + 1) }
        if layout == .customCards {
            let positions = activeDefinition?.positions.sorted { $0.order < $1.order } ?? []
            let label = positions.indices.contains(index)
                ? positions[index].label.trimmingCharacters(in: .whitespacesAndNewlines)
                : ""
            return label.isEmpty ? AppLocalization.format("Card %d", index + 1) : label
        }
        if layout == .oneCard { return AppLocalization.text("Card 1") }
        if layout == .sixCards {
            let keys = ["Self", "Support", "Issue", "Deeper issue", "Action", "Possible outcome"]
            return keys.indices.contains(index) ? AppLocalization.text(keys[index]) : ""
        }
        return (spread ?? .freeform).positionTitle(at: index)
    }

    var canPrepareAnotherReading: Bool {
        guard let session, let layout, isCanonicalSession(session, for: layout),
              session.drawnCards.count == activeCardCount else { return false }
        return session.drawnCards.allSatisfy(\.isRevealed)
    }

    func selectPreset(_ preset: ReadingPreset) {
        guard !isBusy, surface == .home, layout == nil, session == nil else { return }
        preferences.set(preset.rawValue, forKey: Self.presetPreferenceKey)
        homePresetPreference = preset
        selectedPreset = preset
        selectedCustomSpreadID = nil
        homeCustomSpreadPreference = nil
        preferences.set("preset", forKey: Self.selectionKindPreferenceKey)
        preferences.removeObject(forKey: Self.customSelectionPreferenceKey)
    }

    func selectCustomSpread(_ definition: SpreadDefinition) {
        guard !isBusy, surface == .home, layout == nil, session == nil,
              customSpreads.contains(where: { $0.id == definition.id }) else { return }
        selectedCustomSpreadID = definition.id
        homeCustomSpreadPreference = definition.id
        preferences.set("custom", forKey: Self.selectionKindPreferenceKey)
        preferences.set(definition.id.uuidString, forKey: Self.customSelectionPreferenceKey)
    }

    func makeCustomDraft() -> SpreadDefinition {
        let draft = SpreadDefinition(
            name: AppLocalization.text("My Spread"),
            positions: SpreadDefinition.arrangedPositions(count: 3)
        )
        try? customSpreadStore.saveDraft(draft)
        recoveredCustomDraft = draft
        return draft
    }

    func beginEditingCustomSpread(_ id: UUID) -> SpreadDefinition? {
        guard let spread = customSpreads.first(where: { $0.id == id }) else { return nil }
        try? customSpreadStore.saveDraft(spread)
        recoveredCustomDraft = spread
        return spread
    }

    func updateCustomDraft(_ draft: SpreadDefinition) {
        guard (try? draft.validate()) != nil else { return }
        do {
            try customSpreadStore.saveDraft(draft)
            recoveredCustomDraft = draft
        } catch {
            presentIssue(
                title: "Custom spread unavailable",
                message: "We couldn't save this draft. Your library was not changed.",
                retry: nil
            )
        }
    }

    @discardableResult
    func saveCustomSpread(_ definition: SpreadDefinition) -> Bool {
        guard customLibraryAvailable else {
            presentIssue(
                title: "Custom spreads unavailable",
                message: "The saved custom spread file couldn't be read. Retry before changing the library.",
                retry: nil
            )
            return false
        }
        let savedLibrary: CustomSpreadLibrary
        do {
            try definition.validate()
            var library = CustomSpreadLibrary(spreads: customSpreads)
            if let index = library.spreads.firstIndex(where: { $0.id == definition.id }) {
                library.spreads[index] = definition
            } else {
                library.spreads.append(definition)
            }
            try customSpreadStore.saveLibrary(library)
            savedLibrary = library
        } catch {
            presentIssue(
                title: "Custom spread unavailable",
                message: "We couldn't save this spread. Your library was not changed.",
                retry: nil
            )
            return false
        }
        customSpreads = savedLibrary.spreads.sorted { $0.updatedAt > $1.updatedAt }
        selectCustomSpread(definition)
        do {
            try customSpreadStore.clearDraft()
            recoveredCustomDraft = nil
        } catch {
            presentIssue(
                title: "Spread saved",
                message: "The spread was saved, but its recovery draft couldn't be cleared yet.",
                retry: nil
            )
        }
        return true
    }

    func canSaveCustomSpread(_ definition: SpreadDefinition) -> Bool {
        guard customLibraryAvailable, (try? definition.validate()) != nil else { return false }
        var candidate = customSpreads.filter { $0.id != definition.id }
        candidate.append(definition)
        return (try? CustomSpreadLibrary(spreads: candidate).validate()) != nil
    }

    func retryCustomSpreadLibrary() {
        do {
            let library = try customSpreadStore.loadLibrary()
            let draft = try customSpreadStore.loadDraft()
            customSpreads = library.spreads.sorted { $0.updatedAt > $1.updatedAt }
            recoveredCustomDraft = draft
            customLibraryAvailable = true
        } catch {
            customLibraryAvailable = false
        }
    }

    func discardCustomDraft() {
        do {
            try customSpreadStore.clearDraft()
            recoveredCustomDraft = nil
        } catch {
            presentIssue(
                title: "Custom spread unavailable",
                message: "We couldn't clear the saved draft yet.",
                retry: nil
            )
        }
    }

    @discardableResult
    func duplicateCustomSpread(_ id: UUID) -> SpreadDefinition? {
        guard let source = customSpreads.first(where: { $0.id == id }) else { return nil }
        let now = Date()
        let existingNames = Set(customSpreads.map { $0.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() })
        var copyNumber = 1
        var duplicateName = ""
        repeat {
            let suffix = copyNumber == 1 ? " copy" : " copy \(copyNumber)"
            duplicateName = String(source.name.prefix(max(40 - suffix.count, 1))) + suffix
            copyNumber += 1
        } while existingNames.contains(duplicateName.lowercased())
        let duplicate = SpreadDefinition(
            name: duplicateName,
            positions: source.positions.sorted { $0.order < $1.order }.map {
                SpreadPosition(order: $0.order, label: $0.label, point: $0.point)
            },
            createdAt: now,
            updatedAt: now
        )
        return saveCustomSpread(duplicate) ? duplicate : nil
    }

    func deleteCustomSpread(_ id: UUID) {
        guard customSpreads.contains(where: { $0.id == id }) else { return }
        do {
            let remaining = customSpreads.filter { $0.id != id }
            try customSpreadStore.saveLibrary(CustomSpreadLibrary(spreads: remaining))
            customSpreads = remaining
            if recoveredCustomDraft?.id == id {
                try? customSpreadStore.clearDraft()
                recoveredCustomDraft = nil
            }
            if selectedCustomSpreadID == id {
                selectedCustomSpreadID = nil
                homeCustomSpreadPreference = nil
                selectedPreset = homePresetPreference
                preferences.set("preset", forKey: Self.selectionKindPreferenceKey)
                preferences.removeObject(forKey: Self.customSelectionPreferenceKey)
            }
        } catch {
            presentIssue(
                title: "Custom spread unavailable",
                message: "We couldn't delete this spread. Your library was not changed.",
                retry: nil
            )
        }
    }

    func startSelectedPreset() {
        if let selectedCustomSpread {
            startCustomSpread(selectedCustomSpread)
        } else {
            startPreset(selectedPreset)
        }
    }

    func requestReadingFromLearn(_ preset: ReadingPreset) {
        guard !isBusy, surface != .restoring else { return }
        if session != nil {
            surface = .table
        } else if layout == nil {
            selectedPreset = preset
            selectedCustomSpreadID = nil
            surface = .home
        } else {
            prepareLearnPreset(preset)
        }
    }

    func requestCustomSpreadCreationFromLearn() {
        guard !isBusy, surface != .restoring else { return }
        if session == nil, layout == nil { surface = .home }
        customLibraryRequestCount += 1
    }

    private func prepareLearnPreset(_ preset: ReadingPreset) {
        perform(
            retry: .learnPreset(preset),
            failureMessage: "We couldn't save the selected reading. Nothing was changed."
        ) {
            let definition = preset.builtInSnapshot
            try self.continuityStore.save(.ready(preset.layout, spread: preset.spread, definition: definition))
            self.selectedPreset = preset
            self.selectedCustomSpreadID = nil
            self.layout = preset.layout
            self.spread = preset.spread
            self.activeDefinition = definition
            self.session = nil
            self.surface = .table
        }
    }

    private func startCustomSpread(_ customSpread: SpreadDefinition) {
        guard !isBusy, surface == .home, layout == nil, session == nil else { return }
        perform(
            retry: .startCustom(customSpread.id),
            failureMessage: "We couldn't save the selected reading. Nothing was changed."
        ) {
            let snapshot = try customSpread.snapshot()
            try self.continuityStore.save(
                .ready(.customCards, spread: nil, definition: snapshot)
            )
            self.activeDefinition = snapshot
            self.layout = .customCards
            self.spread = nil
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
        let currentDefinition = activeDefinition

        perform(
            retry: .reset,
            failureMessage: "We couldn't reset the reading. It remains unchanged."
        ) {
            if let currentSession {
                try self.continuityStore.save(
                    .resetting(
                        sessionID: currentSession.id,
                        layout: layout,
                        spread: currentSpread,
                        definition: currentDefinition
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
                            spread: currentSpread,
                            definition: currentDefinition
                        )
                    )
                    throw error
                }
            }

            do {
                try self.continuityStore.save(
                    .ready(layout, spread: currentSpread, definition: currentDefinition)
                )
            } catch where currentSession != nil {
                // The durable reset intent plus an absent deck session is recoverable as ready.
                // Publish that truthful result; the next shuffle reasserts the ready marker.
            }
            self.session = nil
            self.activeDefinition = currentDefinition
            if layout != .customCards {
                self.selectedPreset = ReadingPreset.resolved(layout: layout, spread: currentSpread)
            }
            self.surface = .table
        }
    }

    private func startPreset(_ preset: ReadingPreset) {
        guard !isBusy, surface == .home, layout == nil, session == nil else { return }
        perform(
            retry: .startPreset(preset),
            failureMessage: "We couldn't save the selected reading. Nothing was changed."
        ) {
            let definition = preset.builtInSnapshot
            try self.continuityStore.save(
                .ready(preset.layout, spread: preset.spread, definition: definition)
            )
            self.selectedPreset = preset
            self.selectedCustomSpreadID = nil
            self.layout = preset.layout
            self.spread = preset.spread
            self.activeDefinition = definition
            self.session = nil
            self.surface = .table
        }
    }

    func shuffleDeck() {
        guard canShuffleDeck, let layout else { return }
        perform(
            retry: .shuffle,
            failureMessage: "We couldn't finish shuffling. The previous reading state remains available."
        ) {
            let started: DeckSession
            if let existing = await self.coordinator.currentSession() {
                guard self.isCanonicalSession(existing, for: layout) else {
                    throw ReadFlowInvariantError.invalidSession
                }

                try self.continuityStore.save(
                    .reshuffling(
                        sessionID: existing.id,
                        layout: layout,
                        spread: self.spread,
                        definition: self.activeDefinition
                    )
                )
                do {
                    started = try await self.coordinator.reshuffleRemaining()
                } catch {
                    try? self.continuityStore.save(
                        .active(
                            sessionID: existing.id,
                            layout: layout,
                            spread: self.spread,
                            definition: self.activeDefinition
                        )
                    )
                    throw error
                }
            } else {
                // Reassert the write-ahead record before creating the first shuffled session.
                try self.continuityStore.save(
                    .ready(layout, spread: self.spread, definition: self.activeDefinition)
                )
                started = try await self.coordinator.startSession()
            }

            guard self.isCanonicalSession(started, for: layout),
                  started.drawnCards.count <= self.activeCardCount else {
                throw ReadFlowInvariantError.invalidSession
            }

            do {
                try self.continuityStore.save(
                    .active(
                        sessionID: started.id,
                        layout: layout,
                        spread: self.spread,
                        definition: self.activeDefinition
                    )
                )
            } catch {
                // The shuffled deck itself is already committed atomically. Publish that truthful
                // result and leave the shuffling marker for restore() to reconcile safely.
                self.session = started
                self.shufflePresentationGeneration += 1
                self.presentIssue(
                    title: "Shuffle recovery paused",
                    message: "The deck was shuffled, but its recovery marker still needs to be updated.",
                    retry: .restore
                )
                return
            }
            self.session = started
            self.shufflePresentationGeneration += 1
        }
    }

    /// Called by the table when a new/reset reading becomes visible. A restored
    /// active session is never eligible because it already has a session.
    func beginAutomaticShuffleIfNeeded() {
        guard isReadyToShuffle else { return }
        shuffleDeck()
    }

    func placeNextCardInOrder() {
        guard let session, let layout else { return }
        guard isCanonicalSession(session, for: layout) else {
            discardInvalidPublishedSession()
            return
        }
        guard session.drawnCards.count < activeCardCount else { return }

        let occupied = Set(session.drawnCards.map(\.positionIndex))
        guard let expectedPosition = (0..<activeCardCount).first(where: { !occupied.contains($0) }) else {
            return
        }

        perform(
            retry: .placeNext,
            failureMessage: "We couldn't place the next card. Nothing was changed."
        ) {
            let placed = try await self.coordinator.draw()
            guard placed.positionIndex == expectedPosition,
                  let updated = await self.coordinator.currentSession(),
                  self.isCanonicalSession(updated, for: layout),
                  updated.drawnCard(atPosition: expectedPosition) == placed else {
                throw ReadFlowInvariantError.invalidSession
            }
            self.session = updated
        }
    }

    func placeNextCard(at slotIndex: Int) {
        guard let session, let layout else { return }
        guard isCanonicalSession(session, for: layout) else {
            discardInvalidPublishedSession()
            return
        }
        guard canPlaceCard(at: slotIndex) else { return }

        perform(retry: .place(slot: slotIndex), failureMessage: "We couldn't place the next card. Nothing was changed.") {
            _ = try await self.coordinator.draw(into: slotIndex)
            guard let updated = await self.coordinator.currentSession(),
                  self.isCanonicalSession(updated, for: layout),
                  updated.drawnCard(atPosition: slotIndex) != nil else {
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
        case .startCustom(let id):
            if let definition = customSpreads.first(where: { $0.id == id }) {
                startCustomSpread(definition)
            }
        case .learnPreset(let preset): prepareLearnPreset(preset)
        case .shuffle: shuffleDeck()
        case .placeNext: placeNextCardInOrder()
        case .place(let slot): placeNextCard(at: slot)
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
            activeDefinition = definition(for: record)
            if record.layout != .customCards {
                selectedPreset = ReadingPreset.resolved(layout: record.layout, spread: record.resolvedSpread)
            }
            session = nil
            surface = .table

        case (.noSavedSession, .some(let record))
            where record.isStructurallyValid && record.phase == .resetting:
            do {
                try continuityStore.save(.ready(record.layout, spread: record.resolvedSpread, definition: definition(for: record)))
                layout = record.layout
                spread = record.resolvedSpread
                activeDefinition = definition(for: record)
                if record.layout != .customCards {
                    selectedPreset = ReadingPreset.resolved(layout: record.layout, spread: record.resolvedSpread)
                }
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

        case (.noSavedSession, .some(let record))
            where record.isStructurallyValid && record.phase == .shuffling:
            do {
                try continuityStore.save(.ready(record.layout, spread: record.resolvedSpread, definition: definition(for: record)))
                layout = record.layout
                spread = record.resolvedSpread
                activeDefinition = definition(for: record)
                if record.layout != .customCards {
                    selectedPreset = ReadingPreset.resolved(layout: record.layout, spread: record.resolvedSpread)
                }
                session = nil
                surface = .table
                presentRecovery("The deck is ready to shuffle again.")
            } catch {
                presentIssue(
                    title: "Reading recovery paused",
                    message: "The deck is safe, but its shuffle marker couldn't be updated.",
                    retry: .restore
                )
            }

        case (.noSavedSession, .some(let record))
            where record.isStructurallyValid && record.phase == .reshuffling:
            do {
                try continuityStore.clear()
                resetToHome()
                presentRecovery("The incomplete shuffle was cleared without changing a reading.")
            } catch {
                presentIssue(
                    title: "Reading recovery paused",
                    message: "The incomplete shuffle marker couldn't be cleared yet.",
                    retry: .restore
                )
            }

        case (.restored(let restored), .some(let record))
            where record.isStructurallyValid
                && record.phase == .active
                && record.sessionID == restored.id
                && isCanonicalSession(restored, for: record.layout, cardCount: definition(for: record).cardCount):
            layout = record.layout
            spread = record.resolvedSpread
            activeDefinition = definition(for: record)
            if record.layout != .customCards {
                selectedPreset = ReadingPreset.resolved(layout: record.layout, spread: record.resolvedSpread)
            }
            session = restored
            surface = .table

        case (.restored(let restored), .some(let record))
            where record.isStructurallyValid
                && record.phase == .resetting
                && record.sessionID == restored.id
                && isCanonicalSession(restored, for: record.layout, cardCount: definition(for: record).cardCount):
            do {
                try continuityStore.save(
                    .active(
                        sessionID: restored.id,
                        layout: record.layout,
                        spread: record.resolvedSpread,
                        definition: definition(for: record)
                    )
                )
                layout = record.layout
                spread = record.resolvedSpread
                activeDefinition = definition(for: record)
                if record.layout != .customCards {
                    selectedPreset = ReadingPreset.resolved(layout: record.layout, spread: record.resolvedSpread)
                }
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
                && record.phase == .shuffling
                && restored.drawnCards.isEmpty
                && isCanonicalSession(restored, for: record.layout, cardCount: definition(for: record).cardCount):
            do {
                try continuityStore.save(
                    .active(
                        sessionID: restored.id,
                        layout: record.layout,
                        spread: record.resolvedSpread,
                        definition: definition(for: record)
                    )
                )
                layout = record.layout
                spread = record.resolvedSpread
                activeDefinition = definition(for: record)
                if record.layout != .customCards {
                    selectedPreset = ReadingPreset.resolved(layout: record.layout, spread: record.resolvedSpread)
                }
                session = restored
                surface = .table
                presentRecovery(
                    restored.id == record.sessionID
                        ? "The previous shuffled order was restored safely."
                        : "Your newly shuffled deck was recovered safely."
                )
            } catch {
                presentIssue(
                    title: "Reading recovery paused",
                    message: "We found the shuffled deck but couldn't finish restoring it.",
                    retry: .restore
                )
            }

        case (.restored(let restored), .some(let record))
            where record.isStructurallyValid
                && record.phase == .reshuffling
                && record.sessionID == restored.id
                && isCanonicalSession(restored, for: record.layout, cardCount: definition(for: record).cardCount):
            do {
                try continuityStore.save(
                    .active(
                        sessionID: restored.id,
                        layout: record.layout,
                        spread: record.resolvedSpread,
                        definition: definition(for: record)
                    )
                )
                layout = record.layout
                spread = record.resolvedSpread
                activeDefinition = definition(for: record)
                if record.layout != .customCards {
                    selectedPreset = ReadingPreset.resolved(layout: record.layout, spread: record.resolvedSpread)
                }
                session = restored
                surface = .table
                presentRecovery("The latest shuffled order was restored safely.")
            } catch {
                presentIssue(
                    title: "Reading recovery paused",
                    message: "We found the shuffled reading but couldn't finish restoring it.",
                    retry: .restore
                )
            }

        case (.restored(let restored), .some(let record))
            where record.isStructurallyValid
                && record.phase == .readyToShuffle
                && restored.drawnCards.isEmpty
                && isCanonicalSession(restored, for: record.layout, cardCount: definition(for: record).cardCount):
            do {
                try continuityStore.save(
                    .active(
                        sessionID: restored.id,
                        layout: record.layout,
                        spread: record.resolvedSpread,
                        definition: definition(for: record)
                    )
                )
                layout = record.layout
                spread = record.resolvedSpread
                activeDefinition = definition(for: record)
                if record.layout != .customCards {
                    selectedPreset = ReadingPreset.resolved(layout: record.layout, spread: record.resolvedSpread)
                }
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

    private func isCanonicalSession(
        _ candidate: DeckSession,
        for layout: ReadingLayout,
        cardCount: Int? = nil
    ) -> Bool {
        do {
            try candidate.validate()
        } catch {
            return false
        }

        let expectedCount = cardCount
            ?? activeDefinition?.cardCount
            ?? (layout == .customCards ? SpreadDefinition.maximumCardCount : layout.cardLimit)
        guard expectedCount > 0,
              knownCardIDs == canonicalCardIDs,
              candidate.shuffledCardIDs.count == StandardTarotDeck.cardIDs.count,
              Set(candidate.shuffledCardIDs) == canonicalCardIDs,
              candidate.drawnCards.count <= expectedCount,
              candidate.drawnCards.allSatisfy({ (0..<expectedCount).contains($0.positionIndex) }),
              candidate.drawnCards.allSatisfy({ knownCardIDs.contains($0.id) }) else {
            return false
        }
        return true
    }

    private func resetToHome() {
        selectedPreset = homePresetPreference
        selectedCustomSpreadID = homeCustomSpreadPreference
        layout = nil
        spread = nil
        activeDefinition = nil
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

    private static func loadCustomSelectionPreference(from preferences: UserDefaults) -> UUID? {
        guard preferences.string(forKey: selectionKindPreferenceKey) == "custom",
              let rawID = preferences.string(forKey: customSelectionPreferenceKey) else {
            return nil
        }
        return UUID(uuidString: rawID)
    }

    private func definition(for record: ReadingContinuityRecord) -> SpreadDefinitionSnapshot {
        if let definition = record.definition { return definition }
        return ReadingPreset.resolved(
            layout: record.layout,
            spread: record.resolvedSpread
        ).builtInSnapshot
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
            var succeeded = false
            defer {
                self.isBusy = false
                if succeeded {
                    switch retry {
                    case .startPreset, .startCustom, .learnPreset, .reset:
                        Task { @MainActor in
                            await Task.yield()
                            self.beginAutomaticShuffleIfNeeded()
                        }
                    default:
                        break
                    }
                }
            }
            do {
                try await operation()
                succeeded = true
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
