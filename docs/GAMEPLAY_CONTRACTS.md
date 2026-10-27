# Contratos jugables — MVP 01

**Procedencia:** Game Designer, reportes 004 y 005; MAIN los consideró suficientemente especificados para evaluación técnica (directrices 006/007). **Valores experimentales, no calibración final.** R1–R4 aprobados por MAIN.

## Alcance
Arena, jugador, salto, apuntado 8 sectores, fijación asistida, revólver de seis balas, recarga individual cancelable, disparos normal/crítico, concentración A/B, esquiva y Forajido Hueco. Las mecánicas de combate NO están autorizadas para implementación bajo C03.

## Movimiento (autorizado solo en C03, una vez confirmado commit)
- `1 u = anchura de la caja de colisión del protagonista` (contrato de diseño). Conversión absoluta px/u pendiente de aprobación técnica definitiva.
- Velocidad horizontal 5 u/s; acelerar a máxima en 0.12 s; frenar en 0.10 s.
- Salto máximo 3 u; tiempo al ápice 0.35 s; altura variable.
- Coyote time 0.10 s; jump buffer 0.10 s.
- Colisiones básicas con suelo y paredes.

## Apuntado y objetivo (regla jugable especificada, tareas futuras bloqueadas)
- 8 sectores de 45°; el vector original solo determina sector; adquisición y mantenimiento usan **exclusivamente** dirección cuantizada.
- Stick en zona muerta y ratón exactamente en el origen conservan la última dirección válida, bajo política documentada de dispositivos C02.
- Adquisición ±35°; mantenimiento ±45°; alcance de fijación 8 u; línea de visión necesaria; único objetivo y selección determinista.
- Asistencia puede corregir trayectoria hacia objetivo fijado válido, no atravesar obstáculos ni adquirir fuera de cono.
- Margen de fijación inválida 0.3 s desde primera invalidez; se congela concentración; tras expiración se pierde fijación y concentración pasa terminalmente a cero. Esquiva no reinicia margen.

## Disparo (posterior, NO C03)
- Hitscan instantáneo; compromiso en aceptación de orden con munición disponible.
- Secuencia lógica: autorización; snapshot de dirección/fijación/concentración/vulnerabilidad; clasificación; consumir una bala; aplicar coste; resolver primer impacto; recuperación ofensiva.
- Normal: daño experimental 10, coste concentración 20 incluso al fallar. Crítico: multiplicador experimental ×2, gasta toda concentración y una bala incluso al fallar; requiere 100 concentración, objetivo fijado, vulnerable, trayectoria válida, munición.
- Alcance experimental 10 u; sin penetración, solo primer obstáculo/objetivo; apuntado 8 sectores puede corregirse por asistencia válida.
- Tras compromiso, daño/esquiva no revierten disparo ni restauran munición; esquiva durante recuperación ofensiva espera y no queda en cola.

## Orden de acciones (posterior)
Daño válido previamente confirmado > esquiva > disparo > salto > recarga. Movimiento y fijación continuos con restricciones del estado. Una nueva acción comprometida por tick. Solo el salto tiene buffer 0.10 s; las otras acciones en espera no quedan almacenadas. Disparo y esquiva cancelan recarga según contrato; esquiva no autoriza disparo durante ella. Confirmar matriz íntegra del reporte 005 antes de implementar C04.

## Esquiva (posterior)
Duración 0.24 s; desplazamiento 2 u; invulnerabilidad 0.05–0.17 s después del inicio; recuperación 0.12 s; no atraviesa paredes. Suspende concentración pasiva. Bonifica +10 una sola vez por instancia de ataque elegible con contacto real que habría causado daño, dentro de invulnerabilidad, fijación vigente o recuperable. Ataques persistentes pueden dañar al terminar i-frames y nunca bonifican repetidamente.

## Concentración (posterior)
Rango [0,100]; modelo A +25 pts/s; modelo B +10 pts/s normal, +45 pts/s bajo amenaza; +10 por esquiva válida; daño recibido −25; disparo normal −20; crítico consume todo. Recarga, esquiva y pérdida temporal de fijación no generan acumulación pasiva. Actualizar una vez por tick; la pérdida definitiva de fijación fuerza resultado final cero.

## Estado de aprobación
Aprobados como contratos candidatos para planificación técnica, no como balance final; solo C03 ha sido autorizada condicionalmente. Parámetros experimentales deberán quedar configurables.
