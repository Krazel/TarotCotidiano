import Foundation
import SwiftUI
import TarotDeckCore

/// Unsigned internal composition root for the approved iPhone MVP surfaces.
@main
struct TarotDeckInternalApp: App {
#if DEBUG
    private let contentResult: Result<TarotContent, Error>
    @StateObject private var readModel: ReadFlowModel

    init() {
        let loadedContent: Result<TarotContent, Error> = Result {
            try TarotContentLoader.load()
        }
        let applicationSupportURL = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!

        let storageDirectoryURL = applicationSupportURL
            .appendingPathComponent("TarotDeckInternal", isDirectory: true)
        let sessionURL = storageDirectoryURL
            .appendingPathComponent("active-session.v1.json", isDirectory: false)
        let continuityURL = storageDirectoryURL
            .appendingPathComponent("reading-continuity.v1.json", isDirectory: false)

        let coordinator = DeckSessionCoordinator(
            shuffler: SystemDeckShuffler(),
            store: JSONDeckSessionStore(fileURL: sessionURL)
        )
        let knownCardIDs: Set<TarotCardID>
        switch loadedContent {
        case .success(let content):
            knownCardIDs = Set(content.cards.map { TarotCardID(rawValue: $0.id) })
        case .failure:
            knownCardIDs = []
        }
        _readModel = StateObject(
            wrappedValue: ReadFlowModel(
                coordinator: coordinator,
                knownCardIDs: knownCardIDs,
                continuityURL: continuityURL
            )
        )
        contentResult = loadedContent
    }
#endif

    var body: some Scene {
        WindowGroup {
#if DEBUG
            switch contentResult {
            case .success(let content):
                TarotDeckMainShell(
                    content: content,
                    startThreeCardReading: { readModel.requestThreeCardReadingFromLearn() }
                ) { inspectRevealedCard in
                    ReadRootView(
                        model: readModel,
                        content: content,
                        inspectRevealedCard: inspectRevealedCard
                    )
                }

            case .failure(let error):
                TarotContentFailureView(message: error.localizedDescription)
            }
#else
            // This unsigned internal scheme is intentionally Debug-only. A distributable release
            // target, signing identity and final bundle identity remain separately unauthorized.
            EmptyView()
#endif
        }
    }
}
