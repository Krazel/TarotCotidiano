# Daily Tarot — MVP Screen and State Map

Status: functional proposal for owner approval  
First release: iPhone only, English only  
Date: 2026-08-08

## Purpose and boundary

This document defines information structure, user flows, states, and target English interface language. It does not prescribe a visual style, final composition, or architecture. No screen described here is approved for implementation until the owner approves a complete visual reference for that screen.

The MVP retains four useful areas from the existing product concept:

1. Today
2. Explore
3. Saved
4. Settings

There is no onboarding, account, paywall, language selector, or platform choice. The app opens on Today. All product copy and card content are English only.

## Functional hierarchy

```text
App launch
└── Brief local restore
    └── Today
        ├── Card unrevealed
        ├── Card revealed
        │   ├── Save / remove
        │   └── Share → native iOS share sheet
        └── Primary navigation
            ├── Explore
            │   └── Selected category
            │       └── Card
            │           ├── Save / remove
            │           └── Share → native iOS share sheet
            ├── Saved
            │   ├── Empty
            │   └── Collection
            │       └── Saved card
            │           ├── Share → native iOS share sheet
            │           └── Remove
            └── Settings
                └── Daily reminder
                    ├── Off
                    ├── Native iOS permission request
                    ├── On
                    └── Permission denied / restricted
```

“Selected category” and “Card” may be states within one Explore screen rather than separate pushed screens. The approved visual direction will determine that composition.

## Global navigation

| Destination | User purpose | Primary action |
|---|---|---|
| Today | Complete the daily ritual | Reveal the card |
| Explore | Find a card for a current need | Choose a category |
| Saved | Return to deliberately kept messages | Read a saved card |
| Settings | Configure an optional return cue | Enable or change the reminder |

Rules:

- The app launches into Today.
- Moving between destinations never changes Today's card.
- The last selected Explore category is stored locally.
- Save or remove actions update every destination consistently.
- Share actions open the native iOS share sheet and return to the same source context when closed.
- There is no Android navigation, Android copy, or language setting.

## S00 — Launch and local restore

### Goal

Restore local choices before presenting interactive state.

### Entry

- Cold app launch.

### States

| State | Content and behavior | Exit |
|---|---|---|
| `S00.1 Restoring` | Brief non-interactive transition. No network, account, or permission request. | Opens `S01.1` or the persisted revealed state for today. |
| `S00.2 No previous data` | Applies defaults: no saved cards, reminder off, Encouragement selected. | Opens `S01.1`. |
| `S00.3 Local read failed` | Core use continues with session defaults. A message appears only if a user action cannot be preserved. | Opens `S01.1`; a later write may retry. |

Not included:

- Mandatory animated splash content.
- Remote content download.
- Login.
- Notification permission request.
- Language detection or selection.

## S01 — Today

### Goal

Deliver the central value in under two minutes: reveal, read, and leave.

### Shared content

- Local date in English.
- Context label: **Your card for today**.
- One card assigned to that date.
- Primary navigation.

### States

#### S01.1 — Card unrevealed

- Card identity and content remain hidden.
- One primary action: **Reveal card**.
- Short helper copy: **Tap to reveal the message for your day.**
- Save and share are unavailable until reveal.

Transition: `Reveal card` → `S01.2 Card revealed`.

#### S01.2 — Card revealed, not saved

- Shows the English category, title, message, and reflection question for one of the 36 cards.
- Primary content action: **Save**.
- Secondary action: **Share**.
- The user may leave immediately; no written response or completion confirmation is required.

Transitions:

- `Save` → `S01.3 Revealed and saved`.
- `Share` → `S05 Native iOS share sheet`.
- destination selection → chosen area.

#### S01.3 — Card revealed and saved

- Content remains unchanged.
- Save state reads **Saved** and can be reversed through **Remove from Saved**.

Transitions:

- `Remove from Saved` → `S01.2`.
- `Share` → `S05`.

#### S01.4 — Reopen on the same day

- Product recommendation: if already revealed, reopen directly in `S01.2` or `S01.3`.
- The app never simulates a second card or changes the content that day.
- This state depends on owner approval of persistent reveal behavior.

#### S01.5 — Local day changes

- On the next visit after local midnight, Today presents the new date's card in `S01.1`.
- If the app remained open, it refreshes when returning to the foreground; no midnight interruption is needed.
- The previous card remains accessible only if saved. The MVP creates no automatic history.

### Exceptions

- Content is bundled locally, so there is no card loading, offline, or server-error state.
- A device date or time-zone change recalculates the local date; the MVP adds no anti-manipulation behavior.

