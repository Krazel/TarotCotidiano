# Estado de Tarot Deck

Actualizado: 2026-08-11

## Estado ejecutivo

El producto es un **mazo digital de tarot y referencia de aprendizaje para iPhone**, en inglés y castellano, separado por completo de Zodiac/Horoscope. El MVP permite hacer tiradas libres o con posiciones explícitas, consultar el significado de una carta revelada, aprender cómo leer el tarot y recorrer las 78 cartas. No genera interpretaciones automáticas, predicciones ni carta diaria.

Fase actual: **MVP interno `0.2 (1)` compilado y verificado como IPA Local-QA para iOS 16**. Read usa un carrusel visual horizontal de cinco presets, A-034 aporta ocho tutoriales bilingües y AppIcon D está compilado. Los cinco validadores, 24 pruebas Swift y el build Xcode pasan.

La regla global A-022 añade planificación de Settings, apoyo mensual voluntario y reseña separada sin bloquear el uso gratuito ni autorizar todavía productos StoreKit, precios, contratos o review.

A-023 hace obligatoria la skill `ios-app-launch` para lanzamiento, StoreKit, privacidad, soporte, firma y assets de tienda. Se ha aplicado a la planificación: V-027 usa niveles equivalentes y copy sin lenguaje de donación. No existen aún productos, secretos, subida, review ni publicación autorizados. Slug legal provisional recomendado: `tarot-deck`; páginas objetivo futuras: `https://krazel.github.io/tarot-deck/privacy/` y `https://krazel.github.io/tarot-deck/support/`, todavía no verificadas como publicadas.

Implementación visual final: **abierta para toda pantalla que tenga imagen completa creada y registrada bajo A-021**. Implementación estructural no visual: abierta por A-016.

Propietaria activa de implementación: **ninguna**. A-033, A-034, AppIcon D y la IPA Local-QA `0.2 (1)` quedaron cerrados y verificados.

A-031 fue ordenada explícitamente por el propietario el 2026-08-10. V-044–V-048 existen y quedaron aprobadas automáticamente por A-021: Home compacto, Settings con selector `English / Español`, mesa con mazo táctil, tres cartas face-down centradas y storyboard profesional `press → cut → interleave → deal → flip`. V-046/V-047 fueron corregidas el mismo día para compartir etiquetas, centro horizontal y un único anclaje vertical estable.

A-033 fue ordenada y corregida explícitamente por el propietario el 2026-08-11. V-054/V-055 sustituyen V-049–V-051: Home usa un carrusel visual de cinco fichas ilustradas, nunca un desplegable o lista vertical. V-052/V-053 y V-056/V-057 cubren el estado completo de Three Cards y One Card con reset/otra lectura. V-014, V-028, V-039, V-040 y V-044 quedan como referencias históricas allí donde A-033 las sustituye.

Revisión de derechos de 2026-08-10: las 78 reproducciones históricas Rider-Waite-Smith siguen autorizadas solo como candidatos internos. España conserva una regla transitoria que remite al plazo de 80 años para autores fallecidos antes del 7 de diciembre de 1987; por prudencia, no se tratarán como distribuibles en España ni en un lanzamiento mundial hasta obtener revisión jurídica territorial o sustituirlas por arte propio. Settings puede avanzar porque no depende de distribuir esas imágenes.

A-034 fue ordenada e integrada el 2026-08-11. La investigación confirmó que no existe una única lectura “oficial”: Waite y otros manuales históricos describen varios métodos. Learn contiene ocho tutoriales prácticos y bilingües. El tutorial de sí/no usa tres posiciones transparentes —qué favorece el sí, qué favorece el no o la pausa y qué considerar— dentro de `Open Three Cards`; no añade un sexto preset ni un veredicto automático. Las exploraciones visuales de carrusel de seis fichas se conservan como no seleccionadas y no autorizan implementación.

La pausa global terminó el 2026-08-10. Antes de reanudar se verificó que el arnés P1 antiguo seguía intacto, sin una corrección de código parcial que reconciliar. V-037/V-038 quedaron registradas como sustitutas de V-033/V-034 antes de reabrir UI.

