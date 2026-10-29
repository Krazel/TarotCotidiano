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
    #if DEBUG
    /// Runner-only CMP audit: Tarot's message configuration, Google's sample inventory.
    /// Every input is pinned; the flag cannot enable production inventory or Release.
    static var publisherMessageQAEnabled: Bool {
        #if targetEnvironment(simulator)
        return Bundle.main.object(forInfoDictionaryKey: "TarotPublisherMessageQA") as? Bool == true
            && Bundle.main.bundleIdentifier == "com.krazel.tarotdeck.internal.provisional"
            && Bundle.main.object(forInfoDictionaryKey: "TarotAdvertisingMode") as? String == "test-only"
            && Bundle.main.object(forInfoDictionaryKey: "GADApplicationIdentifier") as? String
                == "ca-app-pub-3425091654264901~4270953811"
            && Bundle.main.object(forInfoDictionaryKey: "TarotBannerAdUnitID") as? String
                == AdvertisingConfiguration.sampleBannerID
        #else
        return false
        #endif
    }
    #endif

    static var bannerID: String? {
        #if DEBUG
        if publisherMessageQAEnabled { return AdvertisingConfiguration.sampleBannerID }
        #endif
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
    #if DEBUG
    // Capture the real OS state before any UMP reset/update/presentation.
    private let qaInitialTrackingAuthorizationRaw = ATTrackingManager.trackingAuthorizationStatus.rawValue
    #endif

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
        if ProcessInfo.processInfo.arguments.contains("--qa-consent-us") {
            let debug = DebugSettings()
            debug.geography = .regulatedUSState
            parameters.debugSettings = debug
        } else if ProcessInfo.processInfo.arguments.contains("--qa-consent-eea") {
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
        var values: [String: Any] = [
            "updateCompleted": didUpdateThisLaunch, "busy": isBusy,
            "canRequestAds": canRequestAds,
            "umpCanRequestAds": ConsentInformation.shared.canRequestAds,
            "sdkStarted": isStarted, "requestCount": requestCount,
            "formPresentations": formPresentations,
            "loadedBannerCount": loadedBannerCount,
            "initialTrackingAuthorizationRaw": qaInitialTrackingAuthorizationRaw,
            "trackingAuthorization": qaTrackingAuthorization,
            "automaticPresentationAllowed": automaticPresentationAllowed,
            "bannerConfigured": TarotAdsConfiguration.bannerID != nil,
            "publisherMessageQA": TarotAdsConfiguration.publisherMessageQAEnabled,
            "requiresPrivacyOptions": requiresPrivacyOptions,
            "consentStatus": ConsentInformation.shared.consentStatus.rawValue,
            "formStatus": ConsentInformation.shared.formStatus.rawValue,
            "purposeConsents": UserDefaults.standard.string(forKey: "IABTCF_PurposeConsents") ?? "",
            "vendorConsents": UserDefaults.standard.string(forKey: "IABTCF_VendorConsents") ?? ""
        ]
        if TarotAdsConfiguration.publisherMessageQAEnabled {
            values.merge(TarotGPPQAObservation.read()) { _, observed in observed }
        }
        guard let data = try? JSONSerialization.data(withJSONObject: values, options: .sortedKeys),
              let text = String(data: data, encoding: .utf8) else { return "{}" }
        return text
    }
    #endif
}

#if DEBUG
/// Observation only, never an advertising/ATT gate. UMP only writes the SID and
/// encoded string. Read it transiently; expose no encoded string or identifier.
/// Sources: developers.google.com/admob/ios/privacy/us-iab-support
/// github.com/InteractiveAdvertisingBureau/Global-Privacy-Platform/blob/main/Core/Consent%20String%20Specification.md
/// github.com/InteractiveAdvertisingBureau/Global-Privacy-Platform/tree/main/Sections/US-National
/// github.com/IABTechLab/iabgpp-es/blob/master/modules/cmpapi/src/encoder/segment/UsNatCoreSegment.ts
/// Scope: US National section 7 v1/v2. Other sections/versions are indeterminate.
private enum TarotGPPQAObservation {
    private enum Invalid: Error { case signal }

    private struct Bits {
        private let bits: [Int]
        private var position = 0

        init(_ encoded: Substring) throws {
            let alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_")
            guard !encoded.isEmpty, encoded.count <= 4096 else { throw Invalid.signal }
            var result: [Int] = []
            for character in encoded {
                guard let value = alphabet.firstIndex(of: character) else { throw Invalid.signal }
                for shift in (0..<6).reversed() { result.append((value >> shift) & 1) }
            }
            bits = result
        }

