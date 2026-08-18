# Tarot Deck — Product Brief

Status: active expanded MVP baseline through A-059
First release: iPhone only, English and Spanish
Date: 2026-08-13

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

1. **Do a reading:** choose One Card, one of five Three Cards styles, Six-Card Guidance, or a saved custom spread of 1–12 cards; then let the table shuffle, place, reveal, and interpret.
2. **Understand a revealed card:** tap it to inspect its art, canonical identity, and concise upright meaning, then return to the unchanged table.
3. **Learn the method:** read a short guide explaining how to prepare, notice imagery, combine cards, and form an interpretation.
4. **Study the deck:** browse all 78 cards, filter by arcana or suit, and move through them one by one.

### Not the primary MVP user

- Someone asking the app to predict an outcome, answer a question, or write a personalized reading.
- Someone seeking a daily horoscope, zodiac magazine, automatic card of the day, or reminder habit.
- Someone requiring reversals, custom spreads above 12 cards or with overlapping/resizable cards, multiple decks, certification-style lessons, quizzes, or progress tracking.
- Someone seeking medical, psychological, legal, financial, or crisis advice.

## Problem and job to be done

A physical deck and guidebook are not always nearby or practical. Many tarot apps replace the deck with automatic readings, subscriptions, or engagement loops; basic reference apps can also separate learning from actual practice.

> “Give me a complete deck on my phone, teach me the essentials, and let me check a card when I need help—while leaving the reading to me.”

## Core promise

**A real tarot deck in your pocket, with the knowledge to read it yourself.**

The MVP proves that promise through:

- one complete, recognizable 78-card deck;
- a fair shuffle and draws without duplicates in a reading;
- a one-card layout, five three-card styles, a documented six-card method, and locally saved custom spreads of 1–12 cards;
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
6. **Simple layouts, explicit intent.** A three-card reading either assigns `Past · Present · Possible Future`, `Situation · Challenge · Advice`, `You · The other person · Connection`, or `For · Against · Destiny`, or deliberately uses Freeform with neutral `Card 1 · Card 2 · Card 3` labels.
7. **Private and local.** The app collects no question, notes, account, analytics profile, or cloud record.
8. **Bounded learning.** The guide teaches a usable method; it is not a course, feed, streak, or content program.
9. **Free means complete.** Read, Learn, all 78 Cards, and every meaning remain usable without payment, advertising, or a supporter entitlement.
10. **Support is voluntary.** Equivalent monthly support levels express appreciation through supporter status, a thank-you, and at most minor visual acknowledgement; they do not unlock substantial functionality.
11. **Visual-first.** A complete iPhone image is created and registered before each new final UI surface. Under A-021, in-scope images created by the project brain are approved on registration and do not require a separate pause.
12. **The deck starts the ritual.** Home keeps the deck large and exposes only one small selector button before it is touched. That button opens a progressive visual chooser. Each choice has a separate information action that opens its tutorial without selecting or starting it. The chooser is never a dropdown, permanent carousel, or vertical text list. A newly created table shuffles automatically. After that, tapping the deck places the next card in the spread's defined order, while tapping a particular empty position places the next card there. A small dedicated `Shuffle / Barajar` control can shuffle the remaining undealt cards repeatedly without changing cards already placed.
13. **The viewport does not jump.** Persistent controls, the deck frame, reading positions, and visible tab bar keep stable geometry while labels and logical states change; motion happens inside those bounds.

## Three product loops

### Read

1. Open `Read`; keep the current selection or use the small visual selector to choose One Card, one of five Three Cards presets, Six-Card Guidance, or a saved custom spread.
2. Tap the prominent deck to open that reading directly, with no layout or spread-choice screen.
3. The new table immediately shuffles the complete deck and then becomes ready to deal. A restored active table keeps its existing order instead of silently shuffling again.
4. Tap the deck to place the next card into the next empty position in the spread's defined order, or tap a particular empty position to place the next card there. Use the small `Shuffle / Barajar` control whenever another shuffle is wanted.
5. Turn cards over manually in any order.
6. Tap a revealed card when a meaning is helpful, then return to the exact table state.
7. Back ends the reading and returns Home without a confirmation. A small reset control restarts the same preset and triggers its automatic opening shuffle. The deck remains visible throughout the table, including after every position is filled.

