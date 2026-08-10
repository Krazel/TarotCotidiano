# Tarot Deck — MVP Screen and State Map

Status: active expanded functional baseline under A-020, A-021, A-022, A-027, A-028, A-030, and A-031
First release: iPhone only, English and Spanish
Date: 2026-08-10

## Purpose and boundary

This map defines the smallest coherent deck-and-learning product. It covers function, localized English/Spanish copy intent, transitions, persistence, privacy, and accessibility. It does not itself approve a visual composition.

Every new screen or materially different visual state requires a complete iPhone reference before final UI implementation. Under A-021, an in-scope reference created by the project brain is approved when it is registered; implementation may then continue without returning to the owner for routine visual confirmation.

The app contains three compact primary destinations:

- `Read`: make and resume one-card or three-card readings.
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
        │   │   ├── Tap hero deck / Start a Reading → Layout Choice
        │   │   └── Resume Reading → Reading Table
        │   ├── Reading Table
        │       ├── Tap deck to shuffle
        │       ├── Tap deck to draw one at a time
        │       ├── Reveal independently
        │       ├── Revealed card → Card Meaning → exact table state
        │       └── End Reading confirmation
        │   └── Settings gear
        │       ├── English / Español
        │       ├── Support the App → monthly support states
        │       ├── Restore Purchases
        │       ├── Privacy / Terms
        │       └── Rate the App
        ├── Learn
        │   └── Guide Index → Guide Article
        └── Cards
            └── Library → filter → Card Detail ↔ previous / next
