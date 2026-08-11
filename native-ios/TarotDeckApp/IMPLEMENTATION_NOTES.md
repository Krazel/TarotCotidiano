# Tarot Deck internal SwiftUI implementation inventory

Status: unsigned internal iPhone implementation of the approved English/Spanish Read, Learn, Cards and Settings MVP surfaces. It is not a distributable target.

## Approved visual boundary

The live Read flow follows the approved Ceremonial Obsidian references V-080–V-089. V-080 governs the one-or-three selector with smaller information controls; V-081 governs the neutral five-style grid; V-082–V-085 govern ready, reshuffle and Deal in both orientations; V-086/V-087 govern the complete table with no deck; V-088 governs contextual tutorial navigation; and V-089 governs repeatable physical shuffle motion. V-064 still governs only the stable dark translucent primary tab bar material. Learn Index and Reading Tutorials follow V-072/V-073; V-071 governs the concise three-section article template. Card detail uses the plain `Meaning / Significado` heading, while `In a reading / En una tirada` applies that meaning to the question and assigned position.

Settings follows V-045; V-044's overlaid gear opens it from both empty and active Read Home states. Its app-owned selector atomically validates and swaps the complete English or Spanish UI/content snapshot. StoreKit products, prices, App Store rating and published legal URLs remain unavailable and unauthorized. Each row therefore gives explicit native internal-build feedback instead of invoking a dead callback, fabricated destination or simulated purchase.

## Live source inventory

Favorites follows V-042/V-043 without adding a tab or account.

- `App/TarotDeckInternalApp.swift`: debug-only iPhone composition root using `SystemDeckShuffler`.
- `App/TarotDeckMainShell.swift`: persistent `Read / Learn / Cards` shell and revealed-card meaning sheet.
- `Internal/ReadFlowModel.swift`: one durable reading coordinator plus layout continuity metadata.
- `Internal/FavoriteCardsStore.swift`: one app-owned set of canonical favorite IDs with versioned atomic JSON persistence.
- `Screens/Read/ReadViews.swift`: responsive Read Home, Layout Choice and generic One/Three Card table. Empty Home keeps its normal-size non-scrolling V-044 composition, uses a compact fitting variant on small iPhones, and permits scrolling only for accessibility Dynamic Type while the Settings gear remains overlaid.
- `Screens/Learn/LearnViews.swift`: four bilingual foundation lessons, a dedicated portal to six practical reading tutorials, and concise three-part articles with optional `Try This Reading` mapping to an existing Read preset.
- `Screens/Cards/CardsViews.swift`: 78-card library, Favorites plus six deck filters, empty Favorites state, upright meaning, non-wrapping previous/next and Dynamic Type-aware one/two-column presentation.
- `Screens/Settings/SettingsView.swift`: approved Settings index with safe internal-build availability feedback and bundle-derived version display.
- `Content/AppLocalization.swift`: one persistent iOS 16 language store, language-specific String Catalog lookup and atomic content swapping. English is the String Catalog source language read from the main bundle and does not require a physical `en.lproj`; Spanish requires `es.lproj`. Before commit it resolves every key listed in the versioned runtime interface manifest, so an incomplete language cannot produce a mixed snapshot.
- `Content/TarotContent.swift`: strict language-explicit 78/78/7 loading, exact tutorial order/preset parity, and required artwork descriptions.
- `Resources/required-interface-keys.v1.json`: target-bundled manifest that must exactly match every String Catalog key and is validated for the candidate language before selection commits.
- `Components/TarotArtworkView.swift`: local hash-verified historical candidates and an explicit `ART PENDING` ceremonial fallback.
- `Design/CeremonialMotion.swift`: approved iOS 16 press/cut/interleave/settle/deal/flip tokens and post-landing haptics.

The earlier S03.2–S03.4 fixture files remain in the repository as visual implementation history but are not compiled by the app target. The deleted provisional harness is no longer referenced by the Xcode project.

## Session and privacy invariants

`DeckSession` remains the only source of truth for shuffled order, draws and face-up state. The app stores only a companion layout/phase/session-ID record so a one-card or three-card reading can be reconstructed without guessing. That companion is a distinct Codable JSON sidecar at `Application Support/TarotDeckInternal/reading-continuity.v1.json`, next to but separate from `active-session.v1.json`, and every replacement uses `Data.write(..., .atomic)`. On restoration, an active session is accepted only when its durable session ID matches the companion record and its drawn count fits the chosen layout. Inconsistent state is cleared instead of being represented incorrectly.

Restoration additionally requires an exact 78-card permutation of `StandardTarotDeck.cardIDs`, unique IDs, drawn IDs resolvable by bundled content, and a draw count compatible with the recorded layout. The initial Read surface is a non-interactive restoring state rather than a tappable empty Home.

The `.ready(layout)` companion record is persisted before `startSession()`. If the app stops after the durable session commit but before the companion record is promoted to `.active`, restoration accepts only the demonstrable `ready + canonical zero-draw session` combination, promotes it to active, and reports recovery. Corrupt, missing or contradictory metadata is cleared; an otherwise unrepresentable session is durably discarded before an empty Home is published.

