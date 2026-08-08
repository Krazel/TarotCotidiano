# Auditoría técnica para el reinicio iOS

**Proyecto:** Tarot Cotidiano  
**Fecha de verificación:** 8 de agosto de 2026  
**Alcance de v1 confirmado:** solo iPhone/iOS y solo inglés  
**Tipo de revisión:** auditoría estática, sin modificar ni ejecutar la aplicación

## Conclusión ejecutiva

La versión existente es un prototipo Expo/React Native pequeño y autocontenido, no una base de producción consolidada. Tiene contenido útil y comportamientos que se pueden conservar como referencia, pero casi toda la interfaz, la lógica y el acceso a servicios están concentrados en un único `App.js` de 1.039 líneas. No hay dependencias instaladas, archivo de bloqueo, pruebas, proyecto nativo iOS, configuración de compilación/distribución ni repositorio Git propio. Por ello no fue posible compilar ni probar en simulador o dispositivo sin alterar el proyecto.

La recomendación técnica es **reiniciar la implementación en un proyecto SwiftUI limpio para iPhone, conservando intacto el prototipo Expo como referencia y reutilizando únicamente el modelo de contenido, los identificadores estables y los comportamientos de producto que se vuelvan a aprobar**. La simplificación a solo iOS y solo inglés elimina las dos razones principales para asumir el coste permanente de una capa multiplataforma. Además, la interfaz anterior no cuenta con aprobación visual y, por tanto, reescribirla no sacrifica una inversión de UI validada.

Esta recomendación **no es una decisión ya tomada**. Antes de implementar, el propietario debe aprobar expresamente el cambio a SwiftUI y aceptar sus consecuencias: el MVP será nativo iOS; una futura versión para otra plataforma sería un proyecto independiente; y, si existen usuarios de una versión ya distribuida, habrá que diseñar una migración explícita de sus datos locales.

La alternativa razonable, si el propietario prioriza experiencia previa del equipo en JavaScript o el menor tiempo inicial sobre la sencillez nativa a largo plazo, es conservar Expo/React Native pero partir de un esqueleto moderno y soportado, no continuar directamente sobre SDK 53 ni sobre el monolito actual. La migración gradual entre React Native y SwiftUI no se recomienda para este tamaño de producto.

## Alcance y límites de la auditoría

Se revisaron íntegramente `AGENTS.md`, `PORTFOLIO.md`, `projects/tarot.md`, la skill `visual-first-app-development` y todos los archivos existentes del proyecto. Se respetaron sus límites:

- no se implementaron pantallas ni se alteró el diseño;
- no se trabajó en Android;
- no se añadieron dependencias;
- no se modificaron código, contenido, `docs/product/` ni Brain;
- el prototipo existente se trató como referencia, no como arquitectura aprobada;
- este informe es el único archivo creado.

La auditoría es estática. El directorio no contiene `node_modules` ni `package-lock.json`; `npm ls --depth=0` confirmó que todas las dependencias declaradas están ausentes. Tampoco existe un Mac/Xcode disponible en este entorno. En consecuencia, no se verificaron compilación, prebuild, firma, permisos reales, comportamiento de notificaciones, accesibilidad ni ejecución en iPhone.

## Inventario real

El proyecto contenía siete archivos antes de este informe:

| Archivo | Función | Observación |
|---|---|---|
| `App.js` | Toda la aplicación, navegación manual, UI, estado, compartir, persistencia y notificaciones | 1.039 líneas; responsabilidades mezcladas |
| `data/tarot.js` | 12 categorías y 36 cartas | 353 líneas; tres cartas por categoría; identificadores coherentes |
| `package.json` | Dependencias y scripts Expo | Sin lockfile; declara Expo SDK 53 / React Native 0.79.6 / React 19 |
| `app.json` | Configuración Expo | Identificador iOS presente; configuración de icono, build y privacidad incompleta |
| `babel.config.js` | Babel para Expo | Configuración mínima |
| `.gitignore` | Exclusiones | Excluye `ios/` y `android/`; encaja con generación nativa, pero no hay flujo documentado |
| `README.md` | Descripción y comandos | Describe el prototipo antiguo para dos plataformas; ya no representa el alcance de v1 |

