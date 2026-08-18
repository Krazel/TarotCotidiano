# Tarot Deck — MVP Screen and State Map

Status: active expanded functional baseline through A-059
First release: iPhone only, English and Spanish
Date: 2026-08-13

## Purpose and boundary

This map defines the smallest coherent deck-and-learning product. It covers function, localized English/Spanish copy intent, transitions, persistence, privacy, and accessibility. It does not itself approve a visual composition.

Every new screen or materially different visual state requires a complete iPhone reference before final UI implementation. Under A-021, an in-scope reference created by the project brain is approved when it is registered; implementation may then continue without returning to the owner for routine visual confirmation.

The app contains three compact primary destinations:

- `Read`: make and resume One Card, five Three Cards methods, Six-Card Guidance, and saved custom readings of 1–12 cards.
- `Learn`: read the fixed beginner guide.
- `Cards`: browse all 78 cards and their upright meanings.

The deck remains the product core. Learn and Cards provide knowledge; neither interprets a reading for the user.

## Functional hierarchy

```text
App launch
└── Restore local reading state
    └── Primary navigation
        ├── Read
        │   ├── Deck Home
        │   │   ├── Select One, Three, Six, or Custom; choose a Three Cards style inline
        │   │   ├── Info → matching Learn tutorial without selection
        │   │   └── Tap hero deck → selected Reading Table → automatic opening shuffle
        │   ├── Reading Table
        │       ├── Small Shuffle control → shuffle the undealt pool again
        │       ├── Tap deck → place next card in defined position order
        │       ├── Tap any empty position to place the next card
        │       ├── Reveal independently
        │       ├── Revealed card → Card Meaning → exact table state
        │       ├── Small reset → same preset → automatic opening shuffle
        │       ├── Info → tutorial ↔ previous / next → unchanged table
        │       └── Back → end reading and return Home
        │   └── Settings gear
        │       ├── English / Español
        │       ├── Support the App → seven equivalent monthly levels
        │       ├── Rate the App
        │       ├── Privacy
        │       └── Support
        ├── Learn
        │   ├── Foundations Index → Foundation Article
        │   └── Reading Tutorials → Tutorial Article → optional Try This Reading
        └── Cards
            └── Library → filter → Card Detail ↔ previous / next
```

## Navigation model

- A standard three-destination iOS tab shell uses localized visible labels: `Read / Learn / Cards` or `Leer / Aprender / Cartas`.
- At tab roots, the tab bar remains fixed, legible, and opaque or strongly translucent; content does not scroll behind an unstable transparent bar, and selected state does not change bar geometry.
- A discreet gear overlays the `Read` safe area without reserving vertical layout space and opens Settings. Settings is secondary navigation, not a fourth tab.
- `Read` is the initial destination after local restoration.
- Each destination owns its navigation stack. Switching destination does not end, reveal, draw, reshuffle, or otherwise mutate a reading.
- `Read` returns directly to its current Reading Table when the session is active; Back ends it transactionally and returns to Deck Home.
- A card opened from a reading returns to the exact table state and does not offer previous/next browsing.
- A card opened from Cards returns to the same library filter and scroll position; previous/next stays within that filter.
- A foundation article returns to the Learn index. A normal reading tutorial returns to the Tutorials index. A tutorial opened from an active table offers Previous/Next across all eight methods and `Back to Reading`, which returns to that exact table without changing the session. Learn has no stored progress or completion state.
- Opening or dismissing Settings, support, legal text, or the rating action never changes a reading.
- Changing `English / Español` updates the complete visible interface immediately, preserves navigation and reading state, and persists the explicit choice for relaunch.
- The exact tab, bar, sheet, and landscape treatment must follow the registered visual references.

## S00 — Launch and local restore

### Goal

Restore the active reading before presenting the three destinations.

| State | Content and behavior | Exit |
|---|---|---|
| `S00.1 Restoring` | Brief non-interactive native transition. No network, story splash, account, analytics, or permission request. | `S01.1` or the exact restored `S03` state in `Read`. |
| `S00.2 No saved session` | A complete deck is available and no reading exists. | `S01.1`. |
| `S00.3 Valid active session` | Restore preset, shuffled order, drawn IDs, and face states. | Exact matching `S03` state. |
| `S00.4 Invalid local session` | Discard only the unreadable session, restore a complete deck, and keep Learn/Cards available. | `S01.1`; brief localized recovery feedback may appear. |

Learn, card reference, and artwork are bundled, so there is no remote loading or offline-empty state.

## S01 — Read / Deck Home

### Goal

Choose the intended reading in place and reach the table with one deck tap.

### S01.1 — No active reading

Required information:

- localized title: **Tarot Deck** / **Mazo de tarot**;
- one compact selector above the deck showing the current preset;
- one large, centered face-down hero deck that is itself the primary control;
- visible cue: **Tap the deck to begin** / **Toca el mazo para empezar**;
- accessible action name: **Start a Reading** / **Empezar lectura**;
- a discreet, accessible Settings gear overlaid in the top safe area, visually secondary and excluded from content layout measurement;
- the fixed, legible three-destination tab bar.

Selector options:

- **One Card** / **Una carta**;
- **Past · Present · Future** / **Pasado · Presente · Futuro**;
- **Situation · Challenge · Advice** / **Situación · Reto · Consejo**;
- **You · The other person · Connection** / **Tú · La otra persona · Conexión**;
- **Yes or No** / **Sí o no** — `For / Against / Destiny` (`A favor / En contra / Destino`).
- **Freeform** / **Libre** — neutral `Card 1 / Card 2 / Card 3` (`Carta 1 / Carta 2 / Carta 3`) without assigned roles.

The Situation/Challenge/Advice tile and tutorial explain the question answered: what is happening now, what challenge must be faced, and what response the cards advise next. Spanish: `Qué está pasando, qué reto debes afrontar y qué te aconsejan las cartas después.`

The presets do not occupy Home permanently. Tapping the compact selector opens `S01.2`, where four illustrated choices appear in the stable order One Card, Three Cards, Six Cards, and Custom. Choosing Three Cards opens `S01.3`, where five illustrated tiles select timeline, situation/challenge/advice, relationship, yes/no, or Freeform. A clean installation highlights Three Cards/Past·Present·Possible Direction while leaving Three Cards second in the visual order. Selecting any built-in or custom choice locally persists it; that choice returns after relaunch whenever no active session exists. A restored active reading takes precedence. A separate information button opens the matching tutorial without selecting, persisting, or starting that preset.

