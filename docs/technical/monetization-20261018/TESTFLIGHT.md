# Candidata interna de anuncios — 1.1 (1)

18/10/2026. El usuario pausa el rediseño, autoriza completar anuncios y subir a TestFlight. Después autoriza expresamente hacer público temporalmente `Krazel/TarotCotidiano` para compilar por Actions y devolverlo a privado al terminar. Se usa API/CLI; no navegador. La tarea anterior de implementación terminó, por lo que esta continuación toma la propiedad de esta candidata. No se incorporan propuestas UI/UX.

API Apple comprobada: 1.0 READY_FOR_SALE; siete productos mensuales APPROVED y groupLevel 1; grupo interno Testers existente con acceso a todas las builds. 1.1 (1) no existe todavía. Credenciales protegidas disponibles en app-store-production, sin copiar sus valores.

Cambios de esta continuación: `TAROT_TEST_ADS` habilita exclusivamente IDs públicos de prueba en el workflow interno; el plist debe indicar `test-only`. Release normal conserva anuncios desactivados. Tutorial contextual clasificado como `readingTutorial`, con prueba de navegación y retorno; ampliada matriz de exclusión a 160 combinaciones. Settings explica el tratamiento de datos de la build de prueba. Se conservan UMP, retirada por los siete derechos y recordatorio persistente de 14 días. No hay publicidad real ni precios/productos nuevos.

El workflow ejecuta validadores, XCTest del paquete, compilación/arranque en simulador, archive firmado, comprobación del plist final, export interno y subida. La API de estado verifica procesamiento VALID, audiencia INTERNAL_ONLY y acceso al grupo Testers. No envía a App Review ni permite distribución externa.

Estado al preparar este archivo: comprobaciones estáticas locales PASS; CI/subida pendientes. La ejecución y resultado se anotarán en el recibo final. La captura de arranque no sustituye QA interactivo de consentimientos, StoreKit, VoiceOver ni escucha/gestos en dispositivo. Si Google no permite anuncios por configuración/consentimiento, se mantienen apagados; nunca se omite UMP para aparentar éxito.

La política pública debe reflejar por separado 1.0 sin anuncios y esta beta con los SDK de prueba. La activación real permanece fuera de alcance. Biblioteca D1 PR-003: pendiente de conciliar; no se afirma sincronización.
