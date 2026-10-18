import Combine
import Foundation
import TarotDeckCore

@MainActor
final class SupportReminderStore: ObservableObject {
    private let cadence: SupportReminderCadence

    init(defaults: UserDefaults = .standard, now: Date = Date()) {
        cadence = SupportReminderCadence(defaults: defaults, now: now)
    }

    /// Claim before rendering; repeated entries and upgrades retain the same cooldown.
    func claimIfEligible(store: SupporterStore, now: Date = Date()) -> Bool {
        cadence.claimIfEligible(now: now,
            entitlementResolved: store.hasResolvedEntitlements, isSupporter: store.isSupporter,
            isSafeSettingsEntry: true
        )
    }

    func optOut() { cadence.optOut() }
}
