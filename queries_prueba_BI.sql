-- ============================================================================
-- QUERIES DE PRUEBA Y VALIDACIÓN - MODELO BI EMPANADAS INDEXADAS
-- ============================================================================
-- Este archivo contiene queries para probar el modelo BI completo:
-- - Validación de dimensiones y hechos
-- - Pruebas de las 10 vistas analíticas
-- - Queries de ejemplo para análisis de negocio
-- ============================================================================

USE GD2C2025;
GO

PRINT '============================================================================';
PRINT 'PRUEBAS DEL MODELO BI - EMPANADAS INDEXADAS';
PRINT '============================================================================';
PRINT '';

-- ============================================================================
-- SECCIÓN 1: VALIDACIÓN DE DIMENSIONES
-- ============================================================================

PRINT '--- SECCIÓN 1: VALIDACIÓN DE DIMENSIONES ---';
PRINT '';

-- 1.1) DIM_TIEMPO - Verificar rango de fechas y distribución
PRINT '1.1) DIM_TIEMPO - Rango de fechas cargadas:';
SELECT
    MIN(Fecha) AS Fecha_Minima,
    MAX(Fecha) AS Fecha_Maxima,
    COUNT(*) AS Total_Dias
FROM empanadas_indexadas.BI_DIM_TIEMPO;
PRINT '';

-- 1.2) DIM_SEDE - Ver todas las sedes
PRINT '1.2) DIM_SEDE - Sedes disponibles:';
SELECT
    Sede_Key,
    Sede_Nombre,
    Institucion_Nombre,
    Provincia_Nombre
FROM empanadas_indexadas.BI_DIM_SEDE
ORDER BY Sede_Nombre;
PRINT '';

-- 1.3) DIM_CATEGORIA - Ver categorías
PRINT '1.3) DIM_CATEGORIA - Categorías de cursos:';
SELECT * FROM empanadas_indexadas.BI_DIM_CATEGORIA
ORDER BY Categoria_Key;
PRINT '';

-- 1.4) DIM_TURNO - Ver turnos
PRINT '1.4) DIM_TURNO - Turnos disponibles:';
SELECT * FROM empanadas_indexadas.BI_DIM_TURNO
ORDER BY Turno_Key;
PRINT '';

-- 1.5) DIM_RANGO_ETARIO_ALUMNO - Rangos etarios
PRINT '1.5) DIM_RANGO_ETARIO_ALUMNO - Rangos etarios de alumnos:';
SELECT * FROM empanadas_indexadas.BI_DIM_RANGO_ETARIO_ALUMNO
ORDER BY Rango_Etario_Alumno_Key;
PRINT '';

-- 1.6) DIM_RANGO_ETARIO_PROFESOR - Rangos etarios
PRINT '1.6) DIM_RANGO_ETARIO_PROFESOR - Rangos etarios de profesores:';
SELECT * FROM empanadas_indexadas.BI_DIM_RANGO_ETARIO_PROFESOR
ORDER BY Rango_Etario_Profesor_Key;
PRINT '';

-- 1.7) DIM_MEDIO_PAGO - Medios de pago
PRINT '1.7) DIM_MEDIO_PAGO - Medios de pago:';
SELECT * FROM empanadas_indexadas.BI_DIM_MEDIO_PAGO
ORDER BY MedioPago_Key;
PRINT '';

-- 1.8) DIM_SATISFACCION - Bloques de satisfacción
PRINT '1.8) DIM_SATISFACCION - Bloques de satisfacción:';
SELECT * FROM empanadas_indexadas.BI_DIM_SATISFACCION
ORDER BY Satisfaccion_Key;
PRINT '';

-- ============================================================================
-- SECCIÓN 2: VALIDACIÓN DE TABLAS DE HECHOS
-- ============================================================================

PRINT '--- SECCIÓN 2: VALIDACIÓN DE TABLAS DE HECHOS ---';
PRINT '';

