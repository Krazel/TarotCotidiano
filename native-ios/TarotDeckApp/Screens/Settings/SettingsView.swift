import Foundation
import SwiftUI

struct SettingsView: View {
    @ObservedObject var languageStore: AppLanguageStore

    private enum Feedback: Hashable, Identifiable {
        case supportUnavailable
        case restoreUnavailable
        case ratingUnavailable
        case privacyUnavailable
        case termsUnavailable

        var id: Self { self }

        var title: String {
            switch self {
            case .supportUnavailable: return AppLocalization.text("Support Unavailable")
            case .restoreUnavailable: return AppLocalization.text("Restore Unavailable")
            case .ratingUnavailable, .privacyUnavailable, .termsUnavailable:
                return AppLocalization.text("Destination Unavailable")
            }
        }

        var message: String {
            switch self {
            case .supportUnavailable:
                return AppLocalization.text(
                    "Support isn't available right now. You can keep using the full app."
                )
            case .restoreUnavailable:
                return AppLocalization.text(
                    "Restore Purchases isn't available in this internal build. You can keep using the full app."
                )
            case .ratingUnavailable:
                return AppLocalization.text(
                    "The App Store rating destination isn't available in this internal build."
                )
            case .privacyUnavailable:
                return AppLocalization.text("Privacy is unavailable in this internal build.")
            case .termsUnavailable:
                return AppLocalization.text("Terms are unavailable in this internal build.")
            }
        }
    }

    @Environment(\.dismiss) private var dismiss
    @State private var feedback: Feedback?

    private var appVersion: String {
        let bundleVersion = Bundle.main.object(
            forInfoDictionaryKey: "CFBundleShortVersionString"
        ) as? String
        let fallbackVersion = "0.3"
        guard let bundleVersion, !bundleVersion.isEmpty else { return fallbackVersion }
        return bundleVersion
    }

