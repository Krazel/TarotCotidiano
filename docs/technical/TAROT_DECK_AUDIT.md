# Technical audit — iPhone digital tarot deck

**Project:** Tarot Cotidiano / working native module `TarotDeck`
**Verified:** 9 August 2026
**Scope:** static architecture audit for an English-only iPhone MVP
**Implementation performed:** none

## Executive conclusion

The approved clean SwiftUI restart remains the simplest and most publishable technical direction for the revised product. The existing Expo application is a small daily-reflection prototype, not a reusable production foundation for a digital tarot deck: its UI, daily-card selection, reminders, saves and 36 Spanish oracle cards solve a different problem. It should remain intact as historical reference.

The native application should be created later in a separate top-level `native-ios/` directory so Expo's `ios/` prebuild path cannot overwrite it. The recommended implementation has no third-party dependencies, network, account, notifications, analytics, database or localization layer. It consists of bundled English card metadata and approved artwork, a pure deck engine, one locally persisted active draw session and SwiftUI views built only after their exact images are approved.

There is no architectural blocker. There is one material product/content gate before card-face implementation: a physical-equivalent tarot deck normally contains the standard 78-card structure, while the repository contains 36 original reflective oracle cards. The recommendation is to make the native MVP a complete 78-card tarot deck with original or clearly licensed artwork, and to keep the 36 legacy cards outside the production bundle. This requires owner confirmation and art provenance before the first card face can be implemented.

## Verified facts

### Repository state

- `App.js` is a 1,039-line Expo/React Native prototype that combines navigation, presentation, daily selection, persistence, notifications and sharing.
- `data/tarot.js` contains 12 Spanish self-reflection categories and 36 cards, three per category. Its schema is `category`, `title`, `message` and `prompt`; it does not represent Major and Minor Arcana.
- `package.json` declares Expo 53, React Native 0.79.6, React 19, AsyncStorage and local notifications. Dependencies are not part of the native recommendation.
- `app.json` declares `com.dmkra.tarotcotidiano`, portrait orientation and iPhone-only support, but there is no Xcode project in the repository.
- The current `.gitignore` keeps native source trackable and excludes derived builds, signing material and downloaded dependencies.
- `DECISIONS.md` records the owner's approval of a clean iPhone SwiftUI restart while preserving Expo (`A-012`).
- No evidence in the repository proves that the bundle identifier has or has not shipped to real users.
- The approved images in `design/concepts/` depict the superseded daily-reflection flow. They are useful mood references but do not approve any digital-deck screen or state.

### Consequences of the product change

The following prototype behavior is not part of the digital-deck technical core:

- deterministic card of the day;
- category browsing;
- reflective messages and prompts;
- saved daily cards;
- daily reminder scheduling;
- notification permission and settings;
- automatic interpretation or guided reading.

The only reusable concepts are stable content identifiers, local-first behavior, system sharing patterns if later approved, and the general lesson that content must remain separate from presentation. Reusing the Expo screen structure or persistence payload would add migration cost without preserving an approved user experience.

## Recommended architecture

### Repository isolation

When implementation is authorized, create the native project alongside the untouched prototype:

```text
TarotCotidianoNative/
├── App.js                         # preserved Expo prototype
├── data/tarot.js                  # preserved 36-card Spanish oracle source
├── native-ios/
│   ├── TarotDeck.xcodeproj
│   ├── TarotDeck/
│   │   ├── App/
│   │   ├── Domain/
│   │   ├── Content/
│   │   ├── Persistence/
│   │   ├── Features/
│   │   └── Resources/Assets.xcassets
│   └── TarotDeckTests/
└── docs/ and design/              # durable decisions and approved references
```

Do not generate Expo native files into `native-ios/`, move the prototype, or share source targets between Expo and SwiftUI. The native product should use a distinct Xcode scheme and module name such as `TarotDeck`; the customer-facing app name and final bundle identifier remain release decisions.

### Runtime layers

Use one small application target and one unit-test target:

1. **Bundled content repository** decodes and validates English card metadata from a versioned JSON resource.
2. **Deck engine** owns shuffle, draw, reveal and reset as pure state transitions independent of SwiftUI.
3. **Session store** restores and atomically saves the one active draw session.
4. **Feature state** exposes the current session to SwiftUI and translates user actions into deck-engine operations.
5. **SwiftUI views** render approved screen references. They contain no shuffle, persistence or content-selection logic.

Use Foundation, SwiftUI and native accessibility APIs only. SwiftData, Core Data, CloudKit, a backend, remote configuration, dependency injection frameworks and third-party analytics are unnecessary for this MVP.

## Complete card model

### Canonical deck content

The recommended launch content is the conventional 78-card structure:

- 22 Major Arcana, with stable canonical order `0...21`;
- 56 Minor Arcana;
- four suits: Wands, Cups, Swords and Pentacles;
- fourteen ranks per suit: Ace through Ten, Page, Knight, Queen and King.

The content file should contain only structural English metadata required to identify and display the deck. Interpretations, daily messages, prompts, AI text and localization keys are outside this MVP.

Recommended immutable card fields:

