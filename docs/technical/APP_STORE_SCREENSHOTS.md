# App Store screenshots — Tarot Deck 1.0

Updated: 2026-08-19
Status: the proprietor approved the eight English exports from the supplied recording as the public submission set. Spanish will use App Store Connect's supported fallback to the primary English screenshots; a native Spanish set is an optional later quality improvement, not a submission gate.

## Supplied recording and candidate exports

The private original is preserved outside the public repository under `TarotCotidianoNative-StoreAssets/sources/1.0-1/`.

- source SHA-256: `1b67ee4afd1301587ad19d55762549a7b6997409f32f369c3c314b1f2fe27e3f`;
- duration: 65.02 seconds;
- source canvas: `384 × 848` portrait;
- source condition: WhatsApp-compressed screen recording, English UI;
- selected evidence: eight lossless raw frames;
- candidate exports: eight opaque RGB PNGs at the Apple-accepted `1260 × 2736` canvas;
- evidence manifest: `TarotCotidianoNative-StoreAssets/manifests/app-store-screenshots-1.0.1.json`.

The status/recording bar was removed from the derivatives; the untouched source frames and video remain available for verification. The exports are internally consistent and cover Home, selector, active reading, Meaning, Learn, tutorial detail, Cards and the custom editor. The proprietor explicitly accepted their messaging compression and approved them for submission. The represented UI remains present in `1.0`; the set deliberately does not show Settings or StoreKit, so the later supporter implementation does not make these frames inaccurate.

No Spanish screenshots were synthesized from English frames. App Store Connect may use the primary English screenshot set as the next-best-language fallback for the Spanish localization. A real Spanish set remains desirable but is not required for this submission plan.

## Can a screen recording be used?

Yes. A supplied video can be used to choose and extract clean frames if it shows the final build at sufficient resolution. Every submitted image must still be checked for sharpness, correct localization, safe areas, absence of notifications/personal data and an Apple-accepted final canvas.

Native screenshots from the device or simulator are preferred because video compression can soften small text. If only video is available, preserve the original file and do not send it through a messaging service that recompresses it.

## Recording checklist for the proprietor

- Use the final `1.0 (1)` build.
- Record once in English and once in Spanish, or change language and record both sets.
- Enable Do Not Disturb; hide notifications and personal overlays.
- Use a clean status bar and normal text size.
- Avoid showing Apple ID, email, debug menus or tester invitations.
- Hold each requested screen still for about two seconds after animations settle.
- Record portrait for most screens and landscape for the table where larger cards are important.
- Do not add music, narration, stickers, borders or captions to the source recording.

## Canonical delivery set

Use the eight approved portrait exports as opaque RGB PNGs with no alpha. They use the accepted 6.9-inch canvas `1260 × 2736`. Keep their source frames, timestamps and hashes in the private evidence directory.

### English (U.S.)

1. **Choose your reading** — Read Home with the compact selector open and One/Three/Six/Custom visible.
2. **Place every card yourself** — active three-card table with persistent deck and at least one face-down card placed.
3. **Reveal and understand** — revealed three-card reading plus a separate clean capture of the card Meaning detail; use the stronger of the two as the final third shot.
4. **Learn each method** — Learn foundations with Reading Tutorials visible, or a concise tutorial detail showing positions and steps.
5. **Explore all 78 cards** — Cards library with the horizontally scrollable filters visibly discoverable.
6. **Make it yours** — custom-spread editor or Six-Card Guidance, whichever is clearest and most polished in the final build.

### Spanish (Spain)

If a native Spanish set is added later, use the identical screen order and equivalent state:

1. **Elige tu tirada**.
2. **Coloca cada carta tú mismo**.
3. **Revela y consulta el significado**.
4. **Aprende cada método**.
5. **Explora las 78 cartas**.
6. **Crea tu propia tirada**.

For the first submission, leave the Spanish screenshot well without a separate localized set so App Store Connect can use the approved primary-language screenshots. Do not duplicate or relabel English pixels as Spanish.

## Landscape candidate

Capture one optional landscape table in both languages after the title has settled and the deck is on the physical right. Use it only if it materially demonstrates larger cards better than the portrait table. Landscape output must use the exact reverse of an accepted landscape canvas, for example `2868 × 1320` when paired with `1320 × 2868`.

## Selection rules

- Show the app in use, not a title-only composition.
- Use no concept art, generated mockup or unimplemented screen as the screenshot base.
- Do not show a fake purchase, unavailable supporter flow, reversed-card feature or network feature.
- Do not include price claims, rankings, reviews, competitor marks or unverifiable promises.
- The card identities shown face-up must match the actual runtime frame.
- English and Spanish screenshots must be internally consistent and free of mixed-language UI.
- The selected reading state must look intentional: no clipped title, overlapping cards, unfinished animation or transient orientation hint unless that hint is the subject of the shot.

## Evidence manifest per exported screenshot

Record:

- localization (`en-US` or `es-ES`);
- App Store device class and exact pixel canvas;
- portrait/landscape;
- source build `1.0 (1)`;
- source commit;
- source kind (`native screenshot` or `video frame`);
- source filename and SHA-256;
- video timestamp when applicable;
- export filename and SHA-256;
- screen/state represented;
- governing approved visual master ID where applicable;
- review date and reviewer.

Keep source frames separate from final exports. A crop, scale or captioned derivative never replaces the original evidence.

## Planned repository structure

```text
design/store-screenshots/
  sources/1.0-1/
  exports/en-US/iphone-6.9/
  exports/es-ES/iphone-6.9/
  manifests/app-store-screenshots-1.0.1.json
```

The source video itself should not be committed if it is large or contains status-bar/personal information. Store its hash and keep the private original outside the public repository.

`native-ios/Tools/extract-app-store-video-frame.ps1` extracts one lossless PNG at a chosen timestamp and writes a sidecar evidence JSON containing the source/video hash, frame hash, dimensions, localization, screen state and `1.0 (1)` identity. It deliberately does not crop, upscale or overwrite files; visual export remains a reviewed step.

## Final visual QA

- Exact accepted dimensions and opaque color space.
- No alpha, black accidental bars or mismatched rounded-corner masks.
- Text readable at App Store thumbnail and full-screen sizes.
- Status bar consistent across the set.
- No notification banner, recording control, touch indicator or TestFlight overlay.
- No mixed EN/ES strings.
- Real `1.0 (1)` UI matches the current approved screen masters.
- Screenshot count between 1 and 10 per device/localization.

Official specifications:

- https://developer.apple.com/help/app-store-connect/manage-app-information/upload-app-previews-and-screenshots
- https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/