```

## Navigation model

- A standard three-destination iOS tab shell uses localized visible labels: `Read / Learn / Cards` or `Leer / Aprender / Cartas`.
- At tab roots, the tab bar remains fixed, legible, and opaque or strongly translucent; content does not scroll behind an unstable transparent bar, and selected state does not change bar geometry.
- A discreet gear overlays the `Read` safe area without reserving vertical layout space and opens Settings. Settings is secondary navigation, not a fourth tab.
- `Read` is the initial destination after local restoration.
- Each destination owns its navigation stack. Switching destination does not end, reveal, draw, reshuffle, or otherwise mutate a reading.
- `Read` returns to its current reading surface when the session is active; it returns to Deck Home after the user ends it.
- A card opened from a reading returns to the exact table state and does not offer previous/next browsing.
- A card opened from Cards returns to the same library filter and scroll position; previous/next stays within that filter.
- A Learn article returns to the Learn index. Learn has no stored progress or completion state.
- Opening or dismissing Settings, support, legal text, or the rating action never changes a reading.
- Changing `English / Español` updates the complete visible interface immediately, preserves navigation and reading state, and persists the explicit choice for relaunch.
- The exact tab, bar, sheet, and landscape treatment must follow the registered visual references.

## S00 — Launch and local restore

### Goal

Restore the active reading before presenting the three destinations.

| State | Content and behavior | Exit |
|---|---|---|
| `S00.1 Restoring` | Brief non-interactive native transition. No network, story splash, account, analytics, or permission request. | `S01.1` or `S01.2` in `Read`. |
| `S00.2 No saved session` | A complete deck is available and no reading exists. | `S01.1`. |
| `S00.3 Valid active session` | Restore layout, shuffled order, drawn IDs, and face states. | `S01.2`. |
| `S00.4 Invalid local session` | Discard only the unreadable session, restore a complete deck, and keep Learn/Cards available. | `S01.1`; brief localized recovery feedback may appear. |

Learn, card reference, and artwork are bundled, so there is no remote loading or offline-empty state.

## S01 — Read / Deck Home

### Goal

Make the deck understandable immediately and protect an active reading.

### S01.1 — No active reading

Required information:

- localized title: **Tarot Deck** / **Mazo de tarot**;
- one large, centered face-down hero deck that is itself the primary control;
- visible cue: **Tap the deck to begin** / **Toca el mazo para empezar**;
- accessible action name: **Start a Reading** / **Empezar lectura**;
- a discreet, accessible Settings gear overlaid in the top safe area, visually secondary and excluded from content layout measurement;
- the fixed, legible three-destination tab bar.

Transition: tap the hero deck → `S02.1 Layout Choice`.

Composition invariants from V-044: the first viewport does not scroll; the title, hero deck, cue, and tab bar fit without a long explanatory block; the deck remains centered in the usable content area; the gear must not push the title or deck downward; and no separate primary button duplicates the deck action.

Not present: card of the day, date, zodiac sign, generated interpretation, lesson promotion, account prompt, support promotion, notification prompt, or feed.

### S01.2 — Active reading available

- Primary action: **Resume Reading**.
- Secondary action: **New Reading**.
- Concise status names `One Card` or `Three Cards` and the number drawn without exposing a face-down identity.

Transitions:

- `Resume Reading` → exact matching `S03` state.
- `New Reading` → `S01.3`.
- `Learn` or `Cards` → chosen destination without changing the session.
- `Settings` gear → `S09.1` without changing the session.

### S01.3 — Replace active reading confirmation

- Title: **Start a new reading?**
- Message: **Your current reading will be cleared.**
- Destructive action: **Start New Reading**.
- Safe action: **Keep Current Reading**.

Confirming clears only the active session and opens `S02.1`. Cancelling preserves it exactly.

## S02 — Layout Choice

### Goal

Choose the card count and, for three cards, choose position roles before shuffling; leave the question and interpretation to the user.

### S02.1 — Choice

Options:

- **One Card** — one neutral position.
- **Three Cards** — continue to `S02.2 Spread Choice`.

Supporting copy: **Choose one card, a guided spread, or your own positions.**

Rules:

- no question input or storage;
- one-card selection creates a new unshuffled session;
- dismissal before selection changes nothing.

Transitions:

- `One Card` → `S03.1` with one position.
- `Three Cards` → `S02.2`.
- `Cancel` → `S01`.

### S02.2 — Three-card spread choice

Options:

- **Past · Present · Future** — origins, the present moment, and a possible direction; the third position is never framed as fixed prediction.
- **Situation · Challenge · Advice** — what is happening, what complicates it, and what may help.
- **You · The other person · Connection** — two perspectives and the relationship between them.
- **Open reading** — card one, card two, and card three with no assigned roles.

Choosing an option persists its stable spread ID and opens `S03.1`. Back returns to `S02.1`; no deck session exists until shuffle. Reference V-039 governs this surface.

## S03 — Reading Table

### Goal

Represent `shuffle → draw → turn over → inspect → read → end` without generating a conclusion.

### Shared elements

- Layout identity: `One Card` or `Three Cards`.
- One neutral position, or three stable positions labelled from the selected spread. The open spread uses neutral `Card 1`, `Card 2`, and `Card 3` labels.
- Face-down deck while cards remain, or a clear exhausted state. While present, the deck itself is the one phase-appropriate primary control.
- Localized state copy explains the available deck action without duplicating it as a button.
- Secondary `End Reading` action.
- Revealed card name; meaning remains behind an intentional tap.
- No prediction, combined interpretation, question field, prompt, save, share, upsell, or progress reward.

### S03.1 — Ready to shuffle

- All positions are empty.
- The deck is present as the primary control but cannot be drawn yet.
- Visible cue: **Tap the deck to shuffle** / **Toca el mazo para barajar**.
- Accessible action name: **Shuffle Deck** / **Barajar mazo**.
- There is no separate shuffle button.

Transition: tap the deck → V-048 press, cut, and interleave sequence → durable shuffled state → `S03.2`.

Motion and haptics cannot become a blocking ritual. Reduce Motion receives an equivalent state change without ornamental movement.

### S03.2 — Shuffled, no card drawn

- The deck is face down and ready.
- Empty position count matches the chosen layout.
- The same deck is now the draw control; its frame and surrounding viewport do not move when its action changes.
- Visible cue: **Tap the deck to draw** / **Toca el mazo para sacar**.
- Accessible action name: **Draw Card** / **Sacar carta**.
- There is no separate draw button.

Transition: tap or activate the deck → V-048 deal path → durable draw state → `S03.3`.

### S03.3 — Latest card face down

- The next unique card occupies the next position and remains face down.
- Tapping that card turns it over.
- If positions remain, tapping or activating the deck draws the next card; no **Draw Next Card** button appears.
- Previously drawn cards keep their independent face state.

Transitions:

- `Turn card over` → `S03.4` or `S03.6`, depending on completion.
- `Deck: Draw Next Card` → another `S03.3` until all positions are occupied.
- `End Reading` → `S03.7`.

### S03.4 — Reading in progress, mixed face states

- At least one card is revealed; another drawn card may remain face down; an empty position may remain.
- A revealed card shows its art and localized name at table scale.
- Tapping a revealed card opens `S04.1 Reading Card Meaning`.
- A separate accessible action can turn a revealed card face down again.
- Remaining positions can be filled without revealing existing cards.

### S03.5 — Layout complete, one or more cards face down

- No draw action remains.
- The deck no longer competes with the completed layout.
- In portrait, three equal cards use equal gaps and a mathematically centered horizontal group as specified by corrected V-046/V-047. Their vertical slot anchor is identical before and after the deck disappears; completion copy and `End Reading` do not displace that group.
- Face-down cards remain under the user's control.
- Tapping a revealed card opens `S04.1`.
- `End Reading` remains available.

### S03.6 — Layout complete, all cards face up

- The table is quiet and complete.
- Every card can open `S04.1` independently.
- The app adds no summary, combined meaning, celebration, score, or next-reading prompt.
- Clear action: **End Reading**.

### S03.7 — End reading confirmation

- Title: **End this reading?**
- Message: **The cards will return to the deck. This reading won't be saved.**
- Destructive action: **End Reading**.
- Safe action: **Keep Reading**.

Confirm → delete session → `S01.1`. Cancel → exact prior `S03` state.

### Reading interaction rules

- No card is drawn or revealed automatically.
- No card ID appears twice in one session.
- A face-down card's identity never appears in visible copy, VoiceOver, logs intended for the user, resume status, or navigation state.
- Shuffle order remains stable after app restoration.
- The user cannot reshuffle midway; a new reading begins from a complete deck.
- The deck accepts exactly one action for its phase: shuffle in `S03.1`, draw in `S03.2`–`S03.4` while a position remains, and no action once the layout is full. A second primary button never mirrors that action.
- Tapping a face-down card reveals it; tapping a revealed card opens its meaning. Both actions have explicit VoiceOver alternatives.
- Leaving `Read` for Learn or Cards preserves logical state without replaying motion.

### Reading viewport and motion contract

- Corrected V-046 governs the portrait ready state and labelled positions; corrected V-047 preserves the same horizontal group and vertical slot anchor in the complete face-down state. V-040 governs the large three-card landscape composition, and V-048 supersedes V-041 for principal motion.
- The outer viewport, header corridor, position frames, deck frame while present, and persistent actions stay fixed during press, cut, interleave, deal, and flip. Helper copy may crossfade in place; it must not insert or remove layout height.
- Shuffle follows the contained V-048 sequence `rest → press → cut → interleave → settled shuffled state`. Deal uses one clear path from the stable deck frame to the next stable position. Reveal uses a contained card flip without exposing identity before the logical reveal commits.
- One input produces one state transition. Additional taps are ignored while the current transition is in flight.
- Persistence commits the resulting logical state once; success haptics occur only after that durable commit. Backgrounding, restoration, tab switching, or rotation presents the stable result and never replays motion or haptics.
- Reduce Motion replaces cut, interleave, deal, and flip with short in-place opacity/state changes while preserving the same order, privacy, and controls. VoiceOver receives the same logical actions and post-commit announcements without requiring a gesture-only path.

## S04 — Card Meaning from Reading

### Goal

Explain a revealed card without pretending to interpret the reading or disturbing the table.

### S04.1 — Revealed card meaning

Required content:

- large bundled card art;
- localized English or Spanish name;
- arcana identity and suit/rank where applicable;
- semantic section heading **Upright meaning** / **Significado al derecho**;
- three to five keywords;
- concise general meaning;
- **In a reading** note that suggests what the user might notice without giving a personalized answer;
- one obvious `Back to Reading` or dismiss action.

Rules:

- only a face-up card can open this screen;
- `Upright meaning` / `Significado al derecho` is plain heading text, not a capsule, button, toggle, filter, or orientation control;
- no previous/next control, so the user cannot browse into cards absent from the reading;
- no question, generated interpretation, prediction, advice command, note, share, history, or related-card recommendation;
- one favorite control saves or removes this canonical card locally without changing the reading;
- dismissal returns to the exact card positions, face states, and deck order.

If a developer content record is missing, this is a build-integrity failure. Production must never show a blank, invented, or remotely fetched meaning.

## S05 — Learn Index

### Goal

Give a beginner a short, non-linear path to understanding how to read cards.

### S05.1 — Guide available

Title: **Learn to Read Tarot**
Intro: **A simple guide to reading the cards in your own way.**

Articles appear in this fixed order:

1. **Start with a Question** — frame an open, useful question without entering it in the app.
2. **Shuffle and Draw** — prepare, shuffle, draw, and stay attentive without claims about supernatural certainty.
3. **Read One Card** — connect imagery, keywords, context, and personal observation.
4. **Read Three Cards** — choose one of three named position patterns or an open reading, then read each card and the relationship among all three.
5. **Notice Symbols and Patterns** — notice suit, number, figures, direction, repetition, contrast, and mood.
6. **Build Your Interpretation** — combine observations into a grounded reading and keep ethical limits.

Each row has title, one-sentence summary, and a clear disclosure indicator. Tapping opens `S06.1`.

Not present: progress bars, completed marks, bookmarks, lesson locks, quizzes, certificates, streaks, recommended feed, author profile, or remote update state.

### S05.2 — Content integrity failure

Missing or malformed bundled guide content is a development/release failure, not a normal user-facing empty state. Internal builds may show a clearly labelled diagnostic; production must ship with all six articles.

## S06 — Learn Article

### Goal

Teach one practical concept in a short, readable format.

### S06.1 — Article

- Back action to `Learn`.
- Article title and summary.
- Ordered sections with short paragraphs and optional simple examples.
- Clear heading structure for VoiceOver navigation.
- An optional final link to one existing Cards filter when the article genuinely benefits from deck examples.

Article behavior:

- reading position and completion are not stored;
- no interactive quiz, question field, notes, sharing, external link, comments, or next-lesson gate;
- the copy teaches a method and possibilities, never a guaranteed divination claim or high-stakes instruction;
- Dynamic Type may reflow the article vertically without truncation.

Transition: `Back` → same Learn index. Choosing the optional Cards link opens `S07.1` with its declared filter and does not affect a reading.

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
- **Upright meaning** / **Significado al derecho** as a semantic heading, never button-styled;
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

Keep the persistent app-language choice, voluntary support, purchase recovery, legal information, and rating available without competing with `Read / Learn / Cards`.

### S09.1 — Settings index

Entry: the discreet gear in `Read`.

Required rows:

- **App Language / Idioma de la app** — an internal two-option selector containing only `English` and `Español`.
- **Support the App** — opens `S10`; when active, the row shows a concise supporter state and thank-you without advertising a functional advantage.
- **Restore Purchases** — starts the same restore flow defined in `S10.4` without requiring the user to begin a new purchase.
- **Privacy / Privacidad** — opens the privacy document matching the active app language.
- **Terms / Términos** — opens the terms document matching the active app language.
- **Rate the App** — performs a separate, direct user-initiated App Store rating action.

Rules:

- On first installation, Spanish iOS chooses `Español`; every other device language chooses `English`. An explicit selection then persists and takes priority on later launches.
- Selecting a language first loads and validates the complete bundled interface, card, and guide package, then changes all visible app-owned copy immediately and atomically. No mixed-language intermediate state is shown.
- Language switching preserves stable card IDs, favorites, selected spread, shuffled order, drawn cards, face states, navigation context, and supporter state. It never starts, ends, reshuffles, draws, reveals, or replaces a reading.
- English is the complete fallback if a localized key cannot be resolved; a partial production bundle is a release-blocking content-integrity failure rather than permission to mix copy silently.
- Settings is not a fourth tab and does not become the launch destination.
- The full deck, Learn, all 78 Cards, and all meanings remain available with no supporter entitlement.
- There is no advertisement, paywall, locked content, supporter feed, account, login, or purchase-based ranking.
- `Rate the App` is not inside Support, is not rewarded, and is never required after a purchase or restore.
- The MVP does not show an unsolicited support prompt. Any later low-frequency reminder would require `Not Now` and `Don't Ask Again`, and could never appear on first use, during a reading, while revealing or inspecting a card, or during another critical task.
- Dismissal returns to the exact prior `Read` state.

