-- Dimensiones compatibles con los hechos antiguos (separador coma).

-- Estos cuatro CSV de dimensiones usan punto y coma.

-- Se conserva fechas; no se borran tablas ni datos.

BEGIN;

DO $$ BEGIN IF EXISTS (SELECT 1 FROM public.dim_municipio) OR EXISTS (SELECT 1 FROM public.dim_hotel) OR EXISTS (SELECT 1 FROM public.dim_monumento) OR EXISTS (SELECT 1 FROM public.dim_oficina_turismo) THEN RAISE EXCEPTION 'Las cuatro dimensiones deben estar vacias'; END IF; END $$;

COPY public.dim_municipio (municipio_key, municipio_id, nombre, provincia, cod_provincia, cod_ine, poblacion, comarca, longitud, latitud) FROM '/smarttour/datasets/hechos_prueba/dim_municipio_compatibles.csv' WITH (FORMAT CSV, HEADER TRUE, DELIMITER ';', ENCODING 'UTF8');

COPY public.dim_hotel (hotel_key, hotel_id, nombre, tipo, categoria, direccion, codigo_postal, localidad, telefono, email, web, plazas, accesible_discapacidad, municipio_key, fecha_inicio, fecha_fin, es_actual) FROM '/smarttour/datasets/hechos_prueba/dim_hotel_compatibles.csv' WITH (FORMAT CSV, HEADER TRUE, DELIMITER ';', ENCODING 'UTF8');

COPY public.dim_monumento (monumento_key, monumento_id, nombre, tipo, clasificacion, tipo_construccion, direccion, codigo_postal, periodo_historico, latitud, longitud, municipio_key) FROM '/smarttour/datasets/hechos_prueba/dim_monumento_compatibles.csv' WITH (FORMAT CSV, HEADER TRUE, DELIMITER ';', ENCODING 'UTF8');

COPY public.dim_oficina_turismo (oficina_key, oficina_id, nombre, tipo, establecimiento, localidad, provincia, ambito, municipio_key) FROM '/smarttour/datasets/hechos_prueba/dim_oficina_turismo_compatibles.csv' WITH (FORMAT CSV, HEADER TRUE, DELIMITER ';', ENCODING 'UTF8');

SELECT setval(pg_get_serial_sequence('public.dim_municipio','municipio_key'), (SELECT MAX(municipio_key) FROM public.dim_municipio), true);

SELECT setval(pg_get_serial_sequence('public.dim_hotel','hotel_key'), (SELECT MAX(hotel_key) FROM public.dim_hotel), true);

SELECT setval(pg_get_serial_sequence('public.dim_monumento','monumento_key'), (SELECT MAX(monumento_key) FROM public.dim_monumento), true);

SELECT setval(pg_get_serial_sequence('public.dim_oficina_turismo','oficina_key'), (SELECT MAX(oficina_key) FROM public.dim_oficina_turismo), true);

SELECT setval(pg_get_serial_sequence('public.dim_oficina_turismo','oficina_id'), (SELECT MAX(oficina_id) FROM public.dim_oficina_turismo), true);

COMMIT;

SELECT 'dim_municipio' AS tabla, COUNT(*) AS registros FROM public.dim_municipio UNION ALL SELECT 'dim_hotel',COUNT(*) FROM public.dim_hotel UNION ALL SELECT 'dim_monumento',COUNT(*) FROM public.dim_monumento UNION ALL SELECT 'dim_oficina_turismo',COUNT(*) FROM public.dim_oficina_turismo;