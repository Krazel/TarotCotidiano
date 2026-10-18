# Entrega interna de anuncios — 1.1 (1)

18/10/2026. **Disponible en TestFlight interno**, grupo existente Testers. API Apple releída: VALID, INTERNAL_ONLY, IN_BETA_TESTING, no caducada; pertenencia al grupo y notas EN/ES verificadas. ID de build: `984ee966-7966-4d8c-8886-c0e18ebf118b`. La versión pública sigue siendo 1.0 READY_FOR_SALE. No hay pruebas externas ni envío a App Review.

El usuario pausó el rediseño, autorizó completar los anuncios y subir la beta. Autorizó expresamente abrir temporalmente GitHub para CI y reutilizar el certificado .p12, contraseña y perfil como secretos cifrados de app-store-production. Repositorio `Krazel/TarotCotidiano` **privado de nuevo**, verificado por API después de la subida. Todas las operaciones Apple y GitHub se realizaron mediante API/CLI. No se revocó ni creó ningún certificado; se reutilizó el de distribución vigente y se creó el perfil propio de Tarot.

## Cambios entregados

- Banner adaptativo con los identificadores oficiales de prueba de Google, UMP y retirada por los siete derechos Apple existentes. Fallos, carga pendiente y ausencia de consentimiento dejan cero espacio reservado.
- Ausencia de anuncios durante mesa, significado y tutorial contextual. Prueba de navegación y matriz de exclusión de 160 combinaciones.
- Recordatorio opcional persistente, nunca primer arranque y como máximo cada 14 días, con descarte permanente.
- Banner fuera de TabView para conservar las pestañas nativas. Ajustes explica la privacidad de esta beta. No se incorporó el rediseño ni cambiaron precios/productos.
- Release ordinario conserva anuncios apagados; solo el workflow interno activa `TAROT_TEST_ADS` y exige `TarotAdvertisingMode=test-only`. No hay anuncios reales activos.

## Verificación

Fuente compilada: `06cdf95c05b5454453959e265294d2388b7f5811`.
[CI de entrega](https://github.com/Krazel/TarotCotidiano/actions/runs/39138085413): validadores, 53 XCTest, simulador, archive Release firmado, comprobación de identidad/entitlements/IDs de prueba, exportación interna y subida correctos. La IPA no se publicó como artefacto de GitHub; se conserva manifiesto con SHA-256. [CI de compilación independiente](https://github.com/Krazel/TarotCotidiano/actions/runs/39138082210) también pasó.

Captura anterior: banner oficial Google «Test mode» observado. Captura de la fuente entregada: tres pestañas visibles; el anuncio no era visible a los ocho segundos del arranque. Esto comprueba el estado sin anuncio, no demuestra carga posterior en esa ejecución. No se afirma QA interactivo de compra/restauración, consentimiento regional, rotación ni dispositivo físico: son comprobaciones que quedan para TestFlight. Notas EN/ES incluyen estas pruebas. La subida avisó de dSYM ausentes de los dos SDK binarios de Google; no impidió la aceptación ni el procesamiento de Apple.

Política pública actualizada y HTTP 200 verificado en https://krazel.github.io/tarot-deck/privacy/; distingue la app pública 1.0 de la beta 1.1 con SDK de anuncios. Commit del sitio público: `2aa2d66372ceffe0637383ec94ab28ff32de60b8`.

Recibo completo: [TESTFLIGHT_RECEIPT.json](TESTFLIGHT_RECEIPT.json). Evidencia local adicional: `.studio/tarot-ads-testflight-20261018/` en Studio.

Biblioteca D1 PR-003: actualización pendiente de un canal de escritura autorizado. El conector actual permite lectura; el bloqueo previo de escritura no se eludió. Pendiente guardado en `LIBRARY_PENDING.json`, conservando ID/revisión conocida y valores anteriores; hay que releer y combinar la revisión vigente antes de guardar. No se afirma sincronización.