### S09.2 — Privacy or Terms

- Clear title: **Privacy** or **Terms**.
- A document or valid system destination matching the active app language. Final English and Spanish legal wording and destinations are release inputs.
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

Planned monthly levels:

- **Monthly Supporter**
- **Kind Supporter**
- **Generous Supporter**

Each level:

- is monthly and auto-renewable;
- displays its live localized App Store price and billing period from StoreKit after separate product configuration;
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

Creating product identifiers, choosing prices, accepting paid-app agreements, configuring tax or banking, uploading a build, testing live commerce, and submitting products for review are separate unauthorized actions. Their absence does not block implementation or verification of `Read`, `Learn`, and `Cards`.

## Persistence and privacy matrix

| Data or state | During use | After app close | After ending reading |
|---|---:|---:|---:|
| Chosen reading layout | Yes | Yes | Deleted |
| Complete shuffled order | Yes | Yes | Deleted |
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
- A face-down reading card announces its role and state without identity, for example **Challenge, face down. Double-tap to reveal.** Open readings announce the neutral card number.
- A revealed reading card announces position, identity, and available meaning action.
- Library items announce card name and position in the current filter.
- Card detail exposes title, the semantic `Upright meaning` / `Significado al derecho` heading, keywords, meaning, reading note, and artwork description in a logical order; the heading has no button trait.
- The Settings gear has the label **Settings** rather than relying on its symbol; each Settings row exposes its purpose and current supporter state where applicable.
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
| Privacy, Terms, subscription management, or rating destination unavailable | Return safely to Settings with concise feedback; never substitute an unrelated link. |

