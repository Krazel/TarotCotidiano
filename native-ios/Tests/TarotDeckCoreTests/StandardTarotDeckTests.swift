import Foundation
import XCTest
@testable import TarotDeckCore

final class StandardTarotDeckTests: XCTestCase {
    func testStandardDeckContainsExactlySeventyEightUniqueExternalIDs() {
        let cardIDs = StandardTarotDeck.cardIDs

        XCTAssertEqual(cardIDs.count, 78)
        XCTAssertEqual(Set(cardIDs).count, 78)
        XCTAssertTrue(cardIDs.allSatisfy { !$0.rawValue.isEmpty })
    }

    func testStandardDeckContainsExpectedMajorAndMinorStructure() {
        let rawIDs = StandardTarotDeck.cardIDs.map(\.rawValue)
        let majors = rawIDs.filter { $0.hasPrefix("major-") }
        let minors = rawIDs.filter { $0.hasPrefix("minor-") }

        XCTAssertEqual(majors.count, 22)
        XCTAssertEqual(minors.count, 56)

        for suit in ["wands", "cups", "swords", "pentacles"] {
            XCTAssertEqual(
                minors.filter { $0.hasPrefix("minor-\(suit)-") }.count,
                14
            )
        }
    }

    func testExternalIDCodableRepresentationIsAStableString() throws {
        let cardID = TarotCardID(rawValue: "major-00-the-fool")

        let data = try JSONEncoder().encode(cardID)
        let decoded = try JSONDecoder().decode(TarotCardID.self, from: data)

        XCTAssertEqual(String(decoding: data, as: UTF8.self), "\"major-00-the-fool\"")
        XCTAssertEqual(decoded, cardID)
    }
}
