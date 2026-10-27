# Arquitectura técnica — MVP 01

**Estado:** propuesta consolidada por AGENT 02 (reporte 003), aceptada como base de planificación; su implementación es incremental y solo parte está ejecutada.
**Godot:** 4.7.2 ratificado por MAIN.

## Objetivo y alcance
Arena temporal + protagonista + Forajido Hueco, para evaluar movimiento y, después de autorizaciones separadas, combate. Fuera de MVP 01: muerte/resurrección, exploración, economía, progresión, nuevas armas, jefes y enemigos adicionales.

## Presente según últimas evidencias
- `project.godot` con escena inicial `res://scenes/prototypes/duel_arena.tscn`.
- C02: `scripts/components/input_snapshot.gd`, `aim_quantizer.gd`, `input_controller.gd`; pruebas `tests/run_c02_tests.gd`, documentación `docs/c02_input.md`. Verificar rutas actuales al abrir repo.
- Godot 4.7.2; 70 pruebas reportadas como superadas de C02.
- C03: `MovementComponent` calcula física desde un snapshot; `Player` consume una captura por tick y `CharacterBody2D` resuelve suelo y paredes. Pruebas en `tests/run_c03_tests.gd`.

## Contratos arquitectónicos de referencia (no afirmar implementados)
- `PlayerController`/`InputController`: captura intenciones y snapshots. **No** movimiento ni combate.
- `SimulationCoordinator`/`ActionCoordinator`: orden fijo de acciones, colisiones, daño y concentración **cuando se autoricen**.
- `MovementComponent`: física horizontal y salto (C03 implementada, pendiente de aceptación MAIN).
- `DodgeComponent`: fases, ventanas de invulnerabilidad y evasión (tarea posterior bloqueada).
- `TargetingComponent`: ocho direcciones y fijación (posterior).
- `RevolverComponent`, `CombatController`, `AttackResolver`: munición, compromiso e hitscan (posterior).
- `ConcentrationComponent`: operación única por tick, variante A/B por `Resource` (posterior).
- `HealthComponent` y Forajido Hueco: daño y patrones reproducibles (posterior).
- Sprites/UI/VFX: representación visual separada de la verdad jugable.

## Comunicación
Consultas de acción inmediata por llamadas y contratos tipados; señales para comunicar resultados ya resueltos, sin reglas implícitas dependientes del orden de señales. No crear singleton bus global. Las entradas viven en snapshots inmutables por tick; una única autoridad escribe cada estado jugable.

## Esqueleto de escena futuro (no obligatorio crearlo ahora)
`duel_arena.tscn` coordina prueba; `player.tscn` con raíz `CharacterBody2D` y componentes; `forajido_hueco.tscn` con lógica del único enemigo. Rutas y carpetas definitivas se ajustan al repositorio real y tareas autorizadas.

## Simulación futura — orden contractual
1 captura; 2 relojes/temporizadores; 3 daño ya confirmado en ticks previos; 4 decisión de acciones; 5 movimiento y colisiones; 6 fijación; 7 resolución ofensiva/enemiga; 8 daño y evasiones; 9 concentración; 10 publicación de estado/eventos. Consultar TECHNICAL_DECISIONS para precisiones R1–R4. **No implementar este pipeline completo en C03**.

## Principios
Paso fijo de física, GDScript tipado, configuración numérica via recursos cuando cada sistema sea autorizado, pruebas headless, composición, responsabilidad única, ausencia de dependencias artísticas en reglas físicas. No introducir componentes vacíos por anticipación.