## Hechos verificados

- Repositorio local: `C:\Users\dmkra\Documents\Codex Apps\TarotCotidianoNative`.
- Rama: `main`; `origin/main` contiene `602b9d1c235082c1533bd83036acc7b35cea7f88`, fuente exacta de la IPA formal `0.2 (1)` para iOS 16.
- Remoto público por A-026: `https://github.com/Krazel/TarotCotidiano.git`.
- Acceso GitHub central verificado el 2026-08-10 mediante el comprobador común: `status=OK`, login global `Krazel` desde el llavero de Windows, repo público, `origin` correcto y ambos workflows activos. Actions se opera solo con `gh`; no se usa Chrome ni autenticación por proyecto.
- El prototipo preservado sigue siendo Expo 53 / React Native 0.79.6 / React 19.
- `App.js` y `data/tarot.js` no se han modificado durante la redefinición.
- La fuente existente contiene 12 categorías y 36 cartas reflexivas en español. No representa un tarot estándar de Arcanos Mayores y Menores.
- SwiftUI para iPhone sigue aprobado. El núcleo y el flujo MVP completo compilan con Xcode 26.6 para `iphoneos` arm64; faltan capturas y comparación visual en macOS.
- Zodiac Daily ya tiene ficha propia de Brain y una ruta de proyecto separada propuesta; no pertenece a este repositorio.

## Entregables actuales

### Producto

- `docs/product/PRODUCT_BRIEF.md`: promesa, usuario, bucle, MVP, exclusiones, modelo y diferenciación del mazo digital.
- `docs/product/SCREEN_MAP.md`: estados `S00`–`S04`, transiciones, persistencia, errores y recorridos críticos.
- `docs/product/LEGACY_DAILY_REFLECTION_2026-08-08.md`: definición anterior preservada como referencia histórica.

### Diseño

- `design/TAROT_DECK_VISUAL_BRIEF.md`: frontera visual, herencia de Ceremonial Obsidian y primera pantalla nueva que necesita imagen.
- `design/CONCEPTS.md`, `design/APPROVALS.md` y `design/concepts/`: trabajo de Daily Tarot preservado. Sus imágenes no aprueban pantallas del nuevo producto.
- Primera referencia nueva prevista: `S03.2 Reading Table — Three Cards / shuffled / no card drawn`.
- Propuesta provisional V-005 creada: `design/tarot-deck/reading-table-three-cards-shuffled-a-ceremonial-obsidian.png`, 863×1823, SHA-256 `2469CA34B3BEC37AD56E5D3E46891EE3CDE0252BEFB0212F24AE1B6002996F68`.
- Propuesta provisional V-006 creada a petición del propietario: `design/tarot-deck/reading-table-three-cards-shuffled-landscape-a-ceremonial-obsidian.png`, 1844×853, SHA-256 `5F4E1ED763806AC3CD436B0DE8D0B70AE5CD24A58E569BDCB4A170452692D553`.
- V-005 y V-006 quedaron aprobadas conjuntamente por A-017 como referencias responsivas del mismo estado.
- V-007 y V-008 quedaron aprobadas por A-018 para S03.3.
- Asset derivado del reverso aprobado: `design/assets/ceremonial-card-back-v1.png`, 1024×1536, SHA-256 `8F3329F2949B6052B4684B50DB21745FFA3956C4868BB7777F7C3B9735DCC00C`.
- `design/tarot-deck/app-icon-concepts/` conserva A — The Card y D/E/F con exactamente tres cartas. C — The Deck queda descartado porque mostraba cuatro siluetas. D — Three-Card Fan fue aprobado e instalado como AppIcon por A-035.
- A-035 integra D — Three-Card Fan como AppIcon: master y catálogo 1024×1024 RGB opaco sRGB, SHA-256 `FFB38A413D8A99433A7A13E8626143A4FED96AD41AAB774D5D2C520C20BE200E`; A y las demás variantes permanecen preservadas.

### Técnica

