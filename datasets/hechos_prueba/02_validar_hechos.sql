-- Recuentos esperados: 1000 en cada tabla.
SELECT 'reservas' AS tabla, COUNT(*) AS registros FROM public.reservas
UNION ALL SELECT 'visitadadas', COUNT(*) FROM public.visitadadas
UNION ALL SELECT 'visitas', COUNT(*) FROM public.visitas;

-- Debe devolver cero reservas incoherentes.
SELECT COUNT(*) AS reservas_incoherentes
FROM public.reservas r
JOIN public.fechas fr ON fr.fecha_key = r.fecha_reserva_key
JOIN public.fechas fe ON fe.fecha_key = r.fecha_entrada_key
JOIN public.fechas fs ON fs.fecha_key = r.fecha_salida_key
WHERE fr.fecha > fe.fecha OR fs.fecha <= fe.fecha
   OR r.noches <> fs.fecha - fe.fecha;

-- Debe devolver cero filas incoherentes, segun la regla de estos datos simulados.
SELECT COUNT(*) AS monumentos_incoherentes
FROM public.visitas
WHERE num_visitas <> num_entradas + num_visitas_gratuitas;

-- Comprobaciones de oficinas: grupos son grupos, no personas.
SELECT COUNT(*) AS oficinas_incoherentes
FROM public.visitadadas
WHERE num_visitas_individuales > num_visitas
   OR num_grupos * 2 > num_visitas - num_visitas_individuales;

-- Estas dos consultas deben devolver cero filas.
SELECT fecha_key, oficina_key, COUNT(*)
FROM public.visitadadas
GROUP BY fecha_key, oficina_key HAVING COUNT(*) > 1;

SELECT fecha_key, monumento_key, COUNT(*)
FROM public.visitas
GROUP BY fecha_key, monumento_key HAVING COUNT(*) > 1;

-- Totales de control para comparar con el archivo LEEME.
SELECT SUM(turistas) AS turistas, SUM(noches) AS noches,
       SUM(importe) AS importe FROM public.reservas;
SELECT SUM(num_visitas) AS visitas, SUM(num_grupos) AS grupos,
       SUM(num_consultas) AS consultas FROM public.visitadadas;
SELECT SUM(num_visitas) AS visitas, SUM(num_entradas) AS entradas,
       SUM(importe_entradas) AS importe FROM public.visitas;