The app never decides what the cards mean together. Reading completion is not rewarded, scored, or saved to history.

### Learn

1. Open `Learn` to see the restored foundations index.
2. Choose a concise foundation article, or open `Reading Tutorials` for eight practical tutorials: seven built-in readings plus creating a custom spread.
3. Read one practical concept or method; a preset tutorial may offer `Try This Reading`.
4. Return to the same Learn context or move explicitly to `Read` or `Cards` to apply it.

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

A discreet settings gear overlays the `Read` safe area without reserving layout height. Settings is not a fourth primary destination and never replaces or interrupts the deck flow. The empty Home is a compact, non-scrolling first viewport: concise identity, one small preset selector, one dominant hero deck, its start cue, and the stable tab bar. The selector opens image-led panels only when requested; Home has no permanent carousel, dropdown, long introductory block, separate setup screen, or duplicate primary button.

Exact visual presentation remains governed by the registered screen images.

## Small MVP

### Included

1. **Read**
   - Compact Deck Home with one small selector. Its first visual level offers `One Card`, `Three Cards`, `Six Cards`, and `Custom`; the second level appears only for `Three Cards` and offers five visual styles: timeline, situation/challenge/advice, relationship, Yes or No, and Freeform. On a clean installation, `Three Cards · Past / Present / Possible Direction` is selected even though Three Cards remains the second visual option. After any explicit choice, that saved choice remains authoritative. The dominant deck starts the selected preset directly.
   - Every concrete choice exposes a separate information button. Information navigates to the matching tutorial and never changes the saved selection or starts a reading.
   - No `Layout Choice`, `Spread Choice`, active-reading replacement prompt, or visible `End Reading` action.
   - A new or reset table shuffles automatically. A small, always-visible `Shuffle / Barajar` control can repeat the action at any point. Before placement it shuffles all 78 cards; after placement it shuffles only the undealt remainder, so every placed card keeps its identity, position, and face state.
   - The deck always remains visible and deals exactly one card per tap into the next empty position in defined spread order. Every empty position is also a direct control that atomically receives the next card when tapped. A completed table keeps the deck as a visual anchor but has no further deal destination.
   - Atomic placement, independent reveal, immediate transactional Back, a small reset control, stable viewport, centered layouts, and professional repeated-shuffle motion with visible top-card replacement. Controls do not dim while shuffle motion runs; repeated input is serialized without stacking conflicting transitions.
   - A brief non-blocking orientation hint replaces the normal instruction text when a new or reset multi-card table first appears in portrait, then disappears automatically: `Rotate your phone for larger cards` / `Gira el teléfono para ver las cartas más grandes`. It is not an overlay, toast or capsule, and it does not return until another reading is created or reset.
   - A persistent information action opens the active preset's tutorial. Previous/Next moves among all eight tutorials; `Back to Reading / Volver a la tirada` returns to the exact unchanged table.
   - Meaning available only after tapping a revealed card.

2. **Learn**
   - A foundations index that restores the prior hierarchy: one featured `How to Read Tarot` entry, concise `Shuffle and Draw`, `Symbols and Patterns`, and `Build Your Interpretation` lessons, plus one prominent `Reading Tutorials` portal.
   - `Reading Tutorials` contains exactly eight practical tutorials: One Card, Past/Present/Possible Direction, Situation/Challenge/Guidance, You/Other Person/Connection, For/Against/Destiny, Freeform, Six-Card Guidance, and Create Your Own Spread.
   - The Situation/Challenge/Guidance summary states its purpose rather than merely repeating the labels: understand what is happening, identify the challenge to face, and consider what the cards advise next.
   - The Yes or No tutorial dedicates one concise section to each position: Card 1 explains what supports yes, Card 2 explains what supports no, and Card 3 explains what Destiny holds for the question.
   - Every article contains exactly three concise practical parts. Methodological sourcing stays in internal documentation instead of interrupting the lesson.
   - `Try This Reading` maps only to its existing Read preset. The persisted raw value `open` remains Yes or No for migration; Freeform adds the distinct raw value `freeform` and neutral card-order labels.

3. **Cards**
   - All 78 cards in canonical order.
   - Filters for favorites, all cards, Major Arcana, and the four suits.
   - Large card detail with identity, `Meaning` / `Significado`, upright keywords, concise meaning, a practical `In a reading` note, favorite control, and previous/next browsing.

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