| Field | Purpose |
|---|---|
| `id` | Stable machine identifier, never derived from display copy. |
| `canonicalOrder` | Deterministic validation and browsing order; never used as the shuffled order. |
| `name` | Approved English display name. |
| `arcana` | `major` or `minor`. |
| `suit` | Optional for Major Arcana; one of the four approved Minor suits. |
| `rank` | Optional for Major Arcana; Minor rank enum. |
| `majorNumber` | Optional `0...21` value for Major Arcana. |
| `artworkAsset` | Explicit asset-catalog key. |
| `accessibilityDescription` | Concise editorial description of meaningful artwork, if the card art needs more than its name. |
| `provenanceID` | Link to the internal rights/provenance record for the asset. |

Do not import the legacy `message` and `prompt` fields into the production schema merely for compatibility. Keep `data/tarot.js` unchanged as a separate oracle source.

### Draw-session model

Treat a shuffle as a concrete session, not as repeated random picks. A minimal versioned `DeckSession` stores:

- all 78 card IDs in their shuffled order;
- the index of the next undrawn card;
- drawn card IDs in draw order;
- reveal state per drawn card;
- orientation per drawn card if reversed cards are approved;
- creation and last-update timestamps;
- a schema version.

This guarantees no duplicate card before reset and allows an interrupted reading to survive app termination. The domain should not hard-code a one-card or three-card limit; the approved screen flow can impose a display limit without corrupting deck semantics.

Reversed orientation is a product choice, not an architectural requirement. The model can define `upright` and `reversed` while defaulting every draw to upright until the feature is explicitly approved. Do not expose a settings toggle or reversed meaning text by assumption.

## Shuffle, draw, reveal and reset

### Shuffle

- Start from the validated 78 unique IDs and use Swift's standard shuffle with `SystemRandomNumberGenerator` for production.
- Inject a deterministic random generator in tests. Cryptographic randomness and a remote entropy service are unnecessary.
- Shuffle the whole deck once per session; do not randomly select from the full catalog on every draw.
- Persist the shuffled order, not a random seed, so restoration does not depend on generator implementation details.

### Draw

- Drawing advances exactly one position in the shuffled order.
- A card cannot be drawn twice in the same session.
- Deck exhaustion is an explicit state; it must not wrap silently or reshuffle automatically.
- Reveal is separate from draw so a face-down table state can match the physical-deck metaphor and its approved image.
- Concurrent taps must be serialized or ignored while an animation/state transition is in progress.

### Reset

- Reset atomically discards the active order and drawn state, then creates a fresh shuffled session.
- Whether reset needs confirmation is a visual/product decision. The domain operation remains one transaction.
- Failed persistence must not leave memory and disk representing different sessions; save a complete replacement payload atomically.

## Local persistence and migration

Persist only what improves continuity:

- the active `DeckSession` as versioned `Codable` JSON in Application Support using an atomic file replacement;
- tiny presentation preferences, if any are approved, in `UserDefaults`.

Do not add reading history, favorites, journaling, iCloud sync or user accounts. Do not use Keychain: the MVP holds no credential or secret. If the stored session is absent, corrupt or from an unsupported schema, recover to a fresh deck and record a diagnostic without exposing technical detail to the user.

The old AsyncStorage payload contains daily-card preferences, saved legacy card IDs and a reminder. It has no semantic mapping to a 78-card draw session. Migration should therefore be omitted unless evidence shows an already distributed build with user data that must be retained. Reusing `com.dmkra.tarotcotidiano` without first establishing distribution history could unintentionally replace an installed product; resolve that before signing or release configuration, not before product and visual design.

## Artwork, rights and resource handling

The card art is the largest content and release risk, not the SwiftUI code.

- Do not assume that a Rider–Waite–Smith scan, restored color edition, commercial deck, web image or AI output is safe to distribute.
- Prefer artwork created for this product with documented commercial rights, or a source whose public-domain/licensing status is verified for every release territory.
- Keep a provenance manifest keyed by `provenanceID`: source/creator, license or ownership basis, proof location, attribution requirement, allowed modifications and approval date.
- Keep contracts, receipts, signing identities and personal data outside Git; keep a non-sensitive provenance summary and derived production assets in the repository.
- Validate that all 78 metadata records point to an existing approved asset and that no unapproved placeholder enters a release build.
- Preserve editable masters in design storage; put optimized runtime derivatives in the asset catalog. Do not eagerly decode all full-size faces into memory.
- Card backs, card faces and materially different table states each require their own visual approval before implementation.

The conventional card names and deck structure do not establish rights to any particular illustration, typography, border treatment, restored scan or edition branding. A rights review is required before the art is treated as production-ready.

## Accessibility requirements

Accessibility is part of the implementation contract, even when visual references are approved:

