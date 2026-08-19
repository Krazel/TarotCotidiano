# App Store Connect — Tarot Deck

Actualizado: 2026-08-19
Estado: candidata pública `1.0 (1)` subida, procesada y seleccionada. Metadatos EN/ES, ocho capturas, privacidad, soporte, derechos, siete suscripciones y su grupo están reunidos en un único borrador de nueve elementos. El envío final espera la revisión de Apple de la información DSA del comerciante.

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
| First public train | `1.0`; build `1.0 (1)` processed and selected |
| Latest delivered TestFlight | `1.0 (2)`, `VALID`, `INTERNAL_ONLY`, group `Testers`; runs `32199048236` / `32199365186` |
| Login | None |
| IAP / subscriptions | Seven equivalent monthly supporter subscriptions; live prices; no gated functionality |
| Advertising / analytics / tracking | None |

The App Store names remain editable while the record state permits it. Bundle ID, SKU and Apple ID must not be replaced.

## StoreKit production products

- Subscription group: `Tarot Deck Support`; App Store Connect resource `22318147`.
- Seven `ONE_MONTH` products use the immutable IDs in `store/tarot-subscriptions.v1.json` and one equivalent service level.
- Base Spain prices: `€0.99`, `€2.99`, `€4.99`, `€9.99`, `€14.99`, `€29.99`, and `€49.99`; Great Britain and United States use Apple's equalized official price points. The app itself displays only `Product.displayPrice`.
- Availability: all 175 current App Store countries or regions; future App Store regions are enabled for the subscriptions.
- English (U.S.) and Spanish (Spain) group/product localizations exist.
- Creation/completion run: `32178955952`. Idempotent verification runs: `32179199039` and `32179410198`; the latter reported zero mutation lines.
- Current Apple state for every product and the group: `Ready for Review / Listo para revisión`. Each product has EN/ES metadata and its private in-app review screenshot, and all eight subscription items are attached to the version `1.0` review draft.

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

## Rights, availability and DSA

- The owner has confirmed the current art as final and saved the required third-party Content Rights answer in App Store Connect.
- The app and all seven subscriptions are configured for all 175 current countries or regions; subscriptions automatically include future regions.
- App Store Connect identifies the developer as a trader. Apple received the required contact information on 2026-08-19 and currently shows the DSA verification as `En revisión`.
- The private App Review contact remains separate from the public trader information Apple is verifying.

## Other compliance

- Age rating: current prepared result `13+`; recheck against the exact public RC.
- Encryption: `ITSAppUsesNonExemptEncryption=NO`; verify in the signed archive.
- Accessibility: only claim features manually proven on the RC. Dark Interface is the current conservative draft.
- Copyright and App Review contact: required private values stay in App Store Connect and are not copied to this public repository.
- Supporter subscriptions: seven monthly products in one service-equivalent group. The app remains fully free; every level grants only verified supporter status and a thank-you. Products are configured, localized, priced and included with the first build's review draft.

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

## Remaining public-release gate

The complete nine-item draft contains app version `1.0 (1)`, all seven subscriptions and their subscription group. Build, signature, privacy manifest, localization, metadata, eight screenshots, private subscription screenshots, age rating, encryption, review contact, Content Rights, free/manual release, public Privacy/Support URLs and 175-country availability have been checked. Apple currently keeps the final submission action unavailable while the trader verification is `En revisión`.

When Apple enables the action, perform one final read-only preflight and obtain an immediate confirmation from the owner before clicking `Enviar a revisión`. Publication remains manual after approval.