-- 2.1) FACT_INSCRIPCION - Resumen general
PRINT '2.1) FACT_INSCRIPCION - Resumen:';
SELECT
    COUNT(*) AS Total_Registros,
    SUM(Cantidad_Inscripciones) AS Total_Inscripciones,
    SUM(Inscripciones_Aprobadas) AS Total_Aprobadas,
    SUM(Inscripciones_Rechazadas) AS Total_Rechazadas,
    SUM(Inscripciones_Pendientes) AS Total_Pendientes,
    AVG(Dias_Hasta_Respuesta) AS Dias_Promedio_Respuesta,
    AVG(Precio_Mensual) AS Precio_Promedio
FROM empanadas_indexadas.BI_FACT_INSCRIPCION;
PRINT '';

-- 2.2) FACT_EVALUACION_CURSO - Resumen general
PRINT '2.2) FACT_EVALUACION_CURSO - Resumen:';
SELECT
    COUNT(*) AS Total_Registros,
    SUM(Cantidad_Evaluaciones) AS Total_Evaluaciones,
    SUM(CASE WHEN Presente = 1 THEN 1 ELSE 0 END) AS Total_Presentes,
    SUM(CASE WHEN Aprobado = 1 THEN 1 ELSE 0 END) AS Total_Aprobados,
    AVG(CAST(Nota AS FLOAT)) AS Nota_Promedio
FROM empanadas_indexadas.BI_FACT_EVALUACION_CURSO
WHERE Nota IS NOT NULL;
PRINT '';

-- 2.3) FACT_EVALUACION_FINAL - Resumen general
PRINT '2.3) FACT_EVALUACION_FINAL - Resumen:';
SELECT
    COUNT(*) AS Total_Registros,
    SUM(CASE WHEN Presente = 1 THEN 1 ELSE 0 END) AS Total_Presentes,
    SUM(CASE WHEN Aprobado = 1 THEN 1 ELSE 0 END) AS Total_Aprobados,
    AVG(CAST(Nota AS FLOAT)) AS Nota_Promedio,
    AVG(Dias_Inicio_Curso_A_Final) AS Dias_Promedio_Finalizacion
FROM empanadas_indexadas.BI_FACT_EVALUACION_FINAL
WHERE Nota IS NOT NULL;
PRINT '';

-- 2.4) FACT_PAGO - Resumen general
PRINT '2.4) FACT_PAGO - Resumen:';
SELECT
    COUNT(*) AS Total_Registros,
    SUM(Importe_Factura) AS Facturacion_Total,
    SUM(Importe_Pagado) AS Total_Cobrado,
    SUM(CASE WHEN Factura_Pagada = 1 THEN 1 ELSE 0 END) AS Facturas_Pagadas,
    SUM(CASE WHEN Pago_En_Termino = 1 THEN 1 ELSE 0 END) AS Pagos_En_Termino,
    AVG(Dias_Fuera_Termino) AS Dias_Promedio_Retraso
FROM empanadas_indexadas.BI_FACT_PAGO;
PRINT '';

-- 2.5) FACT_ENCUESTA - Resumen general
PRINT '2.5) FACT_ENCUESTA - Resumen:';
SELECT
    COUNT(*) AS Total_Registros,
    SUM(Cantidad_Respuestas) AS Total_Respuestas,
    AVG(CAST(Nota AS FLOAT)) AS Nota_Promedio_Satisfaccion,
    SUM(CASE WHEN Satisfaccion_Key = 3 THEN 1 ELSE 0 END) AS Satisfechos,
    SUM(CASE WHEN Satisfaccion_Key = 2 THEN 1 ELSE 0 END) AS Neutrales,
    SUM(CASE WHEN Satisfaccion_Key = 1 THEN 1 ELSE 0 END) AS Insatisfechos
FROM empanadas_indexadas.BI_FACT_ENCUESTA;
PRINT '';

-- ============================================================================
-- SECCIÓN 3: PRUEBAS DE LAS 10 VISTAS ANALÍTICAS
-- ============================================================================

PRINT '--- SECCIÓN 3: PRUEBAS DE VISTAS ANALÍTICAS ---';
PRINT '';

-- 3.1) VISTA 1: Categorías y turnos más solicitados
PRINT '3.1) VISTA 1: Categorías y turnos más solicitados (Top 3 por año/sede)';
PRINT 'Ejemplo: Top categorías 2023';
SELECT TOP 10
    Anio,
    Sede_Nombre,
    Categoria_Nombre,
    Total_Inscripciones,
    Ranking_Categoria
