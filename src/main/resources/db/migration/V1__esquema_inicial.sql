-- V1: esquema inicial de Rokola (21 tablas).
-- Generado a partir de contexto/backup.sql (pg_dump 17.10) con pg_restore --schema-only.
-- Se omitio el encabezado del dump (comandos \restrict de psql y SET de sesion).

--
-- Name: accion_admin; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accion_admin (
    id_accion bigint NOT NULL,
    id_establecimiento bigint NOT NULL,
    id_usuario bigint,
    tipo character varying(80) NOT NULL,
    objetivo_tipo character varying(60),
    objetivo_id bigint,
    detalle jsonb,
    fecha timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: accion_admin_id_accion_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.accion_admin ALTER COLUMN id_accion ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.accion_admin_id_accion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: bloqueo_contenido; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bloqueo_contenido (
    id_bloqueo bigint NOT NULL,
    id_establecimiento bigint NOT NULL,
    id_cancion bigint NOT NULL,
    id_usuario bigint NOT NULL,
    motivo text NOT NULL,
    fecha_inicio timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_fin timestamp with time zone,
    activo boolean DEFAULT true NOT NULL,
    CONSTRAINT ck_bloqueo_fechas CHECK (((fecha_fin IS NULL) OR (fecha_fin >= fecha_inicio)))
);


--
-- Name: bloqueo_contenido_id_bloqueo_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.bloqueo_contenido ALTER COLUMN id_bloqueo ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.bloqueo_contenido_id_bloqueo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: busqueda_cache; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.busqueda_cache (
    id_cache bigint NOT NULL,
    consulta_normalizada text NOT NULL,
    region character varying(10) NOT NULL,
    idioma character varying(10) NOT NULL,
    resultados jsonb DEFAULT '[]'::jsonb NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    expira_en timestamp with time zone NOT NULL,
    aciertos bigint DEFAULT 0 NOT NULL,
    CONSTRAINT ck_cache_aciertos CHECK ((aciertos >= 0)),
    CONSTRAINT ck_cache_fechas CHECK ((expira_en > fecha_creacion)),
    CONSTRAINT ck_cache_resultados_array CHECK ((jsonb_typeof(resultados) = 'array'::text))
);


--
-- Name: busqueda_cache_id_cache_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.busqueda_cache ALTER COLUMN id_cache ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.busqueda_cache_id_cache_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: cancion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cancion (
    id_cancion bigint NOT NULL,
    youtube_video_id character varying(30) NOT NULL,
    titulo character varying(300) NOT NULL,
    artista character varying(200),
    canal character varying(200),
    categoria character varying(100),
    duracion_seg integer NOT NULL,
    miniatura_url text,
    categoria_youtube character varying(100),
    embebible boolean DEFAULT true NOT NULL,
    disponibilidad character varying(30) DEFAULT 'desconocida'::character varying NOT NULL,
    ultima_validacion timestamp with time zone,
    fecha_creacion timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT ck_cancion_disponibilidad CHECK (((disponibilidad)::text = ANY ((ARRAY['disponible'::character varying, 'no_disponible'::character varying, 'restringida'::character varying, 'desconocida'::character varying])::text[]))),
    CONSTRAINT ck_cancion_duracion CHECK ((duracion_seg > 0))
);


--
-- Name: cancion_id_cancion_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.cancion ALTER COLUMN id_cancion ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.cancion_id_cancion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: codigo_qr; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.codigo_qr (
    id_qr bigint NOT NULL,
    id_establecimiento bigint NOT NULL,
    token_hash character varying(255) NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_revocacion timestamp with time zone,
    activo boolean DEFAULT true NOT NULL,
    CONSTRAINT ck_qr_fechas CHECK (((fecha_revocacion IS NULL) OR (fecha_revocacion >= fecha_creacion)))
);


--
-- Name: codigo_qr_id_qr_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.codigo_qr ALTER COLUMN id_qr ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.codigo_qr_id_qr_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: configuracion_servicio; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.configuracion_servicio (
    id_configuracion bigint NOT NULL,
    id_establecimiento bigint NOT NULL,
    estado_manual character varying(20) DEFAULT 'disponible'::character varying NOT NULL,
    max_solicitudes_dispositivo integer DEFAULT 5 NOT NULL,
    duracion_max_seg integer DEFAULT 600 NOT NULL,
    minutos_bloqueo_repeticion integer DEFAULT 60 NOT NULL,
    aviso_privacidad_version character varying(40),
    fecha_modificacion timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT ck_config_bloqueo CHECK ((minutos_bloqueo_repeticion >= 0)),
    CONSTRAINT ck_config_duracion CHECK ((duracion_max_seg > 0)),
    CONSTRAINT ck_config_estado CHECK (((estado_manual)::text = ANY ((ARRAY['disponible'::character varying, 'pausado'::character varying, 'mantenimiento'::character varying])::text[]))),
    CONSTRAINT ck_config_max_solicitudes CHECK ((max_solicitudes_dispositivo >= 0))
);


--
-- Name: configuracion_servicio_id_configuracion_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.configuracion_servicio ALTER COLUMN id_configuracion ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.configuracion_servicio_id_configuracion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: dispositivo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dispositivo (
    id_dispositivo bigint NOT NULL,
    id_establecimiento bigint NOT NULL,
    device_hash character varying(255) NOT NULL,
    tipo character varying(30) NOT NULL,
    primer_acceso timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    ultimo_acceso timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    aviso_privacidad_fecha timestamp with time zone,
    CONSTRAINT ck_dispositivo_fechas CHECK ((ultimo_acceso >= primer_acceso)),
    CONSTRAINT ck_dispositivo_tipo CHECK (((tipo)::text = ANY ((ARRAY['movil'::character varying, 'tableta'::character varying, 'otro'::character varying])::text[])))
);


--
-- Name: dispositivo_id_dispositivo_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.dispositivo ALTER COLUMN id_dispositivo ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.dispositivo_id_dispositivo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: ejecucion_pipeline; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ejecucion_pipeline (
    id_ejecucion bigint NOT NULL,
    inicio timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fin timestamp with time zone,
    estado character varying(25) DEFAULT 'ejecutando'::character varying NOT NULL,
    procesado_hasta timestamp with time zone,
    registros_leidos bigint DEFAULT 0 NOT NULL,
    registros_insertados bigint DEFAULT 0 NOT NULL,
    registros_rechazados bigint DEFAULT 0 NOT NULL,
    detalle_error text,
    CONSTRAINT ck_pipeline_contadores CHECK (((registros_leidos >= 0) AND (registros_insertados >= 0) AND (registros_rechazados >= 0))),
    CONSTRAINT ck_pipeline_estado CHECK (((estado)::text = ANY ((ARRAY['ejecutando'::character varying, 'completado'::character varying, 'fallido'::character varying])::text[]))),
    CONSTRAINT ck_pipeline_fechas CHECK (((fin IS NULL) OR (fin >= inicio)))
);


--
-- Name: ejecucion_pipeline_id_ejecucion_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.ejecucion_pipeline ALTER COLUMN id_ejecucion ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ejecucion_pipeline_id_ejecucion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: elemento_lista; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.elemento_lista (
    id_elemento bigint NOT NULL,
    id_lista bigint NOT NULL,
    id_cancion bigint NOT NULL,
    orden integer NOT NULL,
    CONSTRAINT ck_elemento_orden CHECK ((orden > 0))
);


--
-- Name: elemento_lista_id_elemento_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.elemento_lista ALTER COLUMN id_elemento ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.elemento_lista_id_elemento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: error_integracion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.error_integracion (
    id_error bigint NOT NULL,
    id_establecimiento bigint NOT NULL,
    id_sesion bigint,
    proveedor character varying(60) NOT NULL,
    tipo_error character varying(80) NOT NULL,
    mensaje text NOT NULL,
    operacion character varying(100),
    fecha_hora timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    resuelto boolean DEFAULT false NOT NULL,
    fecha_resolucion timestamp with time zone,
    CONSTRAINT ck_error_resolucion CHECK (((fecha_resolucion IS NULL) OR (fecha_resolucion >= fecha_hora)))
);


--
-- Name: error_integracion_id_error_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.error_integracion ALTER COLUMN id_error ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.error_integracion_id_error_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: establecimiento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.establecimiento (
    id_establecimiento bigint NOT NULL,
    nombre character varying(150) NOT NULL,
    slug character varying(100) NOT NULL,
    direccion character varying(250),
    zona_horaria character varying(60) DEFAULT 'America/Bogota'::character varying NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: establecimiento_id_establecimiento_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.establecimiento ALTER COLUMN id_establecimiento ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.establecimiento_id_establecimiento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: evento_analitico; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.evento_analitico (
    id_evento bigint NOT NULL,
    nombre_evento character varying(100) NOT NULL,
    timestamp_utc timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    id_establecimiento bigint,
    id_sesion bigint,
    device_hash character varying(255),
    youtube_video_id character varying(30),
    origen_app character varying(50),
    version_app character varying(40),
    propiedades jsonb DEFAULT '{}'::jsonb NOT NULL,
    CONSTRAINT ck_evento_propiedades_objeto CHECK ((jsonb_typeof(propiedades) = 'object'::text))
);


--
-- Name: evento_analitico_id_evento_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.evento_analitico ALTER COLUMN id_evento ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.evento_analitico_id_evento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: evento_calendario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.evento_calendario (
    id_evento_calendario bigint NOT NULL,
    id_establecimiento bigint NOT NULL,
    nombre character varying(150) NOT NULL,
    descripcion text,
    fecha date NOT NULL,
    hora_inicio time without time zone NOT NULL,
    hora_fin time without time zone NOT NULL,
    tipo character varying(60) NOT NULL,
    CONSTRAINT ck_evento_horas CHECK ((hora_inicio <> hora_fin))
);


--
-- Name: evento_calendario_id_evento_calendario_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.evento_calendario ALTER COLUMN id_evento_calendario ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.evento_calendario_id_evento_calendario_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: horario_operacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.horario_operacion (
    id_horario bigint NOT NULL,
    id_establecimiento bigint NOT NULL,
    dia_semana smallint NOT NULL,
    hora_inicio time without time zone NOT NULL,
    hora_fin time without time zone NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    CONSTRAINT ck_horario_horas CHECK ((hora_inicio <> hora_fin)),
    CONSTRAINT horario_operacion_dia_semana_check CHECK (((dia_semana >= 1) AND (dia_semana <= 7)))
);


--
-- Name: horario_operacion_id_horario_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.horario_operacion ALTER COLUMN id_horario ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.horario_operacion_id_horario_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: lista_defecto; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lista_defecto (
    id_lista bigint NOT NULL,
    id_establecimiento bigint NOT NULL,
    nombre character varying(150) NOT NULL,
    modo_rotacion character varying(30) DEFAULT 'secuencial'::character varying NOT NULL,
    activa boolean DEFAULT true NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_modificacion timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT ck_lista_modo CHECK (((modo_rotacion)::text = ANY ((ARRAY['secuencial'::character varying, 'aleatorio'::character varying])::text[])))
);


--
-- Name: lista_defecto_id_lista_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.lista_defecto ALTER COLUMN id_lista ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.lista_defecto_id_lista_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: reproduccion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reproduccion (
    id_reproduccion bigint NOT NULL,
    id_sesion bigint NOT NULL,
    id_cancion bigint NOT NULL,
    id_solicitud bigint,
    id_elemento bigint,
    fecha_inicio timestamp with time zone,
    fecha_fin timestamp with time zone,
    segundos_reproducidos integer DEFAULT 0 NOT NULL,
    resultado character varying(25) DEFAULT 'iniciada'::character varying NOT NULL,
    CONSTRAINT ck_reproduccion_fechas CHECK (((fecha_fin IS NULL) OR (fecha_inicio IS NULL) OR (fecha_fin >= fecha_inicio))),
    CONSTRAINT ck_reproduccion_resultado CHECK (((resultado)::text = ANY ((ARRAY['iniciada'::character varying, 'completada'::character varying, 'fallida'::character varying, 'saltada'::character varying, 'cancelada'::character varying])::text[]))),
    CONSTRAINT ck_reproduccion_segundos CHECK ((segundos_reproducidos >= 0)),
    CONSTRAINT ck_reproduccion_un_origen CHECK ((((id_solicitud IS NOT NULL) AND (id_elemento IS NULL)) OR ((id_solicitud IS NULL) AND (id_elemento IS NOT NULL))))
);


--
-- Name: reproduccion_id_reproduccion_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.reproduccion ALTER COLUMN id_reproduccion ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.reproduccion_id_reproduccion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: rol; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rol (
    id_rol smallint NOT NULL,
    nombre character varying(40) NOT NULL,
    descripcion character varying(250)
);


--
-- Name: rol_id_rol_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.rol ALTER COLUMN id_rol ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rol_id_rol_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sesion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sesion (
    id_sesion bigint NOT NULL,
    id_establecimiento bigint NOT NULL,
    id_evento_calendario bigint,
    fecha_apertura timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_cierre timestamp with time zone,
    tipo_evento character varying(60),
    estado character varying(20) DEFAULT 'abierta'::character varying NOT NULL,
    indice_lista_defecto integer DEFAULT 1 NOT NULL,
    CONSTRAINT ck_sesion_estado CHECK (((estado)::text = ANY ((ARRAY['abierta'::character varying, 'cerrada'::character varying])::text[]))),
    CONSTRAINT ck_sesion_fechas CHECK (((fecha_cierre IS NULL) OR (fecha_cierre >= fecha_apertura))),
    CONSTRAINT ck_sesion_indice CHECK ((indice_lista_defecto > 0))
);


--
-- Name: sesion_id_sesion_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.sesion ALTER COLUMN id_sesion ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sesion_id_sesion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: solicitud; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.solicitud (
    id_solicitud bigint NOT NULL,
    id_sesion bigint NOT NULL,
    id_cancion bigint NOT NULL,
    id_dispositivo_solicitante bigint NOT NULL,
    fecha_solicitud timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    estado character varying(25) DEFAULT 'pendiente'::character varying NOT NULL,
    motivo_estado text,
    CONSTRAINT ck_solicitud_estado CHECK (((estado)::text = ANY ((ARRAY['pendiente'::character varying, 'reproduciendo'::character varying, 'reproducida'::character varying, 'saltada'::character varying, 'no_disponible'::character varying, 'bloqueada'::character varying, 'expirada'::character varying, 'retirada'::character varying])::text[])))
);


--
-- Name: solicitud_id_solicitud_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.solicitud ALTER COLUMN id_solicitud ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.solicitud_id_solicitud_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usuario (
    id_usuario bigint NOT NULL,
    id_establecimiento bigint NOT NULL,
    id_rol smallint NOT NULL,
    nombre character varying(120) NOT NULL,
    correo character varying(254) NOT NULL,
    password_hash text NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    cambiar_password boolean DEFAULT false NOT NULL,
    intentos_fallidos smallint DEFAULT 0 NOT NULL,
    bloqueado_hasta timestamp with time zone,
    fecha_creacion timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT ck_usuario_intentos CHECK ((intentos_fallidos >= 0))
);


--
-- Name: usuario_id_usuario_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.usuario ALTER COLUMN id_usuario ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.usuario_id_usuario_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: voto; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.voto (
    id_voto bigint NOT NULL,
    id_solicitud bigint NOT NULL,
    id_dispositivo bigint NOT NULL,
    fecha_voto timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    fecha_retiro timestamp with time zone,
    CONSTRAINT ck_voto_fechas CHECK (((fecha_retiro IS NULL) OR (fecha_retiro >= fecha_voto)))
);


--
-- Name: voto_id_voto_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.voto ALTER COLUMN id_voto ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.voto_id_voto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: accion_admin accion_admin_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accion_admin
    ADD CONSTRAINT accion_admin_pkey PRIMARY KEY (id_accion);


--
-- Name: bloqueo_contenido bloqueo_contenido_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bloqueo_contenido
    ADD CONSTRAINT bloqueo_contenido_pkey PRIMARY KEY (id_bloqueo);


--
-- Name: busqueda_cache busqueda_cache_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.busqueda_cache
    ADD CONSTRAINT busqueda_cache_pkey PRIMARY KEY (id_cache);


--
-- Name: cancion cancion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cancion
    ADD CONSTRAINT cancion_pkey PRIMARY KEY (id_cancion);


--
-- Name: cancion cancion_youtube_video_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cancion
    ADD CONSTRAINT cancion_youtube_video_id_key UNIQUE (youtube_video_id);


--
-- Name: codigo_qr codigo_qr_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.codigo_qr
    ADD CONSTRAINT codigo_qr_pkey PRIMARY KEY (id_qr);


--
-- Name: codigo_qr codigo_qr_token_hash_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.codigo_qr
    ADD CONSTRAINT codigo_qr_token_hash_key UNIQUE (token_hash);


--
-- Name: configuracion_servicio configuracion_servicio_id_establecimiento_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuracion_servicio
    ADD CONSTRAINT configuracion_servicio_id_establecimiento_key UNIQUE (id_establecimiento);


--
-- Name: configuracion_servicio configuracion_servicio_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuracion_servicio
    ADD CONSTRAINT configuracion_servicio_pkey PRIMARY KEY (id_configuracion);


--
-- Name: dispositivo dispositivo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dispositivo
    ADD CONSTRAINT dispositivo_pkey PRIMARY KEY (id_dispositivo);


--
-- Name: ejecucion_pipeline ejecucion_pipeline_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ejecucion_pipeline
    ADD CONSTRAINT ejecucion_pipeline_pkey PRIMARY KEY (id_ejecucion);


--
-- Name: elemento_lista elemento_lista_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.elemento_lista
    ADD CONSTRAINT elemento_lista_pkey PRIMARY KEY (id_elemento);


--
-- Name: error_integracion error_integracion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.error_integracion
    ADD CONSTRAINT error_integracion_pkey PRIMARY KEY (id_error);


--
-- Name: establecimiento establecimiento_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.establecimiento
    ADD CONSTRAINT establecimiento_pkey PRIMARY KEY (id_establecimiento);


--
-- Name: establecimiento establecimiento_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.establecimiento
    ADD CONSTRAINT establecimiento_slug_key UNIQUE (slug);


--
-- Name: evento_analitico evento_analitico_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.evento_analitico
    ADD CONSTRAINT evento_analitico_pkey PRIMARY KEY (id_evento);


--
-- Name: evento_calendario evento_calendario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.evento_calendario
    ADD CONSTRAINT evento_calendario_pkey PRIMARY KEY (id_evento_calendario);


--
-- Name: horario_operacion horario_operacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.horario_operacion
    ADD CONSTRAINT horario_operacion_pkey PRIMARY KEY (id_horario);


--
-- Name: lista_defecto lista_defecto_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lista_defecto
    ADD CONSTRAINT lista_defecto_pkey PRIMARY KEY (id_lista);


--
-- Name: reproduccion reproduccion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reproduccion
    ADD CONSTRAINT reproduccion_pkey PRIMARY KEY (id_reproduccion);


--
-- Name: rol rol_nombre_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rol
    ADD CONSTRAINT rol_nombre_key UNIQUE (nombre);


--
-- Name: rol rol_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rol
    ADD CONSTRAINT rol_pkey PRIMARY KEY (id_rol);


--
-- Name: sesion sesion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sesion
    ADD CONSTRAINT sesion_pkey PRIMARY KEY (id_sesion);


--
-- Name: solicitud solicitud_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solicitud
    ADD CONSTRAINT solicitud_pkey PRIMARY KEY (id_solicitud);


--
-- Name: busqueda_cache uq_cache_consulta_region_idioma; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.busqueda_cache
    ADD CONSTRAINT uq_cache_consulta_region_idioma UNIQUE (consulta_normalizada, region, idioma);


--
-- Name: dispositivo uq_dispositivo_est_hash; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dispositivo
    ADD CONSTRAINT uq_dispositivo_est_hash UNIQUE (id_establecimiento, device_hash);


--
-- Name: elemento_lista uq_elemento_lista_cancion; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.elemento_lista
    ADD CONSTRAINT uq_elemento_lista_cancion UNIQUE (id_lista, id_cancion);


--
-- Name: elemento_lista uq_elemento_lista_orden; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.elemento_lista
    ADD CONSTRAINT uq_elemento_lista_orden UNIQUE (id_lista, orden);


--
-- Name: usuario uq_usuario_correo_establecimiento; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT uq_usuario_correo_establecimiento UNIQUE (id_establecimiento, correo);


--
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id_usuario);


--
-- Name: voto voto_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.voto
    ADD CONSTRAINT voto_pkey PRIMARY KEY (id_voto);


--
-- Name: ix_accion_admin_establecimiento_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_accion_admin_establecimiento_fecha ON public.accion_admin USING btree (id_establecimiento, fecha DESC);


--
-- Name: ix_bloqueo_establecimiento_cancion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_bloqueo_establecimiento_cancion ON public.bloqueo_contenido USING btree (id_establecimiento, id_cancion) WHERE (activo = true);


--
-- Name: ix_cache_expiracion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_cache_expiracion ON public.busqueda_cache USING btree (expira_en);


--
-- Name: ix_error_integracion_establecimiento_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_error_integracion_establecimiento_fecha ON public.error_integracion USING btree (id_establecimiento, fecha_hora DESC);


--
-- Name: ix_evento_analitico_timestamp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_evento_analitico_timestamp ON public.evento_analitico USING btree (timestamp_utc);


--
-- Name: ix_evento_establecimiento_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_evento_establecimiento_fecha ON public.evento_calendario USING btree (id_establecimiento, fecha);


--
-- Name: ix_horario_establecimiento; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_horario_establecimiento ON public.horario_operacion USING btree (id_establecimiento, dia_semana);


--
-- Name: ix_reproduccion_cancion_inicio; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_reproduccion_cancion_inicio ON public.reproduccion USING btree (id_cancion, fecha_inicio DESC);


--
-- Name: ix_reproduccion_sesion_inicio; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_reproduccion_sesion_inicio ON public.reproduccion USING btree (id_sesion, fecha_inicio);


--
-- Name: ix_sesion_establecimiento_apertura; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_sesion_establecimiento_apertura ON public.sesion USING btree (id_establecimiento, fecha_apertura DESC);


--
-- Name: ix_solicitud_dispositivo_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_solicitud_dispositivo_fecha ON public.solicitud USING btree (id_dispositivo_solicitante, fecha_solicitud DESC);


--
-- Name: ix_solicitud_sesion_estado_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_solicitud_sesion_estado_fecha ON public.solicitud USING btree (id_sesion, estado, fecha_solicitud);


--
-- Name: ix_usuario_establecimiento_rol; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_usuario_establecimiento_rol ON public.usuario USING btree (id_establecimiento, id_rol);


--
-- Name: ix_voto_solicitud_activo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_voto_solicitud_activo ON public.voto USING btree (id_solicitud) WHERE (activo = true);


--
-- Name: uq_lista_activa_por_establecimiento; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_lista_activa_por_establecimiento ON public.lista_defecto USING btree (id_establecimiento) WHERE (activa = true);


--
-- Name: uq_reproduccion_activa_sesion; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_reproduccion_activa_sesion ON public.reproduccion USING btree (id_sesion) WHERE ((resultado)::text = 'iniciada'::text);


--
-- Name: uq_solicitud_sesion_cancion_activa; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_solicitud_sesion_cancion_activa ON public.solicitud USING btree (id_sesion, id_cancion) WHERE ((estado)::text = ANY ((ARRAY['pendiente'::character varying, 'reproduciendo'::character varying])::text[]));


--
-- Name: uq_voto_activo_solicitud_dispositivo; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_voto_activo_solicitud_dispositivo ON public.voto USING btree (id_solicitud, id_dispositivo) WHERE (activo = true);


--
-- Name: accion_admin fk_accion_establecimiento; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accion_admin
    ADD CONSTRAINT fk_accion_establecimiento FOREIGN KEY (id_establecimiento) REFERENCES public.establecimiento(id_establecimiento);


--
-- Name: accion_admin fk_accion_usuario; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accion_admin
    ADD CONSTRAINT fk_accion_usuario FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario) ON DELETE SET NULL;


