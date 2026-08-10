# Superseded Product Reference — Daily Reflection

Status: historical reference; not the current Tarot MVP
Original definition date: 2026-08-08
Superseded by the owner's digital-deck direction: 2026-08-09

## Why this file exists

The repository previously defined Tarot as `Daily Tarot`, a bounded daily-reflection ritual. That direction is preserved here so its useful thinking, source content, and implemented prototype remain recoverable. It must not be treated as approval for the current digital-deck product or as permission to implement its screens.

## Previous product promise

The earlier proposal offered one stable card per local day, one short non-predictive message, and one reflection question. The intended user wanted a private pause of less than two minutes rather than a traditional tarot reading.

Its daily loop was:

1. optionally receive a local reminder;
2. open `Today` on an unrevealed daily card;
3. reveal and read one message and question;
4. optionally save or share it;
5. return the next local day for another card.

## Previous MVP structure

- `Today`: unrevealed and revealed daily-card states.
- `Explore`: 12 thematic categories with three cards each.
- `Saved`: a local collection of deliberately saved cards.
- `Settings`: one configurable local reminder.
- Native iOS share sheet and notification-permission flows.
- No account or network requirement for core use.

## Preserved source model

The Expo prototype contains 36 original Spanish reflective cards arranged as 12 categories × 3 cards. Each card has a stable identifier, title, message, and question. The categories are encouragement, focus, calm, discipline, self-worth, gratitude, courage, habits, creativity, resilience, relationships, and energy.

These cards are coherent as an oracle-style reflection collection. They are not a standard tarot deck: they do not contain the 22 Major Arcana and 56 Minor Arcana expected from a complete 78-card tarot deck. They therefore remain conceptual and editorial source material, not production content for the current MVP.

## Preserved implementation and visual references

- `README.md`, `App.js`, and `data/tarot.js` describe and implement the earlier Expo prototype.
- `design/CONCEPTS.md`, `design/APPROVALS.md`, and `design/concepts/` preserve its visual exploration.
- The prior approval of `Ceremonial Obsidian` applied to the old revealed daily-card state only. It may inform future exploration, but it does not approve any screen in the digital-deck flow.
- Git history, including initial commit `46127ce`, remains the recoverable baseline.

## What is outside the current Tarot product

The following ideas are not part of the digital-deck MVP: an automatic card of the day, reflection prompts, thematic self-help categories, reminders, a saved-message library, and engagement organized around returning each day.

The separate Zodiac/Horoscope product owns the new daily magazine-style horoscope idea. This Tarot repository must not absorb zodiac signs, horoscope copy, or a second product mode. The 36-card reflection collection is preserved here; it does not move automatically into the Zodiac product.

## Current source of truth

Use `PRODUCT_BRIEF.md` and `SCREEN_MAP.md` for the active digital-deck definition. Product and visual decisions made for this historical direction are superseded wherever they conflict with those documents and the owner's 2026-08-09 instruction.