- Every interactive card must expose its name, face-down/face-up state, draw position and upright/reversed orientation to VoiceOver.
- Drawing, revealing and resetting must have explicit buttons or accessible actions; gestures, drag direction, color and animation cannot be the only controls.
- Decorative card-back detail should be hidden from VoiceOver. Meaningful card-face art should use the approved concise description rather than reading filenames.
- Support Dynamic Type for navigation, instructions and controls. The card title may scale within a bounded layout only if the approved reference remains legible.
- Meet native touch-target, safe-area and contrast requirements; verify at accessibility text sizes.
- Respect Reduce Motion and provide a direct state change instead of requiring a flip or shuffle animation.
- Preserve focus after reveal and announce deck exhaustion or reset without causing repetitive announcements.
- Test in portrait on the oldest and smallest supported iPhone as well as a current large model.

No visual approval can waive operability with VoiceOver, Dynamic Type, sufficient contrast or reduced motion. Any necessary deviation from a mockup should be recorded with the approval.

## Minimum verification plan

### Build-time content tests

- exactly 78 unique IDs;
- exactly 22 Major and 56 Minor cards;
- each Minor suit contains the fourteen expected ranks;
- Major numbers are unique and cover `0...21`;
- every `artworkAsset` and `provenanceID` resolves;
- all launch copy and metadata are English;
- no legacy oracle record is included in the production target.

### Unit tests

- shuffle returns a permutation with no loss or duplication;
- deterministic injected randomness produces repeatable test sessions;
- successive draws traverse the stored order exactly once;
- reveal changes only the selected drawn card;
- reset creates a new complete session and clears prior reveal state;
- empty, last-card and exhausted-deck transitions are explicit;
- repeated or concurrent draw requests cannot skip or duplicate cards;
- session encode/decode round-trips and corrupt/unsupported payloads recover safely;
- orientation behavior is tested only if reversed cards enter the approved scope.

Do not write a brittle test that expects two random shuffles to differ; randomness can legally produce the same order. Test invariants and deterministic generator behavior instead.

### UI and device verification after image approval

- compare implementation screenshots against each approved full-screen image at the same device size;
- run the complete shuffle → draw → reveal → additional draw → reset path;
- terminate and relaunch during an active reading and verify exact restoration;
- verify VoiceOver order/actions, Dynamic Type, Reduce Motion, contrast, safe areas and touch targets;
- stress repeated taps and background/foreground transitions;
- measure launch, reveal animation and memory with production-resolution assets;
- inspect the final archive for entitlements, privacy declarations, asset completeness and placeholder content;
- re-check current App Store/Xcode submission requirements only when a distribution candidate exists.

Tests can be specified before visual approval, but no screen or material screen state should be implemented to satisfy them until its image is explicitly approved.

## Publication posture

The recommended MVP can remain entirely offline and data-minimal. It needs no notification permission, sign-in, tracking disclosure caused by third-party analytics, network privacy policy behavior or server availability. The final App Store privacy answers must still be checked against the built binary and its actual dependencies.

A complete, polished 78-card deck with reliable shuffle/draw/reset, session continuity, original approved art and native accessibility is a coherent app rather than a web-content wrapper. Do not add Zodiac content, AI readings, subscriptions, ads, accounts or unrelated features merely to increase feature count. Store submission, TestFlight and publication remain separately authorized actions.

## Decisions: approved, reversible and pending

### Already approved

- iPhone/iOS only and English-only first version.
- Visual-first: no new screen/state implementation before its exact full-screen image is approved.
- Clean SwiftUI restart, preserving the Expo prototype intact.
- No publication without explicit authorization.

### Reversible technical decisions recommended under delegated autonomy

- Place the future Xcode project in `native-ios/` and leave Expo's root and generated `ios/` convention untouched.
- Use one app target, one test target and no third-party runtime dependency.
- Bundle validated content/art; keep the app offline.
- Use a pure deck engine plus one observable feature-state owner.
- Persist one active session as atomic versioned JSON; use `UserDefaults` only for tiny preferences.
- Exclude notifications, accounts, sync, history, saved readings and analytics from the native MVP.

### Material decisions still pending

| Decision | Recommendation | Why it blocks |
|---|---|---|
| Canonical launch deck | Approve a conventional 78-card tarot deck; preserve the 36 oracle cards only as legacy reference. | Card model, asset count, validation and every card-face image depend on it. |
| Artwork rights and provenance | Use original commissioned/owned art or individually verified commercially distributable art with a provenance manifest. | Unverified art cannot enter a release target or receive meaningful final approval. |
| Existing distribution / bundle identity | Establish whether `com.dmkra.tarotcotidiano` ever shipped before choosing the final native bundle identifier. | It determines replacement/migration obligations; it does not block product or visual concept work. |
| Reversed cards | Default to upright-only for the smallest MVP unless product explicitly requires reversals. | It changes draw state, card orientation visuals and accessibility copy, but not the architecture. |

The first material decision to elevate should be the canonical 78-card launch deck. Once approved, design can produce the complete first digital-deck screen/state and establish the artwork pipeline. Bundle identity can remain deferred until native project creation; distribution is not authorized now.

## Technical readiness verdict

**Ready for product and visual design; not ready for UI implementation.** SwiftUI is already approved and no new architecture approval is needed. The current blockers are product/content and per-screen visual approval, not a technology choice. After the 78-card decision and the first full-screen image are approved, a single implementation owner can create the isolated native skeleton and implement only that approved state while the Expo prototype remains recoverable and unchanged.
