# CI y comprobaciÃ³n nativa de consentimiento y ATT â€” 29/10/2026

Estado de este subencargo: preparación local; esta tarea auxiliar no ha ejecutado Xcode, simulador, firma, CI ni subida. Por A-076, el propietario humano autorizó el repositorio público para CI y su vuelta a privado cuando esté todo aprobado. El padre comunica que ya verificó el cambio de visibilidad y lanzó el run interno 40918369100, fuente e02e295, candidata 1.2.1 (1); este documento no certifica su resultado ni ejecuta operaciones remotas. Antes de cualquier envío adicional debe consultarse de nuevo Apple. La excepción pública autorizada sustituye el bloqueo anterior por cuota privada sin otorgar permiso para gastos nuevos.

## Pipeline interno preparado

`.github/workflows/tarot-testflight-internal.yml` mantiene ejecuciÃ³n manual en main, confirmaciÃ³n exacta, entorno `app-store-production`, certificado/perfil existentes y secretos sin exposiciÃ³n. Simulador, pruebas y archive fuerzan los identificadores de demostraciÃ³n Google y `TAROT_TEST_ADS`; los dos identificadores se comprueban en simulador, archive e IPA. Se conservan pruebas Swift, QA de banner/formulario UMP, pantallas EN/ES y XCUITest del consentimiento. Las capturas de importes/estado activo son fixtures DEBUG de presentaciÃ³n, no compras.

Se aÃ±ade inventario del Xcode y runtimes reales, dispositivos y salida completa de `xcrun simctl help privacy`. La inspecciÃ³n no cambia permisos. No se presupone que el runner soporte un servicio CLI de tracking: el workflow no ejecuta grant/revoke/reset, no escribe TCC y no sustituye el estado ATT por un argumento de la app. La falta de ese servicio no impide las pruebas UMP que sÃ­ soporta el runner. La captura de pantallas y del resultado nativo se intenta conservar tambiÃ©n tras fallos.

Evidencias previstas: `TarotConsentQA.xcresult`, `tarot-consent-tests.log`, `tarot-qa-xcode-version.txt`, `tarot-qa-simulator-runtimes.json`, `tarot-qa-simulator-devices.json`, `tarot-qa-simctl-privacy-help.txt`, capturas y logs de banner/formulario. Los artefactos QA conservan un dÃ­a de retenciÃ³n. El manifiesto/checksum de la IPA conserva commit, versiÃ³n/build y finalidad; la IPA y firma no se publican como artefactos.

## QuÃ© acredita cada prueba

| ComprobaciÃ³n | Evidencia necesaria | LÃ­mite |
| --- | --- | --- |
| UMP pendiente, aceptar, rechazar y revocar | XCUITest sobre formulario real sample; estado y contadores observados | No demuestra que el mensaje IDFA configurado para el publisher real se sirva con los IDs sample. |
| Estado ATT del SO | ObservaciÃ³n `trackingAuthorization` con notDetermined/restricted/denied/authorized y capturas | Registrar un estado no demuestra haber visto ni pulsado el prompt. |
| Prompt ATT y mensaje IDFA reales | Captura del mensaje publicado, alerta del sistema, acciÃ³n humana/XCUITest y transiciÃ³n de estado | Si Google sample no sirve ese mensaje, queda pendiente y no se reemplaza por una aprobaciÃ³n simulada. |
| PolÃ­tica del cÃ³digo en estados sintÃ©ticos | Tests unitarios de decisiones y seÃ±alizaciÃ³n | No se etiquetan como autorizaciÃ³n real del SO ni QA de SDK en dispositivo. |
| Entrega efectiva de anuncios | Banner sample, solicitudes y errores | No valida demanda, segmentaciÃ³n, ingresos ni eCPM de producciÃ³n. |

Contrato coordinado con la propietaria de app: `qaState.trackingAuthorization` serÃ¡ observaciÃ³n del estado real; el flujo de mensaje IDFA se integrarÃ¡ mediante UMP. Este documento y el workflow no modifican la app ni los UITests. La suite debe ser reconciliada con ese contrato antes de ejecutarla; ningÃºn resultado antiguo valida la integraciÃ³n nueva.

