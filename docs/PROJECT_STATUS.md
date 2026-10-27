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
| C03 | AUTORIZADA CONDICIONALMENTE; NO CONSTA EJECUCIÓN | No empezar hasta verificar commit inicial legítimo C01+C02. Movimiento, salto, colisiones y un snapshot/tick. |
| C04–C12 | NO AUTORIZADAS | No ejecutar ni anticipar archivos jugables. |

## Control de versiones
Al iniciar la migración, Git no tenía commits y todos los archivos C01+C02 estaban sin rastrear. `.godot/` está ignorado. La identidad local debía corregirse porque `user.name` contenía un correo y `user.email` estaba ausente; el director creativo proporcionó `user.name=javivimarrero` y un correo legítimo para configuración local.

## Arte
AGENT 03 desarrolla recursos en paralelo. `ART_INTEGRATION.md` contiene propuestas, no aprobaciones artísticas definitivas.

## Próxima puerta
1. Consolidar un único commit inicial real C01+C02 y registrar su hash.
2. Solo entonces ejecutar C03 y sus pruebas.
3. Emitir el REPORTE A MAIN — GODOT ARCHITECT 010. No autoaprobar tareas posteriores.
