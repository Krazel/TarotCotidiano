# Tarot Deck — Product Brief

Status: active expanded MVP baseline under A-020, A-021, A-022, A-027, A-028, A-030, A-031, and A-033
First release: iPhone only, English and Spanish
Date: 2026-08-11

## Product in one sentence

Tarot Deck puts a complete tarot deck and a calm learning reference on the iPhone, so people can make their own readings, understand the cards, and grow as readers without the app interpreting for them.

`Tarot Deck` is a working product name, not an approved launch identity.

## Target user

### Primary user

An English- or Spanish-speaking iPhone owner who reads tarot, is learning to read it, or occasionally reads with friends and wants both a usable deck and a concise reference when a physical deck or guidebook is not available.

They value:

- control over the question, positions, reveal order, and final interpretation;
- familiar deck actions: shuffle, draw without replacement, place, turn over, and clear;
- an explanation they can consult without surrendering the reading to an automated reader;
- a complete 78-card library they can browse at their own pace;
- a private, offline tool without engagement mechanics or an account.

### Core situations

1. **Do a reading:** choose one card, a named three-card spread, or an open three-card reading; then shuffle, draw, reveal, and interpret.
2. **Understand a revealed card:** tap it to inspect its art, canonical identity, and concise upright meaning, then return to the unchanged table.
3. **Learn the method:** read a short guide explaining how to prepare, notice imagery, combine cards, and form an interpretation.
4. **Study the deck:** browse all 78 cards, filter by arcana or suit, and move through them one by one.

### Not the primary MVP user

- Someone asking the app to predict an outcome, answer a question, or write a personalized reading.
- Someone seeking a daily horoscope, zodiac magazine, automatic card of the day, or reminder habit.
- Someone requiring reversals, advanced custom spreads, multiple decks, certification-style lessons, quizzes, or progress tracking.
- Someone seeking medical, psychological, legal, financial, or crisis advice.

## Problem and job to be done

A physical deck and guidebook are not always nearby or practical. Many tarot apps replace the deck with automatic readings, subscriptions, or engagement loops; basic reference apps can also separate learning from actual practice.

> “Give me a complete deck on my phone, teach me the essentials, and let me check a card when I need help—while leaving the reading to me.”

## Core promise

**A real tarot deck in your pocket, with the knowledge to read it yourself.**

The MVP proves that promise through:

- one complete, recognizable 78-card deck;
- a fair shuffle and draws without duplicates in a reading;
- a neutral one-card layout plus three named three-card spreads and an open option;
- user-controlled draw and turn-over actions;
- an optional upright meaning for every revealed card;
- one concise beginner guide and a complete card library;
- no generated interpretation, required question, account, or connection;
- local restoration of the active reading.

## Product principles

1. **The user is the reader.** The app supplies cards and knowledge, not a verdict or personalized answer.
2. **The deck remains the core.** Read is the primary destination; Learn and Cards support actual practice.
3. **Reference is optional and contextual.** Meaning is available on demand, never pushed over the table or revealed automatically.
4. **Physical actions stay legible.** Shuffle, draw, place, turn over, inspect, and clear are distinct actions.
5. **Complete means complete.** All 78 canonical identities, artwork records, and upright meanings ship together.
6. **Simple layouts, explicit intent.** A three-card reading can assign `Past · Present · Possible Future`, `Situation · Challenge · Advice`, or `You · The other person · Connection` before shuffling; an open option remains available.
7. **Private and local.** The app collects no question, notes, account, analytics profile, or cloud record.
8. **Bounded learning.** The guide teaches a usable method; it is not a course, feed, streak, or content program.
9. **Free means complete.** Read, Learn, all 78 Cards, and every meaning remain usable without payment, advertising, or a supporter entitlement.
10. **Support is voluntary.** Equivalent monthly support levels express appreciation through supporter status, a thank-you, and at most minor visual acknowledgement; they do not unlock substantial functionality.
11. **Visual-first.** A complete iPhone image is created and registered before each new final UI surface. Under A-021, in-scope images created by the project brain are approved on registration and do not require a separate pause.
12. **The deck is the control.** Home exposes one compact visual carousel of illustrated preset tiles before the deck is touched; it is never a dropdown or vertical text list. The deck then starts that preset directly; on the table it shuffles, draws, or offers another reading according to the current state. A duplicate large primary button must not compete with it.
13. **The viewport does not jump.** Persistent controls, the deck frame, reading positions, and visible tab bar keep stable geometry while labels and logical states change; motion happens inside those bounds.

## Three product loops

