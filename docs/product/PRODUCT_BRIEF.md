# Daily Tarot — Product Brief

Status: product proposal for owner approval  
First release: iPhone only, English only  
Date: 2026-08-08

## Product in one sentence

Daily Tarot is a private daily reflection ritual: one card, one grounded message, and one question that helps a person choose a useful intention in under two minutes.

It uses tarot-inspired symbolism without claiming to predict the future, replace professional advice, or produce definitive answers.

## Target user

### Primary user

An English-speaking adult who:

- is curious about tarot, symbolism, or mindful rituals but needs no prior tarot knowledge;
- wants a brief pause at the start of the day or during a stressful moment;
- prefers a gentle, practical prompt to a long meditation or endless content feed;
- values privacy and does not want an account, public profile, or writing obligation;
- uses an iPhone as their primary device.

### Core situation

They open the app once a day, often after an optional reminder. They reveal one card, read its message and reflection question, then return to their day. At other times, they can revisit a saved card or browse a category that matches what they need.

### Not the primary MVP user

- Someone seeking fortune-telling, complex spreads, reversed cards, or traditional tarot instruction.
- Someone seeking therapy, diagnosis, crisis support, or professional advice.
- Someone seeking a social network, long-form journal, or infinite stream of new content.

## Problem and job to be done

When people want a small moment of direction, they often encounter content that is generic, time-consuming, or optimized to keep them scrolling. Daily Tarot offers a bounded alternative: one thought to read, one question to consider, and permission to leave.

> “Help me pause and find a useful intention for today without asking for much time, personal data, or public participation.”

## Core promise

**One card a day turns a pause of less than two minutes into a clear, compassionate intention.**

The MVP proves this promise through:

- one card that stays stable for the local calendar day;
- one concise message and one open reflection question;
- no account, purchase, connection, or required setup;
- optional save and share actions;
- one optional local daily reminder.

## Product principles

1. **Reflection, not prediction.** Cards offer a perspective or action, never certainty about the future.
2. **A ritual with an ending.** The daily experience can be completed in under two minutes and does not lead into a feed.
3. **Low friction.** The card can be revealed without registration, connectivity, payment, or a mandatory tutorial.
4. **Private by default.** Saved cards and reminder preferences remain on the iPhone in the MVP.
5. **Curated and finite.** The 36-card collection is the product, not a placeholder for automatically generated content.
6. **User agency.** Saving, sharing, browsing, and enabling reminders are choices, not completion requirements.

## Daily loop

1. **Optional cue:** a local notification arrives at the time chosen by the user.
2. **Arrival:** the app opens on Today with the daily card ready and unrevealed.
3. **Ritual:** the user taps once to reveal it.
4. **Reflection:** they read the title, message, and question and choose an intention outside the app.
5. **Optional keeping:** they save the card or share it through the native iOS share sheet.
6. **Closure:** they leave with nothing else required; the next new card arrives on the next local day.

Revealing and reading completes the loop. Saving, sharing, and browsing are supporting actions, not success gates.

## Small MVP

### Included

1. **Today**
   - One card for the current local date.
   - Unrevealed and revealed states.
   - English category name, card title, message, and reflection question.
   - Save, remove from saved, and share.

2. **Explore**
   - The 12 existing concepts adapted into English categories.
   - Three cards per category, for all 36 existing concepts.
   - Full card reading, save, and share.

3. **Saved**
   - A local collection of cards deliberately saved by the user.
   - Empty and populated states.
   - Read, share, and remove actions.

4. **Settings**
   - Enable or disable one local daily reminder.
   - Choose one valid local time.
   - Handle notification permission granted, denied, or restricted.

5. **Foundations**
   - No account and no network requirement for core use.
   - Local persistence for saved cards, the last explored category, reveal state, and reminder settings.
   - Designed, implemented, and validated for iPhone only.
   - All user-facing product language and card content are English only.

### Why this remains small

The MVP has four functional destinations and one central action: reveal today's card. Explore reuses the fixed 36-card set and does not introduce a second reading mode. Saved and the reminder support return behavior without adding progress systems.

## Explicit exclusions

- Android, iPad, web, and cross-device synchronization.
- Any language other than English, language selection, translation workflow, or localization planning.
- Registration, profiles, login, cloud backup, or data recovery.
- Subscriptions, purchases, advertising, or locked cards.
- Multi-card spreads, reversed cards, question-based draws, predictions, or traditional tarot lessons.
- AI-generated content, chat, or personalized interpretations.
- Journaling, notes, history, calendar, streaks, achievements, statistics, or automatic tracking of viewed cards.
- Community, comments, followers, messaging, or a social feed.
- New cards, categories, decks, remote content management, or content import.
- Widgets, Apple Watch, Live Activities, and multiple reminders.
- Medical, psychological, financial, or legal claims or advice.
- Multi-page onboarding, a mandatory tutorial, or a notification request on first launch.
- A user-facing “test notification” action. It may remain an internal testing aid until technical validation is complete.

## Content model

### Verified source set

The existing project contains **36 complete Spanish source cards**, each with a unique identifier, arranged evenly as **12 categories × 3 cards**. Every card references a valid category and contains a title, message, and prompt.

For the English-only MVP, those Spanish texts are conceptual source material, not production copy. The production set must contain exactly 36 professionally edited English adaptations with the same conceptual coverage and identifiers. This is content adaptation for the first version, not a localization feature.

### Working English content inventory

These are target English names for product definition. Final English prose still needs an editorial pass before implementation.