## Control de permisos y QA adicional

InspecciÃ³n reproducible en un Mac autorizado, sin modificar permisos:

```sh
xcodebuild -version
xcrun simctl list runtimes -j
xcrun simctl help privacy
```

Apple documenta `XCUIApplication.resetAuthorizationStatus(for: .userTracking)` para restablecer ese recurso desde XCUITest. Su propietario puede usarlo para preparar un escenario de permiso sin decidir la respuesta por el usuario. Si se considera un comando de `simctl privacy`, usar exclusivamente el nombre de servicio y operaciones que anuncie la ayuda del Xcode real y comprobar despuÃ©s `ATTrackingManager.trackingAuthorizationStatus`; no adivinar `tracking`, alterar TCC ni tratar un comando sin error como prueba del prompt. No se aÃ±ade ese comando al pipeline actual.

Para el flujo real, verificar instalaciÃ³n limpia, ausencia de decisiÃ³n, aceptaciÃ³n y rechazo de UMP, autorizaciÃ³n y denegaciÃ³n de ATT, permiso restringido/no disponible, relanzamiento, cambio/revocaciÃ³n de cada elecciÃ³n y retorno desde Ajustes. Mantener las dos decisiones separadas: poder solicitar anuncios no autoriza tracking; un rechazo o permiso invÃ¡lido no debe habilitar identificadores. Registrar orden y nÃºmero de formularios, estado ATT, seÃ±ales aplicadas y primera solicitud antes/despuÃ©s de cada cambio. Comprobar que la mesa activa y una suscripciÃ³n vÃ¡lida siguen sin anuncios. El texto del prompt debe probarse en inglÃ©s y espaÃ±ol. No registrar IDFA u otros identificadores completos en logs o artefactos.

Un simulador puede no reproducir todas las condiciones de un iPhone. Los casos no alcanzados deben quedar pendientes de dispositivo real. Si hace falta probar la configuraciÃ³n publicada con identificadores propios, diseÃ±ar una ejecuciÃ³n separada con dispositivo de prueba AdMob y autorizaciÃ³n aplicable; no cambiar el pipeline sample para generar trÃ¡fico real ni pulsar anuncios reales.

## Candidata futura apta para App Store

Este workflow conserva `testFlightInternalTestingOnly=true` tanto en exportaciÃ³n como en subida. Una build asÃ­ no puede enviarse posteriormente a App Review ni a clientes externos. No existe una operaciÃ³n de promociÃ³n de esta build interna a pÃºblica.

Por ampliaciÃ³n del encargo del29/10 se prepara tambiÃ©n `.github/workflows/tarot-app-review-rc.yml` y su validador para 1.2.1 (1), sin ejecutarlos. El workflow usa pruebas Debug con sample IDs y los XCUITest de consentimiento antes de leer secretos de firma; conserva el archive de producciÃ³n, comprueba los IDs exactos de Tarot y exige textos ATT EN/ES presentes tanto en archive como en IPA. Exporta y sube con `testFlightInternalTestingOnly=false`, pero no envÃ­a a revisiÃ³n. Solo archiva capturas, resultados nativos y manifiesto/checksum; nunca la IPA ni secretos.

Sus entradas manuales bloquean el job por defecto: `PUBLIC_1_2_1_BUILD_1`, `release_readiness=PRIVACY_SOURCE_REVIEWED`, `verified_source_sha` igual al commit completo ejecutado, una referencia no sensible a la revisiÃ³n de privacidad/cÃ³digo y una vía sin gasto explícita en `private_ci_clearance`: `PRIVATE_CI_NO_SPEND_VERIFIED` o `PUBLIC_STANDARD_RUNNER_NO_SPEND_VERIFIED` conforme a A-076. Son declaraciones explÃ­citas del operador con evidencia externa, no certificaciones automÃ¡ticas. Se registra `automatedPrivacyCertification=false` y `automatedPhysicalATTValidation=false`. No rellenarlas mientras sigan pendientes esa revisiÃ³n de privacidad/cÃ³digo o la cuota. Las pruebas nativas de ese run deben pasar igualmente; la declaraciÃ³n no las salta. El QA fÃ­sico del binario y del prompt configurado se realiza despuÃ©s de obtenerlo en TestFlight y bloquea el envÃ­o posterior a App Review, no su compilaciÃ³n/subida inicial.

