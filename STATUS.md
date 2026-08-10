# Estado de Tarot Deck

Actualizado: 2026-08-10

## Estado ejecutivo

El producto es un **mazo digital de tarot y referencia de aprendizaje para iPhone**, en inglés y castellano, separado por completo de Zodiac/Horoscope. El MVP permite hacer tiradas libres o con posiciones explícitas, consultar el significado de una carta revelada, aprender cómo leer el tarot y recorrer las 78 cartas. No genera interpretaciones automáticas, predicciones ni carta diaria.

Fase actual: **MVP funcional Read / Learn / Cards / Settings en inglés/castellano, con presets de tres cartas, mesa landscape grande, movimiento profesional y favoritos locales; validadores, pruebas Swift, compilación iPhone/iOS 16 y nuevo IPA verificados; prueba física y comparación visual final pendientes**.

La regla global A-022 añade planificación de Settings, apoyo mensual voluntario y reseña separada sin bloquear el uso gratuito ni autorizar todavía productos StoreKit, precios, contratos o review.

A-023 hace obligatoria la skill `ios-app-launch` para lanzamiento, StoreKit, privacidad, soporte, firma y assets de tienda. Se ha aplicado a la planificación: V-027 usa niveles equivalentes y copy sin lenguaje de donación. No existen aún productos, secretos, subida, review ni publicación autorizados. Slug legal provisional recomendado: `tarot-deck`; páginas objetivo futuras: `https://krazel.github.io/tarot-deck/privacy/` y `https://krazel.github.io/tarot-deck/support/`, todavía no verificadas como publicadas.

Implementación visual final: **abierta para toda pantalla que tenga imagen completa creada y registrada bajo A-021**. Implementación estructural no visual: abierta por A-016.

Propietaria activa de implementación: **ninguna**. A-030 Favoritos ha quedado integrada localmente y revisada; cualquier nueva implementación deberá volver a declarar una única propietaria.

Revisión de derechos de 2026-08-10: las 78 reproducciones históricas Rider-Waite-Smith siguen autorizadas solo como candidatos internos. España conserva una regla transitoria que remite al plazo de 80 años para autores fallecidos antes del 7 de diciembre de 1987; por prudencia, no se tratarán como distribuibles en España ni en un lanzamiento mundial hasta obtener revisión jurídica territorial o sustituirlas por arte propio. Settings puede avanzar porque no depende de distribuir esas imágenes.

La pausa global terminó el 2026-08-10. Antes de reanudar se verificó que el arnés P1 antiguo seguía intacto, sin una corrección de código parcial que reconciliar. V-037/V-038 quedaron registradas como sustitutas de V-033/V-034 antes de reabrir UI.

## Hechos verificados

- Repositorio local: `C:\Users\dmkra\Documents\Codex Apps\TarotCotidianoNative`.
- Rama: `main`; build iOS 16 e IPA bilingüe verificados sobre `63c459e18e97c375c578e8ef653f1d3805f8ad5e` en `origin/main`.
- Remoto público por A-026: `https://github.com/Krazel/TarotCotidiano.git`.
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

### Técnica