No existe un directorio `ios/`, `eas.json`, assets de icono/splash, configuración de CI, pruebas, lint, TypeScript, analítica, backend, cuentas, compras ni red. El `bundleIdentifier` declarado es `com.dmkra.tarotcotidiano`. No hay evidencia local de una compilación firmada o de una publicación, pero esto no demuestra que nunca haya existido fuera del directorio.

Como huella de preservación, en el momento de la auditoría los SHA-256 principales eran:

- `App.js`: `EFC3C74A9AB9B7B92A7811813118F9BED8696F91BA76FFA1767A5F6D03008EAF`
- `data/tarot.js`: `8F3FEBB455F408E0840E59896DFC995AFCFE3CC03F69D013DB0A2CA5EE60C7D6`
- `package.json`: `C7545EA84AA50D31C55D49473DE1A537027AA28486A764D7766466E8EB2703BF`
- `app.json`: `8CDC02DE18BC443553F3A85B1CD0F458B77B6EC356956EBD2C323B562ECC852C`

## Base técnica actual

### Dependencias

| Dependencia declarada | Uso actual | Evaluación |
|---|---|---|
| `expo ^53.0.0` | Toolchain y generación nativa | SDK 53 fue publicado en abril de 2025 y está cuatro generaciones por detrás de la referencia actual SDK 57. No es una base prudente para reiniciar en agosto de 2026. |
| `react-native 0.79.6` | UI y APIs nativas | Ligado a SDK 53. La app importa `SafeAreaView` desde React Native, componente marcado como obsoleto en la documentación vigente. |
| `react 19.0.0` | Estado y renderizado | Correcto para la combinación declarada, pero debe mantenerse alineado con la versión de Expo elegida. |
| `expo-notifications ~0.31.4` | Permiso y recordatorio local | La necesidad funcional es válida; la implementación actual tiene problemas de contenido y consistencia descritos abajo. |
| `@react-native-async-storage/async-storage 2.1.2` | Preferencias, guardados e ID de notificación | Adecuado para pequeñas cantidades no sensibles, pero no está cifrado y el código no versiona ni valida el esquema. |
| `expo-status-bar ~2.2.3` | Barra de estado | Dependencia menor, sin riesgo propio relevante. |
| `@babel/core ^7.25.2` | Transformación de código | Declarada, no instalada. |

El rango con caret en `expo`, combinado con la ausencia de lockfile, impide reconstruir con certeza el mismo árbol de dependencias. La documentación actual de Expo vincula cada SDK a versiones concretas de React y React Native; las versiones deben instalarse mediante el resolvedor de Expo y quedar bloqueadas. Apple exige desde el 28 de abril de 2026 que los envíos usen el SDK de iOS 26 o posterior. Expo indica que SDK 53 puede intentar compilarse con una imagen Xcode 26 elegida expresamente, pero recomienda actualizar al menos a SDK 54; el proyecto ni siquiera contiene esa configuración de build. Por tanto, el estado actual **no es un candidato de App Store verificable**.

### Estructura y mantenibilidad

`App.js` contiene cuatro vistas renderizadas mediante funciones internas y una barra de pestañas manual. También incluye modelos implícitos, selección diaria, transformación de datos, persistencia, permisos, programación de notificaciones, compartir, componentes gráficos y 548 líneas aproximadas de estilos. Esta concentración provoca:

- pruebas unitarias difíciles porque las funciones relevantes no están separadas del componente;
- cambios de diseño con alto riesgo de alterar estado o servicios;
- ausencia de contratos de tipos y validación de datos persistidos;
- navegación, ciclo de vida y restauración de estado resueltos de forma ad hoc;
- accesibilidad difícil de revisar de manera sistemática;
- mayor coste para comparar cada pantalla con una referencia visual aprobada.