FROM empanadas_indexadas.BI_V_Categorias_Turnos_Mas_Solicitados
WHERE Anio = 2023
ORDER BY Sede_Nombre, Ranking_Categoria;
PRINT '';

-- 3.2) VISTA 2: Tasa de rechazo de inscripciones
PRINT '3.2) VISTA 2: Tasa de rechazo de inscripciones';
PRINT 'Ejemplo: Mes con mayor rechazo por sede en 2023';
SELECT TOP 5
    Anio,
    Mes_Nombre,
    Sede_Nombre,
    Total_Inscripciones,
    Total_Rechazadas,
    CAST(Porcentaje_Rechazo AS DECIMAL(5,2)) AS Porcentaje_Rechazo
FROM empanadas_indexadas.BI_V_Tasa_Rechazo_Inscripciones
WHERE Anio = 2023
ORDER BY Porcentaje_Rechazo DESC;
PRINT '';

-- 3.3) VISTA 3A: Desempeño de cursada por sede (Interpretación A - Principal)
PRINT '3.3A) VISTA 3A: Desempeño de cursada por sede (Evaluaciones Individuales)';
PRINT 'Comparación de aprobación entre sedes (2023)';
SELECT
    Anio,
    Sede_Nombre,
    Total_Evaluaciones,
    Total_Aprobadas,
    CAST(Porcentaje_Aprobacion AS DECIMAL(5,2)) AS Porcentaje_Aprobacion
FROM empanadas_indexadas.BI_V_Desempeno_Cursada_Sede
WHERE Anio = 2023
ORDER BY Porcentaje_Aprobacion DESC;
PRINT '';

-- 3.3B) VISTA 3B: Desempeño de cursada por sede (Interpretación B - Alternativa)
PRINT '3.3B) VISTA 3B: Desempeño de cursada completa por sede (Alumnos con TODAS aprobadas)';
PRINT 'Comparación de alumnos que aprobaron TODAS las evaluaciones (2023)';
SELECT
    Anio,
    Sede_Nombre,
    Total_Alumnos_Cursada,
    Total_Cursadas_Aprobadas,
    CAST(Porcentaje_Aprobacion_Cursada_Completa AS DECIMAL(5,2)) AS Porcentaje_Cursada_Completa
FROM empanadas_indexadas.BI_V_Desempeno_Cursada_Completa_Sede
WHERE Anio = 2023
ORDER BY Porcentaje_Aprobacion_Cursada_Completa DESC;
PRINT '';
PRINT 'NOTA: Ambas vistas implementan el Indicador 3 con diferentes interpretaciones.';
PRINT 'Vista 3A (principal): % de evaluaciones aprobadas individualmente';
PRINT 'Vista 3B (alternativa): % de alumnos con TODAS las evaluaciones aprobadas';
PRINT 'Ver estrategia.md para justificación detallada de ambas implementaciones.';
PRINT '';

-- 3.4) VISTA 4: Tiempo promedio de finalización de curso
PRINT '3.4) VISTA 4: Tiempo promedio de finalización';
PRINT 'Días promedio por categoría (2023)';
SELECT
    Anio,
    Categoria_Nombre,
    CAST(Dias_Promedio_Finalizacion AS DECIMAL(10,2)) AS Dias_Promedio,
    Cantidad_Finales_Aprobados
FROM empanadas_indexadas.BI_V_Tiempo_Finalizacion_Curso
WHERE Anio = 2023
ORDER BY Dias_Promedio_Finalizacion;
PRINT '';

-- 3.5) VISTA 5: Nota promedio de finales
PRINT '3.5) VISTA 5: Nota promedio de finales';
PRINT 'Por rango etario y categoría (2023)';
SELECT TOP 10
    Anio,
    Cuatrimestre,
    Rango_Etario_Alumno,
    Categoria_Nombre,
    CAST(Nota_Promedio AS DECIMAL(5,2)) AS Nota_Promedio,
    Cantidad_Finales
FROM empanadas_indexadas.BI_V_Nota_Promedio_Finales
WHERE Anio = 2023
ORDER BY Nota_Promedio DESC;
PRINT '';

