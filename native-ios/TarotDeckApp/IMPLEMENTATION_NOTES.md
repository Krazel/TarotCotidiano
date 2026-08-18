# Tarot Deck internal SwiftUI implementation inventory

Status: public iPhone source candidate `1.0 (1)` of the approved English/Spanish Read, Learn, Cards and Settings MVP surfaces. A-061 corrects localization, the selector information position and public Settings destinations; A-062 makes the orientation recommendation an inline once-per-reading cue and fixes the landscape deck on the physical right. Xcode runtime QA, public screenshots, synchronized web pages, binary upload, build selection and App Review submission remain separate gates.

## Approved visual boundary

A-059 remains governed by V-108–V-119 except where V-129/V-130 replace the orientation hint presentation with inline cue copy; V-110/V-111 remain the post-hint portrait state and V-116/V-117 keep the deck on the landscape right. A-061 adds V-123–V-126 for the upper-left information controls and V-127/V-128 for release-ready Settings. These references preserve 44-point targets, keep selection ticks on the right, and replace simulated Support/Restore/Terms rows with functional Rate, Privacy and Support destinations.

The live Read flow follows Ceremonial Obsidian: V-123/V-124 govern reading-kind selection, V-125/V-126 the neutral five-style grid and V-088 contextual tutorial navigation. Their information glyph is visually 22 points at the upper-left while its full control remains 44×44 points; V-120/V-121 are preserved historical references. V-064 governs only the stable dark translucent primary tab bar material. Learn Index and Reading Tutorials follow V-072/V-073; V-071 governs the concise three-section article template. Card detail uses the plain `Meaning / Significado` heading, while `In a reading / En una tirada` applies that meaning to the question and assigned position.

Settings follows V-127/V-128; V-044's overlaid gear opens it from both empty and active Read Home states. Its app-owned selector atomically validates and swaps the complete English or Spanish UI/content snapshot. The public screen contains only Language, a persistent App Store write-review link, Privacy, Support and the localized version footer. There is no StoreKit purchase surface, product identifier, simulated restore action, terms row or internal-build fallback.

## Live source inventory

Favorites follows V-042/V-043 without adding a tab or account.

- `App/TarotDeckInternalApp.swift`: iPhone composition root using `SystemDeckShuffler` in every build configuration.
- `App/TarotDeckMainShell.swift`: persistent `Read / Learn / Cards` shell and revealed-card meaning sheet.
- `Internal/ReadFlowModel.swift`: one durable reading coordinator plus layout continuity metadata.
- `Internal/FavoriteCardsStore.swift`: one app-owned set of canonical favorite IDs with versioned atomic JSON persistence.
- `Screens/Read/ReadViews.swift`: responsive Read Home, reading choices and generic 1–12-card table. The table automatically shuffles a new/reset reading once, keeps the deck visible in empty/partial/complete states, offers a separate repeatable Shuffle, places the next card either in the tapped slot or the first canonical empty slot when the deck is tapped, and shows a non-reserving three-second `phone / teléfono` rotation hint for portrait multi-card readings. Landscape raises and compacts the header to reserve more room for cards. Every empty/back/front/flip/overlay surface derives from one post-clamp slot geometry with at least 14 points of visible separation; the deterministic row-major presentation fallback never mutates stored custom points or order.
- A-056 selector contract in `Screens/Read/ReadViews.swift`: the order remains One/Three/Six/Custom; Six uses a dedicated exact 2x3 glyph and Custom uses a separate outlined-layout plus glyph.
- `Screens/Learn/LearnViews.swift`: four bilingual foundation lessons, a dedicated portal to six practical reading tutorials, and concise three-part articles with optional `Try This Reading` mapping to an existing Read preset.
- `Screens/Cards/CardsViews.swift`: 78-card library, Favorites plus six deck filters, empty Favorites state, Meaning detail, non-wrapping previous/next and Dynamic Type-aware one/two-column presentation. V-122 keeps the seven 44-point capsules in a native horizontal scroll view and makes overflow discoverable through a partially visible next chip, native indicator and conditional physical-edge fade/chevron. Its bilingual accessibility hint explains the horizontal gesture without adding persistent instructional copy.
- `Screens/Settings/SettingsView.swift`: approved Settings index with safe internal-build availability feedback and bundle-derived version display.
- `Content/AppLocalization.swift`: one persistent iOS 16 language store, language-specific String Catalog lookup and atomic content swapping. English is the String Catalog source language read from the main bundle and does not require a physical `en.lproj`; Spanish requires `es.lproj`. Before commit it resolves every key listed in the versioned runtime interface manifest, so an incomplete language cannot produce a mixed snapshot.
- `Content/TarotContent.swift`: strict language-explicit 78/78/7 loading, exact tutorial order/preset parity, and required artwork descriptions.
- `Resources/required-interface-keys.v1.json`: target-bundled manifest that must exactly match every String Catalog key and is validated for the candidate language before selection commits.
- `Components/TarotArtworkView.swift`: owner-approved, hash-verified historical faces with factual VoiceOver descriptions; an impossible missing-asset path is labelled as a build error rather than provisional art.
- `Design/CeremonialMotion.swift`: approved iOS 16 press/cut/interleave/settle/manual-placement/flip tokens and post-landing haptics.

