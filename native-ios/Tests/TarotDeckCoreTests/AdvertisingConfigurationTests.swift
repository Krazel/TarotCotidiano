import XCTest
@testable import TarotDeckCore

final class AdvertisingConfigurationTests: XCTestCase {
    // Synthetic identifiers exercise parsing only; these are never used for ad requests.
    private let app = "ca-app-pub-3425091654264901~1234567890"
    private let unit = "ca-app-pub-3425091654264901/1234567890"

    func testDevelopmentOnlyAcceptsCompleteGoogleSampleConfiguration() {
        XCTAssertEqual(AdvertisingConfiguration.bannerID(mode: "test-only",
            applicationID: AdvertisingConfiguration.sampleApplicationID,
            unitID: AdvertisingConfiguration.sampleBannerID, allowsProduction: false),
            AdvertisingConfiguration.sampleBannerID)
        XCTAssertNil(AdvertisingConfiguration.bannerID(mode: "production",
            applicationID: app, unitID: unit, allowsProduction: false))
        XCTAssertNil(AdvertisingConfiguration.bannerID(mode: "test-only",
            applicationID: app, unitID: AdvertisingConfiguration.sampleBannerID, allowsProduction: false))
    }

    func testProductionRequiresExplicitModeAndMatchingPublisher() {
        XCTAssertEqual(AdvertisingConfiguration.bannerID(mode: "production",
            applicationID: app, unitID: unit, allowsProduction: true), unit)
        for mode in [nil, "off", "test-only", "$(TAROT_ADS_MODE)"] {
            XCTAssertNil(AdvertisingConfiguration.bannerID(mode: mode,
                applicationID: app, unitID: unit, allowsProduction: true))
        }
        for invalid in [nil, "", AdvertisingConfiguration.sampleBannerID,
                        "ca-app-pub-3425091654264901/123", "$(TAROT_ADMOB_BANNER_ID)"] {
            XCTAssertNil(AdvertisingConfiguration.bannerID(mode: "production",
                applicationID: app, unitID: invalid, allowsProduction: true))
        }
        XCTAssertNil(AdvertisingConfiguration.bannerID(mode: "production",
            applicationID: AdvertisingConfiguration.sampleApplicationID,
            unitID: unit, allowsProduction: true))
    }
}