Composition invariants from V-058/V-061: the first viewport does not scroll; title, small selector, dominant hero deck, cue, and tab bar fit without a long explanatory block; the gear is a true overlay and reserves no height; and no separate primary button duplicates the deck action. Opening or closing the chooser overlays Home and does not move the underlying deck.

Not present: card of the day, date, zodiac sign, generated interpretation, lesson promotion, account prompt, support promotion, notification prompt, or feed.

### S01.2 — Reading kind selector

An image-led panel presents exactly four direct choices in this order: `One Card`, `Three Cards`, `Six Cards`, and `Custom`. The current family receives the gold selected treatment; on first launch only, Three Cards is current by default. Choosing One Card or Six Cards commits that preset and closes the panel; choosing Three Cards opens `S01.3`; choosing Custom opens the local library. Each family has a separate information action whose visible circle is 22 points inside a 44×44-point target. Information never commits a selection. Close or outside dismissal preserves the prior preset. V-120 governs portrait: it preserves V-107's exact Six Cards 2×3 glyph while reducing only the visible information control.

### S01.3 — Three-card style selector

An image-led panel presents exactly five direct tiles in a compact 2×2 grid plus a full-width Freeform tile: timeline, situation/challenge/advice, relationship, yes/no, and Freeform. All five are visible at normal text sizes. If One Card was active when Three Cards was chosen, no style receives a selected mark until the user actually chooses one. Each tile has two non-nested actions: its body commits the prospective preset and closes the panel; its 22-point visible information circle inside a 44×44-point target closes the chooser and opens the matching tutorial without changing the preset. Back returns to `S01.2`; Close preserves the prior preset and returns Home. The panel may scroll only for accessibility text sizes, never as a plain vertical list. V-121 governs portrait.

### Retired setup and replacement states

The former active-reading Home, `Start a new reading?` confirmation, `Layout Choice`, and separate `Three-card spread choice` are superseded by A-033. V-014, V-028, and V-039 remain historical references only. No user-facing transition may route through them.

## S03 — Reading Table

### Goal

Represent `automatic opening shuffle → optional repeat shuffle → tap deck in order or tap a chosen position → turn over → inspect → read → reset or leave` without generating a conclusion.

### Shared elements

- Layout identity: `One Card`, a named `Three Cards` method, `Six-Card Guidance`, or a saved custom-spread snapshot.
- One neutral position; three stable positions labelled from the selected spread; the six documented guidance positions; or 1–12 ordered custom positions. The Yes or No spread uses `For`, `Against`, and `Destiny`; the third shows what Destiny holds for the question.
- The face-down deck remains visible in every table state, including a completed layout. It deals one card into the next empty authored position when tapped; after completion it remains a non-dealing visual anchor.
- A small dedicated `Shuffle / Barajar` control remains visible throughout the table. It shuffles the complete deck before placement and only the undealt remainder afterward. Placed identities, positions, authored order, and face states never change.
- Every empty position is also a direct deal target for the next card. There is no full-layout `Deal / Repartir` action.
- A persistent information action opens the active preset tutorial without mutating the reading.
- A small reset action with a 44-point accessible hit target, visually secondary to the deck.
- Revealed card name; meaning remains behind an intentional tap.
- No prediction, combined interpretation, question field, prompt, save, share, upsell, or progress reward.

### S03.1 — Automatic opening shuffle

- All positions are empty and keep their normal approved contrast; the table does not dim them or the deck during motion.
- A newly created or reset table immediately commits a valid shuffled order and presents the approved shuffle motion. A restored active session keeps its saved order and enters its exact stable state without another automatic shuffle.
- The small dedicated control is named **Shuffle Deck** / **Barajar mazo**. It remains visually available rather than being represented by disabled darkened content.
- During the brief opening transition, placement waits for the committed order. VoiceOver announces **Deck shuffled. Ready to deal.** / **Mazo barajado. Listo para repartir.** when the table becomes actionable.
- On a new or reset multi-card table in portrait, the normal instruction corridor temporarily shows **Rotate your phone for larger cards** / **Gira el teléfono para ver las cartas más grandes** for about three seconds, then returns to the current reading cue. It is never a toast, capsule, banner or overlay, has no dismissal, and never says `iPhone`. Restoring or revisiting the same reading does not show it again.

Transition: durable automatic shuffle → approved tracked-top press, cut, insertion, interleave, riffle, and square presentation → `S03.2`.

Motion and haptics cannot become a blocking ritual. Reduce Motion receives an equivalent state change without ornamental movement.

### S03.2 — Shuffled, positions ready

- The deck is face down and ready.
- Empty position count matches the chosen layout.
- The small `Shuffle / Barajar` control may shuffle all 78 cards again as often as desired while zero cards are dealt.
- Visible cue: **Tap the deck to deal in order, or choose a position** / **Toca el mazo para repartir en orden o elige una posición**.
- Tapping the deck atomically assigns the next card to the first empty position in the spread's authored order.
- Every empty position is also a button. Tapping it atomically assigns the same next card directly to that exact position.

Transition: tap the deck or an empty position → card and selected position persisted together → one-card placement presentation → partial or complete face-down table.

### S03.3 — Partial or complete layout face down

- The next unique card occupies the position the user tapped and remains face down.
- Tapping that card turns it over.
- Other positions may remain empty and actionable; their visual order does not force deal order.
- Previously drawn cards keep their independent face state.
- The deck remains visible and tappable to deal the next card into the next empty authored position. The dedicated Shuffle control randomizes only the undealt remainder.

Transitions:

- `Turn card over` → `S03.4` or `S03.6`, depending on completion.
- Revealing any face-down card preserves the other positions and their independent face state.
- `Back` → transactionally delete the session → `S01.1`.

### S03.4 — Reading in progress, mixed face states

