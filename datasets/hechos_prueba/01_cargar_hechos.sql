-- Colocar los tres CSV en datasets/hechos_prueba dentro del proyecto.
-- PostgreSQL debe verlos en /smarttour/datasets/hechos_prueba/.
-- Carga inicial: no borra ni reemplaza datos.
BEGIN;
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM public.reservas)
       OR EXISTS (SELECT 1 FROM public.visitadadas)
       OR EXISTS (SELECT 1 FROM public.visitas) THEN
        RAISE EXCEPTION 'Las tablas de hechos no estan vacias. Revisar antes de repetir la carga.';
    END IF;
END;
$$;

COPY public.reservas (fecha_reserva_key, fecha_entrada_key, fecha_salida_key, hotel_key, municipio_key, turistas, noches, importe, num_reservas)
FROM '/smarttour/datasets/hechos_prueba/reservas_prueba.csv'
WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', ENCODING 'UTF8');

COPY public.visitadadas (fecha_key, oficina_key, municipio_key, num_visitas, num_grupos, num_consultas, num_visitas_individuales)
FROM '/smarttour/datasets/hechos_prueba/visitadadas_prueba.csv'
WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', ENCODING 'UTF8');

COPY public.visitas (fecha_key, monumento_key, municipio_key, num_visitas, num_entradas, importe_entradas, num_visitas_gratuitas)
FROM '/smarttour/datasets/hechos_prueba/visitas_prueba.csv'
WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', ENCODING 'UTF8');

COMMIT;
