# Tarot Deck — Visual-First Brief

Status: first Tarot Deck candidate generated; no new screen is visually approved
Updated: 2026-08-09
Platform: iPhone/iOS only
Product language: English only

## Product boundary

This brief covers the redefined Tarot product: a digital deck that lets a person shuffle, draw, place, and reveal cards for their own reading. It does not cover an automatic daily card, editorial reflection prompts, AI interpretation, reminders, or the separate Zodiac/Horoscope product.

No interface may be implemented from this brief. A complete image of each new Tarot Deck screen or materially different state must be approved explicitly before implementation.

## Historical references preserved

The existing Daily Tarot references remain intact in `design/concepts/` and retain their recorded approval history. Their approvals apply only to the Daily Tarot states named in `design/APPROVALS.md`; they do not approve any Tarot Deck screen.

| Reference | Status after the product change | Reusable value |
|---|---|---|
| `design/concepts/daily-card-a-ceremonial-obsidian.png` | Approved historical `Daily Card`, revealed | Primary seed for color, material, card-back ornament, tactile lighting, and ceremonial restraint |
| `design/concepts/today-unrevealed-a-ceremonial-obsidian.png` | Approved historical `Today`, unrevealed | Useful proof that a face-down deck object can dominate a complete iPhone composition |
| `design/concepts/daily-card-b-dawn-journal.png` | Unapproved historical alternative | Preserve only; do not mix its paper/editorial language into the new baseline |
| `design/concepts/daily-card-c-celestial-threshold.png` | Unapproved historical alternative | Preserve only; do not mix its luminous portal language into the new baseline |

The old Daily Tarot images are references, not production assets. Their generated card art and frame treatment still require asset provenance and production preparation before use in an app.

## Recommended inherited visual language

Carry **Ceremonial Obsidian** forward as the sole baseline visual language. Do not reopen the already settled preference among A/B/C merely because the product has changed. The new product still benefits from the same quiet, tactile ritual, and this avoids spending another approval cycle on an abstract style choice.

Carry forward:

- midnight navy and matte-black surfaces;
- antique-gold line work with warm ivory type;
- restrained celestial geometry and paper texture;
- one physical card or deck stack as the dominant object;
- realistic iPhone safe areas and native control behavior;
- accessibility allowances already recorded for Dynamic Type, VoiceOver, contrast, tap targets, and Reduced Motion.

Do not carry forward:

- `Daily Card`, dates, daily-readiness language, or a once-per-day reveal;
- the `Today / Explore / Saved / Settings` tab bar;
- category labels, reflection messages, prompts, or the 36-day rotation;
- save/share controls attached to the central draw experience;
- notification or reminder concepts;
- a layout that treats one editorial message as the final product value.

## First new screen/state that needs approval

### S03.2 — Reading Table / Three Cards / shuffled / no card drawn

This must be the first complete new visual reference because it establishes whether the app genuinely feels like holding a usable deck rather than consuming a daily message.

The image should show:

- a complete modern iPhone composition, including safe areas, status bar, and home indicator;
- an uncluttered obsidian reading surface with enough negative space to become the later card-placement area;
- a coherent face-down deck stack using the Ceremonial Obsidian card-back language;
- one obvious primary action to begin the physical ritual;
- only the navigation and utility controls confirmed by the final MVP screen map;
- English copy only;
- no revealed identity, interpretation, reflection prompt, date, daily framing, horoscope language, or AI guidance.

Provisional working copy, to be reconciled with the product brief before image generation:

- Title: `Tarot Deck`
- Primary action: `Shuffle Deck`
- Helper: `Shuffle, then draw the cards for your reading.`

The image should communicate that the user directs the reading. The deck is a tool, not a feed and not an automated oracle.

### Why this state comes first

- It represents the product's new core promise before any secondary collection or settings screen.
- It sets the spatial rules for deck, hand, drawn cards, controls, and later spread states.
- It tests whether the inherited visual language works as an interactive table, not only as a decorative card display.
- Its approved card-back treatment can become a shared production asset for every unrevealed-card state.

## Resolved material dependency for S03.2