The earlier S03.2–S03.4 fixture files remain in the repository as visual implementation history but are not compiled by the app target. The deleted provisional harness is no longer referenced by the Xcode project.

## Session and privacy invariants

`DeckSession` schema 2 remains the only source of truth for shuffled order, draw order, exact `positionIndex` and face-up state. Its decoder migrates a schema-1 sequential session losslessly by assigning positions `0..<drawnCards.count`; later unknown schemas still fail closed. The app stores only a companion layout/phase/session-ID record so a built-in or custom reading can be reconstructed without guessing. That companion is a distinct Codable JSON sidecar at `Application Support/TarotDeckInternal/reading-continuity.v1.json`, next to but separate from the historical path `active-session.v1.json`, and every replacement uses `Data.write(..., .atomic)`. On restoration, an active session is accepted only when its durable session ID matches the companion record and every unique saved position fits the selected snapshot. Inconsistent state is cleared instead of being represented incorrectly.

Restoration additionally requires an exact 78-card permutation of `StandardTarotDeck.cardIDs`, unique IDs, drawn IDs resolvable by bundled content, and a draw count compatible with the recorded layout. The initial Read surface is a non-interactive restoring state rather than a tappable empty Home.

The `.ready(layout)` companion record is persisted before `startSession()`. If the app stops after the durable session commit but before the companion record is promoted to `.active`, restoration accepts only the demonstrable `ready + canonical zero-draw session` combination, promotes it to active, and reports recovery. Corrupt, missing or contradictory metadata is cleared; an otherwise unrepresentable session is durably discarded before an empty Home is published.

The automatic first shuffle creates the real persisted session only for a new/reset ready table. Restoration of an active session never starts presentation, haptics or a second shuffle. Repeated Shuffle preserves the complete dealt prefix, positions, reveal states and session identity and atomically permutes only the undealt suffix. Its write-ahead `.reshuffling` marker recovers to the committed canonical session when present, or safely clears an orphaned marker without inventing an order. Manual placement, reveal and conceal each refresh from the coordinator only after persistence succeeds. A placement writes the next deck card and chosen slot in the same atomic session replacement, so interruption cannot separate them.

Restore, metadata, shuffle, draw, reveal, conceal and clear failures preserve the last valid published state and present a generic native issue alert with a safe retry. No storage error detail or card ID enters user-facing feedback. End/replace publish Home or Layout Choice only after the coordinator's durable clear succeeds.

The Learn CTA selects a new Three Cards ready state when no session exists. An active Three Cards session resumes directly. An active One Card session is never relabelled or silently replaced: Read presents the standard native replacement confirmation over that exact table, cancellation preserves it, and confirmation durably clears it before atomically saving the new Three Cards ready sidecar.

A face-down card is labelled only by position and face-down state. Its identity is never interpolated into visible copy, VoiceOver, error copy or logs. Meaning inspection is accepted only after `DeckSession` says that exact card is revealed.