### Read

1. Open `Read`; choose `One Card` or one of the four three-card presets from the visual tile carousel above the deck.
2. Tap the prominent deck to open that reading directly, with no layout or spread-choice screen.
3. Tap the table deck to shuffle the complete deck.
4. Draw cards one at a time; each arrives face down and cannot repeat.
5. Turn cards over manually in any order.
6. Tap a revealed card when a meaning is helpful, then return to the exact table state.
7. Back ends the reading and returns Home without a confirmation. A small reset control restarts the same preset; once every drawn card is revealed, the deck also offers another reading with that preset.

The app never decides what the cards mean together. Reading completion is not rewarded, scored, or saved to history.

### Learn

1. Open `Learn`.
2. Choose one short article from the fixed beginner guide.
3. Read a practical method or concept.
4. Return to the index or move to `Read` or `Cards` to apply it.

There is no enrollment, progress state, quiz, lesson lock, reminder, or completion badge.

### Cards

1. Open `Cards` to see the complete deck in canonical order.
2. Show all cards or filter by `Major`, `Wands`, `Cups`, `Swords`, or `Pentacles`.
3. Tap a card to see its art and upright reference.
4. Move to the previous or next card inside the active filter to study the deck one by one.

Browsing never changes the active reading or the shuffled order.

## Compact navigation

The MVP has three primary iPhone destinations:

- **Read:** deck home with inline preset selection, and the active reading table.
- **Learn:** beginner guide index and articles.
- **Cards:** complete library and card detail.

A standard three-destination iOS navigation shell keeps them directly reachable. Its visible tab bar uses a stable opaque or strongly translucent Ceremonial Obsidian surface so labels and selected state remain legible and content never causes the bar to change height, opacity, or position. An active reading remains intact when the user visits Learn or Cards. Detail views return to their source context; a meaning opened from a reading returns to the same reading, while a card opened from the library returns to the same filter and position.

A discreet settings gear overlays the `Read` safe area without reserving layout height. Settings is not a fourth primary destination and never replaces or interrupts the deck flow. The empty Home is a compact, non-scrolling first viewport: concise identity, one horizontal carousel of illustrated preset tiles, one centered hero deck, its start cue, and the stable tab bar; it has no dropdown, long introductory block, separate setup screen, or duplicate primary button.

Exact visual presentation remains governed by the registered screen images.

## Small MVP

### Included

1. **Read**
   - Compact Deck Home with one inline selector for `One Card`, the three named `Three Cards` spreads, or the open three-card option; the centered deck starts the selected preset directly.
   - No `Layout Choice`, `Spread Choice`, active-reading replacement prompt, or visible `End Reading` action.
   - Tap the table deck to shuffle when unshuffled and to draw the next card when shuffled; after every drawn card is revealed, it offers another reading with the same preset.
   - One-at-a-time draw, independent reveal, immediate transactional Back, a small reset control, stable viewport, centered completed layouts, and professional motion governed by V-048.
   - Meaning available only after tapping a revealed card.

2. **Learn**
   - One static index with eight practical tutorials:
     1. `Prepare a Reading`
     2. `One Card Focus`
     3. `Past, Present, Possible Direction`
     4. `Situation, Challenge, Guidance`
     5. `You, Other Person, Connection`
     6. `A Yes-or-No Question, With Context`
     7. `Open Three Cards`
     8. `Read Symbols and the Whole Spread`
   - Every tutorial contains purpose, exact positions when applicable, steps, synthesis, and closing limits. Copy is original in English with a complete Spanish translation and briefly distinguishes documented tradition, widespread modern practice, and responsible editorial adaptation.
   - `Try This Reading` maps only to an existing Read preset. The contextual yes-or-no method uses `Open Three Cards`; it adds no sixth preset, universal card classification, automatic verdict, or repeated draw for a preferred answer.

3. **Cards**
   - All 78 cards in canonical order.
   - Filters for favorites, all cards, Major Arcana, and the four suits.
   - Large card detail with identity, `Upright meaning` / `Significado al derecho` as an editorial heading, upright keywords, concise meaning, practical reading note, favorite control, and previous/next browsing.

4. **Deck and content integrity**
   - Standard 22 Major Arcana plus 56 Minor Arcana.
   - Upright orientation only.
   - Canonical language-neutral IDs, localized English/Spanish names, bundled art, and original bundled reference copy in both languages.
   - Stable IDs allow historical launch art to be replaced later with original in-house art without changing readings or meanings.