-- 3.6) VISTA 6: Tasa de ausentismo en finales
PRINT '3.6) VISTA 6: Tasa de ausentismo en finales';
PRINT 'Por cuatrimestre y sede (2023)';
SELECT
    Anio,
    Cuatrimestre,
    Sede_Nombre,
    Total_Inscripciones_Final,
    Total_Ausentes,
    CAST(Porcentaje_Ausentismo AS DECIMAL(5,2)) AS Porcentaje_Ausentismo
FROM empanadas_indexadas.BI_V_Tasa_Ausentismo_Finales
WHERE Anio = 2023
ORDER BY Cuatrimestre, Porcentaje_Ausentismo DESC;
PRINT '';

-- 3.7) VISTA 7: Desvío de pagos
PRINT '3.7) VISTA 7: Desvío de pagos (fuera de término)';
PRINT 'Por cuatrimestre (2023)';
SELECT
    Anio,
    Cuatrimestre,
    Total_Pagos,
    Pagos_Fuera_Termino,
    CAST(Porcentaje_Fuera_Termino AS DECIMAL(5,2)) AS Porcentaje_Fuera_Termino
FROM empanadas_indexadas.BI_V_Desvio_Pagos
WHERE Anio = 2023
ORDER BY Cuatrimestre;
PRINT '';

-- 3.8) VISTA 8: Tasa de morosidad
PRINT '3.8) VISTA 8: Tasa de morosidad financiera';
PRINT 'Mensual (2023)';
SELECT
    Anio,
    Mes_Nombre,
    CAST(Facturacion_Total AS DECIMAL(15,2)) AS Facturacion_Total,
    CAST(Monto_Adeudado AS DECIMAL(15,2)) AS Monto_Adeudado,
    CAST(Porcentaje_Morosidad AS DECIMAL(5,2)) AS Porcentaje_Morosidad
FROM empanadas_indexadas.BI_V_Tasa_Morosidad
WHERE Anio = 2023
ORDER BY Mes;
PRINT '';

-- 3.9) VISTA 9: Ingresos por categoría
PRINT '3.9) VISTA 9: Ingresos por categoría (Top 3)';
PRINT 'Por sede y año (2023)';
SELECT
    Anio,
    Sede_Nombre,
    Categoria_Nombre,
    CAST(Ingresos_Totales AS DECIMAL(15,2)) AS Ingresos_Totales,
    Ranking
FROM empanadas_indexadas.BI_V_Ingresos_Por_Categoria
WHERE Anio = 2023
ORDER BY Sede_Nombre, Ranking;
PRINT '';

-- 3.10) VISTA 10: Índice de satisfacción
PRINT '3.10) VISTA 10: Índice de satisfacción';
PRINT 'Por rango etario de profesor y sede (2023)';
SELECT
    Anio,
    Sede_Nombre,
    Rango_Etario_Profesor,
    Total_Respuestas,
    Cantidad_Satisfechos,
    Cantidad_Insatisfechos,
    CAST(Porcentaje_Satisfechos AS DECIMAL(5,2)) AS Pct_Satisfechos,
    CAST(Porcentaje_Insatisfechos AS DECIMAL(5,2)) AS Pct_Insatisfechos,
    CAST(Indice_Satisfaccion AS DECIMAL(5,2)) AS Indice_Satisfaccion
FROM empanadas_indexadas.BI_V_Indice_Satisfaccion
WHERE Anio = 2023
ORDER BY Indice_Satisfaccion DESC;
PRINT '';

-- ============================================================================
-- SECCIÓN 4: ANÁLISIS DE NEGOCIO AVANZADOS
-- ============================================================================

PRINT '--- SECCIÓN 4: ANÁLISIS DE NEGOCIO AVANZADOS ---';
PRINT '';

-- 4.1) Evolución temporal de inscripciones por estado
PRINT '4.1) Evolución de inscripciones por mes y estado (2023)';
SELECT
    t.Anio,
    t.Mes_Nombre,
    SUM(f.Cantidad_Inscripciones) AS Total,
    SUM(f.Inscripciones_Aprobadas) AS Aprobadas,
    SUM(f.Inscripciones_Rechazadas) AS Rechazadas,
    SUM(f.Inscripciones_Pendientes) AS Pendientes
