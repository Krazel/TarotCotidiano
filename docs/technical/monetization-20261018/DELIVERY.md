> Entrega histórica de preparación. Sustituida para el estado actual por [TESTFLIGHT.md](TESTFLIGHT.md): 1.1 (1) ya está en TestFlight interno. Las limitaciones de Debug, ausencia de CI y tutorial elegible de este documento son anteriores a esa entrega.

# Delivery — prepared banner and supporter integration

18/10/2026 · Tarot Deck / Tarot Cotidiano · implementation owner for the delegated scope.

**Outcome: local code and contracts prepared; no new app build and no active advertising.** Public version remains 1.0 per owner. Source version/build 1.0(1) was deliberately not changed; this is not a claim about which public binary is current. No CI, archive/IPA, TestFlight, App Review, release, Apple/AdMob configuration, repository visibility, payment, commit or push occurred. D1 PR-003 remains the central brain's responsibility; this task made no library write or duplicate product.

## Files and ownership

| Area | Files |
|---|---|
| Eligibility and persistent reminder | `native-ios/Sources/TarotDeckCore/MonetizationPolicy.swift`, `SupportReminderCadence.swift`; `native-ios/Tests/TarotDeckCoreTests/MonetizationPolicyTests.swift` |
| StoreKit rights | `native-ios/TarotDeckApp/Internal/SupporterStore.swift` |
| Consent/test configuration and reminder bridge | `native-ios/TarotDeckApp/Internal/TarotAdConsent.swift`, `SupportReminderStore.swift` |
| Adaptive banner bridge | `native-ios/TarotDeckApp/Components/TarotBanner.swift` |
| Root/shell and Settings integration | `native-ios/TarotDeckApp/App/TarotDeckInternalApp.swift`, `TarotDeckMainShell.swift`; `Screens/Read/ReadViews.swift`; `Screens/Settings/SettingsView.swift` |
| Project/resources | `native-ios/TarotDeck.xcodeproj/project.pbxproj`; `Resources/Advertising.plist`, `Localizable.xcstrings`, `required-interface-keys.v1.json` |
| Local contract/product | `store/tarot-monetization-20261018.json`; `docs/product/PRODUCT_BRIEF.md` |
| Verification/preparation tools | `native-ios/Tools/validate-monetization.py`, `audit-advertising-sdk.py`, `prepare-monetization-project.py`, `finish-monetization-reference.py`; scoped updates to `validate-app-integration.ps1`, `validate-support-products.ps1` |
| Evidence | this directory's `AUDIT_PLAN.md`, `SDK_AUDIT.json`, `VALIDATION.json`, `PRIVACY_AND_APPLE_GATE.md`; `design/monetization-20261018/{integration.svg,integration-preview.png,REFERENCE.md}` |

`AGENTS.md`, `STATUS.md`, `DECISIONS.md`, `docs/coordination/`, canonical design masters and `design/proposals/uiux-20261018/` were not written by this task. Concurrent changes there belong to other owners. The two pre-existing modified technical launch records and all eight untracked historical PNGs were preserved. Voice Recorder files were read only.

## Entitlement decisions

All seven existing immutable IDs remain unchanged: the `com.krazel.tarotdeck.support.monthly` suffixes `.099`, `.299`, `.499`, `.999`, `.1499`, `.2999`, `.50`. No new product, price, trial, group or tier was created. Every verified active supporter—including pre-update subscribers—receives ad removal plus the existing supporter status/thanks. Prices still come only from `Product.displayPrice`; core content and actions remain free.

Rights are resolved before any banner or reminder, independently of product-catalog lookup. `Transaction.currentEntitlements` and verified `Transaction.updates` remain authoritative; restore uses `AppStore.sync()`. Revoked/unverified/upgraded transactions cannot grant support. A relevant unverified entitlement without a valid entitlement also leaves ads unresolved/off. Foreground entry invalidates stale banner eligibility, then rechecks rights. A bounded scheduled StoreKit refresh handles expiry while the app stays open; there is no reminder timer. Apple's subscribed and billing-grace entitlements are preserved; an expiration timestamp alone never removes grace rights. Cancellation keeps service through the entitled period, while expiry/revocation/billing retry without grace allows banners again only after StoreKit resolves that state.

The seven-product audit is of local code/contract plus historical Apple records. **No fresh server-side approval/availability claim is made.** The old Apple setup manifest is preserved as historical configuration; the additive local amendment contains the exact proposed benefit copy for later authorized reconciliation.

## Banner/reading matrix

All “eligible” rows also require resolved non-supporter rights, active app, sample Debug configuration, current UMP permission and SDK start. Release is always off.

| Visible state | Banner | Layout/request behavior |
|---|---|---|
| Home, selectors, ordinary Cards/library/meaning, Learn/tutorial/article | Eligible | Adaptive safe-width banner below normal content/tab navigation; appears only after load |
| Settings | Eligible | Dedicated sheet host; underlying shell host suspended |
| Support options, not subscribed | Eligible outside purchase/restore/notice | Screen host removed while Apple transaction/restore flow or notice is active |
| Restoration or reading entry before session exists | Hidden | No view/controller or reserved height |
| Any active table: shuffle/repeat shuffle, place/deal, face-down, reveal/conceal, completed, reset, orientation cue, dialogs/overlays | Hidden | Excluded by the whole read surface, not card count, phase, orientation or banner callback |
| Meaning opened from table with reading context | Hidden | Explicit reading-meaning exclusion remains until dismissed |
| Navigate from table to Learn/tutorial | Eligible | Tutorial is a normal reference destination; returning to read table excludes it immediately |
| Any verified active supporter | Hidden | No ad host/request |
| Unresolved/unverified rights, background, UMP update/form/error, missing/different test app ID | Hidden | Zero reserved height; no fallback real request |
| Banner loading, no fill or request failure | Hidden | Height zero; no fake ad/placeholder |

