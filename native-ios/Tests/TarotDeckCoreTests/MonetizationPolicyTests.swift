import Foundation
import XCTest
@testable import TarotDeckCore

final class MonetizationPolicyTests: XCTestCase {
    func testBannerRequiresEveryGateAndExcludesEntireReadingContext() {
        for surface in [MonetizationPolicy.Surface.normal, .table, .restoring, .readingMeaning, .readingTutorial] {
            for resolved in [false, true] {
                for supporter in [false, true] {
                    for consent in [false, true] {
                        for started in [false, true] {
                            for active in [false, true] {
                                XCTAssertEqual(MonetizationPolicy.allowsBanner(
                                    surface: surface, entitlementResolved: resolved,
                                    isSupporter: supporter, consentAllowsAds: consent,
                                    sdkStarted: started, isActive: active
                                ), surface == .normal && resolved && !supporter && consent && started && active)
                            }
                        }
                    }
                }
            }
        }
    }

    func testTutorialNavigationKeepsReadingExclusionUntilLeavingContext() {
        func surface(read: Bool = false, learn: Bool = true, active: Bool = true,
                     meaning: Bool = false, contextual: Bool = true, routed: Bool = true) -> MonetizationPolicy.Surface {
            MonetizationPolicy.surface(isReadDestination: read, isLearnDestination: learn,
                readingContextActive: active, hasReadingMeaning: meaning,
                tutorialReturnsToReading: contextual, hasLearnRoute: routed)
        }
        XCTAssertEqual(surface(read: true, learn: false), .table)
        XCTAssertEqual(surface(), .readingTutorial)
        XCTAssertEqual(surface(meaning: true), .readingMeaning)
        XCTAssertEqual(surface(contextual: false), .normal)
        XCTAssertEqual(surface(routed: false), .normal)
        XCTAssertEqual(surface(learn: false), .normal)
        XCTAssertEqual(surface(active: false), .normal)
        XCTAssertFalse(MonetizationPolicy.allowsBanner(surface: surface(), entitlementResolved: true,
            isSupporter: false, consentAllowsAds: true, sdkStarted: true, isActive: true))
    }

    func testReminderBoundaryRollbackAndEveryExclusion() {
        let first = Date(timeIntervalSince1970: 1_800_000_000)
        let boundary = first.addingTimeInterval(MonetizationPolicy.reminderInterval)
        func allowed(_ now: Date, last: Date? = nil, later: Bool = true,
                     optedOut: Bool = false, resolved: Bool = true,
                     supporter: Bool = false, safe: Bool = true) -> Bool {
            MonetizationPolicy.allowsReminder(now: now, firstSeen: first, lastShown: last,
                isLaterLaunch: later, optedOut: optedOut, entitlementResolved: resolved,
                isSupporter: supporter, isSafeSettingsEntry: safe)
        }
        XCTAssertFalse(allowed(first))
        XCTAssertFalse(allowed(boundary.addingTimeInterval(-1)))
        XCTAssertTrue(allowed(boundary))
        XCTAssertFalse(allowed(boundary, later: false))
        XCTAssertFalse(allowed(boundary, optedOut: true))
        XCTAssertFalse(allowed(boundary, resolved: false))
        XCTAssertFalse(allowed(boundary, supporter: true))
        XCTAssertFalse(allowed(boundary, safe: false))
        XCTAssertFalse(allowed(boundary, last: boundary))
        XCTAssertFalse(allowed(boundary, last: boundary.addingTimeInterval(1)))
        XCTAssertFalse(allowed(first.addingTimeInterval(-1)))
        XCTAssertFalse(allowed(boundary.addingTimeInterval(MonetizationPolicy.reminderInterval - 1), last: boundary))
        XCTAssertTrue(allowed(boundary.addingTimeInterval(MonetizationPolicy.reminderInterval), last: boundary))
    }

    func testPersistentClaimsAcrossReopenAndUpgradeAndPermanentOptOut() throws {
        let suite = "TarotReminderTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let first = Date(timeIntervalSince1970: 1_800_000_000)
        let day14 = first.addingTimeInterval(MonetizationPolicy.reminderInterval)
        let initialLaunch = SupportReminderCadence(defaults: defaults, now: first)
        XCTAssertFalse(initialLaunch.claimIfEligible(now: day14,
            entitlementResolved: true, isSupporter: false, isSafeSettingsEntry: true))
        let nextLaunch = SupportReminderCadence(defaults: defaults, now: day14)
        XCTAssertFalse(nextLaunch.claimIfEligible(now: day14,
            entitlementResolved: true, isSupporter: true, isSafeSettingsEntry: true))
        XCTAssertFalse(nextLaunch.claimIfEligible(now: day14,
            entitlementResolved: false, isSupporter: false, isSafeSettingsEntry: true))
        XCTAssertTrue(nextLaunch.claimIfEligible(now: day14,
            entitlementResolved: true, isSupporter: false, isSafeSettingsEntry: true))
        let upgradedProcess = SupportReminderCadence(defaults: defaults, now: day14)
        XCTAssertFalse(upgradedProcess.claimIfEligible(now: day14,
            entitlementResolved: true, isSupporter: false, isSafeSettingsEntry: true))
        let day28 = day14.addingTimeInterval(MonetizationPolicy.reminderInterval)
        XCTAssertTrue(upgradedProcess.claimIfEligible(now: day28,
            entitlementResolved: true, isSupporter: false, isSafeSettingsEntry: true))
        upgradedProcess.optOut()
        let laterProcess = SupportReminderCadence(defaults: defaults, now: day28)
        XCTAssertFalse(laterProcess.claimIfEligible(now: day28.addingTimeInterval(99_999_999),
            entitlementResolved: true, isSupporter: false, isSafeSettingsEntry: true))
    }
}
