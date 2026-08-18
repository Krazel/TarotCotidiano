# Tarot Deck content manifests

This directory defines the canonical deck identity and preserves the exact historical source evidence for the owner-approved final visual set. The 78 faces are cleared only for the explicit `US`, `GB` and `ES` storefront allowlist; worldwide distribution is not approved.

## Files

- `tarot-deck.v1.json`: versioned canonical inventory of exactly 78 cards.
- `provenance.v1.json`: preserved initial work-level provenance model.
- `provenance.v2.json`: current metadata manifest with one exact TaionWC Commons page and original-file URL per card.
- `PROVENANCE_COMPLETENESS.md`: completeness result and remaining release gates.
- `CandidateRWS/`: all 78 unmodified historical source files with complete local integrity evidence. Its v1 three-card candidate snapshot is preserved as history; v2 records the current final, territory-limited decision.
- `validate-content.ps1`: dependency-free structural validation.

## Stable identity

`id` is the durable identity used by the shuffle engine and persisted reading sessions. It is independent of display copy, artwork, file format, and provenance.

Changing from historical RWS imagery to future original art must not change any card `id`, `order`, `arcana`, `suit`, `rank`, or `majorNumber`. Only `artworkAsset`, `artworkStatus`, and `provenanceID` may change for an art replacement. A manifest schema change requires a new versioned file and a documented migration; do not silently mutate the meaning of version 1.

`order` is zero-based. Orders 0-21 are the Major Arcana. Orders 22-77 contain Wands, Cups, Swords, and Pentacles, with Ace through King inside each suit. Order is an inventory convention, not the shuffled order of a reading.

## Final visual set and territorial boundary

Every canonical card now has `artworkStatus=final`, a verified Apple asset-catalog key and exact local integrity evidence. The owner's visual approval does not imply worldwide rights clearance. Public release is limited to `US`, `GB` and `ES`; `distributionApproved=false` and `worldwideDistributionApproved=false` remain deliberate global safeguards.

The current provenance reference identifies the coherent 78-file TaionWC Pam-A scan set on Wikimedia Commons. The release audit separately records the factual and territorial basis for the three approved storefronts. Any expansion still requires all of the following:

1. Confirm that it is a faithful reproduction of the original work, not a modern edition or creative derivative.
2. Keep the exact URL, SHA-1, local SHA-256, byte, JPEG and dimension evidence intact.
3. Review rights for every additional intended App Store territory. Public-domain conclusions can differ by jurisdiction and by the rights in a particular scan or restoration.
4. Keep modern recolorings, restorations, borders, typography, card backs, guidebook material, trademarks, and commercial edition assets out unless separately licensed.
5. Update the explicit allowlist only after adequate evidence and a truthful project decision; never infer worldwide approval from the current three territories.

This is a provenance control, not legal advice.

## Future original deck

The future art set has a reserved provenance record: `tarot-cotidiano-original-artwork-future`. If original faces replace the current final set later, update the asset key and provenance reference card by card while retaining stable IDs. Mixed art may be useful during production, but release should use one coherent, fully cleared 78-card set plus a separately cleared card back.

## Validation

From the repository root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\native-ios\Content\validate-content.ps1
```

The script checks counts, unique IDs and orders, the exact Major/Minor structure, suit/rank completeness, 78 unique TaionWC evidence mappings, the historical v1 snapshot, and all 78 current v2 local files against source SHA-1, bytes, JPEG format and dimensions while independently recording local SHA-256. It requires the final visual state, exact `US/GB/ES` allowlist and worldwide=false boundary. Legal and runtime release gates remain separate.
