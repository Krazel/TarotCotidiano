# Privacy and data inventory

Updated: 2026-08-12
Scope: Tarot Deck `0.7.2 (2)` TestFlight Internal Only candidate source before upload, plus the prior signed archive evidence recorded below. Build 2 recompiles the same app code and data behavior after a deterministic test-only correction; the candidate must be rechecked against its signed archive after CI processes the authorized upload.

## Current declaration

App Store Connect's **Data Not Collected / No se recopilan datos** answer remains accurate for the `0.7.2 (2)` candidate. The app has no account, backend, analytics, advertising, tracking, StoreKit, third-party runtime SDK, network client, or system permission request. It does not transmit readings, custom spread names or labels, favorites, language choices, device identifiers, contact information, or diagnostics to the developer.

The earlier Local-QA IPA SHA-256 is `8D8D9ECCD086D8EF03543FC155A3A0EE0C9CF4484F33DDE5B6053DDB31B9A0CF`. The signed Internal Only IPA has SHA-256 `13CDBC1F398CA4CECBEA5864CD4C89153CAC9879A7E03AC66336FCD8E5E0FA47`; CI verified bundle `com.krazel.tarotdeck`, version `0.2.1 (1)`, iOS 16, arm64, valid distribution signature, `get-task-allow=false`, embedded profile and `PrivacyInfo.xcprivacy` before upload. App Store Connect processed it and made it available only to the existing internal group.

## Information stored locally by the app

| Information | Storage | Purpose | Transmission | Removal |
|---|---|---|---|---|
| Selected language (`en` or `es`) | App-owned `UserDefaults`, key `tarot.appLanguage.v1` | Keep the explicit in-app language choice | None | Delete the app or clear its container |
| Preferred built-in reading preset | App-owned `UserDefaults`, key `tarot.readingPreset.v1` | Reopen Home with the user's last explicit built-in style | None | Choose another style, delete the app, or clear its container |
| Preferred selection kind and custom spread ID | App-owned `UserDefaults`, keys `tarot.readingSelection.kind.v2` and `tarot.readingSelection.customID.v2` | Reopen Home with the user's last explicit built-in or custom choice | None | Choose another style, delete the custom spread, delete the app, or clear its container |
| Active reading | `active-session.v1.json` in the app's Application Support directory | Restore the exact shuffled deck, cards, chosen slot positions and revealed state | None | Back from the reading, reset where applicable, or delete the app |
| Reading continuity | `reading-continuity.v1.json` in the same directory | Recover the selected built-in definition or immutable custom-spread snapshot and safe transition state after interruption | None | Cleared with the reading where applicable, or delete the app |
| Favorite card IDs | `favorites.v1.json` in the same directory | Keep the user's saved cards | None | Remove individual favorites or delete the app |
| Saved custom spreads | `custom-spreads.v1.json` in the same directory | Keep up to 50 user-created spread names, optional position labels, ordering and normalized layout coordinates | None | Delete an individual spread or delete the app |
| Custom spread recovery draft | `custom-spread-draft.v1.json` in the same directory | Resume an unfinished local custom-spread edit | None | Discard or finish the draft, or delete the app |

The JSON files contain app-defined card IDs and reading state. Custom spread files may also contain a user-entered spread name and optional short position labels; they are used only to render that saved spread and are never transmitted. The app does not request or store a person's name, email address, general journal or reading note, device identifier, location, contacts, photos, health data, payment data, or advertising identifier. The app-owned Application Support directory is excluded from device backup before these files are read or written, so the feature remains device-local and does not provide app-managed cloud sync or cross-device recovery.

## Permissions and platform access

- No camera, microphone, photos, contacts, calendar, location, Bluetooth, motion, health, notifications, local-network, tracking, or other protected-data permission is requested.
- The target has no corresponding `UsageDescription` strings.
- The app uses `UserDefaults` only for its own language and reading-selection preferences. `PrivacyInfo.xcprivacy` declares no tracking, no collected data, and the applicable required-reason API category for app-only preferences.
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
