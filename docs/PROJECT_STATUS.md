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
| C03 | IMPLEMENTADA; PENDIENTE DE ACEPTACIÓN MAIN | Commit inicial verificado; movimiento, salto, colisiones y un snapshot/tick implementados. 26 checks C03 y 70 checks de regresión C02 superados. |
| C04–C12 | NO AUTORIZADAS | No ejecutar ni anticipar archivos jugables. |

## Control de versiones
Al iniciar la migración, Git no tenía commits y todos los archivos C01+C02 estaban sin rastrear. `.godot/` está ignorado. La identidad local debía corregirse porque `user.name` contenía un correo y `user.email` estaba ausente; el director creativo proporcionó `user.name=javivimarrero` y un correo legítimo para configuración local.

## Arte
AGENT 03 desarrolla recursos en paralelo. `ART_INTEGRATION.md` contiene propuestas, no aprobaciones artísticas definitivas.

## Estado de la puerta C03
El commit inicial real es `a9572d20273a052e7be18085ab83ea6eb3d82f69`. C03 se implementó después de verificarlo. MAIN debe decidir su aceptación; C04–C12 siguen bloqueadas.