7. **Release Settings and planned voluntary support**
   - A discreet settings gear in `Read`; no fourth tab.
   - The first Settings control is the persistent internal `English / Español` selector; switching language never resets or mutates a reading.
   - The public 1.0 Settings surface contains only functional rows: `Rate the App`, `Privacy`, and `Support`.
   - `Support the App`, `Restore Purchases`, subscription terms and supporter status are deferred until real StoreKit products, prices, legal copy and review approval exist. They must not appear as unavailable or simulated rows in 1.0.
   - Three provisional monthly levels—`Monthly Supporter`, `Kind Supporter`, and `Generous Supporter`—with equivalent product access and benefits. Exact product identifiers and prices are not defined here.
   - A clear supporter state and thank-you after a verified entitlement.
   - Before any purchase, the live App Store price and monthly duration, automatic-renewal behavior, how to manage or cancel, restoration, Privacy, and Terms must be visible.
   - Cancellation, failed purchase, unavailable products, or no restored purchase never limits Read, Learn, Cards, or meanings.
   - `Rate the App` is a separate user-initiated action, never a purchase benefit or condition.

### Why this remains small

The MVP has one central job—help the user read a physical-style deck—and two supporting reference surfaces. Learn contains a small fixed foundations index and eight fixed reading tutorials; Cards reuses one meaning model across 78 identities, and Settings keeps language, rating, privacy and support outside the core flow. Custom spread definitions are the only user-authored product content; there is no account, progression, social behavior, or required purchase.

## Explicit exclusions

- Automatic card of the day, daily reminder, streak, calendar, or notification.
- Zodiac signs, horoscope copy, daily magazine cards, or any Zodiac/Horoscope mode.
- App-generated interpretations, AI chat, predictions, personalized answers, or card-combination interpretations.
- Reflection messages, prompts, or the 12 thematic categories from the prior prototype.
- Reversed cards or randomized card orientation.
- Custom spreads above 12 cards, more than 50 saved spreads, per-card rotation or resizing, overlapping slots, free-text reading notes, cloud sync, export, or sharing. Custom spreads of 1–12 cards and the built-in six-card method remain in scope.
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

- `layout`: `oneCard`, `threeCards`, `sixCards`, or an immutable `custom` snapshot with 1–12 ordered positions.
- `spread`: absent for one card; otherwise `pastPresentFuture`, `situationChallengeAdvice`, `relationship`, `open` (Yes or No), `freeform`, `sixCardGuidance`, or the saved custom-spread ID plus snapshot.
- `shuffledOrder`: a permutation of all 78 stable card IDs.
- `drawnCards`: each consumed card ID paired atomically with its chosen position index; tapping the deck chooses the next empty index in spread order, while tapping an empty slot chooses that index directly.
- `faceUpCardIDs`: the subset currently turned over.
- `phase`: opening shuffle, ready to deal, in progress, or layout complete. Shuffle is a repeatable operation over the undealt pool, not a phase that invalidates placed cards.
- `lastPreset`: the most recent explicit Home selection, stored locally as a versioned preset ID and restored on relaunch. It changes no card identity and creates no reading until the deck is tapped. An active reading temporarily governs the table without overwriting this preference.

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

- A first-time user can start any built-in reading without mandatory onboarding, and can create a custom spread with 1–12 cards.
- On an empty Home, the deck is the unmistakable start control above the fold; the gear does not displace it and the initial surface does not scroll.
- The user understands the opening-shuffle, ready, placed, revealed, and complete states.
- Every draw is deliberate and no card repeats within a reading.
- A newly created table shuffles automatically. Each later deck tap places exactly one card in the next empty position, each empty-position tap places exactly one card there, and the separate small shuffle control never changes a placed card.
- Reading positions, the persistent deck frame, and persistent chrome do not jump during shuffle, placement, reveal, restoration, or orientation changes. In landscape the title/header moves higher and becomes more compact so the cards receive the greatest safe-area height; three-card geometry remains mathematically centered with one stable slot anchor.
- An interrupted reading resumes with the same order, cards, and face states.
- Tapping a revealed card opens the correct meaning and returning leaves the table unchanged.
- A learner can find the foundations and finish any of the eight reading tutorials without creating progress state; information links never change the preset, while an explicit CTA opens the matching mode or custom editor.
- The library displays exactly 78 cards; filters resolve to 22 Major and four groups of 14.
- Previous and next move only within the active library filter and stop or wrap consistently as defined in the screen map.
- Every card detail uses the same localized name and reference content as reading context.
- Core use works in airplane mode and requests no permission.
- Settings is reachable from Read without creating a fourth tab, and dismissing it preserves the exact reading state.
- Switching `English / Español` in Settings updates all visible app-owned copy immediately, persists after relaunch, preserves stable IDs and reading state, and never leaves a mixed-language surface.
- Every planned support level communicates the same access and recognition; no purchase state changes core functionality.
- If deferred S10 is implemented later, it must disclose monthly auto-renewal and Apple-managed cancellation before purchase and provide restoration and legal destinations; none of that commerce appears in 1.0.
- VoiceOver identifies tabs, reading positions and face states, library position, card identity, artwork description, headings, and actions.

