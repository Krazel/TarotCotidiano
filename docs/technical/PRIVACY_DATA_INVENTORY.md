# Privacy and data inventory

Updated: 2026-08-11
Scope: Tarot Deck `0.2.1 (1)` TestFlight Internal Only source, its declared dependencies, plus the verified unsigned `0.2 (1)` Local-QA IPA from CI run 12. The signed archive remains to be audited after upload.

## Current declaration

App Store Connect's **Data Not Collected / No se recopilan datos** answer is accurate for the audited app build. The app has no account, backend, analytics, advertising, tracking, StoreKit, third-party runtime SDK, network client, or system permission request. It does not transmit readings, favorites, language choices, device identifiers, contact information, or diagnostics to the developer.

The audited IPA SHA-256 is `8D8D9ECCD086D8EF03543FC155A3A0EE0C9CF4484F33DDE5B6053DDB31B9A0CF`. It is the earlier unsigned Debug Local-QA artifact, not the signed candidate. Release `0.2.1 (1)` now uses the real app composition and a privacy manifest; repeat the binary inspection against the signed archive before treating this inventory as final evidence.

## Information stored locally by the app

| Information | Storage | Purpose | Transmission | Removal |
|---|---|---|---|---|
| Selected language (`en` or `es`) | App-owned `UserDefaults`, key `tarot.appLanguage.v1` | Keep the explicit in-app language choice | None | Delete the app or clear its container |
| Active reading | `active-session.v1.json` in the app's Application Support directory | Restore the exact shuffled deck, drawn cards and revealed state | None | End/back from the reading where applicable, or delete the app |
| Reading continuity | `reading-continuity.v1.json` in the same directory | Recover the selected preset and safe transition state after interruption | None | Cleared with the reading where applicable, or delete the app |
| Favorite card IDs | `favorites.v1.json` in the same directory | Keep the user's saved cards | None | Remove individual favorites or delete the app |

The JSON files contain app-defined card IDs and reading state, not names, email addresses, free-form notes, device identifiers, location, contacts, photos, health data, payment data, or advertising identifiers. The app-owned Application Support directory is excluded from device backup before these files are read or written, so the feature remains device-local and does not provide app-managed cloud sync or cross-device recovery.

## Permissions and platform access

- No camera, microphone, photos, contacts, calendar, location, Bluetooth, motion, health, notifications, local-network, tracking, or other protected-data permission is requested.
- The target has no corresponding `UsageDescription` strings.
- The app uses `UserDefaults` only for its own language preference. `PrivacyInfo.xcprivacy` declares no tracking, no collected data, and the applicable required-reason API category for app-only preferences.
- No third-party frameworks, extensions, plug-ins, or embedded SDK privacy manifests were found in the audited IPA.

## Support email is separate from the app

The app itself does not collect support data. If a person voluntarily emails the public support alias, Gmail/Google processes the sender address, message, and any iOS version the person chooses to include so the developer can reply and troubleshoot. Support does not ask for a full name, phone number, device identifier, attachments, account credentials, reading content, or other sensitive information.

Support messages remain in the support mailbox until removed during mailbox maintenance or after a deletion request, unless retention is legally required. A deletion request can be sent to the same support alias. This out-of-app correspondence is described separately on the public privacy and support pages and does not change the current App Store declaration for data collected by the app.

## Public and private App Store information

- Public Support URL and Privacy Policy URL are necessary and use a support alias rather than the proprietor's personal contact details.
- Optional Marketing URL, Promotional Text, Privacy Choices URL, routing file, review attachment, and other unnecessary optional fields remain empty.
- App Review contact details and the required copyright value are held privately in App Store Connect and are not duplicated in this public repository.
- No full name, home address, phone number, personal account, repository URL, certificate, profile, or secret is intentionally published by the app metadata or support pages.
- App Store Connect currently identifies the developer as a trader for this app. This material status must be confirmed truthfully before enabling EU territories. Any information that Apple or applicable law requires to be public must be limited to that requirement; it must not be hidden or replaced with false information.

## Public copy and operational gates

The repository copy of the privacy policy distinguishes app behavior from user-initiated support email and contains no hypothetical clauses for SDKs or services that are absent. Publishing that revision remains a separate authorized action; until it is deployed, the live policy must be treated as needing synchronization.

Re-run this audit before any distribution build and whenever the app adds or changes StoreKit, advertising, analytics, crash reporting, network access, accounts, cloud sync, sharing, support inside the app, user-entered content, permissions, or third-party SDKs. Update the app, privacy manifest, public policy, App Store Privacy answers, support copy, and metadata together; never describe a planned service as if it were already present.