Shuffle creates the real persisted session. Draw, reveal and conceal each use an independent coordinator command and refresh from the coordinator only after its persistence boundary succeeds. Navigation among Read, Learn and Cards does not replace the model. Ending or replacing a reading clears the coordinator and continuity record through the exact approved native confirmation alerts.

Restore, metadata, shuffle, draw, reveal, conceal and clear failures preserve the last valid published state and present a generic native issue alert with a safe retry. No storage error detail or card ID enters user-facing feedback. End/replace publish Home or Layout Choice only after the coordinator's durable clear succeeds.

The Learn CTA selects a new Three Cards ready state when no session exists. An active Three Cards session resumes directly. An active One Card session is never relabelled or silently replaced: Read presents the standard native replacement confirmation over that exact table, cancellation preserves it, and confirmation durably clears it before atomically saving the new Three Cards ready sidecar.

A face-down card is labelled only by position and face-down state. Its identity is never interpolated into visible copy, VoiceOver, error copy or logs. Meaning inspection is accepted only after `DeckSession` says that exact card is revealed.

Favorites is independent from `DeckSession`. The single `FavoriteCardsStore` is created by the composition root and shared by meanings opened from Read and Cards. It persists only canonical IDs to `Application Support/TarotDeckInternal/favorites.v1.json`; the local directory is excluded from device backup, writes are atomic, and UI state publishes only after success. Missing storage means an empty set. Corrupt, duplicate or unknown IDs recover to an empty list with localized feedback and never block the deck. Ending a reading does not clear favorites.

## Motion boundary

V-089 and `design/tarot-deck/MOTION_SPEC.md` define the live motion language. Each valid deck tap commits a fresh full order, then presents press, split/cut, interleave, riffle and square. `Deal / Repartir` commits the complete one- or three-card layout before sequential curved presentation, so interruption restores a complete stable table. Reveal/conceal use independent two-surface vertical-axis turns whose destination face remains hidden until the midpoint. After Deal the deck remains absent; reset is the only quick restart.

Motion observes only the already-published `DeckSession` signature, so a failed save cannot trigger a success haptic or animation. Presentation keeps its own cancellable token and stable visual baseline; the success haptic fires only after settle, landing or flip completion while the scene remains active. Restoration, rotation, backgrounding or leaving the table cancels overlays and establishes the latest committed state without replay. Reduce Motion and VoiceOver replace displacement, scale and 3D turns with short opacity changes; decorative packets and dealt overlays remain hidden from accessibility while the committed position supplies semantics. The implementation uses only SwiftUI/UIKit APIs available on iOS 16 and contains no looping ambience, particles or iOS 17 motion APIs.

## Artwork boundary

The owner-selected D — Three-Card Fan icon is installed as `Resources/Assets.xcassets/AppIcon.appiconset`. Its single universal iOS rendition is a byte-identical copy of the prepared design master at `design/tarot-deck/app-icon-masters/app-icon-d-three-card-fan-1024.png`: 1024 × 1024, 8-bit opaque sRGB RGB PNG, no alpha/transparency and no baked iOS mask, SHA-256 `FFB38A413D8A99433A7A13E8626143A4FED96AD41AAB774D5D2C520C20BE200E`. The generated 1254 × 1254 concept and every other icon concept remain preserved. Both target build configurations use `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon`; the existing `Assets.xcassets` Resources membership includes the icon set without adding a second catalog reference.

`native-ios/Tools/sync-verified-candidate-assets.ps1` reads `Content/CandidateRWS/local-evidence.v2.json`, verifies each local candidate against recorded SHA-1, bytes and dimensions, and copies it to the single app asset catalog without deleting valid assets. Rerun it whenever the candidate downloader produces a newer evidence snapshot, including at 78 candidates.

Every historical face remains provisional and has `distributionApproved=false` in the current evidence. The internal app can render only verified local candidates; missing candidates use the conspicuous ceremonial `ART PENDING` fallback. `validate-app-integration.ps1` treats this as an allowed internal snapshot and reports the explicit placeholder count. Its `-ReleaseGate` mode separately requires 78/78 verified, final and distribution-approved assets with zero failures.

The current internal snapshot contains 78/78 hash-verified bundled candidates and zero placeholders. This is completeness of the internal candidate snapshot only: `candidateOnly=true`, `finalAsset=false`, `distributionApproved=false`, and territorial rights review remains pending, so the release gate still fails intentionally.

The runtime image-set allowlist is exactly the 78 canonical `artworkAsset` names plus `ceremonial-card-back`. The former `rws-the-moon` duplicate belonged only to an excluded historical fixture and has been removed from the runtime catalog; CandidateRWS and design sources remain untouched.

All 78 meanings contain `artworkDescription`. Revealed cards and the library pass this field into the artwork component for VoiceOver; a missing image is described honestly as a provisional placeholder rather than as the final scene.

## Verification boundary

The macOS CI job validates content and the internal snapshot, builds/tests the Foundation-only core, then runs an unsigned Debug simulator build of `TarotDeck.xcodeproj` / `TarotDeckInternal`. It performs no archive, signing, upload or publication.

Windows can run the content, education, asset-sync and app-integration validators, but cannot compile SwiftUI, render previews or prove Xcode target resolution. Before considering the internal implementation visually verified, CI or a Mac must complete the unsigned Xcode build and simulator checks in portrait, landscape, VoiceOver and accessibility Dynamic Type.
