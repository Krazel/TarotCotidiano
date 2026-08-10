# Tarot Deck — iOS Launch Readiness Inventory

Status: honest pre-release inventory; no distribution action authorized
Snapshot date: 2026-08-09
Applies to: iPhone, English-first native SwiftUI restart in `native-ios/`

## Purpose

This document records what exists, what is only provisional, and what still requires owner authority before TestFlight or App Store release. It applies the repository's launch rules and the `ios-app-launch` skill without creating accounts, products, legal pages, secrets, builds, or external records.

It is not evidence that the app has compiled in Xcode, passed App Review, cleared artwork rights, or been configured for sale.

## Executive status

Tarot Deck has an unsigned internal SwiftUI target, a dependency-free local deck engine, complete English identity and education manifests, and a read-only macOS package-test workflow. It is not a distribution candidate.

The principal release blockers are:

1. no successful Xcode app-target build, archive, export, signing, or device evidence;
2. provisional product identity, version, display name, and bundle identifier;
3. incomplete and distribution-unapproved artwork;
4. unpublished legal/support destinations and incomplete App Store compliance answers;
5. no App Store Connect app, StoreKit products, subscription group, product IDs, or prices;
6. no final app icon, store screenshots, or store metadata;
7. no authorization for signing, TestFlight, App Store Connect, contracts, commerce, or publication.

`Read / Learn / Cards` remain fully free by product decision. Planned supporter subscriptions are optional and do not block functional completion of those three core destinations.

## Verified repository snapshot

| Item | Verified state | Launch interpretation |
|---|---|---|
| Local repository | `C:\Users\dmkra\Documents\Codex Apps\TarotCotidianoNative` | Correct project scope. |
| Remote | Public `https://github.com/Krazel/TarotCotidiano.git` | Made public by A-026 after a current/history credential scan; app publication authority does not follow from repository visibility. |
| Branch | `main` | Current local branch. |
| Local `HEAD` | `46127ce` | Same commit as the locally recorded `origin/main`. |
| Working tree | Dirty, with the native restart, current documentation, design references, content, and workflow not included in `46127ce` | Current launch work is not represented by the remote commit. No commit or push was made in this task. |
| Native project | `native-ios/TarotDeck.xcodeproj` | Internal Xcode container exists. |
| Target / scheme | `TarotDeckInternal`; shared Debug scheme | Explicitly provisional, not a production target or archive scheme. |
| Minimum OS | iOS 16.0 | Verified target intent; iPhone only. No required iOS 17-only API is present. |
| Device family | `TARGETED_DEVICE_FAMILY = 1` | iPhone, not iPad. |
| Orientation | Portrait, landscape left, landscape right | Must still be verified on real Xcode/simulator builds. |
| Development language | `en` | Consistent with English-only first release. |
| Display name | `Tarot Deck Internal` | Internal label, not final App Store name. |
| Marketing version | `0.0.1` | Internal placeholder, not aligned to an App Store Connect record. |
| Build number | `1` | Internal placeholder, not aligned to an App Store Connect record. |
| Bundle identifier | `com.krazel.tarotdeck.internal.provisional` | Explicitly provisional; no final identifier or distribution history decision is recorded. |
| Signing | `CODE_SIGNING_ALLOWED = NO`; `CODE_SIGNING_REQUIRED = NO` | Cannot produce a signed distribution build in current configuration. |
| Apple team | No Development Team recorded | Pending owner/account authority. |
| App Store Connect app ID | Not present | No app record has been verified or created. |
| Runtime dependencies | Local `TarotDeckCore`; no external Swift package dependency in the core | Good privacy and supply-chain baseline, subject to Xcode verification. |
| CI | One `Tarot core` workflow, read-only permissions, macOS package build/tests, no secret use, signing, archive, upload, or deployment | Useful structural gate only; not an iOS app release pipeline. The workflow is currently uncommitted and has no verified remote run for this snapshot. |
| Local build evidence | No Swift/Xcode toolchain on this Windows host | Swift package tests and the SwiftUI app target have not executed here. |

## Verified content and integration evidence

The repository's local validation scripts were executed with a process-scoped PowerShell execution-policy bypass; no repository configuration was changed.

