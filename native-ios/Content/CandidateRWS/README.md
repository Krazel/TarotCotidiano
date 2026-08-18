# CandidateRWS — canonical source evidence

This historically named directory contains the 78 exact TaionWC source files mapped by `../provenance.v2.json`. They are the integrity-verified source evidence for the owner-approved final card-face set.

Visual approval and territorial clearance are separate. The current decision permits storefront preparation only for `US`, `GB` and `ES`; `distributionApproved=false` and `worldwideDistributionApproved=false` prohibit treating this as worldwide approval. The files remain outside the production Apple asset catalog, while the runtime catalog contains verified byte copies mapped to the canonical asset keys.

## Evidence manifests

- `local-evidence.v2.json` is current. It records 78/78 source matches, local hashes and dimensions, `artworkStatus=final`, `candidateOnly=false`, `finalAsset=true`, `distributionApprovedForDeclaredTerritories=true`, the exact `US/GB/ES` allowlist and worldwide=false.
- `local-evidence.v1.json` is immutable historical evidence for the first three controlled candidate downloads: The Star, The Moon and The Sun. Its provisional wording describes that earlier snapshot only.
- `sync-candidate-rws.ps1` is a re-entrant integrity synchronizer. It verifies the exact release decision in `provenance.v2.json`, never replaces a mismatched existing file, and writes v2 only after all 78 files pass. An incomplete or inconsistent run exits without replacing the valid manifest.

Do not overwrite or edit these JPEGs. Any crop, recoloring, restoration, compression, border change or other derivative requires a new filename, provenance and rights review. Any new storefront requires its own evidence and an explicit allowlist update; never expand the current decision implicitly.