- `docs/technical/TAROT_DECK_AUDIT.md`: SwiftUI sigue siendo viable; recomienda proyecto aislado en `native-ios/`, motor puro de mazo, contenido local, una sesión persistida y cero dependencias de runtime externas.
- `docs/technical/IOS_RESTART_AUDIT.md`: auditoría anterior preservada como referencia.
- `native-ios/Package.swift` y `native-ios/Sources/TarotDeckCore/`: núcleo Foundation sin SwiftUI/UIKit ni dependencias externas.
- `native-ios/Tests/TarotDeckCoreTests/`: 24 pruebas declaradas para reglas, persistencia, concurrencia, rollback y recuperación.
- `native-ios/Content/`: 78 cartas canónicas, 78 registros de procedencia y 78/78 JPEG candidatos locales verificados por URL, SHA-1, SHA-256, bytes, JPEG y dimensiones. No hay parciales ni faltantes. Todos siguen fuera de producción: `candidateOnly=true`, `finalAsset=false`, `distributionApproved=false` y revisión territorial pendiente.
- `.github/workflows/tarot-core.yml`: CI macOS de solo lectura, sin firma, secretos, publicación ni despliegue.
- `.github/workflows/tarot-local-qa-ipa.yml`: workflow manual público y sin secretos para compilar Debug `iphoneos`, exigir `MinimumOSVersion=16.0`, validar arm64 sin firma y empaquetar exactamente `Payload/TarotDeckInternal.app`. La ejecución CI `12` / run `31443312685` completó correctamente el 2026-08-11 sobre `602b9d1`; artefacto `9083642098`, disponible hasta el 2026-08-13 23:42 UTC. `run_number` es solo evidencia y el binario conserva `0.2 (1)`.
- `docs/technical/LOCAL_QA_IPA.md`: guía verificada para descargar, comprobar y volver a firmar el IPA con Sideloadly o AltStore en Windows. El paquete permanece `INTERNAL ONLY` por el arte RWS provisional.
- Validación local en Windows superada: manifiesto 78/22/56, cuatro palos, evidencia 78/78, IDs Swift/JSON idénticos, núcleo sin UI/red y prototipo Expo intacto.
- Verificación macOS iOS 16 superada: 24 pruebas Swift, build Debug para iPhone físico, ejecutable arm64, `MinimumOSVersion=16.0`, ausencia de firma y paquete IPA `Payload` exacto.
- IPA bilingüe A-031 iOS 16 histórica y **sustituida por A-032**: `C:\Users\dmkra\Documents\Codex Apps\TarotCotidianoNative-LocalQA\run-31427009585\contents\TarotDeck-0.0.1-1-local-qa-unsigned.ipa`, SHA-256 `8fe68def507c263051e5be4caf223f481808cea856d362b253e6b2c58f3024f9`. Se preserva como evidencia, pero no cumple la primera línea formal `0.1 (1)` ni el nombre/manifiesto con CI run y no debe entregarse como vigente.
- IPA formal vigente iOS 16: `C:\Users\dmkra\Documents\Codex Apps\TarotCotidianoNative-LocalQA\run-31443312685\contents\TarotDeck-0.2-1-ci12-602b9d1c2350-Local-QA-unsigned.ipa`, 74,151,905 bytes, SHA-256 `8d8d9eccd086d8ef03543fc155a3a0ee0c9cf4484f33dde5b6053ddb31b9a0cf`. Nombre, manifiesto y `.sha256` coinciden; confirma `0.2 (1)`, `iphoneos`, mínimo `16.0`, Mach-O arm64, AppIcon D compilado y ausencia de `_CodeSignature` y `embedded.mobileprovision`.
- Los IPA locales anteriores, incluido `run-31414355150`, quedan preservados como históricos y sustituidos para las pruebas del propietario.
- `native-ios/Content/Education/` contiene 78 significados upright-only, 78 descripciones visuales originales y ocho tutoriales prácticos; su validador confirma IDs/nombres/orden 78/78, unicidad, estructura de cuatro secciones, cinco mappings de preset y el método contextual de sí/no.
- `native-ios/Content/Localization/` contiene 78 nombres, 78 significados, 78 descripciones accesibles y los ocho tutoriales en castellano, validados contra los IDs y mappings ingleses. `MEANING_METHODOLOGY.md` documenta que el copy de cartas es original y moderno; `THREE_CARD_SPREADS.md` distingue tradición documentada, práctica moderna y adaptación editorial.

