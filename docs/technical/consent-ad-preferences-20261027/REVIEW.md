# Corrección de preferencias publicitarias — candidata local 1.2.1 (1)

27/10/2026. Propietario de esta corrección: tarea Tarot `01a14ee2-3d19-7be2-a2dd-b13fa1f6b609`, por encargo del cerebro de Studio. Estado: fuente preparada para revisión; no compilada, subida ni publicada. No se ha cambiado AdMob ni la privacidad pública.

## Estado comprobado

La API de Apple y la consulta pública de la tienda coinciden en la versión pública **1.2 (1)**, build `cb6ea8b2-c2b1-45f1-9fcc-9c022b3bfd58`. La revisión de app `32df187e-377e-4585-97fe-f4c75dacf28e` y la revisión de metadatos `530362ed-708a-44b0-9ba1-3625c28e6f2d` están COMPLETE. TestFlight: interno IN_BETA_TESTING; sin beta externa enviada. El dominio de desarrollador ya aparece públicamente. No confundir este estado con el registro del 18/10, cuando aún esperaba aprobación.

El diagnóstico de Studio del 27/10 acredita anuncios reales: 301 impresiones NPA y dos limitadas. En Estados Unidos, banner: Tarot 286 impresiones/eCPM USD0,60; Grabadora 35/USD5,50. La muestra es pequeña; esta comparación no identifica todas las causas ni permite prometer un aumento de ingresos. Evidencia fuente: `.studio/coordination/admob-revenue-audit-20261027.json`.

## Causa y corrección mínima preparada

1. Cada solicitud añadía `npa=1`, aunque el usuario permitiera personalización. Se elimina ese parámetro, sin sustituirlo por `npa=0`.
2. El SDK recibía PPT `.disabled` para toda la sesión. Se cambia a `.default`; nunca se fuerza `.enabled`.
3. Se conserva **publisher first-party ID desactivado**, sin incorporar ATT, AdSupport, IDFA, identificadores propios, mediación ni proveedores. Por tanto esta candidata no habilita el mecanismo de personalización mediante first-party ID que Google documenta para iOS sin IDFA. No se afirma que vaya a generar anuncios personalizados ni una mejora concreta.
4. UMP conserva actualización, presentación automática y opciones de retirada. GMA consume las señales regulatorias aplicables. `canRequestAds` permite un modo de servicio; no demuestra aceptación de personalización ni permiso de seguimiento. No se añade una lectura parcial de bits TCF ni se copia una elección a otro usuario o sesión.
5. Se mantienen el control de UMP al crear cada solicitud, retirada de la vista al cambiar preferencias, suscripción verificada, ausencia de banner en mesa y overlays, recordatorio de14d y las siete opciones EN/ES. SDKs conservados: GMA12.14.0/UMP3.1.0.

Google documenta que la señal más restrictiva prevalece: retirar NPA/PPT del editor no convierte una negativa del usuario en aceptación. Eso tampoco acredita por sí solo ausencia de seguimiento por todos los componentes del SDK. La nueva configuración debe reconciliarse con los textos y declaraciones antes de distribuirse.

## Puerta concreta pendiente de privacidad y distribución

La política pública y el recibo de privacidad del18/10 dicen expresamente que Tarot desactiva personalización y pide NPA en todos los casos. La candidata cambia esa promesa. **No se ha publicado con esos textos antiguos.** Preparado un texto EN/ES en `PRIVACY_COPY_PROPOSED.json`; el enlace existente permanece intacto.

Antes de distribuir: aprobar el cambio desde prohibición global a tratamiento determinado por las preferencias aplicables; revisar el comportamiento efectivo del SDK y compradores para mantener una declaración de seguimiento exacta; ajustar política y respuestas Apple solo donde corresponda. La ausencia de ATT no constituye prueba de ausencia de tracking. Si se pretende personalización mediante identificadores first-party o seguimiento entre empresas, requiere una decisión adicional explícita y el tratamiento/consentimiento y declaraciones correspondientes; esta candidata no lo activa.

La publicación de1.2 autorizada en A-072 no se trata como permiso ilimitado para nuevos cambios de privacidad. No se ha creado una versión1.2.1 en Apple ni alterado la versión pública. El workflow de subida histórico está fijado a1.2 y su validación rechaza la candidata1.2.1 antes de compilar/subir: deberá actualizarse para una entrega posterior autorizada.

## Verificación y vía de compilación

Validadores locales pertinentes y revisión independiente se registran junto a este documento. Son comprobaciones estructurales, no ejecución del SDK ni prueba del consentimiento en un iPhone. Swift/Xcode no están instalados localmente. No atribuir los59tests de1.2 a esta nueva fuente.

GitHub continúa PRIVATE. La consulta de cuota mediante `GET /users/Krazel/settings/billing/usage` devuelve404 y pide scope `user`; la sesión actual no permite verificar cuota/límite. No se amplían permisos, se activa gasto, se abre el código ni se lanza CI. Para compilar hace falta una vía privada con coste/cuota verificados o runner autorizado. La pauta pública antigua de la skill queda subordinada a la orden vigente de código privado.

Plan de QA tras resolver esas puertas: primera instalación EEE aceptar/rechazar/opciones parciales; US con y sin restricciones regulatorias; consentimiento ausente y error de actualización; reapertura y retirada; regreso a primer plano; suscriptor activo/restauración; mesa sin banner. Inspeccionar solicitudes de prueba para verificar que una negativa conserva tratamiento no personalizado/limitado y nunca usar `canRequestAds` como prueba de personalización. Comparar resultados publicitarios reales después de distribuir, con periodo/país/formato equiparables y sin prometer un eCPM.

## Fuentes oficiales consultadas

- https://developers.google.com/admob/ios/targeting?hl=en — PPT y precedencia restrictiva.
- https://support.google.com/admob/answer/14323214?hl=en — PPT y señales regulatorias.
- https://developers.google.com/admob/ios/privacy — UMP y permiso para solicitar anuncios.
- https://developers.google.com/admob/ios/privacy/idfa — ausencia de IDFA sin autorización ATT.
- https://support.google.com/admob/answer/14199649?hl=en — identificadores first-party y sus controles.
- https://developer.apple.com/app-store/user-privacy-and-data-use/ — tracking y responsabilidad de SDKs.

Biblioteca PR-003: sin sincronización afirmada. El cerebro informó lectura vigente revisión1 y rechazo previo de escritura; se conserva pendiente sin eludir restricciones y deberá releerse/CAS antes de guardar.
