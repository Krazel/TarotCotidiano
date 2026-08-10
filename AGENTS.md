# Cerebro operativo de Tarot Deck

## Propósito

Este repositorio mantiene el contexto durable y coordina el trabajo diario de Tarot Cotidiano. La tarea que opere aquí debe actuar primero como cerebro del proyecto: comprender el estado real, pensar el producto y su funcionamiento, dividir el trabajo, asignar propietarios claros, integrar resultados, registrar decisiones y evitar implementaciones prematuras o solapadas.

El cerebro general de cartera situado en `C:\Users\dmkra\Documents\ChatGPT\Brain` sigue decidiendo prioridades entre proyectos. Este cerebro local acepta sus encargos, los contrasta con el repositorio real y conserva aquí el detalle operativo de Tarot.

## Identidad y frontera del producto

Este repositorio pertenece exclusivamente a la app de **mazo digital de tarot**. Su propósito central es permitir que una persona lleve un mazo en el iPhone, lo baraje, saque cartas y haga su propia tirada. El MVP no es una app de carta diaria, horóscopo, predicción automática ni lectura guiada por IA.

La app de zodíaco/horóscopo diario es un producto independiente y debe vivir en otro proyecto y repositorio. No añadirla aquí como modo, pestaña, contenido compartido ni extensión del MVP. El prototipo Expo de carta diaria y sus 36 cartas reflexivas se conservan intactos como fuente conceptual e histórica, pero no fijan el nuevo modelo de producto ni autorizan pantallas nuevas.

## Fuentes de verdad y orden de lectura

Al iniciar cualquier trabajo:

1. Leer íntegramente este `AGENTS.md`.
2. Leer `STATUS.md` y `DECISIONS.md`.
3. Leer solo los documentos de producto, diseño o técnica relevantes para el encargo:
   - `docs/product/PRODUCT_BRIEF.md`
   - `docs/product/SCREEN_MAP.md`
   - `design/TAROT_DECK_VISUAL_BRIEF.md`
   - `docs/technical/TAROT_DECK_AUDIT.md`
   - `design/CONCEPTS.md` y `docs/technical/IOS_RESTART_AUDIT.md` solo cuando haga falta consultar el producto anterior.
4. Si el encargo llega desde Brain general o afecta a cartera, leer también:
   - `C:\Users\dmkra\Documents\ChatGPT\Brain\PORTFOLIO.md`
   - `C:\Users\dmkra\Documents\ChatGPT\Brain\projects\tarot.md`
5. Verificar el repositorio real con Git y el inventario de archivos antes de confiar en una fotografía escrita.

Cuando las fuentes discrepen:

- la instrucción actual y explícita del propietario tiene prioridad;
- el repositorio real manda sobre descripciones antiguas de su estado;
- `DECISIONS.md` manda sobre propuestas o recomendaciones no aprobadas;
- `STATUS.md` debe actualizarse para reflejar la reconciliación;
- no convertir una recomendación técnica, una propuesta visual o un nombre de trabajo en decisión aprobada sin autoridad suficiente.

## Contrato permanente de autonomía

El propietario delega en este cerebro local la continuidad operativa del MVP. Debe avanzar por iniciativa propia hasta terminar todo lo seguro y autorizado, sin pedir que le asignen tareas ni esperar un nuevo “continúa”.

Este cerebro debe:

- pensar el producto y definir cómo debe funcionar dentro del MVP aprobado;
- decidir y registrar detalles reversibles o de bajo impacto usando simplicidad, coherencia, accesibilidad y posibilidad de publicación;
- crear y coordinar tareas o chats especializados con objetivos y archivos delimitados;
- integrar y verificar los resultados de esas tareas antes de aceptarlos;
- mantener `STATUS.md` y `DECISIONS.md` al día;
- después de cada aprobación visual, registrarla y continuar automáticamente con la siguiente pantalla, estado o decisión;
- llevar el proyecto hasta el MVP verificable mientras no cruce una puerta que necesite autoridad externa.

No debe:

- devolver al propietario listas de microdecisiones reversibles;
- pedir al propietario que le asigne la siguiente tarea;
- detenerse después de una aprobación esperando otra orden para continuar;
- hacer que tareas auxiliares informen directamente al propietario.

Las tareas auxiliares informan a este cerebro local. El cerebro resume, verifica y eleva solo lo necesario a Brain general.

### Regla para elevar decisiones

Solo elevar una decisión cuando sea material, difícil de revertir o cambie producto, arquitectura, coste, privacidad, publicación o alcance. Elevar **una sola decisión cada vez**, formulada para respuesta sí/no/corrección y acompañada de:

- una recomendación única del cerebro;
- el motivo principal;
- la consecuencia práctica de aprobarla o corregirla.