There are no app-account, notification-permission, synchronization, remote tarot-content, or remote learning-content states. Commerce and system-link failures are contained inside Settings and cannot degrade the three core destinations.

## Critical acceptance journeys

### A. First one-card reading with meaning

`Launch` → `Read` → tap hero deck → `One Card` → tap deck to shuffle → tap deck to draw → reveal → tap revealed card → read upright meaning → `Back to Reading` → `End Reading`

Result: the user receives deck utility and optional knowledge without an automatic interpretation; the table is unchanged after meaning dismissal.

### B. Three-card reading with independent reveals

`New Reading` → `Three Cards` → `Situation · Challenge · Advice` → shuffle → draw three → reveal Challenge → inspect its meaning → return → reveal Situation → leave Advice face down

Result: draw order and selected roles stay stable, meanings do not reveal other cards, and the app does not combine meanings or generate a conclusion.

### C. Learn the basic method

`Learn` → `Read Three Cards` → read article → `Back` → `Notice Symbols and Patterns`

Result: both articles are available offline and no progress, account, quiz, or personal question is stored.

### D. Browse the deck one by one

`Cards` → `Cups` → `Ace of Cups` → `Next` repeatedly → `King of Cups` → `Back to Cards`

Result: exactly 14 Cups appear in canonical order; Next stops at the King and the Cups filter remains selected.

