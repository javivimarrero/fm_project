# C04 — Coordinación de acciones

**Estado:** implementado para validación técnica bajo DIRECTRIZ MAIN — 016.

## Contrato

`ActionCoordinator` recibe exactamente un `InputSnapshot` y un `ActionContext` por tick. Devuelve un `ActionDecision` separado de la ejecución física.

Prioridad de solicitudes nuevas: esquiva > disparo > salto > recarga. El daño confirmado pendiente se expresa en el contexto y bloquea solicitudes nuevas porque se resuelve antes que ellas.

La decisión contiene:

- acción comprometida, como máximo una;
- solicitudes observadas en orden contractual;
- motivo explícito para cada rechazo;
- solicitud lógica de cancelar recarga solo para esquiva o disparo;
- marca que distingue una resolución nueva de un tick duplicado.

## Bloqueos y disponibilidad

El contexto declara capacidades y bloqueos. En C04 solo el salto está disponible por defecto; esquiva, disparo y recarga permanecen como interfaces sin ejecutores. Daño pendiente, recuperación o una acción activa bloquean nuevos compromisos. Las transiciones individuales pueden prohibirse explícitamente.

Una solicitud no disponible o prohibida se rechaza y se evalúa la siguiente solicitud válida del mismo snapshot. Las solicitudes de ticks bloqueados no se almacenan. El único buffer existente continúa siendo el jump buffer de C03, y solo recibe pulsaciones que el coordinador haya autorizado.

## Integración actual

`Player` consume un snapshot, obtiene una decisión y permite que `MovementComponent` registre la pulsación de salto únicamente cuando C04 la compromete. Los demás tipos no producen efectos jugables.

## Fuera de alcance

No se implementan esquiva física, disparo, recarga, enemigos, concentración, efectos, UI, animaciones ni C05–C12.