## S02 — Explore

### Goal

Let the user intentionally choose a topic and read from the fixed collection without turning Explore into another draw.

### Required inventory

- 12 English categories: Encouragement, Focus, Calm, Discipline, Self-Worth, Gratitude, Courage, Habits, Creativity, Resilience, Relationships, and Energy.
- 3 English cards within each category.
- All 36 cards reachable, with no duplicates, locks, or Spanish fallback.

### States

#### S02.1 — Default category

- Shows all 12 categories.
- On first use, Encouragement may be selected to remain coherent with the existing stored default.
- Shows its three cards.

#### S02.2 — Category selected

- Selecting a category updates the context and the three visible cards.
- The latest selection persists locally.
- It never affects Today's card.

Target helper pattern: **Three reflections for [Category].**

#### S02.3 — Explore card, not saved

- Shows the English title, message, and question in full.
- Actions: **Save** and **Share**.
- It does not use **Reveal**: browsing is intentional consultation, not a second draw.

#### S02.4 — Explore card, saved

- Content remains unchanged.
- The saved state is unambiguous and reversible.

### Transitions

- `Choose category` → `S02.2`.
- `Choose card` → `S02.3` or `S02.4`.
- `Save / remove` → updates `S02` and `S03`.
- `Share` → `S05`.

### Unneeded states

- No category is empty: the verified source has three concepts in each.
- No search, filters, manual sorting, folders, pagination, or “load more”.
- No remote loading, locked content, or translation state.

## S03 — Saved

### Goal

Provide a private, intentional collection of messages the user wants to revisit.

### States

#### S03.1 — Empty

- Title: **Saved**.
- Message: **No saved cards yet. Save a card from Today or Explore when you want to return to its message.**
- Navigation to Today and Explore remains available.
- Empty is not presented as an error.

#### S03.2 — Populated

- Shows all locally saved cards.
- Each item identifies at least English title and category and gives access to the full message and question.
- Recommended order: most recently saved first, coherent with existing behavior.
- Per-card actions: **Share** and **Remove**.

#### S03.3 — Last card removed

- The collection immediately becomes `S03.1 Empty`.
- No confirmation screen is required for an action that can be reversed by saving the card again.

#### S03.4 — Missing card reference

- If a stored identifier does not match one of the 36 cards, no broken card appears.
- Other saved cards remain usable.
- This is a recovery state, not a normal user feature.

Not included:

- Notes, journaling, or automatic history.
- Folders, tags, or manual reordering.
- Cloud sync or bulk export.

## S04 — Settings

### Goal

Offer one optional daily reminder without making notifications a condition of use.

### Reminder states

#### S04.1 — Off, permission not requested

- Section title: **Daily reminder**.
- Supporting copy: **Get a reminder when your daily card is ready.**
- Toggle is off.
- Time may show the default `8:00 AM`, but nothing is scheduled.
- Enabling the toggle triggers the contextual native iOS permission request.

Transition: `Enable` → `S06.1 Native permission request`.

#### S04.2 — On

- Toggle is on.
- Current local reminder time is visible.
- The user can choose and save another valid time.
- Only one reminder exists; changing the time replaces the previous schedule.

Transitions:

- `Change time` → remains in `S04.2` with brief success feedback.
- `Disable` → cancels the reminder and returns to off.

#### S04.3 — Off, permission denied or restricted

- Toggle remains off.
- Message: **Notifications are turned off for Daily Tarot. You can enable them in iPhone Settings.**
- A clear action may open the appropriate iOS Settings destination when technically available.
- The app remains fully usable and does not repeatedly trigger the system prompt.

#### S04.4 — Time selection

- Uses an iOS-appropriate localized time control while all surrounding product copy remains English.
- The selected value represents an unambiguous local time.
- Saving reschedules the reminder if it is enabled.

#### S04.5 — Invalid or incomplete value

- This state is needed only if implementation uses manual text entry rather than the native time picker.
- No ambiguous time is scheduled.
- The last valid time remains active and corrective copy appears next to the control.

#### S04.6 — Schedule or cancellation failed

- The UI shows the last confirmed state, not an optimistic state that did not complete.
- Message: **We couldn't update your reminder. Try again.**
- Retry is available.
- Today, Explore, and Saved remain unaffected.

### “Test notification” decision

The existing app exposes this action. It is excluded from the user-facing MVP because it does not support the daily loop. It may remain an internal validation aid until technical testing is complete, then be removed or hidden before release.

