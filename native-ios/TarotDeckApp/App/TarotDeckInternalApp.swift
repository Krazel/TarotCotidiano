import Foundation
import SwiftUI
import TarotDeckCore

/// Composition root for the approved iPhone MVP surfaces.
@main
@MainActor
struct TarotDeckInternalApp: App {
    private enum StoragePreparationError: Error {
        case applicationSupportUnavailable
        case backupExclusionNotApplied
    }

    @StateObject private var languageStore: AppLanguageStore
    @StateObject private var readModel: ReadFlowModel
    @StateObject private var favoriteStore: FavoriteCardsStore
    @StateObject private var supporterStore: SupporterStore

    init() {
        let languageStore = AppLanguageStore()
        let storageDirectoryURL: URL
        do {
            storageDirectoryURL = try Self.prepareStorageDirectory()
        } catch {
            preconditionFailure("Private app storage could not be prepared: \(error)")
        }
        let sessionURL = storageDirectoryURL
            .appendingPathComponent("active-session.v1.json", isDirectory: false)
        let continuityURL = storageDirectoryURL
            .appendingPathComponent("reading-continuity.v1.json", isDirectory: false)
        let favoritesURL = storageDirectoryURL
            .appendingPathComponent("favorites.v1.json", isDirectory: false)
        let customSpreadsURL = storageDirectoryURL
            .appendingPathComponent("custom-spreads.v1.json", isDirectory: false)
        let customSpreadDraftURL = storageDirectoryURL
            .appendingPathComponent("custom-spread-draft.v1.json", isDirectory: false)

        let coordinator = DeckSessionCoordinator(
            shuffler: SystemDeckShuffler(),
            store: JSONDeckSessionStore(fileURL: sessionURL)
        )
        let knownCardIDs: Set<TarotCardID>
        switch languageStore.contentResult {
        case .success(let content):
            knownCardIDs = Set(content.cards.map { TarotCardID(rawValue: $0.id) })
        case .failure:
            knownCardIDs = []
        }
        _readModel = StateObject(
            wrappedValue: ReadFlowModel(
                coordinator: coordinator,
                knownCardIDs: knownCardIDs,
                continuityURL: continuityURL,
                customSpreadStore: JSONCustomSpreadStore(
                    libraryURL: customSpreadsURL,
                    draftURL: customSpreadDraftURL
                )
            )
        )
        _favoriteStore = StateObject(
            wrappedValue: FavoriteCardsStore(
                fileURL: favoritesURL,
                knownCardIDs: Set(knownCardIDs.map(\.rawValue))
            )
        )
        _languageStore = StateObject(wrappedValue: languageStore)
        _supporterStore = StateObject(wrappedValue: SupporterStore())
    }

    /// Creates and verifies the one app-owned persistence directory before any store is built.
    /// Failing closed prevents session, continuity, or favorite data from being read or written
    /// from a directory that iOS may include in device backups.
    private static func prepareStorageDirectory(
        fileManager: FileManager = .default
    ) throws -> URL {
        guard let applicationSupportURL = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            throw StoragePreparationError.applicationSupportUnavailable
        }

        var storageDirectoryURL = applicationSupportURL
            .appendingPathComponent("TarotDeckInternal", isDirectory: true)
        try fileManager.createDirectory(
            at: storageDirectoryURL,
            withIntermediateDirectories: true
        )

        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = true
        try storageDirectoryURL.setResourceValues(resourceValues)

        let verifiedValues = try storageDirectoryURL.resourceValues(
            forKeys: [.isExcludedFromBackupKey]
        )
        guard verifiedValues.isExcludedFromBackup == true else {
            throw StoragePreparationError.backupExclusionNotApplied
        }
        return storageDirectoryURL
    }
    var body: some Scene {
        WindowGroup {
            Group {
                switch languageStore.contentResult {
                case .success(let content):
                    TarotDeckMainShell(
                        content: content,
                        languageStore: languageStore,
                        favoriteStore: favoriteStore,
                        startReading: { presetID in
                            if presetID == "customSpread" {
                                readModel.requestCustomSpreadCreationFromLearn()
                                return
                            }
                            guard let preset = ReadingPreset(rawValue: presetID) else { return }
                            readModel.requestReadingFromLearn(preset)
                        }
                    ) { inspectRevealedCard, openReadingTutorial in
                        ReadRootView(
                            model: readModel,
                            content: content,
                            languageStore: languageStore,
                            supporterStore: supporterStore,
                            inspectRevealedCard: inspectRevealedCard,
                            openReadingTutorial: openReadingTutorial
                        )
                    }

                case .failure(let error):
                    TarotContentFailureView(message: error.localizedDescription)
                }
            }
            .environment(\.locale, languageStore.language.locale)
        }
    }
}