No hay una complejidad de dominio que justifique conservar esta estructura. La lógica reutilizable real se reduce a los datos, los IDs, una regla de carta diaria, guardados, una preferencia horaria y acciones de compartir/notificar.

## Datos y contenido reutilizable

### Lo que sí merece preservarse

- El esquema conceptual `Category` / `Card`.
- Los 12 IDs de categoría y 36 IDs de carta; son coherentes y permiten referencias estables.
- La relación de tres cartas por categoría.
- Los campos `title`, `message` y `prompt` como modelo editorial.
- La idea de estado mínimo: IDs guardados, categoría elegida, preferencia de recordatorio y hora.
- Los textos españoles como fuente creativa y registro de intención.

### Lo que no está listo para el lanzamiento en inglés

Todo el contenido y casi todo el copy de interfaz están en español, con frecuencia sin tildes. No existe contenido inglés ni revisión editorial. Para v1 no hace falta construir un sistema de localización: basta con que la nueva fuente canónica contenga inglés. El español debe quedar preservado fuera del bundle de lanzamiento o claramente identificado como referencia, sin asumir que una traducción literal está aprobada.

La regla actual de carta diaria usa el día del año módulo 36. Además de necesitar una especificación de producto, presenta dos defectos técnicos:

1. calcula el día dividiendo milisegundos locales desde el inicio del año, una operación vulnerable a cambios de horario estacional;
2. `todayCard` se memoriza una sola vez y no cambia a medianoche mientras la app permanece abierta.

La nueva implementación debe convertir la fecha en un identificador de día basado en calendario y zona horaria, y probar cambio de año, cambio de zona y horario estacional. Debe decidirse también si todos reciben la misma carta o si la selección es personal; el prototipo implementa lo primero, pero no constituye una decisión de producto aprobada.

## Persistencia

El estado se guarda como un único JSON bajo `tarot-cotidiano-state`; el ID de la notificación se guarda en una segunda clave. Esto es suficiente en volumen, pero frágil:

- `JSON.parse` no tiene `catch` ni validación; un valor corrupto deja la app con defaults y una promesa rechazada;
- las escrituras no esperan resultado ni informan de fallo;
- no existe versión de esquema ni migración;
- los tipos persistidos se confían ciegamente;
- `reminderEnabled` puede divergir del permiso o de las solicitudes realmente pendientes en iOS;
- guardar el ID de una notificación por separado permite estados parciales si programar, guardar o cancelar falla.

No hay secretos, identidad ni datos sensibles en el alcance actual, por lo que el almacenamiento cifrado no aporta valor al MVP. En SwiftUI, unas preferencias `Codable` pequeñas y versionadas sobre `UserDefaults` son suficientes; no hace falta introducir SwiftData mientras no haya historial, diario personal o consultas complejas. En Expo, AsyncStorage seguiría siendo aceptable con validación, versión y manejo explícito de errores.

Una reescritura SwiftUI con el mismo bundle ID **no leerá automáticamente** el formato interno de AsyncStorage mediante una API pública estable. Si hubo una versión instalada por usuarios reales, se necesita un plan de migración probado o una decisión explícita de no conservar ese estado. Si nunca hubo distribución, no debe añadirse esa complejidad al MVP.

## Notificaciones locales

La app solicita permiso al activar el interruptor y programa un trigger diario, enfoque coherente con un recordatorio opcional. No usa push, servidor ni datos remotos. Sin embargo:

- el contenido de la notificación repetitiva se calcula al programarla, por lo que **repite para siempre el título de la carta de ese día**, no la carta correspondiente a cada día futuro;
- no se reconcilian al arrancar el permiso, el estado guardado y las solicitudes pendientes del sistema;
- si el usuario deniega permiso, iOS no vuelve a mostrar normalmente el diálogo; falta un flujo hacia Ajustes del sistema;
- no hay `try/catch`, estado de operación ni recuperación ante fallo de programación/cancelación;
- el botón de prueba y el recordatorio no fueron verificados en un iPhone real;
- el mensaje no incluye datos para abrir un destino concreto y no hay manejo de respuestas a notificaciones.

