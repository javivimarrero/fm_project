# Registro de decisiones técnicas

**Convenciones R1–R4:** expresamente aprobadas por MAIN en DIRECTRIZ 007. **No reinterpretar silenciosamente.**

| ID | Estado | Decisión / alcance |
|---|---|---|
| R1 | APROBADA | Un disparo comprometido captura dirección, objetivo, concentración y vulnerabilidad al compromiso; pérdida posterior no revierte su clasificación. |
| R2 | APROBADA | Ciclo de recarga completado antes o exactamente en el umbral del tick se acredita antes de procesar cancelación. |
| R3 | APROBADA | Evaluación discreta de contactos e invulnerabilidad por tick; una esquiva no evita daño ya confirmado. |
| R4 | APROBADA | En compromiso de disparo se capturan origen y geometría; movimiento posterior no cambia ese tiro. |

## Reglas posteriores de MAIN
- DIRECTRIZ 006: pérdida definitiva de fijación es terminal durante ese paso; concentración final 0.
- DIRECTRIZ 006: separar daño confirmado previamente de contactos actuales; sin evasión retroactiva.
- DIRECTRIZ 010: Godot 4.7.2 de referencia y autorización de Git y C02 finalizada.
- DIRECTRIZ 014: C03 exclusivamente después de commit inicial C01+C02; C04–C12 bloqueadas.

## Convenciones de implementación y estado
- **APROBADO:** Godot 4.7.2; uso de InputSnapshot C02; no alterar snapshots de ticks anteriores.
- **PROPUESTA TÉCNICA:** coordinador central por tick y nombres internos futuros; no añadir mecánicas anticipadas.
- **EXPERIMENTAL:** números de movimiento y demás parámetros jugables documentados.
- **PENDIENTE:** conversión px/u definitiva, contrato gráfico final, balance y arte maestro.

## Política de nuevos acuerdos
Añadir entradas solo tras confirmación expresa de MAIN o como decisión técnica interna claramente etiquetada, sin cambiar contratos jugables.

## Decisiones internas C03 — 27/10/2026
- **EXPERIMENTAL:** `pixels_per_unit = 24`, igual al ancho del collider provisional. Es configurable y no constituye contrato artístico.
- **EXPERIMENTAL:** liberación anticipada multiplica la velocidad ascendente por `0.50` para producir salto variable.
- **IMPLEMENTADA:** `Player` rechaza ids de snapshot ya consumidos; `MovementComponent` no lee `Input`.
