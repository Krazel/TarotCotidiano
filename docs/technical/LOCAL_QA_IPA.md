# Tarot Deck local QA IPA

## Purpose and boundary

This path produces an **unsigned Debug IPA for local testing on one iPhone**. It is not a TestFlight build, an App Store build, a release, or a distributable copy.

> **INTERNAL ONLY — final Rider–Waite–Smith faces cleared only for US/GB/ES storefront preparation — not for redistribution.**

The IPA cannot be installed directly. Sideloadly or AltStore must re-sign it with the tester's Apple ID before iOS can install it. No Apple credentials, certificates, profiles, signing keys, or other secrets enter GitHub Actions.

Current build facts:

- project: `native-ios/TarotDeck.xcodeproj`;
- shared scheme: `TarotDeckInternal`;
- configuration: `Debug`;
- platform: generic physical iPhone (`iphoneos`), never Simulator;
- minimum system: iOS 16.0;
- provisional bundle identifier: `com.krazel.tarotdeck.internal.provisional`;
- formal marketing version/build: `1.0 (1)`;
- the CI run number is evidence only; it does not replace `CURRENT_PROJECT_VERSION`;
- signing in CI: disabled.

Debug remains intentional for this unsigned Local-QA path. The real `TarotDeckMainShell` and `ReadRootView` now compile in both Debug and Release; Local-QA still uses only the provisional Debug bundle identity and never gains signing or upload capability.

## Manual workflow

Workflow: `.github/workflows/tarot-local-qa-ipa.yml`.

It runs only through `workflow_dispatch`. After an authorized commit places it on the repository's default branch and GitHub Actions is enabled:

1. Open the public `Krazel/TarotCotidiano` repository on GitHub.
2. Open **Actions** → **Tarot local QA unsigned IPA**.
3. Choose **Run workflow**. There are no inputs, secrets, signing options, or upload switches.
4. Wait for the `INTERNAL ONLY - unsigned device IPA` job to finish.
5. Download the Actions artifact named like `TarotDeck-1.0-1-ci<run>-<short-commit>-Local-QA-unsigned` before its short retention window ends.

The job validates the 78-card content, English education content and integrated app, runs the Swift tests, and builds the shared scheme for generic `iphoneos` with code signing disabled. It rejects a Simulator executable, a missing executable or `Info.plist`, an unexpected signature, and any IPA entry outside the exact app payload.

The downloaded artifact contains exactly three files:

- `TarotDeck-<version>-<build>-ci<run>-<short-commit>-Local-QA-unsigned.ipa`;
- the matching `.sha256` checksum;
- the matching `.manifest.json` internal-build manifest.

The IPA itself contains only `Payload/TarotDeckInternal.app`. The checksum and manifest deliberately remain outside the IPA.

## Verify the download on Windows

1. Extract the GitHub artifact ZIP into a local folder.
2. In PowerShell, run:

   ```powershell
   Get-FileHash .\TarotDeck-1.0-1-ci<run>-<short-commit>-Local-QA-unsigned.ipa -Algorithm SHA256
   ```

3. Compare the reported hash with the first value in the adjacent `.sha256` file.
4. Open the `.manifest.json` and confirm `version` is `1.0`, `build` is `1`, `ciRunNumber` matches the workflow run, `purpose` is `Local-QA`, `configuration` is `Debug`, `platform` is `iphoneos`, `signed` is `false`, and the commit matches the workflow run.
5. Do not install or share the IPA if the hash differs or the internal-only notice is absent.

## Install with Sideloadly on Windows

Use the current Windows installer and instructions from [Sideloadly](https://sideloadly.io/). Its normal Windows setup requires the web versions of iTunes and iCloud. Uninstall the Microsoft Store versions before installing those required web versions, and follow the current Sideloadly page rather than an old cached installer guide.

1. Install Sideloadly and the Apple components it currently requires on Windows.
2. Connect the unlocked iPhone by USB. Accept **Trust This Computer** on the iPhone if prompted and make sure the device appears in the Apple device software and in Sideloadly.
3. If the iPhone requires it, open **Settings → Privacy & Security → Developer Mode**, enable it, restart when requested, and confirm after restart.
4. Open Sideloadly, select the connected iPhone, and drag the verified unsigned IPA into the app field.
5. Choose the normal **Apple ID Sideload** mode. Do not inject tweaks, change the minimum iOS version, or use an external signing profile for this QA pass.
6. Enter the Apple ID that will sign this local test copy and complete any Apple authentication prompt. Credentials are handled by the sideloading tool and Apple, never by this repository or workflow.
7. Start the sideload and wait for Sideloadly to report installation success.
8. If iOS reports an untrusted developer, open **Settings → General → VPN & Device Management** (the exact label can vary), choose the profile associated with that Apple ID, and trust it.
9. Launch **Tarot Deck** and test Read, Learn, Cards, Settings, orientation, VoiceOver, Dynamic Type and reading restoration.

The signing validity and refresh interval depend on the Apple account, profile and Apple's current policies. Check the validity shown by Sideloadly or iOS and re-sign/refresh before that date. Do not rely on a hard-coded duration in this repository.

Sideloadly's current official FAQ covers [Developer Mode and profile trust](https://sideloadly.io/faq), plus device-detection troubleshooting. If the device is not detected, re-check the cable, the computer trust prompt and the Apple desktop components before changing the IPA.

## AltStore alternative

AltStore Classic can also re-sign a local IPA. Follow the current official [AltStore Windows setup](https://faq.altstore.io/altstore-classic/how-to-install-altstore-windows): install its required Apple desktop components, run AltServer, pair and trust the iPhone, install AltStore, enable Developer Mode when required, then use AltStore's local IPA sideload action. AltStore PAL is a different distribution system and is not the path for this unsigned internal IPA.

Use the same Apple ID and unchanged bundle identifier when refreshing an existing local install if preserving that install's on-device reading state matters. Removing the app, changing its bundle identifier, or installing it as a different signed identity can remove or isolate its local data.

## Limitations and stop conditions

- The CI artifact is unsigned and cannot install without user-side signing.
- The build uses a provisional internal bundle identifier and is not a production identity.
- The 78 historical card faces are the owner-approved final visual set and integrity-verified. Their rights evidence is limited to US/GB/ES storefront preparation and does not approve worldwide distribution.
- The current source includes StoreKit purchase and restoration, but an unsigned sideloaded Local-QA build cannot prove production product loading, purchase or entitlement behavior. Verify those only in an authorized StoreKit sandbox/TestFlight/App Store context; public Privacy/Support/Terms and rating destinations remain separately user initiated.
- GitHub stores the artifact only for a short QA window. Repository access controls govern who can download it.
- Sideloading and Apple authentication happen outside this repository. Do not paste Apple credentials into GitHub, logs, issues or this documentation.
- The workflow performs no archive, export, notarization, TestFlight upload, App Store submission, release creation or external network upload beyond GitHub Actions artifact storage. Because the repository is public under A-026, treat the artifact and its territory-limited artwork as publicly exposed even though the IPA remains unsigned and marked `INTERNAL ONLY`.
- Building and installing the IPA does not authorize redistribution, publishing or submission.

If the physical-device build fails, preserve the log and fix only the compile or packaging problem. Do not add certificates, profiles, secrets, external upload steps or ReleaseGate bypasses to make it pass.