--
-- Name: bloqueo_contenido fk_bloqueo_cancion; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bloqueo_contenido
    ADD CONSTRAINT fk_bloqueo_cancion FOREIGN KEY (id_cancion) REFERENCES public.cancion(id_cancion);


--
-- Name: bloqueo_contenido fk_bloqueo_establecimiento; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bloqueo_contenido
    ADD CONSTRAINT fk_bloqueo_establecimiento FOREIGN KEY (id_establecimiento) REFERENCES public.establecimiento(id_establecimiento);


--
-- Name: bloqueo_contenido fk_bloqueo_usuario; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bloqueo_contenido
    ADD CONSTRAINT fk_bloqueo_usuario FOREIGN KEY (id_usuario) REFERENCES public.usuario(id_usuario);


--
-- Name: configuracion_servicio fk_configuracion_establecimiento; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuracion_servicio
    ADD CONSTRAINT fk_configuracion_establecimiento FOREIGN KEY (id_establecimiento) REFERENCES public.establecimiento(id_establecimiento) ON DELETE CASCADE;


--
-- Name: dispositivo fk_dispositivo_establecimiento; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dispositivo
    ADD CONSTRAINT fk_dispositivo_establecimiento FOREIGN KEY (id_establecimiento) REFERENCES public.establecimiento(id_establecimiento) ON DELETE CASCADE;


