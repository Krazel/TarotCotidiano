import GoogleMobileAds
import SwiftUI
import TarotDeckCore
import UIKit
import UserMessagingPlatform
import OSLog

/// Removed from the hierarchy (including its request/controller) in excluded contexts.
struct TarotBannerSlot: View {
    let surface: MonetizationPolicy.Surface
    @EnvironmentObject private var supporter: SupporterStore
    @EnvironmentObject private var consent: TarotAdConsent
    @Environment(\.scenePhase) private var scenePhase
    @State private var loadedHeight: CGFloat = 0

    private var eligible: Bool {
        TarotAdsConfiguration.bannerID != nil && MonetizationPolicy.allowsBanner(
            surface: surface, entitlementResolved: supporter.hasResolvedEntitlements,
            isSupporter: supporter.isSupporter, consentAllowsAds: consent.canRequestAds && !consent.isBusy,
            sdkStarted: consent.isStarted, isActive: scenePhase == .active
        )
    }

    var body: some View {
        Group {
            if eligible {
                GeometryReader { proxy in
                    TarotBannerControllerHost(width: proxy.size.width) { loadedHeight = $0 }
                        .id("\(Int(proxy.size.width))-\(consent.requestGeneration)")
                        .onChange(of: proxy.size.width) { _ in loadedHeight = 0 }
                }
                .frame(height: loadedHeight)
                .clipped()
                .allowsHitTesting(loadedHeight > 0)
                .accessibilityHidden(loadedHeight == 0)
                .accessibilityLabel("Advertisement")
                .background(CeremonialObsidianTheme.background)
            }
        }
        .onChange(of: eligible) { _ in loadedHeight = 0 }
        .transaction { $0.animation = nil }
    }
}

private struct TarotBannerControllerHost: UIViewControllerRepresentable {
    let width: CGFloat
    let onHeight: (CGFloat) -> Void

    func makeUIViewController(context: Context) -> TarotBannerController {
        TarotBannerController(width: width, onHeight: onHeight)
    }

    func updateUIViewController(_ controller: TarotBannerController, context: Context) {}

    static func dismantleUIViewController(_ controller: TarotBannerController, coordinator: ()) {
        controller.stop()
    }
}

private final class TarotBannerController: UIViewController, BannerViewDelegate {
    private let width: CGFloat
    private let onHeight: (CGFloat) -> Void
    private var banner: BannerView?
    private var stopped = false

    init(width: CGFloat, onHeight: @escaping (CGFloat) -> Void) {
        self.width = width
        self.onHeight = onHeight
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard width >= 320, let unitID = TarotAdsConfiguration.bannerID,
              ConsentInformationBridge.canRequestAds else { return }
        let adSize = currentOrientationAnchoredAdaptiveBanner(width: width)
        let banner = BannerView(adSize: adSize)
        self.banner = banner
        banner.adUnitID = unitID
        banner.rootViewController = self
        banner.delegate = self
        banner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(banner)
        NSLayoutConstraint.activate([
            banner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            banner.topAnchor.constraint(equalTo: view.topAnchor),
            banner.widthAnchor.constraint(equalToConstant: adSize.size.width),
            banner.heightAnchor.constraint(equalToConstant: adSize.size.height)
        ])
        // GMA consumes UMP/TCF and other applicable privacy signals. Do not
        // overwrite every user's choice with npa=1, or force it with npa=0.
        // The fresh UMP gate above only permits an applicable ad-serving mode.
        let request = Request()
        #if DEBUG
        TarotConsentQAObservation.shared.recordRequest()
        #endif
        banner.load(request)
    }

    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        guard !stopped else { return }
        let logger = Logger(subsystem: "com.krazel.tarotdeck", category: "ads")
        if bannerView.adUnitID == AdvertisingConfiguration.sampleBannerID {
            logger.notice("test_banner_loaded")
        } else {
            logger.notice("production_banner_loaded")
        }
        onHeight(bannerView.adSize.size.height)
    }

    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        guard !stopped else { return }
        onHeight(0)
    }

    func stop() {
        stopped = true
        banner?.delegate = nil
        banner?.removeFromSuperview()
        banner?.rootViewController = nil
        banner = nil
    }
}

// UMP is queried again at the request boundary; the published app flag is not consent storage.
@MainActor
private enum ConsentInformationBridge {
    static var canRequestAds: Bool { ConsentInformation.shared.canRequestAds }
}
