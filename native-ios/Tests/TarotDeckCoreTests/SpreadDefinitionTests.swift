import Foundation
import XCTest
@testable import TarotDeckCore

final class SpreadDefinitionTests: XCTestCase {
    func testAutomaticLayoutsStayNormalizedForOneThroughTwelveCards() throws {
        for count in 1...12 {
            let positions = SpreadDefinition.arrangedPositions(count: count)
            XCTAssertEqual(positions.count, count)
            XCTAssertEqual(positions.map(\.order), Array(0..<count))
            XCTAssertTrue(positions.allSatisfy { (0...1).contains($0.point.x) && (0...1).contains($0.point.y) })
            try SpreadDefinition(name: "Test", positions: positions).validate()
        }
    }

    func testRejectsOutOfBoundsPointAndThirteenCards() {
        var invalidPoint = SpreadDefinition.arrangedPositions(count: 3)
        invalidPoint[1].point.x = 1.1
        XCTAssertThrowsError(try SpreadDefinition(name: "Invalid", positions: invalidPoint).validate())

        let thirteen = (0..<13).map {
            SpreadPosition(order: $0, label: "Card \($0 + 1)", point: SpreadPoint(x: 0.5, y: 0.5))
        }
        XCTAssertThrowsError(try SpreadDefinition(name: "Too many", positions: thirteen).validate())
    }

    func testSnapshotIsImmutableAfterSourceChanges() throws {
        var definition = SpreadDefinition(
            name: "Original",
            positions: SpreadDefinition.arrangedPositions(count: 6)
        )
        let snapshot = try definition.snapshot()
        definition.name = "Changed"
        definition.positions[0].label = "Changed"
        XCTAssertEqual(snapshot.name, "Original")
        XCTAssertEqual(snapshot.positions[0].label, "")
    }

    func testJSONStoreRoundTripsLibraryAndDraftAtomically() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = JSONCustomSpreadStore(
            libraryURL: directory.appendingPathComponent("library.json"),
            draftURL: directory.appendingPathComponent("draft.json")
        )
        // Use an integer-second timestamp so JSON number serialization is
        // deterministic across Foundation implementations and architectures.
        let persistedTimestamp = Date(timeIntervalSince1970: 1_700_000_000)
        let definition = SpreadDefinition(
            name: "Six",
            positions: SpreadDefinition.arrangedPositions(count: 6, columns: 3),
            createdAt: persistedTimestamp,
            updatedAt: persistedTimestamp
        )
        try store.saveLibrary(CustomSpreadLibrary(spreads: [definition]))
        try store.saveDraft(definition)
        XCTAssertEqual(try store.loadLibrary().spreads, [definition])
        XCTAssertEqual(try store.loadDraft(), definition)
        try store.clearDraft()
        XCTAssertNil(try store.loadDraft())
    }

    func testLibraryRejectsDuplicateNamesAndMoreThanFiftySpreads() {
        let first = SpreadDefinition(name: "Same", positions: SpreadDefinition.arrangedPositions(count: 1))
        let second = SpreadDefinition(name: " same ", positions: SpreadDefinition.arrangedPositions(count: 1))
        XCTAssertThrowsError(try CustomSpreadLibrary(spreads: [first, second]).validate())

        let tooMany = (0...CustomSpreadLibrary.maximumSpreadCount).map { index in
            SpreadDefinition(name: "Spread \(index)", positions: SpreadDefinition.arrangedPositions(count: 1))
        }
        XCTAssertThrowsError(try CustomSpreadLibrary(spreads: tooMany).validate())
    }

    func testNameAndPositionLabelRespectPublishedLimits() {
        XCTAssertThrowsError(
            try SpreadDefinition(
                name: String(repeating: "N", count: 41),
                positions: SpreadDefinition.arrangedPositions(count: 1)
            ).validate()
        )
        var positions = SpreadDefinition.arrangedPositions(count: 1)
        positions[0].label = String(repeating: "L", count: 33)
        XCTAssertThrowsError(try SpreadDefinition(name: "Valid", positions: positions).validate())

        positions[0].label = ""
        XCTAssertNoThrow(try SpreadDefinition(name: "Optional label", positions: positions).validate())
    }

    func testRejectsOverlappingPositions() {
        let positions = [
            SpreadPosition(order: 0, label: "", point: SpreadPoint(x: 0.5, y: 0.5)),
            SpreadPosition(order: 1, label: "", point: SpreadPoint(x: 0.52, y: 0.52))
        ]
        XCTAssertThrowsError(try SpreadDefinition(name: "Overlap", positions: positions).validate())
    }
}
