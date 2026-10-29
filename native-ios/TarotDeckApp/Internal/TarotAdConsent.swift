import Combine
import Foundation
import GoogleMobileAds
import UIKit
import UserMessagingPlatform
import TarotDeckCore
import OSLog
import AppTrackingTransparency
#if DEBUG
import SwiftUI
#endif

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

    init() {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--qa-consent-reset") {
            // Actual UMP reset in a simulator test installation; never a fake choice.
            ConsentInformation.shared.reset()
        }
        #endif
    }

    func setAutomaticPresentationAllowed(_ allowed: Bool) {
        automaticPresentationAllowed = allowed
        if allowed { Task { await updateIfNeeded() } }
    }

    /// Re-read both current CMP signals and OS permissions after Settings changes.
    /// An ATT sheet also changes scene phase: never interrupt an in-flight UMP flow.
    func applicationDidBecomeActive() {
        guard !isBusy else { return }
        canRequestAds = false
        requestGeneration += 1
        didUpdateThisLaunch = false
        Task { await updateIfNeeded() }
    }

    private func requestParameters() -> RequestParameters {
        let parameters = RequestParameters()
        #if DEBUG
        // Simulator QA only. Release/TestFlight always uses the user's real geography.
        if ProcessInfo.processInfo.arguments.contains("--qa-consent-eea") {
            let debug = DebugSettings()
            debug.geography = .EEA
            parameters.debugSettings = debug
        } else if ProcessInfo.processInfo.arguments.contains("--qa-consent-non-eea") {
            // Isolate the no-regional-form banner smoke test from runner geography.
            // EEA acceptance/refusal is tested separately; never used in Release.
            let debug = DebugSettings()
            debug.geography = .other
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
                // UMP 3.1's official loadAndPresentIfRequired uses this same status.
                // With both AdMob messages configured UMP coordinates GDPR then ATT;
                // do not derive tracking consent from canRequestAds or call ATT again.
                requiresForm: { ConsentInformation.shared.consentStatus == .required },
                mayPresent: { self.automaticPresentationAllowed },
                load: { try await ConsentForm.load() },
                present: { form in
                    self.logger.notice("consent_form_presenting")
                    #if DEBUG
                    TarotConsentQAObservation.shared.recordForm()
                    #endif
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
            try await ConsentInformation.shared.requestConsentInfoUpdate(with: requestParameters())
            if ConsentInformation.shared.consentStatus == .required {
                #if DEBUG
                TarotConsentQAObservation.shared.recordForm()
                #endif
                try await ConsentForm.loadAndPresentIfRequired(from: nil)
            } else if ConsentInformation.shared.privacyOptionsRequirementStatus == .required {
                #if DEBUG
                TarotConsentQAObservation.shared.recordForm()
                #endif
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
        guard canRequestAds else { return }
        let configuration = MobileAds.shared.requestConfiguration
        // Explicitly undo the persisted 1.2 publisher opt-out for upgrading users.
        // This is a publisher-scoped ID, not a replacement for denied ATT/IDFA.
        // GMA still applies UMP/TCF, regional opt-outs and the OS permission.
        configuration.setPublisherFirstPartyIDEnabled(true)
        // No additional app-wide opt-out: let the SDK apply the user's choices.
        // Never use .enabled or infer personalization from canRequestAds.
        configuration.publisherPrivacyPersonalizationState = .default
        guard !isStarted, !isStarting else { return }
        isStarting = true
        _ = await MobileAds.shared.start()
        isStarted = true
        isStarting = false
    }

    #if DEBUG
    private var qaTrackingAuthorization: String {
        switch ATTrackingManager.trackingAuthorizationStatus {
        case .notDetermined: return "notDetermined"
        case .restricted: return "restricted"
        case .denied: return "denied"
        case .authorized: return "authorized"
        @unknown default: return "unknown"
        }
    }

    func qaState(requestCount: Int, formPresentations: Int, loadedBannerCount: Int) -> String {
        let values: [String: Any] = [
            "updateCompleted": didUpdateThisLaunch, "busy": isBusy,
            "canRequestAds": canRequestAds,
            "umpCanRequestAds": ConsentInformation.shared.canRequestAds,
            "sdkStarted": isStarted, "requestCount": requestCount,
            "formPresentations": formPresentations,
            "loadedBannerCount": loadedBannerCount,
            "trackingAuthorization": qaTrackingAuthorization,
            "automaticPresentationAllowed": automaticPresentationAllowed,
            "bannerConfigured": TarotAdsConfiguration.bannerID != nil,
            "consentStatus": ConsentInformation.shared.consentStatus.rawValue,
            "formStatus": ConsentInformation.shared.formStatus.rawValue,
            "purposeConsents": UserDefaults.standard.string(forKey: "IABTCF_PurposeConsents") ?? "",
            "vendorConsents": UserDefaults.standard.string(forKey: "IABTCF_VendorConsents") ?? ""
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: values, options: .sortedKeys),
              let text = String(data: data, encoding: .utf8) else { return "{}" }
        return text
    }
    #endif
}

#if DEBUG
/// Read-only observations of real SDK calls. No identifiers or TCString are exposed.
@MainActor
final class TarotConsentQAObservation: ObservableObject {
    static let shared = TarotConsentQAObservation()
    @Published private(set) var requestCount = 0
    @Published private(set) var formPresentations = 0
    @Published private(set) var loadedBannerCount = 0
    func recordRequest() { requestCount += 1 }
    func recordForm() { formPresentations += 1 }
    func recordLoadedBanner() { loadedBannerCount += 1 }
}

@MainActor
struct TarotConsentQAView: View {
    @ObservedObject var consent: TarotAdConsent
    @ObservedObject private var observation = TarotConsentQAObservation.shared
    var body: some View {
        let state = consent.qaState(requestCount: observation.requestCount,
                                    formPresentations: observation.formPresentations,
                                    loadedBannerCount: observation.loadedBannerCount)
        // Keep observation out of the Settings button's hit-test area. The
        // complete read-only JSON remains available to XCTest, not on screen.
        Text(verbatim: "Consent QA")
            .font(.system(size: 8))
            .fixedSize()
            .foregroundStyle(.white)
            .background(.black)
            .accessibilityLabel(state)
            .accessibilityValue(state)
            .accessibilityIdentifier("tarot.qa.consent-state")
            .allowsHitTesting(false)
    }
}
#endif