- Canonical deck validation passed: 78 card identities and 78 unique provenance records.
- Education validation passed: 78 upright meanings, six beginner-guide articles, English content.
- App integration validation passed: exact 78 IDs/names, 78 meanings, six articles, target membership and scope checks.
- The integration validator found 40 source-integrity-verified provisional face assets.
- `provenance.v2.json` contains 78 asset-evidence entries and zero entries approved for distribution.
- `local-evidence.v2.json` records 40 verified candidates, 38 failures/missing candidates, `territorialRightsReviewStatus = pending`, and `distributionApproved = false`.
- All candidate faces remain internal/provisional even where their hashes match a recorded source.
- The existing 36 Spanish reflection cards are historical source material and are not part of the native 78-card production manifest.

Passing these validators proves consistency, not copyright clearance, territorial public-domain status, App Store suitability, or final visual quality.

## Product and platform scope

- First release: iPhone/iOS only.
- Product and visible copy: English only.
- Core destinations: `Read`, `Learn`, `Cards`.
- Content: one upright-only 78-card deck, 78 upright meanings, six guide articles.
- Data model: one locally persisted active reading; no account, cloud sync, history, favorites, journal, analytics, advertising, or remote tarot content.
- Zodiac/Horoscope is a separate product and must not enter this app or listing.
- The app remains fully usable for free.
- There are no ads and no AdMob dependency or account requirement.

## Provisional legal and support URL plan

Working app slug: **`tarot-deck`**.

The launch standard places legal/support pages in the shared GitHub Pages site, not at an app-repository URL.

| Purpose | Provisional target | Current state |
|---|---|---|
| Privacy | `https://krazel.github.io/tarot-deck/privacy/` | Target only; page was not created, published, or verified live. |
| Support | `https://krazel.github.io/tarot-deck/support/` | Target only; page was not created, published, or verified live. |
| Terms / subscription terms | `https://krazel.github.io/tarot-deck/terms/` | Provisional convention only; page and final EULA approach are pending. |

Before release, the slug, final app identity, legal owner/contact, page copy, hosting repository, and URL behavior must agree. Publishing any page or creating a live link is outside this task.

## Privacy and compliance inventory

### Privacy

Known privacy-minimizing evidence:

- no app account, login, analytics SDK, advertising SDK, tracking identifier, notification request, or remote card service found in the inspected native scope;
- Read, Learn, Cards, meanings, and reading restoration are designed to work locally;
- no `PrivacyInfo.xcprivacy` file exists in the native project;
- no App Store privacy questionnaire or signed-binary privacy audit exists.

Pending before release:

- write and publish the English privacy page after final binary behavior is known;
- decide whether a privacy manifest is required by the final APIs and dependencies;
- answer App Privacy from the signed archive and actual StoreKit/system-link behavior;
- verify that diagnostics and persistence collect no unnecessary reading data;
- record support contact and data-retention statements consistently across app, legal pages, and listing.

### Content rights

Pending and release-blocking:

- obtain all 78 final face assets or approved original replacements;
- complete source-file and territorial rights review for every intended storefront;
- convert zero provisional records to an explicitly documented distribution-approved state only with adequate evidence;
- confirm rights for the shared back, typography, icons, textures, copy, and any final audio/haptics assets;
- answer App Store Connect content-rights questions against the final bundle.

Historical or Commons-hosted artwork must not be treated as cleared merely because a source labels it public domain. The 40 downloaded candidates remain non-production.

### Age rating

No age-rating questionnaire is recorded. Complete it against the final art and copy, including tarot/occult themes and any artistic nudity, death, devil, weapon, or frightening imagery present in the selected historical deck. Do not choose a rating from the current partial asset set.

### Export compliance

No custom networking or cryptography was found in the inspected core, but no export-compliance answer is recorded and `ITSAppUsesNonExemptEncryption` has not been set. Re-evaluate the final signed binary, Apple frameworks, StoreKit integration, and distribution configuration before answering.

### Other App Store fields still pending