- At least one card is revealed; another drawn card may remain face down; an empty position may remain.
- A revealed card shows its art and localized name at table scale.
- Tapping a revealed card opens `S04.1 Reading Card Meaning`.
- A separate accessible action can turn a revealed card face down again.
- Remaining positions can be filled without revealing existing cards.

### S03.5 — Layout complete, one or more cards face down

- No further deal destination remains once every position is occupied.
- The deck remains visible as a quiet visual anchor; tapping it cannot add a thirteenth card or replace a placed card. Shuffle may still animate and reorder the unused remainder without changing the visible layout.
- In portrait, three equal cards use equal gaps and a mathematically centered horizontal group. Their vertical slot anchor is identical before and after completion; helper copy, deck, Shuffle, and reset do not displace that group.
- Face-down cards remain under the user's control.
- Tapping a revealed card opens `S04.1`.
- Back and reset remain available.

### S03.6 — Layout complete, all cards face up

- The table is quiet and complete.
- Every card can open `S04.1` independently.
- The app adds no summary, combined meaning, celebration, or score.
- The deck remains present. The small reset action is the only control that clears placed cards and prepares another reading with the same preset; it immediately starts that new table's opening shuffle.
- Existing no-deck references V-086/V-087 and the corresponding One Card complete references are historical for deck visibility after A-059. New registered A-059 references must preserve the large-card scale while accommodating the persistent deck.

### Reading interaction rules

- No card is drawn or revealed automatically.
- No card ID appears twice in one session.
- A face-down card's identity never appears in visible copy, VoiceOver, logs intended for the user, resume status, or navigation state.
- Shuffle order remains stable after app restoration.
- `Shuffle / Barajar` can be used at any table point. Before placement it permutes all 78 IDs; after placement it permutes only the undealt IDs. It never changes a placed card's ID, position, authored order, or face state.
- Reset clears every placed card and creates the same preset with a new automatic opening shuffle; it never preserves prior drawn IDs.
- The deck remains a one-card deal control until every position is occupied, then remains visible without a valid deal destination. No full-layout `Deal / Repartir` control exists.
- Back clears the active reading without a confirmation. If durable clear fails, the user remains on the exact table state with recoverable error feedback.
- Tapping a face-down card reveals it; tapping a revealed card opens its meaning. Both actions have explicit VoiceOver alternatives.
- Leaving `Read` for Learn or Cards preserves logical state without replaying motion.

### Reading viewport and motion contract

- V-082/V-083 continue to inform density without their obsolete Deal control. V-097–V-102 and V-100 remain behavioral references for placement and physical shuffle, but any state that removes the deck or lacks the dedicated Shuffle control is superseded in that respect by A-059 and needs a new complete registered reference before final UI implementation.
- The outer viewport, position frames, persistent deck frame, and persistent actions stay fixed during shuffle, placement, and flip. Helper copy may crossfade in place; it must not insert or remove layout height. In landscape the title/header corridor is raised and compacted to maximize safe-area height for the cards without moving them between states.
- Shuffle follows `rest → press → cut with tracked old top → insert old top under packet → interleave → riffle with incoming top → square/new top`. After placement the same motion represents only the undealt pool. Tapping the deck or one empty slot presents one already committed card from the stable deck frame. Reveal uses a contained card flip without exposing identity before the logical reveal commits.
- The table never darkens its deck, slots, cards, title, or persistent controls during shuffle. Logical transitions remain serialized; a rapid extra shuffle request may be coalesced into one follow-up shuffle so animations never stack or corrupt order.
- One deal or reveal input produces one state transition. Shuffle requests are serialized; at most one follow-up shuffle is retained while the current shuffle presentation is in flight.
- Persistence commits the resulting logical state once; success haptics occur only after that durable commit. Backgrounding, restoration, tab switching, or rotation presents the stable result and never replays motion or haptics.
- Reduce Motion replaces shuffle, placement, and flip with short in-place opacity/state changes while preserving the same order, privacy, and controls. VoiceOver receives the same logical actions and post-commit announcements without requiring a gesture-only path.

## S04 — Card Meaning from Reading

### Goal

Explain a revealed card without pretending to interpret the reading or disturbing the table.

### S04.1 — Revealed card meaning

Required content:

- large bundled card art;
- localized English or Spanish name;
- arcana identity and suit/rank where applicable;
- semantic section heading **Meaning** / **Significado**;
- three to five keywords;
- concise general meaning;
- **In a reading** note that suggests what the user might notice without giving a personalized answer;
- one obvious `Back to Reading` or dismiss action.

Rules:

- only a face-up card can open this screen;
- `Meaning` / `Significado` is plain heading text. `In a reading` / `En una tirada` applies the meaning to the question and the role assigned to that card in the spread;
- no previous/next control, so the user cannot browse into cards absent from the reading;
- no question, generated interpretation, prediction, advice command, note, share, history, or related-card recommendation;
- one favorite control saves or removes this canonical card locally without changing the reading;
- dismissal returns to the exact card positions, face states, and deck order.

If a developer content record is missing, this is a build-integrity failure. Production must never show a blank, invented, or remotely fetched meaning.

## S05 — Learn and Reading Tutorials

### Goal

Give a beginner a short, non-linear path to understanding how to read cards.

### S05.1 — Guide available

Title: **Learn** / **Aprender**
Intro: **A simple way to read for yourself** / **Una forma sencilla de leer por tu cuenta**

The index restores a clear learning hierarchy under V-072:

1. featured **How to Read Tarot** / **Cómo leer el tarot**;
2. **Shuffle and Draw** / **Barajar y sacar**;
3. prominent portal **Reading Tutorials** / **Tutoriales de tiradas** → `S05.3`;
4. **Symbols and Patterns** / **Símbolos y patrones**;
5. **Build Your Interpretation** / **Construir tu interpretación**.

The portal is navigation, not a seventh article and not progress state. Foundation rows open `S06.1`; the portal opens `S05.3`.

Not present: progress bars, completed marks, bookmarks, lesson locks, quizzes, certificates, streaks, recommended feed, author profile, or remote update state.

### S05.2 — Content integrity failure

Missing, reordered, mismatched, or malformed bundled Learn content is a development/release failure, not a normal user-facing empty state. Production must ship with all foundation lessons and all eight tutorials in exact English/Spanish parity.

### S05.3 — Reading Tutorials Index

