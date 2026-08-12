import Foundation

public struct SpreadPoint: Codable, Equatable, Sendable {
    public var x: Double
    public var y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

public struct SpreadPosition: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public var order: Int
    public var label: String
    public var point: SpreadPoint

    public init(
        id: UUID = UUID(),
        order: Int,
        label: String,
        point: SpreadPoint
    ) {
        self.id = id
        self.order = order
        self.label = label
        self.point = point
    }
}

/// A user-authored spread. Positions live in a normalized 0...1 canvas so the
/// same immutable snapshot can be rendered in portrait and landscape.
public struct SpreadDefinition: Codable, Equatable, Identifiable, Sendable {
    public static let currentSchemaVersion = 1
    public static let minimumCardCount = 1
    public static let maximumCardCount = 12
    public static let minimumPointSeparation = 0.05

    public let schemaVersion: Int
    public let id: UUID
    public var name: String
    public var positions: [SpreadPosition]
    public let createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        positions: [SpreadPosition],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.schemaVersion = Self.currentSchemaVersion
        self.id = id
        self.name = name
        self.positions = positions
        self.createdAt = createdAt
        self.updatedAt = max(updatedAt, createdAt)
    }

    public var cardCount: Int { positions.count }

    public func validate() throws {
        guard schemaVersion == Self.currentSchemaVersion else {
            throw SpreadDefinitionValidationError.unsupportedSchemaVersion(schemaVersion)
        }
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, trimmedName.count <= 40 else {
            throw SpreadDefinitionValidationError.invalidName
        }
        guard (Self.minimumCardCount...Self.maximumCardCount).contains(positions.count) else {
            throw SpreadDefinitionValidationError.invalidCardCount(positions.count)
        }
        guard Set(positions.map(\.id)).count == positions.count else {
            throw SpreadDefinitionValidationError.duplicatePositionIDs
        }
        guard positions.map(\.order).sorted() == Array(0..<positions.count) else {
            throw SpreadDefinitionValidationError.invalidPositionOrder
        }
        for position in positions {
            let label = position.label.trimmingCharacters(in: .whitespacesAndNewlines)
            guard label.count <= 32 else {
                throw SpreadDefinitionValidationError.invalidPositionLabel(position.order)
            }
            guard position.point.x.isFinite,
                  position.point.y.isFinite,
                  (0...1).contains(position.point.x),
                  (0...1).contains(position.point.y) else {
                throw SpreadDefinitionValidationError.invalidPositionPoint(position.order)
            }
        }
        for firstIndex in positions.indices {
            for secondIndex in positions.indices where secondIndex > firstIndex {
                let first = positions[firstIndex].point
                let second = positions[secondIndex].point
                let distance = hypot(first.x - second.x, first.y - second.y)
                guard distance >= Self.minimumPointSeparation else {
                    throw SpreadDefinitionValidationError.overlappingPositions(
                        positions[firstIndex].order,
                        positions[secondIndex].order
                    )
                }
            }
        }
        guard updatedAt >= createdAt else {
            throw SpreadDefinitionValidationError.invalidTimestamps
        }
    }

    public func snapshot() throws -> SpreadDefinitionSnapshot {
        try validate()
        return SpreadDefinitionSnapshot(
            sourceID: id,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            positions: positions.sorted { $0.order < $1.order }
        )
    }

    public static func arrangedPositions(
        count: Int,
        columns requestedColumns: Int? = nil,
        labels: [String] = []
    ) -> [SpreadPosition] {
        let safeCount = min(max(count, minimumCardCount), maximumCardCount)
        let columns = min(max(requestedColumns ?? automaticColumnCount(for: safeCount), 1), 4)
        let rowCount = Int(ceil(Double(safeCount) / Double(columns)))
        return (0..<safeCount).map { index in
            let row = index / columns
            let column = index % columns
            let itemsInRow = min(columns, safeCount - row * columns)
            let x = Double(column + 1) / Double(itemsInRow + 1)
            let y = Double(row + 1) / Double(rowCount + 1)
            let label = labels.indices.contains(index) ? labels[index] : ""
            return SpreadPosition(order: index, label: label, point: SpreadPoint(x: x, y: y))
        }
    }

    public static func automaticColumnCount(for count: Int) -> Int {
        switch count {
        case 1: return 1
        case 2...4: return 2
        case 5...9: return 3
        default: return 4
        }
    }
}

