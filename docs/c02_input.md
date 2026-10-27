# C02 — Input provisional

Este módulo captura intención de entrada; no mueve nodos ni ejecuta acciones
jugables. Las asignaciones iniciales son:

| Acción | Teclado/ratón | Mando |
| --- | --- | --- |
| Mover izquierda/derecha | A / D | Stick izquierdo X |
| Saltar | Espacio | Botón A |
| Esquivar | E | Botón B |
| Disparar | Botón izquierdo | Gatillo derecho |
| Recargar | R | Botón X |
| Fijar objetivo | Q | Pulsación del stick derecho |
| Apuntar | I / J / K / L | Stick derecho |

El origen temporal del apuntado con ratón es `Vector2.ZERO` en la arena, ya que
C02 no crea un jugador. Puede configurarse mediante `mouse_aim_origin`.

Política simultánea: una entrada válida de las acciones direccionales (teclas o
stick derecho) tiene prioridad sobre el ratón. Si queda dentro de la zona muerta
provisional `0.20`, se usa el ratón cuando su vector no es nulo. Si ninguna
entrada es válida, se conserva el último sector.

Las transiciones de botones se acumulan entre ticks mediante `_input()` y se
consumen una sola vez al crear el siguiente snapshot. Una pulsación y liberación
completas dentro del mismo tick produce `pressed = true`, `released = true` y
`held = false`. Varias transiciones dentro del tick conservan ambos eventos y el
estado final, sin repetirlos en el snapshot posterior.

La prioridad de apuntado se resuelve a partir del estado muestreado, no del orden
en que llegaron los eventos. Por ello la transición stick válido → stick en zona
muerta → ratón válido es estable: primero manda el stick y, en la captura
siguiente, manda el ratón.

Los sectores se numeran desde la derecha en sentido antihorario visual:
derecha, arriba-derecha, arriba, arriba-izquierda, izquierda, abajo-izquierda,
abajo y abajo-derecha. En un límite exacto siempre gana el índice menor.