Title: **Reading Tutorials** / **Tutoriales de tiradas**

Eight equal tutorial rows appear in the current index: One Card; Past/Present/Possible Direction; Situation/Challenge/Guidance; You/Other Person/Connection; For/Against/Destiny; Freeform; Six-Card Guidance; and Create Your Own Spread. Tapping opens the matching `S06.1`. Back returns to the Learn Index. There is no recommendation, completion state, quiz, or remote content. V-073 remains historical for the original six-row composition; the eight-row index requires its registered extended reference.

## S06 — Learn Article

### Goal

Teach one practical concept in a short, readable format.

### S06.1 — Article

- Back action to `Learn`.
- Article title and summary.
- Exactly three ordered sections covering purpose or exact positions, how to draw or place the cards, and how to read the result.
- Clear heading structure for VoiceOver navigation.
- An optional `Try This Reading` CTA when the tutorial maps cleanly to one of the seven built-in Read choices; the custom-spread guide may instead open the custom editor.

Article behavior:

- reading position and completion are not stored;
- no interactive quiz, question field, notes, sharing, external link, comments, or next-lesson gate;
- user-facing copy stays on the practical method; source classification and editorial caveats remain in internal content documentation rather than appearing as repeated lesson disclaimers;
- the yes-or-no tutorial opens the persisted `open` preset and teaches three explicit blocks: Card 1 `For`, Card 2 `Against`, and Card 3 `Destiny`;
- the Freeform tutorial opens the distinct `freeform` preset and teaches neutral `Card 1 / Card 2 / Card 3` order without assigned roles;
- an existing reading is never silently replaced; the Read model preserves its current safe behavior when a tutorial CTA is used;
- Dynamic Type may reflow the article vertically without truncation.

Transition: `Back` → originating Learn index (`S05.1` for foundations or `S05.3` for methods). An information deep link from Read lands in `S05.3 → S06.1`; returning does not alter the current or preferred preset. `Try This Reading` is the only educational action that explicitly requests a preset.

## S07 — Cards Library

### Goal

Let the user inspect the complete deck and choose any card deliberately.

### S07.1 — All cards

- Title: **Cards**.
- Count: **78 Cards**.
- Active filter: **All**.
- Cards appear in canonical manifest order: 22 Major Arcana, then Wands, Cups, Swords, and Pentacles.
- Every item shows face art and the localized English or Spanish name.

Tap a card → `S08.1 Card Detail` at that library position.

### S07.2 — Filtered cards

Available filters:

- **Favorites** — zero to 78 locally saved cards, in canonical order.
- **All** — 78 cards.
- **Major** — 22 cards.
- **Wands** — 14 cards.
- **Cups** — 14 cards.
- **Swords** — 14 cards.
- **Pentacles** — 14 cards.

The filter row remains a native horizontal ScrollView and visibly teaches its own gesture without permanent instructional copy. At the start, the next capsule is partially visible and a short trailing fade/chevron indicates more content; in the middle both physical edges may indicate overflow; at the end only the opposite edge remains. The native horizontal indicator stays visible. VoiceOver labels the collection and announces `Swipe horizontally to explore all card categories / Desliza horizontalmente para ver todas las categorías`. V-122 governs the portrait library surface.

Changing filter resets the library to the beginning of the selected group. There is no search, sort menu, or custom grouping in the MVP.

### S07.3 — Favorites empty

- Active filter: **Favorites**.
- Title: **No favorites yet**.
- Supporting copy: **Open a card and tap the heart to save it here.**
- No CTA, account request, cloud prompt, or fabricated card appears.

### Library rules

- Browsing does not reveal, draw, remove, or reorder a card in the reading engine.
- Face-up art in Cards never exposes the identity of a face-down reading card because the library has no link to session positions.
- The active filter and scroll position need only survive the current navigation session; they are not durable user data.
- Favorite IDs survive app closure, remain independent of readings, and are displayed in canonical deck order.
- A missing card, duplicate ID, bad filter count, absent meaning, or absent art is a release-blocking manifest error.

## S08 — Card Detail from Library

### Goal

Study any of the 78 cards one by one with the same trustworthy reference used during a reading.

### S08.1 — Card detail

Required content:

- large bundled card art;
- localized English or Spanish name;
- arcana identity and suit/rank where applicable;
- **Meaning** / **Significado** as a semantic heading, never button-styled;
- the same keywords, meaning, reading note, and artwork description associated with this canonical `cardID`;
- position text such as **17 of 78** or **4 of 14**, based on the active filter;
- previous and next actions.
- a 44-point favorite button showing outlined when unsaved and filled antique gold when saved.

Navigation rules:

- `Previous` and `Next` follow canonical order inside the active filter.
- At the first card, `Previous` is unavailable; at the last, `Next` is unavailable. The list does not wrap.
- `Back to Cards` restores the same filter and library position.
- Opening or moving between details does not mutate the reading session.

Favoriting writes only the canonical `cardID`. It is available from library detail and from the meaning of a revealed reading card. Not present: reverse meaning, note, share, history, related cards, purchase, alternate deck, or generated explanation.

## Shared reference behavior

S04 and S08 use the same canonical identity and upright reference data, but they are different navigation contexts:

| Behavior | From reading (`S04`) | From library (`S08`) |
|---|---:|---:|
| Card must already be revealed | Yes | No |
| Previous / next | No | Yes, within active filter |
| Return destination | Exact table state | Same library filter and position |
| Mutates reading | Never | Never |
| Meaning source | Same bundled record | Same bundled record |

## S09 — Settings

### Goal

Keep the persistent app-language choice, public privacy/support destinations and rating available without competing with `Read / Learn / Cards`.

### S09.1 — Settings index

Entry: the discreet gear in `Read`.

Required rows:

- **App Language / Idioma de la app** — an internal two-option selector containing only `English` and `Español`.
- **Support the App / Apoya la app** — opens `S10`, shows verified supporter state and never gates a core feature.
- **Privacy / Privacidad** — opens the privacy document matching the active app language.
- **Support / Soporte** — opens the public support destination.
- **Rate the App** — performs a separate, direct user-initiated App Store rating action.

Rules:

- On first installation, Spanish iOS chooses `Español`; every other device language chooses `English`. An explicit selection then persists and takes priority on later launches.
- Selecting a language first loads and validates the complete bundled interface, card, and guide package, then changes all visible app-owned copy immediately and atomically. No mixed-language intermediate state is shown.
- Language switching preserves stable card IDs, favorites, selected spread, shuffled order, drawn cards, face states and navigation context. It never starts, ends, reshuffles, draws, reveals, or replaces a reading.
- English is the complete fallback if a localized key cannot be resolved; a partial production bundle is a release-blocking content-integrity failure rather than permission to mix copy silently.
- Settings is not a fourth tab and does not become the launch destination.
- The full deck, Learn, all 78 Cards, and all meanings remain available with no supporter entitlement.
- There is no advertisement, paywall, locked content, supporter feed, account, login, or purchase-based ranking.
- `Support the App` uses real StoreKit products and live localized prices. No unavailable placeholder, hard-coded price or external payment route is permitted.
- `Rate the App` is not inside Support, is not rewarded, and is never required after a purchase or restore.
- The MVP does not show an unsolicited support prompt. Any later low-frequency reminder would require `Not Now` and `Don't Ask Again`, and could never appear on first use, during a reading, while revealing or inspecting a card, or during another critical task.
- Dismissal returns to the exact prior `Read` state.

### S09.2 — Privacy or Support

- Clear title: **Privacy** or **Support**.
- A valid public destination matching the active app language and the exact released behavior.
- One obvious return action.
- No consent checkbox, account gate, marketing opt-in, or reading-state mutation.

The final legal destinations and wording are release inputs. Creating or accepting contracts is not authorized by this map.

### S09.3 — Rate the App

- Starts only after the user taps **Rate the App**.
- Uses the appropriate Apple-provided rating surface or persistent App Store review destination once an app listing exists.
- Shows no custom star gate, sentiment survey, reward, purchase prompt, or review requirement.
- Cancellation or system unavailability returns quietly to Settings and does not affect supporter or reading state.

## S10 — Support the App

### Goal

Let a user voluntarily support continued development while making it unmistakable that every core feature is free and each level has equivalent access.

### S10.1 — Not supporting / products available

Title: **Support the App**
Intro: **Tarot Deck is free for everyone. If you enjoy it, you can support its continued development.**

The screen presents exactly seven monthly levels from the single `Tarot Deck Support` subscription group. All seven grant the same supporter recognition. Their immutable product IDs are recorded in `store/tarot-subscriptions.v1.json`; visible prices and currencies always come from StoreKit.

Each level:

- is monthly and auto-renewable;
  - displays its live localized App Store price and monthly billing period from StoreKit;
- grants the same access, supporter status, thank-you, and at most minor visual acknowledgement;
- differs only in the amount the user voluntarily contributes;
- has a clear purchase action with no preselected level.

Before purchase, the screen must state automatic renewal, identify that subscription management and cancellation are handled through Apple, provide **Restore Purchases**, and make **Privacy** and **Terms** directly available. Final legal copy must match the live products and approved terms; it is not inferred from this map.

### S10.2 — Purchase pending

- The selected level and Apple-provided purchase state remain clear.
- Duplicate purchase actions are disabled while the system transaction is pending.
- Dismissing or cancelling returns to `S10.1` with the free app unchanged.
- No reading is ended and no entitlement is assumed before verification.

### S10.3 — Active supporter / thank-you

- Heading: **Thank You for Supporting Tarot Deck**.
- Show verified supporter status and the active monthly level.
- Provide a restrained supporter acknowledgement; do not unlock substantial features or hide free content.
- Provide **Manage Subscription**, **Restore Purchases**, **Privacy**, and **Terms**.
- Explain that renewal and cancellation are managed through Apple.

An expired or cancelled entitlement returns to the ordinary free state without removing content, readings, or reference access.

### S10.4 — Restore Purchases

| State | Behavior |
|---|---|
| `Restore pending` | Show a bounded progress state and prevent duplicate restore actions. |
| `Support restored` | Verify the entitlement, show the supporter thank-you, and preserve the reading. |
| `Nothing to restore` | State **No active support was found.** and keep the full free app available. |
| `Restore failed` | Give a concise retry option; never block Settings or any core destination. |

Restore is available from both Settings and Support. It does not require an account created by the app.

### S10.5 — Products unavailable or purchase failed

- Message intent: **Support isn't available right now. You can keep using the full app.**
- Retry may appear when appropriate.
- Read, Learn, Cards, all meanings, active readings, Privacy, Terms, and Rate the App remain usable.
- No fallback payment link, manual transfer, external checkout, or invented price appears.

The proprietor authorized creation and configuration of the seven production products under A-064. Accepting agreements, changing tax or banking, uploading a build, enabling external testing, and submitting the app or subscriptions for review remain separate actions.

## Persistence and privacy matrix

| Data or state | During use | After app close | After ending reading |
|---|---:|---:|---:|
| Chosen reading layout | Yes | Yes | Deleted |
| Current complete deck order, including the shuffled undealt pool | Yes | Yes | Deleted |
| Drawn card IDs and order | Yes | Yes | Deleted |
| Face-up / face-down states | Yes | Yes | Deleted |
| Focused meaning presentation | Yes | No | Deleted |
| Selected primary destination | Yes | No | Not applicable |
| Learn article / scroll | Yes | No | Not applicable |
| Cards filter / scroll / detail | Yes | No | Not applicable |
| Question or interpretation | Not collected | Not collected | Not collected |
| Reading history | No | No | No |
| Favorite card IDs | Yes | Yes, local JSON excluded from backup | Unchanged |
| Explicit app language (`en` or `es`) | Yes | Yes, local preference | Unchanged |
| Notes | No | No | No |
| Learning progress | No | No | No |
| Account or cloud record | No | No | No |
| Support purchase presentation | Yes | No | Not applicable |
| Supporter entitlement | StoreKit-verified when configured | Restored or refreshed through Apple; local cache may present last verified status | Unchanged |

Read, Learn, Cards, meanings, favorites, and local restoration make no network request. The local storage directory is marked as excluded from device backup. Configured StoreKit purchase/restore, legal destinations, subscription management, and App Store rating may require Apple or system connectivity. The app requests no contacts, photos, microphone, camera, location, notification, tracking, or account permission.