- `docs/technical/TAROT_DECK_AUDIT.md`: SwiftUI sigue siendo viable; recomienda proyecto aislado en `native-ios/`, motor puro de mazo, contenido local, una sesión persistida y cero dependencias de runtime externas.
- `docs/technical/IOS_RESTART_AUDIT.md`: auditoría anterior preservada como referencia.
- `native-ios/Package.swift` y `native-ios/Sources/TarotDeckCore/`: núcleo Foundation sin SwiftUI/UIKit ni dependencias externas.
- `native-ios/Tests/TarotDeckCoreTests/`: 24 pruebas declaradas para reglas, persistencia, concurrencia, rollback y recuperación.
- `native-ios/Content/`: 78 cartas canónicas, 78 registros de procedencia y 78/78 JPEG candidatos locales verificados por URL, SHA-1, SHA-256, bytes, JPEG y dimensiones. No hay parciales ni faltantes. Todos siguen fuera de producción: `candidateOnly=true`, `finalAsset=false`, `distributionApproved=false` y revisión territorial pendiente.
- `.github/workflows/tarot-core.yml`: CI macOS de solo lectura, sin firma, secretos, publicación ni despliegue.
- `.github/workflows/tarot-local-qa-ipa.yml`: workflow manual público y sin secretos para compilar Debug `iphoneos`, exigir `MinimumOSVersion=16.0`, validar el binario arm64 sin firma y empaquetar exactamente `Payload/TarotDeckInternal.app` como IPA de QA. La ejecución `31414355150` completó correctamente el 2026-08-10 sobre `63c459e`; artefacto `9072856781`, disponible en GitHub hasta el 2026-08-13 17:31 UTC.
- `docs/technical/LOCAL_QA_IPA.md`: guía verificada para descargar, comprobar y volver a firmar el IPA con Sideloadly o AltStore en Windows. El paquete permanece `INTERNAL ONLY` por el arte RWS provisional.
- Validación local en Windows superada: manifiesto 78/22/56, cuatro palos, evidencia 78/78, IDs Swift/JSON idénticos, núcleo sin UI/red y prototipo Expo intacto.
- Verificación macOS iOS 16 superada: 24 pruebas Swift, build Debug para iPhone físico, ejecutable arm64, `MinimumOSVersion=16.0`, ausencia de firma y paquete IPA `Payload` exacto.
- IPA bilingüe iOS 16 verificado: `C:\Users\dmkra\Documents\Codex Apps\TarotCotidianoNative-LocalQA\run-31414355150\contents\TarotDeck-0.0.1-1-local-qa-unsigned.ipa`, 72,506,981 bytes, SHA-256 `4ba500683447eb16616aa01963a0d6069b688c27eeee0bd38b3dbbda0bbfdca8`. El hash coincide con `.sha256` y manifiesto; este confirma `iphoneos`, Debug, bundle provisional, mínimo `16.0`, commit exacto y ausencia de firma. El ZIP contiene exclusivamente `Payload/TarotDeckInternal.app`, con ejecutable e `Info.plist`, sin `_CodeSignature` ni `embedded.mobileprovision`. Requiere firma local con Sideloadly o AltStore y permanece `INTERNAL ONLY`.
- Los IPA locales anteriores de `run-31394351514` y `run-31348569722` quedan preservados como históricos y sustituidos para las pruebas del propietario.
- `native-ios/Content/Education/` contiene 78 significados upright-only, 78 descripciones visuales originales y seis artículos; su validador confirma IDs/nombres/orden 78/78, unicidad y English/ASCII.
- `native-ios/Content/Localization/` contiene 78 nombres, 78 significados, 78 descripciones accesibles y los seis artículos en castellano, validados uno a uno contra los IDs canónicos. `MEANING_METHODOLOGY.md` documenta que el copy es original y moderno, contrastado con la tradición RWS/Waite, no una cita ni una definición canónica única.

### Implementación visual aprobada

- `native-ios/TarotDeckApp/` contiene la shell `Read / Learn / Cards`, Home vacío/activo, Layout Choice, One Card y Three Cards completos, significados de cartas reveladas, seis artículos, biblioteca 78, filtros y anterior/siguiente sin wrap.
- Settings S09.1 está integrado desde el engranaje de Read en Home vacío o activo, conserva exactamente la lectura y contiene cinco filas con feedback interno honesto. No importa StoreKit, no inventa precios, productos, URLs ni resultados de restauración, y toma la versión del bundle con fallback `0.0.1`.
- `ReadFlowModel` representa la `DeckSession` real, exige exactamente los 78 IDs canónicos y usa dos JSON atómicos —sesión y continuidad— con write-ahead/reconciliación. Restore, errores, replace y end solo publican estados persistidos; no quedan callbacks activos vacíos ni exposición de identidad face-down.
- CTA Learn abre Three Cards realmente: reanuda Three activa, abre Three nueva sin sesión y protege una One activa mediante confirmación de reemplazo.
- El catálogo runtime contiene exactamente 79 image sets: 78 caras canónicas y `ceremonial-card-back`. No quedan placeholders ni el duplicado histórico `rws-the-moon`.
- `native-ios/TarotDeck.xcodeproj` contiene el target interno `TarotDeckInternal`: iPhone/iOS 16+, portrait y landscape, paquete local `TarotDeckCore`, sin firma, icono final, archive de producción ni dependencias externas. La bajada desde iOS 17 fue solicitada por el propietario, la auditoría estática no encontró APIs exclusivas de iOS 17 y el build Xcode/macOS confirmó `MinimumOSVersion=16.0`.
- Integra `ceremonial-card-back` como asset independiente con el mismo SHA-256 que el master de diseño.
- Incluye controles semánticos, targets de 44 puntos, descripciones visuales, posiciones neutrales, Dynamic Type adaptativo y estado S00 no interactivo durante restauración.
- Tres pasadas de revisión estática cerraron los P1/P2 de restauración, persistencia, botones muertos, CTA y accesibilidad con resultado final **PASS**. Compilación SwiftUI, XCTest y empaquetado iOS 16 están verdes; previews y comparación de capturas siguen pendientes.
- A-027/A-028 están integradas localmente: iOS selecciona inglés o castellano sin selector propio; una lectura de tres cartas ofrece `Past · Present · Future`, `Situation · Challenge · Advice`, `You · The other person · Connection` u opción abierta; el preset se restaura junto a la sesión y no altera IDs ni orden.
- V-039 registra la selección de tirada en castellano y V-040 sustituye las proporciones anteriores de Three Cards landscape con rail compacto y cartas ocupando casi toda la altura disponible.
- V-041 y `design/tarot-deck/MOTION_SPEC.md` registran el storyboard y contrato de movimiento. La implementación iOS 16 añade transiciones breves, shuffle, draw, giro reveal/conceal, respuesta táctil de botones y haptics solo después de un estado durable. Reduce Motion y VoiceOver usan variantes de opacidad; restaurar, rotar o volver de segundo plano no reproduce efectos.
- La revisión final independiente de motion cerró sin P0–P2: comprobó compatibilidad estática iOS 16, foco VoiceOver post-commit, supresión de replay/haptics en background, privacidad face-down, PBX y contratos del validador.
- A-030 está integrada mediante un único `FavoriteCardsStore` compartido por Read y Cards. Guarda solo `cardID` canónicos en `favorites.v1.json`, con JSON atómico y directorio excluido de backup; el filtro `Favorites/Favoritas`, su estado vacío y el corazón del detalle siguen V-042/V-043. La revisión independiente cerró sin P0–P2.
- Los validadores locales de mazo, educación inglesa, localización española, integración y workflow IPA pasan. GitHub Actions verificó además las pruebas Swift, la compilación completa para iPhone/iOS 16 y el IPA bilingüe exacto del commit `63c459e`.

