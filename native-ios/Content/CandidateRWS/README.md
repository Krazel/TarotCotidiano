# CandidateRWS — NOT PRODUCTION ASSETS

This directory contains the 78 exact TaionWC source files mapped by `../provenance.v2.json`. They are an integrity-verified historical candidate set for internal development and content review only.

They are not approved final art, do not approve any screen, and must not be distributed while `distributionApproved` remains `false`. The files are stored outside the production Apple asset catalog. A separate internal snapshot may copy candidate bytes for development, but that does not change their rights or release status.

## Evidence manifests

- `local-evidence.v2.json` is the current complete snapshot. It records all 78 card IDs, exact source URLs, source SHA-1 matches, local SHA-256 hashes, byte sizes, JPEG decode results, and dimensions. Its required state is `candidateOnly=true`, `finalAsset=false`, `territorialRightsReviewStatus=pending`, and `distributionApproved=false`.
- `local-evidence.v1.json` is preserved as historical evidence for the first three controlled downloads: The Star, The Moon, and The Sun.
- `sync-candidate-rws.ps1` is a re-entrant integrity synchronizer. It never replaces an existing file whose SHA-1 differs, downloads only missing exact source URLs, validates bytes before moving a file into place, and limits each run to a small batch so Wikimedia's `Retry-After` can be respected.

The complete 78/78 integrity result is not a legal or territorial rights clearance. Pixel-level final-art review, territory review, explicit distribution approval, any production transformation record, and future release decisions remain pending.

Do not overwrite or edit these JPEGs. Any crop, color correction, restoration, compression, border change, or other derivative must use a new filename and receive its own provenance and rights review. Future original Tarot Cotidiano art replaces the asset reference while retaining the stable card IDs.
