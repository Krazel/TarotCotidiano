# App Store record — Tarot Deck: Read & Learn

Actualizado: 2026-08-11

## Propósito y estado

Esta ficha registra los datos verificados de App Store Connect para **Tarot Deck: Read & Learn**. `0.2.1 (1)` está subida y disponible exclusivamente como **TestFlight Internal Only**. No autoriza contratos, StoreKit, testers externos, App Review o publicación.

Estado de preparación: **registro externo y metadata bilingüe guardados; privacidad, edad, accesibilidad conservadora y precio gratuito configurados; derechos y distribución pendientes**.

Bloqueo de distribución: la obra histórica Rider–Waite–Smith está fuera de copyright en los territorios principales auditados, pero los 78 JPEG TaionWC/Pam-A siguen marcados como candidatos internos y no tienen una cadena suficientemente limpia para distribución mundial. No debe subirse una build ni enviarse la app a revisión hasta sustituirlos por arte propio o un conjunto con licencia/CC0 y cobertura territorial expresa. Evidencia: `docs/technical/CONTENT_RIGHTS_AUDIT.md`.

## Datos del registro

| Campo | Valor preparado | Estado / nota |
|---|---|---|
| Plataforma | iOS | Solo iPhone. No añadir Android, iPad, macOS o visionOS. |
| Nombre provisional EN | `Tarot Deck: Read & Learn` | `Tarot Deck` no estaba disponible. Nombre reservado y editable antes de review. |
| Nombre provisional ES | `Tarot Deck: Lee y aprende` | Localización Español (España) guardada y editable antes de review. |
| Bundle ID | `com.krazel.tarotdeck` | App ID explícito registrado y permanente en Apple Developer. La futura configuración de distribución de Xcode debe coincidir exactamente. |
| SKU | `tarot-deck-ios` | Permanente e interno; nunca se muestra al público. |
| Idioma principal | English (U.S.) | Fallback de la ficha. |
| Localización adicional | Spanish (Spain) | Añadida; nombre y subtítulo básicos guardados. La app ya contempla inglés y castellano. |
| Acceso | Full Access | Configurado. |
| Versión visible | `0.2.1` | Corrección de la composición Release posterior a la entrega `0.2`; no equivale a versión pública. |
| Build | `1` | Subida, procesada y `En pruebas` en el grupo interno `Testers`. |
| App Store Connect Apple ID | `6800144105` | Generado y verificado en App Store Connect el 2026-08-11. |
| Tren público inicial | `1.0` | Permanece en preparación y sin build seleccionada. TestFlight `0.2.1 (1)` no sustituye ni publica ese tren. |
| Publicación | Manual | Configurada para impedir una publicación automática tras una futura aprobación. |
| Inicio de sesión para review | No requerido | La app no tiene cuentas ni login. |
| Precio | Gratis (`0,00 €`) | España (EUR) es la región base; precios equivalentes gratuitos en las 175 regiones. |
| Disponibilidad territorial | **Sin configurar** | No seleccionar territorios hasta cerrar Content Rights. |
| Dispositivos de tienda | iPhone | Mac con Apple silicon y Apple Vision Pro desactivados. |

## Clasificación configurada

- **Categoría primaria: Lifestyle.** La experiencia central es usar un mazo digital como afición personal. Apple define Lifestyle para apps sobre temas o servicios de interés general e incluye hobbies entre sus ejemplos.
- **Categoría secundaria: Reference.** Learn, los significados y la biblioteca ayudan a recuperar información y seguir métodos; Apple incluye how-tos y material de consulta en Reference.