### Implementación visual aprobada

- `native-ios/TarotDeckApp/` contiene la shell `Read / Learn / Cards`, Home con carrusel directo de cinco presets, One Card y Three Cards completos, significados de cartas reveladas, ocho tutoriales con `Try This Reading`, biblioteca 78, filtros y anterior/siguiente sin wrap.
- Settings S09.1 está integrado desde el engranaje de Read en Home vacío o activo, conserva exactamente la lectura y contiene cinco filas con feedback interno honesto. No importa StoreKit, no inventa precios, productos, URLs ni resultados de restauración, y toma la versión del bundle con fallback `0.1`.
- `ReadFlowModel` representa la `DeckSession` real, exige exactamente los 78 IDs canónicos y usa dos JSON atómicos —sesión y continuidad— con write-ahead/reconciliación. Restore, errores, replace y end solo publican estados persistidos; no quedan callbacks activos vacíos ni exposición de identidad face-down.
- CTA Learn abre Three Cards realmente: reanuda Three activa, abre Three nueva sin sesión y protege una One activa mediante confirmación de reemplazo.
- El catálogo runtime contiene exactamente 79 image sets: 78 caras canónicas y `ceremonial-card-back`. No quedan placeholders ni el duplicado histórico `rws-the-moon`.
- `native-ios/TarotDeck.xcodeproj` contiene el target interno `TarotDeckInternal`: iPhone/iOS 16+, portrait y landscape, paquete local `TarotDeckCore`, sin firma, icono final, archive de producción ni dependencias externas. La bajada desde iOS 17 fue solicitada por el propietario, la auditoría estática no encontró APIs exclusivas de iOS 17 y el build Xcode/macOS confirmó `MinimumOSVersion=16.0`.
- Integra `ceremonial-card-back` como asset independiente con el mismo SHA-256 que el master de diseño.
- Incluye controles semánticos, targets de 44 puntos, descripciones visuales, posiciones neutrales, Dynamic Type adaptativo y estado S00 no interactivo durante restauración.
- Tres pasadas de revisión estática cerraron los P1/P2 de restauración, persistencia, botones muertos, CTA y accesibilidad con resultado final **PASS**. Compilación SwiftUI, XCTest y empaquetado iOS 16 están verdes; previews y comparación de capturas siguen pendientes.
- A-027/A-028 están integradas localmente: en primera instalación iOS elige inglés o castellano y A-031 añade un selector interno persistente `English / Español`; una lectura de tres cartas ofrece `Past · Present · Future`, `Situation · Challenge · Advice`, `You · The other person · Connection` u opción abierta; idioma y preset no alteran IDs ni orden. A-033 conserva esas opciones pero sustituye las pantallas de selección por un selector inline antes de tocar el mazo.
- V-039 registra la selección de tirada en castellano y V-040 sustituye las proporciones anteriores de Three Cards landscape con rail compacto y cartas ocupando casi toda la altura disponible.
- V-041 y `design/tarot-deck/MOTION_SPEC.md` registran el storyboard y contrato de movimiento. La implementación iOS 16 añade transiciones breves, shuffle, draw, giro reveal/conceal, respuesta táctil de botones y haptics solo después de un estado durable. Reduce Motion y VoiceOver usan variantes de opacidad; restaurar, rotar o volver de segundo plano no reproduce efectos.
- La revisión final independiente de motion cerró sin P0–P2: comprobó compatibilidad estática iOS 16, foco VoiceOver post-commit, supresión de replay/haptics en background, privacidad face-down, PBX y contratos del validador.
- A-030 está integrada mediante un único `FavoriteCardsStore` compartido por Read y Cards. Guarda solo `cardID` canónicos en `favorites.v1.json`, con JSON atómico y directorio excluido de backup; el filtro `Favorites/Favoritas`, su estado vacío y el corazón del detalle siguen V-042/V-043. La revisión independiente cerró sin P0–P2.
- A-031 está integrada localmente: selector `English / Español` atómico sobre 215 claves de interfaz, Home V-044 sin scroll normal y con adaptación AX, Settings V-045, mesa V-046/V-047 con centro horizontal y anclaje vertical estable, mazo como único control contextual, tab bar opaca, encabezado `Upright meaning / Significado al derecho` y motion V-048 con reparto curvo, flip de dos caras, cancelación y haptics posteriores al aterrizaje. La revisión independiente final cerró sin P0–P2.
- Los validadores locales de mazo, educación inglesa, localización española, integración y workflow IPA pasan. GitHub Actions verificó además las pruebas Swift, la compilación completa para iPhone/iOS 16 y el IPA formal `0.1 (1)` exacto del commit `ae0838c`.

