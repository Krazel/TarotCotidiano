# Pantallas finales de publicidad — 1.1.2 (1)

**Disponible en TestFlight interno**, grupo Testers: VALID, INTERNAL_ONLY e IN_BETA_TESTING verificados por API el 18/10/2026 a las 17:08 UTC. Notas EN/ES guardadas y releídas. Repositorio privado restaurado y verificado. Evidencia: [FINAL_SCREENS_RECEIPT.json](FINAL_SCREENS_RECEIPT.json).

Encargo directo del 18/10/2026: conservar el diseño vigente y preparar la versión de TestFlight con textos definitivos. Sustituir «Support the App»/«Apoyar la app» por «Remove ads»/«Quitar anuncios» y retirar el aviso interno sobre anuncios de prueba. El rediseño visual sigue pausado.

## Cambios

- Ajustes: sección Publicidad y acceso Quitar anuncios, estado Sin anuncios activo o Suscripción mensual. Ayuda y contacto se conserva como destino separado.
- Hoja Quitar anuncios: beneficio, opciones mensuales, restauración, gestión, confirmaciones y accesibilidad coherentes en EN/ES. El estado activo oculta las ofertas nuevas. Conserva información de renovación y cancelación, privacidad y términos.
- Siete IDs existentes, precios vivos de StoreKit y derechos verificados conservados. No se crean productos ni se cambia ningún precio. La hoja de compra no muestra banner.
- Se retira el aviso de beta de Ajustes; la versión normal de la app permanece. El consentimiento automático de 1.1.1 se conserva, confirmado funcionando por el usuario.

## Comprobación

Las capturas de Ajustes y Quitar anuncios se generan con las vistas SwiftUI reales en simulador, en español e inglés. Los precios de esas capturas son fixtures DEBUG no interactivos para comprobar la composición: no acreditan una compra real. Release no incluye la entrada directa de QA ni sus precios. Los productos de la app instalada siguen cargándose de StoreKit.

Capturas inspeccionadas: [Ajustes ES](final-screens-qa/tarot-settings-spanish.png), [Quitar anuncios ES](final-screens-qa/tarot-remove-ads-spanish.png), [Settings EN](final-screens-qa/tarot-settings-english.png), [Remove ads EN](final-screens-qa/tarot-remove-ads-english.png). Títulos, opciones y textos visibles legibles, sin solapamientos. Las secciones inferiores continúan por desplazamiento; los destinos de restauración/gestión y la retirada del aviso interno se verifican también en fuente y catálogo. [Inicio con banner](final-screens-qa/tarot-home-simulator.png) y [consentimiento automático EEA](final-screens-qa/tarot-consent-eea.png) inspeccionados.

La CI comprueba tests Swift, compilación, un banner real de prueba de Google y presentación automática del formulario UMP EEA antes de firmar y subir. La build de TestFlight mantiene anuncios de demostración; esta limpieza de textos no activa anuncios reales ni publica una versión en App Store.

El primer intento de compilación detectó un condicional mal situado al extraer las ofertas. Se corrigió antes de cualquier subida; el intento fallido no produjo una beta.

La primera ejecución con la corrección se canceló prematuramente al superar doce minutos en una fase que combinaba compilación, arranque y capturas. El registro posterior mostró que había compilado y avanzado correctamente, con un simulador lento. Se repitió íntegramente como intento 2 del [run 39145715872](https://github.com/Krazel/TarotCotidiano/actions/runs/39145715872), conservando todas las comprobaciones.

## Nombres de la hoja de Apple

Los nombres aprobados de los siete productos eran «Monthly Supporter»/«Supporter mensual». La modificación directa mediante v1 devuelve 409 porque esa localización está activa. La API 4.4.1 permite preparar nuevas versiones de metadatos con localizaciones v2; se conservan IDs, duración, precios y derechos.

Textos preparados: «Remove ads» / «Quitar anuncios»; descripciones «Monthly subscription. No ads while active.» / «Suscripción mensual. Sin anuncios mientras esté activa.». El grupo usa los mismos nombres. Las versiones de metadatos quedan separadas de una publicación de la app: preparar un borrador no acredita su aprobación ni que la hoja de compra de Apple ya muestre el texto nuevo.

Los ocho borradores y sus dieciséis localizaciones fueron guardados y releídos: estado PREPARE_FOR_SUBMISSION, recibo APPLE_METADATA_DRAFTS.json. Se solicitó autorización separada para enviarlos a revisión porque puede cambiar sus nombres también en la versión pública. Mientras no llegue esa autorización, no se envían. La solicitud anterior de excepción de navegador quedó descartada al verificar la API v2; no se usó navegador.

Referencias oficiales: [versiones de suscripción](https://developer.apple.com/documentation/appstoreconnectapi/working-with-subscription-versions), [migración a v2](https://developer.apple.com/documentation/appstoreconnectapi/migrating-in-app-purchase-metadata-to-v2).

Biblioteca PR-003: actualización pendiente en LIBRARY_PENDING.json; no se afirma sincronización de D1. El recibo final adjunto acredita procesamiento, acceso interno, notas, QA y repositorio privado. App Store conserva 1.0 READY_FOR_SALE; la nueva build no se ha publicado en la tienda.
