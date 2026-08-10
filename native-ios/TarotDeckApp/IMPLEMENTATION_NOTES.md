# Tarot Deck internal SwiftUI implementation inventory

Status: unsigned internal iPhone implementation of the approved English Read, Learn, Cards and Settings MVP surfaces. It is not a distributable target.

## Approved visual boundary

The live Read flow follows the approved Ceremonial Obsidian references V-014, V-024, V-028–V-032, V-035–V-038, V-011/V-012 and V-017/V-018. V-037/V-038 are the current One Card face-down references and supersede V-033/V-034: once the single card is drawn, the remaining deck disappears. Learn, Cards and upright meaning follow V-019–V-023.

Settings follows V-025; V-024's discreet gear opens it from both empty and active Read Home states. StoreKit products, prices, App Store rating and published legal URLs remain unavailable and unauthorized. Each row therefore gives explicit native internal-build feedback instead of invoking a dead callback, fabricated destination or simulated purchase.

## Live source inventory

- `App/TarotDeckInternalApp.swift`: debug-only iPhone composition root using `SystemDeckShuffler`.
- `App/TarotDeckMainShell.swift`: persistent `Read / Learn / Cards` shell and revealed-card meaning sheet.
- `Internal/ReadFlowModel.swift`: one durable reading coordinator plus layout continuity metadata.
- `Screens/Read/ReadViews.swift`: responsive Read Home, Layout Choice and generic One/Three Card table.
- `Screens/Learn/LearnViews.swift`: six-article beginner guide.
- `Screens/Cards/CardsViews.swift`: 78-card library, six filters, upright meaning, non-wrapping previous/next and Dynamic Type-aware one/two-column presentation.
- `Screens/Settings/SettingsView.swift`: approved Settings index with safe internal-build availability feedback and bundle-derived version display.
- `Content/TarotContent.swift`: strict 78/78/6 loading and required artwork descriptions.
- `Components/TarotArtworkView.swift`: local hash-verified historical candidates and an explicit `ART PENDING` ceremonial fallback.

The earlier S03.2–S03.4 fixture files remain in the repository as visual implementation history but are not compiled by the app target. The deleted provisional harness is no longer referenced by the Xcode project.

## Session and privacy invariants

`DeckSession` remains the only source of truth for shuffled order, draws and face-up state. The app stores only a companion layout/phase/session-ID record so a one-card or three-card reading can be reconstructed without guessing. That companion is a distinct Codable JSON sidecar at `Application Support/TarotDeckInternal/reading-continuity.v1.json`, next to but separate from `active-session.v1.json`, and every replacement uses `Data.write(..., .atomic)`. On restoration, an active session is accepted only when its durable session ID matches the companion record and its drawn count fits the chosen layout. Inconsistent state is cleared instead of being represented incorrectly.

Restoration additionally requires an exact 78-card permutation of `StandardTarotDeck.cardIDs`, unique IDs, drawn IDs resolvable by bundled content, and a draw count compatible with the recorded layout. The initial Read surface is a non-interactive restoring state rather than a tappable empty Home.

The `.ready(layout)` companion record is persisted before `startSession()`. If the app stops after the durable session commit but before the companion record is promoted to `.active`, restoration accepts only the demonstrable `ready + canonical zero-draw session` combination, promotes it to active, and reports recovery. Corrupt, missing or contradictory metadata is cleared; an otherwise unrepresentable session is durably discarded before an empty Home is published.

Shuffle creates the real persisted session. Draw, reveal and conceal each use an independent coordinator command and refresh from the coordinator only after its persistence boundary succeeds. Navigation among Read, Learn and Cards does not replace the model. Ending or replacing a reading clears the coordinator and continuity record through the exact approved native confirmation alerts.

Restore, metadata, shuffle, draw, reveal, conceal and clear failures preserve the last valid published state and present a generic native issue alert with a safe retry. No storage error detail or card ID enters user-facing feedback. End/replace publish Home or Layout Choice only after the coordinator's durable clear succeeds.

The Learn CTA selects a new Three Cards ready state when no session exists. An active Three Cards session resumes directly. An active One Card session is never relabelled or silently replaced: Read presents the standard native replacement confirmation over that exact table, cancellation preserves it, and confirmation durably clears it before atomically saving the new Three Cards ready sidecar.

A face-down card is labelled only by position and face-down state. Its identity is never interpolated into visible copy, VoiceOver, error copy or logs. Meaning inspection is accepted only after `DeckSession` says that exact card is revealed.

## Artwork boundary

`native-ios/Tools/sync-verified-candidate-assets.ps1` reads `Content/CandidateRWS/local-evidence.v2.json`, verifies each local candidate against recorded SHA-1, bytes and dimensions, and copies it to the single app asset catalog without deleting valid assets. Rerun it whenever the candidate downloader produces a newer evidence snapshot, including at 78 candidates.

Every historical face remains provisional and has `distributionApproved=false` in the current evidence. The internal app can render only verified local candidates; missing candidates use the conspicuous ceremonial `ART PENDING` fallback. `validate-app-integration.ps1` treats this as an allowed internal snapshot and reports the explicit placeholder count. Its `-ReleaseGate` mode separately requires 78/78 verified, final and distribution-approved assets with zero failures.

The current internal snapshot contains 78/78 hash-verified bundled candidates and zero placeholders. This is completeness of the internal candidate snapshot only: `candidateOnly=true`, `finalAsset=false`, `distributionApproved=false`, and territorial rights review remains pending, so the release gate still fails intentionally.

The runtime image-set allowlist is exactly the 78 canonical `artworkAsset` names plus `ceremonial-card-back`. The former `rws-the-moon` duplicate belonged only to an excluded historical fixture and has been removed from the runtime catalog; CandidateRWS and design sources remain untouched.

All 78 meanings contain `artworkDescription`. Revealed cards and the library pass this field into the artwork component for VoiceOver; a missing image is described honestly as a provisional placeholder rather than as the final scene.

## Verification boundary

The macOS CI job validates content and the internal snapshot, builds/tests the Foundation-only core, then runs an unsigned Debug simulator build of `TarotDeck.xcodeproj` / `TarotDeckInternal`. It performs no archive, signing, upload or publication.

Windows can run the content, education, asset-sync and app-integration validators, but cannot compile SwiftUI, render previews or prove Xcode target resolution. Before considering the internal implementation visually verified, CI or a Mac must complete the unsigned Xcode build and simulator checks in portrait, landscape, VoiceOver and accessibility Dynamic Type.
