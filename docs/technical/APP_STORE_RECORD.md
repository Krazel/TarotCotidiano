# App Store Connect — Tarot Deck

Actualizado: 2026-08-18
Estado: candidata pública `1.0 (1)` aprobada para preparación. Swift tests y builds iPhone sin firma pasaron en macOS; aún no se ha creado/subido el archive público firmado, seleccionado una build ni enviado a App Review.

## Identidad verificada

| Campo | Valor |
|---|---|
| Plataforma | iOS, solo iPhone |
| App Store name EN | `Tarot Deck: Read & Learn` |
| App Store name ES | `Tarot Deck: Lee y aprende` |
| Display name EN | `Tarot Deck` |
| Display name ES | `Mazo de tarot` |
| Bundle ID | `com.krazel.tarotdeck` |
| SKU | `tarot-deck-ios` |
| Apple ID | `6800144105` |
| Primary language | English (U.S.) |
| Additional localization | Spanish (Spain) |
| Category | Lifestyle; Reference secondary |
| Price | Free |
| Release | Manual |
| Minimum OS | iOS 16.0 |
| Current source version | `1.0 (1)` |
| First public train | `1.0`; source RC prepared, no build selected |
| Latest delivered TestFlight | `0.8 (1)`, `VALID`, `INTERNAL_ONLY`, group `Testers` |
| Login | None |
| IAP / subscriptions | Seven equivalent monthly supporter subscriptions; live prices; no gated functionality |
| Advertising / analytics / tracking | None |

The App Store names remain editable while the record state permits it. Bundle ID, SKU and Apple ID must not be replaced.

## Public metadata — English (U.S.)

### Name

`Tarot Deck: Read & Learn`

### Subtitle

`Your deck, always with you`

### Description

```text
Carry a complete 78-card tarot deck on your iPhone and read at your own pace.

READ YOUR WAY
• Choose one card, five three-card styles, or Six-Card Guidance.
• Create and save your own spreads with 1 to 12 cards.
• Shuffle, place, and reveal each card yourself.
• Open any revealed card to see its Meaning and how it can work In a Reading.

LEARN THE METHODS
Follow eight concise tutorials for the included readings and for building your own spread. Each tutorial explains what every position represents and how to work through the cards.

EXPLORE ALL 78 CARDS
Browse Major and Minor Arcana, open each card one by one, and save favorites for quick reference.

Tarot Deck works offline, stores your choices and readings only on your device, and is available in English and Spanish.
```

### Keywords

`tarot,cards,spreads,meanings,learn,arcana,reading,favorites,offline,custom`

Promotional Text and Marketing URL remain empty.

## Metadata pública — Spanish (Spain)

### Nombre

`Tarot Deck: Lee y aprende`

### Subtítulo

`Tu mazo, siempre contigo`

### Descripción

```text
Lleva un mazo de tarot completo de 78 cartas en tu iPhone y lee a tu propio ritmo.

LEE A TU MANERA
• Elige una carta, cinco estilos de tres cartas u Orientación en seis cartas.
• Crea y guarda tus propias tiradas de 1 a 12 cartas.
• Baraja, coloca y revela cada carta tú mismo.
• Abre cualquier carta revelada para consultar su Significado y cómo puede funcionar En una tirada.

APRENDE LOS MÉTODOS
Sigue ocho tutoriales breves para las tiradas incluidas y para crear la tuya. Cada tutorial explica qué representa cada posición y cómo trabajar con las cartas.

EXPLORA LAS 78 CARTAS
Recorre los Arcanos Mayores y Menores, abre cada carta una a una y guarda favoritas para consultarlas rápidamente.

Mazo de tarot funciona sin conexión, guarda tus elecciones y lecturas solo en tu dispositivo y está disponible en inglés y castellano.
```

### Palabras clave

`tarot,cartas,tiradas,significados,aprender,arcanos,lectura,favoritas,sin conexión`

El texto promocional y la URL de marketing permanecen vacíos.

## URLs y destinos dentro de la app

| Uso | URL / comportamiento | Estado local |
|---|---|---|
| Privacy Policy | `https://krazel.github.io/tarot-deck/privacy/` | Publicada desde commit `90d0752`; HTTP 200 verificado el 2026-08-18; incluye datos locales y tratamiento StoreKit. |
| Support | `https://krazel.github.io/tarot-deck/support/` | Publicada desde commit `90d0752`; HTTP 200 verificado el 2026-08-18; incluye siete niveles equivalentes, restauración y gestión/cancelación de Apple. |
| Rate the App | `https://apps.apple.com/app/id6800144105?action=write-review` | La fila usa el enlace oficial persistente y no un prompt directo. El destino devolvió 404 el 2026-08-18 mientras la ficha no es pública; revalidarlo cuando la app esté disponible. |
| Marketing URL | Vacío | Opcional y no necesario. |
| Terms / EULA | Apple Standard EULA | Linked directly before purchase and from Support the App. |

