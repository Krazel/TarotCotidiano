# App Review preflight — Tarot Deck 1.0 (1)

Updated: 2026-08-19
Scope: first public iPhone release candidate. The signed build, metadata, screenshots, content-rights answer, subscriptions and subscription group are staged together in one App Review draft. Final submission remains pending while Apple's DSA trader verification is under review.

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
| Territories | All 175 current App Store countries or regions | Configured in App Store Connect; future regions enabled for subscriptions |

TestFlight `1.0 (2)` is the current internal beta and is not eligible for the public App Review submission because it was permanently exported as `INTERNAL_ONLY`. Build `1` remains reserved for the public candidate.

Current signed TestFlight evidence for source commit `bd77c9ab0b5b0dd9dd0334a2f5f12ce3f78896ef`:

- Archive, signature, entitlements, EN/ES resources, StoreKit source, Swift tests and upload: run `32199048236`, success.
- Manifest: `TarotDeck-1.0-2-ci13-bd77c9ab0b5b-TestFlight-Internal`.
- IPA SHA-256 recorded before upload: `49897da6220c13e2d4676b90b8be9fe2ca1e756a53d5afa9ae0d3cfd9b7a8be4`.
- Apple processing and tester assignment: run `32199365186`, upload `COMPLETE`, build `VALID`, audience `INTERNAL_ONLY`, group `Testers` verified.

MacOS evidence for source commit `0ed6cca7a31b3e6d3d935ec9e9d277c700a18386`:

- Core, Release package, Swift tests and unsigned iPhone app: run `32172356174`, success.
- Local-QA unsigned physical-device IPA: run `32172373006`, success.
- Local-QA artifact: `TarotDeck-1.0-1-ci13-0ed6cca7a31b-Local-QA-unsigned`.
- IPA SHA-256: `00011a14270f6399643aaa3465f8bc71c13d669a5239eaef8c50d6f5170f5809`.
- Independently rechecked: ZIP integrity, `1.0 (1)`, iOS 16.0, EN/ES display names, PrivacyInfo, Assets catalog and compiled icons; unsigned/provisional identity confirmed.

This evidence proves source compilation and packaging only. It does not replace the signed public Release archive or App Store Connect processing result.

## Product and binary facts

- Full 78-card deck, one-card, five three-card methods, one documented six-card method, and saved custom spreads of 1–12 cards.
- Read, Learn, Cards, Favorites and Settings are available without account, payment or network access.
- English and Spanish content are bundled and selected inside Settings.
- No ads, analytics, tracking, third-party runtime SDK, account, cloud sync or protected-data permission. StoreKit 2 is used only for seven equivalent optional monthly supporter subscriptions.
- `PrivacyInfo.xcprivacy` declares no tracking, no collected data and only the app-owned UserDefaults required-reason API.
- `ITSAppUsesNonExemptEncryption=NO` is set for Release.
- The 78 card faces and non-face assets have project provenance, and the owner has attested the required third-party content rights in App Store Connect.
- The seven monthly support products exist in App Store Connect with EN/ES, live Apple-localized prices, review screenshots, all 175 current countries or regions and future-region availability. The seven products and their group are staged with version `1.0 (1)` in the same nine-item review draft.

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
7. Open Settings to change language or open Support the App, Rate the App, Privacy and Support.
8. Open Support the App to inspect seven live monthly prices, the free-app disclosure, restoration, subscription management, Privacy and Terms.

Custom spread names, optional position labels, readings, favorites and language choice remain only on the device. Optional monthly support is processed by Apple through StoreKit; every level provides the same supporter status and unlocks no functionality. The app has no ads, analytics, tracking, third-party SDKs, protected-data permissions, accounts or cloud sync.

Privacy is available from Settings and at https://krazel.github.io/tarot-deck/privacy/.
```

The App Review contact is private App Store Connect data. Verify it there and never copy the proprietor's home address, phone number or personal account into public metadata unless Apple or law requires the exact field.

## Screenshot gate

Screenshots must come from the real processed `1.0 (1)` build. Approved design masters guide art direction but are not submitted as runtime evidence. The bilingual shot list, accepted canvas sizes and provenance requirements are in `APP_STORE_SCREENSHOTS.md`.

The proprietor approved the eight-image English set extracted from the supplied recording for public submission. The original video, raw frames, timestamps, transformations and SHA-256 hashes remain in the private `TarotCotidianoNative-StoreAssets` directory; every export is an opaque RGB `1260 × 2736` PNG. The screenshots represent UI that remains in `1.0` and exclude the later Settings/StoreKit surface. The Spanish localization will use App Store Connect's primary-language screenshot fallback; a native Spanish set is optional. This closes the public screenshot gate, but not the separate private subscription-review screenshot: the supplied video contains no Support the App screen.

## Public-page gate

Privacy and Support were published from Pages commit `90d0752` and both returned HTTP 200 on 2026-08-18. Privacy lists every local state in `PRIVACY_DATA_INVENTORY.md` and the Apple-managed StoreKit boundary. Support describes one/three/six/custom readings, the seven equivalent monthly levels, restoration and Apple-managed cancellation. Recheck both URLs and the public support alias immediately before selecting the final build.

## DSA trader verification

The developer is declared as a trader. Apple received the required contact information on 2026-08-19 and App Store Connect currently shows the verification as `En revisión`. The private App Review contact remains separate from the public trader information.

## Automated release path

`.github/workflows/tarot-app-review-rc.yml` is manual, main-only and protected by `app-store-production`. It requires the exact red confirmation `UPLOAD_APP_REVIEW_RC_1_0_1`, runs content/localization/release gates and Swift tests, archives and verifies a signed Release build, creates non-binary evidence, and uploads only the binary to App Store Connect.

The automated workflow did not perform App Store Connect form actions. Those staging steps were completed manually afterward with owner authorization: build selection, metadata, screenshots, Content Rights, availability, subscription review items and DSA submission. It still does not submit App Review or publish.

## Final red-action checklist

Current final-action state:

- `1.0 (1)` is uploaded, processed and selected;
- Privacy and Support are public;
- trader information is under Apple review;
- Content Rights is saved;
- the app, seven subscriptions and group are staged together;
- `Enviar a revisión` has not been clicked and requires immediate confirmation once Apple enables it.

## Official Apple references

- App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- Screenshots and previews: https://developer.apple.com/help/app-store-connect/manage-app-information/upload-app-previews-and-screenshots
- Screenshot specifications: https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/
- App Privacy: https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy
- Age rating: https://developer.apple.com/help/app-store-connect/manage-app-information/set-an-app-age-rating
- EU DSA trader requirements: https://developer.apple.com/help/app-store-connect/manage-compliance-information/manage-european-union-digital-services-act-trader-requirements/
