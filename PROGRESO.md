# Progreso del backend de Rokola

Última actualización: 2026-11-07

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

**Paso 4 – Módulo `usuario`: usuarios y roles (solo lectura):** terminado y verificado (2026-11-07).

| Endpoint | Respuesta |
|---|---|
| `GET /api/roles` | Lista de roles ordenada por id (Administrador, Operador) |
| `GET /api/establecimientos/{id}/usuarios` | Usuarios del establecimiento ordenados por id, cada uno con su rol; 404 "Establecimiento no encontrado" si no existe |
| `GET /api/usuarios/{id}` | 200 con el usuario; 404 "Usuario no encontrado"; 400 si el id no es numérico |

- Archivos en `usuario/`: `Rol.kt`, `Usuario.kt` (entidades), `RolRepository.kt`, `UsuarioRepository.kt`, `RolResponse.kt`, `UsuarioResponse.kt`, `UsuarioService.kt`, `UsuarioController.kt`, `UsuarioNoEncontradoException.kt`.
- `id_rol` es `smallint`, por eso en Kotlin es `Short`.
- La respuesta **no incluye** `passwordHash` ni `intentosFallidos` (datos internos del login).
- `@EntityGraph(attributePaths = ["rol"])` trae cada usuario con su rol en una sola consulta (evita una consulta extra por usuario). Verificado en el log: 2 consultas por petición (existe el establecimiento + usuarios con rol).
- Postman: carpeta "Paso 4 - Usuarios y roles", 6 peticiones y 19 aserciones (incluidas pruebas de seguridad contra la fuga de la contraseña). Nueva variable de colección `idUsuario` (por defecto 1). La colección completa da 60/60.

**Paso 5 – Módulo `sesion`: sesiones musicales (solo lectura):** terminado y verificado (2026-11-07).

| Endpoint | Respuesta |
|---|---|
| `GET /api/establecimientos/{id}/sesiones?page=&size=` | Historial paginado `{content, page}`, de la más reciente a la más antigua (orden fijo; `sort` se ignora) |
| `GET /api/establecimientos/{id}/sesion-abierta` | La sesión abierta (la más reciente si hubiera varias); 404 "No hay sesión abierta" si no tiene |
| `GET /api/sesiones/{id}` | 200 con la sesión; 404 "Sesión no encontrada"; 400 si el id no es numérico |

- Las dos rutas de establecimiento responden 404 "Establecimiento no encontrado" si no existe.
- Archivos en `sesion/`: `Sesion.kt` (entidad), `EstadoSesion.kt` (enum `abierta`/`cerrada` + conversor), `SesionRepository.kt`, `SesionResponse.kt`, `SesionService.kt`, `SesionController.kt`, `SesionNoEncontradaException.kt`, `SinSesionAbiertaException.kt`.
- `id_evento_calendario` se guarda como un id simple (`idEventoCalendario`), sin entidad `EventoCalendario` todavía: los eventos quedan para un paso propio.
- Postman: carpeta "Paso 5 - Sesiones musicales", 8 peticiones y 17 aserciones. "Sesión abierta" guarda la variable `idSesion` que usa "Obtener sesión por id". La colección completa da 77/77.
- Sin prueba en Postman para "No hay sesión abierta": los dos establecimientos de prueba tienen una sesión abierta.

**Paso 6 – Módulo `dispositivo` (solo lectura):** terminado y verificado (2026-11-07).

| Endpoint | Respuesta |
|---|---|
| `GET /api/establecimientos/{id}/dispositivos?page=&size=` | Lista paginada `{content, page}`, del usado más recientemente al más antiguo (orden fijo); 404 "Establecimiento no encontrado" si no existe |
| `GET /api/dispositivos/{id}` | 200 con el dispositivo; 404 "Dispositivo no encontrado"; 400 si el id no es numérico |

