import Foundation

public protocol DeckShuffling: Sendable {
    func shuffled(_ cardIDs: [TarotCardID]) -> [TarotCardID]
}

public struct SystemDeckShuffler: DeckShuffling {
    public init() {}

    public func shuffled(_ cardIDs: [TarotCardID]) -> [TarotCardID] {
        cardIDs.shuffled()
    }
}
