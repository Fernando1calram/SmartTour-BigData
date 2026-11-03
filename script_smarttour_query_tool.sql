DROP TABLE IF EXISTS staging_municipios CASCADE;
CREATE TABLE staging_municipios (
    municipio VARCHAR(150),
    cod_municipio VARCHAR(10),
    provincia VARCHAR(100),
    cod_provincia VARCHAR(5),
    cod_ine VARCHAR(10),
    poblacion INTEGER,
    mancomunidades TEXT,
    entidades_locales_menores TEXT,
    comarca VARCHAR(250),
    longitud DECIMAL(12,8),
    latitud DECIMAL(12,8),
    coordenada_x DECIMAL(15,2),
    coordenada_y DECIMAL(15,2)
);

DROP TABLE IF EXISTS staging_hoteles CASCADE;
CREATE TABLE staging_hoteles (
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
    plazas INTEGER,
    gps_longitud DECIMAL(12,8),
    gps_latitud DECIMAL(12,8),
    accesible_discapacidad VARCHAR(20)
);

DROP TABLE IF EXISTS staging_monumentos CASCADE;
CREATE TABLE staging_monumentos (
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

DROP TABLE IF EXISTS staging_oficinas CASCADE;
CREATE TABLE staging_oficinas (
    provincia VARCHAR(100),
    localidad VARCHAR(200),
    tipo VARCHAR(200),
    nombre_recurso VARCHAR(500),
    establecimiento VARCHAR(250),
    ambito VARCHAR(100)
);

COPY staging_municipios (
    municipio, cod_municipio, provincia, cod_provincia, cod_ine,
    poblacion, mancomunidades, entidades_locales_menores, comarca,
    longitud, latitud, coordenada_x, coordenada_y
)
FROM '/smarttour/datasets/municipios.csv'
DELIMITER ';' CSV HEADER;

COPY staging_hoteles (
    n_registro, tipo, categoria, especialidades, nombre, direccion,
    codigo_postal, provincia, municipio, localidad, nucleo,
    telefono1, telefono2, telefono3, email, web, q_calidad,
    central_reservas, plazas, gps_longitud, gps_latitud,
    accesible_discapacidad
)
FROM '/smarttour/datasets/hoteles.csv'
DELIMITER ';' CSV HEADER;

COPY staging_monumentos (
    identificador, nombre, tipo_monumento, identificador_bic, calle,
    clasificacion, tipo_construccion, codigo_postal, descripcion,
    periodo_historico, coordenadas_latitud, coordenadas_longitud,
    poblacion_provincia, poblacion_municipio, poblacion_localidad,
    pto_geolocalizado, poblacion, coordenadas
)
FROM '/smarttour/datasets/monumentos.csv'
DELIMITER ';' CSV HEADER;

COPY staging_oficinas (
    provincia, localidad, tipo, nombre_recurso, establecimiento, ambito
)
FROM '/smarttour/datasets/oficinas.csv'
DELIMITER ';' CSV HEADER;

DROP TABLE IF EXISTS dim_fecha CASCADE;
CREATE TABLE dim_fecha (
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

DROP TABLE IF EXISTS hecho_hoteles CASCADE;
CREATE TABLE hecho_hoteles (
    reserva_id BIGSERIAL PRIMARY KEY,
    fecha_reserva_key INTEGER NOT NULL REFERENCES dim_fecha(fecha_key),
    fecha_entrada_key INTEGER NOT NULL REFERENCES dim_fecha(fecha_key),
    fecha_salida_key INTEGER NOT NULL REFERENCES dim_fecha(fecha_key),
    hotel_key INTEGER NOT NULL REFERENCES dim_hotel(hotel_key),
    municipio_key INTEGER NOT NULL REFERENCES dim_municipio(municipio_key),
    turistas INTEGER NOT NULL CHECK (turistas > 0),
    noches INTEGER NOT NULL CHECK (noches > 0),
    importe DECIMAL(12,2) NOT NULL CHECK (importe >= 0),
    num_reservas INTEGER NOT NULL DEFAULT 1 CHECK (num_reservas = 1)
);

DROP TABLE IF EXISTS hecho_monumentos CASCADE;
CREATE TABLE hecho_monumentos (
    fecha_key INTEGER NOT NULL REFERENCES dim_fecha(fecha_key),
    monumento_key INTEGER NOT NULL REFERENCES dim_monumento(monumento_key),
    municipio_key INTEGER NOT NULL REFERENCES dim_municipio(municipio_key),
    num_visitas INTEGER NOT NULL CHECK (num_visitas >= 0),
    num_entradas INTEGER NOT NULL DEFAULT 0 CHECK (num_entradas >= 0),
    importe_entradas DECIMAL(12,2) NOT NULL DEFAULT 0 CHECK (importe_entradas >= 0),
    num_visitas_gratuitas INTEGER NOT NULL DEFAULT 0 CHECK (num_visitas_gratuitas >= 0),
    PRIMARY KEY (fecha_key, monumento_key)
);

DROP TABLE IF EXISTS hecho_oficinas CASCADE;
CREATE TABLE hecho_oficinas (
    fecha_key INTEGER NOT NULL REFERENCES dim_fecha(fecha_key),
    oficina_key INTEGER NOT NULL REFERENCES dim_oficina_turismo(oficina_key),
    municipio_key INTEGER NOT NULL REFERENCES dim_municipio(municipio_key),
    num_visitas INTEGER NOT NULL CHECK (num_visitas >= 0),
    num_grupos INTEGER NOT NULL DEFAULT 0 CHECK (num_grupos >= 0),
    num_consultas INTEGER NOT NULL DEFAULT 0 CHECK (num_consultas >= 0),
    num_visitas_individuales INTEGER NOT NULL DEFAULT 0 CHECK (num_visitas_individuales >= 0),
    PRIMARY KEY (fecha_key, oficina_key)
);

-- Dimensión municipio
INSERT INTO dim_municipio (
    municipio_id, nombre, provincia, cod_provincia, cod_ine,
    poblacion, comarca, longitud, latitud
)
SELECT
    cod_ine,
    INITCAP(municipio),
    INITCAP(provincia),
    cod_provincia,
    cod_ine,
    poblacion,
    comarca,
    longitud,
    latitud
FROM staging_municipios
WHERE cod_ine IS NOT NULL
ON CONFLICT (municipio_id) DO NOTHING;

-- Dimensión hotel
INSERT INTO dim_hotel (
    hotel_id, nombre, tipo, categoria, direccion, codigo_postal,
    localidad, telefono, email, web, plazas,
    accesible_discapacidad, fecha_inicio, esSí: **hay que modificar el script**. El enunciado pide un Data Warehouse con dimensiones (`dim_*`), tablas de hechos (`fact_*`) y claves sustitutas; no basta con crear las cuatro tablas planas y cargar los CSV originales. Además, el `COPY` del enunciado no corresponde con las cabeceras reales de los CSV adjuntos. [1][2][3][4]

## Modelo recomendado

Usa un modelo en constelación: las dimensiones `dim_municipio`, `dim_hotel`, `dim_oficina_turismo` y `dim_monumento` se cargan desde los CSV; las tablas de hechos se generan posteriormente con datos sintéticos, tal como pide el ejercicio. [5]

```sql
-- ============================================
-- DIMENSIÓN: MUNICIPIOS
-- ============================================
CREATE TABLE dim_municipio (
    municipio_key SERIAL PRIMARY KEY,
    municipio_id VARCHAR(20) UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    cod_municipio VARCHAR(10),
    provincia VARCHAR(50) NOT NULL,
    cod_provincia VARCHAR(5),
    cod_ine VARCHAR(10),
    poblacion INTEGER,
    mancomunidades TEXT,
    entidades_locales_menores TEXT,
    comarca VARCHAR(150),
    longitud DECIMAL(12,8),
    latitud DECIMAL(12,8),
    coordenada_x DECIMAL(15,2),
    coordenada_y DECIMAL(15,2)
);

-- ============================================
-- DIMENSIÓN: HOTELES
-- ============================================
CREATE TABLE dim_hotel (
    hotel_key SERIAL PRIMARY KEY,
    hotel_id VARCHAR(30) UNIQUE NOT NULL,
    nombre VARCHAR(200) NOT NULL,
    tipo VARCHAR(50),
    categoria VARCHAR(50),
    especialidades TEXT,
    direccion VARCHAR(300),
    codigo_postal VARCHAR(10),
    provincia VARCHAR(50),
    municipio VARCHAR(100),
    localidad VARCHAR(100),
    nucleo VARCHAR(100),
    telefono VARCHAR(20),
    email VARCHAR(200),
    web VARCHAR(300),
    plazas INTEGER,
    gps_longitud DECIMAL(12,8),
    gps_latitud DECIMAL(12,8),
    accesible_discapacidad VARCHAR(10),
    municipio_key INTEGER REFERENCES dim_municipio (municipio_key)
);

-- ============================================
-- DIMENSIÓN: OFICINAS DE TURISMO
-- ============================================
CREATE TABLE dim_oficina_turismo (
    oficina_key SERIAL PRIMARY KEY,
    oficina_id SERIAL UNIQUE,
    nombre VARCHAR(250) NOT NULL,
    tipo VARCHAR(100),
    establecimiento VARCHAR(150),
    ambito VARCHAR(100),
    provincia VARCHAR(50) NOT NULL,
    localidad VARCHAR(100) NOT NULL,
    municipio_key INTEGER REFERENCES dim_municipio (municipio_key)
);

-- ============================================
-- DIMENSIÓN: MONUMENTOS
-- ============================================
CREATE TABLE dim_monumento (
    monumento_key SERIAL PRIMARY KEY,
    monumento_id VARCHAR(30) UNIQUE NOT NULL,
    nombre VARCHAR(250) NOT NULL,
    tipo VARCHAR(100),
    identificador_bic VARCHAR(100),
    calle VARCHAR(300),
    clasificacion VARCHAR(100),
    tipo_construccion VARCHAR(150),
    codigo_postal VARCHAR(10),
    descripcion TEXT,
    periodo_historico VARCHAR(250),
    coordenadas_latitud DECIMAL(12,8),
    coordenadas_longitud DECIMAL(12,8),
    poblacion_provincia VARCHAR(50),
    poblacion_municipio VARCHAR(100),
    poblacion_localidad VARCHAR(100),
    municipio_key INTEGER REFERENCES dim_municipio (municipio_key)
);

-- ============================================
-- DIMENSIÓN: FECHA
-- ============================================
CREATE TABLE dim_fecha (
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
```

## Carga de dimensiones

Estos `COPY` sí coinciden con las columnas reales de los ficheros. El separador es `;`, no `,`. [1][2][3][4]

```sql
COPY dim_municipio (
    municipio_id, nombre, cod_municipio, provincia, cod_provincia,
    cod_ine, poblacion, mancomunidades, entidades_locales_menores,
    comarca, longitud, latitud, coordenada_x, coordenada_y
)
FROM '/smarttour/datasets/municipios.csv'
DELIMITER ';' CSV HEADER;

COPY dim_hotel (
    hotel_id, nombre, tipo, categoria, especialidades, direccion,
    codigo_postal, provincia, municipio, localidad, nucleo,
    telefono, email, web, plazas, gps_longitud, gps_latitud,
    accesible_discapacidad
)
FROM '/smarttour/datasets/hoteles.csv'
DELIMITER ';' CSV HEADER;

COPY dim_oficina_turismo (
    nombre, tipo, establecimiento, ambito, provincia, localidad
)
FROM '/smarttour/datasets/oficinas.csv'
DELIMITER ';' CSV HEADER;

COPY dim_monumento (
    monumento_id, nombre, tipo, identificador_bic, calle,
    clasificacion, tipo_construccion, codigo_postal, descripcion,
    periodo_historico, coordenadas_latitud, coordenadas_longitud,
    poblacion_provincia, poblacion_municipio, poblacion_localidad
)
FROM '/smarttour/datasets/monumentos.csv'
DELIMITER ';' CSV HEADER;
```

Después de cargar hoteles, oficinas y monumentos, actualiza `municipio_key` relacionando por nombre de municipio:

```sql
UPDATE dim_hotel h
SET municipio_key = m.municipio_key
FROM dim_municipio m
WHERE lower(trim(h.municipio)) = lower(trim(m.nombre));

UPDATE dim_oficina_turismo o
SET municipio_key = m.municipio_key
FROM dim_municipio m
WHERE lower(trim(o.localidad)) = lower(trim(m.nombre));

UPDATE dim_monumento mo
SET municipio_key = m.municipio_key
FROM dim_municipio m
WHERE lower(trim(mo.poblacion_municipio)) = lower(trim(m.nombre));
```

## Tablas de hechos

El enunciado pide **al menos 1.000 registros** por hecho. Estas tablas no se cargan desde los CSV originales: primero debes generar tres CSV sintéticos con las columnas siguientes y después importarlos. [5]

```sql
CREATE TABLE fact_reservas_hotel (
    reserva_id BIGINT PRIMARY KEY,
    fecha_reserva_key INTEGER NOT NULL REFERENCES dim_fecha (fecha_key),
    fecha_entrada_key INTEGER NOT NULL REFERENCES dim_fecha (fecha_key),
    fecha_salida_key INTEGER NOT NULL REFERENCES dim_fecha (fecha_key),
    hotel_key INTEGER NOT NULL REFERENCES dim_hotel (hotel_key),
    municipio_key INTEGER NOT NULL REFERENCES dim_municipio (municipio_key),
    turistas INTEGER NOT NULL CHECK (turistas > 0),
    noches INTEGER NOT NULL CHECK (noches > 0),
    importe DECIMAL(12,2) NOT NULL CHECK (importe >= 0),
    num_reservas INTEGER NOT NULL DEFAULT 1 CHECK (num_reservas = 1)
);

CREATE TABLE fact_visitas_oficinas (
    fecha_key INTEGER NOT NULL REFERENCES dim_fecha (fecha_key),
    oficina_key INTEGER NOT NULL REFERENCES dim_oficina_turismo (oficina_key),
    municipio_key INTEGER NOT NULL REFERENCES dim_municipio (municipio_key),
    num_visitas INTEGER NOT NULL CHECK (num_visitas >= 0),
    num_grupos INTEGER NOT NULL CHECK (num_grupos >= 0),
    num_consultas INTEGER NOT NULL CHECK (num_consultas >= 0),
    num_visitas_individuales INTEGER NOT NULL CHECK (num_visitas_individuales >= 0),
    PRIMARY KEY (fecha_key, oficina_key)
);

CREATE TABLE fact_visitas_monumentos (
    fecha_key INTEGER NOT NULL REFERENCES dim_fecha (fecha_key),
    monumento_key INTEGER NOT NULL REFERENCES dim_monumento (monumento_key),
    municipio_key INTEGER NOT NULL REFERENCES dim_municipio (municipio_key),
    num_visitas INTEGER NOT NULL CHECK (num_visitas >= 0),
    num_entradas INTEGER NOT NULL CHECK (num_entradas >= 0),
    importe_entradas DECIMAL(12,2) NOT NULL CHECK (importe_entradas >= 0),
    num_visitas_gratuitas INTEGER NOT NULL CHECK (num_visitas_gratuitas >= 0),
    PRIMARY KEY (fecha_key, monumento_key)
);
```

## Carga de hechos

Una vez generados los CSV, por ejemplo `fact_reservas_hotel.csv`, `fact_visitas_oficinas.csv` y `fact_visitas_monumentos.csv`:

```sql
COPY fact_reservas_hotel (
    reserva_id, fecha_reserva_key, fecha_entrada_key, fecha_salida_key,
    hotel_key, municipio_key, turistas, noches, importe, num_reservas
)
FROM '/smarttour/datasets/fact_reservas_hotel.csv'
DELIMITER ';' CSV HEADER;

COPY fact_visitas_oficinas (
    fecha_key, oficina_key, municipio_key, num_visitas, num_grupos,
    num_consultas, num_visitas_individuales
)
FROM '/smarttour/datasets/fact_visitas_oficinas.csv'
DELIMITER ';' CSV HEADER;

COPY fact_visitas_monumentos (
    fecha_key, monumento_key, municipio_key, num_visitas,
    num_entradas, importe_entradas, num_visitas_gratuitas
)
FROM '/smarttour/datasets/fact_visitas_monumentos.csv'
DELIMITER ';' CSV HEADER;
```

## Qué cambia respecto al enunciado

- **No uses `id_hotel`, `id_monumento` ni `id_oficina` como claves primarias dimensionales**: el enunciado recomienda claves sustitutas (`hotel_key`, `monumento_key`, `oficina_key`) y conservar el identificador original como atributo. [5]
- **No crees las relaciones directamente entre `dim_hotel`, `dim_monumento` y `dim_municipio` como base del análisis**: las tablas de hechos guardan ambas claves y el ETL debe asegurar su coherencia. [5]
- **No cargues las tablas de hechos desde los CSV turísticos originales**: estos solo alimentan las dimensiones; los hechos requieren generar reservas y visitas. [5]
- **No uses el `COPY` con `,`**: los CSV adjuntos están delimitados por `;`. [1][2][3][4]
- **No unas directamente las tres tablas de hechos**: agrega primero por municipio y periodo, como exige la vista final del ejercicio. [5]

