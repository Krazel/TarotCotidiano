import Foundation

/// Refresh UMP, collect a required choice on a safe surface, then enable requests.
/// Loading and presentation are separate so late network responses cannot open
/// a form over a reading that started while the form was loading.
@MainActor
public enum ConsentLaunchSequence {
    public static func run<Form>(
        refresh: () async throws -> Void,
        requiresForm: () -> Bool,
        mayPresent: () -> Bool,
        load: () async throws -> Form,
        present: (Form) async throws -> Void,
        finish: () async -> Void
    ) async throws -> Bool {
        try await refresh()
        guard mayPresent() else { return false }
        if requiresForm() {
            let form = try await load()
            guard mayPresent() else { return false }
            try await present(form)
        }
        await finish()
        return true
    }
}
