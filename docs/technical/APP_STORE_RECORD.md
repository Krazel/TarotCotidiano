# App Store record — Tarot Deck

Actualizado: 2026-08-11

## Propósito y estado

Esta ficha prepara los datos de App Store Connect para **Tarot Deck** sin afirmar que la app, el App ID o la ficha externa ya se hayan creado. No autoriza ni documenta como realizados contratos, precios, StoreKit, subida de builds, TestFlight, App Review o publicación.

Estado de preparación: **metadata bilingüe preparada; registro externo y cumplimiento pendientes**.

Bloqueo de distribución: las 78 reproducciones históricas Rider–Waite–Smith siguen marcadas como candidatas internas. No debe subirse una build ni enviarse la app a revisión hasta sustituirlas por arte propio o confirmar derechos de distribución para todos los territorios seleccionados.

## Datos del registro

| Campo | Valor preparado | Estado / nota |
|---|---|---|
| Plataforma | iOS | Solo iPhone. No añadir Android, iPad, macOS o visionOS. |
| Nombre provisional | `Tarot Deck` | Aprobado como nombre de trabajo; 10 caracteres, dentro del límite de 2–30. Su disponibilidad debe comprobarse al crear la ficha. |
| Bundle ID | `com.krazel.tarotdeck` | Tratar como permanente. Debe coincidir exactamente con Xcode. Registro en Apple pendiente de verificación. |
| SKU | `tarot-deck-ios` | Permanente e interno; nunca se muestra al público. |
| Idioma principal | English (U.S.) | Fallback de la ficha. |
| Localización adicional | Spanish (Spain) | Añadir metadata completa en castellano; la app ya contempla inglés y castellano. |
| Acceso | Full Access | Valor preparado para la ficha. |
| Versión visible | `0.2` | Línea vigente de desarrollo; no equivale a versión pública. |
| Build | `1` | Primer binario previsto de `0.2`; todavía no subido. |
| App Store Connect Apple ID | **Pendiente / desconocido** | Apple lo genera al crear la ficha. No inventar ni reservar un valor local. |
| Precio / disponibilidad | **Pendiente** | No configurar en este encargo. |

## Clasificación recomendada

- **Categoría primaria: Lifestyle.** La experiencia central es usar un mazo digital como afición personal. Apple define Lifestyle para apps sobre temas o servicios de interés general e incluye hobbies entre sus ejemplos.
- **Categoría secundaria: Reference.** Learn, los significados y la biblioteca ayudan a recuperar información y seguir métodos; Apple incluye how-tos y material de consulta en Reference.

