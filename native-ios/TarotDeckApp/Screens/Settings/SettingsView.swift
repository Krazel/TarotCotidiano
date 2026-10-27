import Foundation
import StoreKit
import SwiftUI

struct SettingsView: View {
    @ObservedObject var languageStore: AppLanguageStore
    @ObservedObject var supporterStore: SupporterStore
    @EnvironmentObject private var adConsent: TarotAdConsent
    @EnvironmentObject private var reminder: SupportReminderStore
    @State private var showsSupportReminder = false
    @State private var isSettingsVisible = false

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    private static let reviewURL = URL(
        string: "https://apps.apple.com/app/id6800144105?action=write-review"
    )
    private static let privacyURL = SupporterConfiguration.privacyURL
    private static let supportURL = URL(string: "https://krazel.github.io/tarot-deck/support/")

    private var appVersion: String {
        let bundleVersion = Bundle.main.object(
            forInfoDictionaryKey: "CFBundleShortVersionString"
        ) as? String
        let fallbackVersion = "1.2.1"
        guard let bundleVersion, !bundleVersion.isEmpty else { return fallbackVersion }
        return bundleVersion
    }

    var body: some View {
        ZStack {
            CeremonialBackdrop()

            GeometryReader { proxy in
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

                        if showsSupportReminder && supporterStore.hasResolvedEntitlements && !supporterStore.isSupporter {
                            settingsSection(title: "Read without ads") {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Choose a monthly option to remove ads. All readings and cards remain free.")
                                        .fixedSize(horizontal: false, vertical: true)
                                    NavigationLink("Remove ads") {
                                        RemoveAdsView(store: supporterStore)
                                    }
                                    .frame(minHeight: 44)
                                    Button("Not now") { showsSupportReminder = false }
                                        .frame(minHeight: 44)
                                    Button("Don't ask again") {
                                        reminder.optOut()
                                        showsSupportReminder = false
                                    }
                                    .frame(minHeight: 44)
                                }
                                .font(.system(.body, design: .serif))
                                .foregroundStyle(CeremonialObsidianTheme.parchment)
                                .tint(CeremonialObsidianTheme.brightGold)
                                .padding(18)
                            }
                        }

                        settingsSection(title: "Ads") {
                            NavigationLink {
                                RemoveAdsView(store: supporterStore)
                            } label: {
                                SettingsRowLabel(
                                    title: "Remove ads",
                                    subtitle: supporterStore.isSupporter
                                        ? "Ad-free active"
                                        : "Monthly subscription",
                                    systemImage: "rectangle.slash"
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Remove ads")
                            .accessibilityValue(
                                AppLocalization.text(
                                    supporterStore.isSupporter ? "Ad-free active" : "Monthly subscription"
                                )
                            )
                            .accessibilityHint("Opens monthly ad-removal options")
                        }

                        settingsSection(title: "App") {
                            SettingsRow(
                                title: "Rate the App",
                                systemImage: "star",
                                accessibilityHint: "Opens the App Store review page"
                            ) {
                                if let url = Self.reviewURL { openURL(url) }
                            }

                            settingsDivider

                            SettingsRow(
                                title: "Privacy",
                                systemImage: "lock",
                                accessibilityHint: "Opens the privacy policy in your browser"
                            ) {
                                openURL(Self.privacyURL)
                            }

                            if TarotAdsConfiguration.bannerID != nil || adConsent.requiresPrivacyOptions {
                                settingsDivider
                                SettingsRow(
                                    title: "Advertising choices",
                                    systemImage: "hand.raised",
                                    accessibilityHint: "Opens advertising privacy choices"
                                ) {
                                    Task { await adConsent.presentChoices() }
                                }
                                .disabled(adConsent.isBusy)
                            }

                            settingsDivider

                            SettingsRow(
                                title: "Help and contact",
                                systemImage: "ellipsis.message",
                                accessibilityHint: "Opens help and contact in your browser"
                            ) {
                                if let url = Self.supportURL { openURL(url) }
                            }
                        }

                        Spacer(minLength: 24)

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
                    .frame(maxWidth: 680, minHeight: max(proxy.size.height - 52, 0), alignment: .top)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 36)
                    .frame(maxWidth: .infinity)
                }
                .scrollIndicators(.hidden)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if isSettingsVisible { TarotBannerSlot(surface: .normal) }
        }
        .onAppear { isSettingsVisible = true }
        .onDisappear { isSettingsVisible = false }
        .task {
            await supporterStore.refreshEntitlements()
            showsSupportReminder = reminder.claimIfEligible(store: supporterStore)
        }
        .alert("Advertising choices unavailable", isPresented: $adConsent.showsError) {
            Button("OK", role: .cancel) { adConsent.showsError = false }
        } message: {
            Text("Ads remain off. You can try again later.")
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
        SettingsSection(title: title, content: content)
    }
}

struct RemoveAdsView: View {
    @ObservedObject var store: SupporterStore

    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.openURL) private var openURL