## Definition of done

The expanded MVP is release-candidate ready when:

1. `Read`, `Learn`, and `Cards` are implemented from complete registered iPhone references in Ceremonial Obsidian.
2. One-card, five three-card methods, Six-Card Guidance, and custom readings of 1–12 cards work, restore locally, never duplicate a card, and preserve identity secrecy while face down.
3. The fixed foundation lessons and eight practical reading tutorials are complete, concise, original, available in English and Spanish, bundled, readable offline, and mapped exactly to the seven built-in reading choices plus the custom-spread guide.
4. The content manifest has exactly 78 identities and exactly 78 matching upright-reference records, with no missing or extra `cardID`.
5. All 78 rights-cleared faces and the shared back are bundled; provenance is documented and no provisional asset is treated as production-ready.
6. Meaning opened from a reading returns to the exact prior session; Cards browsing never mutates that session.
7. Functional, content-integrity, persistence, accessibility, orientation, and recovery tests pass on iPhone using macOS/Xcode.
8. Every visible string and all 78 card references are complete in English and Spanish; the internal selector changes the complete validated language bundle immediately, persists its explicit choice, and preserves all language-neutral IDs and reading state. Core flows work offline, and no account, analytics, notification, or personal-data collection exists.
9. Settings is accessible from the overlaid Read gear and contains language, Rate the App, Privacy, and Support destinations without adding a fourth tab or interrupting a reading; it contains no unavailable commerce row.
10. Planned support states prove that free access is unchanged before, during, after, or without a purchase; equivalent levels, thank-you, renewal/cancellation disclosure, and recoverable errors are represented without hard-coded prices.
11. Home selects the preset inline and uses the deck to start it directly. A newly created or reset Reading Table shuffles automatically; the persistent deck deals one card per tap in defined order, every empty position can receive the next card directly, and a small dedicated shuffle control can reshuffle only the undealt pool at any point. Placed cards never change silently. The table ends transactionally through Back, hides the tab bar while active, keeps viewport geometry stable, and implements the approved shuffle, position-placement, and flip sequences with an equivalent Reduce Motion path.
12. `Meaning` / `Significado` renders as a semantic heading. `In a reading` / `En una tirada` explains how that general meaning can be applied to the question and the card's assigned position.
13. Final implementation captures have been compared with the registered references at matching sizes.

Commit, push, TestFlight, App Store submission, and publication remain separate actions requiring explicit authorization.

StoreKit product creation, pricing, contracts, tax/banking configuration, live purchase testing, and in-app purchase review are also separate authorized work. They do not block defining or completing `Read`, `Learn`, and `Cards`.

## Preserved work

- The Expo prototype and its 36 Spanish reflective cards remain intact as historical and conceptual reference.
- Existing Daily Tarot images remain aesthetic exploration, not functional approval for this product.
- The SwiftUI restart, pure deck engine, local persistence, tests, and the already approved S03.2–S03.5 reading states remain valid foundations.
- The old exclusion of meanings and a card browser is superseded by A-020. A-030 adds local favorite card IDs. A-022 adds optional monthly support planning, but the exclusions of automated interpretation, Zodiac, accounts, remote tarot content, notes, history, and cloud user content remain in force.

## A-053 — Six cards and custom spreads

