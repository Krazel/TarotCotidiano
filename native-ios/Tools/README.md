# Native iOS internal tools

## Sync verified provisional card faces

Run this after `Content/CandidateRWS/local-evidence.v2.json` changes and once more when the candidate download finishes:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File native-ios/Tools/sync-verified-candidate-assets.ps1
```

The synchronizer is deterministic and safe to repeat. It reads the v2 evidence snapshot, accepts only records whose source SHA-1, byte size and pixel dimensions are marked as matching, verifies the local SHA-1 again, and then copies those local files into their canonical `artworkAsset.imageset` directories in the existing app asset catalog. It updates only the matching generated image set and never removes another valid asset.

This is an internal bundling step, not a rights approval. It does not edit either provenance manifest and does not change `distributionApproved=false`, candidate status, territorial review status or final-art status.

After syncing, validate the current snapshot:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File native-ios/Tools/validate-app-integration.ps1
```

If the downloader updates the evidence between these two commands, rerun the synchronizer and validator. The project root should always rerun both commands after the downloader reaches its final 78-card snapshot.

The default validator deliberately accepts a partial internal artwork snapshot and prints both the provisional candidate count and the explicit placeholder count. It must not be treated as a release-art approval. The separate release gate is:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File native-ios/Tools/validate-app-integration.ps1 -ReleaseGate
```

That gate requires 78/78 records, zero evidence failures, final-asset status and distribution approval. It is expected to fail while the historical candidates remain non-production.