- El dispositivo pertenece al **establecimiento**, no a la sesión: el mismo teléfono se reconoce en noches distintas.
- Archivos en `dispositivo/`: `Dispositivo.kt` (entidad), `TipoDispositivo.kt` (enum `movil`/`tableta`/`otro` + conversor), `DispositivoRepository.kt`, `DispositivoResponse.kt`, `DispositivoService.kt`, `DispositivoController.kt`, `DispositivoNoEncontradoException.kt`.
- La respuesta **no incluye** `deviceHash`: con ella alguien podría hacerse pasar por otro cliente (por ejemplo, para votar varias veces).
- El registro del dispositivo al escanear el QR (escritura) queda para la Etapa 5 (ver pregunta 16).
- Postman: carpeta "Paso 6 - Dispositivos", 6 peticiones y 16 aserciones. Nueva variable `idDispositivo` (por defecto 1). La colección completa da 93/93.

**Paso 7 – Módulo `cancion`: catálogo local (solo lectura):** terminado y verificado (2026-11-07).

| Endpoint | Respuesta |
|---|---|
| `GET /api/canciones?q=&page=&size=` | Lista paginada ordenada por título. `q` (opcional) busca en título o artista sin distinguir mayúsculas; sin resultados → 200 con lista vacía |
| `GET /api/canciones/{id}` | 200 con la canción; 404 "Canción no encontrada"; 400 si el id no es numérico |
| `GET /api/canciones/youtube/{youtubeVideoId}` | La canción de ese video; 404 "Canción no encontrada" si el video no está en el catálogo |

- El catálogo es **común a todos los establecimientos** (la tabla `cancion` no tiene `id_establecimiento`). Los bloqueos por establecimiento (`bloqueo_contenido`) se aplicarán en la Etapa 5.
- Archivos en `cancion/`: `Cancion.kt` (entidad), `Disponibilidad.kt` (enum `disponible`/`no_disponible`/`restringida`/`desconocida` + conversor), `CancionRepository.kt`, `CancionResponse.kt`, `CancionService.kt`, `CancionController.kt`, `CancionNoEncontradaException.kt` (con `porId` y `porYoutubeVideoId`).
- La búsqueda escapa `%` y `_`: buscar `%` no devuelve todo el catálogo (probado en Postman).
- **Limitación:** la búsqueda distingue tildes (`cancion` no encuentra `canción`). Ignorarlas requiere la extensión `unaccent` de PostgreSQL (una migración); se puede decidir más adelante.
- Solo busca en las canciones ya guardadas; la búsqueda en YouTube es de la Etapa 8.
- Postman: carpeta "Paso 7 - Canciones", 10 peticiones y 21 aserciones. Nuevas variables `idCancion` (1) y `youtubeVideoId` (`dQw4w9WgXcQ`). La colección completa da 114/114.

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
- **Hashes de contraseña de prueba inválidos:** los 5 `password_hash` empiezan como BCrypt (`$2b$12$`) pero miden 64 caracteres; un BCrypt real mide 60. Con ellos nadie podrá iniciar sesión en la Etapa 7 (ver pregunta 14).
- Los endpoints de usuarios muestran nombres y correos sin autenticación: se restringirán en la Etapa 7.
- **Varias sesiones abiertas:** la base no impide que un establecimiento tenga dos sesiones abiertas a la vez (ver pregunta 15).
- La sesión 2 de prueba sigue "abierta" desde el 2026-11-03: nada cierra las sesiones automáticamente (ver pregunta 15).

## Próximos pasos

1. Paso 8: módulos `solicitud` y `voto` (lectura): la cola de una sesión ordenada por votos (descendente) y antigüedad (ascendente). Para contar los votos hace falta decidir la **pregunta 1** (voto inicial).
2. Con eso termina la parte de lectura de los módulos fundamentales del PDF; después vienen las reglas de negocio (Etapa 5), que dependen de las preguntas 🔴.
3. Escritura de establecimientos y usuarios (crear/editar): queda para cuando exista la autenticación (Etapa 7), porque solo debe hacerla un administrador.