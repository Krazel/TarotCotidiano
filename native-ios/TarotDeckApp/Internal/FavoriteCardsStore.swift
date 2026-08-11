import Combine
import Foundation

private struct FavoriteCardsSnapshot: Codable {
    let schemaVersion: Int
    let cardIDs: [String]
}

/// Device-local favorites keyed only by canonical, language-neutral card identifiers.
///
/// Every mutation is persisted atomically before the published set changes. An unreadable file
/// never blocks the deck or its bundled reference content; the next valid mutation replaces it.
@MainActor
final class FavoriteCardsStore: ObservableObject {
    @Published private(set) var cardIDs: Set<String> = []
    @Published var showsIssueAlert = false

    private let fileURL: URL
    private let knownCardIDs: Set<String>
    private var issue: Issue?

    private enum Issue {
        case loadFailed
        case saveFailed
    }

    init(fileURL: URL, knownCardIDs: Set<String>) {
        self.fileURL = fileURL
        self.knownCardIDs = knownCardIDs
        load()
    }

    var issueMessage: String {
        switch issue {
        case .loadFailed:
            return AppLocalization.text(
                "Your cards are still available. Add a favorite to start a new list."
            )
        case .saveFailed:
            return AppLocalization.text("Favorites couldn't be updated. Nothing was changed.")
        case nil:
            return ""
        }
    }

    func contains(_ cardID: String) -> Bool {
        cardIDs.contains(cardID)
    }

    @discardableResult
    func toggle(_ cardID: String) -> Bool {
        guard knownCardIDs.contains(cardID) else {
            issue = .saveFailed
            showsIssueAlert = true
            return false
        }

        var candidate = cardIDs
        if candidate.contains(cardID) {
            candidate.remove(cardID)
        } else {
            candidate.insert(cardID)
        }

        do {
            try save(candidate)
            cardIDs = candidate
            return true
        } catch {
            issue = .saveFailed
            showsIssueAlert = true
            return false
        }
    }

    func dismissIssue() {
        showsIssueAlert = false
        issue = nil
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }

        do {
            let data = try Data(contentsOf: fileURL)
            let snapshot = try JSONDecoder().decode(FavoriteCardsSnapshot.self, from: data)
            let decodedIDs = Set(snapshot.cardIDs)
            guard snapshot.schemaVersion == 1,
                  decodedIDs.count == snapshot.cardIDs.count,
                  decodedIDs.isSubset(of: knownCardIDs) else {
                throw FavoriteCardsStoreError.invalidSnapshot
            }
            cardIDs = decodedIDs
        } catch {
            cardIDs = []
            issue = .loadFailed
            showsIssueAlert = true
        }
    }

    private func save(_ candidate: Set<String>) throws {
        let snapshot = FavoriteCardsSnapshot(
            schemaVersion: 1,
            cardIDs: candidate.sorted()
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        try encoder.encode(snapshot).write(to: fileURL, options: .atomic)
    }
}

private enum FavoriteCardsStoreError: Error {
    case invalidSnapshot
}
