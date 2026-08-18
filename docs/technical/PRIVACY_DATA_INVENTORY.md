# Privacy and data inventory

Updated: 2026-08-18
Scope: public source candidate `1.0 (1)`. The last signed evidence remains TestFlight `0.8 (1)`; this public candidate has not yet been built with Xcode.

## App Privacy answer

**Data Not Collected / No se recopilan datos** remains accurate for the current source. The app has no account, backend, analytics, advertising, tracking, crash-reporting SDK, StoreKit purchase flow, third-party runtime SDK, or app-initiated network client. It does not transmit readings, custom-spread text, favorites, language choices, device identifiers, contact information, or diagnostics to the developer.

The three Settings destinations open only after a user taps them:

- App Store review page: `https://apps.apple.com/app/id6800144105?action=write-review`;
- Privacy: `https://krazel.github.io/tarot-deck/privacy/`;
- Support: `https://krazel.github.io/tarot-deck/support/`.

The app does not append identifiers or stored content to those URLs. Opening a browser or App Store destination is not app collection, but the destination provider processes the connection under its own terms.

## Information stored only on the device

| Information | Storage | Purpose | Transmission | User control |
|---|---|---|---|---|
| Selected language (`en`/`es`) | App-owned `UserDefaults`: `tarot.appLanguage.v1` | Keep the explicit app-language choice | None | Select another language or delete the app |
| Preferred built-in preset | App-owned `UserDefaults`: `tarot.readingPreset.v1` | Reopen Home with the last built-in style | None | Select another style or delete the app |
| Preferred selection kind and custom ID | App-owned `UserDefaults`: `tarot.readingSelection.kind.v2`, `tarot.readingSelection.customID.v2` | Restore the last built-in/custom choice | None | Change selection, delete the custom spread, or delete the app |
| Active reading | `active-session.v1.json` in Application Support | Restore deck order, placements and reveal state | None | Leave/reset as offered, or delete the app |
| Reading continuity | `reading-continuity.v1.json` | Recover the selected definition and interrupted transition safely | None | Cleared with the reading where applicable, or delete the app |
| Favorite card IDs | `favorites.v1.json` | Keep the user's saved cards | None | Remove favorites or delete the app |
| Saved custom spreads | `custom-spreads.v1.json` | Keep up to 50 names, optional labels, order and layout coordinates | None | Delete a spread or delete the app |
| Custom-spread recovery draft | `custom-spread-draft.v1.json` | Resume an unfinished edit | None | Finish/discard the draft or delete the app |

Custom-spread names and optional position labels are user-entered text, used only to display that local spread. The app does not request or store a person's name, email, journal, general question, reading note, device identifier, location, contacts, photos, health data, payment data, or advertising identifier.

The app-owned Application Support directory is excluded from device backup before these files are accessed. The app provides no account, app-managed cloud sync, export, sharing, history service or cross-device recovery.

## Permissions, APIs and SDKs

- No camera, microphone, photos, contacts, calendar, location, Bluetooth, motion, health, notifications, local-network, tracking or other protected-data permission.
- No corresponding `UsageDescription` key.
- `PrivacyInfo.xcprivacy` declares `NSPrivacyTracking=false`, an empty collected-data array, and only the app-owned UserDefaults required-reason API `CA92.1`.
- No third-party framework, extension, plug-in or SDK privacy manifest in the target.
- iOS 16 minimum; no API in this change requires a later OS.

## Support email outside the app

The app does not collect support data. If a person follows the Support page and voluntarily emails the public alias, the email provider processes the sender address, message and any troubleshooting detail they choose to include. Support should not request full name, phone number, device identifier, credentials, reading content or attachments unless a specific case genuinely requires it.

Out-of-app support correspondence is separate from the App Store declaration for data collected by the app. The public privacy/support pages must explain it accurately and provide the applicable deletion-contact route without exposing the proprietor's personal information.

## Public and private information

- Public: app-specific Privacy and Support URLs using a support alias.
- Empty because unnecessary: Marketing URL, Promotional Text, Privacy Choices URL, routing file and review attachment.
- Private in App Store Connect: App Review contact and required account/legal values that are not meant for the public page.
- Do not publish the proprietor's full name, home address, phone number, personal accounts, repository, certificate, profile or secrets unless Apple or law specifically requires the item.
- App Store Connect identifies the developer as trader. If Spain is enabled, DSA-required trader information must be truthful; minimization cannot be used to omit a legal requirement.

## Synchronization gate

On 2026-08-18 the live Privacy and Support pages both returned HTTP 200. The Privacy page still names only active reading, language and favorites; it must be updated before App Review to cover every local item in this inventory, especially preferred preset/selection, continuity, custom spreads and the recovery draft. The Support page must describe the current one/three/six/custom product, use `Meaning / Significado` rather than the obsolete upright-only label, and remove the tangential generic tarot disclaimer.

The exact App Store write-review URL returned HTTP 404 on the same date while this app record was not publicly available. Keep the official persistent URL required by the Settings contract, but re-test its destination after the listing becomes public; do not claim a successful live review flow from TestFlight or this source-only audit.

Publishing those page changes is an external action and was not performed here.

Re-run this inventory against the exact signed public RC and whenever StoreKit, ads, analytics, crash reporting, accounts, cloud sync, sharing, permissions, network behavior, support integration, user-entered content, or a third-party SDK changes.
