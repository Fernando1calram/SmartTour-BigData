-- SmartTour: 11 vistas analiticas adaptadas al esquema real.
-- No modifica registros de las tablas. Crea o reemplaza las vistas indicadas.
-- Datos de prueba ficticios, no turistas unicos ni ocupacion real.
-- vw_ingresos_mensuales agrupa importes por fecha de RESERVA, no cobros reales.
-- La vista conjunta asigna reservas al mes de ENTRADA; no reparte noches entre meses.
-- COALESCE a cero significa sin hechos cargados para ese proceso/periodo,
-- no demuestra ausencia de actividad real.
BEGIN;

-- Vista 1
CREATE OR REPLACE VIEW public.vw_reservas_municipio AS
SELECT m.municipio_key, m.nombre AS municipio, m.provincia,
       COUNT(*) AS total_reservas,
       SUM(r.turistas) AS turistas_en_reservas,
       SUM(r.importe) AS importe_reservas
FROM public.reservas r
JOIN public.dim_municipio m ON m.municipio_key = r.municipio_key
GROUP BY m.municipio_key, m.nombre, m.provincia;

-- Vista 2
CREATE OR REPLACE VIEW public.vw_turistas_provincia AS
SELECT m.provincia, SUM(r.turistas) AS turistas_en_reservas
FROM public.reservas r
JOIN public.dim_municipio m ON m.municipio_key = r.municipio_key
GROUP BY m.provincia;

-- Vista 3
CREATE OR REPLACE VIEW public.vw_ingresos_mensuales AS
SELECT f.anio, f.mes, f.nombre_mes,
       COUNT(*) AS total_reservas, SUM(r.importe) AS importe_reservado
FROM public.reservas r
JOIN public.fechas f ON f.fecha_key = r.fecha_reserva_key
GROUP BY f.anio, f.mes, f.nombre_mes;

-- Vista 4
CREATE OR REPLACE VIEW public.vw_estancia_hoteles AS
SELECT h.hotel_key, h.nombre AS hotel, h.categoria,
       COUNT(*) AS total_reservas,
       SUM(r.turistas) AS turistas_en_reservas,
       SUM(r.noches) AS noches_acumuladas_reservas,
       SUM(r.turistas::BIGINT * r.noches) AS pernoctaciones_persona,
       ROUND(AVG(r.noches)::NUMERIC, 2) AS media_noches_reserva,
       SUM(r.importe) AS importe_reservas
FROM public.reservas r
JOIN public.dim_hotel h ON h.hotel_key = r.hotel_key
GROUP BY h.hotel_key, h.nombre, h.categoria;

-- Vista 5
CREATE OR REPLACE VIEW public.vw_visitas_oficinas AS
SELECT o.oficina_key, o.nombre AS oficina, o.ambito,
       SUM(v.num_visitas) AS total_visitas,
       SUM(v.num_grupos) AS total_grupos,
       SUM(v.num_consultas) AS total_consultas,
       SUM(v.num_visitas_individuales) AS visitas_individuales
FROM public.visitadadas v
JOIN public.dim_oficina_turismo o ON o.oficina_key = v.oficina_key
GROUP BY o.oficina_key, o.nombre, o.ambito;

-- Vista 6
CREATE OR REPLACE VIEW public.vw_visitas_oficinas_municipio AS
SELECT m.municipio_key, m.nombre AS municipio, m.provincia,
       SUM(v.num_visitas) AS total_visitas,
       SUM(v.num_consultas) AS total_consultas
FROM public.visitadadas v
JOIN public.dim_municipio m ON m.municipio_key = v.municipio_key
GROUP BY m.municipio_key, m.nombre, m.provincia;

-- Vista 7
CREATE OR REPLACE VIEW public.vw_visitas_oficinas_mensuales AS
SELECT f.anio, f.mes, f.nombre_mes,
       SUM(v.num_visitas) AS total_visitas,
       SUM(v.num_consultas) AS total_consultas
FROM public.visitadadas v
JOIN public.fechas f ON f.fecha_key = v.fecha_key
GROUP BY f.anio, f.mes, f.nombre_mes;

