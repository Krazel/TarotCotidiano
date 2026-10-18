# Privacy and Apple preparation — not applied remotely

2026-10-18. No SDK was installed/executed, no app was built, and no Apple/AdMob console field or public policy was changed.

## Actual pinned SDK audit

`SDK_AUDIT.json` contains the exact manifests extracted from Google's official GMA 12.14.0 and UMP 3.1.0 device and simulator archives. Both archive SHA-256 values matched the official Swift package manifests. Archives were read in memory and not retained. GMA's adaptive banner, first-party ID and publisher privacy configuration symbols were also found in the device headers.

| SDK / declared type | Linked | Tracking in generic SDK manifest | Declared purposes |
|---|---|---|---|
| GMA · other diagnostic data | No | No | Third-party ads, developer ads, analytics |
| GMA · approximate location | Yes | No | Third-party ads, developer ads, analytics |
| GMA · performance data | No | No | Third-party ads, developer ads, analytics |
| GMA · crash data | No | No | Analytics |
| GMA · advertising data | Yes | No | Third-party ads, developer ads, analytics |
| GMA · product interaction | Yes | No | Third-party ads, developer ads, analytics |
| GMA · device ID | Yes | **Yes** | Third-party ads, developer ads, analytics |
| UMP · approximate location, performance, product interaction | No | No | App functionality |

Required-reason declarations: GMA system boot time `35F9.1`, UserDefaults `CA92.1`, disk space `E174.1`; UMP UserDefaults `CA92.1`. The app's own manifest continues to describe only its own local storage/UserDefaults `CA92.1`. Its empty own-data array is **not** a combined SDK privacy report or an assertion that this prepared dependency graph collects no data.

No reading, card identity, spread, favorite, language selection, or free-text information is passed to an ad request. Requests contain no content URL, keywords, user ID or targeting profile. Core readings and education remain local and offline. Support purchases continue through Apple; no application account/server was introduced. Cadence dates and opt-out are local UserDefaults and are not ad targeting data.

## Implemented consent and tracking boundaries

- Debug accepts only Google's documented sample app and adaptive-banner units. Missing/different app ID disables requests. Release returns nil in source unconditionally, so filling a build setting alone cannot activate real ads.
- UMP information is refreshed once per eligible process launch; failures keep ads off. No locally cached consent decision is treated as permission. `canRequestAds` is queried again at the request boundary.
- No form is automatically presented during a reading. If UMP requires a form, ads remain off until the user opens **Settings → Advertising choices**. This explicit entry also exposes required regional privacy options and can be reopened while a supporter is active in Debug.
- Privacy-choice entry removes existing banners/requests first. Both successful changed choices and failures require a new eligible request; failure does not reuse the previous consent flag. No ATT call follows any form.
- Before SDK start: publisher first-party ID disabled and publisher personalization disabled. Each banner request additionally sets `npa=1`. No ATT framework/import/call, IDFA API, usage-description prompt, mediation adapter or app analytics SDK was added. SDK start is guarded against duplication.
- These are the **intended no-tracking settings**, not proof of absence of tracking. In particular, GMA's generic manifest declares device ID tracking. Neither `npa`, no ATT prompt nor UMP permission alone resolves Apple's tracking definition. Keep live activation disabled until the exact configured SDK/network behavior and combined privacy report have been checked. If that mode cannot avoid Apple's tracking definition, prepare an explicit ATT/regional-consent gate as a separate material change; never silently enable tracking or publish an AdMob IDFA explainer.

## Exact future gate, not authorization

Before any tester distribution or release of this changed dependency graph:

1. Fresh read-only ASC verification of all seven immutable products, approval/availability, equivalent group level, active subscription agreements and current metadata. Source/historical descriptions of Ready for Review must not be treated as live status. Use the official API first and existing authorized mechanisms; this task used no Apple credential.
2. Retain all IDs/prices/durations. Proposed benefit description for **each existing product**: EN `Monthly support. Removes ads while active.`; ES `Apoyo mensual. Sin anuncios mientras esté activo.`. Names/group unchanged. This is recorded in `store/tarot-monetization-20261018.json`; no setup workflow or metadata mutation was run.
3. Prepare App Privacy using the table above and the Xcode combined report; the historical `Data Not Collected` label is unsuitable for an ad-enabled submission. Resolve linked-data/tracking fields against actual configured behavior, including consent requests. The generic SDK manifest must not be edited to make a report appear private.
4. Update the existing independent public privacy destination (keep URLs) with the real SDK version, Google recipient, purposes/data, regional choices, controls and applicable retention policy. Retention must follow verified Google policy/contract; no unverified duration is promised here. Include that reading content is not sent. No public page was edited by this task.
5. Own AdMob app/banner IDs, ownership/eligibility, territorial message configuration and age-appropriate creatives remain unconfirmed. Do not copy Voice Recorder units. Prepare EEA/UK/Switzerland and applicable US-state privacy messages; leave IDFA/ATT messages unpublished for this intended mode. The current plist's single Google SKAdNetwork identifier is a test preparation, not the complete buyer list for a live configuration.
6. On an authorized macOS/device QA phase, compile the exact pins, execute all XCTest including the new cases, inspect final merged plist and manifests, verify the release-off binary, and compare native screenshots to the scoped reference plus unchanged masters. Runtime consent/network tests must include clean EEA accept/reject, non-EEA, form/update failures, reopen, later withdrawal, and no ATT request. Verify refusal does not activate tracking; limited or no ads is valid.
7. Obtain the separately required authority before any Apple/privacy metadata write, live AdMob configuration, build/CI, upload, review, release or expense. No new product or price is proposed.

## Sources checked 2026-10-18

- [GMA setup](https://developers.google.com/admob/ios/quick-start) and [banner test unit](https://developers.google.com/admob/ios/banner).
- [GMA exact package](https://raw.githubusercontent.com/googleads/swift-package-manager-google-mobile-ads/12.14.0/Package.swift), [UMP exact package](https://raw.githubusercontent.com/googleads/swift-package-manager-google-user-messaging-platform/3.1.0/Package.swift), [supported/deprecation schedule](https://developers.google.com/admob/ios/deprecation). The deliberate 12.x reference-compatible pin is not advertised as the newest SDK.
- [UMP setup and regional choices](https://developers.google.com/admob/ios/privacy), [privacy strategies](https://developers.google.com/admob/ios/privacy/strategies), [publisher privacy treatment](https://developers.google.com/admob/ios/targeting).
- [Google data disclosure](https://developers.google.com/admob/ios/privacy/data-disclosure), [Google privacy policy](https://policies.google.com/privacy).
- [Apple current entitlements](https://developer.apple.com/documentation/storekit/transaction/currententitlements), [renewal states](https://developer.apple.com/documentation/storekit/product/subscriptioninfo/renewalstate), [subscriptions](https://developer.apple.com/app-store/subscriptions/), [review guidelines](https://developer.apple.com/app-store/review/guidelines/).
