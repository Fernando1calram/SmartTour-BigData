-- Ejecutar SELECT por SELECT para revisar cada resultado.

SELECT * FROM public.vw_reservas_municipio
ORDER BY total_reservas DESC
LIMIT 20;

SELECT * FROM public.vw_turistas_provincia
ORDER BY turistas_en_reservas DESC
LIMIT 20;

SELECT * FROM public.vw_ingresos_mensuales
ORDER BY anio, mes
LIMIT 20;

SELECT * FROM public.vw_estancia_hoteles
ORDER BY turistas_en_reservas DESC
LIMIT 20;

SELECT * FROM public.vw_visitas_oficinas
ORDER BY total_visitas DESC
LIMIT 20;

SELECT * FROM public.vw_visitas_oficinas_municipio
ORDER BY total_visitas DESC
LIMIT 20;

SELECT * FROM public.vw_visitas_oficinas_mensuales
ORDER BY anio, mes
LIMIT 20;

SELECT * FROM public.vw_monumentos_mas_visitados
ORDER BY total_visitas DESC
LIMIT 20;

SELECT * FROM public.vw_ingresos_monumentos
ORDER BY ingresos_entradas DESC
LIMIT 20;

SELECT * FROM public.vw_visitas_monumentos_mensuales
ORDER BY anio, mes, visitas DESC
LIMIT 20;

SELECT * FROM public.vw_actividad_turistica_municipio
ORDER BY anio, mes, municipio
LIMIT 20;

-- Debe listar 11 vistas con estos nombres.
SELECT table_name
FROM information_schema.views
WHERE table_schema = 'public'
AND table_name IN (
    'vw_reservas_municipio',
    'vw_turistas_provincia',
    'vw_ingresos_mensuales',
    'vw_estancia_hoteles',
    'vw_visitas_oficinas',
    'vw_visitas_oficinas_municipio',
    'vw_visitas_oficinas_mensuales',
    'vw_monumentos_mas_visitados',
    'vw_ingresos_monumentos',
    'vw_visitas_monumentos_mensuales',
    'vw_actividad_turistica_municipio'
)
ORDER BY table_name;

-- Control conjunto: deben coincidir con las tablas base.
SELECT
    SUM(total_reservas) AS reservas_esperadas_1000,
    SUM(turistas_en_reservas) AS turistas_esperados_2981,
    SUM(importe_reservas) AS importe_reservas_esperado_947454_82,
    SUM(visitas_oficinas) AS visitas_oficinas_esperadas_75628,
    SUM(visitas_monumentos) AS visitas_monumentos_esperadas_286485,
    SUM(ingresos_entradas) AS entradas_importe_esperado_1684332
FROM public.vw_actividad_turistica_municipio;