## Canonical content coverage

The identity source is `native-ios/Content/tarot-deck.v1.json`. Verified baseline:

- 78 unique IDs total;
- 22 Major Arcana IDs from `major-00-the-fool` to `major-21-the-world`;
- 14 IDs each for Wands, Cups, Swords, and Pentacles;
- Minor ranks Ace, Two through Ten, Page, Knight, Queen, and King;
- English identity fields, complete Spanish display overlays, and `uprightOnly` orientation policy.

Both English and Spanish reference-content key sets must equal the identity-manifest key set exactly: 78 matched `cardID` values per language, no missing records, no extras, and no duplicates. The 36 legacy reflection cards are never inserted, renamed, filtered, or mixed into this library.

## Accessibility requirements

- Primary destinations expose clear `Read`, `Learn`, and `Cards` labels and selected state.
- Every actionable target is at least 44×44 points and has a non-gesture alternative.
- A face-down reading card announces its role and state without identity, for example **Challenge, face down. Double-tap to reveal.** Yes or No announces `For`, `Against`, or `Destiny` without exposing card identity.
- A revealed reading card announces position, identity, and available meaning action.
- Library items announce card name and position in the current filter.
- Card detail exposes title, the semantic `Meaning` / `Significado` heading, keywords, meaning, reading note, and artwork description in a logical order; the heading has no button trait.
- The Settings gear has the label **Settings** rather than relying on its symbol; each row exposes its purpose and the Support row announces verified supporter state without implying locked functionality.
- The language selector announces its group label, both options, and selected state; a switch announces completion in the newly active language without moving focus unexpectedly.
- Support level controls announce name, live price, monthly period, selected state, and equivalent-access explanation. Purchase and restore status changes are announced without trapping focus.
- Decorative texture and ornament are hidden from VoiceOver.
- Dynamic Type does not truncate critical copy; long guide and meaning content scrolls.
- Text and controls meet contrast requirements over Ceremonial Obsidian surfaces.
- Reduce Motion removes nonessential shuffle, draw, and reveal motion while preserving understandable state changes.
- Portrait and landscape retain reading order and operability; orientation changes never mutate session or library state.

## Recovery and error boundaries

| Condition | User-facing behavior |
|---|---|
| Corrupt or incompatible reading session | Restore an empty complete deck and show brief localized feedback; Learn/Cards remain available. |
| Local save fails after an action | Keep the in-memory table usable, explain that it may not resume, and retry on the next state change. |
| App backgrounds mid-motion | Persist the logical state once and restore a stable result without duplicating or replaying a draw. |
| Language bundle is missing or invalid | Keep the last complete language active, show concise localized feedback, and treat the incomplete bundle as release-blocking. Never publish a partially switched interface. |
| Missing identity, art, meaning, or guide content | Release-blocking content error. Internal diagnostic only; no shippable placeholder or network fallback. |
| Invalid filter count or duplicate reference key | Release-blocking validation failure. |
| StoreKit products not configured or unavailable | Show `S10.5`; keep the full free app and non-commerce Settings destinations usable. |
| Purchase cancelled, pending, or failed | Preserve free access and the reading; reflect only the verified Apple state and offer a safe retry when appropriate. |
| Restore finds nothing or fails | Show the matching `S10.4` result; never create an entitlement or block use. |
| Privacy, Support, or rating destination unavailable | Return safely to Settings; never substitute an unrelated link or claim success. |

There are no app-account, notification-permission, synchronization, remote tarot-content, or remote learning-content states. Commerce and system-link failures are contained inside Settings and cannot degrade the three core destinations.

## Critical acceptance journeys

### A. First one-card reading with meaning

`Launch` → `Read` → select `One Card` inline → tap hero deck → automatic opening shuffle → tap deck to place → reveal → tap revealed card → read upright meaning → `Back to Reading` → table Back

Result: the user receives deck utility and optional knowledge without an automatic interpretation; the table is unchanged after meaning dismissal.

### B. Three-card reading with independent reveals

`Read Home` → select `Situation · Challenge · Advice` inline → tap hero deck → automatic opening shuffle → tap deck or chosen empty positions three times → reveal Challenge → inspect its meaning → return → reveal Situation → leave Advice face down

Result: draw order and selected roles stay stable, meanings do not reveal other cards, and the app does not combine meanings or generate a conclusion.

### C. Learn the basic method

`Learn` → `Reading Tutorials` → `For, Against, and Destiny` → learn what to do with each of the three cards → `Try This Reading` → `Yes or No`

Result: the documented Yes or No preset is selected explicitly; information-only navigation would not change it. No verdict, progress, account, quiz, personal question, or interpretation is stored.

### D. Browse the deck one by one

`Cards` → `Cups` → `Ace of Cups` → `Next` repeatedly → `King of Cups` → `Back to Cards`

Result: exactly 14 Cups appear in canonical order; Next stops at the King and the Cups filter remains selected.

### E. Preserve reading while studying

`Three Cards active` → `Cards` → inspect `The Moon` → `Read`

Result: the exact shuffled order, drawn cards, face states, and positions remain unchanged.

### F. Resume after interruption

`Three Cards` → draw two → reveal one → inspect meaning → close app → reopen

Result: the same two cards and face states return; focused presentation is dismissed and the third position remains empty.

### G. Leave and restart without friction

`Reading Table` → Back → `Read Home` → choose another preset → tap hero deck

Result: Back durably clears only the active session and returns Home without confirmation. On a completed table the deck remains visible but cannot replace or add a card; reset creates another reading with the same preset and immediately performs its opening shuffle.

### H. Content and privacy integrity

Run manifest validation, exercise Read/Learn/Cards in airplane mode, then inspect visible and accessibility text across all destinations.

Result: 78 identities map one-to-one to complete English and Spanish upright references; foundations and eight tutorials exist in both languages with identical built-in mappings and a matching custom-spread guide; the three core destinations make no network request; favorites persist only as canonical IDs; and no opposite-orientation meaning, Zodiac content, app account, analytics, question capture, notes, or history appears.

### I. Inspect support without losing a reading