- The Read selector offers four destinations: One Card, Three Cards, Six Cards, and Custom Spreads.
- The visual order stays One/Three/Six/Custom. A clean installation starts with Three Cards selected; a saved selection or restored active reading always takes precedence afterward.
- `Six-Card Guidance / Orientación en seis cartas` is a documented six-position method credited in Learn to Katalin Jett Koda and Llewellyn (2015). Its positions are Self, Support, The issue, Deeper issue, Action, and Possible outcome. The 2×3 geometry is an app adaptation, not a historical claim.
- Custom Spreads are created and stored only on device. A spread has a required name and 1–12 ordered slots. Each slot may have a label and a normalized position; order of dealing is independent from visual placement.
- The editor supports add, remove, drag, accessible directional movement, label editing, order changes, undo, and automatic arrangements for one, two, three, or four cards per row. It does not support rotation, per-card resizing, overlap, free text, cloud sync, export, or sharing in this version.
- Saving is atomic. Editing or deleting a saved spread never mutates an active reading, which keeps an immutable snapshot. A missing or corrupt custom library never blocks built-in readings.
- The selector convention is global: the information action is top-left and the selection check is top-right. The information glyph stays visually secondary at 22 points while retaining a 44×44-point touch target.
- The Cards category row is explicitly discoverable as horizontal navigation: it preserves all seven capsule filters, exposes a partial next capsule plus a short edge fade/chevron wherever more filters remain, keeps the native horizontal indicator, and provides a localized VoiceOver swipe hint.
- Learn adds a concise Six-Card Guidance tutorial and a generic Create Your Own Spread tutorial. Custom labels are user content and are not translated.
- This scope is a significant feature increment after 0.5 and therefore targets `0.6 (1)`.

## A-054 — Manual placement and immersive table (historical interaction baseline)

- `Deal / Repartir` is removed. After a valid shuffle, tapping any empty slot places the next card from the shuffled order into that exact slot.
- The chosen slot is saved in the same atomic session record as the card. Existing sequential sessions migrate without losing order or reveal state.
- The original A-054 rule allowed reshuffling only before the first placement and removed the deck after the last slot. A-059 supersedes both behaviors while retaining atomic position assignment and the immersive table.
- Shuffle V4 visibly carries the old top card into the packets and leaves a different top layer after squaring; identical static copies may not fake the change.
- The main tab bar is hidden for every active Reading Table state. Contextual Learn shows it; returning to Read restores the exact table and hides it again.
- The same interaction applies to One Card, every Three Cards method, Six-Card Guidance, and Custom Spreads from 1–12 cards.
- This is a new behavior increment after 0.6 and targets `0.7 (1)`.

## A-059 — Automatic opening shuffle, persistent deck, and dual placement

- Entering a newly created Reading Table immediately performs one shuffle. Reset creates a new session for the same spread and performs the same opening shuffle. Restoring an existing session never auto-shuffles because its exact saved order is authoritative.
- A small dedicated `Shuffle / Barajar` control remains visible throughout the reading and may be used repeatedly. Before any placement it shuffles all 78 cards. After one or more cards are placed, it shuffles only the remaining undealt cards. This is the governing meaning of “shuffle at any time”: identities, positions, order among placed cards, and face states already on the table never change silently.
- The deck remains visible in every table state. Tapping it deals the next card into the next empty position according to the spread's authored order. Tapping a particular empty position deals that same next card there instead. After all positions are occupied, the deck stays as a visual anchor but cannot deal another card; Shuffle can still randomize the unused remainder without altering the completed layout.
- Shuffle motion never darkens the deck, slots, cards, header, or persistent controls to imply that the table is unavailable. Logical changes remain serialized, and a rapid extra shuffle request may be coalesced into one follow-up shuffle rather than stacking animations.
- On a new or reset multi-card table in portrait, replace the ordinary cue with `Rotate your phone for larger cards` / `Gira el teléfono para ver las cartas más grandes` for about three seconds, then restore the current reading cue in the same corridor. It is never an overlay, toast, capsule or permanent row, and it does not return on restore, rotation, or contextual Learn navigation. App copy uses `phone / teléfono`, never `iPhone`.
- In landscape, raise and compact the title/header corridor so card slots and dealt cards can use more of the safe-area height. The deck stays visible, and title changes must not move the table geometry.
- A-059 changes material table states and therefore requires new complete portrait and landscape references, registration, and runtime comparison before final UI implementation. Existing no-deck masters remain historical evidence rather than governing this behavior.
