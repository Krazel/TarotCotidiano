# Structural readiness — Tarot Deck core

**Verified:** 9 August 2026
**Scope:** non-visual Swift core, bundled content contract, local persistence, CI and release boundaries
**UI status:** excluded; provisional visual reference V-005 is not approved

## Readiness verdict

The repository now contains a standalone Swift package at `native-ios/Package.swift`, a pure Foundation deck engine, local JSON persistence, 78-card metadata, provenance controls and unit tests. The package appeared from the parallel structural implementation while this CI contract was being prepared. The structural core is therefore **implemented, pending its first macOS CI execution**.

The workflow at `.github/workflows/tarot-core.yml` validates static source/privacy boundaries, exact identity agreement between Swift and JSON, the content manifests and the package manifest; it then rejects external Swift package dependencies, builds the package in release configuration and runs all Swift tests. Its pre-package path remains intentionally tolerant for recoverability: it emits a visible notice only when `Package.swift` has never existed in Git history. If an incorporated package later disappears, CI fails instead of silently returning to the waiting state.

Static inspection on Windows confirms the expected package path, one library target, one test target and no declared package dependency. The workflow's full compiler-independent gate passes locally: Swift/JSON IDs match exactly, the source remains non-visual and offline, no obvious credential signature is present, and the dependency-free content validator passes. Swift is not installed on the current Windows host, so compilation and XCTest execution are correctly deferred to the macOS runner and must not be reported as passed until that workflow completes.

The 24 declared automated tests cover deterministic injected shuffle, invalid shuffle rejection, duplicate source-ID rejection, 78 unique draws and exhaustion, independent reveal state, reset, stable string Codable identity, session Codable round-trip, atomic replacement and clearing. The actor-coordinator tests additionally cover 100 concurrent draw attempts without duplication, repeated concurrent reveal idempotence, failed-save rollback, failed reset persistence without memory/disk divergence, failed clear without losing the active session, safe empty restoration for missing storage, discard-and-recover behavior for corrupt or unsupported storage, and exact valid-session restoration.

Structural readiness is not green yet because none of those XCTest sources has executed on macOS in this repository state. The remaining implementation-level evidence is the non-visual accessibility state contract when a feature/navigation layer is introduced; final accessibility remains tied to approved screens.

This work is authorized by A-016 and does not approve or implement layout, final artwork, icons, principal animation, store screenshots or any production screen.

## CI contract

The `Tarot core` workflow:

- runs on a GitHub-hosted macOS runner for pull requests and pushes that change `native-ios/**` or the workflow itself;
- can also be run manually;
- has read-only repository permission;
- does not read repository secrets, persist checkout credentials, sign an app, upload artifacts, deploy or publish;
- expects one standalone Swift Package at `native-ios/Package.swift`;
- verifies without Swift that the canonical 78 IDs are identical and identically ordered in `TarotCardID.swift` and `tarot-deck.v1.json`;
- rejects SwiftUI/UIKit imports and obvious network/web runtime use in the non-visual source target;
- scans the native package for common private-key, AWS, Google, GitHub and live Stripe credential signatures;
- accepts no external Swift package dependency for the MVP core;
- runs the dependency-free validator at `native-ios/Content/validate-content.ps1`;
- runs `swift build --package-path native-ios --configuration release`;
- runs `swift test --package-path native-ios --parallel`.

The workflow is a package gate, not an iOS application archive. Xcode app-target building, code signing, device UI tests, TestFlight and App Store delivery remain outside this workflow and require separate authorization.

The credential scan is deliberately conservative and dependency-free. It catches obvious committed secret formats but does not replace repository secret scanning or a release security review.

## Verifiable structural criteria

### 1. Deck engine

The core is ready when automated tests prove all of the following without importing SwiftUI or UIKit into the domain target:

- a session owns one concrete shuffled permutation of the canonical card IDs;
- production shuffle uses an injected randomness boundary and tests can supply deterministic randomness;
- shuffle preserves every input ID exactly once and does not assert that two random shuffles must differ;
- each draw advances exactly one position through the stored order;
- no card can be drawn twice before reset;
- draw and reveal are separate state transitions;
- reveal changes only a card that was already drawn;
- repeated or concurrent draw requests cannot skip or duplicate a card;
- the last draw and exhausted-deck states are explicit and do not wrap or reshuffle silently;
- reset replaces the complete session and clears prior draw and reveal state;
- the engine does not contain interpretations, daily selection, Zodiac logic, notifications, sharing or AI behavior.

### 2. Canonical 78-card content

The production content contract follows A-015: a standard 78-card tarot deck, English only and upright only for the MVP. Build-time tests must verify:

