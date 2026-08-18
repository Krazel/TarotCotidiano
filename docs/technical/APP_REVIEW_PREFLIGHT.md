# App Review preflight — Tarot Deck 1.0 (1)

Updated: 2026-08-18
Scope: first public iPhone release candidate. This record prepares the submission but does not upload, select a build, attest DSA/content rights in App Store Connect, accept agreements, submit for review, or publish.

## Release identity

| Field | Prepared value | Gate |
|---|---|---|
| App Store Connect Apple ID | `6800144105` | Existing record; recheck before upload |
| Bundle ID | `com.krazel.tarotdeck` | Fixed |
| SKU | `tarot-deck-ios` | Fixed |
| Version | `1.0` | Prepared in source |
| Build | `1` | Prepared in source; must be unused when uploaded |
| Platform | iPhone, iOS 16.0+ | Prepared |
| Primary language | English (U.S.) | Prepared |
| Additional localization | Spanish (Spain) | Prepared |
| Distribution mode | Free, manual release | Prepared; confirm in App Store Connect |
| Territories | `US`, `GB`, `ES` only | ReleaseGate passes; Spain requires DSA completion |

The previous TestFlight `0.8 (1)` is historical internal-only evidence. It is not eligible for the public App Review submission.

## Product and binary facts

- Full 78-card deck, one-card, five three-card methods, one documented six-card method, and saved custom spreads of 1–12 cards.
- Read, Learn, Cards, Favorites and Settings are available without account, payment or network access.
- English and Spanish content are bundled and selected inside Settings.
- No ads, analytics, tracking, third-party runtime SDK, account, cloud sync, StoreKit purchase, subscription or protected-data permission.
- `PrivacyInfo.xcprivacy` declares no tracking, no collected data and only the app-owned UserDefaults required-reason API.
- `ITSAppUsesNonExemptEncryption=NO` is set for Release.
- The 78 card faces and non-face assets have project provenance. Public distribution is cleared by the project gate only for `US`, `GB` and `ES`; worldwide remains false.

## App Store metadata

Canonical values live in `APP_STORE_RECORD.md`. Current limits are satisfied:

- EN name: `Tarot Deck: Read & Learn` — 24 characters.
- EN subtitle: `Your deck, always with you` — 26 characters.
- ES name: `Tarot Deck: Lee y aprende` — 25 characters.
- ES subtitle: `Tu mazo, siempre contigo` — 24 characters.
- EN keywords: 74 characters.
- ES keywords: 81 characters.
- Promotional Text: empty.
- Marketing URL: empty.
- Privacy URL: `https://krazel.github.io/tarot-deck/privacy/`.
- Support URL: `https://krazel.github.io/tarot-deck/support/`.
- EULA: Apple Standard EULA.
- Login/demo account: not applicable.
- Review attachment: empty unless Apple requests a diagnostic artifact.

## App Privacy

Prepared App Privacy answer: **Data Not Collected / No se recopilan datos**.

The exact local data inventory is recorded in `PRIVACY_DATA_INVENTORY.md`: language, preferred reading, active reading, continuity marker, favorites, custom spreads and an unfinished custom-spread draft. These stay on the device and are not transmitted. Re-audit the signed archive before submission.

## Age rating and content declarations

- Prepared age-rating result: `13+`.
- Re-answer the current App Store Connect questionnaire against the processed `1.0 (1)` binary before selecting the build; do not copy an obsolete questionnaire result.
- No gambling, simulated gambling, unrestricted web access, user-generated public content, messaging, purchases, advertising, violence, sexual content, substances or medical treatment guidance.
- The app presents tarot reading and educational content. Metadata must describe it plainly and must not promise guaranteed outcomes.

## App Review notes

Use this exact English draft after validating the processed build:

```text
Tarot Deck requires no account or sign-in and is fully usable offline.

To review the main flow:
1. Open Read and use the small selector to choose One Card, Three Cards, Six Cards, or Custom.
2. Tap the deck to enter the reading. The deck shuffles automatically. Use Shuffle to mix again, tap the deck to place the next card in the first available position, or tap an empty position to place it there.
3. Tap a face-down card to reveal it, then tap a revealed card to open its Meaning and In a Reading reference.
4. Open the information control on a reading to visit its tutorial and return to the unchanged reading.
5. Open Learn to browse the foundations and eight reading tutorials.
6. Open Cards to browse all 78 cards, filter the deck and save favorites.
7. Open Settings to change language or open Rate the App, Privacy and Support.

Custom spread names, optional position labels, readings, favorites and language choice remain only on the device. The app has no purchases, subscriptions, ads, analytics, tracking, third-party SDKs, protected-data permissions, accounts or cloud sync.

Privacy is available from Settings and at https://krazel.github.io/tarot-deck/privacy/.
```

The App Review contact is private App Store Connect data. Verify it there and never copy the proprietor's home address, phone number or personal account into public metadata unless Apple or law requires the exact field.

## Screenshot gate

Screenshots must come from the real processed `1.0 (1)` build. Approved design masters guide art direction but are not submitted as runtime evidence. The bilingual shot list, accepted canvas sizes and provenance requirements are in `APP_STORE_SCREENSHOTS.md`.

## Public-page gate

The prepared local Privacy and Support pages are newer than the live pages. Before selecting the build:

1. deploy the prepared page source;
2. verify both URLs return HTTP 200 without redirects to an unrelated destination;
3. verify Privacy lists every local state in `PRIVACY_DATA_INVENTORY.md`;
4. verify Support describes one/three/six/custom readings and uses `Meaning / Significado`;
5. verify the public support alias works without exposing unnecessary personal details.

## DSA gate for Spain

Apple requires a truthful trader/non-trader declaration for EU distribution and cannot determine the answer for the developer. If `ES` is enabled:

- decide the real status based on whether the app is offered in connection with a trade, business, craft or profession;
- if trader, provide and verify the contact information Apple/DSA requires for public display;
- if non-trader, make that declaration truthfully;
- keep private App Review contact separate from public trader information.

If this decision is not complete, do not enable Spain. The technical rights allowlist does not replace DSA compliance.

## Automated release path

`.github/workflows/tarot-app-review-rc.yml` is manual, main-only and protected by `app-store-production`. It requires the exact red confirmation `UPLOAD_APP_REVIEW_RC_1_0_1`, runs content/localization/release gates and Swift tests, archives and verifies a signed Release build, creates non-binary evidence, and uploads only the binary to App Store Connect.

It does **not** select the build for version 1.0, change territories, fill metadata, attest rights or DSA, accept agreements, submit for review, configure automatic release or publish.

## Final red-action checklist

These remain intentionally undone until the proprietor explicitly authorizes each material action against the exact processed build:

- upload `1.0 (1)`;
- deploy the public Privacy/Support pages;
- declare DSA trader/non-trader status;
- attest Content Rights in App Store Connect;
- select storefronts and the processed build;
- save final age rating, App Privacy and accessibility claims;
- upload final screenshots;
- accept any agreement;
- click **Add for Review** or **Submit for Review**;
- release the approved app.

## Official Apple references

- App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- Screenshots and previews: https://developer.apple.com/help/app-store-connect/manage-app-information/upload-app-previews-and-screenshots
- Screenshot specifications: https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/
- App Privacy: https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy
- Age rating: https://developer.apple.com/help/app-store-connect/manage-app-information/set-an-app-age-rating
- EU DSA trader requirements: https://developer.apple.com/help/app-store-connect/manage-compliance-information/manage-european-union-digital-services-act-trader-requirements/