## App Privacy y datos

`Data Not Collected / No se recopilan datos` continúa siendo la respuesta exacta para los datos recogidos por el desarrollador:

- no cuenta, backend, red propia, analítica, anuncios, tracking ni SDK de terceros;
- no permisos protegidos;
- idioma, selección de tirada, sesión, continuidad, favoritos, tiradas personalizadas y borrador se guardan solo en el dispositivo;
- StoreKit transmite a Apple únicamente las solicitudes necesarias para cargar productos, comprar, verificar y restaurar; el desarrollador no recibe datos de tarjeta ni contenido de tarot;
- tocar Privacy, Support, Terms, Manage Subscription o Rate abre un destino por decisión del usuario; la app no adjunta ni transmite datos propios.

La política pública debe enumerar todos los datos locales anteriores. Evidencia: `docs/technical/PRIVACY_DATA_INVENTORY.md` y `PrivacyInfo.xcprivacy`.

## Rights, territorios y DSA

- Las 78 caras son finales y la evidencia local permite preparar solo `US`, `GB` y `ES`.
- `worldwideDistributionApproved=false`; no seleccionar otros storefronts.
- Card back, icon and programmatic backgrounds have separate project provenance.
- Content Rights has not been attested in App Store Connect in this task.
- Spain is an EU territory. App Store Connect currently identifies the developer as trader; the required DSA information must be confirmed truthfully before enabling `ES`. The private review contact remains separate from public trader information.

Evidence: `docs/technical/CONTENT_RIGHTS_AUDIT.md`, `native-ios/Content/provenance.v2.json`, `native-ios/Content/CandidateRWS/local-evidence.v2.json`, and `native-ios/Content/release-asset-provenance.v1.json`.

## Other compliance

- Age rating: current prepared result `13+`; recheck against the exact public RC.
- Encryption: `ITSAppUsesNonExemptEncryption=NO`; verify in the signed archive.
- Accessibility: only claim features manually proven on the RC. Dark Interface is the current conservative draft.
- Copyright and App Review contact: required private values stay in App Store Connect and are not copied to this public repository.
- Supporter subscriptions: seven monthly products in one service-equivalent group. The app remains fully free; every level grants only verified supporter status and a thank-you. Products must be configured, localized and priced in App Store Connect, then included with the first build submitted for review.

## Review Notes — prepared English draft

```text
Tarot Deck requires no account or sign-in and is fully usable offline.

To review the main flow:
1. Open Read and use the small selector to choose One Card, Three Cards, Six Cards, or Custom.
2. Tap the deck to start a reading, tap the deck or an empty position to place cards, and tap a face-down card to reveal it.
3. Tap a revealed card to open its Meaning and In a Reading reference.
4. Open Learn to browse eight reading tutorials.
5. Open Cards to browse all 78 cards and save favorites.
6. Open Settings for language, Support the App, Rate the App, Privacy, and Support.
7. In Support the App, verify seven monthly choices with live prices, the free-app disclosure, Restore Purchases, Manage Subscription, Privacy, and Terms.

Custom spread names, optional position labels, readings, favorites, and language choice remain only on the device. Optional monthly support is processed by Apple through StoreKit; all levels provide the same supporter status and unlock no functionality. The app has no ads, analytics, tracking, third-party SDKs, protected-data permissions, accounts, or cloud sync.

Privacy is available from Settings and at https://krazel.github.io/tarot-deck/privacy/.
```

Review contact details remain private and must be checked in App Store Connect against the exact submission.

## Remaining public-release gates

Before `1.0 (1)` can be selected or submitted:

1. Run the public RC workflow on macOS after the separate red upload authorization: Release archive, distribution signature, privacy manifest, localization and `US/GB/ES` ReleaseGate must all pass. Core and unsigned iPhone QA already passed for commit `0ed6cca7a31b3e6d3d935ec9e9d277c700a18386` in runs `32172356174` and `32172373006`.
2. Record the processed App Store Connect build ID and verify `1.0 (1)` is `VALID`; do not reuse Internal Only `0.8`.
3. Capture real `1.0 (1)` build screenshots in EN-US and ES-ES for Home/selector, a three-card reading, six/custom, Learn, and Cards/detail/favorites. Concept masters are art direction only.
4. Complete the truthful DSA trader/non-trader declaration required for Spain; if it is not complete, omit `ES` and do not claim the three-territory release is ready.
5. Verify all seven monthly products have complete EN/ES localization, availability, live prices, review screenshots and an App Store Connect state eligible to accompany the first app version.
6. Recheck Content Rights, age rating, encryption, accessibility claims, private review contact, metadata, screenshots and Review Notes against the processed binary.

No upload, build selection, territory mutation, DSA attestation, agreement acceptance, review submission or publication was performed while preparing this record.