5. **Local continuity and privacy**
   - The active reading, shuffled order, drawn cards, and face states survive app closure.
   - Ending a reading deletes the session; no history is created.
   - Learn and Cards content is bundled and requires no connection.
   - Favorite card IDs are stored only on the device and excluded from device backup. No question, interpretation, note, reading history, or learning progress is collected.

6. **Release foundations**
   - iPhone/iOS only and all app-owned copy in English and Spanish.
   - An internal `English / Español` selector in Settings changes the whole app immediately and persists the explicit choice. First installation follows Spanish iOS when applicable and otherwise uses English; English remains the complete fallback.
   - VoiceOver, Dynamic Type, sufficient contrast, Reduce Motion compatibility, and 44-point touch targets.
   - Core use works in airplane mode and requests no permission.

7. **Settings and planned voluntary support**
   - A discreet settings gear in `Read`; no fourth tab.
   - The first Settings control is the persistent internal `English / Español` selector; switching language never resets or mutates a reading.
   - Separate rows for `Support the App`, `Restore Purchases`, `Privacy`, `Terms`, and `Rate the App`.
   - Three provisional monthly levels—`Monthly Supporter`, `Kind Supporter`, and `Generous Supporter`—with equivalent product access and benefits. Exact product identifiers and prices are not defined here.
   - A clear supporter state and thank-you after a verified entitlement.
   - Before any purchase, the live App Store price and monthly duration, automatic-renewal behavior, how to manage or cancel, restoration, Privacy, and Terms must be visible.
   - Cancellation, failed purchase, unavailable products, or no restored purchase never limits Read, Learn, Cards, or meanings.
   - `Rate the App` is a separate user-initiated action, never a purchase benefit or condition.

### Why this remains small

The MVP has one central job—help the user read a physical-style deck—and two supporting reference surfaces. Learn contains eight fixed tutorials, Cards reuses one meaning model across 78 identities, and Settings keeps optional support and legal links outside the core flow. No account, user-generated content, progression, social behavior, or purchase is required.

## Explicit exclusions

- Automatic card of the day, daily reminder, streak, calendar, or notification.
- Zodiac signs, horoscope copy, daily magazine cards, or any Zodiac/Horoscope mode.
- App-generated interpretations, AI chat, predictions, personalized answers, or card-combination interpretations.
- Reflection messages, prompts, or the 12 thematic categories from the prior prototype.
- Reversed cards or randomized card orientation.
- Custom layouts, free placement, or spreads larger than three cards. The three approved named spreads and open three-card reading remain in scope.
- Search, reading history, journaling, notes, tags, reading statistics, or learning progress. The only saved-card behavior is the local favorites set defined by A-030.
- Quizzes, courses, certificates, gated lessons, glossary expansion, or an encyclopedia beyond the defined guide and 78 card entries.
- Sharing cards or readings.
- Multiple visual decks, alternate card backs, themes, imports, or downloadable content.
- Accounts, profiles, login, sync, cloud backup, or cross-device recovery.
- Required purchase, paywall, locked card, feature entitlement, advertising, or supporter-only content. The only planned commerce is the equivalent monthly voluntary support defined by A-022.
- One-time tips, consumables, paid deck packs, premium readings, or differing functional benefits between support levels.
- Network-fetched tarot or learning content, remote content management, analytics, or generative content. Future StoreKit support, restoration, legal links, and App Store rating may use Apple or system services without making core use network-dependent.
- Promotional support prompts in the first-use experience, during a reading, while revealing or inspecting a card, or during another critical task. The MVP keeps support discoverable in Settings instead of interrupting use.
- Onboarding carousel or mandatory tutorial.
- Android, iPad, web, Apple Watch, widgets, or languages other than English and Spanish.
- Publishing, App Store submission, or external services without separate authorization.

## Deck and content model

### Canonical deck

`native-ios/Content/tarot-deck.v1.json` is the current identity manifest. It contains exactly 78 unique stable IDs:

- 22 Major Arcana, ordered `major-00-the-fool` through `major-21-the-world`;
- 14 Wands, `minor-wands-ace` through `minor-wands-king`;
- 14 Cups, `minor-cups-ace` through `minor-cups-king`;
- 14 Swords, `minor-swords-ace` through `minor-swords-king`;
- 14 Pentacles, `minor-pentacles-ace` through `minor-pentacles-king`.

The first version may use verified scans of original public-domain Rider–Waite–Smith artwork. Modern commercial editions, recolorings, or restorations are not interchangeable with the historical source. The existing 36 Spanish reflective cards remain historical oracle-style material and are not mapped into this deck.

