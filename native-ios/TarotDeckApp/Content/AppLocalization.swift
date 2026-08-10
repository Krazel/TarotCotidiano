import Foundation

enum AppLocalization {
    static var contentLanguageCode: String {
        contentLanguageCode(bundle: .main)
    }

    static func contentLanguageCode(bundle: Bundle) -> String {
        let preferred = bundle.preferredLocalizations.first
            ?? Locale.preferredLanguages.first
            ?? "en"
        return preferred.lowercased().hasPrefix("es") ? "es" : "en"
    }

    static var isSpanish: Bool {
        contentLanguageCode == "es"
    }

    static func isSpanish(bundle: Bundle) -> Bool {
        contentLanguageCode(bundle: bundle) == "es"
    }

    static func text(_ key: String) -> String {
        NSLocalizedString(key, bundle: .main, value: key, comment: "")
    }

    static func format(_ key: String, _ arguments: CVarArg...) -> String {
        String(format: text(key), locale: Locale.current, arguments: arguments)
    }
}