- exactly 78 records and 78 unique stable IDs;
- exactly 22 Major Arcana and 56 Minor Arcana;
- unique Major numbers covering `0...21`;
- four Minor suits: Wands, Cups, Swords and Pentacles;
- fourteen unique ranks per suit: Ace through Ten, Page, Knight, Queen and King;
- deterministic canonical order independent of shuffled order;
- every required field decodes and every enum value is recognized;
- production metadata is English and contains no Spanish legacy copy;
- no record from `data/tarot.js` enters the native production target;
- each future production artwork reference has a matching non-sensitive provenance identifier.

CI additionally compares the exact ordered Swift ID inventory with the exact ordered JSON ID inventory. This prevents the engine and content layer from silently assigning different identities to the same canonical position.

Artwork references may remain clearly marked placeholders during structural development. A placeholder, an unverified scan or a modern commercial Rider–Waite–Smith edition must never be accepted as release-ready content merely because the metadata tests pass.

The stable card ID is the compatibility boundary for replacing initial, rights-verified imagery with original Tarot Deck artwork later. Artwork filename, display copy and provenance record must not be used as the card's identity.

### 3. Session persistence

Persistence is ready when tests verify:

- a versioned `Codable` session round-trips without changing shuffle order, next index, drawn IDs or reveal state;
- only one active session is stored and no reading history is created;
- the complete replacement payload is written atomically in Application Support;
- a missing file creates a fresh valid session;
- corrupt data and unsupported schema versions recover safely without crashing or partially applying state;
- a failed save does not leave memory and disk representing different accepted sessions;
- reset persists the replacement session as one operation;
- no Keychain, SwiftData, Core Data, CloudKit, account or remote store is introduced.

Migration from the old Expo `AsyncStorage` payload is not part of the structural package. Decision T-002 must be resolved before a shipping bundle identity or migration path is finalized.

### 4. Privacy and offline operation

The MVP core is ready when repository inspection and tests confirm:

- no runtime network client, remote endpoint, account, analytics SDK, advertising SDK or tracking identifier;
- no notification registration or permission request;
- no embedded credential, signing material, API key or environment-specific secret;
- no third-party Swift package dependency;
- all card metadata required for a reading is bundled locally;
- shuffle, draw, reveal, reset, restore and content validation work with networking unavailable;
- diagnostics do not include card-reading history or other unnecessary user data.

Final App Store privacy answers must be checked against the actual signed binary later; passing this core gate is evidence for an offline, data-minimal design, not a publication authorization.

### 5. Non-visual accessibility contract

Visual accessibility is tested only after approved screens exist, but the domain and feature-state APIs must make an accessible implementation possible. Structural tests or API review must confirm that they expose:

- drawn position and face-down/face-up state independently of color, image or animation;
- the English card name and stable ID after reveal;
- explicit commands for draw, reveal and reset so gestures are never the only possible control path;
- a deterministic direct state transition that can be used when Reduce Motion is enabled;
- explicit last-card, exhausted-deck, recovery and persistence-error states suitable for VoiceOver announcements;
- state changes granular enough for UI code to preserve focus after reveal.

The core must not embed accessibility strings that depend on an unapproved layout. Final VoiceOver labels, reading order, Dynamic Type behavior, touch targets, contrast and focus behavior remain acceptance criteria for the approved SwiftUI screens.

## Provisional boundaries while V-005 is pending

Allowed before visual approval:

- pure Swift models, engine rules and deterministic tests;
- canonical English metadata and content validation;
- local persistence and recovery tests;
- feature-state and navigation state with no final presentation;
- CI, privacy checks and technical documentation;
- internal harnesses explicitly labelled provisional and excluded from the production UI target.

Not allowed before visual approval:

- final SwiftUI view hierarchy or layout values;
- final card face, card back, table artwork, typography or asset treatment;
- final icons, app icon, splash treatment or store screenshots;
- principal shuffle, deal, flip or reveal animations;
- treating V-005 or any internal harness as an approved production screen.

No structural test should force a particular visual arrangement. Domain APIs describe reading state and user intent; approved SwiftUI views will decide how that state is presented.

## Exit checklist

Structural readiness becomes **green** only when:

1. `native-ios/Package.swift` exists and `Tarot core` runs rather than taking its waiting path.
2. The package manifest has no external dependency and release build succeeds on macOS CI.
3. All engine, 78-card content and persistence criteria above are represented by passing automated tests.
4. The static CI gate confirms Swift/JSON identity parity, the non-visual/offline source boundary and absence of obvious credential signatures; repository inspection confirms the broader privacy boundary.
5. The package contains no production UI or unapproved final visual asset.
6. T-002 is either resolved or explicitly remains a release-only gate with no incompatible persistence assumption.

Passing this checklist authorizes integration of the non-visual core into a future approved iPhone app target. It does not approve a screen, visual asset, signing identity, build for distribution or publication.
