# Auditoría de derechos del arte Rider–Waite–Smith

Actualizado: 2026-08-11

## Conclusión operativa

Las ilustraciones históricas originales del mazo Rider–Waite–Smith están fuera de copyright en Estados Unidos y Reino Unido. En la Unión Europea, la obra subyacente también ha agotado el plazo ordinario de protección. Sin embargo, la evidencia actual **no permite certificar los 78 JPEG concretos para una distribución comercial mundial**.

Los archivos actuales siguen siendo candidatos internos:

- `candidateOnly=true`
- `finalAsset=false`
- `distributionApproved=false`
- `territorialRightsReviewStatus=pending`

No se debe contestar afirmativamente `Content Rights` para distribución mundial ni abrir todos los territorios de App Store con este conjunto.

## Conjunto exacto auditado

- 78 archivos JPEG del conjunto `TaionWC / Pam-A` de Wikimedia Commons.
- Los 78 `cardID` coinciden con el manifiesto canónico.
- URL, SHA-1, SHA-256, bytes, MIME y dimensiones están documentados y verificados en `native-ios/Content/provenance.v2.json` y `native-ios/Content/CandidateRWS/local-evidence.v2.json`.
- Las páginas de Commons identifican las cartas como reproducciones del mazo de 1909/1910 y las marcan con Public Domain Mark 1.0.
- No se incorporan restauraciones, recoloreados, dorsos, bordes, tipografía ni packaging de ediciones comerciales modernas.

## Obra histórica subyacente

### Estados Unidos

La U.S. Copyright Office confirma que, en 2026, todas las obras publicadas en Estados Unidos antes del 1 de enero de 1931 están en dominio público. El mazo se publicó en 1909/1910. Fuente: [U.S. Copyright Office — What is Copyright?](https://www.copyright.gov/what-is-copyright/).

### Reino Unido

El plazo ordinario para obras artísticas es la vida del autor más 70 años. Incluso usando la fecha conservadora de Pamela Colman Smith —fallecida en 1951—, el plazo terminó el 31 de diciembre de 2021 y la obra entró en dominio público el 1 de enero de 2022. Fuentes: [GOV.UK — How long copyright lasts](https://www.gov.uk/copyright/how-long-copyright-lasts) y [Copyright Notice: Duration of copyright](https://www.gov.uk/government/publications/copyright-notice-duration-of-copyright-term/copyright-notice-duration-of-copyright-term).

### Unión Europea y España

La Directiva 2006/116/CE establece vida más 70 años y cómputo desde el 1 de enero siguiente; para obras de país tercero también contempla comparación con el plazo del país de origen. Fuente: [Directiva 2006/116/CE](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX:32006L0116).

En España, el artículo 199.4 del texto refundido limita las obras cuyo país de origen conforme a Berna sea un país tercero al plazo del país de origen, sin exceder el español. Esa regla apunta al mismo vencimiento británico de 2021. La disposición transitoria cuarta y el antiguo plazo español de 80 años crean una cautela interpretativa para obras antiguas, pero no justifican por sí solos afirmar que las ilustraciones siguen protegidas hasta 2031. Fuentes: [TRLPI, artículos 26, 30 y 199.4](https://www.boe.es/buscar/act.php?id=BOE-A-1996-8930) y [Ley de 1879, artículo 6](https://www.boe.es/buscar/doc.php?id=BOE-A-1879-40001).

## Por qué los JPEG actuales no quedan aprobados mundialmente

1. **Public Domain Mark no es una licencia ni una garantía.** Creative Commons y Wikimedia indican que la marca describe una creencia sobre el estado de la obra, pero no garantiza que esté libre en todas las jurisdicciones. Wikimedia exige que quien reutiliza verifique el estado por sí mismo. Fuentes: [Creative Commons — Public Domain Mark 1.0](https://creativecommons.org/publicdomain/mark/1.0/) y [Wikimedia Commons — Reusing content](https://commons.wikimedia.org/wiki/Commons:Reusing_content_outside_Wikimedia).
2. **La autoría histórica aparece descrita de forma inconsistente.** Las páginas identifican a Pamela Colman Smith como creadora, pero calculan la plantilla `PD-old-80-expired` desde la muerte de Arthur Edward Waite, descrito como titular. Ser titular por encargo no demuestra universalmente que su muerte sea la fecha que fija el plazo.
3. **No existe una licencia o CC0 expresa del digitalizador.** Los archivos actuales son escaneos de mayor calidad subidos por TaionWC en 2024. En EE. UU. y, en general, Reino Unido/UE, una copia digital puramente fiel difícilmente genera un copyright nuevo; aun así, no hay una cesión expresa que resuelva cualquier derecho residual o derecho afín reconocido por todos los países.
4. **La distribución mundial incluye jurisdicciones no auditadas y plazos distintos.** La propia etiqueta de Commons limita su afirmación a determinados territorios. No existe una matriz completa de todos los storefronts de Apple que permita atestiguar derechos mundiales.

## Decisión de lanzamiento

La ruta recomendada es sustituir estos JPEG antes de la distribución pública por una de estas opciones:

1. arte propio original para las 78 cartas; o
2. un conjunto cuyo digitalizador esté identificado y conceda CC0 o licencia comercial mundial expresa, acompañado de una revisión territorial de la obra subyacente.

Los escaneos actuales pueden permanecer en builds internas de QA. No deben figurar como arte final de producción ni desbloquear `Content Rights`, territorios, TestFlight externo, App Review o publicación.

## Crédito de procedencia recomendado

Mientras el conjunto siga presente como referencia interna:

`Original illustrations by Pamela Colman Smith (1909/1910). TaionWC Pam-A scans via Wikimedia Commons. Public Domain Mark 1.0.`

Este crédito mejora la trazabilidad, pero no sustituye una licencia ni convierte el conjunto en distribuible mundialmente.

## Límite de esta auditoría

Esta es una conclusión operativa basada en fuentes oficiales y en la procedencia técnica exacta del repositorio; no es un dictamen jurídico vinculante. Ante una distribución comercial con estos mismos JPEG, la puerta correcta sigue siendo arte propio/licencia expresa o revisión profesional de los territorios seleccionados.
