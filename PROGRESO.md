# Progreso del backend de Rokola

Última actualización: 2026-11-05

## Estado actual

**Paso 1 – Proyecto base, conexión a PostgreSQL y Flyway:** terminado y verificado.

| Elemento | Estado |
|---|---|
| Base local `db_rokola` restaurada desde `contexto/backup.sql` | Hecho y verificado (21 tablas, 28 FK, 33 CHECK, 49 índices) |
| Proyecto Spring Boot generado (Initializr) | Hecho; `build` exitoso (incluye la prueba `contextLoads`) |
| Migración `V1__esquema_inicial.sql` | Hecha; verificada en base temporal (esquema idéntico al backup) |
| Flyway en `db_rokola` | Baseline en versión 1 registrada; la V1 aparece como `BASELINE_IGNORED` (no se ejecutó) |
| Colección Postman del Paso 1 | 7/7 aserciones pasan (`/actuator/health`, `/actuator/flyway`) |
| JDK 21 | Instalado: Oracle JDK 21.0.12.1 en `C:\Program Files\Java\jdk-21.0.12.1`. `build.gradle.kts` usa el toolchain 21 original; bytecode verificado (major 65) |

### Cómo compilar y arrancar

`JAVA_HOME` no está definido en el sistema, así que se indica en la terminal antes de usar el wrapper (Gradle 9.8.2):

```powershell
$env:JAVA_HOME = "C:\Program Files\Java\jdk-21.0.12.1"
.\gradlew.bat build     # compila y ejecuta las pruebas
.\gradlew.bat bootRun   # arranca el backend en http://localhost:8080
```

Pruebas: `postman collection run postman\Rokola.postman_collection.json -e postman\Rokola-local.postman_environment.json`

**Paso 2 – Módulo `establecimiento` (solo lectura):** terminado y verificado.

| Endpoint | Respuesta |
|---|---|
| `GET /api/establecimientos?page=&size=` | 200, lista paginada `{content, page}`, ordenada por id, `size` máximo 100 |
| `GET /api/establecimientos/{id}` | 200 con el establecimiento; 404 Problem Details si no existe; 400 si el id no es numérico |

- Archivos: `establecimiento/` → `Establecimiento.kt` (entidad), `EstablecimientoRepository.kt`, `EstablecimientoService.kt`, `EstablecimientoController.kt`, `EstablecimientoResponse.kt` (DTO), `EstablecimientoNoEncontradoException.kt`.
- `ddl-auto=validate`: al arrancar, Hibernate comprueba que las entidades coinciden con las tablas reales.
- Postman: carpeta "Paso 2 - Establecimientos", 6 peticiones y 18 aserciones. La colección completa da 25/25.

**Paso 3 – Horarios, configuración y códigos QR (solo lectura):** terminado y verificado.

| Endpoint | Respuesta |
|---|---|
| `GET /api/establecimientos/{id}/horarios` | Lista ordenada por día (1 = lunes … 7 = domingo) y hora de inicio |
| `GET /api/establecimientos/{id}/configuracion` | Reglas del servicio; 404 "Configuración no encontrada" si no tiene |
| `GET /api/establecimientos/{id}/codigos-qr` | QR del más reciente al más antiguo, **sin `token_hash`** |

- Las tres responden 404 "Establecimiento no encontrado" si el establecimiento no existe, en lugar de una lista vacía.
- Archivos nuevos en `establecimiento/`: `HorarioOperacion.kt`, `ConfiguracionServicio.kt`, `CodigoQr.kt`, `EstadoServicio.kt` (enum + conversor a texto en minúsculas), sus `*Repository.kt` y `*Response.kt`, y `ConfiguracionServicioNoEncontradaException.kt`.
- Postman: carpeta "Paso 3", 6 peticiones y 16 aserciones (incluida una prueba de seguridad contra la fuga del hash). La colección completa da 41/41.

## Stack

- Kotlin 2.3.21, Spring Boot 4.1.2, Java 21, Gradle 9.8.2 (Kotlin DSL)
- PostgreSQL 18.6 local (`localhost:5432/db_rokola`); el backup proviene de PostgreSQL 17.10
- Flyway con `baseline-on-migrate=true` y `baseline-version=1`
- Paquete base: `com.proyectoN.rokolaBackend`

## Decisiones tomadas

1. **El esquema lo maneja solo Flyway** (`ddl-auto=none`). La `V1` es el esquema del backup sin el encabezado de `pg_dump`.
2. **Baseline en la versión 1:** `db_rokola` ya tiene las tablas, así que Flyway registra la V1 como *baseline* sin ejecutarla. En una base vacía (otra máquina, pruebas) ejecuta la V1 completa.
3. **Los datos de prueba no van en migraciones:** solo existen en `db_rokola` porque se restauraron del backup.
4. **Pruebas del Paso 1 con Actuator:** `/actuator/health` (conexión a la BD) y `/actuator/flyway` (historial de migraciones), en lugar de un endpoint temporal `/prueba-bd`.
5. La base se llama `db_rokola` (minúsculas) para no tener que escribirla entre comillas en SQL.

## Pendientes por confirmar con el usuario

- **Voto inicial:** en los datos de prueba, el dispositivo que crea una solicitud no aparece en la tabla `voto`. ¿El total de votos es 1 (implícito) + votos activos? Hay que decidirlo antes de la Etapa 5.
- `evento_analitico` id 4 tiene `youtube_video_id = '7'` (dato de prueba inválido).
- **Railway:** antes de apuntar el backend allí, revisar qué tablas tiene. Con `baseline-on-migrate=true`, Flyway marcaría la V1 como aplicada aunque el esquema esté incompleto.
- Actuator expone detalles de salud sin autenticación: restringirlo en la etapa de seguridad.
- `GET /api/establecimientos` lista también los inactivos y no pide autenticación. Hay que definir en la Etapa 7 quién puede verlo.
- Las fechas se devuelven en UTC (`...Z`): es el mismo instante que guarda la base (`-05` en Bogotá).
- **Supuesto:** `dia_semana` sigue ISO-8601 (1 = lunes … 7 = domingo). Los datos de prueba encajan (Bar La Nota abre de jueves a domingo), pero el PDF no lo dice. Confirmar.
- **Escaneo del QR (pendiente):** la base solo guarda la huella del token, no el token. Falta definir el algoritmo (los datos de prueba parecen SHA-256) y cómo se generan los QR. Se resolverá junto con `dispositivo`/`sesion`.
- No hay datos de prueba de un establecimiento sin configuración, así que el 404 "Configuración no encontrada" no tiene prueba en Postman.

## Próximos pasos

1. Paso 4: módulo `usuario` y `rol` (lectura), como base para la autenticación.
2. Escritura de establecimientos (crear/editar): queda para cuando exista la autenticación (Etapa 7), porque solo debe hacerla un administrador.