FROM empanadas_indexadas.BI_FACT_INSCRIPCION f
INNER JOIN empanadas_indexadas.BI_DIM_TIEMPO t ON f.Tiempo_Inscripcion_Key = t.Tiempo_Key
WHERE t.Anio = 2023
GROUP BY t.Anio, t.Mes, t.Mes_Nombre
ORDER BY t.Mes;
PRINT '';

-- 4.2) Rendimiento por rango etario de alumnos
PRINT '4.2) Rendimiento en cursada por rango etario de alumnos';
SELECT
    r.Rango_Descripcion,
    COUNT(*) AS Total_Evaluaciones,
    AVG(CAST(f.Nota AS FLOAT)) AS Nota_Promedio,
    SUM(CASE WHEN f.Aprobado = 1 THEN 1 ELSE 0 END) AS Aprobados,
    CAST(SUM(CASE WHEN f.Aprobado = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Porcentaje_Aprobacion
FROM empanadas_indexadas.BI_FACT_EVALUACION_CURSO f
INNER JOIN empanadas_indexadas.BI_DIM_RANGO_ETARIO_ALUMNO r ON f.Rango_Etario_Alumno_Key = r.Rango_Etario_Alumno_Key
WHERE f.Presente = 1 AND f.Nota IS NOT NULL
GROUP BY r.Rango_Descripcion, r.Rango_Etario_Alumno_Key
ORDER BY r.Rango_Etario_Alumno_Key;
PRINT '';

-- 4.3) Análisis de medios de pago más utilizados
PRINT '4.3) Ranking de medios de pago utilizados';
SELECT
    mp.Medio_Descripcion,
    COUNT(*) AS Cantidad_Pagos,
    SUM(f.Importe_Pagado) AS Total_Cobrado,
    AVG(f.Importe_Pagado) AS Importe_Promedio
FROM empanadas_indexadas.BI_FACT_PAGO f
INNER JOIN empanadas_indexadas.BI_DIM_MEDIO_PAGO mp ON f.MedioPago_Key = mp.MedioPago_Key
WHERE f.Factura_Pagada = 1
GROUP BY mp.Medio_Descripcion
ORDER BY Cantidad_Pagos DESC;
PRINT '';

-- 4.4) Comparación sede - Performance general
PRINT '4.4) Dashboard por sede: inscripciones, aprobaciones y satisfacción (2023)';
WITH SedeSummary AS (
    SELECT
        s.Sede_Nombre,
        -- Inscripciones
        (SELECT SUM(Cantidad_Inscripciones)
         FROM empanadas_indexadas.BI_FACT_INSCRIPCION i
         INNER JOIN empanadas_indexadas.BI_DIM_TIEMPO t ON i.Tiempo_Inscripcion_Key = t.Tiempo_Key
         WHERE i.Sede_Key = s.Sede_Key AND t.Anio = 2023) AS Total_Inscripciones,
        -- Tasa aprobación cursada
        (SELECT AVG(CAST(Porcentaje_Aprobacion AS FLOAT))
         FROM empanadas_indexadas.BI_V_Desempeno_Cursada_Sede
         WHERE Sede_Nombre = s.Sede_Nombre AND Anio = 2023) AS Aprobacion_Cursada,
        -- Índice satisfacción
        (SELECT AVG(CAST(Indice_Satisfaccion AS FLOAT))
         FROM empanadas_indexadas.BI_V_Indice_Satisfaccion
         WHERE Sede_Nombre = s.Sede_Nombre AND Anio = 2023) AS Indice_Satisfaccion
    FROM empanadas_indexadas.BI_DIM_SEDE s
)
SELECT
    Sede_Nombre,
    Total_Inscripciones,
    CAST(Aprobacion_Cursada AS DECIMAL(5,2)) AS Pct_Aprobacion_Cursada,
    CAST(Indice_Satisfaccion AS DECIMAL(5,2)) AS Indice_Satisfaccion
FROM SedeSummary
WHERE Total_Inscripciones IS NOT NULL
ORDER BY Total_Inscripciones DESC;
PRINT '';

