DROP TABLE IF EXISTS municipios CASCADE;
CREATE TABLE municipios (
    municipio VARCHAR(150),
    cod_municipio VARCHAR(10),
    provincia VARCHAR(100),
    cod_provincia VARCHAR(5),
    cod_ine VARCHAR(10),
    poblacion INTEGER,
    mancomunidades TEXT,
    entidades_locales_menores TEXT,
    comarca VARCHAR(250),
    longitud TEXT,
    latitud TEXT,
    coordenada_x TEXT,
    coordenada_y TEXT
);

DROP TABLE IF EXISTS hoteles CASCADE;
CREATE TABLE hoteles (
    n_registro VARCHAR(30),
    tipo VARCHAR(100),
    categoria VARCHAR(100),
    especialidades TEXT,
    nombre VARCHAR(300),
    direccion VARCHAR(500),
    codigo_postal VARCHAR(10),
    provincia VARCHAR(100),
    municipio VARCHAR(200),
    localidad VARCHAR(200),
    nucleo VARCHAR(200),
    telefono1 VARCHAR(50),
    telefono2 VARCHAR(50),
    telefono3 VARCHAR(50),
    email VARCHAR(500),
    web VARCHAR(500),
    q_calidad VARCHAR(20),
    central_reservas VARCHAR(20),
    plazas TEXT,
    gps_longitud TEXT,
    gps_latitud TEXT,
    accesible_discapacidad VARCHAR(20),
    columna_vacia TEXT
);

DROP TABLE IF EXISTS monumentos CASCADE;
CREATE TABLE monumentos (
    identificador BIGINT,
    nombre VARCHAR(500),
    tipo_monumento VARCHAR(250),
    identificador_bic VARCHAR(250),
    calle VARCHAR(500),
    clasificacion VARCHAR(250),
    tipo_construccion VARCHAR(250),
    codigo_postal VARCHAR(20),
    descripcion TEXT,
    periodo_historico VARCHAR(500),
    coordenadas_latitud DECIMAL(12,8),
    coordenadas_longitud DECIMAL(12,8),
    poblacion_provincia VARCHAR(100),
    poblacion_municipio VARCHAR(200),
    poblacion_localidad VARCHAR(200),
    pto_geolocalizado VARCHAR(200),
    poblacion TEXT,
    coordenadas TEXT
);

DROP TABLE IF EXISTS oficinas CASCADE;
CREATE TABLE oficinas (
    provincia VARCHAR(100),
    localidad VARCHAR(200),
    tipo VARCHAR(200),
    nombre_recurso VARCHAR(500),
    establecimiento VARCHAR(250),
    ambito VARCHAR(100)
);

COPY municipios (
    municipio, cod_municipio, provincia, cod_provincia, cod_ine,
    poblacion, mancomunidades, entidades_locales_menores, comarca,
    longitud, latitud, coordenada_x, coordenada_y
)
FROM '/smarttour/datasets/municipios/municipios.csv'
DELIMITER ';' CSV HEADER ENCODING 'LATIN1';

COPY hoteles (
    n_registro, tipo, categoria, especialidades, nombre, direccion,
    codigo_postal, provincia, municipio, localidad, nucleo,
    telefono1, telefono2, telefono3, email, web, q_calidad,
    central_reservas, plazas, gps_longitud, gps_latitud,
    accesible_discapacidad, columna_vacia
)
FROM '/smarttour/datasets/hoteles/hoteles.csv'
DELIMITER ';' CSV HEADER ENCODING 'LATIN1';

COPY monumentos (
    identificador, nombre, tipo_monumento, identificador_bic, calle,
    clasificacion, tipo_construccion, codigo_postal, descripcion,
    periodo_historico, coordenadas_latitud, coordenadas_longitud,
    poblacion_provincia, poblacion_municipio, poblacion_localidad,
    pto_geolocalizado, poblacion, coordenadas
)
FROM '/smarttour/datasets/monumentos/monumentos.csv'
DELIMITER ';' CSV HEADER ENCODING 'LATIN1';

COPY oficinas (
    provincia, localidad, tipo, nombre_recurso, establecimiento, ambito
)
FROM '/smarttour/datasets/oficinas_turismo/oficinas.csv'
DELIMITER ';' CSV HEADER ENCODING 'LATIN1';

DROP TABLE IF EXISTS dim_municipio CASCADE;
CREATE TABLE dim_municipio (
    municipio_key SERIAL PRIMARY KEY,
    municipio_id VARCHAR(20) UNIQUE,
    nombre VARCHAR(200) NOT NULL,
    provincia VARCHAR(100) NOT NULL,
    cod_provincia VARCHAR(5),
    cod_ine VARCHAR(10),
    poblacion INTEGER,
    comarca VARCHAR(250),
    longitud DECIMAL(12,8),
    latitud DECIMAL(12,8)
);

