# C03 — Movimiento y salto

**Estado:** implementado para validación técnica bajo DIRECTRIZ MAIN — 014. Parámetros experimentales.

## Conversión de unidades

Decisión técnica interna configurable: el collider provisional del jugador mide 24 px de ancho, por lo que `1 u = 24 px`. Esta conversión no aprueba dimensiones artísticas definitivas. Todos los valores se exportan desde `MovementComponent`.

| Contrato | Conversión actual |
|---|---|
| Velocidad 5 u/s | 120 px/s |
| Aceleración 0.12 s | 1000 px/s² |
| Frenado 0.10 s | 1200 px/s² |
| Salto 3 u | 72 px |
| Tiempo al ápice 0.35 s | gravedad 1175.51 px/s²; impulso 411.43 px/s |
| Coyote time | 0.10 s |
| Jump buffer | 0.10 s |

La liberación anticipada del salto multiplica la velocidad ascendente por `0.50`, también configurable.

## Flujo por tick

`InputController` crea un único `InputSnapshot` en `_physics_process`. Como primer hermano de la arena, se procesa antes del jugador. `Player` consume ese snapshot una vez, rechaza ids repetidos, actualiza `MovementComponent` y llama `move_and_slide()` para resolver suelo y paredes.

`MovementComponent` no consulta `Input`: recibe únicamente el snapshot inmutable, el delta, la velocidad previa y el estado de suelo.

## Representación provisional

DIRECTRIZ MAIN — 017 verificó que la escena del jugador estaba instanciada, dentro del viewport y correctamente conectada a C02, pero carecía de representación visible. `player.tscn` incluye ahora un `Polygon2D` rectangular cian de 24×48 px, alineado con el collider. Es una figura temporal, no un sprite ni una decisión artística definitiva.

## Alcance excluido

No se implementan esquiva, disparo, recarga, enemigos, concentración, animaciones definitivas, UI ni tareas C04–C12.
