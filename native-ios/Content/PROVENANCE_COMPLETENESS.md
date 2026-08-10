# TaionWC provenance completeness report

Status: metadata-complete candidate; three integrity-verified source files downloaded; not distribution-cleared
Checked: 2026-08-09

## Result

The [Wikimedia Commons TaionWC category](https://commons.wikimedia.org/wiki/Category:Rider-Waite-Smith_tarot_deck_(TaionWC)) currently returns exactly 78 JPEG files and describes them as one Pam-A scan set. Every file maps one-to-one to a stable card ID in `tarot-deck.v1.json`.

- Evidence records: **78**
- Unique stable card IDs: **78**
- Unique Commons page IDs: **78**
- Unique description-page URLs: **78**
- Unique original-file URLs: **78**
- Unique source SHA-1 values: **78**
- Major Arcana mappings: **22**
- Minor Arcana mappings: **56**
- Wands, Cups, Swords, Pentacles: **14 each**
- Declared creator: **Pamela Colman Smith on 78/78 pages**
- Declared source date: **1910 on 78/78 pages**
- Declared license: **Public domain on 78/78 pages**
- Public-domain categories: **CC-PD-Mark and PD-old-80-expired on 78/78 pages**
- Dimensions present: **78/78**; widths range from 1090 to 1144 pixels and heights from 1919 to 1920 pixels
- Candidate source files downloaded: **3** — The Star, The Moon, and The Sun
- Files added to a production asset catalog: **0**
- Local SHA-256 values: **3**
- Source-integrity, dimensions, and JPEG decode reviews: **3**
- Final-art pixel reviews: **0**
- Territorial rights approvals: **0**
- Distribution approvals: **0**

The exact metadata query is recorded in `provenance.v2.json`. Wikimedia's page URL, original-file URL, page ID, dimensions, byte size, MIME type, source SHA-1, license metadata, public-domain marks, and review state are preserved for every card.

## Review boundary

This pass verifies metadata completeness and set coherence only. It does not independently prove that a particular scan is clear in every intended storefront, and it does not treat a Commons label as project legal approval.

The following remain release gates:

1. Download each candidate through a controlled asset task.
2. Calculate a local SHA-256 and compare the downloaded bytes with the recorded Commons source.
3. Review every image for the expected card, complete borders, crop consistency, resolution, modern restoration, recoloring, watermarks, added typography, or other derivative material.
4. Review public-domain and source-file status for the intended App Store territories.
5. Record any transformations and approve one coherent 78-face set plus a separately cleared card back.
6. Change `distributionApproved` only through an explicit project decision.

## Future original artwork

The TaionWC mapping is replaceable. A future original deck keeps all 78 stable card IDs and changes only the asset/provenance references after written ownership or license evidence exists. No TaionWC filename is used as a persisted card identity.
