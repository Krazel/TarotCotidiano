# Inventory and implementation plan — 2026-10-18

Authority: delegated human brief of 18 October; implementation owner for this scope only. No build, CI, Apple mutation, release, live ad activation, spending, commit or push.

## Audited baseline

- Public version 1.0 per owner; APP_STORE_RECORD describes publication while STATUS still describes an older candidate. No launch is repeated and version/build remain untouched.
- Seven canonical monthly IDs in SupporterConfiguration agree with store/tarot-subscriptions.v1.json; one equivalent level, live Product.displayPrice, no feature gating. Historical Apple group 22318147. These are source/historical facts, not a fresh Apple-server check.
- SupporterStore verifies purchase and currentEntitlements, finishes verified transactions, listens to updates, and restores via AppStore.sync. Gaps: no app-start/foreground entitlement gate, no upgraded-transaction filter, and a failed product lookup can skip entitlement refresh. No migration or additional product is needed.
- ReadFlowModel.surface is restoring/home/table. A table exists before the first session and survives shuffle, reveal, rotation and overlays. Therefore banner exclusion must use surface rather than drawn-card count/session alone. Card meaning is a shell sheet; tutorials navigate to Learn and may show ads. Existing home/settings and learning/cards compositions remain authoritative.
- Voice Recorder reference audited read-only: Audio/native-ios/Sources/{RootView,AdMobBannerView,AdConsentManager,MonetizationStore,AudioRecorderApp}.swift and native-ios/project.yml. Pattern: UIKit BannerView in SwiftUI, hidden loading/failure space, supporter gate, UMP canRequestAds and single SDK start. Its fixed 320x50 layout and ATT policy are not imported; no product identifiers, real ad IDs, contacts or credentials are reused.
- Preserve two pre-existing modified technical documents and eight untracked historical PNGs. AGENTS/STATUS/DECISIONS, docs/coordination, canonical design manifests and the other chat's proposal directory are outside ownership.

## Concrete plan

1. Record complete code-native visual references in design/monetization-20261018 before changing UI: ordinary screen/banner, table/no reserved space, voluntary settings reminder/support benefit.
2. Add pure core policy + XCTest matrix for eligibility and persistent 14-day reminder dates; retain all seven IDs/benefits. CurrentEntitlements is Apple's authority, including grace periods; do not infer lapse from a transaction date alone.
3. Use GMA 12.14.0 and UMP 3.1.0 exact versions matching the audited working reference and confirmed official package manifests; iOS16 remains. Debug uses only Google's documented sample application/banner IDs. Release serves no ads; no real configuration is invented.
4. Single consent controller: delay UMP presentation until an explicit safe Settings action; refresh info on each eligible process launch, re-check immediately before presentation and requests; UMP privacy-choice entry. No ATT request/usage string, no IDFA code, publisher personalization/first-party ID disabled, npa request, no mediation/analytics.
5. One shared banner host, destroyed synchronously on table/meaning/restoring/supporter/background/consent exclusion. Adaptive safe-width size, no height until load, no animation during removal, no controls covered. Settings sheets have their own host while shell banner is suspended.
6. Optional inline reminder only on Settings entry after 14 elapsed days and a later launch; persistent last-shown claim before display, Not Now and Don't Ask Again, no delayed pop-up or per-screen repetition.
7. Update scoped product contract and privacy/Apple preparation notes; run local static/content/integration validators and diff checks. Add XCTest cases but do not claim execution: this Windows host lacks Swift/Xcode and new app builds are excluded.

Official sources checked 2026-10-18: [Google setup](https://developers.google.com/admob/ios/quick-start), [UMP](https://developers.google.com/admob/ios/privacy), [SDK release notes](https://developers.google.com/admob/ios/rel-notes), [privacy strategies](https://developers.google.com/admob/ios/privacy/strategies), [data disclosure](https://developers.google.com/admob/ios/privacy/data-disclosure), [Apple current entitlements](https://developer.apple.com/documentation/storekit/transaction/currententitlements), [Apple subscriptions](https://developer.apple.com/app-store/subscriptions/). SDK versions are deliberate reference-compatible pins, not a claim of latest release.
