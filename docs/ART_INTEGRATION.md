# Integración gráfica con Godot 4

**Fuente:** REPORTE GODOT ARCHITECT 005 / DIRECTRIZ MAIN 009. **Estado:** contrato técnico propuesto, sujeto a aprobación de MAIN y AGENT 03 para valores concretos.

## Contratos técnicos recomendados
- Integración prevista: `AnimatedSprite2D` y `SpriteFrames`; cantidades de frames variables.
- PNG RGBA con alfa real, un frame por archivo y mismo lienzo por personaje; spritesheet horizontal opcional sin solapamiento ni suavizado.
- Filtrado `Nearest`; revisar escalado entero y pixel snapping cuando se autorice.
- Orientación base propuesta: derecha (`+X`), `flip_h` para izquierda solo si el arte lo permite.
- Separar sprite, collider, hurtbox, hitbox y origen funcional. El lienzo no equivale al collider.
- Mantener paleta, anclaje y suelo; no recortar transparencia ni cambiar escala accidentalmente.

## Valores PROPUESTOS, NO aprobados definitivamente
| Ítem | Propuesta | Estado |
|---|---|---|
| Resolución interna | 640×360, 16:9 | PENDIENTE |
| Lienzo protagonista | 96×96 px | PROPUESTA |
| Anclaje protagonista | (48,88) | PROPUESTA |
| Lienzo Forajido Hueco | 128×128 px | PROPUESTA |
| Anclaje Forajido Hueco | (64,120) | PROPUESTA |
| Conversión física | 1 u = 24 px | PROPUESTA; el contrato aprobado es 1 u = anchura del collider |

**Importante:** inspeccionar decisiones artísticas posteriores y no sustituirlas por estas propuestas antiguas.

## Checklist
- PNG y spritesheets dentro del lienzo acordado, alfa válido y apoyo alineado.
- Metadatos de personaje, animación, frames, dimensión, anchor, fps, loop, orientación y paleta.
- No mover colliders mediante frames ni inferir reglas jugables del arte.

## Responsabilidades
Art Director: estética. Game Designer: reglas. Godot Architect: contratos técnicos. MAIN: conflictos y cambios transversales.