## Qué se conserva y qué queda fuera

Se conserva intacto el prototipo Expo, las 36 cartas, la exploración visual y el historial de decisiones. Sirven como referencia conceptual, estética y recuperable.

Quedan fuera del MVP de Tarot: carta diaria automática, categorías reflexivas, mensajes y preguntas, recordatorios, historial de tiradas, notas, compartir, feed, horóscopo, Zodiac, IA, interpretaciones automáticas, cuentas, red, pagos, Android y lenguas distintas de inglés/castellano.

## Decisión material resuelta

**P-004 — modelo canónico del mazo**, cerrada por A-015.

El MVP usa un tarot estándar completo de **78 cartas** —22 Arcanos Mayores y 56 Menores—, solo en orientación normal. La primera versión puede usar las imágenes históricas originales Rider–Waite–Smith de dominio público y debe evitar ediciones comerciales modernas o modificaciones con derechos propios. Las 36 cartas reflexivas antiguas se conservan, pero no se presentan como el mazo de producción.

Motivo: “un mazo de tarot en el móvil” promete el equivalente reconocible de un mazo físico. Usar 36 cartas temáticas convertiría el producto en una baraja oráculo y cambiaría su promesa.

El modelo y los identificadores deben permitir sustituir en el futuro cada imagen histórica por arte propio sin reescribir el motor ni perder compatibilidad.

## Bloqueos y puertas

1. Firmar localmente el IPA verificado y comparar en un iPhone real portrait/landscape/motion/favoritos con V-039–V-043; Windows no puede producir previews, capturas ni validar fidelidad háptica sin el dispositivo.
2. Resolver revisión territorial y aprobación de distribución del arte antes de cualquier release. El gate release falla intencionalmente solo por `candidateOnly/finalAsset/distributionApproved/territorial`.
3. Resolver bundle identifier e historial de distribución antes de firma de distribución.
4. Settings S09.1 está integrado; StoreKit, productos, precios reales, páginas legales publicadas, ficha App Store, secretos, firma de distribución, subida y publicación siguen sin autorización.

La procedencia del arte debe quedar documentada antes de tratar cualquier cara como asset de producción. El historial de distribución y el bundle identifier se resuelven antes de firma o release; no bloquean el diseño conceptual.

## Siguiente acción automática

Siguiente punto exacto: firmar localmente el IPA de `run-31414355150` con Sideloadly o AltStore y probar cambio de idioma, las cuatro tiradas, favoritos tras relanzar, último favorito, tamaño landscape, Reduce Motion y la cadencia/haptics en un iPhone. No tratar los 78 candidatos históricos como arte distribuible; el gate de release sigue bloqueado hasta cerrar derechos.

No aumentar límites de gasto, añadir métodos de pago, usar TestFlight, App Store ni publicar sin autorización expresa separada.