-- 4.5) Análisis de cobranzas por cuatrimestre
PRINT '4.5) Análisis de cobranzas y morosidad por cuatrimestre (2023)';
SELECT
    t.Cuatrimestre,
    COUNT(*) AS Total_Facturas,
    SUM(f.Importe_Factura) AS Facturacion_Total,
    SUM(CASE WHEN f.Factura_Pagada = 1 THEN f.Importe_Pagado ELSE 0 END) AS Total_Cobrado,
    SUM(CASE WHEN f.Factura_Pagada = 0 THEN f.Importe_Factura ELSE 0 END) AS Total_Adeudado,
    CAST(SUM(CASE WHEN f.Pago_En_Termino = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Pct_Pagos_En_Termino
FROM empanadas_indexadas.BI_FACT_PAGO f
INNER JOIN empanadas_indexadas.BI_DIM_TIEMPO t ON f.Tiempo_Emision_Key = t.Tiempo_Key
WHERE t.Anio = 2023
GROUP BY t.Cuatrimestre
ORDER BY t.Cuatrimestre;
PRINT '';

-- ============================================================================
-- SECCIÓN 5: VALIDACIONES DE INTEGRIDAD REFERENCIAL
-- ============================================================================

PRINT '--- SECCIÓN 5: VALIDACIONES DE INTEGRIDAD ---';
PRINT '';

-- 5.1) Verificar que no hay NULLs en FKs obligatorias de FACT_INSCRIPCION
PRINT '5.1) Validar FKs obligatorias en FACT_INSCRIPCION';
SELECT
    COUNT(*) AS Total_Registros,
    SUM(CASE WHEN Tiempo_Inscripcion_Key IS NULL THEN 1 ELSE 0 END) AS Nulos_Tiempo_Inscripcion,
    SUM(CASE WHEN Sede_Key IS NULL THEN 1 ELSE 0 END) AS Nulos_Sede
FROM empanadas_indexadas.BI_FACT_INSCRIPCION;
PRINT '';

-- 5.2) Verificar rangos de notas válidos en hechos
PRINT '5.2) Validar rango de notas en evaluaciones';
SELECT
    'EVALUACION_CURSO' AS Tabla,
    MIN(Nota) AS Nota_Minima,
    MAX(Nota) AS Nota_Maxima,
    COUNT(*) AS Total_Con_Nota
FROM empanadas_indexadas.BI_FACT_EVALUACION_CURSO
WHERE Nota IS NOT NULL
UNION ALL
SELECT
    'EVALUACION_FINAL' AS Tabla,
    MIN(Nota) AS Nota_Minima,
    MAX(Nota) AS Nota_Maxima,
    COUNT(*) AS Total_Con_Nota
FROM empanadas_indexadas.BI_FACT_EVALUACION_FINAL
WHERE Nota IS NOT NULL
UNION ALL
SELECT
    'ENCUESTA' AS Tabla,
    MIN(Nota) AS Nota_Minima,
    MAX(Nota) AS Nota_Maxima,
    COUNT(*) AS Total_Con_Nota
FROM empanadas_indexadas.BI_FACT_ENCUESTA
WHERE Nota IS NOT NULL;
PRINT '';

-- 5.3) Verificar coherencia de importes en pagos
PRINT '5.3) Validar coherencia de importes en FACT_PAGO';
SELECT
    COUNT(*) AS Total_Pagos,
    SUM(CASE WHEN Importe_Factura < 0 THEN 1 ELSE 0 END) AS Importes_Negativos,
    SUM(CASE WHEN Importe_Pagado > Importe_Factura THEN 1 ELSE 0 END) AS Pagos_Superiores_Factura,
    SUM(CASE WHEN Factura_Pagada = 1 AND Importe_Pagado IS NULL THEN 1 ELSE 0 END) AS Pagadas_Sin_Importe
FROM empanadas_indexadas.BI_FACT_PAGO;
PRINT '';

-- ============================================================================
-- FIN DE QUERIES DE PRUEBA
-- ============================================================================

PRINT '';
PRINT '============================================================================';
PRINT 'PRUEBAS COMPLETADAS';
PRINT '============================================================================';
GO