### E. Preserve reading while studying

`Three Cards active` → `Cards` → inspect `The Moon` → `Read`

Result: the exact shuffled order, drawn cards, face states, and positions remain unchanged.

### F. Resume after interruption

`Three Cards` → draw two → reveal one → inspect meaning → close app → reopen → `Resume Reading`

Result: the same two cards and face states return; focused presentation is dismissed and the third position remains empty.

### G. Protect an active reading

`Resume available` → `New Reading` → `Keep Current Reading`

Result: nothing changes. Confirming instead deletes only that session and opens layout choice with a complete deck.

### H. Content and privacy integrity

Run manifest validation, exercise Read/Learn/Cards in airplane mode, then inspect visible and accessibility text across all destinations.

Result: 78 identities map one-to-one to complete English and Spanish upright references; six guide articles exist in both languages; the three core destinations make no network request; favorites persist only as canonical IDs; and no reverse meaning, Zodiac content, app account, analytics, question capture, notes, or history appears. Settings connectivity is limited to separately configured Apple commerce, legal, subscription-management, and rating destinations.

### I. Inspect support without losing a reading

`Three Cards active` → Settings gear → `Support the App` → compare the three monthly levels → `Back` → dismiss Settings

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

`Read empty` → tap hero deck → choose `Three Cards` → tap table deck to shuffle → tap it three times to deal → tap each card to reveal

Result: no duplicate primary shuffle/draw button appears; one tap causes one durable action; the V-048 sequence stays inside fixed bounds; all three completed cards are centered with equal gaps; backgrounding or Reduce Motion yields the same logical state without replay.