Para SwiftUI, usar `UNUserNotificationCenter` directamente reduce capas. Si el mensaje debe variar con cada carta, no debe usarse una única notificación repetitiva con contenido fijo: se pueden programar solicitudes individuales para un horizonte acotado y reponerlas al abrir la app, o usar un recordatorio genérico como “Your daily card is ready”. Esa elección afecta la experiencia y debe corresponder al producto aprobado. El MVP no necesita notificaciones remotas.

## Accesibilidad y comportamiento iOS

La interfaz actual no permite certificar una experiencia iOS lista:

- los `Pressable` principales no declaran roles, etiquetas ni estados accesibles;
- símbolos decorativos basados en texto pueden producir anuncios confusos en VoiceOver;
- muchas alturas, anchuras y tamaños de texto son fijos, con riesgo ante Dynamic Type;
- la barra inferior es absoluta y su relación con zonas seguras no se ha probado en dispositivos;
- no existe evidencia de contraste medido, Reduce Motion, VoiceOver, tamaños de toque o textos largos;
- el `SafeAreaView` usado está obsoleto en React Native actual;
- compartir y permisos no tienen manejo visible de errores.

Estos hallazgos no autorizan un rediseño. Deben convertirse en criterios de verificación cuando existan imágenes aprobadas para cada pantalla.

## Riesgos para App Store

### Altos antes de plantear un envío

1. **Toolchain no demostrada.** El proyecto no se puede reproducir tal como está y no acredita compilación con el SDK de iOS exigido actualmente.
2. **Completitud.** No hay icono/splash final, build number, proyecto de firma, artefacto, pruebas en dispositivo ni evidencia de estabilidad. Apple identifica fallos, contenido provisional y builds incompletas como causas frecuentes de rechazo bajo 2.1.
3. **Permiso y notificación sin validar.** La ruta de denegación y la repetición de contenido incorrecto pueden producir una experiencia engañosa o defectuosa.

### Medios

1. **Funcionalidad mínima (4.2).** Carta diaria, biblioteca de 36 cartas, guardados, compartir y recordatorio aportan interacción, pero sigue siendo una app de contenido pequeña. La propuesta de valor, la calidad de la experiencia nativa y el valor de retorno deben quedar claros; añadir funciones no aprobadas solo para “pasar revisión” sería un error.
2. **Privacidad.** El código revisado no envía datos, no crea cuentas y no incluye tracking. Aun así, Apple exige una URL de política de privacidad en App Store Connect y dentro de la app. El formulario de privacidad debe basarse en el binario final, no solo en este código.
3. **Privacy manifest.** `app.json` no declara uno y las dependencias no están instaladas, así que no se pudo comprobar qué manifiestos aportan los paquetes nativos. El binario final debe inspeccionarse y declarar los motivos de APIs requeridas cuando corresponda.
4. **Metadatos coherentes.** La configuración se llama “Tarot Cotidiano”, mientras la cabecera interna dice “Oraculo Cotidiano”. El lanzamiento inglés necesitará nombre, textos, screenshots y descripción coherentes con la experiencia final.

### Bajos con el alcance actual

- No hay cuenta, tracking, anuncios, compras, backend, contenido generado por usuarios ni tratamiento de datos personales.
- El recordatorio es local, opcional y relacionado con la función principal.
- Los textos actuales son reflexivos y no hacen afirmaciones médicas evidentes. El marketing final no debería presentar las cartas como diagnóstico, tratamiento, garantía o decisión profesional.

## Comparación de opciones