Esta combinación representa mejor el orden real del producto: primero mazo usable, después referencia de aprendizaje. La categoría primaria configurada en App Store Connect debe coincidir con la de Xcode. Fuente: [Apple — Choosing a category](https://developer.apple.com/app-store/categories/).

## Metadata pública — English (U.S.)

### Name

`Tarot Deck: Read & Learn`

### Subtitle

`Your deck, always with you`

### Promotional text — optional

Empty. It is optional and unnecessary for the initial record.

### Description

```text
Carry a complete tarot deck on your iPhone and read the cards at your own pace.

Tarot Deck is designed to feel like having a physical deck with you. Choose a one-card reading or a three-card spread, shuffle, draw, and reveal the cards yourself. The app gives you the structure and reference material; it does not generate an automatic prediction.

READ YOUR WAY
• Draw one card or work with three.
• Choose Past · Present · Possible Direction, Situation · Challenge · Guidance, You · The Other Person · Connection, or an open three-card reading.
• Tap a revealed card to see its upright meaning and a practical reflection prompt.
• Restart a reading quickly without losing the rhythm of the table.

LEARN THE METHODS
Follow step-by-step tutorials for preparing a reading, asking a clear question, understanding each position, combining the cards, and closing the reading.

EXPLORE THE DECK
Browse all 78 Major and Minor Arcana cards, open them one by one, and save favorites for later reference.

Available in English and Spanish. Designed for iPhone and usable offline.

Tarot is a reflective practice. The app does not provide medical, legal, financial, or other professional advice.
```

### Keywords

`cards,spreads,meanings,learn,major arcana,minor arcana,reading,favorites,symbolism`

## Metadata pública — Spanish (Spain)

### Name

`Tarot Deck: Lee y aprende`

Ambos nombres siguen siendo provisionales y editables antes de review.

### Subtitle

`Tu mazo, siempre contigo`

### Promotional text — optional

Vacío. Es opcional y no es necesario para la ficha inicial.

### Description

```text
Lleva un mazo de tarot completo en tu iPhone y lee las cartas a tu propio ritmo.

Tarot Deck está diseñada para sentirse como llevar un mazo físico contigo. Elige una lectura de una carta o una tirada de tres, baraja, saca y revela tú mismo las cartas. La app aporta la estructura y el material de consulta; no genera una predicción automática.

LEE A TU MANERA
• Saca una carta o trabaja con tres.
• Elige Pasado · Presente · Posible dirección, Situación · Reto · Orientación, Tú · La otra persona · Vínculo o una tirada abierta de tres cartas.
• Toca una carta revelada para consultar su significado al derecho y una propuesta práctica de reflexión.
• Reinicia una lectura rápidamente sin romper el ritmo de la mesa.

APRENDE LOS MÉTODOS
Sigue tutoriales paso a paso para preparar una lectura, formular una pregunta clara, comprender cada posición, relacionar las cartas y cerrar la lectura.

EXPLORA EL MAZO
Recorre las 78 cartas de los Arcanos Mayores y Menores, ábrelas una a una y guarda tus favoritas para consultarlas después.

Disponible en inglés y castellano. Diseñada para iPhone y utilizable sin conexión.

El tarot es una práctica de reflexión. La app no ofrece asesoramiento médico, jurídico, financiero ni de otro tipo profesional.
```

### Keywords

`cartas,tiradas,significados,aprender,arcanos mayores,arcanos menores,lectura,favoritas,símbolos`

## URLs y datos editoriales

| Campo | Valor preparado | Puerta |
|---|---|---|
| Support URL | `https://krazel.github.io/tarot-deck/support/` | Publicada, verificada con HTTP 200 e introducida en la ficha. |
| Privacy Policy URL | `https://krazel.github.io/tarot-deck/privacy/` | Publicada, verificada con HTTP 200 e introducida para EN-US y ES-ES. |
| Marketing URL | Vacío | Campo opcional eliminado de EN-US y ES-ES bajo A-039; la página informativa no es necesaria para describir la app. |
| Copyright | Valor obligatorio configurado de forma privada en App Store Connect | No se duplica el dato legal del titular en el repositorio público. Apple indica que este campo no es visible para clientes. |
| App icon | D — Three-Card Fan | Integrado en el catálogo y verificado dentro del IPA Local-QA; App Store lo recibirá únicamente desde una futura build de distribución. |

Apple limita el subtitle a 30 caracteres, promotional text a 170, description a 4.000 y keywords a 100 bytes; Support URL es obligatorio y la descripción/keywords son localizables. Fuentes: [Apple — App information](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information/) y [Apple — Platform version information](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information).

## Preguntas de cumplimiento aún pendientes

### Content Rights — bloqueante para distribución externa o pública

No seleccionar todavía una respuesta en App Store Connect. La app muestra arte de cartas y Apple exige disponer de los derechos necesarios sobre contenido de terceros. Antes de responder:

1. cerrar una de estas rutas: arte propio final o un conjunto con licencia/CC0 expresa del digitalizador y revisión territorial documentada del arte histórico;
2. reconciliar el manifiesto de las 78 cartas con los assets exactos de la build;
3. conservar evidencia de fuente, autoría/licencia y territorios autorizados;
4. decidir disponibilidad territorial coherente con esa evidencia.

El estado actual `candidateOnly=true`, `finalAsset=false`, `distributionApproved=false` impide afirmar que los derechos de distribución pública estén resueltos. Public Domain Mark acredita la identificación de Commons, pero no es una licencia, cesión ni garantía mundial. A-040 permite solo QA interna y el binario se exporta con la restricción irreversible `testFlightInternalTestingOnly=true`; no puede pasar a testers externos ni App Store.

### Age Rating — completado

El cuestionario real fue completado contra las 78 imágenes y el contenido bilingüe. Se declararon como poco frecuentes terror/miedo, temas adultos o sugestivos, desnudez no explícita y violencia fantástica; armas como frecuentes; el resto de capacidades y contenido no aplicable como ausente. Apple calculó **13+** y no se aplicó reemplazo manual. La app no está marcada como Made for Kids. Reauditar si cambia el arte o el contenido: [Apple — Set an app age rating](https://developer.apple.com/help/app-store-connect/manage-app-information/set-an-app-age-rating).

### App Privacy — publicada para el estado actual

La auditoría del runtime actual confirmó ausencia de analítica, anuncios, tracking, cuentas, backend, red y SDK de terceros. Se publicó **Data Not Collected / No se recopilan datos**. La app conserva localmente idioma, favoritos y lectura; no los transmite. El correo voluntario de soporte ocurre fuera de la app y se documenta por separado en la política pública y en `docs/technical/PRIVACY_DATA_INVENTORY.md`. Reauditar antes de la build final y ante cualquier incorporación de StoreKit, publicidad, analítica, soporte integrado, red o SDK: [Apple — Manage app privacy](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy).

### Accessibility — borrador conservador

App Store Connect contiene un borrador para iPhone con **Dark Interface / Interfaz oscura** como única prestación declarada. VoiceOver, Voice Control, Larger Text, Reduce Motion, contraste y diferenciación sin color requieren QA manual completo en un iPhone antes de declararse. Apple no permite publicar este borrador hasta que exista una versión pública de la app.

### Export compliance / encryption — preparada, pendiente de verificar en archive

El código no implementa cifrado propio ni integra SDK criptográfico o de red. Release declara `ITSAppUsesNonExemptEncryption=NO`; el workflow debe verificar ese valor en el archive firmado antes de subir. Revalidar el flujo de App Store Connect si cambia el código o aparece criptografía no exenta. Fuente: [Apple — Overview of export compliance](https://developer.apple.com/help/app-store-connect/manage-app-information/overview-of-export-compliance).

### Review y disponibilidad — pendientes

- No hay build seleccionada para el tren público `1.0`; la ficha verificada usa Apple ID `6800144105`.
- TestFlight contiene `0.2.1 (1)` como build Internal Only, estado `En pruebas`, asignada al grupo interno `Testers` con un tester. Las instrucciones de QA están guardadas en English (U.S.).
- Nombre, subtítulo, descripción y keywords están guardados en English (U.S.) y Español (España); la publicación está configurada como manual.
- Screenshots y app previews deben esperar a una build visualmente cerrada y no se preparan en esta ficha.
- Review contact y notes están guardados contra la funcionalidad actual; son privados para App Review, sus valores no se reproducen en el repositorio ni en páginas públicas y deben revalidarse con la build candidata.
- Precio gratuito y publicación manual están configurados. Países/regiones y fecha de lanzamiento permanecen sin configurar por Content Rights.
- No hay productos StoreKit, contratos nuevos ni datos bancarios configurados.

### DSA / condición de comerciante — decisión material pendiente

App Store Connect identifica actualmente al desarrollador como **trader / comerciante** para esta app. No se ha cambiado ni eludido ese estado. Antes de habilitar territorios de la Unión Europea, el propietario debe confirmar que la condición sigue siendo veraz y completar únicamente la información que Apple o la ley exijan. Si la app se distribuye como actividad profesional o comercial —incluido un futuro apoyo mensual— la recomendación es conservar la condición de comerciante. Los datos privados de verificación permanecen en App Store Connect y no se copian al repositorio; cualquier dato que deba hacerse público por obligación legal se limita a lo estrictamente requerido.

## Qué puede cambiar y qué debe tratarse como permanente

| Dato | Tratamiento | Regla práctica |
|---|---|---|
| Name y nombre localizado | Editable | Puede cambiarse antes de enviar a App Review; más adelante, con una versión nueva o cuando el estado permita editarlo. |
| Subtitle | Editable/localizable según estado | Mantener cada localización dentro de 30 caracteres. |
| Description y keywords | Editables/localizables según estado | Se preparan por versión; respetar 4.000 caracteres y 100 bytes. |
| Promotional text | Editable sin nueva versión | Es opcional y no afecta al ranking de búsqueda. |
| Primary Language | Editable | Apple permite cambiarlo; conservar English (U.S.) como fallback mientras esa sea la decisión del producto. |
| Categorías | Editables según estado | Lifestyle debe coincidir entre App Store Connect y Xcode. |
| URLs, privacidad, edad y derechos | Actualizables, siempre veraces | Volver a revisar con cada cambio de datos, SDK, contenido o distribución. |
| Versión visible / build | Identidad de cada binario | Primera build prevista de esta línea: `0.2.1 (1)`. No reutilizar una combinación ya aceptada. |
| Bundle ID | Permanente en la práctica | Debe coincidir con Xcode y no puede cambiarse después de subir una build. |
| SKU | Permanente | Apple no permite cambiarlo después de añadir la app. |
| Apple ID de App Store Connect | Permanente y generado por Apple | Registrarlo aquí solo cuando exista; nunca inventarlo. |

Fuente de editabilidad y permanencia: [Apple — App information](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information/) y [Apple — Required, localizable, and editable properties](https://developer.apple.com/help/app-store-connect/reference/app-information/required-localizable-and-editable-properties).

## Puerta antes de introducir o enviar datos externos

- El App ID definitivo y la ficha ya están creados. No duplicarlos ni sustituir el SKU o bundle ID.
- Support y Privacy responden públicamente y están introducidas en la ficha. Marketing URL permanece vacío por ser opcional; actualizar únicamente los destinos necesarios si cambia el producto o las prácticas de datos.
- Age Rating y App Privacy están completados para el estado actual. No marcar Content Rights para distribución pública hasta cerrar su puerta específica.
- A-040/A-041 cerraron la subida de `0.2.1 (1)` únicamente a TestFlight Internal Only. No crear StoreKit, aceptar contratos, habilitar testers externos, enviar a revisión o publicar sin autorización expresa separada.
