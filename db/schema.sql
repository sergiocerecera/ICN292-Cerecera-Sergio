
PRAGMA foreign_keys = ON;

CREATE TABLE CLIENTE (
    id_cliente INTEGER PRIMARY KEY,
    rut_cliente TEXT NOT NULL UNIQUE,
    razon_social TEXT NOT NULL,
    direccion TEXT,
    activo INTEGER DEFAULT 1
);

CREATE TABLE COLABORADOR (
    id_colaborador INTEGER PRIMARY KEY,
    nombre TEXT NOT NULL,
    correo_electronico TEXT NOT NULL UNIQUE,
    rol TEXT NOT NULL,
    area_principal TEXT,
    fecha_ingreso TEXT,
    id_supervisor INTEGER,
    activo INTEGER DEFAULT 1,
    FOREIGN KEY (id_supervisor)
        REFERENCES COLABORADOR(id_colaborador)
);

CREATE TABLE CARTERA (
    id_cartera INTEGER PRIMARY KEY,
    id_colaborador INTEGER NOT NULL,
    id_cliente INTEGER NOT NULL,
    area_servicio TEXT,
    fecha_asignacion TEXT,
    FOREIGN KEY (id_colaborador)
        REFERENCES COLABORADOR(id_colaborador),
    FOREIGN KEY (id_cliente)
        REFERENCES CLIENTE(id_cliente)
);

CREATE TABLE TIPO_DOCUMENTO (
    id_tipo_documento INTEGER PRIMARY KEY,
    nombre_tipo TEXT NOT NULL UNIQUE,
    descripcion TEXT,
    periodicidad TEXT
);

CREATE TABLE DOCUMENTO (
    id_documento INTEGER PRIMARY KEY,
    id_cliente INTEGER NOT NULL,
    id_tipo_documento INTEGER NOT NULL,
    periodo TEXT,
    FOREIGN KEY (id_cliente)
        REFERENCES CLIENTE(id_cliente),
    FOREIGN KEY (id_tipo_documento)
        REFERENCES TIPO_DOCUMENTO(id_tipo_documento)
);

CREATE TABLE VERSION_DOCUMENTO (
    id_version INTEGER PRIMARY KEY,
    id_documento INTEGER NOT NULL,
    numero_version INTEGER NOT NULL,
    id_colaborador_autor INTEGER NOT NULL,
    fecha_version TEXT,
    ruta_almacenamiento TEXT NOT NULL,
    UNIQUE (id_documento, numero_version),
    FOREIGN KEY (id_documento)
        REFERENCES DOCUMENTO(id_documento),
    FOREIGN KEY (id_colaborador_autor)
        REFERENCES COLABORADOR(id_colaborador)
);

CREATE TABLE PERMISO (
    id_permiso INTEGER PRIMARY KEY,
    id_colaborador INTEGER NOT NULL,
    id_cliente INTEGER NOT NULL,
    nivel_acceso TEXT NOT NULL,
    fecha_otorgamiento TEXT,
    otorgado_por INTEGER,
    vigente INTEGER DEFAULT 1,
    FOREIGN KEY (id_colaborador)
        REFERENCES COLABORADOR(id_colaborador),
    FOREIGN KEY (id_cliente)
        REFERENCES CLIENTE(id_cliente),
    FOREIGN KEY (otorgado_por)
        REFERENCES COLABORADOR(id_colaborador)
);

CREATE TABLE CONSULTA (
    id_consulta INTEGER PRIMARY KEY,
    id_colaborador INTEGER NOT NULL,
    id_cliente INTEGER NOT NULL,
    id_tipo_documento INTEGER,
    id_documento INTEGER,
    periodo_buscado TEXT,
    fecha_hora_inicio TEXT,
    fecha_hora_acceso TEXT,
    fecha_hora_fin TEXT,
    resultado TEXT,
    motivo_denegacion TEXT,
    requirio_equipo_origen INTEGER DEFAULT 0,
    bloqueada_por_equipo INTEGER DEFAULT 0,
    hubo_actualizacion INTEGER DEFAULT 0,
    FOREIGN KEY (id_colaborador)
        REFERENCES COLABORADOR(id_colaborador),
    FOREIGN KEY (id_cliente)
        REFERENCES CLIENTE(id_cliente),
    FOREIGN KEY (id_tipo_documento)
        REFERENCES TIPO_DOCUMENTO(id_tipo_documento),
    FOREIGN KEY (id_documento)
        REFERENCES DOCUMENTO(id_documento)
);

CREATE TABLE RESPALDO (
    id_respaldo INTEGER PRIMARY KEY,
    fecha_ejecucion TEXT,
    tipo TEXT,
    estado TEXT,
    detalle TEXT,
    nombre_zip TEXT,
    archivos_evaluados INTEGER,
    archivos_recuperados INTEGER
);

CREATE TABLE RESPALDO_DOCUMENTO (
    id_respaldo_documento INTEGER PRIMARY KEY,
    id_respaldo INTEGER NOT NULL,
    id_documento INTEGER NOT NULL,
    resultado_restauracion TEXT,
    FOREIGN KEY (id_respaldo)
        REFERENCES RESPALDO(id_respaldo),
    FOREIGN KEY (id_documento)
        REFERENCES DOCUMENTO(id_documento)
);

CREATE TABLE SEGUIMIENTO (
    id_seguimiento INTEGER PRIMARY KEY,
    id_consulta INTEGER NOT NULL,
    id_responsable INTEGER NOT NULL,
    id_asignado_por INTEGER NOT NULL,
    fecha_asignacion TEXT,
    accion TEXT,
    fecha_resolucion TEXT,
    FOREIGN KEY (id_consulta)
        REFERENCES CONSULTA(id_consulta),
    FOREIGN KEY (id_responsable)
        REFERENCES COLABORADOR(id_colaborador),
    FOREIGN KEY (id_asignado_por)
        REFERENCES COLABORADOR(id_colaborador)
);

CREATE TABLE BITACORA_ACCION (
    id_evento INTEGER PRIMARY KEY,
    fecha_hora TEXT,
    id_colaborador INTEGER,
    id_cliente INTEGER,
    id_documento INTEGER,
    accion TEXT,
    resultado TEXT,
    motivo TEXT,
    FOREIGN KEY (id_colaborador)
        REFERENCES COLABORADOR(id_colaborador),
    FOREIGN KEY (id_cliente)
        REFERENCES CLIENTE(id_cliente),
    FOREIGN KEY (id_documento)
        REFERENCES DOCUMENTO(id_documento)
);
