# Preguntas pendientes – Backend de Rokola

Última actualización: 2026-11-07 (después del Paso 7)

> **Siguiente bloqueo:** la **pregunta 1** (voto inicial) se necesita para el Paso 8.

Cada pregunta trae el contexto, las opciones y una recomendación. Escribe tu decisión en **Respuesta** y la aplico en el paso que corresponda.

**Prioridad**
- 🔴 Hay que responderla antes de la etapa indicada; sin respuesta no se puede implementar bien.
- 🟡 Conviene responderla pronto, pero no bloquea el siguiente paso.
- 🟢 Menor o de organización.

---

## Reglas de negocio

### 1. 🔴 ¿El voto inicial de una solicitud se guarda como fila en `voto`?
**Se necesita para:** ⏭️ **el Paso 8 (siguiente)**, la cola de solicitudes con sus votos, y después para la Etapa 5 (crear solicitudes y votar).

**Por qué bloquea el Paso 8:** la cola se ordena por cantidad de votos (de más a menos) y, si empatan, por antigüedad (la más antigua primero). Si el voto de quien pide la canción se cuenta o no, cambia el total de cada solicitud y puede cambiar el orden en que se ve la cola.

El PDF dice: *"Una solicitud nueva comienza en estado de espera y recibe un voto inicial"*. En los datos de prueba, el dispositivo que crea la solicitud **nunca** aparece en la tabla `voto`. Por ejemplo, la solicitud 7 la creó el dispositivo 2, pero sus votos son de los dispositivos 1, 3, 4 y 5.

| Opción | Total de votos | Consecuencia |
|---|---|---|
| A. Voto implícito | `1 + votos activos` | Coincide con los datos actuales; la tabla `voto` solo guarda los votos de otros dispositivos |
| B. Voto explícito | `votos activos` | Al crear la solicitud se inserta también un voto del solicitante, y habría que corregir los datos de prueba |

**Recomendación:** A, porque es lo que ya reflejan los datos.

**Cómo responder:** escribe "A" o "B" aquí, o dímelo en el chat (por ejemplo: *"sigue con el Paso 8, opción A"*).

**Respuesta:**

B

### 2. 🟡 ¿Qué día es `dia_semana = 1`?
**Se necesita para:** validar horarios y saber si el establecimiento está abierto.

Asumí el estándar ISO-8601: **1 = lunes … 7 = domingo**. Con eso, Bar La Nota abre de jueves a domingo y Café Vinilo lunes, martes y sábado. Si fuera 1 = domingo, todo se correría un día.

**Respuesta:**

1 = lunes y 7 = domingo

### 3. 🟡 Horarios que pasan de medianoche
**Se necesita para:** calcular si el establecimiento está abierto en un momento dado.

Bar La Nota tiene franjas como `18:00 → 02:00`. Interpreté que **si `horaFin` es menor que `horaInicio`, el horario termina al día siguiente**. Dos dudas:

- a) ¿La franja del **jueves** 18:00 → 02:00 cubre hasta las 02:00 del **viernes**?
- b) El domingo tiene `18:00 → 00:00`. ¿Significa "hasta la medianoche" (fin del domingo)?

**Respuesta:**

a) Sí. 
b) Sí, termina al comenzar el lunes.

### 4. 🔴 ¿Cómo se genera y se valida el token del código QR?
**Se necesita para:** Etapa 5 (el cliente escanea el QR y el sistema identifica el establecimiento).

La tabla `codigo_qr` guarda solo `token_hash` (64 caracteres, al parecer SHA-256), no el token. Falta definir:

- a) ¿Qué contiene el QR? Por ejemplo, una URL como `https://.../q/{token}`, o el `slug` más el token.
- b) ¿Qué algoritmo de huella se usa: SHA-256 del token tal cual, o con algún prefijo?
- c) ¿Quién crea los QR (el administrador desde el panel) y qué pasa con los anteriores al rotarlo?

**Recomendación:** token aleatorio de 32 bytes en Base64URL dentro de una URL; huella SHA-256; al crear uno nuevo se revoca el anterior, como en los datos de prueba (`accion_admin`: *"reemplazado por nuevo QR"*).

**Ojo:** los datos de prueba no traen los tokens originales, así que con esos QR no se puede probar el escaneo. Habría que crear un QR nuevo.

**Respuesta:**

mantener tokens aleatorios, almacenar SHA-256 y administrar los QR desde el panel del establecimiento.
n código QR impreso podría utilizarse durante varias noches. No recomendaría rotarlo automáticamente en cada sesión. Debe permanecer válido hasta que un administrador decida reemplazarlo, por ejemplo, por pérdida de control sobre su distribución.

## Seguridad y acceso

### 5. 🔴 ¿Quién puede ver cada endpoint?
**Se necesita para:** Etapa 7 (seguridad).

Hoy todos los endpoints son públicos, sin login:

| Endpoint | ¿Público, operador o administrador? |
|---|---|
| `GET /api/establecimientos` (incluye los inactivos) | |
| `GET /api/establecimientos/{id}` | |
| `GET /api/establecimientos/{id}/horarios` | |
| `GET /api/establecimientos/{id}/configuracion` | |
| `GET /api/establecimientos/{id}/codigos-qr` | |
| `GET /api/roles` | |
| `GET /api/establecimientos/{id}/usuarios` (nombres y correos) | |
| `GET /api/usuarios/{id}` | |
| `GET /api/establecimientos/{id}/sesiones` (historial) | |
| `GET /api/establecimientos/{id}/sesion-abierta` | |
| `GET /api/sesiones/{id}` | |
| `GET /api/establecimientos/{id}/dispositivos` | |
| `GET /api/dispositivos/{id}` | |

Pregunta relacionada: ¿un administrador ve **solo su establecimiento** o todos? La tabla `usuario` tiene `id_establecimiento`, lo que sugiere solo el suyo.

**Recomendación:** horarios y configuración, públicos (el cliente los necesita, por ejemplo para ver la duración máxima de una canción); códigos QR, solo administrador; el listado completo de establecimientos, solo administrador; cada usuario limitado a su establecimiento.

**Respuesta:**

Propongo que Administrador y Operador estén limitados al establecimiento al que pertenecen, y que los clientes accedan únicamente a la información necesaria para utilizar el servicio.
No crearía otro rol ahora. Administrador significa administración completa de su establecimiento; no administración global de toda la plataforma

### 14. 🔴 Las contraseñas de los usuarios de prueba no sirven para iniciar sesión
**Se necesita para:** Etapa 7 (inicio de sesión del personal).

Los 5 usuarios de prueba tienen un `password_hash` que empieza como BCrypt (`$2b$12$`), pero mide **64 caracteres**. Un hash BCrypt real mide **60**. Es decir, son valores de relleno: ninguna contraseña coincidirá con ellos.

| Opción | Qué implica |
|---|---|
| A. Migración de desarrollo que asigne contraseñas conocidas | Por ejemplo, todos con una contraseña de prueba, guardada ya como BCrypt real |
| B. Endpoint o script para que un administrador fije contraseñas | Más trabajo, pero sirve también fuera de las pruebas |
| C. Actualizarlas a mano en `db_rokola` | Lo más rápido, pero solo funciona en tu máquina |

**Recomendación:** decidirlo al llegar a la Etapa 7; probablemente C para empezar y B después. (Relacionada con la pregunta 8.)

**Respuesta:**

B como solución definitiva y C como medida temporal para desarrollo.

### 15. 🔴 ¿Puede un establecimiento tener más de una sesión abierta? ¿Quién la cierra?
**Se necesita para:** Etapa 5 (abrir y cerrar sesiones, y saber en qué sesión entra una solicitud).

La tabla `sesion` no tiene ninguna regla que impida dos sesiones `abierta` en el mismo establecimiento. Hoy `GET /api/establecimientos/{id}/sesion-abierta` devuelve la abierta más reciente, pero si hubiera dos, las solicitudes podrían repartirse entre ellas.

- a) ¿Solo puede haber **una** sesión abierta por establecimiento?
- b) ¿Quién cierra la sesión: el personal a mano, o el sistema cuando termina el horario de operación? En los datos de prueba, la sesión 2 sigue abierta desde el 3 de noviembre.

**Recomendación:** a) sí, una sola. Se aseguraría con la primera migración nueva, `V2`, que agregaría un índice único parcial (`UNIQUE (id_establecimiento) WHERE estado = 'abierta'`); no borra datos y los de prueba ya lo cumplen. b) El personal la abre y la cierra a mano en el PMV; el cierre automático por horario puede venir después.

**Respuesta:**

a) No, únicamente una sesión abierta por establecimiento. b) Apertura y cierre manual por el personal autorizado.

### 16. 🔴 ¿Cómo se identifica un dispositivo sin pedir datos personales?
**Se necesita para:** Etapa 5 (registrar el dispositivo cuando el cliente escanea el QR).

La tabla `dispositivo` guarda una huella `device_hash`, única por establecimiento. En los datos de prueba mide **32 caracteres hexadecimales** (128 bits), no 64 como el hash SHA-256 del QR. Falta definir:

- a) ¿Qué envía el teléfono? Por ejemplo, un identificador aleatorio (UUID) que la app o la página web generan la primera vez y guardan en el teléfono.
- b) ¿El backend guarda ese identificador tal cual o su huella? ¿Con qué algoritmo?
- c) ¿Cuándo se pide aceptar el aviso de privacidad (`aviso_privacidad_fecha`)? ¿Al primer acceso, o de nuevo si cambia `aviso_privacidad_version` en la configuración?

**Recomendación:** a) UUID aleatorio generado en el teléfono; b) guardar su SHA-256 (64 caracteres, cabe en la columna de 255), como con el QR, y dejar los datos de prueba como están; c) al primer acceso, y otra vez si la versión del aviso es posterior a la fecha en que el dispositivo lo aceptó.