Esta combinación representa mejor el orden real del producto: primero mazo usable, después referencia de aprendizaje. La categoría primaria configurada en App Store Connect debe coincidir con la de Xcode. Fuente: [Apple — Choosing a category](https://developer.apple.com/app-store/categories/).

## Metadata pública — English (U.S.)

### Name

`Tarot Deck`

### Subtitle

`Your deck, always with you`

### Promotional text — optional

Candidate, but leave empty at initial record creation unless there is a current feature announcement:

`Carry 78 cards, choose a one- or three-card reading, reveal each card at your own pace, and learn practical ways to read the spread.`

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

`Tarot Deck`

Se mantiene el mismo nombre de producto en ambas localizaciones hasta decidir un nombre definitivo.

### Subtitle

`Tu mazo, siempre contigo`

### Promotional text — optional

Candidato; dejar vacío al crear la ficha salvo que exista una novedad vigente:

`Lleva 78 cartas contigo, elige una tirada de una o tres cartas, revela cada carta a tu ritmo y aprende formas prácticas de leer el conjunto.`

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
| Support URL | `https://krazel.github.io/tarot-deck/support/` | Placeholder reservado. No introducir hasta que la página exista, sea pública y describa un canal de soporte real. |
| Privacy Policy URL | `https://krazel.github.io/tarot-deck/privacy/` | Placeholder reservado. No introducir hasta publicar y verificar una política fiel a la build final. Es obligatorio para iOS. |
| Marketing URL | Vacío | Opcional; no inventar un destino. |
| Copyright | **Pendiente** | Requiere confirmar el nombre legal exacto del titular; no usar una marca o persona inferida. |
| App icon | Concepto D — Three-Card Fan, elegido por el propietario | La integración final se realiza en una tarea separada. App Store debe recibir el icono validado desde la build, sin tratar el PNG conceptual como asset de distribución por sí solo. |

Apple limita el subtitle a 30 caracteres, promotional text a 170, description a 4.000 y keywords a 100 bytes; Support URL es obligatorio y la descripción/keywords son localizables. Fuentes: [Apple — App information](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information/) y [Apple — Platform version information](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information).

## Preguntas de cumplimiento aún pendientes

### Content Rights — bloqueante

No seleccionar todavía una respuesta en App Store Connect. La app muestra arte de cartas y Apple exige disponer de los derechos necesarios sobre contenido de terceros. Antes de responder:

1. cerrar una de estas rutas: arte propio final o revisión jurídica territorial documentada del arte histórico;
2. reconciliar el manifiesto de las 78 cartas con los assets exactos de la build;
3. conservar evidencia de fuente, autoría/licencia y territorios autorizados;
4. decidir disponibilidad territorial coherente con esa evidencia.

El estado actual `candidateOnly=true`, `finalAsset=false`, `distributionApproved=false` impide afirmar que los derechos de distribución estén resueltos.

### Age Rating — pendiente de cuestionario

No proponer manualmente una edad como si estuviera calculada. Revisar la build final, los textos bilingües y las 78 imágenes y responder el cuestionario real de Apple, incluyendo cualquier descriptor aplicable a temas sugerentes, violencia simbólica, horror/miedo, salud/bienestar o actividades basadas en azar. La app no debe marcarse como Made for Kids. Apple calcula la clasificación a partir de las respuestas: [Apple — Set an app age rating](https://developer.apple.com/help/app-store-connect/manage-app-information/set-an-app-age-rating).

### App Privacy — pendiente de auditoría final

No declarar aún “Data Not Collected”. La arquitectura actual es local y sin servicios de runtime, pero la respuesta debe auditar la build candidata completa y todo SDK de terceros. StoreKit, analítica, publicidad, enlaces externos o soporte futuro podrían cambiarla. La Privacy Policy URL debe estar publicada antes de completar este apartado. Apple exige incluir las prácticas propias y las de terceros integrados: [Apple — Manage app privacy](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy).

### Export compliance / encryption — pendiente por build

No responder por inferencia. Inspeccionar la build que se vaya a subir y contestar el flujo de cifrado de App Store Connect; el uso de funcionalidad criptográfica del propio sistema también requiere una determinación. Si resulta exenta, registrar el valor correcto en Xcode solo después de confirmarlo. Fuente: [Apple — Overview of export compliance](https://developer.apple.com/help/app-store-connect/manage-app-information/overview-of-export-compliance).

### Review y disponibilidad — pendientes

- No hay build de distribución seleccionable ni App Store Connect ID verificado.
- Screenshots y app previews deben esperar a una build visualmente cerrada y no se preparan en esta ficha.
- Review notes se redactan contra la funcionalidad exacta de la build candidata.
- Precio, países/regiones, fecha de lanzamiento y método de publicación no están autorizados.
- No hay productos StoreKit, contratos ni datos bancarios/precios configurados.

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
| Versión visible / build | Identidad de cada binario | Primera build prevista de esta línea: `0.2 (1)`. No reutilizar una combinación ya aceptada. |
| Bundle ID | Permanente en la práctica | Debe coincidir con Xcode y no puede cambiarse después de subir una build. |
| SKU | Permanente | Apple no permite cambiarlo después de añadir la app. |
| Apple ID de App Store Connect | Permanente y generado por Apple | Registrarlo aquí solo cuando exista; nunca inventarlo. |

Fuente de editabilidad y permanencia: [Apple — App information](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information/) y [Apple — Required, localizable, and editable properties](https://developer.apple.com/help/app-store-connect/reference/app-information/required-localizable-and-editable-properties).

## Puerta antes de introducir o enviar datos externos

- La creación de la ficha puede usar los datos de registro de este documento cuando la tarea propietaria confirme que el App ID definitivo está registrado y que no hay un acuerdo legal interpuesto.
- No introducir Support/Privacy URLs hasta que respondan públicamente y su contenido haya sido verificado.
- No marcar Content Rights, Age Rating, App Privacy o Export Compliance como completados hasta cerrar las auditorías anteriores.
- No subir `0.2 (1)`, crear StoreKit, aceptar contratos, enviar a revisión o publicar sin autorización expresa separada.
