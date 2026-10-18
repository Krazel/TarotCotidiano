import Combine
import Foundation
import StoreKit

enum SupporterConfiguration {
    static let monthlyProductIDs = [
        "com.krazel.tarotdeck.support.monthly.099",
        "com.krazel.tarotdeck.support.monthly.299",
        "com.krazel.tarotdeck.support.monthly.499",
        "com.krazel.tarotdeck.support.monthly.999",
        "com.krazel.tarotdeck.support.monthly.1499",
        "com.krazel.tarotdeck.support.monthly.2999",
        "com.krazel.tarotdeck.support.monthly.50"
    ]

    static let privacyURL = URL(string: "https://krazel.github.io/tarot-deck/privacy/")!
    static let termsURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
    static let manageSubscriptionsURL = URL(string: "https://apps.apple.com/account/subscriptions")!
}

enum SupporterNotice: Equatable {
    case thankYou
    case subscriptionChanged
    case subscriptionChangePending
    case pending
    case purchaseFailed
    case restored
    case nothingToRestore
    case restoreFailed
    case productsUnavailable

    var titleKey: String {
        switch self {
        case .thankYou, .restored:
            return "Ads removed"
        case .subscriptionChanged:
            return "Subscription change confirmed"
        case .subscriptionChangePending:
            return "Subscription change pending"
        case .pending:
            return "Purchase Pending"
        case .purchaseFailed:
            return "Purchase Couldn't Be Completed"
        case .nothingToRestore:
            return "Nothing to Restore"
        case .restoreFailed:
            return "Restore Couldn't Be Completed"
        case .productsUnavailable:
            return "Subscriptions Unavailable"
        }
    }

    var messageKey: String {
        switch self {
        case .thankYou:
            return "Your subscription is active. Enjoy Tarot Deck without ads."
        case .subscriptionChanged:
            return "Apple has confirmed your request. Manage Subscription shows your current subscription and any upcoming change."
        case .subscriptionChangePending:
            return "Apple is still processing this change. Your current subscription remains in effect."
        case .pending:
            return "Apple is still processing this purchase. Ads will be removed once it is approved."
        case .purchaseFailed:
            return "The purchase wasn't completed. The full app remains available."
        case .restored:
            return "Your subscription was restored. Ads are now removed."
        case .nothingToRestore:
            return "No active ad-removal subscription was found for this Apple Account."
        case .restoreFailed:
            return "Purchases couldn't be restored right now. Please try again."
        case .productsUnavailable:
            return "Subscriptions could not be loaded right now. You can keep using the full app."
        }
    }
}

