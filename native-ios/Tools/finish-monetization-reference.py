from pathlib import Path

root = Path(__file__).resolve().parents[2]
svg = root / 'design/monetization-20261018/integration.svg'
text = svg.read_text(encoding='utf-8')
text = text.replace('Tu referencia para leer a tu manera', 'Una guía para leer a tu manera')
text = text.replace('Preparar · observar · interpretar', 'Preparar · observar · leer')
text = text.replace('Cualquier nivel mensual retira</text><text x="42" y="353" class="body muted">los anuncios mientras esté activo.',
                    'Cualquier nivel mensual</text><text x="42" y="353" class="body muted">retira los anuncios.</text><text x="42" y="377" class="body muted">Mientras esté activo.')
text = text.replace('Cualquier nivel mensual retira</text><text x="187" y="352" text-anchor="middle" class="body muted">los anuncios mientras esté activo.',
                    'Cualquier nivel mensual</text><text x="187" y="352" text-anchor="middle" class="body muted">retira los anuncios.</text><text x="187" y="378" text-anchor="middle" class="body muted">Mientras esté activo.')
text = text.replace('Gracias por apoyar el desarrollo.', 'Gracias por apoyar la app.')
text = text.replace('La app completa sigue siendo gratis.', 'La app completa sigue gratis.')
text = text.replace('x="42" y="377"', 'x="42" y="368"')
text = text.replace('x="42" y="391"', 'x="42" y="403"')
text = text.replace('x="42" y="429"', 'x="42" y="435"')
text = text.replace('x="42" y="459"', 'x="42" y="464"')
svg.write_text(text, encoding='utf-8')
