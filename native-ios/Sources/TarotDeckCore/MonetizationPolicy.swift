import Foundation

/// Presentation and cadence only. StoreKit and UMP remain the authorities for rights/consent.
public enum MonetizationPolicy {
    public enum Surface: Equatable, Sendable { case normal, table, restoring, readingMeaning, readingTutorial }

    /// A contextual tutorial remains part of a reading, even on the Learn tab.
    public static func surface(
        isReadDestination: Bool, isLearnDestination: Bool, readingContextActive: Bool,
        hasReadingMeaning: Bool, tutorialReturnsToReading: Bool, hasLearnRoute: Bool
    ) -> Surface {
        if hasReadingMeaning { return .readingMeaning }
        if isReadDestination && readingContextActive { return .table }
        if isLearnDestination && readingContextActive && tutorialReturnsToReading && hasLearnRoute {
            return .readingTutorial
        }
        return .normal
    }

    public static func allowsBanner(
        surface: Surface, entitlementResolved: Bool, isSupporter: Bool,
        consentAllowsAds: Bool, sdkStarted: Bool, isActive: Bool
    ) -> Bool {
        surface == .normal && entitlementResolved && !isSupporter
            && consentAllowsAds && sdkStarted && isActive
    }

    public static let reminderInterval: TimeInterval = 14 * 24 * 60 * 60

    public static func allowsReminder(
        now: Date, firstSeen: Date, lastShown: Date?, isLaterLaunch: Bool,
        optedOut: Bool, entitlementResolved: Bool, isSupporter: Bool,
        isSafeSettingsEntry: Bool
    ) -> Bool {
        guard isLaterLaunch, !optedOut, entitlementResolved, !isSupporter,
              isSafeSettingsEntry, now.timeIntervalSince(firstSeen) >= reminderInterval else {
            return false
        }
        return lastShown.map { now.timeIntervalSince($0) >= reminderInterval } ?? true
    }
}