The canonical deck model must be settled first. The current repository contains 36 custom reflective cards, while users reasonably understand “a tarot deck” to mean the traditional 78-card structure. This decision changes the truth of the product, the size of the stack, card numbering and symbols, face artwork requirements, browsing, state coverage, and App Store positioning. It is therefore not a reversible visual detail.

**Approved 2026-08-09:** one complete **78-card tarot deck** (22 Major Arcana and 56 Minor Arcana), upright-only for the first release. Verified original public-domain Rider–Waite–Smith imagery may serve as the launch source; stable card IDs must support later replacement with original in-house art. Preserve the 36 Spanish reflective cards as conceptual history, but do not present them as the deck.

This dependency is closed. It authorized generation of the S03.2 proposal but did not approve that screen or any final UI.

## Image-generation plan after the dependency closes

Because Ceremonial Obsidian already provides the inherited language, the next visual task should create one complete, strongly recommended S03.2 candidate in that direction rather than reopening unrelated A/B/C styles. If the first candidate fails at interaction clarity, iterate its layout while keeping the approved language stable.

The generation reference must:

1. use `daily-card-a-ceremonial-obsidian.png` and `today-unrevealed-a-ceremonial-obsidian.png` only as historical style inputs;
2. show the full device and all app-owned controls needed in S03.2;
3. use the product-approved deck count and navigation model;
4. keep critical copy legible and English-only;
5. be saved under `design/tarot-deck/` with screen, state, and variant in the filename;
6. record dimensions and SHA-256 before presentation;
7. remain explicitly unapproved until the owner accepts that exact image.

Suggested output path after product confirmation:

`C:\Users\dmkra\Documents\Codex Apps\TarotCotidianoNative\design\tarot-deck\reading-table-three-cards-shuffled-a-ceremonial-obsidian.png`

## Subsequent visual states

These are sequencing notes, not an approved screen map. After S03.2 is approved, the product map should determine the exact inventory. The likely next references are:

1. deck shuffled and ready to draw;
2. one card drawn face down on the table;
3. a compact multi-card spread with all positions face down;
4. the same spread revealed;
5. single-card detail for artwork/title inspection;
6. reset confirmation only if the approved interaction can destroy a reading accidentally.

Each materially different state requires its own complete image and explicit approval. Native iOS sheets or alerts should not be imitated as custom artwork when the native component is appropriate.

## Visual acceptance checks for S03.2

- The screen reads as a usable tarot deck within three seconds without tutorial copy.
- The card stack is the dominant object, but the surrounding surface can later hold drawn cards.
- `Shuffle Deck` is unambiguous, reachable, and at least a native 44-point target.
- No Daily Tarot or Zodiac/Horoscope behavior leaks into the composition.
- The layout remains plausible in SwiftUI and does not depend on ornamental text baked into generated pixels.
- VoiceOver order, Dynamic Type growth, high contrast, and Reduced Motion can be supported without changing the product hierarchy.

## Visual decision ready for the owner

Approve or correct the exact S03.2 proposal at:

`C:\Users\dmkra\Documents\Codex Apps\TarotCotidianoNative\design\tarot-deck\reading-table-three-cards-shuffled-a-ceremonial-obsidian.png`

Dimensions: 863×1823. SHA-256: `2469CA34B3BEC37AD56E5D3E46891EE3CDE0252BEFB0212F24AE1B6002996F68`.

Recommendation: approve this composition as the visual target for S03.2. Until explicit approval, it remains a provisional prototype and does not authorize final UI implementation.

### Landscape companion requested by the owner

`C:\Users\dmkra\Documents\Codex Apps\TarotCotidianoNative\design\tarot-deck\reading-table-three-cards-shuffled-landscape-a-ceremonial-obsidian.png`

Dimensions: 1844×853. SHA-256: `5F4E1ED763806AC3CD436B0DE8D0B70AE5CD24A58E569BDCB4A170452692D553`.

The landscape candidate gives the deck its own left-hand control zone and reserves the wider right-hand table for three large card positions. Recommendation: approve portrait and landscape together as responsive presentations of the same S03.2 state. Neither image approves revealed-card artwork or another screen.