@MainActor
final class SupporterStore: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var isLoadingProducts = false
    @Published private(set) var isSupporter = false
    @Published private(set) var hasResolvedEntitlements = false
    @Published private(set) var activeProductID: String?
    @Published private(set) var busyProductID: String?
    @Published private(set) var isRestoring = false
    @Published var notice: SupporterNotice?

    private var transactionUpdatesTask: Task<Void, Never>?
    private var expirationRefreshTask: Task<Void, Never>?
    private var entitlementRefreshTask: Task<Void, Never>?

    init() {
        transactionUpdatesTask = listenForTransactionUpdates()
    }

    deinit {
        transactionUpdatesTask?.cancel()
        expirationRefreshTask?.cancel()
    }

    func loadProductsIfNeeded() async {
        guard products.isEmpty, !isLoadingProducts else {
            await refreshEntitlements()
            return
        }

        isLoadingProducts = true
        defer { isLoadingProducts = false }
        // Existing subscribers never depend on the product catalog/network succeeding.
        await refreshEntitlements()

        do {
            let order = Dictionary(
                uniqueKeysWithValues: SupporterConfiguration.monthlyProductIDs.enumerated().map {
                    ($0.element, $0.offset)
                }
            )
            let loadedProducts = try await Product.products(
                for: SupporterConfiguration.monthlyProductIDs
            )
                .sorted { (order[$0.id] ?? .max) < (order[$1.id] ?? .max) }
            guard loadedProducts.count == SupporterConfiguration.monthlyProductIDs.count else {
                products = []
                notice = .productsUnavailable
                await refreshEntitlements()
                return
            }
            products = loadedProducts
            await refreshEntitlements()
        } catch {
            notice = .productsUnavailable
        }
    }

    func purchase(_ product: Product) async {
        guard SupporterConfiguration.monthlyProductIDs.contains(product.id),
              product.id != activeProductID,
              busyProductID == nil, !isRestoring else {
            return
        }

        let isChangingSubscription = isSupporter
        busyProductID = product.id
        defer { busyProductID = nil }

        do {
            switch try await product.purchase() {
            case .success(let verification):
                let transaction = try verified(verification)
                await transaction.finish()
                await refreshEntitlements(forceRefresh: true)
                notice = isChangingSubscription ? .subscriptionChanged
                    : (isSupporter ? .thankYou : .purchaseFailed)
            case .pending:
                notice = isChangingSubscription ? .subscriptionChangePending : .pending
            case .userCancelled:
                break
            @unknown default:
                notice = .purchaseFailed
            }
        } catch {
            notice = .purchaseFailed
        }
    }

    func restorePurchases() async {
        guard !isRestoring, busyProductID == nil else { return }
        isRestoring = true
        defer { isRestoring = false }

        do {
            try await AppStore.sync()
            await refreshEntitlements(forceRefresh: true)
            notice = isSupporter ? .restored : .nothingToRestore
        } catch {
            notice = .restoreFailed
        }
    }

    func refreshEntitlements(forceRefresh: Bool = false) async {
        if let entitlementRefreshTask {
            await entitlementRefreshTask.value
            // A purchase/restore/update must not reuse a scan begun before that event.
            if forceRefresh { await resolveEntitlements() }
            return
        }
        let task = Task<Void, Never> { [weak self] in
            guard let self else { return }
            await self.resolveEntitlements()
        }
        entitlementRefreshTask = task
        await task.value
        entitlementRefreshTask = nil
    }

    private func resolveEntitlements() async {
        var verifiedProductID: String?
        var nextExpiration: Date?
        var hasUnverifiedSupport = false
        for await result in Transaction.currentEntitlements {
            if case .unverified(let transaction, _) = result,
               SupporterConfiguration.monthlyProductIDs.contains(transaction.productID) {
                hasUnverifiedSupport = true
            }
            guard let transaction = try? verified(result),
                  SupporterConfiguration.monthlyProductIDs.contains(transaction.productID),
                  transaction.revocationDate == nil, !transaction.isUpgraded else {
                continue
            }
            verifiedProductID = transaction.productID
            if let expiration = transaction.expirationDate {
                nextExpiration = min(nextExpiration ?? expiration, expiration)
            }
        }
        activeProductID = verifiedProductID
        isSupporter = verifiedProductID != nil
        hasResolvedEntitlements = isSupporter || !hasUnverifiedSupport
        expirationRefreshTask?.cancel()
        if let nextExpiration {
            // currentEntitlements also covers Apple's billing grace period. A past
            // expiration is not itself a revocation; ask StoreKit again during grace.
            let delay = nextExpiration > Date()
                ? max(1, nextExpiration.timeIntervalSinceNow + 1) : 60
            expirationRefreshTask = Task { [weak self] in
                do { try await Task.sleep(nanoseconds: UInt64(min(delay, 86_400) * 1_000_000_000)) }
                catch { return }
                await self?.refreshEntitlements()
            }
        }
    }

    func dismissNotice() {
        notice = nil
    }

    func invalidateEntitlements() {
        // Re-entering the foreground must not briefly show ads using stale rights.
        hasResolvedEntitlements = false
    }

    private func listenForTransactionUpdates() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                guard let transaction = try? self.verified(result) else { continue }
                await transaction.finish()
                if SupporterConfiguration.monthlyProductIDs.contains(transaction.productID) {
                    await self.refreshEntitlements(forceRefresh: true)
                }
            }
        }
    }

    private func verified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value):
            return value
        case .unverified:
            throw SupporterVerificationError.failed
        }
    }
}

private enum SupporterVerificationError: Error {
    case failed
}