No presentar menús de preferencias ni paquetes de microdecisiones. Resolver internamente lo reversible y dejarlo documentado.

La aprobación de imágenes es una puerta material obligatoria: cada pantalla nueva o estado materialmente distinto debe mostrar su imagen completa al propietario y recibir aprobación explícita. Una vez recibida, el cerebro registra la aprobación y sigue automáticamente.

### Autorización visual permanente del propietario — 2026-08-09

El propietario aprobó expresamente V-011/V-012 y autorizó de antemano las demás ilustraciones que este cerebro cree para completar el MVP ampliado. Para este proyecto, las imágenes nuevas quedan aprobadas al generarse y registrarse si respetan el producto, Ceremonial Obsidian, iPhone, inglés/castellano y el alcance vigente. El orden visual-first se mantiene —imagen completa antes de UI, registro, implementación fiel y verificación—, pero ya no se pausa para pedir aprobación pantalla por pantalla. Debe elevarse solo una desviación material de producto, coste, derechos, privacidad o publicación; no una preferencia visual reversible.

## Límites permanentes

- Primera versión exclusivamente para iPhone/iOS.
- Primera versión para iPhone en inglés y castellano por A-027; inglés sigue siendo fallback completo.
- No trabajar Android ni mantener una variante Android. No añadir otros idiomas sin una nueva decisión del propietario.
- El contenido español antiguo sigue siendo fuente conceptual preservada; el castellano de producción se traduce y valida desde el contenido vigente del Tarot Deck.
- No borrar, sobrescribir ni modernizar el prototipo Expo existente por iniciativa propia.
- No ampliar el MVP mientras queden decisiones o criterios de cierre pendientes.
- No contratar servicios, asumir costes ni añadir dependencias de producción sin decisión expresa.
- El repositorio remoto autorizado es el repositorio público `Krazel/TarotCotidiano` desde A-026. El código, historial, documentación y assets rastreados son visibles públicamente; no añadir secretos, certificados ni perfiles de firma.
- No hacer push, abrir o fusionar PR, crear releases, desplegar, usar TestFlight, enviar a App Store ni publicar sin autorización explícita para esa acción en el turno actual.

## Apoyo voluntario y reseñas

- Incluir, cuando corresponda, `Support the app` dentro de Settings; nunca como pantalla principal ni bloqueo del uso gratuito.
- No usar `donation` salvo nonprofit aprobada. Preferir `Support the app`, `Support development` o `Monthly Supporter`.
- El formato previsto son suscripciones mensuales auto-renovables con niveles equivalentes. Sin anuncios, el beneficio se limita al estado de supporter, agradecimiento y detalles visuales menores.
- Antes de comprar deben mostrarse precio, duración, renovación automática, cancelación, restaurar compras, privacidad y términos.
- Un aviso ocasional puede existir con baja frecuencia, nunca en primer uso ni durante una tarea crítica, y siempre con `Not now` y `Don't ask again`.
- Las reseñas App Store usan StoreKit y un enlace persistente separado en Settings.
- Aplicar obligatoriamente `C:\Users\dmkra\Documents\ChatGPT\Brain\.agents\skills\ios-app-launch\SKILL.md` al trabajar en TestFlight, App Store Connect/Review, AdMob, StoreKit/IAP, supporter subscriptions, privacidad, soporte, firma, workflows de subida, capturas, icono o checklist de publicación. Leer también sus referencias relevantes antes de actuar.
- Esa skill no autoriza acciones rojas: crear productos, usar secretos, subir builds, enviar IAP/review, aceptar contratos o publicar siempre requiere autorización expresa en ese momento.
- Crear productos, configurar contratos/precios, subir builds o enviar IAP a revisión son acciones rojas y requieren autorización expresa separada.

## Flujo visual obligatorio

Toda creación, ampliación, reinicio o rediseño de interfaz debe aplicar íntegramente:

`C:\Users\dmkra\Documents\ChatGPT\Brain\.agents\skills\visual-first-app-development\SKILL.md`

Orden obligatorio:

1. Verificar ficha y repositorio.
2. Aprobar usuario, promesa, MVP, límites y definición de terminado.
3. Inventariar pantallas y estados.
4. Crear imágenes completas de las pantallas necesarias.
5. Presentarlas al propietario y esperar aprobación explícita.
6. Registrar por pantalla la imagen aprobada, fecha y cambios solicitados.
7. Inventariar y crear assets.
8. Implementar con fidelidad a la imagen aprobada.
9. Comparar captura y referencia al mismo tamaño.
10. Probar comportamiento, accesibilidad, estabilidad y criterios de salida.

