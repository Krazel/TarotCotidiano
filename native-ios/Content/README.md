# Tarot Deck content manifests

This directory defines the non-visual identity of the MVP deck and stages the exact historical source candidates used for internal development. No card image here is approved for distribution or promoted to final production art.

## Files

- `tarot-deck.v1.json`: versioned canonical inventory of exactly 78 cards.
- `provenance.v1.json`: preserved initial work-level provenance model.
- `provenance.v2.json`: current metadata manifest with one exact TaionWC Commons page and original-file URL per card.
- `PROVENANCE_COMPLETENESS.md`: completeness result and remaining release gates.
- `CandidateRWS/`: all 78 unmodified historical source candidates with complete local integrity evidence; explicitly not production assets. Its v1 three-card snapshot is preserved as history and v2 is current.
- `validate-content.ps1`: dependency-free structural validation.

## Stable identity

`id` is the durable identity used by the shuffle engine and persisted reading sessions. It is independent of display copy, artwork, file format, and provenance.

Changing from historical RWS imagery to future original art must not change any card `id`, `order`, `arcana`, `suit`, `rank`, or `majorNumber`. Only `artworkAsset`, `artworkStatus`, and `provenanceID` may change for an art replacement. A manifest schema change requires a new versioned file and a documented migration; do not silently mutate the meaning of version 1.

`order` is zero-based. Orders 0-21 are the Major Arcana. Orders 22-77 contain Wands, Cups, Swords, and Pentacles, with Ace through King inside each suit. Order is an inventory convention, not the shuffled order of a reading.

## Artwork is provisional

Every `artworkAsset` is a proposed Apple asset-catalog key and `artworkStatus` remains `provisional`. The 78 raw files in `CandidateRWS/` are source candidates, not approval to bundle those keys as production art. This manifest does not approve final art or final UI.

The current provenance reference identifies the coherent 78-file TaionWC Pam-A scan set on Wikimedia Commons. Commons declares every page public domain, but this metadata pass does not clear any downloaded file or intended App Store territory. Before an image can be treated as distributable:

1. Confirm that it is a faithful reproduction of the original work, not a modern edition or creative derivative.
2. Download from the exact URL in `provenance.v2.json`, then record the local SHA-256 and manual pixel review.
3. Review rights for every intended App Store territory. Public-domain conclusions can differ by jurisdiction and by the rights in a particular scan or restoration.
4. Keep modern recolorings, restorations, borders, typography, card backs, guidebook material, trademarks, and commercial edition assets out unless separately licensed.
5. Set `distributionApproved` and each card's `artworkStatus` only after the project owner accepts the evidence.

This is a provenance control, not legal advice.

## Future original deck

The future art set has a reserved provenance record: `tarot-cotidiano-original-artwork-future`. When original faces are ready, replace the provisional asset key and provenance reference card by card while retaining stable IDs. Mixed art may be useful during production, but release should use one coherent, fully cleared 78-card set plus a separately cleared card back.

## Validation

From the repository root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\native-ios\Content\validate-content.ps1
```

The script checks counts, unique IDs and orders, the exact Major/Minor structure, suit/rank completeness, 78 unique TaionWC evidence mappings, the historical v1 snapshot, and all 78 v2 local files against source SHA-1, bytes, JPEG format and dimensions while independently recording local SHA-256. It also requires the candidate-only and distribution gates to remain closed. It does not validate image rights, territorial clearance or final visual quality.
