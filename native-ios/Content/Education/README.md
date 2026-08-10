# Tarot Deck Education Content

This directory contains the English, offline educational content approved for the iPhone MVP.

## Files

- `card-meanings.v1.json`: upright-only reference meanings and original VoiceOver artwork descriptions for the canonical 78-card deck.
- `beginner-guide.v1.json`: eight fixed practical tutorials for preparing, using the five Read presets, reading the whole spread, and closing responsibly.
- `validate-education.ps1`: dependency-free validation against `../tarot-deck.v1.json`.

## Editorial boundaries

- The content supports reflection and learning; it does not predict outcomes or make decisions for the reader.
- Meanings are original summaries, not copied from a book, deck guide, or website.
- Artwork descriptions state the principal visible elements of the historical card image without interpreting them.
- The MVP includes upright meanings only. Opposite-orientation interpretations are intentionally absent.
- Tutorials identify documented tradition, widespread modern practice, and product-specific editorial adaptations without presenting any method as the single official way to read.
- The contextual yes-or-no lesson uses `Open Three Cards`; it never classifies individual cards, calculates a verdict, or adds a sixth Read preset.
- The guide does not replace reliable information or appropriate professional support.
- The educational layer is fully bundled and does not store the reader's question or interpretation.
- Card IDs and order must remain identical to the canonical deck manifest. Artwork can change later without changing these IDs.

## Validate

From the repository root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File native-ios/Content/Education/validate-education.ps1
```

The script exits nonzero if the schema, language, structure, IDs, order, names, keyword counts, text lengths, artwork-description uniqueness, or editorial exclusions fail.

The guide validator also fixes the eight approved tutorial IDs, titles, display order, four-section learning contract, and optional mapping to one of the five existing Read presets. It does not record reading progress or completion.
