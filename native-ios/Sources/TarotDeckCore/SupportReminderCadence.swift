import Foundation

/// Local-only persistent cadence. Keys are stable across app upgrades.
public struct SupportReminderCadence {
    private let defaults: UserDefaults
    private let firstSeen: Date
    private let isLaterLaunch: Bool
    private let prefix = "tarot.supportReminder.v1."

    public init(defaults: UserDefaults = .standard, now: Date = Date()) {
        self.defaults = defaults
        let previous = defaults.object(forKey: "tarot.supportReminder.v1.firstSeen") as? Date
        firstSeen = previous ?? now
        isLaterLaunch = previous != nil
        if previous == nil { defaults.set(now, forKey: prefix + "firstSeen") }
    }

    /// Claim before rendering; repeated entries retain the same cooldown.
    public func claimIfEligible(
        now: Date = Date(), entitlementResolved: Bool, isSupporter: Bool,
        isSafeSettingsEntry: Bool
    ) -> Bool {
        guard MonetizationPolicy.allowsReminder(
            now: now, firstSeen: firstSeen,
            lastShown: defaults.object(forKey: prefix + "lastShown") as? Date,
            isLaterLaunch: isLaterLaunch, optedOut: defaults.bool(forKey: prefix + "optedOut"),
            entitlementResolved: entitlementResolved, isSupporter: isSupporter,
            isSafeSettingsEntry: isSafeSettingsEntry
        ) else { return false }
        defaults.set(now, forKey: prefix + "lastShown")
        return true
    }

    public func optOut() { defaults.set(true, forKey: prefix + "optedOut") }
}