-- Vista 8
CREATE OR REPLACE VIEW public.vw_monumentos_mas_visitados AS
SELECT m.monumento_key, m.nombre AS monumento, m.tipo,
       SUM(v.num_visitas) AS total_visitas
FROM public.visitas v
JOIN public.dim_monumento m ON m.monumento_key = v.monumento_key
GROUP BY m.monumento_key, m.nombre, m.tipo;

-- Vista 9
CREATE OR REPLACE VIEW public.vw_ingresos_monumentos AS
SELECT m.monumento_key, m.nombre AS monumento,
       SUM(v.num_entradas) AS entradas_vendidas,
       SUM(v.num_visitas_gratuitas) AS visitas_gratuitas,
       SUM(v.importe_entradas) AS ingresos_entradas
FROM public.visitas v
JOIN public.dim_monumento m ON m.monumento_key = v.monumento_key
GROUP BY m.monumento_key, m.nombre;

-- Vista 10
CREATE OR REPLACE VIEW public.vw_visitas_monumentos_mensuales AS
SELECT m.monumento_key, m.nombre AS monumento,
       f.anio, f.mes, f.nombre_mes,
       SUM(v.num_visitas) AS visitas,
       SUM(v.importe_entradas) AS ingresos_entradas
FROM public.visitas v
JOIN public.dim_monumento m ON m.monumento_key = v.monumento_key
JOIN public.fechas f ON f.fecha_key = v.fecha_key
GROUP BY m.monumento_key, m.nombre, f.anio, f.mes, f.nombre_mes;

-- Vista 11
CREATE OR REPLACE VIEW public.vw_actividad_turistica_municipio AS
WITH reservas_mes AS (
    SELECT r.municipio_key, f.anio, f.mes,
           COUNT(*) AS total_reservas,
           SUM(r.turistas) AS turistas_en_reservas,
           SUM(r.importe) AS importe_reservas
    FROM public.reservas r
    JOIN public.fechas f ON f.fecha_key = r.fecha_entrada_key
    GROUP BY r.municipio_key, f.anio, f.mes
), oficinas_mes AS (
    SELECT v.municipio_key, f.anio, f.mes,
           SUM(v.num_visitas) AS visitas_oficinas
    FROM public.visitadadas v
    JOIN public.fechas f ON f.fecha_key = v.fecha_key
    GROUP BY v.municipio_key, f.anio, f.mes
), monumentos_mes AS (
    SELECT v.municipio_key, f.anio, f.mes,
           SUM(v.num_visitas) AS visitas_monumentos,
           SUM(v.importe_entradas) AS ingresos_entradas
    FROM public.visitas v
    JOIN public.fechas f ON f.fecha_key = v.fecha_key
    GROUP BY v.municipio_key, f.anio, f.mes
), periodos AS (
    SELECT municipio_key, anio, mes FROM reservas_mes
    UNION
    SELECT municipio_key, anio, mes FROM oficinas_mes
    UNION
    SELECT municipio_key, anio, mes FROM monumentos_mes
)
SELECT m.municipio_key, m.nombre AS municipio, m.provincia,
       p.anio, p.mes,
       COALESCE(r.total_reservas, 0) AS total_reservas,
       COALESCE(r.turistas_en_reservas, 0) AS turistas_en_reservas,
       COALESCE(r.importe_reservas, 0) AS importe_reservas,
       COALESCE(o.visitas_oficinas, 0) AS visitas_oficinas,
       COALESCE(mo.visitas_monumentos, 0) AS visitas_monumentos,
       COALESCE(mo.ingresos_entradas, 0) AS ingresos_entradas
FROM periodos p
JOIN public.dim_municipio m ON m.municipio_key = p.municipio_key
LEFT JOIN reservas_mes r
    ON r.municipio_key = p.municipio_key AND r.anio = p.anio AND r.mes = p.mes
LEFT JOIN oficinas_mes o
    ON o.municipio_key = p.municipio_key AND o.anio = p.anio AND o.mes = p.mes
LEFT JOIN monumentos_mes mo
    ON mo.municipio_key = p.municipio_key AND mo.anio = p.anio AND mo.mes = p.mes;

COMMIT;