`Three Cards active` → Settings gear → `Support the App` → compare the seven monthly levels → `Back` → dismiss Settings

Result: all levels communicate equivalent access, no level is preselected, no purchase is required, and the exact reading returns unchanged.

### J. Supporter and restore states

`Settings` → `Restore Purchases` → verified active entitlement → thank-you → `Manage Subscription`

Result: supporter status is shown without unlocking a core feature; renewal and Apple-managed cancellation are disclosed. Nothing-found, cancellation, failure, or unavailable products leave the same complete free app usable.

### K. Rate separately

`Settings` → `Rate the App` → dismiss the Apple rating surface → `Settings`

Result: rating is user-initiated, independent from Support, unrewarded, and does not mutate the reading or supporter state.

### L. Switch language without losing the table

`Three Cards active in English` → Settings gear → `Español` → return to `Leer`

Result: Settings changes immediately to Spanish, the exact spread, order, drawn cards and face states remain unchanged, the visible interface contains no leftover English app copy, and relaunch keeps Spanish. Switching back to `English` has the symmetric result.

### M. Deck-led table motion without viewport jumps

`Read empty` → choose a three-card preset inline → tap hero deck → automatic opening shuffle → optionally tap the small Shuffle control again → tap the deck for authored order and/or empty positions for chosen placement → reveal cards independently → reset when another reading is wanted

Result: shuffle and placement remain distinct; each deal tap creates one durable card-to-position assignment; a later shuffle changes only the undealt pool; the deck remains visible; motion stays inside fixed bounds without dimming the table; all three cards are centered with equal gaps; backgrounding or Reduce Motion yields the same logical state without replay.

### N. Shuffle between placements without changing the table

`Three Cards` → automatic opening shuffle → tap the deck to fill the first authored position → reveal it → tap `Shuffle` → tap a different empty position → close app → reopen

Result: the first card keeps the same identity, position, and face-up state; only the undealt pool changes order; the selected empty position receives the new top undealt card; the deck remains visible; relaunch restores the exact result without another automatic shuffle.

### O. Temporary orientation guidance and larger landscape table

`Six Cards` in portrait → enter table → observe the temporary hint → wait → rotate to landscape

Result: the hint says `phone` or `teléfono`, never `iPhone`, disappears after about three seconds without user action, and leaves no empty gap. Landscape places the title higher in a compact header and gives more safe-area height to the six cards while retaining labels, deck, Shuffle, reset, information, and 44-point targets.

## Visual-first implementation inventory

Already registered reading references remain governed by `DECISIONS.md` and `design/APPROVALS.md`:

1. `S03.2 Three Cards / shuffled / no card drawn` — V-005/V-006, approved by A-017.
2. `S03.3 Three Cards / first card face down` — V-007/V-008, approved by A-018.
3. `S03.4 Three Cards / mixed reveal` — V-009/V-010, approved by A-019.
4. `S03.5 Three Cards / complete, mixed faces` — V-011/V-012, approved by A-021.

Additional registered references under A-021:

5. `S03.6 Three Cards / complete, all face up` — V-017/V-018.
6. `S03.1 Three Cards / ready to shuffle` — V-015/V-016, historical after A-059's automatic opening shuffle.
7. `S01.1 Read / Deck Home / compact selector closed` — V-058 portrait and V-061 landscape, which supersede V-054/V-055; English uses the same composition.
8. `S01.2 Read / Deck Home / one-or-three selector open` — V-074 portrait and V-075 landscape, replacing V-059/V-062.
9. `S01.3 Read / Deck Home / three-card style selector open` — V-076 portrait and V-077 landscape, replacing V-065/V-066.
10. `S04 Card Meaning from Reading` — V-019.
11. `S05 Learn Index` — V-072; replaces V-070 while restoring V-020's hierarchy.
12. `S05.3 Reading Tutorials Index` — V-073.
13. `S06 Learn Article` — V-071; replaces V-021.
14. `S07 Cards Library / All with discoverable horizontal filters` — V-122, replacing V-022.
15. `S08 Card Detail from Library / previous-next` — V-023.
16. `S09 Settings` — V-127 Spanish and V-128 English, replacing V-045 with release-ready language, rating, privacy and support rows.
17. `S10 Support the App / not active and active` — V-133/V-134 govern the seven-level support screen; V-027 remains historical.
18. `S01.2 Read / Deck Home / active Three Cards reading` — V-028, historical and superseded by direct table restoration under A-033.
19. `S03.1 One Card / ready to shuffle` — V-029 portrait and V-030 landscape, historical after A-059's automatic opening shuffle.
20. `S03.2 One Card / shuffled` — V-031 portrait and V-032 landscape.
21. `S03.3 One Card / drawn face down` — V-037 portrait and V-038 landscape, historical for deck visibility after A-059; card scale and centered placement remain useful references.
22. `S03.6 One Card / The Hermit revealed` — V-035 portrait and V-036 landscape.
23. `S02.2 Three-card spread choice / Spanish` — V-039, historical and superseded by V-049–V-051 under A-033.
24. `S03 Three Cards / Past · Present · Future / large landscape / Spanish` — V-040, which supersedes the previous landscape proportions for the three-card table.
25. `S03 Reading Table / tracked-top shuffle and manual placement storyboard V4` — V-100, which supersedes V-089 with explicit old-top burial, a new top layer, and tap-position placement inside a stable viewport.
26. `S08.2 Card Detail / favorite saved` — V-042.
27. `S07.3 Cards / Favorites empty` — V-043.
28. `S03.1 Three Cards / ready / deck tap`, portrait Spanish — V-046, which supersedes V-015 for portrait interaction; English uses the same composition.
29. `S03.5 Three Cards / complete / all face down / centered`, portrait Spanish — V-047; English uses the same composition.
30. `S03.6 Three Cards / all revealed / no deck / contextual info`, portrait Spanish — V-086, historical after A-059.
31. `S03.6 Three Cards / all revealed / no deck / contextual info`, landscape Spanish — V-087, historical after A-059.
32. `S03 active reading / contextual tutorial`, portrait Spanish — V-088.
33. `S03 Reading Table / repeatable physical shuffle motion V3` — V-089, historical and superseded by V-100.

