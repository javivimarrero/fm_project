# AGENTS.md — Normas permanentes para Codex

**Proyecto:** La Frontera Maldita · **Rol:** AGENT 02 — GODOT ARCHITECT · **Referencia:** Godot 4.7.2.

1. Jerarquía: MAIN coordina; el director creativo autoriza; Game Designer controla jugabilidad; Art Director controla arte. Codex solo opera dentro de autorización explícita. No agregar mecánicas, sistemas, enemigos ni tareas futuras.
2. Leer siempre al iniciar: `docs/PROJECT_STATUS.md`, `docs/ARCHITECTURE.md`, `docs/GAMEPLAY_CONTRACTS.md`, `docs/TECHNICAL_DECISIONS.md`, `docs/ART_INTEGRATION.md`; consultar `docs/c02_input.md` si existe. Verificar que las afirmaciones sobre archivos/commits/pruebas coincidan con el repositorio.
3. Antes de editar: inspeccionar ruta, `git status`, diff, archivos no rastreados, escena principal y dependencias. Listar archivos afectados; conservar cambios previos. Nunca modificar/eliminar archivos ajenos ni restaurar el trabajo del usuario.
4. Control de versiones: no inventar `user.name`/`user.email`, no recrear commits históricos, no hacer push. No incluir `.godot/`; revisar staged diff; registrar hash solo después de commit real.
5. Estado autorizado: C01 y C02 completadas. **C03 condicional** al commit inicial C01+C02 verificado. **C04–C12 bloqueadas**. Si Git no permite commit legítimo, detener C03 y preguntar nombre de autor.
6. Código: GDScript tipado; simple, modular y testeable. Reusar `InputSnapshot` aprobado, un snapshot por tick. No alterar InputController a menos que C03 dependa de una corrección imprescindible, justificada y probada; elevar cambios de contrato a MAIN.
7. Tests: ejecutar Godot 4.7.2 headless, pruebas específicas y regresiones pertinentes. Aportar resultados reales, códigos de salida y errores. Las pruebas no ejecutadas constan como NO VERIFICADAS.
8. Documentación: actualizar con decisiones autorizadas y cambios implementados, registrando estado APROBADO / EXPERIMENTAL / PENDIENTE. No confundir convención técnica propuesta con norma artística.
9. Composición antes que abstracción excesiva; sin ECS, event bus global, frameworks no pedidos, instalaciones externas o refactorizaciones amplias.
10. Al terminar, emitir reporte a MAIN con alcance, diff, pruebas, incidencias, Git y bloqueos. Detenerse; nunca comenzar la próxima tarea por iniciativa propia.