| Stable ID | English category | Editorial purpose | Three working card titles |
|---|---|---|---|
| `animo` | Encouragement | Begin with clarity and self-directed momentum | Inner Dawn; The Steady Flame; The Low Sun |
| `foco` | Focus | Direct attention and choose a priority | The Serene Eye; The Golden Needle; The Clear Table |
| `calma` | Calm | Return to presence and create space | The Still Bowl; The Night Bloom; The Blue Mist |
| `disciplina` | Discipline | Move through sustainable consistency | The Patient Mountain; The Narrow Gate; The Constant Thread |
| `autoestima` | Self-Worth | Relate to oneself with truth and kindness | The Noble Mirror; The Crowned Heart; A Home Within |
| `gratitud` | Gratitude | Notice support and resources already present | Open Hands; The Full Cup; Shared Bread |
| `valentia` | Courage | Act with calm, responsible bravery | The Golden Lion; The Torch; The Threshold |
| `habitos` | Habits | Make small actions repeatable | The Seed; The Inner Garden; The Simple Key |
| `creatividad` | Creativity | Open play, variation, and intuition | The Creative Moon; The Spark; The Secret Workshop |
| `resiliencia` | Resilience | Adapt without abandoning direction | The Waves; The Warm Stone; The Bridge |
| `relaciones` | Relationships | Practice listening, reciprocity, and boundaries | The Two Candles; The Loose Knot; The Golden Boundary |
| `energia` | Energy | Choose where to place effort and rest | The Guiding Star; The Solar Circle; The Blue Fire |

### Entities and fields

**Category**

- `id`: stable internal key; existing keys may remain internal.
- `name`: English user-facing name.
- `description`: short English thematic promise.
- `symbol`: symbolic reference.
- `color` and `softColor`: existing presentation metadata; final use depends on the approved visual direction.

**Card**

- `id`: unique stable key using the existing `<category>-<number>` convention.
- `category`: required relation to one category.
- `title`: evocative English card name.
- `message`: concise, self-contained, non-predictive English interpretation.
- `prompt`: open English question that turns the message into personal reflection.

**User state**

- saved card identifiers;
- last selected category;
- daily card reveal state and its local date;
- reminder enabled or disabled;
- reminder time.

### Editorial rules

- Each card belongs to exactly one category and retains the title + message + prompt structure.
- English copy should sound natural and intentional, not like a literal translation from Spanish.
- A message may invite or suggest, but must not command, promise outcomes, or claim supernatural certainty.
- A prompt must be answerable mentally and must not require the user to enter personal data.
- Tone is warm, concise, inclusive, contemporary, and free of gendered address.
- Shared text contains only approved English product copy and is sent only after an explicit user action.
- The 36-card set is frozen for the MVP. Content review improves English craft without expanding the collection.

### Reference daily selection rule

To stay coherent with the existing product idea, the MVP baseline is:

- one card per local calendar date;
- the card stays unchanged for that day;
- all 36 cards participate in a deterministic rotation and repeat after the cycle;
- the Explore category does not influence Today's card;
- no automatic card history is stored.

The owner still needs to approve whether the sequence is common by date or personal to each device.

## Differentiation

1. **Grounded tarot symbolism.** Each symbol leads to a practical question, not a theatrical prediction.
2. **Deliberate closure.** One card and one question provide a satisfying endpoint instead of an engagement feed.
3. **A visible, original collection.** All 36 concepts can be browsed through recognizable human needs.
4. **Private core experience.** The ritual works locally without identity, profiling, or public participation.
5. **Two compatible modes.** Today supports the habit; Explore supports intentional reflection without inventing another type of draw.

## MVP success signals

These guide product testing and do not require remote analytics in the MVP.

- A first-time user understands the action on Today without outside instruction.
- They can reveal and read the card in under two minutes.
- The card stays stable for the local date and changes on the next day.
- All 36 cards are reachable: three within each of 12 English categories.
- Save, remove, and share remain consistent from every defined entry point.
- A user can enable, change, and disable the reminder, including after denying permission.
- Core use works offline and after closing and reopening the app.
- All visible production copy is English, with no Spanish fallback or mixed-language state.
- VoiceOver, Dynamic Type, contrast, and touch targets are validated during implementation.

## Definition of done

Product definition is complete when the owner approves the promise, English-only scope, daily selection model, content direction, and screen map. The MVP becomes release-ready only after every screen has an approved full-screen visual reference, the iPhone implementation matches those references, all English content is editorially approved, and the defined states pass validation. Publishing or App Store submission is not authorized by this document.

## Owner decisions

These should be reviewed as one decision set. They do not authorize implementation.

### Identity and content

1. **Product name:** approve `Daily Tarot` or choose another English name. Existing source materials use both “Tarot Cotidiano” and “Oráculo Cotidiano”; neither remains user-facing in the English-only MVP.
2. **Positioning:** confirm tarot-inspired reflection without predictive claims, or request a more explicitly spiritual voice.
3. **English titles:** approve the 12 category names and 36 working card titles as the basis for the editorial adaptation.

### Daily card rule

4. **Shared or personal sequence:** use one deterministic card for the local date across all devices, or generate a stable device-specific sequence.
5. **Persistent reveal:** decide whether a revealed card remains face-up after reopening on the same day. Recommendation: yes.
6. **36-day repetition:** accept the finite cycle as intentional. Any collection expansion belongs to a later milestone, not this MVP.

### Scope and return

7. **Explore in MVP:** confirm the 12-category collection as one of the four destinations. Recommendation: keep it because it makes the existing content useful without adding a new reading mechanic.
8. **Notification timing:** confirm that iOS permission is requested only after the user enables the reminder in Settings. Recommendation: yes.
9. **Share copy:** decide whether shared text includes the reflection question in addition to title, message, and product name.