--
-- Name: elemento_lista fk_elemento_cancion; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.elemento_lista
    ADD CONSTRAINT fk_elemento_cancion FOREIGN KEY (id_cancion) REFERENCES public.cancion(id_cancion);


--
-- Name: elemento_lista fk_elemento_lista; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.elemento_lista
    ADD CONSTRAINT fk_elemento_lista FOREIGN KEY (id_lista) REFERENCES public.lista_defecto(id_lista) ON DELETE CASCADE;


--
-- Name: error_integracion fk_error_establecimiento; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.error_integracion
    ADD CONSTRAINT fk_error_establecimiento FOREIGN KEY (id_establecimiento) REFERENCES public.establecimiento(id_establecimiento);


--
-- Name: error_integracion fk_error_sesion; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.error_integracion
    ADD CONSTRAINT fk_error_sesion FOREIGN KEY (id_sesion) REFERENCES public.sesion(id_sesion) ON DELETE SET NULL;


--
-- Name: evento_calendario fk_evento_establecimiento; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.evento_calendario
    ADD CONSTRAINT fk_evento_establecimiento FOREIGN KEY (id_establecimiento) REFERENCES public.establecimiento(id_establecimiento) ON DELETE CASCADE;


--
-- Name: horario_operacion fk_horario_establecimiento; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.horario_operacion
    ADD CONSTRAINT fk_horario_establecimiento FOREIGN KEY (id_establecimiento) REFERENCES public.establecimiento(id_establecimiento) ON DELETE CASCADE;