Favorites is independent from `DeckSession`. The single `FavoriteCardsStore` is created by the composition root and shared by meanings opened from Read and Cards. It persists only canonical IDs to `Application Support/TarotDeckInternal/favorites.v1.json`; the local directory is excluded from device backup, writes are atomic, and UI state publishes only after success. Missing storage means an empty set. Corrupt, duplicate or unknown IDs recover to an empty list with localized feedback and never block the deck. Ending a reading does not clear favorites.

## Motion boundary

V-119 and `design/tarot-deck/MOTION_SPEC.md` define the live motion language. New/reset entry commits before presenting one automatic shuffle. The independent Shuffle control remains available after placement and after the authored layout is complete whenever undealt cards remain. Tapping the persistent deck places the next card in the first canonical empty slot; tapping an empty slot places it there. The deck remains visible but non-dealing after completion. No table control or slot is visually dimmed while transaction/presentation locks prevent duplicate input.

Shuffle presentation observes an ephemeral post-commit generation rather than session identity, because an undealt-suffix shuffle deliberately preserves that identity. One request may queue behind current table choreography; further requests are ignored until that single queued transaction resolves. A failed save emits neither success presentation nor haptic. Restoration, rotation, backgrounding or leaving cancels overlays and adopts committed state without replay. Reduce Motion and VoiceOver use shortened presentation, with no restore haptic; the implementation uses only SwiftUI/UIKit APIs available on iOS 16.

A-055 removes placement rotation so the travelling card remains inside the reserved slot-clearance envelope. Landing swaps the overlay for the committed face-down surface in a transaction with no implicit animation, so orientation changes and state transitions cannot leave two differently sized card surfaces visible.

## Artwork boundary

The owner-selected D — Three-Card Fan icon is installed as `Resources/Assets.xcassets/AppIcon.appiconset`. Its single universal iOS rendition is a byte-identical copy of the prepared design master at `design/tarot-deck/app-icon-masters/app-icon-d-three-card-fan-1024.png`: 1024 × 1024, 8-bit opaque sRGB RGB PNG, no alpha/transparency and no baked iOS mask, SHA-256 `FFB38A413D8A99433A7A13E8626143A4FED96AD41AAB774D5D2C520C20BE200E`. The generated 1254 × 1254 concept and every other icon concept remain preserved. Both target build configurations use `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon`; the existing `Assets.xcassets` Resources membership includes the icon set without adding a second catalog reference.

`native-ios/Tools/sync-verified-candidate-assets.ps1` reads `Content/CandidateRWS/local-evidence.v2.json`, requires its complete final `US/GB/ES`-only state, verifies every local source file against recorded SHA-1, bytes and dimensions, and copies it to the single app asset catalog without deleting valid assets. It rejects incomplete, provisional or worldwide-expanded evidence.

The current bundle contains all 78 owner-approved final faces, each mapped one-to-one to its canonical asset and verified against the recorded source integrity evidence. Rights evidence clears only the explicit `US`, `GB` and `ES` storefront allowlist: `distributionApprovedForDeclaredTerritories=true`, `distributionApproved=false` and `worldwideDistributionApproved=false`. The internal gate checks completeness without granting distribution; `-ReleaseGate` additionally requires the caller to provide the exact intended storefronts and rejects every territory outside that allowlist.

The runtime image-set allowlist is exactly the 78 canonical `artworkAsset` names plus `ceremonial-card-back`. The former `rws-the-moon` duplicate belonged only to an excluded historical fixture and has been removed from the runtime catalog; CandidateRWS and design sources remain untouched.

All 78 meanings contain `artworkDescription`. Revealed cards and the library pass this field into the artwork component for VoiceOver; release validation rejects a missing canonical face or a non-final record.

## Verification boundary

The macOS CI job validates content and the internal snapshot, builds/tests the Foundation-only core, then runs an unsigned Debug simulator build of `TarotDeck.xcodeproj` / `TarotDeckInternal`. It performs no archive, signing, upload or publication.

Windows can run the content, education, asset-sync and app-integration validators, but cannot compile SwiftUI, render previews or prove Xcode target resolution. Before considering the internal implementation visually verified, CI or a Mac must complete the unsigned Xcode build and simulator checks in portrait, landscape, VoiceOver and accessibility Dynamic Type.