    var body: some View {
        ZStack {
            CeremonialBackdrop()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Read", systemImage: "chevron.left")
                            .font(.system(.title3, design: .serif, weight: .medium))
                            .frame(minHeight: 44)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(CeremonialObsidianTheme.brightGold)
                    .accessibilityHint("Closes Settings and returns to Read")

                    Text("Settings")
                        .font(.system(.largeTitle, design: .serif, weight: .semibold))
                        .foregroundStyle(CeremonialObsidianTheme.parchment)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)

                    settingsSection(title: "Language") {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(spacing: 16) {
                                Image(systemName: "globe")
                                    .font(.system(.title2, weight: .light))
                                    .foregroundStyle(CeremonialObsidianTheme.brightGold)
                                    .frame(width: 40)
                                    .frame(minHeight: 44)
                                    .accessibilityHidden(true)

                                Text("App Language")
                                    .font(.system(.title3, design: .serif, weight: .medium))
                                    .foregroundStyle(CeremonialObsidianTheme.parchment)
                            }

                            Picker(
                                AppLocalization.text("App Language"),
                                selection: Binding(
                                    get: { languageStore.language },
                                    set: { languageStore.select($0) }
                                )
                            ) {
                                ForEach(AppLanguage.allCases) { language in
                                    Text(language.autonym)
                                        .tag(language)
                                        .environment(\.locale, language.locale)
                                }
                            }
                            .pickerStyle(.segmented)
                            .tint(CeremonialObsidianTheme.brightGold)
                            .frame(minHeight: 44)
                            .accessibilityLabel("App Language")
                            .accessibilityValue(languageStore.language.autonym)
                            .accessibilityHint("Changes the app language immediately.")
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                    }

                    settingsSection(title: "Support") {
                        SettingsRow(
                            title: "Support the App",
                            subtitle: "Help fund maintenance and updates.",
                            systemImage: "heart"
                        ) {
                            feedback = .supportUnavailable
                        }

                        settingsDivider

                        SettingsRow(
                            title: "Restore Purchases",
                            systemImage: "arrow.counterclockwise"
                        ) {
                            feedback = .restoreUnavailable
                        }
                    }

                    settingsSection(title: "App") {
                        SettingsRow(title: "Rate the App", systemImage: "star") {
                            feedback = .ratingUnavailable
                        }

                        settingsDivider

                        SettingsRow(title: "Privacy", systemImage: "lock") {
                            feedback = .privacyUnavailable
                        }

                        settingsDivider

                        SettingsRow(title: "Terms", systemImage: "doc.text") {
                            feedback = .termsUnavailable
                        }
                    }

                    VStack(spacing: 8) {
                        HStack(spacing: 10) {
                            Rectangle()
                                .fill(CeremonialObsidianTheme.gold.opacity(0.35))
                                .frame(height: 1)
                            Image(systemName: "sparkle")
                                .foregroundStyle(CeremonialObsidianTheme.brightGold)
                                .accessibilityHidden(true)
                            Rectangle()
                                .fill(CeremonialObsidianTheme.gold.opacity(0.35))
                                .frame(height: 1)
                        }

                        Text(AppLocalization.format("Tarot Deck • Version %@", appVersion))
                            .font(.system(.body, design: .serif, weight: .medium))
                            .foregroundStyle(CeremonialObsidianTheme.brightGold)

                        Text("Made with care for curious readers.")
                            .font(.system(.subheadline, design: .serif))
                            .foregroundStyle(CeremonialObsidianTheme.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityElement(children: .combine)
                }
                .frame(maxWidth: 680)
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 36)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
        }
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .alert(item: $feedback) { item in
            Alert(
                title: Text(item.title),
                message: Text(item.message),
                dismissButton: .cancel(
                    Text("OK"),
                    action: { feedback = nil }
                )
            )
        }
        .alert(
            AppLocalization.text("Language Couldn't Be Changed"),
            isPresented: $languageStore.showsIssueAlert
        ) {
            Button("OK") {
                languageStore.dismissIssue()
            }
        } message: {
            Text(languageStore.issueMessage)
        }
    }

    private var settingsDivider: some View {
        Rectangle()
            .fill(CeremonialObsidianTheme.gold.opacity(0.26))
            .frame(height: 1)
            .padding(.leading, 66)
            .accessibilityHidden(true)
    }

    private func settingsSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 9) {
                Image(systemName: "sparkle")
                    .font(.caption)
                    .accessibilityHidden(true)
                Text(AppLocalization.text(title).uppercased())
                    .font(.system(.headline, design: .serif, weight: .semibold))
                    .tracking(1.4)
                Rectangle()
                    .fill(CeremonialObsidianTheme.gold.opacity(0.35))
                    .frame(height: 1)
            }
            .foregroundStyle(CeremonialObsidianTheme.brightGold)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(AppLocalization.text(title))
            .accessibilityAddTraits(.isHeader)

            VStack(spacing: 0) {
                content()
            }
            .background {
                RoundedRectangle(cornerRadius: 18)
                    .fill(CeremonialObsidianTheme.cardSurface.opacity(0.92))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(CeremonialObsidianTheme.gold.opacity(0.72), lineWidth: 1)
                    }
            }
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }
}

private struct SettingsRow: View {
    let title: String
    var subtitle: String?
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 16) {
                Image(systemName: systemImage)
                    .font(.system(.title2, weight: .light))
                    .foregroundStyle(CeremonialObsidianTheme.brightGold)
                    .frame(width: 40)
                    .frame(minHeight: 44)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 3) {
                    Text(AppLocalization.text(title))
                        .font(.system(.title3, design: .serif, weight: .medium))
                        .foregroundStyle(CeremonialObsidianTheme.parchment)

                    if let subtitle {
                        Text(AppLocalization.text(subtitle))
                            .font(.system(.subheadline, design: .serif))
                            .foregroundStyle(CeremonialObsidianTheme.secondaryText)
                    }
                }
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)

                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(CeremonialObsidianTheme.brightGold)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(AppLocalization.text(title))
        .accessibilityValue(subtitle.map(AppLocalization.text) ?? "")
        .accessibilityHint("Shows availability information")
    }
}