| Criterio | Conservar Expo/React Native | Migración gradual RN → SwiftUI | Rehacer en SwiftUI |
|---|---|---|---|
| Encaje con solo iOS/inglés | Correcto, pero conserva una capa multiplataforma no necesaria para v1 | Débil; mantiene dos pilas | Muy alto |
| Reutilización de UI actual | Alta técnicamente, aunque la UI no está aprobada | Parcial | Baja, y de poco valor por falta de aprobación |
| Reutilización de datos/lógica | Alta | Alta | Alta mediante conversión controlada |
| Tiempo inicial | Menor si la actualización sale limpia | Mayor e impredecible | Moderado para este alcance pequeño |
| Mantenibilidad a largo plazo | Buena tras actualización y modularización; exige cadencia Expo/RN | Baja por puentes, doble ciclo de vida y dos toolchains | Alta con frameworks de primera parte |
| Fidelidad a patrones iOS y accesibilidad | Posible, exige disciplina y librerías adecuadas | Posible, con complejidad de integración | Directa |
| Riesgo técnico de transición | Actualización SDK 53→actual y refactor del monolito | El mayor de los tres | Reimplementación y posible migración de datos |
| Dependencias de producción mínimas | No | No | Sí; viable con SwiftUI, Foundation y UserNotifications |
| Utilidad de una futura plataforma distinta | Ventaja potencial, fuera del alcance aprobado | Dudosa | Ninguna reutilización de UI; fuera del alcance aprobado |

### Opción 1: conservar Expo/React Native

No debería significar “seguir desde `App.js`”. El camino responsable sería congelar el prototipo, crear una base Expo compatible con el SDK estable vigente, copiar solo los comportamientos aprobados, usar TypeScript, separar dominio/datos/servicios/pantallas, bloquear dependencias y verificar con Expo Doctor, prebuild iOS, tests y dispositivo real. No hace falta Expo Router hasta que el mapa de pantallas aprobado demuestre que aporta valor.

Es la alternativa preferible si la competencia disponible es claramente JavaScript/React Native o si existe una obligación real de preservar usuarios con AsyncStorage mediante una actualización continua. Su coste permanente es seguir el ciclo Expo/React Native y validar dependencias nativas en cada actualización relevante de Apple.

### Opción 2: migrar gradualmente

No se recomienda. El producto no contiene módulos grandes, backend ni pantallas aprobadas que justifiquen mantener React Native mientras se sustituyen piezas. Un enfoque híbrido obligaría a resolver navegación y estado entre runtimes, packaging, depuración, accesibilidad y dos modelos de UI para conservar menos de 1.400 líneas de código fuente. Solo tendría sentido si se descubre una base instalada que exige entregas incrementales sin interrupción, circunstancia no acreditada en el proyecto.

### Opción 3: reinicio SwiftUI

Es la recomendación principal para el alcance confirmado. La arquitectura mínima podría ser:

- modelos inmutables `Card` y `Category` con IDs estables;
- contenido inglés empaquetado en un archivo legible y validable;
- selección diaria como función pura de calendario, con pruebas;
- preferencias pequeñas, versionadas y `Codable`;
- repositorio de contenido separado de la presentación;
- servicio de notificaciones sobre `UNUserNotificationCenter`;
- compartir mediante APIs del sistema;
- vistas SwiftUI creadas únicamente después de aprobar sus imágenes;
- pruebas unitarias del dominio/persistencia/notificaciones y pruebas UI de los recorridos aprobados.

No se necesita SwiftData para v1 ni una abstracción de localización. Tampoco se debe importar el CSS mental de la pantalla React Native: las imágenes aprobadas serán la fuente visual.

## Recomendación y decisión pendiente

**Recomendación:** aprobar un reinicio limpio en SwiftUI para iPhone y en inglés, manteniendo el directorio Expo actual intacto como referencia histórica. Reutilizar el esquema e IDs del contenido, traducir y revisar editorialmente el material que el MVP apruebe, y reimplementar solo los comportamientos confirmados con APIs nativas. No realizar una migración gradual.

**Decisión concreta que debe aprobar el propietario antes de abrir una tarea de implementación:**