--
-- Name: lista_defecto fk_lista_establecimiento; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lista_defecto
    ADD CONSTRAINT fk_lista_establecimiento FOREIGN KEY (id_establecimiento) REFERENCES public.establecimiento(id_establecimiento);


--
-- Name: codigo_qr fk_qr_establecimiento; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.codigo_qr
    ADD CONSTRAINT fk_qr_establecimiento FOREIGN KEY (id_establecimiento) REFERENCES public.establecimiento(id_establecimiento) ON DELETE CASCADE;


--
-- Name: reproduccion fk_reproduccion_cancion; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reproduccion
    ADD CONSTRAINT fk_reproduccion_cancion FOREIGN KEY (id_cancion) REFERENCES public.cancion(id_cancion);


--
-- Name: reproduccion fk_reproduccion_elemento; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reproduccion
    ADD CONSTRAINT fk_reproduccion_elemento FOREIGN KEY (id_elemento) REFERENCES public.elemento_lista(id_elemento);


--
-- Name: reproduccion fk_reproduccion_sesion; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reproduccion
    ADD CONSTRAINT fk_reproduccion_sesion FOREIGN KEY (id_sesion) REFERENCES public.sesion(id_sesion);


--
-- Name: reproduccion fk_reproduccion_solicitud; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reproduccion
    ADD CONSTRAINT fk_reproduccion_solicitud FOREIGN KEY (id_solicitud) REFERENCES public.solicitud(id_solicitud);