### Card identity fields

- `id`: stable, language-neutral key from the canonical manifest.
- `order`: canonical whole-deck order.
- `name`: localized English or Spanish display name resolved from the stable ID.
- `arcana`: `major` or `minor`.
- `majorNumber`: Major Arcana number when applicable.
- `suit`: `wands`, `cups`, `swords`, or `pentacles` for Minor Arcana.
- `rank`: `ace`, `two` through `ten`, `page`, `knight`, `queen`, or `king` for Minor Arcana.
- `artworkAsset`: bundled card-face asset.
- `accessibilityLabel`: concise localized identity.

### Upright reference fields

Every canonical card ID resolves to exactly one English and one Spanish reference record:

- `cardID`: exact foreign key to the identity manifest.
- `keywords`: three to five concise upright concepts.
- `meaning`: two or three original sentences explaining the card generally.
- `readingNote`: one original, non-prescriptive sentence suggesting what to notice in a reading.
- `artworkDescription`: concise factual description of the principal imagery for accessibility and study.

Reference copy describes possibilities, not certainties. It must not diagnose, predict, instruct high-stakes action, or imply that the app has interpreted the user's question.

### Learn article fields

- `id`: stable English-independent key.
- `order`: fixed guide order.
- `title`: localized English or Spanish article title.
- `summary`: one-sentence index description.
- `sections`: ordered headings and original body paragraphs.
- `relatedCardFilter`: optional link to one existing library filter; no remote link or generated recommendation.

### Reading session fields

- `layout`: `oneCard` or `threeCards`.
- `spread`: absent for one card; otherwise `pastPresentFuture`, `situationChallengeAdvice`, `relationship`, or `open`.
- `shuffledOrder`: a permutation of all 78 stable card IDs.
- `drawnCardIDs`: the first one or three IDs consumed from that order.
- `faceUpCardIDs`: the subset currently turned over.
- `phase`: setup, ready to shuffle, ready to draw, in progress, or complete.
- `lastPreset`: the most recent Home selection for the current app use; it changes no card identity and creates no reading until the deck is tapped.

The reading session, favorite card IDs, and explicit app-language choice are the only durable app-authored product state. `preferredLanguage` is either `en` or `es`, uses stable content IDs, and changes presentation without migrating or rewriting a session. A supporter entitlement is owned and verified through the App Store and may be cached locally for presentation; it is not an account, reading record, or access gate. Focused presentation, selected tab, Learn article, Cards filter, library position, and scroll offsets may reset without data loss.

### Voluntary support model

- `levelID`: provisional product mapping for `monthlySupporter`, `kindSupporter`, or `generousSupporter`; final App Store product IDs require separate authorization.
- `billingPeriod`: monthly auto-renewable for every level.
- `entitlement`: the same supporter recognition for every level; a higher level expresses greater voluntary support rather than buying more functionality.
- `status`: unavailable, not supporting, purchase pending, active supporter, restore pending, restore found, restore not found, or recoverable error.
- `displayPrice`: supplied by StoreKit after products and prices are separately configured; never hard-coded in product copy.

Read, Learn, Cards, all meanings, and future core fixes remain available whether the entitlement is absent, expired, cancelled, pending, unavailable, or failed. Creating products, choosing prices, accepting contracts, configuring tax/banking, uploading builds, or submitting purchases for review is outside the current authorization and does not block completion of the three core loops.

### Artwork rule

All 78 faces and the shared back must be coherent, legible at iPhone sizes, and have documented distribution rights. Production is not complete while any card uses an unverified, missing, or low-fidelity asset. Stable IDs and separate artwork references preserve the planned future replacement with original in-house art.

## Differentiation

1. **Deck first, learning beside it.** The product starts with an honest physical-deck metaphor and keeps reference one tap away.
2. **Knowledge without takeover.** It explains individual cards and a reading method but never generates the reading's conclusion.
3. **No engagement machinery.** There is no daily obligation, feed, streak, reminder, progression system, or artificial scarcity.
4. **Private by construction.** Questions and interpretations are not entered, uploaded, saved, or profiled.
5. **One coherent deck.** The first version earns trust through a complete 78-card system rather than a catalog of upsells.
6. **Practice and study agree.** The same stable identity and upright meaning power both a revealed reading card and the library detail.

## MVP success signals