- final app name and bundle identifier;
- primary/secondary category;
- subtitle, description, keywords, promotional text, and review notes;
- copyright and seller/legal entity;
- support contact;
- content-rights declaration;
- age rating;
- privacy questionnaire;
- export-compliance declaration;
- EULA/terms choice required by the supporter subscriptions;
- App Store Connect app ID and SKU.

## Monetization readiness

### Approved product intent

- Placement: `Support the App` inside Settings reached from a discreet gear in Read, never as a fourth tab or usage gate.
- Model: monthly auto-renewable supporter subscriptions.
- Working level labels: `Monthly Supporter`, `Kind Supporter`, and `Generous Supporter`.
- Benefit: equivalent access at every level, active supporter status, thank-you, and at most a small visual acknowledgement.
- Free guarantee: no core feature, card, meaning, guide article, fix, or reading behavior depends on support.
- No advertising, external payment link, donation/nonprofit claim, guilt copy, or rating reward.
- `Rate the App` remains separate from support.

### Verified implementation state

- No `StoreKit` import was found in the native app source.
- No `.storekit` configuration file exists.
- No subscription group, product identifier, price, App Store Connect product, or product-to-level mapping exists.
- Purchase, entitlement verification, restore, manage-subscription, renewal/cancellation disclosure, StoreKit error, and thank-you behavior are documented product states but are not verified native commerce implementations.
- No paid-app agreement, tax, banking, or subscription review state is recorded.

### Required before commerce can be enabled

1. Obtain explicit authorization to create paid App Store products and accept any required agreements.
2. Confirm the final bundle identifier and App Store Connect app.
3. Choose the subscription group, final level names, product IDs, and owner-approved prices.
4. Implement StoreKit using no external payment provider.
5. Display live price, duration, auto-renewal, cancellation management, Restore Purchases, Privacy, and Terms before purchase.
6. Verify entitlement, expiration, cancellation, pending, refund/revocation where applicable, restore-not-found, offline, and recoverable-error behavior.
7. Test in an authorized StoreKit/sandbox environment and write review notes explaining that support is optional and levels are equivalent.
8. Include the first subscription with the authorized app-version submission.

None of these commerce steps is authorized by A-022 or by this readiness document. Their absence does not block building and testing Read, Learn, and Cards.

## Build, signing, and distribution readiness

Not ready:

- Xcode app-target compilation and simulator/device run are unverified.
- The shared scheme is Debug-only and deliberately does not archive.
- Release presentation is intentionally not a production root.
- Code signing is disabled.
- No final App ID, bundle identifier, certificate, provisioning profile, entitlements, or Apple team is configured.
- No protected release environment or Apple signing/App Store Connect secrets exist.
- No release/TestFlight GitHub Actions workflow exists; the only workflow tests the Swift package.
- No archive validation, `.xcarchive`, exported IPA, notarized/uploaded build, or App Store processing record exists.
- No internal tester group or TestFlight test notes exist.

When separately authorized, any upload workflow must remain manual, use a protected GitHub Environment, persist no checkout credentials, and keep certificate, provisioning profile, App Store Connect API key, and passwords in protected secrets without printing decoded material.

## Store asset and metadata readiness

- Final app icon: absent; there is no `AppIcon` asset set.
- Store screenshots: absent. Existing design mockups are product references, not App Store screenshots.
- App previews/video: absent and not required by current scope.
- Final launch identity and display name: pending.
- Subtitle, keywords, description, promotional text, category, copyright, review notes, and support contact: pending.
- Final screenshots and icon require visual-first creation, registration, implementation where applicable, and capture from a verified build.
- Signing, App Store asset upload, TestFlight, and review submission remain unauthorized.

## Secrets and credential hygiene

Repository inspection found:

- zero files named as common Apple/signing/environment credentials (`.p8`, `.p12`, `.mobileprovision`, `.cer`, `.key`, `.env`, or `GoogleService-Info.plist`);
- zero likely secret assignments matching the scoped API-key/client-secret/password/token scan;
- no use of secrets in the current CI workflow;
- `.gitignore` excludes environment files, common signing material, archives, IPAs, DerivedData, logs, and downloaded dependencies.

The result is **zero known secrets in the inspected working tree**, not a substitute for provider-side secret inventory or release security review. No secret should be added until a protected release workflow is explicitly authorized.