## Qué se conserva y qué queda fuera

Se conserva intacto el prototipo Expo, las 36 cartas, la exploración visual y el historial de decisiones. Sirven como referencia conceptual, estética y recuperable.

Quedan fuera del MVP de Tarot: carta diaria automática, categorías reflexivas, mensajes y preguntas, recordatorios, historial de tiradas, notas, compartir, feed, horóscopo, Zodiac, IA, interpretaciones automáticas, cuentas, red, pagos, Android y lenguas distintas de inglés/castellano.

## Decisión material resuelta

**P-004 — modelo canónico del mazo**, cerrada por A-015.

El MVP usa un tarot estándar completo de **78 cartas** —22 Arcanos Mayores y 56 Menores—, solo en orientación normal. La primera versión puede usar las imágenes históricas originales Rider–Waite–Smith de dominio público y debe evitar ediciones comerciales modernas o modificaciones con derechos propios. Las 36 cartas reflexivas antiguas se conservan, pero no se presentan como el mazo de producción.

Motivo: “un mazo de tarot en el móvil” promete el equivalente reconocible de un mazo físico. Usar 36 cartas temáticas convertiría el producto en una baraja oráculo y cambiaría su promesa.

El modelo y los identificadores deben permitir sustituir en el futuro cada imagen histórica por arte propio sin reescribir el motor ni perder compatibilidad.

## Bloqueos y puertas

1. **Cerrado:** `0.2 (1)` fue compilado en macOS/Xcode y verificado como IPA Local-QA; los cinco validadores y 24 pruebas pasan.
2. Resolver revisión territorial y aprobación de distribución del arte antes de cualquier release. El gate release falla intencionalmente solo por `candidateOnly/finalAsset/distributionApproved/territorial`.
3. El propietario aprobó `com.krazel.tarotdeck`, nombre provisional `Tarot Deck`, SKU `tarot-deck-ios`, English (U.S.) principal y español adicional. El intento de registro no se completó porque caducó la sesión de Apple Developer; queda pendiente volver a iniciar sesión en Chrome. No hay firma ni build de distribución.
4. Settings S09.1 está integrado; StoreKit, productos, precios reales, páginas legales publicadas, secretos, firma de distribución, subida y publicación siguen sin autorización. La autorización actual alcanza solo el registro del App ID y la creación de la ficha iOS, no acuerdos, productos, builds ni review.

La procedencia del arte debe quedar documentada antes de tratar cualquier cara como asset de producción. El historial de distribución y el bundle identifier se resuelven antes de firma o release; no bloquean el diseño conceptual.

## Siguiente acción automática

Siguiente punto exacto: el propietario debe volver a iniciar sesión en Apple Developer dentro de Chrome; después se registrará `com.krazel.tarotdeck` y se creará la ficha iOS `Tarot Deck` con English (U.S.) principal y español adicional. No tratar los 78 candidatos históricos como arte distribuible; el gate de release sigue bloqueado hasta cerrar derechos.

No aumentar límites de gasto, añadir métodos de pago, usar TestFlight, App Store ni publicar sin autorización expresa separada.