## Visual-first implementation inventory

Already registered reading references remain governed by `DECISIONS.md` and `design/APPROVALS.md`:

1. `S03.2 Three Cards / shuffled / no card drawn` — V-005/V-006, approved by A-017.
2. `S03.3 Three Cards / first card face down` — V-007/V-008, approved by A-018.
3. `S03.4 Three Cards / mixed reveal` — V-009/V-010, approved by A-019.
4. `S03.5 Three Cards / complete, mixed faces` — V-011/V-012, approved by A-021.

Additional registered references under A-021:

5. `S03.6 Three Cards / complete, all face up` — V-017/V-018.
6. `S03.1 Three Cards / ready to shuffle` — V-015/V-016.
7. `S01.1 Read / Deck Home / empty` — V-044, which supersedes V-024 with the compact no-scroll deck CTA, overlaid gear, and stable tab bar; English uses the same composition.
8. `S02 Layout Choice` — V-014.
9. `S04 Card Meaning from Reading` — V-019.
10. `S05 Learn Index` — V-020.
11. `S06 Learn Article` — V-021.
12. `S07 Cards Library / All with filters` — V-022.
13. `S08 Card Detail from Library / previous-next` — V-023.
14. `S09 Settings` — V-045, which supersedes V-025 with the internal `English / Español` selector.
15. `S10 Support the App / not active` — V-027, which supersedes V-026 with `ios-app-launch` copy; its displayed prices are illustrative and not live product configuration.
16. `S01.2 Read / Deck Home / active Three Cards reading` — V-028.
17. `S03.1 One Card / ready to shuffle` — V-029 portrait and V-030 landscape.
18. `S03.2 One Card / shuffled` — V-031 portrait and V-032 landscape.
19. `S03.3 One Card / drawn face down` — V-037 portrait and V-038 landscape, superseding V-033/V-034 so the exhausted deck no longer competes with the completed layout.
20. `S03.6 One Card / The Hermit revealed` — V-035 portrait and V-036 landscape.
21. `S02.2 Three-card spread choice / Spanish` — V-039.
22. `S03 Three Cards / Past · Present · Future / large landscape / Spanish` — V-040, which supersedes the previous landscape proportions for the three-card table.

23. `S03 Reading Table / professional motion storyboard V2` — V-048, which supersedes V-041 with press, cut, interleave, deal, and flip inside a stable viewport.
24. `S08.2 Card Detail / favorite saved` — V-042.
25. `S07.3 Cards / Favorites empty` — V-043.
26. `S03.1 Three Cards / ready / deck tap`, portrait Spanish — V-046, which supersedes V-015 for portrait interaction; English uses the same composition.
27. `S03.5 Three Cards / complete / all face down / centered`, portrait Spanish — V-047; English uses the same composition.

Still requiring a complete reference before final implementation: the remaining `S10` supporter/restore/unavailable variants and custom confirmations if they depart from standard native iOS confirmation patterns. Standard native iOS confirmations may implement the approved copy without a custom composition. StoreKit product creation and live prices remain separately unauthorized.

A shared card-reference component may serve S04 and S08 only after both navigation contexts are represented and registered. Portrait and landscape require separate references whenever the composition changes materially. A-021 removes the need to pause for routine approval but does not remove image creation, registration, fidelity review, or accessibility adaptation.

## MVP completion gate

The expanded MVP core is complete when the journeys above for Read, Learn, and Cards pass on iPhone, all required visual references are registered before their corresponding final UI, Home/Table/meaning interaction conforms to V-044 and V-046–V-048, the 78 identity and 78 meaning key sets match exactly, the full internal `English / Español` switch is atomic and persistent, all artwork distribution rights are resolved, the six Learn articles are bundled, and macOS/Xcode verifies build, tests, orientation, VoiceOver, Dynamic Type, Reduce Motion, recovery, and offline behavior.

Settings and support are complete at product-design level when S09/S10 references and states are registered, free access is invariant across every purchase state, equivalent levels and supporter acknowledgement are represented, Restore Purchases and renewal/cancellation disclosures are present, and Privacy, Terms, and Rate the App remain distinct destinations. Live StoreKit products, prices, contracts, tax/banking setup, builds, and purchase review require separate authority and do not block core completion.

Publishing remains separately unauthorized.