**Ojo:** igual que con el QR, los datos de prueba no traen los identificadores originales, así que para probar habrá que registrar un dispositivo nuevo.

**Respuesta:**

identificador aleatorio persistente generado por el cliente y huella SHA-256 almacenada por el servidor.

### 6. 🟡 ¿Quién crea y edita establecimientos?
**Se necesita para:** Etapa 7.

Todavía no hay endpoints de escritura. Si cada usuario pertenece a un establecimiento, ¿quién da de alta un establecimiento nuevo? ¿Un "superadministrador" (no existe en `rol`), o se cargan a mano en la base por ahora?

**Respuesta:**

para el PMV, el alta inicial de establecimientos debe realizarse mediante un proceso técnico controlado.

## Base de datos y despliegue

### 7. 🟡 ¿Qué hacemos con la base de Railway?
**Se necesita para:** Etapa 10 (despliegue), o antes si quieres probar contra Railway.

Ahora trabajamos con la base local `db_rokola`. Según el PDF, la de Railway tenía tablas sin historial de Flyway y no se sabe si están completas. Con `baseline-on-migrate=true`, Flyway marcaría la V1 como aplicada **aunque falten tablas**.

| Opción | Qué implica |
|---|---|
| A. Revisar Railway primero | Comparar sus tablas con la V1 antes de conectar el backend |
| B. Base nueva y vacía en Railway | Flyway ejecuta la V1 completa; es lo más limpio si ahí no hay datos que conservar |

**Recomendación:** B si Railway no tiene datos reales; A si los tiene.

**Respuesta:**

la Db de railway es la bb que se usara para todo el proyecto esta en la nibe y esta coenctada ya en el proyecto
tiene las 21 tablas y datos de prueba en cada tabla

### 8. 🟡 ¿Los datos de prueba deben existir fuera de tu máquina?
Los datos de ejemplo (Bar La Nota, Café Vinilo, canciones…) solo están en `db_rokola` porque se restauraron del backup. Una base nueva, como Railway o la de un compañero, quedaría **vacía**.

| Opción | Qué implica |
|---|---|
| A. Dejarlo así | Cada quien restaura `contexto/backup.sql` a mano |
| B. Migración de datos de prueba | Un script de Flyway que solo se ejecute en desarrollo |

**Respuesta:**

A

### 9. 🟢 Dato inválido en `evento_analitico`
El evento con id 4 (`voto_emitido`) tiene `youtube_video_id = '7'`, que no es un id de video de YouTube. Por los datos parece que debía ser `RgKAFK5djSk` (canción 7). ¿Lo corrijo en `db_rokola` o lo dejas así?

**Respuesta:**

ya lo cambie

## Organización del proyecto

### 10. 🟢 ¿Dónde vive el repositorio?
Ya hay git en `tamara/` (rama `main`, primer commit con los pasos 1 a 3). Según el PDF, el backend vivía en el repositorio `web-musica`, carpeta `rokolaBackend`, rama `backend`. ¿Lo dejamos aquí o se sube a `web-musica`? Si es lo segundo, ¿dónde está clonado?

**Respuesta:**

estamos en un ambiente de prueba el repo real esta en otro lado ya despues de que pruebe las clases y demas

### 11. 🟡 ¿Agregamos pruebas automáticas en Kotlin?
Hoy cada paso se prueba con Postman (41 aserciones) y con una sola prueba en Kotlin (`contextLoads`). Las instrucciones que pegaste al inicio piden pruebas unitarias, Testcontainers, ktlint y detekt. El PDF pide no agregar herramientas innecesarias.

| Opción | Qué implica |
|---|---|
| A. Solo Postman por ahora | Más simple; las pruebas automáticas quedan para la Etapa 10 |
| B. Pruebas unitarias de los servicios desde ya | Usan las librerías que ya trae Spring Boot, sin dependencias nuevas |
| C. Todo lo de las instrucciones | Agrega Testcontainers (requiere Docker), ktlint y detekt |

**Recomendación:** A ahora y B desde la Etapa 5, cuando haya reglas de negocio reales que probar.

**Respuesta:**

A

### 12. 🟢 Nombre de la base local
Se creó como `db_rokola` (minúsculas) en lugar de `DB_Rokola`, el nombre del backup, para no tener que escribirla entre comillas en SQL. ¿Te parece bien?

**Respuesta:**

dejalo como esta

### 13. 🟢 Carpeta sobrante de la descarga cancelada
Quedó `C:\Users\jgara\.jdks\_descarga21`, con un zip de 0 MB del intento de descargar el JDK. ¿La borro?

**Respuesta:**

si no afecta al proyecto aslo

## Recomendación (no es pregunta)

**Definir `JAVA_HOME` en Windows**, para no tener que escribirlo en cada terminal:
*Configuración → Sistema → Información → Configuración avanzada del sistema → Variables de entorno → Nueva (variables del sistema)*
- Nombre: `JAVA_HOME`
- Valor: `C:\Program Files\Java\jdk-21.0.12.1`
