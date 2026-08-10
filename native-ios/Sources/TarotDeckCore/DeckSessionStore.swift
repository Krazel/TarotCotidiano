import Foundation

/// Persistence boundary for the single active session.
///
/// Implementations must replace a complete saved snapshot or throw without
/// changing the previous snapshot. This contract lets the coordinator publish
/// its in-memory candidate only after persistence has committed successfully.
public protocol DeckSessionStoring: Sendable {
    func load() throws -> DeckSession?
    func save(_ session: DeckSession) throws
    func clear() throws
}

/// Stores one active reading as versioned JSON. `Data.write(.atomic)` writes a
/// temporary sibling file and replaces the destination only after completion.
public struct JSONDeckSessionStore: DeckSessionStoring {
    public let fileURL: URL

    public init(fileURL: URL) {
        self.fileURL = fileURL
    }

    public func load() throws -> DeckSession? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        let data = try Data(contentsOf: fileURL)
        let session = try Self.makeDecoder().decode(DeckSession.self, from: data)
        try session.validate()
        return session
    }

    public func save(_ session: DeckSession) throws {
        try session.validate()

        let directoryURL = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )

        let data = try Self.makeEncoder().encode(session)
        try data.write(to: fileURL, options: .atomic)
    }

    public func clear() throws {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return
        }

        try FileManager.default.removeItem(at: fileURL)
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
