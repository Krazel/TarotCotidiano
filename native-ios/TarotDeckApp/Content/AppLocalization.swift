import Foundation
import SwiftUI
import UIKit

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case spanish = "es"

    var id: String { rawValue }

    var locale: Locale {
        Locale(identifier: self == .spanish ? "es_ES" : "en_US")
    }

    var accessibilityCode: String {
        self == .spanish ? "es-ES" : "en-US"
    }

    var autonym: String {
        self == .spanish ? "Español" : "English"
    }

    static func resolved(from preferredLanguages: [String]) -> Self {
        preferredLanguages.first?.lowercased().hasPrefix("es") == true ? .spanish : .english
    }
}

private enum AppLanguageValidationError: Error {
    case missingInterfaceLocalization(String)
}

private struct RequiredInterfaceKeysDocument: Decodable {
    let schemaVersion: Int
    let keys: [String]
}

@MainActor
final class AppLanguageStore: ObservableObject {
    struct State {
        let language: AppLanguage
        let contentResult: Result<TarotContent, Error>
    }

    static let preferenceKey = "tarot.appLanguage.v1"

    @Published private(set) var state: State
    @Published var showsIssueAlert = false
    @Published private(set) var issueMessage = ""

    private let bundle: Bundle
    private let defaults: UserDefaults

    var language: AppLanguage { state.language }
    var contentResult: Result<TarotContent, Error> { state.contentResult }
    var content: TarotContent? { try? state.contentResult.get() }

    init(
        bundle: Bundle = .main,
        defaults: UserDefaults = .standard,
        preferredLanguages: [String] = Locale.preferredLanguages
    ) {
        self.bundle = bundle
        self.defaults = defaults

        let saved = defaults.string(forKey: Self.preferenceKey).flatMap(AppLanguage.init(rawValue:))
        let preferred = saved ?? AppLanguage.resolved(from: preferredLanguages)
        let initial: State

        do {
            try AppLocalization.validateInterfaceResources(for: preferred, in: bundle)
            initial = State(
                language: preferred,
                contentResult: .success(
                    try TarotContentLoader.load(language: preferred, bundle: bundle)
                )
            )
        } catch {
            // English is the complete product fallback. A corrupt or incomplete Spanish package
            // never produces a mixed-language state and never changes the explicit preference.
            do {
                try AppLocalization.validateInterfaceResources(for: .english, in: bundle)
                initial = State(
                    language: .english,
                    contentResult: .success(
                        try TarotContentLoader.load(language: .english, bundle: bundle)
                    )
                )
                if saved != nil {
                    // A persisted preference that cannot produce a valid complete snapshot is no
                    // longer a usable commit. Clear it only after the English fallback validates.
                    defaults.removeObject(forKey: Self.preferenceKey)
                }
            } catch {
                initial = State(language: .english, contentResult: .failure(error))
            }
        }

        state = initial
        AppLocalization.configure(language: initial.language, bundle: bundle)
    }

    func select(_ candidate: AppLanguage) {
        guard candidate != language else { return }

        do {
            // Validate the complete candidate content before committing either the persisted
            // preference or the published UI/content snapshot.
            try AppLocalization.validateInterfaceResources(for: candidate, in: bundle)
            let candidateContent = try TarotContentLoader.load(language: candidate, bundle: bundle)
            defaults.set(candidate.rawValue, forKey: Self.preferenceKey)
            AppLocalization.configure(language: candidate, bundle: bundle)
            state = State(language: candidate, contentResult: .success(candidateContent))

            let announcement = AppLocalization.format(
                "Language changed to %@.",
                candidate.autonym
            )
            DispatchQueue.main.async {
                UIAccessibility.post(notification: .announcement, argument: announcement)
            }
        } catch {
            issueMessage = AppLocalization.text(
                "The complete language content couldn't be loaded. Nothing was changed."
            )
            showsIssueAlert = true
        }
    }

    func dismissIssue() {
        showsIssueAlert = false
        issueMessage = ""
    }
}

enum AppLocalization {
    private static var activeLanguage = AppLanguage.resolved(from: Locale.preferredLanguages)
    private static var activeBundle = Bundle.main

    static func configure(language: AppLanguage, bundle: Bundle = .main) {
        activeLanguage = language
        activeBundle = bundle
    }

    static var contentLanguageCode: String {
        activeLanguage.rawValue
    }

    static func contentLanguageCode(bundle: Bundle) -> String {
        if bundle === activeBundle { return activeLanguage.rawValue }
        return AppLanguage.resolved(
            from: bundle.preferredLocalizations.isEmpty
                ? Locale.preferredLanguages
                : bundle.preferredLocalizations
        ).rawValue
    }

    static var isSpanish: Bool {
        contentLanguageCode == "es"
    }

    static func isSpanish(bundle: Bundle) -> Bool {
        contentLanguageCode(bundle: bundle) == "es"
    }

    static func text(_ key: String) -> String {
        // String Catalog keys are the complete English source language. Returning the key
        // directly keeps an explicit English choice independent from the device language even
        // though Xcode is not required to emit a physical en.lproj directory.
        guard activeLanguage == .spanish else { return key }
        return localizedBundle(for: .spanish, in: activeBundle)
            .localizedString(forKey: key, value: key, table: nil)
    }

    static func format(_ key: String, _ arguments: CVarArg...) -> String {
        String(format: text(key), locale: activeLanguage.locale, arguments: arguments)
    }

    static func validateInterfaceResources(for language: AppLanguage, in bundle: Bundle) throws {
        guard let manifestURL = bundle.url(
            forResource: "required-interface-keys.v1",
            withExtension: "json"
        ),
              let document = try? JSONDecoder().decode(
                RequiredInterfaceKeysDocument.self,
                from: Data(contentsOf: manifestURL)
              ),
              document.schemaVersion == 1,
              !document.keys.isEmpty,
              Set(document.keys).count == document.keys.count,
              document.keys.allSatisfy({
                  let sourceText = $0.trimmingCharacters(in: .whitespacesAndNewlines)
                  return !sourceText.isEmpty && sourceText == $0
              }) else {
            throw AppLanguageValidationError.missingInterfaceLocalization(language.rawValue)
        }

        // English String Catalog keys are themselves the complete source-language copy. Their
        // manifest is bundled at the main level, so English must not depend on a generated
        // en.lproj directory or ask Bundle to resolve a device-preferred localization.
        if language == .english { return }

        guard let localized = spanishBundle(in: bundle) else {
            throw AppLanguageValidationError.missingInterfaceLocalization(language.rawValue)
        }
        for key in document.keys {
            let value = localized.localizedString(forKey: key, value: "", table: nil)
            guard !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw AppLanguageValidationError.missingInterfaceLocalization(language.rawValue)
            }
        }
    }

    private static func localizedBundle(for language: AppLanguage, in bundle: Bundle) -> Bundle {
        interfaceBundle(for: language, in: bundle) ?? bundle
    }

    private static func interfaceBundle(for language: AppLanguage, in bundle: Bundle) -> Bundle? {
        if language == .english {
            return bundle
        }
        return spanishBundle(in: bundle)
    }

    private static func spanishBundle(in bundle: Bundle) -> Bundle? {
        guard let path = bundle.path(forResource: AppLanguage.spanish.rawValue, ofType: "lproj") else {
            return nil
        }
        return Bundle(path: path)
    }
}