## S05 — Native iOS share sheet

### Goal

Let the user voluntarily send a card through services available on their iPhone.

### Entry points

- A revealed Today card.
- An Explore card.
- A Saved card.

### Base shared text

- English card title.
- English message.
- Approved English product name.
- Reflection question only if approved by the owner.

Example structure, not final card copy:

```text
[Card title]

[Message]

Daily Tarot
```

### States

| State | Result |
|---|---|
| `S05.1 Open` | iOS presents available destinations. Daily Tarot does not access accounts or contacts. |
| `S05.2 Shared` | Returning to the app preserves the originating card and state. |
| `S05.3 Cancelled` | Closes without changes and returns to the same context. |
| `S05.4 Failed` | The system or app gives brief English feedback; card and save state do not change. |

## S06 — Native iOS notification permission

### Goal

Request permission only after the user explicitly chooses to enable the daily reminder.

| State | Behavior | Exit |
|---|---|---|
| `S06.1 System request` | iOS controls the dialog. The app does not imitate it or precede it with mandatory onboarding. | Granted → `S04.2`; denied → `S04.3`. |
| `S06.2 Granted` | Schedules one local reminder at the chosen time. | Returns to Settings with confirmation. |
| `S06.3 Denied/restricted` | Schedules nothing and keeps the product usable. | Returns to `S04.3`. |

## Persistence matrix

| Data or state | During session | After app close | When local date changes |
|---|---:|---:|---:|
| Card assigned to the date | Yes | Recomputed consistently | Changes by rotation |
| Daily card revealed | Yes | **Owner decision; recommended yes** | Resets for new card |
| Saved card identifiers | Yes | Yes | Yes |
| Last Explore category | Yes | Yes | Yes |
| Reminder state and time | Yes | Yes | Yes |
| Currently open Explore/Saved card | Not required | No | No |
| Daily card history | No | No | No |
| Language preference | Not applicable | Not applicable | Not applicable |

## Coverage of the 36 existing concepts

| Area | Coverage |
|---|---|
| Today | All 36 English adaptations participate in the daily rotation; one appears per date. |
| Explore | All 36 are reachable: 12 English categories with 3 cards each. |
| Saved | May contain any subset of the 36, with no duplicates. |
| Share | Accepts any of the 36 from its current context. |
| Settings | Does not affect the collection or card selection. |

The old Spanish texts remain source references only. No user-facing state may mix English and Spanish.

## Critical acceptance journeys

### A. First visit without permissions

`Launch` → `Today, unrevealed` → `Reveal card` → `Read` → `Leave`

Result: complete value without account, network, saving, or permission.

### B. Save and return

`Today, revealed` → `Save` → `Saved` → `Open card` → `Remove`

Result: state stays consistent; removing the final card reveals the empty state.

### C. Browse the full collection

`Explore` → `Choose each category` → `Read its three cards`

Result: all 12 categories and 36 English cards are reachable; browsing never changes Today.

### D. Enable a reminder

`Settings, off` → `Enable` → `iOS permission granted` → `Choose time` → `Save`

Result: exactly one local reminder is scheduled for the confirmed time.

### E. Deny permission

`Settings, off` → `Enable` → `iOS permission denied` → `Explanatory state`

Result: no phantom reminder; every other feature remains usable.

### F. Share and cancel

`Card` → `Share` → `iOS share sheet` → `Cancel`

Result: returns to the same card without changing save, selection, or reveal state.

### G. English-only integrity

`Launch` → visit every destination and system-return state → open all 36 cards

Result: every app-owned visible string and card field is English; no language selector, Spanish fallback, or mixed-language error appears.

## States requiring an approved visual reference

Before implementation or redesign, the visual task must create and obtain separate approval for at least:

1. Today with the card unrevealed.
2. Today with the card revealed and actions visible.
3. Explore with one category and its three cards.
4. Saved in both empty and populated states.
5. Settings with the reminder off and on.

The share and permission panels belong to iOS. Their entry context must be designed, but the app must not replace them with custom imitations.

## Owner decisions affecting this map

1. Approve `Daily Tarot` or provide another English product name.
2. Approve persistent reveal after reopening on the same day; recommendation: yes.
3. Choose a common date-based rotation or a stable device-specific sequence.
4. Confirm Explore as one of the four MVP destinations.
5. Decide whether shared text includes the reflection question.
6. Approve the 12 English category names and 36 working English card titles before editorial adaptation.

These decisions must be settled before the related visual references are approved. They do not authorize implementation, Android work, additional languages, or new product features.