The controller uses the same UIKit `BannerView`/SwiftUI wrapper pattern audited in Voice Recorder. It adds anchored adaptive sizing, explicit teardown and late-callback suppression. Removed views have no hit testing/AX element; loaded ads have a localized “Advertisement/Anuncio” label. Existing controls retain their layout and minimum targets; the host consumes safe-area space and does not overlay controls. These are source-level properties; actual iPhone layout and accessibility still require runtime verification.

## Optional 14-day reminder

Inline Settings card only; no pop-up, screen-based repetition, delayed timer or first-run request. New keys `tarot.supportReminder.v1.firstSeen`, `.lastShown`, `.optedOut` are stored locally. On first observed launch (including existing users receiving this update), only `firstSeen` is recorded. The first eligible appearance requires a subsequent process launch **and at least 14×24 hours** since that date. Every later appearance requires the same elapsed interval since the persisted claim. The claim is written before rendering, so reopening/updating/navigation does not reset it. Backward clock movement suppresses rather than accelerates eligibility. “Not now” dismisses; “Don't ask again” persists opt-out. Supporters, unresolved rights and all table/critical paths cannot claim a reminder. Restoring from device backup/reinstall may affect local preferences; no claim of cross-device cooldown is made.

## SDK, data and regional consent

GMA **12.14.0** and UMP **3.1.0** are exact SPM pins matching the audited functional reference, supported on the retained iOS16 baseline. Official archive checksums and bundled privacy manifests were verified. No Voice Recorder real ID, credential, contact or product was copied. No interstitial, rewarded, app-open, mediation or analytics integration was added.

Debug uses only Google's public sample app/banner IDs. Missing or mismatched configuration fails closed. Release returns nil unconditionally; real app/unit IDs remain **unconfirmed**. GAD measurement is delayed until SDK start. UMP info updates per eligible launch and guards each request. Where consent is required, ads stay off until the user voluntarily opens Advertising choices in Settings; no form interrupts the table. Required privacy options remain available. Changing choices tears down requests first; failures keep ads off.

No ATT/IDFA request was added. Publisher first-party ID and personalization are disabled, and requests set `npa=1`. The generic GMA manifest nevertheless declares tracking-capable device ID, linked location/advertising/interaction data and diagnostic categories; UMP also declares consent-related location/performance/interaction. Therefore **absence of tracking is not certified** from source settings or lack of ATT alone. Live activation stays disabled pending the exact network/privacy-report audit. Full data table, unchanged public-policy caveat, regional matrix and precise Apple metadata proposal are in [PRIVACY_AND_APPLE_GATE.md](PRIVACY_AND_APPLE_GATE.md).

## Verification and limits

Executed on Windows, without compiling a new app:

- Offline monetization structural validator: **29 checks PASS**, recorded in `VALIDATION.json` (project object integrity, dependency pins/linkage, unchanged IDs/version, Debug-only samples, Release gate, entitlement/consent/presentation wiring, teardown, localized copy, SDK/privacy and design evidence).
- Existing app integration validator: PASS. Its historical no-external-SDK premise was narrowly replaced with an allowlist for the two authorized Google packages; other network/permission restrictions remain.
- Existing seven-product validator: PASS, with historical Apple setup preserved and additive ad-removal contract checked. Content SHA/provenance, English education and Spanish localization validators: PASS.
- Both official SDK archives: SHA-256 PASS; device/simulator manifests extracted; adaptive banner/configuration symbols present in exact device headers. No binaries retained.
- Complete code-native reference rendered to PNG and visually inspected; it specifies the new footprint/copy only and does not approve or integrate the other chat's redesign. SHA is registered in its scoped manifest. It is **not** a native screenshot.
- `git diff --check`: PASS at closure, with no whitespace errors.

Prepared but **not executed**: three XCTest methods covering the full 128-case banner gate matrix, elapsed-time/clock boundaries and real UserDefaults reopen/update/opt-out persistence. This host has no Swift/Xcode. No simulator/device run, ad load, UMP regional flow, StoreKit sandbox purchase/restore, compiled merged plist, combined Xcode privacy report or native screenshot comparison is claimed.

Required future QA: all seven sandbox products, pre-existing entitlement on upgrade, offline catalog failure, restore, pending/cancelled purchase, renewal, expiry, revocation, tier change and grace; every table phase/orientation/overlay and contextual meaning; Learn/return; EEA accept/reject/non-EEA/errors/reopen/withdrawal and absence of unexpected ATT; compact and large iPhones, landscape safe areas, largest Dynamic Type, VoiceOver, no-fill and late callbacks. Verify Release cannot start advertising. Keep expected privacy console messages configured for tests; a missing sample-app UMP setup may deliberately produce no ad.

## Next step

The permanent brain can integrate these facts into its owned records and D1 without claiming a build or live ads. Next technical milestone is an **authorized macOS/physical-device QA pass**, followed by exact privacy/Apple reconciliation. Real AdMob identifiers, UMP territorial messages, actual Apple product approval/availability and public-policy updates remain gates; no new price/product is needed and none is proposed. No further implementation microdecision is waiting on the brain in this scope.
