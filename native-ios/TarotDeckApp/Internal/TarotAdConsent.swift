import Combine
import Foundation
import GoogleMobileAds
import UIKit
import UserMessagingPlatform
import TarotDeckCore
import OSLog

enum TarotAdsConfiguration {
    static var bannerID: String? {
        #if DEBUG || TAROT_TEST_ADS
        let allowsProduction = false
        #elseif TAROT_PRODUCTION_ADS
        guard Bundle.main.bundleIdentifier == "com.krazel.tarotdeck" else { return nil }
        let allowsProduction = true
        #else
        return nil
        #endif
        #if DEBUG || TAROT_TEST_ADS || TAROT_PRODUCTION_ADS
        return AdvertisingConfiguration.bannerID(
            mode: Bundle.main.object(forInfoDictionaryKey: "TarotAdvertisingMode") as? String,
            applicationID: Bundle.main.object(forInfoDictionaryKey: "GADApplicationIdentifier") as? String,
            unitID: Bundle.main.object(forInfoDictionaryKey: "TarotBannerAdUnitID") as? String,
            allowsProduction: allowsProduction
        )
        #endif
    }
}

@MainActor
final class TarotAdConsent: ObservableObject {
    @Published private(set) var canRequestAds = false
    @Published private(set) var isStarted = false
    @Published private(set) var requiresPrivacyOptions = false
    @Published private(set) var isBusy = false
    @Published private(set) var requestGeneration = 0
    @Published var showsError = false
    private var didUpdateThisLaunch = false
    private var isStarting = false
    private var automaticPresentationAllowed = false
    private let logger = Logger(subsystem: "com.krazel.tarotdeck", category: "ads")

    func setAutomaticPresentationAllowed(_ allowed: Bool) {
        automaticPresentationAllowed = allowed
        if allowed { Task { await updateIfNeeded() } }
    }

    private func requestParameters() -> RequestParameters {
        let parameters = RequestParameters()
        #if DEBUG
        // Simulator QA only. Release/TestFlight always uses the user's real geography.
        if ProcessInfo.processInfo.arguments.contains("--qa-consent-eea") {
            let debug = DebugSettings()
            debug.geography = .EEA
            parameters.debugSettings = debug
        }
        #endif
        return parameters
    }

    /// Collect the first required choice automatically; Settings remains available
    /// for subsequent changes. Never bypass UMP or present over a reading.
    func updateIfNeeded() async {
        guard TarotAdsConfiguration.bannerID != nil, !didUpdateThisLaunch, !isBusy else { return }
        isBusy = true
        defer { isBusy = false }
        do {
            didUpdateThisLaunch = try await ConsentLaunchSequence.run(
                refresh: {
                    try await ConsentInformation.shared.requestConsentInfoUpdate(with: self.requestParameters())
                },
                requiresForm: { ConsentInformation.shared.consentStatus == .required },
                mayPresent: { self.automaticPresentationAllowed },
                load: { try await ConsentForm.load() },
                present: { form in
                    self.logger.notice("consent_form_presenting")
                    try await form.present(from: nil)
                },
                finish: {
                    self.refreshState()
                    await self.startIfAllowed()
                }
            )
        } catch {
            // Fail closed on update errors, including a missing UMP console configuration.
            canRequestAds = false
            requiresPrivacyOptions = ConsentInformation.shared.privacyOptionsRequirementStatus == .required
            didUpdateThisLaunch = false
            logger.error("automatic_consent_failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    func presentChoices() async {
        guard TarotAdsConfiguration.bannerID != nil, !isBusy else { return }
        isBusy = true
        canRequestAds = false
        requestGeneration += 1 // Destroy all existing requests before changing choices.
        defer { isBusy = false }
        do {
            try await ConsentInformation.shared.requestConsentInfoUpdate(with: RequestParameters())
            if ConsentInformation.shared.consentStatus == .required {
                try await ConsentForm.loadAndPresentIfRequired(from: nil)
            } else if ConsentInformation.shared.privacyOptionsRequirementStatus == .required {
                try await ConsentForm.presentPrivacyOptionsForm(from: nil)
            } else {
                try await ConsentForm.loadAndPresentIfRequired(from: nil)
            }
            didUpdateThisLaunch = true
            refreshState()
            await startIfAllowed()
        } catch {
            // Do not reuse a previous request or consent flag after a failed choices flow.
            canRequestAds = false
            showsError = true
        }
    }

    private func refreshState() {
        canRequestAds = ConsentInformation.shared.canRequestAds
        requiresPrivacyOptions = ConsentInformation.shared.privacyOptionsRequirementStatus == .required
    }

    private func startIfAllowed() async {
        guard canRequestAds, !isStarted, !isStarting else { return }
        isStarting = true
        let configuration = MobileAds.shared.requestConfiguration
        configuration.setPublisherFirstPartyIDEnabled(false)
        configuration.publisherPrivacyPersonalizationState = .disabled
        _ = await MobileAds.shared.start()
        isStarted = true
        isStarting = false
    }
}