Still requiring a complete reference before any future implementation: custom confirmation compositions if they depart from standard native iOS presentation. V-131–V-134 now cover Settings and the seven-level Support surface; StoreKit system purchase sheets, pending states and errors remain native Apple or standard alert presentation and do not need invented custom compositions.

A shared card-reference component may serve S04 and S08 only after both navigation contexts are represented and registered. Portrait and landscape require separate references whenever the composition changes materially. A-021 removes the need to pause for routine approval but does not remove image creation, registration, fidelity review, or accessibility adaptation.

## MVP completion gate

The expanded MVP core is complete when the journeys above for Read, Learn, and Cards pass on iPhone, all required visual references are registered before their corresponding final UI, Home/tutorial interaction conforms to V-080–V-102, Table interaction conforms to new A-059 portrait/landscape references, the 78 identity and 78 meaning key sets match exactly, the full internal `English / Español` switch is atomic and persistent, all artwork distribution rights are resolved, the foundation lessons and eight reading tutorials are bundled with exact bilingual parity, and macOS/Xcode verifies build, tests, orientation, VoiceOver, Dynamic Type, Reduce Motion, recovery, and offline behavior.

Settings is complete for the free 1.0 release when language switching is atomic and Support the App, Rate the App, Privacy and Support are functional, accessible and bilingual. S10 loads exactly seven live monthly products, verifies transactions, restores purchases and links Apple management, Privacy and Terms while leaving every feature free. Product review, agreements and tax/banking remain separate App Store Connect gates.

Publishing remains separately unauthorized.

## A-053 screen extension — Six cards and Custom Spreads

### S01.2 Reading kind selector

- Four visual tiles, no text-only menu: One Card, Three Cards, Six Cards, Custom.
- Every tile places information top-left and selection top-right. Three Cards still opens its style selector; Six Cards selects the built-in documented method; Custom opens the saved-spread library.
- The tile order is stable, but a clean installation marks Three Cards. Subsequent launches mark the saved selection; an active restored reading remains authoritative.
- The Six Cards tile must depict exactly six cards, never a generic three-card glyph or a seven-card fan.

### S01.4 Custom spread library

- Empty: explanation and Create New Spread.
- Populated: saved spreads with miniature layout, name, card count, open action, and overflow actions Edit, Duplicate, Delete.
- Maximum 50 saved spreads. Delete is confirmed. Duplicate receives a unique suggested name.

### S01.5 Custom spread editor

- Required name (1–40 graphemes), 1–12 slots, optional slot label (up to 32 graphemes), add/remove, drag, order controls, Undo, Arrange, Cancel, Save.
- Arrange is a visual grid chooser: Automatic, One per row, Two per row, Three per row, Four per row. Incomplete final rows are centered.
- Dragging is not the only control: VoiceOver offers move directions and move earlier/later. Save validates and commits once; failure preserves the draft.
- Draft restoration is local. Cancel with unsaved changes uses a native confirmation.

### S03.7 Six-Card Guidance table

- Same automatic opening shuffle, repeatable remaining-deck Shuffle, deck-tap ordered placement, direct per-position placement, reveal, Meaning, info, reset and Back contract as existing readings.
- Six cards are placed one at a time into user-chosen positions in a centered 2×3 layout. Positions: Self, Support, The issue, Deeper issue, Action, Possible outcome.
- After the sixth placement the deck remains visible but cannot deal into an occupied layout. Reset prepares the same six-card method and immediately performs its opening shuffle.

### S03.8 Custom reading table

- Uses the immutable snapshot captured when the reading starts: name, order, labels, and normalized portrait/landscape positions.
- The table scales all slots to fit; 7–12 cards prefer landscape but remain usable in portrait. Each slot tap commits exactly one card and its chosen position atomically.
- Editing or deleting the saved definition does not affect the active table. Info shows its position list and links to Create Your Own Spread; it never invents a method-specific tutorial.

### S05/S06 tutorial additions

- Six-Card Guidance: credited source, purpose, six positions, placement and reading sequence.
- Create Your Own Spread: how to define a focused role per slot, choose order, arrange the board, and test the saved spread.

## A-059 screen update — Automatic shuffle and persistent deck

### New-entry and restore contract

- Creating a built-in or custom Reading Table performs one automatic opening shuffle. Reset creates a fresh session for the same selection and performs the same automatic shuffle.
- Restoring a saved active table never performs an automatic shuffle. Its persisted order, placements, and face states are authoritative and appear directly in their stable state.
- The opening shuffle does not darken the table. Positions, deck, title, and controls retain their normal contrast even though deal input waits for the durable shuffle result.

### Persistent controls and placement

- A small `Shuffle / Barajar` control is present from opening shuffle through completed layout. Its accessible target is at least 44×44 points even if its visible symbol is compact.
- Before any placement, Shuffle permutes all 78 cards. After any placement, Shuffle permutes only the undealt pool. This is the sole meaning of “shuffle at any time”; placed cards never change identity, position, authored order, or face state.
- Tapping the visible deck places one card into the first empty position in the spread's canonical/authored order. For a custom spread, this means the stored slot order, not the slot's visual coordinates.
- Tapping a particular empty position places that same next card directly there. Both paths use one atomic card-plus-position commit and consume exactly one undealt card.
- The deck remains visible after every placement and after completion. Once no empty position exists, deck taps do nothing destructive and expose an accessible `Layout complete` state; only Reset clears the layout.

### Temporary orientation hint and landscape density

- New or reset multi-card portrait tables replace the normal cue with `Rotate your phone for larger cards` / `Gira el teléfono para ver las cartas más grandes` for about three seconds. It is non-blocking, disappears automatically in the same stable corridor, and is announced once without trapping VoiceOver focus. Restore, rotation and return from contextual Learn do not offer it again.
- The hint says `phone / teléfono`, never `iPhone`. One Card does not need the hint.
- Landscape raises and compacts the reading title/header inside the safe area. The released height enlarges the cards while preserving labels, 44-point controls, equal gaps, and the exact saved slot coordinates; the persistent deck occupies the physical right side.
- These are materially changed visual states. Complete A-059 portrait and landscape references must be created and registered before final UI implementation; earlier no-deck and ready-to-shuffle images stay preserved as historical references.