Antes de checkout, el job consulta los metadatos del mismo repositorio con `github.token` y permisos de lectura, sin imprimir el token. Exige visibilidad pública para la vía pública, o privada para la alternativa privada; un error de API o discrepancia detiene el job. La consulta no mide facturación: `ci-route.json` registra `billingVerifiedByAPI=false`, visibilidad, vía y runner. No cambia la visibilidad ni autoriza una transición adicional. Los controles de privacidad, SHA, evidencia y finalidad permanecen intactos.

Los workflows interno y apto para tienda comparten por ahora la misma candidata propuesta 1.2.1 (1): no lanzar ambos para subir ese mismo par. Elegir la finalidad y volver a consultar los pares aceptados en Apple antes de ejecutar. `tarot-testflight-status.yml` todavÃ­a conserva filtros 1.1.2: no usar su resultado para afirmar el estado de 1.2.1 sin corregirlo o consultar la API con los filtros exactos.

Antes de construir una candidata apta para tienda:

1. Verificar cuota/runner/almacenamiento/acceso privados sin gasto y la vigencia real de firma. Mantener las operaciones de envÃ­o con su autorizaciÃ³n vigente.
2. Revisar el cÃ³digo exacto, las cadenas EN/ES, manifiestos y exclusiÃ³n de hooks DEBUG. Ejecutar el QA nativo automatizado del workflow antes de firmar/subir; el QA fÃ­sico del binario resultante queda para TestFlight.
3. Reconciliar polÃ­tica pÃºblica y App Privacy con los datos y tracking realmente permitidos; comprobar configuraciÃ³n UMP/IDFA publicada en la cuenta correcta y los identificadores propios.
4. Preparar un archive/export apto para App Store con la finalidad explÃ­cita correspondiente, sin la restricciÃ³n internal-only. La build sample interna no se reutiliza como binario pÃºblico.
5. Consultar por API pares versiÃ³n/build existentes, aplicar `versioning.md` al contenido final y evitar reutilizar un par ya aceptado. Si se envÃ­a primero 1.2.1 (1) interna, la futura candidata necesitarÃ¡ un par nuevo adecuado a su contenido. Mantener SHA/run/finalidad coherentes.
6. Releer el procesamiento y audiencia por API y obtener la build apta para tienda en TestFlight. Completar sobre ese binario el QA fÃ­sico de consentimiento, ATT/IDFA, first-party y del mensaje configurado; resolver cualquier diferencia con privacidad antes de seleccionar/enviar la build exacta a App Review. RevisiÃ³n y publicaciÃ³n no se deducen del Ã©xito de CI ni de TestFlight.

## Fuentes oficiales revisadas

- [Apple: permisos protegidos, incluido userTracking](https://developer.apple.com/documentation/xcuiautomation/xcuiprotectedresource).
- [Apple: resetAuthorizationStatus(for:)](https://developer.apple.com/documentation/xcuiautomation/xcuiapplication/resetauthorizationstatus(for:)).
- [Apple: capacidades de simctl y consulta de su ayuda](https://developer.apple.com/videos/play/wwdc2020/10647/).
- [Apple: distribuciÃ³n y restricciÃ³n TestFlight Internal Only](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases).
- [Apple: las builds internas no pueden enviarse a App Review](https://developer.apple.com/tutorials/develop-in-swift/test-your-beta-app).

VerificaciÃ³n local de esta preparaciÃ³n: validadores de ambos workflows y `git diff --check`; no equivale a compilaciÃ³n Swift, ejecuciÃ³n XCUITest ni prueba ATT. El smoke inicial todavÃ­a espera un banner sample: si el mensaje de Google exige una interacciÃ³n ATT que el smoke no resuelve, se detiene antes de firmar. Ese resultado requiere ajustar/ejecutar el escenario nativo adecuado; no autoriza un permiso forzado ni declarar superado el prompt.
