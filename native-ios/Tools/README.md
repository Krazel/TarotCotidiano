# Native iOS internal tools

## Synchronize the verified final card faces

Run after `Content/CandidateRWS/local-evidence.v2.json` is safely regenerated:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File native-ios/Tools/sync-verified-candidate-assets.ps1
```

The synchronizer requires the complete final state: 78/78 integrity-verified records, `candidateOnly=false`, `finalAsset=true`, approval only for the exact `US/GB/ES` allowlist and `worldwideDistributionApproved=false`. It verifies each local SHA-1 before copying the file to its canonical asset-catalog image set. It does not grant rights, alter the territorial decision or remove other valid assets.

After syncing, validate the current snapshot:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File native-ios/Tools/validate-app-integration.ps1
```

The default validator checks code, content, localization and the complete final artwork snapshot. Internal TestFlight remains explicitly internal-only. A territory-aware public preflight must name the intended storefronts:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File native-ios/Tools/validate-app-integration.ps1 -ReleaseGate -RequestedTerritories US,GB,ES
```

The release gate accepts only storefronts within the recorded allowlist and rejects worldwide or implicit expansion. Passing it is local evidence, not upload, App Review submission or publication authority.