## Next approval — S03.3 first card drawn face down

Portrait:

`C:\Users\dmkra\Documents\Codex Apps\TarotCotidianoNative\design\tarot-deck\reading-table-three-cards-first-drawn-face-down-a-ceremonial-obsidian.png`

Landscape:

`C:\Users\dmkra\Documents\Codex Apps\TarotCotidianoNative\design\tarot-deck\reading-table-three-cards-first-drawn-face-down-landscape-a-ceremonial-obsidian.png`

Recommendation: approve both as V-007/V-008. They preserve the approved responsive table and change only the functional state: position one contains a face-down card, positions two and three remain empty, the remaining deck stays available, and the primary action becomes `Draw Next Card`. No face identity or interpretation is exposed.

## Next approval — S03.4 mixed reveal

Portrait V-009:

`C:\Users\dmkra\Documents\Codex Apps\TarotCotidianoNative\design\tarot-deck\reading-table-three-cards-mixed-the-moon-a-ceremonial-obsidian.png`

Landscape V-010:

`C:\Users\dmkra\Documents\Codex Apps\TarotCotidianoNative\design\tarot-deck\reading-table-three-cards-mixed-the-moon-landscape-a-ceremonial-obsidian.png`

These references introduce the smallest new interaction state needed to verify a real tarot face: position one is revealed as the exact historical `The Moon` candidate, position two remains face down, position three remains empty, and the next action is `Draw Final Card`. The artwork is a hash-verified candidate and remains non-production while distribution review is open.

Recommendation: approve V-009 and V-010 together. They preserve the approved portrait/landscape grammar, demonstrate that historical card art remains legible, and add no interpretation or automated reading.

## Next approval — S03.5 complete layout with mixed faces

Portrait V-011:

`C:\Users\dmkra\Documents\Codex Apps\TarotCotidianoNative\design\tarot-deck\reading-table-three-cards-complete-mixed-the-moon-a-ceremonial-obsidian.png`

Landscape V-012:

`C:\Users\dmkra\Documents\Codex Apps\TarotCotidianoNative\design\tarot-deck\reading-table-three-cards-complete-mixed-the-moon-landscape-a-ceremonial-obsidian.png`

This is the direct result of `Draw Final Card`: all three positions are occupied, `The Moon` remains revealed, positions two and three remain independently face down, and the deck plus draw action disappear. The only guidance is `Tap a face-down card to turn it over.` with `End Reading` kept secondary.

Recommendation: approve V-011 and V-012 together. They complete the physical draw loop without forcing reveal order or adding interpretation.

## Expanded MVP references under A-021

The owner expanded the product to include learning, meanings and a complete card library, then granted standing approval for the remaining MVP illustrations. V-013–V-027 now define the empty Read home, layout choice, ready-to-shuffle and all-revealed three-card states, meaning sheet, Learn index/article, Cards library, library detail, Settings and the not-active support surface. V-024 supersedes V-013 by adding the discreet Settings control. V-027 supersedes V-026 with copy aligned to `ios-app-launch`; it remains a visual reference only until real StoreKit products and localized prices are separately authorized. Exact paths, dimensions and hashes are recorded in `DECISIONS.md`; approval status is mirrored in `design/APPROVALS.md`.

V-028–V-036 complete the remaining Read references needed for the functional MVP: active-session home plus One Card in ready, shuffled, face-down and revealed states, each table state represented in portrait and landscape. The revealed example uses the locally verified historical `The Hermit` candidate and does not authorize distribution of that art.

V-037/V-038 supersede the first One Card face-down pair V-033/V-034. Once the single position is occupied, the remaining deck is removed in both orientations, matching S03.5 and keeping the drawn card as the sole primary object.

The generated system establishes three primary destinations — `Read`, `Learn`, `Cards` — without changing the Ceremonial Obsidian language. Meanings are educational and upright-only; the library has fixed filters and no search, favorites or remote content. New unrepresented states still require a complete image before implementation, but A-021 removes the need to pause for routine per-screen approval.