## Launch checklist by authority and readiness

### 🟢 Green — verified local foundation

- [x] Public repository and `main` branch identified; workflow is manual and contains no secrets.
- [x] iPhone-only SwiftUI target exists with English development language.
- [x] Internal version `0.0.1` and build `1` are recorded as provisional.
- [x] Provisional bundle identifier is explicitly marked non-launch.
- [x] Canonical 78-card identities validate.
- [x] All 78 upright meaning records and six Learn articles validate in English.
- [x] Core has no external Swift package dependency, account, analytics, ad SDK, or remote card-content client in the inspected scope.
- [x] Existing CI is read-only and contains no upload, signing, deploy, or secret consumption.
- [x] No credential/signing files or likely assigned secret values were found by the scoped scan.
- [x] Read/Learn/Cards remain free; supporter levels are planned with equivalent access.

### 🟡 Yellow — safe preparation or unresolved evidence

- [ ] Build and test the Swift package on macOS CI and retain passing evidence.
- [ ] Build the Xcode app target on macOS, run it on iPhone simulator/device, and fix compile/runtime defects.
- [ ] Compare final implementation captures with registered visual references.
- [ ] Complete accessibility, orientation, persistence, offline, and recovery testing.
- [ ] Resolve final product name, version/build strategy, bundle identifier, and prior-distribution/migration question.
- [ ] Finish all 78 final card assets and rights evidence; 40 candidates are present and all remain distribution-unapproved.
- [ ] Draft final Privacy, Support, and Terms copy for provisional slug `tarot-deck` without publishing it yet.
- [ ] Draft App Privacy, age-rating, content-rights, export-compliance, category, metadata, and review-note answers against the final binary/content.
- [ ] Create visual-first final app-icon and store-screenshot specifications; existing mockups do not count as store assets.
- [ ] Design and implement Settings/StoreKit behavior only after its applicable visual and implementation gates are satisfied.
- [ ] Confirm final supporter level names. Current `Monthly / Kind / Generous Supporter` wording follows the launch reference and remains provisional until products are authorized.
- [ ] Prepare a release/test plan and a protected manual workflow design without adding secrets or upload capability.

### 🔴 Red — explicit authorization required before action

- [ ] Register or change the final Apple App ID/bundle identifier.
- [ ] Create the App Store Connect app/SKU.
- [ ] Create a subscription group, StoreKit products, product IDs, or prices.
- [ ] Accept paid-app, tax, banking, EULA, or other legal agreements.
- [ ] Create or use Apple certificates, provisioning profiles, API keys, passwords, or protected environment secrets.
- [ ] Publish the legal/support pages or make the provisional URLs live.
- [ ] Create external service accounts or spend money.
- [ ] Archive/export a distribution build or enable a release upload workflow.
- [ ] Upload to App Store Connect or TestFlight, add testers, or distribute a build.
- [ ] Submit the app or its first subscription for review.
- [ ] Publish the app, legal pages, release, or store listing.
- [ ] Commit or push the current working tree without separate authority.

## Consistency check against product documents

No material contradiction was found with `docs/product/PRODUCT_BRIEF.md` or `docs/product/SCREEN_MAP.md`:

- both preserve `Read / Learn / Cards` as the three primary destinations;
- both place Settings behind a discreet Read gear, not a fourth tab;
- both define optional monthly levels with equivalent access and a separate Rate the App action;
- both keep core content offline and treat StoreKit/legal/rating connectivity as secondary;
- both state that products, prices, contracts, builds, and review require separate authority and do not block core completion.

The current supporter labels are working copy, not product IDs or approved prices. They must remain provisional until the owner authorizes App Store product creation.

## Actions deliberately not taken

This inventory did not:

- browse or verify the provisional URLs;
- create or edit legal pages;
- create an Apple/App Store/StoreKit record or account;
- choose prices or product IDs;
- accept an agreement;
- add a privacy manifest, entitlement, certificate, profile, key, token, or secret;
- run an Xcode build, archive, export, upload, TestFlight action, or review submission;
- generate final store icons or screenshots;
- commit or push.
