# Estado del proyecto — punto de migración 27/10/2026

**Esta es una instantánea documental, contrastada con el repositorio durante la migración a Codex.**

## Identidad
Repositorio: `C:\Users\jmargarr\Documents\juego\fm_project`.
Godot verificado: `4.7.2.stable.official.ed1daf0bf`.
Escena inicial: `res://scenes/prototypes/duel_arena.tscn`.

## Tareas
| Tarea | Estado aceptado | Evidencia y restricción |
|---|---|---|
| C01 | COMPLETADA | Godot importó y ejecutó arena headless, C01-V superada. |
| C02 | COMPLETADA | 70 checks C02 superados de nuevo durante la migración. |
| C03 | COMPLETADA | MAIN la declaró completada en DIRECTRIZ 016; commit independiente `78850ef25cbcacb1a75092a8d3ca911cee03c26b`. |
| C04 | IMPLEMENTADA; PENDIENTE DE ACEPTACIÓN MAIN | Coordinación determinista, permisos, bloqueos y cancelaciones lógicas. 34 checks C04 superados. |
| C05–C12 | NO AUTORIZADAS | No ejecutar ni anticipar mecánicas. |

## Control de versiones
Al iniciar la migración, Git no tenía commits y todos los archivos C01+C02 estaban sin rastrear. `.godot/` está ignorado. La identidad local debía corregirse porque `user.name` contenía un correo y `user.email` estaba ausente; el director creativo proporcionó `user.name=javivimarrero` y un correo legítimo para configuración local.

## Arte
AGENT 03 desarrolla recursos en paralelo. `ART_INTEGRATION.md` contiene propuestas, no aprobaciones artísticas definitivas.

## Estado de control de versiones
El commit inicial C01+C02 es `a9572d20273a052e7be18085ab83ea6eb3d82f69`. C03 fue consolidada antes de C04 en `78850ef25cbcacb1a75092a8d3ca911cee03c26b`. C04 permanece sin commit a la espera de revisión; C05–C12 siguen bloqueadas.
