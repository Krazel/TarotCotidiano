# TaionWC provenance completeness report

Status: 78/78 source metadata complete; owner-approved final visual set; release clearance limited to US/GB/ES
Checked: 2026-08-18

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
- Historical v1 source snapshot downloads: **3** — The Star, The Moon, and The Sun
- Complete v2 local evidence: **78/78** files, hashes, dimensions and JPEG checks
- Files added to the production asset catalog: **78/78**
- Visual-final approvals: **78/78**, by explicit owner decision
- Approved storefront allowlist: **US, GB, ES**
- Worldwide distribution approval: **false**

The exact metadata query is recorded in `provenance.v2.json`. Wikimedia's page URL, original-file URL, page ID, dimensions, byte size, MIME type, source SHA-1, license metadata, public-domain marks, and review state are preserved for every card.

## Review boundary

The historical v1 pass verified metadata completeness and three controlled downloads. The current v2 snapshot verifies all 78 exact local files. The project decision does not treat a Commons label as worldwide clearance; it separately approves only the reviewed US/GB/ES storefront allowlist.

The following remain release gates:

1. Keep selected App Store territories within US/GB/ES unless a new review expands the allowlist.
2. Keep `worldwideDistributionApproved=false`.
3. Re-run the hash, image-set and provenance validators for the exact release candidate.
4. Validate the separately cleared card back, icon and programmatic visual system through `release-asset-provenance.v1.json`.
5. Obtain explicit authorization before external Content Rights attestations, territory changes, App Review or publication.

## Future original artwork

The TaionWC mapping is replaceable. A future original deck keeps all 78 stable card IDs and changes only the asset/provenance references after written ownership or license evidence exists. No TaionWC filename is used as a persisted card identity.
