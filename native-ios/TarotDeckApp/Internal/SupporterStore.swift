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
    case pending
    case purchaseFailed
    case restored
    case nothingToRestore
    case restoreFailed
    case productsUnavailable

    var titleKey: String {
        switch self {
        case .thankYou, .restored:
            return "Thank You"
        case .pending:
            return "Purchase Pending"
        case .purchaseFailed:
            return "Purchase Couldn't Be Completed"
        case .nothingToRestore:
            return "Nothing to Restore"
        case .restoreFailed:
            return "Restore Couldn't Be Completed"
        case .productsUnavailable:
            return "Support Options Unavailable"
        }
    }

    var messageKey: String {
        switch self {
        case .thankYou:
            return "Your supporter status is active. Thank you for helping maintain Tarot Deck and future updates."
        case .pending:
            return "Apple is still processing this purchase. Supporter status will update after approval."
        case .purchaseFailed:
            return "The purchase wasn't completed. The full app remains available."
        case .restored:
            return "Your active supporter status was restored. Thank you for supporting the app."
        case .nothingToRestore:
            return "No active monthly support subscription was found for this Apple Account."
        case .restoreFailed:
            return "Purchases couldn't be restored right now. Please try again."
        case .productsUnavailable:
            return "Monthly support options couldn't be loaded right now. The full app remains available."
        }
    }
}

@MainActor
final class SupporterStore: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var isLoadingProducts = false
    @Published private(set) var isSupporter = false
    @Published private(set) var activeProductID: String?
    @Published private(set) var busyProductID: String?
    @Published private(set) var isRestoring = false
    @Published var notice: SupporterNotice?

    private var transactionUpdatesTask: Task<Void, Never>?

    init() {
        transactionUpdatesTask = listenForTransactionUpdates()
    }

    deinit {
        transactionUpdatesTask?.cancel()
    }

    func loadProductsIfNeeded() async {
        guard products.isEmpty, !isLoadingProducts else {
            await refreshEntitlements()
            return
        }

        isLoadingProducts = true
        defer { isLoadingProducts = false }

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
        guard SupporterConfiguration.monthlyProductIDs.contains(product.id), busyProductID == nil else {
            return
        }

        busyProductID = product.id
        defer { busyProductID = nil }

        do {
            switch try await product.purchase() {
            case .success(let verification):
                let transaction = try verified(verification)
                await transaction.finish()
                await refreshEntitlements()
                notice = isSupporter ? .thankYou : .purchaseFailed
            case .pending:
                notice = .pending
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
        guard !isRestoring else { return }
        isRestoring = true
        defer { isRestoring = false }

        do {
            try await AppStore.sync()
            await refreshEntitlements()
            notice = isSupporter ? .restored : .nothingToRestore
        } catch {
            notice = .restoreFailed
        }
    }

    func refreshEntitlements() async {
        var verifiedProductID: String?
        for await result in Transaction.currentEntitlements {
            guard let transaction = try? verified(result),
                  SupporterConfiguration.monthlyProductIDs.contains(transaction.productID),
                  transaction.revocationDate == nil else {
                continue
            }
            verifiedProductID = transaction.productID
            break
        }
        activeProductID = verifiedProductID
        isSupporter = verifiedProductID != nil
    }

    func dismissNotice() {
        notice = nil
    }

    private func listenForTransactionUpdates() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                guard let transaction = try? self.verified(result) else { continue }
                await transaction.finish()
                if SupporterConfiguration.monthlyProductIDs.contains(transaction.productID) {
                    await self.refreshEntitlements()
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