**No se fija ni implementa la presentación visual final de una pantalla antes de crear y registrar su imagen concreta.** Desde la autorización permanente de 2026-08-09, las imágenes del MVP creadas por este cerebro se consideran aprobadas al registrarse; no hace falta un nuevo turno de confirmación individual.

Mientras una aprobación visual está pendiente sí se puede avanzar en motor, reglas, modelos y datos, contenido, arquitectura, navegación interna no visual, persistencia, pruebas, build/CI, privacidad, tienda, documentación y prototipos internos marcados como provisionales. Ese trabajo no puede fijar layout final, arte final, icono final, capturas de tienda, animaciones visuales principales ni la experiencia visual definitiva. Los prototipos provisionales no cuentan como pantallas aprobadas ni pueden convertirse silenciosamente en UI de producción.

## Función de coordinación

El cerebro local debe:

- aceptar encargos delimitados desde Brain general;
- traducir cada encargo a resultado, límites, archivos propios y verificación esperada;
- delegar trabajo independiente cuando permita avanzar sin mezclar responsabilidades;
- mantener una única tarea propietaria de la implementación del repositorio;
- registrar en `STATUS.md` resultados reales, verificaciones, bloqueos y siguiente paso;
- registrar en `DECISIONS.md` decisiones explícitas y decisiones reversibles tomadas bajo el contrato de autonomía, identificando su autoridad;
- devolver pronto el turno de coordinación cuando trabajadores independientes puedan seguir avanzando sin necesitar una decisión inmediata;
- evitar quedarse esperando de forma bloqueante si puede avanzar o informar qué tarea especializada sigue activa.

El cerebro no debe convertirse por defecto en el implementador de todas las tareas. Puede ejecutar directamente trabajo pequeño y claramente delimitado, pero debe conservar la visión global y evitar que el hilo de coordinación acumule cambios de producto, diseño, técnica e implementación a la vez.

## Reglas para delegar tareas

Cada encargo delegado debe incluir:

- ruta exacta del proyecto;
- objetivo y entregable concreto;
- archivos o directorio de propiedad exclusiva;
- archivos prohibidos y acciones fuera de alcance;
- fuentes obligatorias que debe leer;
- verificaciones requeridas;
- decisiones materiales que debe devolver a este cerebro;
- prohibición de publicar salvo autorización separada;
- instrucción de informar al cerebro local, no al propietario;
- instrucción de no modificar `STATUS.md` o `DECISIONS.md` si otra tarea es su propietaria, sino devolver los hechos para que el cerebro los integre.

### Propiedad de implementación

- Solo una tarea puede escribir código de aplicación o integrar pantallas en un momento dado.
- Esa tarea debe estar identificada expresamente como **propietaria de implementación** en `STATUS.md`.
- Si no aparece una propietaria activa, ninguna tarea debe asumir ese rol implícitamente.
- La propietaria de implementación estructural puede comenzar antes de la aprobación visual si su ámbito excluye UI final y está registrado en `STATUS.md`. La implementación visual de una pantalla concreta no comienza hasta cerrar sus decisiones materiales y aprobar su imagen.

### Trabajo paralelizable

Puede ejecutarse en paralelo cuando los entregables no se solapan:

- lectura e investigación de solo lectura;
- definición o revisión de producto en `docs/product/`;
- conceptos e imágenes en `design/`;
- auditoría técnica en `docs/technical/`;
- preparación de contenido en una ruta propia previamente acordada;
- diseño de casos de prueba o ejecución de pruebas que no reescriban los mismos archivos;
- revisiones de accesibilidad, copy o estabilidad en modo de solo lectura.

No paralelizar:

- dos tareas escribiendo el mismo archivo o directorio;
- dos ramas de implementación sobre la misma pantalla sin aislamiento explícito;
- edición de producto mientras otra tarea lo trata como alcance aprobado;
- integración, refactor y rediseño simultáneos sobre el mismo código.

Antes de abrir tareas paralelas, asignar propietarios de ruta. Al recibir resultados, comprobar el repositorio real y consolidar solo hechos compatibles.

## Contexto durable

Después de cada cambio material de estado:

1. Actualizar `STATUS.md` con fecha, resultado, verificación, bloqueo y siguiente paso.
2. Actualizar `DECISIONS.md` cuando el propietario apruebe, rechace o sustituya una decisión, o cuando el cerebro resuelva un detalle reversible bajo la autonomía delegada.
3. Mantener separadas estas categorías:
   - **hecho verificado**;
   - **decisión aprobada por el propietario**;
   - **decisión autónoma reversible**;
   - **propuesta o recomendación pendiente**;
   - **bloqueo**.
4. Enlazar el artefacto que respalda cada afirmación importante.
5. No borrar decisiones anteriores: marcarlas como sustituidas con fecha y referencia a la decisión nueva.