        mutating func take(_ count: Int) throws -> Int {
            guard count > 0, count <= 16, position + count <= bits.count else { throw Invalid.signal }
            let value = bits[position..<(position + count)].reduce(0) { ($0 << 1) | $1 }
            position += count
            return value
        }

        mutating func fibonacci() throws -> Int {
            var current = 1, next = 2, previousBit = 0, value = 0
            // Section IDs are bounded; reject truncated/unbounded inputs.
            for _ in 0..<20 {
                let bit = try take(1)
                if bit == 1 && previousBit == 1 { return value }
                if bit == 1 { value += current }
                (current, next) = (next, current + next)
                previousBit = bit
            }
            throw Invalid.signal
        }

        func validatePadding() throws {
            // IAB compressed base64 pads to a byte boundary, then six bits.
            let paddedLength = (((position + 7) / 8 * 8) + 5) / 6 * 6
            guard bits.count == paddedLength, bits[position...].allSatisfy({ $0 == 0 })
            else { throw Invalid.signal }
        }
    }

    static func read() -> [String: Any] {
        let defaults = UserDefaults.standard
        return observe(encoded: defaults.string(forKey: "IABGPP_HDR_GppString") ?? "",
                       sid: defaults.string(forKey: "IABGPP_GppSID"))
    }

    static func observe(encoded: String, sid: String?) -> [String: Any] {
        var output: [String: Any] = ["gppPresent": !encoded.isEmpty,
                                      "gppSectionIDs": [Int](), "gppObservation": "indeterminate"]
        guard let sid, !sid.isEmpty,
              sid.count <= 128 else { return output }
        let parts = sid.split(separator: "_", omittingEmptySubsequences: false)
        let ids = parts.compactMap { Int($0) }
        guard ids.count == parts.count, Set(ids).count == ids.count,
              parts.map(String.init) == ids.map(String.init),
              ids.allSatisfy({ $0 == -1 || (1...4095).contains($0) }) else { return output }
        output["gppSectionIDs"] = ids
        // The regulated-US-state simulator exercises the US National message.
        // Do not interpret Florida/another active section using National offsets.
        guard ids == [7], !encoded.isEmpty, encoded.count <= 8192 else { return output }
        do {
            let sections = encoded.split(separator: "~", omittingEmptySubsequences: false)
            guard sections.count >= 2 else { throw Invalid.signal }
            var header = try Bits(sections[0])
            guard try header.take(6) == 3, try header.take(6) == 1 else { throw Invalid.signal }
            let count = try header.take(12)
            guard (1...64).contains(count) else { throw Invalid.signal }
            var sectionIDs: [Int] = []
            var last = 0
            for _ in 0..<count {
                let range = try header.take(1) == 1
                let start = last + (try header.fibonacci())
                let end = range ? start + (try header.fibonacci()) : start
                guard start > last, end <= 4095, end - start < 64,
                      sectionIDs.count + end - start + 1 <= 64 else { throw Invalid.signal }
                sectionIDs.append(contentsOf: start...end)
                last = end
            }
            try header.validatePadding()
            guard sections.count == sectionIDs.count + 1,
                  let index = sectionIDs.firstIndex(of: 7) else { throw Invalid.signal }
            let segments = sections[index + 1].split(separator: ".", omittingEmptySubsequences: false)
            guard (1...2).contains(segments.count) else { throw Invalid.signal }
            var core = try Bits(segments[0])
            let version = try core.take(6)
            guard version == 1 || version == 2 else { throw Invalid.signal }
            // Six notices; three opt-outs; sensitive/child arrays; personal
            // consent; three MSPA fields. Full core length and value validation.
            let fieldCount = version == 1 ? 27 : 32
            var fields: [Int] = []
            for _ in 0..<fieldCount {
                let value = try core.take(2)
                guard (0...2).contains(value) else { throw Invalid.signal }
                fields.append(value)
            }
            guard fields[fieldCount - 3] != 0 else { throw Invalid.signal }
            try core.validatePadding()
            if segments.count == 2 {
                var gpc = try Bits(segments[1])
                guard try gpc.take(2) == 1 else { throw Invalid.signal }
                _ = try gpc.take(1)
                try gpc.validatePadding()
            }
            output["gppObservation"] = "usNationalV\(version)"
            output["gppSaleOptOut"] = fields[6]
            output["gppSharingOptOut"] = fields[7]
            output["gppTargetedAdvertisingOptOut"] = fields[8]
        } catch {
            // Missing, malformed and unsupported are never converted to false.
            output["gppObservation"] = "indeterminate"
        }
        return output
    }
}

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