DROP TABLE IF EXISTS dim_hotel CASCADE;
CREATE TABLE dim_hotel (
    hotel_key SERIAL PRIMARY KEY,
    hotel_id VARCHAR(30) UNIQUE,
    nombre VARCHAR(300) NOT NULL,
    tipo VARCHAR(100),
    categoria VARCHAR(100),
    direccion VARCHAR(500),
    codigo_postal VARCHAR(10),
    localidad VARCHAR(200),
    telefono VARCHAR(50),
    email VARCHAR(500),
    web VARCHAR(500),
    plazas INTEGER,
    accesible_discapacidad BOOLEAN,
    fecha_inicio DATE,
    fecha_fin DATE,
    es_actual BOOLEAN DEFAULT TRUE
);

DROP TABLE IF EXISTS dim_monumento CASCADE;
CREATE TABLE dim_monumento (
    monumento_key SERIAL PRIMARY KEY,
    monumento_id BIGINT UNIQUE,
    nombre VARCHAR(500) NOT NULL,
    tipo VARCHAR(250),
    clasificacion VARCHAR(250),
    tipo_construccion VARCHAR(250),
    direccion VARCHAR(500),
    codigo_postal VARCHAR(20),
    periodo_historico VARCHAR(500),
    latitud DECIMAL(12,8),
    longitud DECIMAL(12,8)
);

DROP TABLE IF EXISTS dim_oficina_turismo CASCADE;
CREATE TABLE dim_oficina_turismo (
    oficina_key SERIAL PRIMARY KEY,
    oficina_id SERIAL UNIQUE,
    nombre VARCHAR(500) NOT NULL,
    tipo VARCHAR(200),
    establecimiento VARCHAR(250),
    localidad VARCHAR(200),
    provincia VARCHAR(100),
    ambito VARCHAR(100)
);

DROP TABLE IF EXISTS fechas CASCADE;
CREATE TABLE fechas (
    fecha_key INTEGER PRIMARY KEY,
    fecha DATE NOT NULL UNIQUE,
    dia INTEGER NOT NULL,
    mes INTEGER NOT NULL,
    nombre_mes VARCHAR(20) NOT NULL,
    trimestre INTEGER NOT NULL,
    anio INTEGER NOT NULL,
    dia_semana INTEGER NOT NULL,
    nombre_dia VARCHAR(20) NOT NULL,
    es_fin_semana BOOLEAN NOT NULL,
    temporada_turistica VARCHAR(30)
);

DROP TABLE IF EXISTS reservas CASCADE;
CREATE TABLE reservas (
    reserva_id BIGSERIAL PRIMARY KEY,
    fecha_reserva_key INTEGER NOT NULL REFERENCES fechas(fecha_key),
    fecha_entrada_key INTEGER NOT NULL REFERENCES fechas(fecha_key),
    fecha_salida_key INTEGER NOT NULL REFERENCES fechas(fecha_key),
    hotel_key INTEGER NOT NULL REFERENCES dim_hotel(hotel_key),
    municipio_key INTEGER NOT NULL REFERENCES dim_municipio(municipio_key),
    turistas INTEGER NOT NULL CHECK (turistas > 0),
    noches INTEGER NOT NULL CHECK (noches > 0),
    importe DECIMAL(12,2) NOT NULL CHECK (importe >= 0),
    num_reservas INTEGER NOT NULL DEFAULT 1 CHECK (num_reservas = 1)
);

DROP TABLE IF EXISTS visitas CASCADE;
CREATE TABLE visitas (
    fecha_key INTEGER NOT NULL REFERENCES fechas(fecha_key),
    monumento_key INTEGER NOT NULL REFERENCES dim_monumento(monumento_key),
    municipio_key INTEGER NOT NULL REFERENCES dim_municipio(municipio_key),
    num_visitas INTEGER NOT NULL CHECK (num_visitas >= 0),
    num_entradas INTEGER NOT NULL DEFAULT 0 CHECK (num_entradas >= 0),
    importe_entradas DECIMAL(12,2) NOT NULL DEFAULT 0 CHECK (importe_entradas >= 0),
    num_visitas_gratuitas INTEGER NOT NULL DEFAULT 0 CHECK (num_visitas_gratuitas >= 0),
    PRIMARY KEY (fecha_key, monumento_key)
);

DROP TABLE IF EXISTS visitadadas CASCADE;
CREATE TABLE visitadadas (
    fecha_key INTEGER NOT NULL REFERENCES fechas(fecha_key),
    oficina_key INTEGER NOT NULL REFERENCES dim_oficina_turismo(oficina_key),
    municipio_key INTEGER NOT NULL REFERENCES dim_municipio(municipio_key),
    num_visitas INTEGER NOT NULL CHECK (num_visitas >= 0),
    num_grupos INTEGER NOT NULL DEFAULT 0 CHECK (num_grupos >= 0),
    num_consultas INTEGER NOT NULL DEFAULT 0 CHECK (num_consultas >= 0),
    num_visitas_individuales INTEGER NOT NULL DEFAULT 0 CHECK (num_visitas_individuales >= 0),
    PRIMARY KEY (fecha_key, oficina_key)
);