> ¿Apruebo que Tarot Cotidiano v1 se reconstruya como una aplicación SwiftUI exclusivamente para iPhone y en inglés, preservando el prototipo Expo sin modificar, aceptando que una futura versión para otra plataforma sería independiente y condicionando cualquier migración de AsyncStorage a confirmar primero si existen usuarios reales con datos que deban conservarse?

Una aprobación afirmativa debe registrar también si el bundle ID `com.dmkra.tarotcotidiano` corresponde a una app ya distribuida. Si la respuesta arquitectónica es negativa, la alternativa a aprobar es un reinicio estructural sobre Expo SDK estable vigente, no una continuación directa sobre SDK 53.

## Secuencia recomendada después de la aprobación

Esta secuencia no autoriza implementación durante el hito actual:

1. Confirmar historial de distribución, titularidad del bundle ID y necesidad de migrar datos.
2. Preservar el prototipo con control de versiones y registrar el contenido fuente sin alterarlo.
3. Fijar versión mínima de iOS según dispositivos objetivo; no introducir persistencia más compleja de la necesaria.
4. Definir y validar el archivo de contenido inglés y sus IDs sin construir UI.
5. Especificar mediante pruebas la carta diaria, cambio de fecha/zona, guardados y recordatorios.
6. Esperar mapa de pantallas e imágenes aprobadas conforme a `visual-first-app-development`.
7. Implementar una pantalla cada vez con comparación visual, Dynamic Type, VoiceOver, contraste y zonas seguras.
8. Probar notificaciones y ciclo de vida en iPhone real.
9. Auditar el binario final: privacy manifest, privacidad de App Store, permisos, iconos, metadatos, política/soporte y compilación con el SDK exigido.
10. Solicitar autorización separada antes de TestFlight externo, envío o publicación.

## Criterios técnicos de salida para un candidato iOS

- build reproducible desde un checkout limpio y dependencias bloqueadas;
- compilación con una versión de Xcode/SDK aceptada por App Store Connect;
- cero crashes y promesas/errores de persistencia o notificación sin manejar;
- carta diaria estable y correcta en medianoche, cambio de año, DST y cambio de zona;
- restauración de guardados y preferencias con esquema versionado;
- permiso, programación, cambio de hora, cancelación y denegación de notificaciones probados en dispositivo;
- VoiceOver, Dynamic Type, contraste, zonas seguras y tamaños de toque verificados;
- copy e inventario de cartas completamente en inglés y revisados;
- icono, screenshots y metadatos finales coherentes con la aplicación;
- política de privacidad accesible y declaración de datos contrastada con el binario;
- comparación visual de cada pantalla implementada con su imagen aprobada.

## Fuentes oficiales consultadas

- [Apple — App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/), especialmente 2.1/2.3, 4.2, 4.5.4 y 5.1.
- [Apple — requisito de SDK para envíos desde el 28 de abril de 2026](https://developer.apple.com/news/?id=ueeok6yw).
- [Apple — versiones de Xcode, SDKs y deployment targets](https://developer.apple.com/xcode/system-requirements).
- [Expo — referencia y matriz vigente de SDK, React Native, React, iOS y Xcode](https://docs.expo.dev/versions/latest/).
- [Expo — actualización de requisitos mínimos de App Store Connect](https://expo.dev/blog/app-store-connect-minimum-sdk-26).
- [Expo — guía de actualización de SDK](https://docs.expo.dev/workflow/upgrading-expo-sdk-walkthrough/).
- [Expo — privacy manifests para iOS](https://docs.expo.dev/guides/apple-privacy/).
- [Expo — almacenamiento local y características de AsyncStorage](https://docs.expo.dev/develop/user-interface/store-data/).
- [Expo — notificaciones](https://docs.expo.dev/versions/latest/sdk/notifications/).
- [React Native — `SafeAreaView` obsoleto](https://reactnative.dev/docs/SafeAreaView).

Las condiciones de App Store y las versiones soportadas cambian con el tiempo; deben comprobarse de nuevo al preparar el candidato de distribución.