public struct SpreadDefinitionSnapshot: Codable, Equatable, Sendable {
    public let sourceID: UUID?
    public let name: String
    public let positions: [SpreadPosition]

    public init(sourceID: UUID?, name: String, positions: [SpreadPosition]) {
        self.sourceID = sourceID
        self.name = name
        self.positions = positions
    }

    public var cardCount: Int { positions.count }

    public func validate() throws {
        let surrogate = SpreadDefinition(
            id: sourceID ?? UUID(),
            name: name,
            positions: positions,
            createdAt: .distantPast,
            updatedAt: .distantPast
        )
        try surrogate.validate()
    }
}

public enum SpreadDefinitionValidationError: Error, Equatable, Sendable {
    case unsupportedSchemaVersion(Int)
    case invalidName
    case invalidCardCount(Int)
    case duplicatePositionIDs
    case invalidPositionOrder
    case invalidPositionLabel(Int)
    case invalidPositionPoint(Int)
    case overlappingPositions(Int, Int)
    case invalidTimestamps
}

public struct CustomSpreadLibrary: Codable, Equatable, Sendable {
    public static let currentSchemaVersion = 1
    public static let maximumSpreadCount = 50
    public let schemaVersion: Int
    public var spreads: [SpreadDefinition]

    public init(spreads: [SpreadDefinition] = []) {
        self.schemaVersion = Self.currentSchemaVersion
        self.spreads = spreads
    }

    public func validate() throws {
        guard schemaVersion == Self.currentSchemaVersion else {
            throw CustomSpreadStoreError.unsupportedSchemaVersion(schemaVersion)
        }
        guard Set(spreads.map(\.id)).count == spreads.count else {
            throw CustomSpreadStoreError.duplicateSpreadIDs
        }
        guard spreads.count <= Self.maximumSpreadCount else {
            throw CustomSpreadStoreError.tooManySpreads(spreads.count)
        }
        let normalizedNames = spreads.map {
            $0.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        }
        guard Set(normalizedNames).count == normalizedNames.count else {
            throw CustomSpreadStoreError.duplicateSpreadNames
        }
        try spreads.forEach { try $0.validate() }
    }
}

public protocol CustomSpreadStoring: Sendable {
    func loadLibrary() throws -> CustomSpreadLibrary
    func saveLibrary(_ library: CustomSpreadLibrary) throws
    func loadDraft() throws -> SpreadDefinition?
    func saveDraft(_ draft: SpreadDefinition) throws
    func clearDraft() throws
}

public struct JSONCustomSpreadStore: CustomSpreadStoring {
    public let libraryURL: URL
    public let draftURL: URL

    public init(libraryURL: URL, draftURL: URL) {
        self.libraryURL = libraryURL
        self.draftURL = draftURL
    }

    public func loadLibrary() throws -> CustomSpreadLibrary {
        guard FileManager.default.fileExists(atPath: libraryURL.path) else {
            return CustomSpreadLibrary()
        }
        let library = try Self.makeDecoder().decode(CustomSpreadLibrary.self, from: Data(contentsOf: libraryURL))
        try library.validate()
        return library
    }

    public func saveLibrary(_ library: CustomSpreadLibrary) throws {
        try library.validate()
        try Self.write(Self.makeEncoder().encode(library), to: libraryURL)
    }

    public func loadDraft() throws -> SpreadDefinition? {
        guard FileManager.default.fileExists(atPath: draftURL.path) else { return nil }
        let draft = try Self.makeDecoder().decode(SpreadDefinition.self, from: Data(contentsOf: draftURL))
        try draft.validate()
        return draft
    }

    public func saveDraft(_ draft: SpreadDefinition) throws {
        try draft.validate()
        try Self.write(Self.makeEncoder().encode(draft), to: draftURL)
    }

    public func clearDraft() throws {
        guard FileManager.default.fileExists(atPath: draftURL.path) else { return }
        try FileManager.default.removeItem(at: draftURL)
    }

    private static func write(_ data: Data, to url: URL) throws {
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try data.write(to: url, options: .atomic)
    }

    private static func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }

    private static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

public enum CustomSpreadStoreError: Error, Equatable, Sendable {
    case unsupportedSchemaVersion(Int)
    case duplicateSpreadIDs
    case duplicateSpreadNames
    case tooManySpreads(Int)
}