    private var screenshotPrices: [String] {
        #if DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("--qa-remove-ads"), let index = arguments.firstIndex(of: "--qa-prices"),
           arguments.indices.contains(index + 1) {
            return arguments[index + 1].split(separator: "|").map(String.init)
        }
        #endif
        return []
    }

    private var screenshotActiveProductID: String? {
        #if DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        if screenshotPrices.count == SupporterConfiguration.monthlyProductIDs.count,
           let index = arguments.firstIndex(of: "--qa-active-product"),
           arguments.indices.contains(index + 1),
           SupporterConfiguration.monthlyProductIDs.contains(arguments[index + 1]) {
            return arguments[index + 1]
        }
        #endif
        return nil
    }

    // Screenshot fixtures affect presentation only, never verified StoreKit rights.
    private var displaysActiveSubscription: Bool {
        screenshotActiveProductID != nil || store.isSupporter
    }

    private var columns: [GridItem] {
        dynamicTypeSize.isAccessibilitySize
            ? [GridItem(.flexible(), spacing: 12)]
            : [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
    }

    private var noticeBinding: Binding<Bool> {
        Binding(
            get: { store.notice != nil },
            set: { if !$0 { store.dismissNotice() } }
        )
    }

    var body: some View {
        ZStack {
            CeremonialBackdrop()

            ScrollView {
                VStack(spacing: 22) {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Label("Settings", systemImage: "chevron.left")
                                .font(.system(.title3, design: .serif, weight: .medium))
                                .frame(minHeight: 44)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(CeremonialObsidianTheme.brightGold)
                        Spacer()
                    }

                    Text("Remove ads")
                        .font(.system(.largeTitle, design: .serif, weight: .semibold))
                        .foregroundStyle(CeremonialObsidianTheme.parchment)
                        .multilineTextAlignment(.center)
                        .accessibilityAddTraits(.isHeader)

                    Image(systemName: displaysActiveSubscription ? "checkmark.seal.fill" : "rectangle.slash")
                        .font(.system(size: 52, weight: .light))
                        .foregroundStyle(CeremonialObsidianTheme.brightGold)
                        .frame(width: 76, height: 76)
                        .background(Circle().fill(CeremonialObsidianTheme.cardSurface.opacity(0.9)))
                        .overlay(Circle().stroke(CeremonialObsidianTheme.gold, lineWidth: 1))
                        .accessibilityHidden(true)

                    VStack(spacing: 8) {
                        if displaysActiveSubscription {
                            Text("Ad-free active")
                                .font(.system(.title3, design: .serif, weight: .semibold))
                                .foregroundStyle(CeremonialObsidianTheme.brightGold)
                            Text("Your subscription removes ads. Thank you!")
                                .foregroundStyle(CeremonialObsidianTheme.parchment)
                        } else {
                            Text("Enjoy Tarot Deck without ads.")
                                .foregroundStyle(CeremonialObsidianTheme.parchment)
                            Text("All monthly options remove ads.")
                                .foregroundStyle(CeremonialObsidianTheme.secondaryText)
                        }
                    }
                    .font(.system(.body, design: .serif))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                    Text(AppLocalization.text(displaysActiveSubscription
                         ? "Choose another monthly amount to change your subscription. All options remove ads. Apple shows when the change takes effect before you confirm."
                         : "Choose a monthly option to remove ads. All readings and cards remain free."))
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(CeremonialObsidianTheme.secondaryText)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    if !screenshotPrices.isEmpty {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(Array(screenshotPrices.enumerated()), id: \.offset) { index, price in
                                purchaseOption(
                                    price: price,
                                    isCurrent: SupporterConfiguration.monthlyProductIDs.indices.contains(index)
                                        && SupporterConfiguration.monthlyProductIDs[index] == screenshotActiveProductID,
                                    action: {}
                                )
                                .disabled(true)
                                .allowsHitTesting(false)
                            }
                        }
                    } else if store.isLoadingProducts {
                        ProgressView("Loading subscriptions")
                            .tint(CeremonialObsidianTheme.brightGold)
                            .frame(minHeight: 88)
                    } else if store.products.isEmpty {
                        VStack(spacing: 10) {
                            Text("Subscriptions are temporarily unavailable.")
                                .font(.system(.headline, design: .serif))
                                .foregroundStyle(CeremonialObsidianTheme.parchment)
                            Button("Try Again") {
                                Task { await store.loadProductsIfNeeded() }
                            }
                            .buttonStyle(.bordered)
                            .tint(CeremonialObsidianTheme.brightGold)
                            .frame(minHeight: 44)
                        }
                        .frame(maxWidth: .infinity, minHeight: 120)
                    } else {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(store.products, id: \.id) { product in
                                purchaseOption(
                                    price: product.displayPrice,
                                    isCurrent: product.id == store.activeProductID
                                ) {
                                    Task { await store.purchase(product) }
                                }
                            }
                        }
                    }

                    VStack(spacing: 8) {
                        Text("Each option is a monthly auto-renewable subscription. Payment is charged to your Apple Account and renews automatically until cancelled.")
                        Text("Manage or cancel in your Apple Account. Ads return when your subscription ends.")
                    }
                    .font(.system(.caption, design: .serif))
                    .foregroundStyle(CeremonialObsidianTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(CeremonialObsidianTheme.cardSurface.opacity(0.82))
                            .overlay {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(CeremonialObsidianTheme.gold.opacity(0.65), lineWidth: 1)
                            }
                    }

                    SettingsSection(title: "Subscription") {
                        SettingsRow(
                            title: "Restore Purchases",
                            systemImage: "arrow.clockwise",
                            accessibilityHint: "Restores an active ad-removal subscription"
                        ) {
                            Task { await store.restorePurchases() }
                        }
                        .disabled(!screenshotPrices.isEmpty || store.isRestoring || store.busyProductID != nil)

                        settingsDivider

                        SettingsRow(
                            title: "Manage Subscription",
                            systemImage: "person.crop.circle.badge.checkmark",
                            accessibilityHint: "Opens Apple subscription management"
                        ) {
                            openURL(SupporterConfiguration.manageSubscriptionsURL)
                        }

                        settingsDivider

                        SettingsRow(
                            title: "Privacy",
                            systemImage: "lock",
                            accessibilityHint: "Opens the privacy policy in your browser"
                        ) {
                            openURL(SupporterConfiguration.privacyURL)
                        }

                        settingsDivider

                        SettingsRow(
                            title: "Terms",
                            systemImage: "doc.text",
                            accessibilityHint: "Opens the Apple standard terms of use"
                        ) {
                            openURL(SupporterConfiguration.termsURL)
                        }
                    }
                }
                .frame(maxWidth: 680)
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 36)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.visible)
        }
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .task {
            if screenshotPrices.isEmpty { await store.loadProductsIfNeeded() }
        }
        .alert(
            AppLocalization.text(store.notice?.titleKey ?? "Remove ads"),
            isPresented: noticeBinding
        ) {
            Button("OK") { store.dismissNotice() }
        } message: {
            Text(AppLocalization.text(store.notice?.messageKey ?? ""))
        }
    }

    private func purchaseOption(
        price: String,
        isCurrent: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Text(price)
                    .font(.system(.title3, design: .serif, weight: .semibold))
                Text("per month")
                    .font(.system(.caption, design: .serif))
                    .foregroundStyle(CeremonialObsidianTheme.secondaryText)
                if isCurrent {
                    Label("Current subscription", systemImage: "checkmark.circle.fill")
                        .font(.system(.caption, design: .serif, weight: .semibold))
                        .foregroundStyle(CeremonialObsidianTheme.brightGold)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 64)
            .padding(.horizontal, 8)
            .padding(.vertical, isCurrent ? 8 : 0)
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .fill(CeremonialObsidianTheme.cardSurface.opacity(0.92))
                    .overlay {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(CeremonialObsidianTheme.gold, lineWidth: isCurrent ? 2 : 1)
                    }
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(CeremonialObsidianTheme.parchment)
        .disabled(isCurrent || store.busyProductID != nil || store.isRestoring)
        .accessibilityLabel(
            AppLocalization.format(
                "Remove ads, %@ per month",
                price
            )
        )
        .accessibilityValue(isCurrent ? Text("Current subscription") : Text(""))
        .accessibilityHint(isCurrent
                           ? Text("This subscription is already active")
                           : Text("Starts the Apple purchase confirmation"))
    }

    private var settingsDivider: some View {
        Rectangle()
            .fill(CeremonialObsidianTheme.gold.opacity(0.26))
            .frame(height: 1)
            .padding(.leading, 66)
            .accessibilityHidden(true)
    }
}

private struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
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
                content
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

private struct SettingsRowLabel: View {
    let title: String
    var subtitle: String?
    let systemImage: String

    var body: some View {
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
}

private struct SettingsRow: View {
    let title: String
    var subtitle: String?
    let systemImage: String
    let accessibilityHint: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            SettingsRowLabel(title: title, subtitle: subtitle, systemImage: systemImage)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(AppLocalization.text(title))
        .accessibilityValue(subtitle.map(AppLocalization.text) ?? "")
        .accessibilityHint(Text(AppLocalization.text(accessibilityHint)))
    }
}
