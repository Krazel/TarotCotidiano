# Auditoría de derechos y procedencia de contenido

Actualizado: 2026-08-18
Alcance: candidata pública `1.0 (1)`; preparación de lanzamiento, no envío ni publicación.

## Conclusión operativa

Las 78 caras actuales son el arte visual definitivo por decisión expresa del propietario. Los archivos exactos están íntegros, enlazados uno a uno y conservan URL, SHA-1, SHA-256, bytes, MIME y dimensiones.

La aprobación de distribución es territorial, no mundial:

- `finalAsset=true`;
- `approvedTerritories=[US, GB, ES]`;
- `distributionApprovedForDeclaredTerritories=true`;
- `worldwideDistributionApproved=false`.

No se puede seleccionar ningún storefront fuera de Estados Unidos, Reino Unido o España sin ampliar primero esta auditoría. El `ReleaseGate` exige que se le pase la lista real de territorios pretendidos y rechaza cualquier código fuera de esa allowlist.

## Conjunto exacto de 78 caras

- Fuente: conjunto fiel `TaionWC / Pam-A` de Wikimedia Commons, correspondiente a las ilustraciones Rider–Waite–Smith de 1909/1910.
- Alcance: solo las 78 caras históricas. No incluye dorsos, icono, packaging, marca, tipografía ni una edición moderna.
- Evidencia fuente: `native-ios/Content/provenance.v2.json`.
- Evidencia local: `native-ios/Content/CandidateRWS/local-evidence.v2.json`.
- Integridad: 78/78 archivos, cero fallos, un `cardID` y un asset de runtime por registro.
- Transformación: los JPEG de runtime son los mismos bytes verificados; no se incorporan recoloreados, restauraciones, marcas de agua ni elementos editoriales modernos.

## Base territorial revisada

### Estados Unidos (`US`)

La obra publicada en 1909/1910 está en el dominio público. Además, el Compendium de la U.S. Copyright Office §909.3(A) indica que un escaneo o digitalización fiel de una obra de dominio público no contiene autoría nueva registrable. Fuente: [U.S. Copyright Office — Compendium, Chapter 900](https://www.copyright.gov/comp3/chap900/ch900-visual-art.pdf).

### Reino Unido (`GB`)

El plazo ordinario de las ilustraciones terminó después de la muerte de Pamela Colman Smith en 1951. La guía del UK Intellectual Property Office considera improbable que una reproducción digital simple cuyo objetivo sea fidelidad cumpla el umbral de originalidad para un copyright nuevo. Fuentes: [GOV.UK — How long copyright lasts](https://www.gov.uk/copyright/how-long-copyright-lasts) y [UK IPO — Digital images, photographs and the internet](https://www.gov.uk/government/publications/copyright-notice-digital-images-photographs-and-the-internet/copyright-notice-digital-images-photographs-and-the-internet).

### España (`ES`)

La obra histórica está fuera del plazo ordinario. El artículo 14 de la Directiva (UE) 2019/790 excluye derechos nuevos sobre el material resultante de reproducir fielmente arte visual ya en dominio público, salvo que el resultado sea una creación intelectual original. España transpone esa regla en el artículo 72 del Real Decreto-ley 24/2021. Fuentes: [EUR-Lex — Directiva (UE) 2019/790](https://eur-lex.europa.eu/eli/dir/2019/790/oj/spa) y [BOE — RDL 24/2021](https://www.boe.es/buscar/act.php?id=BOE-A-2021-17910).

La Directiva aporta una base armonizada, pero esta auditoría no declara automáticamente aprobados los otros Estados de la UE: no se han revisado aquí sus transposiciones, reglas transitorias y storefronts de forma individual.

## Activos visuales no históricos

`native-ios/Content/release-asset-provenance.v1.json` separa y fija:

- reverso Ceremonial Obsidian: asset creado para el proyecto y derivado de la dirección visual aprobada, con master y runtime byte-idénticos;
- icono D — Three-Card Fan: imagen generada para el proyecto, aprobada por el propietario y preparada como PNG iOS opaco de 1024×1024;
- fondo, rayos, estrellas, materiales y texturas: dibujo programático original en Swift; no existe una textura raster de terceros oculta en el target.

El validador comprueba las rutas y SHA-256 exactas. Un cambio exige actualizar su procedencia antes de otra candidata.

## Texto, significados y tutorial de seis cartas

- Los 78 significados y su traducción son copy editorial original documentado en `native-ios/Content/Localization/MEANING_METHODOLOGY.md`.
- Los tutoriales redactan instrucciones propias y breves; no reproducen texto de las fuentes.
- `Six-Card Guidance` cita a Katalin Jett Koda/Llewellyn para identificar el método factual de seis posiciones. La secuencia de posiciones y el método de una tirada son ideas o procedimientos; la app usa redacción independiente, no copia el artículo ni sus expresiones. Esta independencia consta también en `native-ios/Content/Education/THREE_CARD_SPREADS.md`.
- Una cita no se trata como licencia. Si el texto llegara a incorporar una reproducción literal o material gráfico de la fuente, esta conclusión dejaría de aplicar y habría que eliminarlo u obtener permiso.

## Crédito recomendado

`Original illustrations by Pamela Colman Smith (1909/1910). TaionWC Pam-A scans via Wikimedia Commons.`

El crédito preserva trazabilidad. No sustituye la allowlist ni implica licencia o clearance mundial.

## Puertas externas que siguen cerradas

Esta auditoría prepara evidencia local; no realiza atestaciones externas. Seleccionar territorios, confirmar Content Rights en App Store Connect, completar DSA trader para España, subir una build pública, enviarla a App Review o publicar requieren autorización separada y deben coincidir exactamente con `US/GB/ES` o un subconjunto.

## Límite

Es una decisión operativa de publicación basada en fuentes oficiales y en los archivos exactos del repositorio; no es asesoramiento jurídico vinculante. No debe extrapolarse a todo el mundo, otras ediciones, otras marcas ni futuros assets.