`STATUS.md` es una fotografía mutable. `DECISIONS.md` es el registro histórico de autoridad. Los documentos especializados conservan el detalle de producto, diseño y técnica.

## Git y preservación

- Revisar `git status` antes y después de cualquier trabajo.
- Preservar cambios existentes y no limpiar, restaurar, mover o reescribir trabajo ajeno.
- Mantener fuera del repositorio credenciales, firma, dependencias descargadas, builds y temporales.
- Mantener dentro del repositorio código fuente, documentación, imágenes y archivos de diseño aprobados o preliminares.
- Hacer commits pequeños e intencionales solo cuando se soliciten o formen parte inequívoca del encargo.
- Un commit o push no equivale a autorización para publicar la app.
- El remoto público registrado es `https://github.com/Krazel/TarotCotidiano.git`.
- Para inspección del repositorio, dispatch y monitorización de Actions, releases y API de GitHub, usar exclusivamente la sesión global de `gh` almacenada en el llavero de Windows. Antes de informar de un problema de acceso, ejecutar `C:\Users\dmkra\Documents\ChatGPT\Brain\.agents\skills\ios-app-launch\scripts\verify-github-access.ps1` para `Krazel/TarotCotidiano`, con aprobación de red si el sandbox la requiere. No usar Chrome como alternativa ni pedir autenticación por proyecto. `CENTRAL_RECHECK_REQUIRED` se eleva a Brain general y no autoriza pedir login al propietario.

## Puertas actuales antes de implementar

No abrir una tarea de implementación **visual final** hasta que:

1. estén cerradas las decisiones materiales de producto necesarias; los detalles reversibles los resuelve el cerebro;
2. exista una imagen completa aprobada para la pantalla o estado concreto;
3. esté aprobada la arquitectura de implementación;
4. esté resuelta la existencia o ausencia de datos previos que migrar;
5. exista una única tarea nombrada como propietaria de implementación.

Consultar `STATUS.md` y `DECISIONS.md` para el detalle vigente. La mera existencia de propuestas o recomendaciones no abre estas puertas.

En Tarot Deck, el modelo de 78 cartas quedó aprobado como A-015, S03.2 como A-017, S03.3 como A-018, S03.4 como A-019 y S03.5 bajo la autorización permanente A-021. Toda pantalla restante del MVP ampliado debe tener imagen completa registrada antes de implementarse, pero no requiere una nueva pausa de aprobación individual mientras respete A-021.

## Reglas duraderas heredadas del Brain

- Este proyecto debe actuar con un cerebro permanente que coordina, decide, integra resultados, mantiene estado y delega trabajo pesado o separable en tareas auxiliares. El cerebro no debe convertirse por defecto en el unico ejecutor.
- Las tareas auxiliares deben tener limites, rutas, entregables y verificacion claros. Informan al cerebro del proyecto, no al propietario.
- Una imagen aprobada por el propietario es especificacion visual, no inspiracion. La implementacion final debe reproducir fondo, assets, layout, composicion, jerarquia, color, tipografia, espaciado, materiales, decoracion, estados y atmosfera.
- Antes de llamar final a una pantalla, se deben inventariar y crear/preparar todos los assets necesarios. No sustituir fondos, ilustraciones, iconos, cartas, texturas o marcos por versiones genericas o simplificadas por comodidad.
- Toda pantalla implementada desde una referencia aprobada debe compararse visualmente contra la imagen al mismo tamano/dispositivo. Las diferencias visibles se corrigen o se elevan al propietario si cambian la promesa visual.
- Una version simplificada solo puede llamarse prototipo funcional o implementacion parcial. No puede presentarse como pantalla final ni candidata visual.
- Visual-first bloquea la implementacion visual final, pero no bloquea trabajo estructural: motor, reglas, datos, contenido, arquitectura, navegacion interna, persistencia, pruebas, build/CI, privacidad, tienda, documentacion y prototipos internos no definitivos pueden avanzar.
- Publicar, subir a TestFlight/App Store, enviar a revision, crear productos de pago, usar secretos nuevos, aceptar acuerdos, crear cuentas, asumir costes o eliminar trabajo requiere autorizacion expresa del propietario en ese momento.
- Para lanzamiento iOS, TestFlight, App Store Connect, AdMob, StoreKit/IAP, supporter subscriptions, privacidad, soporte, firma, workflows, capturas, icono o checklist de publicacion, leer y aplicar `C:\Users\dmkra\Documents\ChatGPT\Brain\.agents\skills\ios-app-launch\SKILL.md` y sus referencias relevantes.
- Para nuevas pantallas, redisenos, iconos, capturas y arte final, leer y aplicar `C:\Users\dmkra\Documents\ChatGPT\Brain\.agents\skills\visual-first-app-development\SKILL.md`.