- A first-time user can start a one-card or three-card reading without mandatory onboarding.
- On an empty Home, the deck is the unmistakable start control above the fold; the gear does not displace it and the initial surface does not scroll.
- The user understands the deck's unshuffled, shuffled, drawn, revealed, and complete states.
- Every draw is deliberate and no card repeats within a reading.
- Tapping the table deck performs exactly one phase-appropriate action—shuffle before readiness, draw afterward—and no duplicate primary control appears.
- Reading positions, the deck frame, and persistent chrome do not jump during press, cut, interleave, deal, reveal, restoration, or orientation changes; the three-card composition remains mathematically centered horizontally and retains one fixed vertical slot anchor throughout the reading.
- An interrupted reading resumes with the same order, cards, and face states.
- Tapping a revealed card opens the correct meaning and returning leaves the table unchanged.
- A learner can find and finish any of the eight tutorials without creating progress state, and can open a matching existing Read preset without creating a new mode.
- The library displays exactly 78 cards; filters resolve to 22 Major and four groups of 14.
- Previous and next move only within the active library filter and stop or wrap consistently as defined in the screen map.
- Every card detail uses the same localized name and reference content as reading context.
- Core use works in airplane mode and requests no permission.
- Settings is reachable from Read without creating a fourth tab, and dismissing it preserves the exact reading state.
- Switching `English / Español` in Settings updates all visible app-owned copy immediately, persists after relaunch, preserves stable IDs and reading state, and never leaves a mixed-language surface.
- Every planned support level communicates the same access and recognition; no purchase state changes core functionality.
- Support clearly discloses monthly auto-renewal and Apple-managed cancellation before purchase, while Restore Purchases, Privacy, Terms, and a separate Rate the App action remain findable.
- VoiceOver identifies tabs, reading positions and face states, library position, card identity, artwork description, headings, and actions.

## Definition of done

The expanded MVP is release-candidate ready when:

1. `Read`, `Learn`, and `Cards` are implemented from complete registered iPhone references in Ceremonial Obsidian.
2. One-card and three-card readings work, restore locally, never duplicate a card, and preserve identity secrecy while face down.
3. The eight practical tutorials are complete, original, available in English and Spanish, bundled, readable offline, mapped only to the five existing presets, and reviewed for non-prescriptive language and ethical limits.
4. The content manifest has exactly 78 identities and exactly 78 matching upright-reference records, with no missing or extra `cardID`.
5. All 78 rights-cleared faces and the shared back are bundled; provenance is documented and no provisional asset is treated as production-ready.
6. Meaning opened from a reading returns to the exact prior session; Cards browsing never mutates that session.
7. Functional, content-integrity, persistence, accessibility, orientation, and recovery tests pass on iPhone using macOS/Xcode.
8. Every visible string and all 78 card references are complete in English and Spanish; the internal selector changes the complete validated language bundle immediately, persists its explicit choice, and preserves all language-neutral IDs and reading state. Core flows work offline, and no account, analytics, notification, or personal-data collection exists.
9. Settings is accessible from the overlaid Read gear and contains language, support, restore, Privacy, Terms, and rating destinations without adding a fourth tab or interrupting a reading.
10. Planned support states prove that free access is unchanged before, during, after, or without a purchase; equivalent levels, thank-you, renewal/cancellation disclosure, and recoverable errors are represented without hard-coded prices.
11. Home selects the preset inline and uses the deck to start it directly. Reading Table uses the deck as the phase-appropriate CTA, provides only a small reset secondary action, ends transactionally through Back without confirmation, keeps viewport geometry stable, centers the completed three-card layout, and implements the professional V-048 press/cut/interleave/deal/flip sequence with an equivalent Reduce Motion path.
12. `Upright meaning` / `Significado al derecho` renders as a semantic heading, never as a button, capsule, toggle, or promise of reversed meanings.
13. Final implementation captures have been compared with the registered references at matching sizes.

Commit, push, TestFlight, App Store submission, and publication remain separate actions requiring explicit authorization.

StoreKit product creation, pricing, contracts, tax/banking configuration, live purchase testing, and in-app purchase review are also separate authorized work. They do not block defining or completing `Read`, `Learn`, and `Cards`.

## Preserved work

- The Expo prototype and its 36 Spanish reflective cards remain intact as historical and conceptual reference.
- Existing Daily Tarot images remain aesthetic exploration, not functional approval for this product.
- The SwiftUI restart, pure deck engine, local persistence, tests, and the already approved S03.2–S03.5 reading states remain valid foundations.
- The old exclusion of meanings and a card browser is superseded by A-020. A-030 adds local favorite card IDs. A-022 adds optional monthly support planning, but the exclusions of automated interpretation, Zodiac, accounts, remote tarot content, notes, history, and cloud user content remain in force.
