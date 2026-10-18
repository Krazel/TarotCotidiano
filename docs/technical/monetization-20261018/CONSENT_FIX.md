# Consentimiento automático — 1.1.1 (1)

18/10/2026. **Disponible en TestFlight interno**, grupo Testers: VALID, INTERNAL_ONLY e IN_BETA_TESTING verificados por API; notas EN/ES guardadas y releídas. Repositorio privado restaurado tras la compilación temporal pública autorizada.

El usuario confirmó que 1.1 no mostraba anuncios hasta entrar en Opciones de publicidad y responder al formulario. El problema era que el inicio solo actualizaba el estado UMP, sin presentar el formulario obligatorio. La corrección recoge esa primera decisión automáticamente, antes de iniciar anuncios. Ajustes sigue permitiendo cambiarla. Una decisión ya guardada no se repite si UMP no la requiere.

La secuencia real usada por la app está probada: actualizar UMP → cargar formulario requerido → comprobar de nuevo que la pantalla es segura → presentar → consultar el permiso UMP e iniciar SDK. Una tirada iniciada durante la carga pospone el formulario; un error mantiene los anuncios apagados. No se simula consentimiento ni se fuerza aceptar. La geografía EEA forzada existe solo en DEBUG para la prueba del simulador y no se compila en TestFlight.

Validación: 57 XCTest y compilación iOS correctos; CI exige un evento real de carga de Google y una presentación automática EEA antes de firmar/subir. Capturas inspeccionadas:

- [Banner de prueba y pestañas visibles](consent-fix-qa/tarot-home-simulator.png).
- [Formulario automático al abrir sin entrar en Ajustes](consent-fix-qa/tarot-consent-eea.png).

[CI de entrega](https://github.com/Krazel/TarotCotidiano/actions/runs/39140082659); [compilación independiente](https://github.com/Krazel/TarotCotidiano/actions/runs/39140082947). Fuente: `31394078415f` (SHA completo y huella IPA en CONSENT_FIX_RECEIPT.json). La prueba de esta corrección en iPhone físico queda para TestFlight; el usuario confirmó el funcionamiento del banner tras consentimiento manual en la beta anterior.

Público 1.0 sin cambios; anuncios exclusivamente de prueba. Rediseño pausado. Biblioteca D1 PR-003 pendiente de escritura autorizada, conservada en LIBRARY_PENDING.json; no se afirma sincronización.

Referencias oficiales usadas: [UMP](https://developers.google.com/admob/ios/privacy) y [carga/presentación separadas](https://developers.google.com/admob/ios/privacy/api/reference/Classes/UMPConsentForm).