--
-- Name: sesion fk_sesion_establecimiento; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sesion
    ADD CONSTRAINT fk_sesion_establecimiento FOREIGN KEY (id_establecimiento) REFERENCES public.establecimiento(id_establecimiento);


--
-- Name: sesion fk_sesion_evento; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sesion
    ADD CONSTRAINT fk_sesion_evento FOREIGN KEY (id_evento_calendario) REFERENCES public.evento_calendario(id_evento_calendario) ON DELETE SET NULL;


--
-- Name: solicitud fk_solicitud_cancion; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solicitud
    ADD CONSTRAINT fk_solicitud_cancion FOREIGN KEY (id_cancion) REFERENCES public.cancion(id_cancion);


--
-- Name: solicitud fk_solicitud_dispositivo; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solicitud
    ADD CONSTRAINT fk_solicitud_dispositivo FOREIGN KEY (id_dispositivo_solicitante) REFERENCES public.dispositivo(id_dispositivo);


--
-- Name: solicitud fk_solicitud_sesion; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solicitud
    ADD CONSTRAINT fk_solicitud_sesion FOREIGN KEY (id_sesion) REFERENCES public.sesion(id_sesion);


--
-- Name: usuario fk_usuario_establecimiento; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT fk_usuario_establecimiento FOREIGN KEY (id_establecimiento) REFERENCES public.establecimiento(id_establecimiento);


--
-- Name: usuario fk_usuario_rol; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT fk_usuario_rol FOREIGN KEY (id_rol) REFERENCES public.rol(id_rol);


--
-- Name: voto fk_voto_dispositivo; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.voto
    ADD CONSTRAINT fk_voto_dispositivo FOREIGN KEY (id_dispositivo) REFERENCES public.dispositivo(id_dispositivo);


--
-- Name: voto fk_voto_solicitud; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.voto
    ADD CONSTRAINT fk_voto_solicitud FOREIGN KEY (id_solicitud) REFERENCES public.solicitud(id_solicitud) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--


