# Tarot Deck app icon concepts

Created: 2026-08-11

Status: **D — Three-Card Fan selected and approved by the owner on 2026-08-11.** D is installed as the current iOS app icon for the internal SwiftUI target. A, B, C, E and F remain preserved as design history and alternatives; C remains superseded.

Shared source: `design/assets/ceremonial-card-back-v1.png`. All concepts preserve Ceremonial Obsidian, use an opaque square canvas, contain no text, and leave iOS to apply the final icon mask.

## A — The Card

- File: `design/tarot-deck/app-icon-concepts/app-icon-a-the-card.png`
- SHA-256: `3907EBFDC990A6B7FA92FE249ABA1C49746558130721CBC1E3FA1985FAD35F95`
- 1254 × 1254 PNG.
- Direction: the existing ceremonial card itself, centered and lifted slightly from the obsidian field.
- Strength: closest to the product's current visual identity.

## B — Solar Sigil

- File: `design/tarot-deck/app-icon-concepts/app-icon-b-solar-sigil.png`
- SHA-256: `2ABDC17466F6B8AA3851D514FC8BB1C59B829DE18CB1F1D8D67EF2EE81D334AA`
- 1254 × 1254 PNG.
- Direction: simplified sun, mountains and reflection without a separate card object.
- Strength: clearest mark at very small sizes.

## C — The Deck

- File: `design/tarot-deck/app-icon-concepts/app-icon-c-the-deck.png`
- SHA-256: `F7FF57AE3F8AFC3E17B7B9A5DE66D0215A7E3DC74106CE8E5572D95EF15032CD`
- 1254 × 1254 PNG.
- Direction: early fanned-deck exploration.
- Status: **superseded**. Visual inspection found four card silhouettes, so it does not satisfy the owner's exact three-card requirement.

## D — Three-Card Fan

- File: `design/tarot-deck/app-icon-concepts/app-icon-d-three-card-fan.png`
- SHA-256: `7F2DC4CE3A0A70DC9626D1C5FE9CF482CCB336DBD0971B7E8255771167031163`
- 1254 × 1254 PNG.
- Direction: exactly three cards, symmetrical fan, original solar-horizon motif.
- Strength: clearest expression of “a tarot deck” while preserving the established card back.
- Owner decision: selected explicitly on 2026-08-11.
- Preserved generated source: 1254 × 1254 opaque RGB PNG; SHA-256 `7F2DC4CE3A0A70DC9626D1C5FE9CF482CCB336DBD0971B7E8255771167031163`.
- Prepared iOS master: `design/tarot-deck/app-icon-masters/app-icon-d-three-card-fan-1024.png`; 1024 × 1024, 8-bit opaque sRGB RGB PNG without a baked mask; SHA-256 `FFB38A413D8A99433A7A13E8626143A4FED96AD41AAB774D5D2C520C20BE200E`.
- Target rendition: `native-ios/TarotDeckApp/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png`; byte-identical to the prepared master.

## E — Three-Card Stack

- File: `design/tarot-deck/app-icon-concepts/app-icon-e-three-card-stack.png`
- SHA-256: `F7E3CF9FC03B62AC03CCC436CB51B0CC875B2FD821745C3DD9FF2477C062CBAC`
- 1254 × 1254 PNG.
- Direction: exactly three cards in a diagonal stack with a bolder eclipse motif.
- Strength: more dynamic silhouette and stronger recognition at small sizes.

## F — Three-Card Crescent

- File: `design/tarot-deck/app-icon-concepts/app-icon-f-three-card-crescent.png`
- SHA-256: `AACE436916D4B9CF7517147FB7ACD168897A7A38E9967E47E35A196E97FE4F31`
- 1254 × 1254 PNG.
- Direction: exactly three equally visible cards with a simplified crescent-and-star system.
- Strength: the most graphic and logo-like option.

## Recommendation

**D — Three-Card Fan is the selected current app icon.** It communicates the product more explicitly than the abstract sigil, satisfies the exact three-card requirement, and stays closest to the approved ceremonial card back. Keep **A — The Card** as the strongest preserved single-card alternative. Apple applies the platform mask at build/install time; neither the master nor the catalog rendition contains baked corner rounding.

Generation method: built-in image generation, one reference-guided prompt per concept.
