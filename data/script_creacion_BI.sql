-- ============================================================================
-- MODELO DE BI - EMPANADAS INDEXADAS
-- ============================================================================

USE GD2C2025;
GO

-- ============================================================================
-- 1) DROPS DE OBJETOS BI (en orden inverso de dependencias)
-- ============================================================================

-- Drops de vistas
IF OBJECT_ID('empanadas_indexadas.BI_V_Categorias_Turnos_Mas_Solicitados', 'V') IS NOT NULL
    DROP VIEW empanadas_indexadas.BI_V_Categorias_Turnos_Mas_Solicitados;
IF OBJECT_ID('empanadas_indexadas.BI_V_Tasa_Rechazo_Inscripciones', 'V') IS NOT NULL
    DROP VIEW empanadas_indexadas.BI_V_Tasa_Rechazo_Inscripciones;
IF OBJECT_ID('empanadas_indexadas.BI_V_Desempeno_Cursada_Sede', 'V') IS NOT NULL
    DROP VIEW empanadas_indexadas.BI_V_Desempeno_Cursada_Sede;
IF OBJECT_ID('empanadas_indexadas.BI_V_Tiempo_Finalizacion_Curso', 'V') IS NOT NULL
    DROP VIEW empanadas_indexadas.BI_V_Tiempo_Finalizacion_Curso;
IF OBJECT_ID('empanadas_indexadas.BI_V_Nota_Promedio_Finales', 'V') IS NOT NULL
    DROP VIEW empanadas_indexadas.BI_V_Nota_Promedio_Finales;
IF OBJECT_ID('empanadas_indexadas.BI_V_Tasa_Ausentismo_Finales', 'V') IS NOT NULL
    DROP VIEW empanadas_indexadas.BI_V_Tasa_Ausentismo_Finales;
IF OBJECT_ID('empanadas_indexadas.BI_V_Desvio_Pagos', 'V') IS NOT NULL
    DROP VIEW empanadas_indexadas.BI_V_Desvio_Pagos;
IF OBJECT_ID('empanadas_indexadas.BI_V_Tasa_Morosidad', 'V') IS NOT NULL
    DROP VIEW empanadas_indexadas.BI_V_Tasa_Morosidad;
IF OBJECT_ID('empanadas_indexadas.BI_V_Ingresos_Por_Categoria', 'V') IS NOT NULL
    DROP VIEW empanadas_indexadas.BI_V_Ingresos_Por_Categoria;
IF OBJECT_ID('empanadas_indexadas.BI_V_Indice_Satisfaccion', 'V') IS NOT NULL
    DROP VIEW empanadas_indexadas.BI_V_Indice_Satisfaccion;

-- Drops de tablas de hechos
IF OBJECT_ID('empanadas_indexadas.BI_FACT_ENCUESTA', 'U') IS NOT NULL
    DROP TABLE empanadas_indexadas.BI_FACT_ENCUESTA;
IF OBJECT_ID('empanadas_indexadas.BI_FACT_PAGO', 'U') IS NOT NULL
    DROP TABLE empanadas_indexadas.BI_FACT_PAGO;
IF OBJECT_ID('empanadas_indexadas.BI_FACT_EVALUACION_FINAL', 'U') IS NOT NULL
    DROP TABLE empanadas_indexadas.BI_FACT_EVALUACION_FINAL;
IF OBJECT_ID('empanadas_indexadas.BI_FACT_EVALUACION_CURSO', 'U') IS NOT NULL
    DROP TABLE empanadas_indexadas.BI_FACT_EVALUACION_CURSO;
IF OBJECT_ID('empanadas_indexadas.BI_FACT_INSCRIPCION', 'U') IS NOT NULL
    DROP TABLE empanadas_indexadas.BI_FACT_INSCRIPCION;

-- Drops de dimensiones
IF OBJECT_ID('empanadas_indexadas.BI_DIM_SATISFACCION', 'U') IS NOT NULL
    DROP TABLE empanadas_indexadas.BI_DIM_SATISFACCION;
IF OBJECT_ID('empanadas_indexadas.BI_DIM_MEDIO_PAGO', 'U') IS NOT NULL
    DROP TABLE empanadas_indexadas.BI_DIM_MEDIO_PAGO;
IF OBJECT_ID('empanadas_indexadas.BI_DIM_CATEGORIA', 'U') IS NOT NULL
    DROP TABLE empanadas_indexadas.BI_DIM_CATEGORIA;
IF OBJECT_ID('empanadas_indexadas.BI_DIM_TURNO', 'U') IS NOT NULL
    DROP TABLE empanadas_indexadas.BI_DIM_TURNO;
IF OBJECT_ID('empanadas_indexadas.BI_DIM_RANGO_ETARIO_PROFESOR', 'U') IS NOT NULL
    DROP TABLE empanadas_indexadas.BI_DIM_RANGO_ETARIO_PROFESOR;
IF OBJECT_ID('empanadas_indexadas.BI_DIM_RANGO_ETARIO_ALUMNO', 'U') IS NOT NULL
    DROP TABLE empanadas_indexadas.BI_DIM_RANGO_ETARIO_ALUMNO;
IF OBJECT_ID('empanadas_indexadas.BI_DIM_SEDE', 'U') IS NOT NULL
    DROP TABLE empanadas_indexadas.BI_DIM_SEDE;
IF OBJECT_ID('empanadas_indexadas.BI_DIM_TIEMPO', 'U') IS NOT NULL
    DROP TABLE empanadas_indexadas.BI_DIM_TIEMPO;

-- ============================================================================
-- 2) CREACIÓN DE DIMENSIONES
-- ============================================================================

-- DIMENSIÓN TIEMPO
CREATE TABLE empanadas_indexadas.BI_DIM_TIEMPO (
    Tiempo_Key INT PRIMARY KEY IDENTITY(1,1),
    Fecha DATE NOT NULL UNIQUE,
    Anio INT NOT NULL,
    Cuatrimestre TINYINT NOT NULL,
    Mes TINYINT NOT NULL,
    Mes_Nombre NVARCHAR(20) NOT NULL,
    INDEX IX_BI_DIM_TIEMPO_Anio_Cuatrimestre (Anio, Cuatrimestre),
    INDEX IX_BI_DIM_TIEMPO_Anio_Mes (Anio, Mes)
);

-- DIMENSIÓN SEDE
CREATE TABLE empanadas_indexadas.BI_DIM_SEDE (
    Sede_Key INT PRIMARY KEY IDENTITY(1,1),
    ID_Sede BIGINT NOT NULL,
    Sede_Nombre NVARCHAR(255),
    Institucion_Nombre NVARCHAR(255),
    Localidad_Nombre NVARCHAR(255),
    Provincia_Nombre NVARCHAR(255),
    INDEX IX_BI_DIM_SEDE_ID (ID_Sede)
);

-- DIMENSIÓN RANGO ETARIO ALUMNO
CREATE TABLE empanadas_indexadas.BI_DIM_RANGO_ETARIO_ALUMNO (
    Rango_Etario_Alumno_Key TINYINT PRIMARY KEY,
    Rango_Descripcion NVARCHAR(50) NOT NULL,
    Edad_Minima INT NOT NULL,
    Edad_Maxima INT NULL
);

-- Poblar rangos etarios alumno
INSERT INTO empanadas_indexadas.BI_DIM_RANGO_ETARIO_ALUMNO VALUES
(1, '<25', 0, 24),
(2, '25-35', 25, 35),
(3, '35-50', 36, 50),
(4, '>50', 51, NULL);

-- DIMENSIÓN RANGO ETARIO PROFESOR
CREATE TABLE empanadas_indexadas.BI_DIM_RANGO_ETARIO_PROFESOR (
    Rango_Etario_Profesor_Key TINYINT PRIMARY KEY,
    Rango_Descripcion NVARCHAR(50) NOT NULL,
    Edad_Minima INT NOT NULL,
    Edad_Maxima INT NULL
);

-- Poblar rangos etarios profesor
INSERT INTO empanadas_indexadas.BI_DIM_RANGO_ETARIO_PROFESOR VALUES
(1, '25-35', 25, 35),
(2, '35-50', 36, 50),
(3, '>50', 51, NULL);

-- DIMENSIÓN TURNO
CREATE TABLE empanadas_indexadas.BI_DIM_TURNO (
    Turno_Key TINYINT PRIMARY KEY IDENTITY(1,1),
    ID_Turno TINYINT NOT NULL,
    Turno_Nombre NVARCHAR(50) NOT NULL,
    INDEX IX_BI_DIM_TURNO_ID (ID_Turno)
);

-- DIMENSIÓN CATEGORÍA
CREATE TABLE empanadas_indexadas.BI_DIM_CATEGORIA (
    Categoria_Key TINYINT PRIMARY KEY IDENTITY(1,1),
    ID_Categoria TINYINT NOT NULL,
    Categoria_Nombre NVARCHAR(100) NOT NULL,
    INDEX IX_BI_DIM_CATEGORIA_ID (ID_Categoria)
);

-- DIMENSIÓN MEDIO DE PAGO
CREATE TABLE empanadas_indexadas.BI_DIM_MEDIO_PAGO (
    MedioPago_Key INT PRIMARY KEY IDENTITY(1,1),
    ID_MedioPago BIGINT NOT NULL,
    Medio_Descripcion NVARCHAR(100),
    INDEX IX_BI_DIM_MEDIO_PAGO_ID (ID_MedioPago)
);

-- DIMENSIÓN SATISFACCIÓN
CREATE TABLE empanadas_indexadas.BI_DIM_SATISFACCION (
    Satisfaccion_Key TINYINT PRIMARY KEY,
    Bloque_Descripcion NVARCHAR(50) NOT NULL,
    Nota_Minima TINYINT NOT NULL,
    Nota_Maxima TINYINT NOT NULL
);

-- Poblar bloques de satisfacción
INSERT INTO empanadas_indexadas.BI_DIM_SATISFACCION VALUES
(1, 'Insatisfechos', 1, 4),
(2, 'Neutrales', 5, 6),
(3, 'Satisfechos', 7, 10);

-- ============================================================================
-- 3) CREACIÓN DE TABLAS DE HECHOS
-- ============================================================================

-- FACT: INSCRIPCIONES
-- Agrupado por Tiempo (fecha inscripción) + Sede + Categoría + Turno + Rango Etario
CREATE TABLE empanadas_indexadas.BI_FACT_INSCRIPCION (
    Fact_Inscripcion_Key BIGINT PRIMARY KEY IDENTITY(1,1),
    Tiempo_Key INT NOT NULL,
    Sede_Key INT NOT NULL,
    Categoria_Key TINYINT NULL,
    Turno_Key TINYINT NULL,
    Rango_Etario_Alumno_Key TINYINT NULL,
    -- Métricas pre-calculadas
    Cantidad_Inscripciones INT NOT NULL DEFAULT 0,
    Inscripciones_Aprobadas INT NOT NULL DEFAULT 0,
    Inscripciones_Rechazadas INT NOT NULL DEFAULT 0,
    Inscripciones_Pendientes INT NOT NULL DEFAULT 0,
    Dias_Promedio_Hasta_Respuesta DECIMAL(10,2) NULL,
    Importe_Total_Esperado DECIMAL(18,2) NULL,
    -- FKs
    FOREIGN KEY (Tiempo_Key) REFERENCES empanadas_indexadas.BI_DIM_TIEMPO(Tiempo_Key),
    FOREIGN KEY (Sede_Key) REFERENCES empanadas_indexadas.BI_DIM_SEDE(Sede_Key),
    FOREIGN KEY (Categoria_Key) REFERENCES empanadas_indexadas.BI_DIM_CATEGORIA(Categoria_Key),
    FOREIGN KEY (Turno_Key) REFERENCES empanadas_indexadas.BI_DIM_TURNO(Turno_Key),
    FOREIGN KEY (Rango_Etario_Alumno_Key) REFERENCES empanadas_indexadas.BI_DIM_RANGO_ETARIO_ALUMNO(Rango_Etario_Alumno_Key)
);

-- FACT: EVALUACIONES DE CURSO
-- Agrupado por Tiempo + Sede + Categoría + Rango Etario
CREATE TABLE empanadas_indexadas.BI_FACT_EVALUACION_CURSO (
    Fact_Evaluacion_Key BIGINT PRIMARY KEY IDENTITY(1,1),
    Tiempo_Key INT NOT NULL,
    Sede_Key INT NOT NULL,
    Categoria_Key TINYINT NULL,
    Rango_Etario_Alumno_Key TINYINT NULL,
    -- Métricas pre-calculadas
    Cantidad_Evaluaciones INT NOT NULL DEFAULT 0,
    Cantidad_Presentes INT NOT NULL DEFAULT 0,
    Cantidad_Ausentes INT NOT NULL DEFAULT 0,
    Cantidad_Aprobados INT NOT NULL DEFAULT 0,
    Suma_Notas DECIMAL(18,2) NULL,
    Nota_Promedio DECIMAL(5,2) NULL,
    -- FKs
    FOREIGN KEY (Tiempo_Key) REFERENCES empanadas_indexadas.BI_DIM_TIEMPO(Tiempo_Key),
    FOREIGN KEY (Sede_Key) REFERENCES empanadas_indexadas.BI_DIM_SEDE(Sede_Key),
    FOREIGN KEY (Categoria_Key) REFERENCES empanadas_indexadas.BI_DIM_CATEGORIA(Categoria_Key),
    FOREIGN KEY (Rango_Etario_Alumno_Key) REFERENCES empanadas_indexadas.BI_DIM_RANGO_ETARIO_ALUMNO(Rango_Etario_Alumno_Key)
);

-- FACT: EVALUACIONES FINALES
-- Agrupado por Tiempo (fecha del final) + Sede + Categoría + Rango Etario
CREATE TABLE empanadas_indexadas.BI_FACT_EVALUACION_FINAL (
    Fact_Final_Key BIGINT PRIMARY KEY IDENTITY(1,1),
    Tiempo_Key INT NOT NULL,
    Sede_Key INT NOT NULL,
    Categoria_Key TINYINT NULL,
    Rango_Etario_Alumno_Key TINYINT NULL,
    -- Métricas pre-calculadas
    Cantidad_Inscripciones_Final INT NOT NULL DEFAULT 0,
    Cantidad_Presentes INT NOT NULL DEFAULT 0,
    Cantidad_Ausentes INT NOT NULL DEFAULT 0,
    Cantidad_Aprobados INT NOT NULL DEFAULT 0,
    Suma_Notas DECIMAL(18,2) NULL,
    Nota_Promedio DECIMAL(5,2) NULL,
    Dias_Promedio_Finalizacion DECIMAL(10,2) NULL,
    -- FKs
    FOREIGN KEY (Tiempo_Key) REFERENCES empanadas_indexadas.BI_DIM_TIEMPO(Tiempo_Key),
    FOREIGN KEY (Sede_Key) REFERENCES empanadas_indexadas.BI_DIM_SEDE(Sede_Key),
    FOREIGN KEY (Categoria_Key) REFERENCES empanadas_indexadas.BI_DIM_CATEGORIA(Categoria_Key),
    FOREIGN KEY (Rango_Etario_Alumno_Key) REFERENCES empanadas_indexadas.BI_DIM_RANGO_ETARIO_ALUMNO(Rango_Etario_Alumno_Key)
);

-- FACT: PAGOS
-- Agrupado por Tiempo (fecha emisión factura) + Sede + Categoría + Medio Pago
CREATE TABLE empanadas_indexadas.BI_FACT_PAGO (
    Fact_Pago_Key BIGINT PRIMARY KEY IDENTITY(1,1),
    Tiempo_Key INT NOT NULL,
    Sede_Key INT NOT NULL,
    Categoria_Key TINYINT NULL,
    MedioPago_Key INT NULL,
    -- Métricas pre-calculadas
    Cantidad_Facturas INT NOT NULL DEFAULT 0,
    Importe_Total_Facturado DECIMAL(18,2) NOT NULL DEFAULT 0,
    Importe_Total_Pagado DECIMAL(18,2) NULL DEFAULT 0,
    Cantidad_Facturas_Pagadas INT NOT NULL DEFAULT 0,
    Cantidad_Pagos_En_Termino INT NOT NULL DEFAULT 0,
    Cantidad_Pagos_Fuera_Termino INT NOT NULL DEFAULT 0,
    Importe_Adeudado DECIMAL(18,2) NULL DEFAULT 0,
    -- FKs
    FOREIGN KEY (Tiempo_Key) REFERENCES empanadas_indexadas.BI_DIM_TIEMPO(Tiempo_Key),
    FOREIGN KEY (Sede_Key) REFERENCES empanadas_indexadas.BI_DIM_SEDE(Sede_Key),
    FOREIGN KEY (Categoria_Key) REFERENCES empanadas_indexadas.BI_DIM_CATEGORIA(Categoria_Key),
    FOREIGN KEY (MedioPago_Key) REFERENCES empanadas_indexadas.BI_DIM_MEDIO_PAGO(MedioPago_Key)
);

-- FACT: ENCUESTAS
-- Agrupado por Tiempo + Sede + Categoría + Rango Etario Profesor + Satisfacción
CREATE TABLE empanadas_indexadas.BI_FACT_ENCUESTA (
    Fact_Encuesta_Key BIGINT PRIMARY KEY IDENTITY(1,1),
    Tiempo_Key INT NOT NULL,
    Sede_Key INT NOT NULL,
    Categoria_Key TINYINT NULL,
    Rango_Etario_Profesor_Key TINYINT NULL,
    Satisfaccion_Key TINYINT NULL,
    -- Métricas pre-calculadas
    Cantidad_Respuestas INT NOT NULL DEFAULT 0,
    Suma_Notas DECIMAL(18,2) NULL,
    Nota_Promedio DECIMAL(5,2) NULL,
    -- FKs
    FOREIGN KEY (Tiempo_Key) REFERENCES empanadas_indexadas.BI_DIM_TIEMPO(Tiempo_Key),
    FOREIGN KEY (Sede_Key) REFERENCES empanadas_indexadas.BI_DIM_SEDE(Sede_Key),
    FOREIGN KEY (Categoria_Key) REFERENCES empanadas_indexadas.BI_DIM_CATEGORIA(Categoria_Key),
    FOREIGN KEY (Rango_Etario_Profesor_Key) REFERENCES empanadas_indexadas.BI_DIM_RANGO_ETARIO_PROFESOR(Rango_Etario_Profesor_Key),
    FOREIGN KEY (Satisfaccion_Key) REFERENCES empanadas_indexadas.BI_DIM_SATISFACCION(Satisfaccion_Key)
);

-- ============================================================================
-- 4) MIGRACIÓN DE DATOS - DIMENSIONES
-- ============================================================================

PRINT 'Iniciando migración del modelo BI...';
PRINT '';

-- 4.1) Poblar DIM_TIEMPO (2019-2026)
PRINT 'Poblando BI_DIM_TIEMPO...';
WITH Fechas AS (
    SELECT CAST('2019-01-01' AS DATE) AS Fecha
    UNION ALL
    SELECT DATEADD(DAY, 1, Fecha)
    FROM Fechas
    WHERE Fecha < '2026-12-31'
)
INSERT INTO empanadas_indexadas.BI_DIM_TIEMPO (Fecha, Anio, Cuatrimestre, Mes, Mes_Nombre)
SELECT
    Fecha,
    YEAR(Fecha) AS Anio,
    CASE WHEN MONTH(Fecha) <= 6 THEN 1 ELSE 2 END AS Cuatrimestre,
    MONTH(Fecha) AS Mes,
    DATENAME(MONTH, Fecha) AS Mes_Nombre
FROM Fechas
OPTION (MAXRECURSION 0);  -- 0 = sin límite

DECLARE @count_tiempo INT = @@ROWCOUNT;
PRINT 'BI_DIM_TIEMPO: ' + CAST(@count_tiempo AS VARCHAR(10)) + ' registros';

-- 4.2) Poblar DIM_SEDE
PRINT 'Poblando BI_DIM_SEDE...';
INSERT INTO empanadas_indexadas.BI_DIM_SEDE (ID_Sede, Sede_Nombre, Institucion_Nombre, Localidad_Nombre, Provincia_Nombre)
SELECT DISTINCT
    s.ID_Sede,
    s.Nombre AS Sede_Nombre,
    i.Nombre AS Institucion_Nombre,
    l.Nombre AS Localidad_Nombre,
    p.Nombre AS Provincia_Nombre
FROM empanadas_indexadas.SEDE s
LEFT JOIN empanadas_indexadas.INSTITUCION i ON s.ID_Institucion = i.ID_Institucion
LEFT JOIN empanadas_indexadas.LOCALIDAD l ON s.ID_Localidad = l.ID_Localidad
LEFT JOIN empanadas_indexadas.PROVINCIA p ON l.ID_Provincia = p.ID_Provincia;

DECLARE @count_sede INT = @@ROWCOUNT;
PRINT 'BI_DIM_SEDE: ' + CAST(@count_sede AS VARCHAR(10)) + ' registros';

-- 4.3) Poblar DIM_TURNO
PRINT 'Poblando BI_DIM_TURNO...';
INSERT INTO empanadas_indexadas.BI_DIM_TURNO (ID_Turno, Turno_Nombre)
SELECT ID_Turno, Nombre
FROM empanadas_indexadas.TURNO;

DECLARE @count_turno INT = @@ROWCOUNT;
PRINT 'BI_DIM_TURNO: ' + CAST(@count_turno AS VARCHAR(10)) + ' registros';

-- 4.4) Poblar DIM_CATEGORIA
PRINT 'Poblando BI_DIM_CATEGORIA...';
INSERT INTO empanadas_indexadas.BI_DIM_CATEGORIA (ID_Categoria, Categoria_Nombre)
SELECT ID_Categoria, Nombre
FROM empanadas_indexadas.CATEGORIA;

DECLARE @count_categoria INT = @@ROWCOUNT;
PRINT 'BI_DIM_CATEGORIA: ' + CAST(@count_categoria AS VARCHAR(10)) + ' registros';

-- 4.5) Poblar DIM_MEDIO_PAGO
PRINT 'Poblando BI_DIM_MEDIO_PAGO...';
INSERT INTO empanadas_indexadas.BI_DIM_MEDIO_PAGO (ID_MedioPago, Medio_Descripcion)
SELECT ID_MedioPago, Medio
FROM empanadas_indexadas.MEDIO_PAGO;

DECLARE @count_mediopago INT = @@ROWCOUNT;
PRINT 'BI_DIM_MEDIO_PAGO: ' + CAST(@count_mediopago AS VARCHAR(10)) + ' registros';
PRINT '';

-- ============================================================================
-- 5) MIGRACIÓN DE DATOS - TABLAS DE HECHOS
-- ============================================================================

-- 5.1) FACT_INSCRIPCION
-- 5.1) FACT_INSCRIPCION Agregado por (Tiempo + Sede + Categoría + Turno + Rango Etario)
PRINT 'Poblando BI_FACT_INSCRIPCION...';
INSERT INTO empanadas_indexadas.BI_FACT_INSCRIPCION (
    Tiempo_Key,
    Sede_Key,
    Categoria_Key,
    Turno_Key,
    Rango_Etario_Alumno_Key,
    Cantidad_Inscripciones,
    Inscripciones_Aprobadas,
    Inscripciones_Rechazadas,
    Inscripciones_Pendientes,
    Dias_Promedio_Hasta_Respuesta,
    Importe_Total_Esperado
)
SELECT
    ti.Tiempo_Key,
    ds.Sede_Key,
    dc.Categoria_Key,
    dt.Turno_Key,
    CASE
        WHEN DATEDIFF(YEAR, a.FechaNacimiento, i.FechaInscripcion) < 25 THEN 1
        WHEN DATEDIFF(YEAR, a.FechaNacimiento, i.FechaInscripcion) BETWEEN 25 AND 35 THEN 2
        WHEN DATEDIFF(YEAR, a.FechaNacimiento, i.FechaInscripcion) BETWEEN 36 AND 50 THEN 3
        ELSE 4
    END AS Rango_Etario_Alumno_Key,
    COUNT(*) AS Cantidad_Inscripciones,
    SUM(CASE WHEN i.Estado = 'Confirmada' THEN 1 ELSE 0 END) AS Inscripciones_Aprobadas,
    SUM(CASE WHEN i.Estado = 'Rechazada' THEN 1 ELSE 0 END) AS Inscripciones_Rechazadas,
    SUM(CASE WHEN i.Estado = 'Pendiente' THEN 1 ELSE 0 END) AS Inscripciones_Pendientes,
    AVG(CAST(DATEDIFF(DAY, i.FechaInscripcion, i.FechaRespuesta) AS DECIMAL(10,2))) AS Dias_Promedio_Hasta_Respuesta,
    SUM(c.PrecioMensual * c.DuracionMeses) AS Importe_Total_Esperado
FROM empanadas_indexadas.INSCRIPCION i
INNER JOIN empanadas_indexadas.ALUMNO a ON i.Legajo_Alumno = a.Legajo_Alumno
INNER JOIN empanadas_indexadas.CURSO c ON i.Cod_Curso = c.Cod_Curso
INNER JOIN empanadas_indexadas.BI_DIM_TIEMPO ti ON ti.Fecha = CAST(i.FechaInscripcion AS DATE)
INNER JOIN empanadas_indexadas.BI_DIM_SEDE ds ON ds.ID_Sede = c.ID_Sede
LEFT JOIN empanadas_indexadas.BI_DIM_CATEGORIA dc ON dc.ID_Categoria = c.ID_Categoria
LEFT JOIN empanadas_indexadas.BI_DIM_TURNO dt ON dt.ID_Turno = c.ID_Turno
WHERE i.FechaInscripcion IS NOT NULL
GROUP BY
    ti.Tiempo_Key,
    ds.Sede_Key,
    dc.Categoria_Key,
    dt.Turno_Key,
    CASE
        WHEN DATEDIFF(YEAR, a.FechaNacimiento, i.FechaInscripcion) < 25 THEN 1
        WHEN DATEDIFF(YEAR, a.FechaNacimiento, i.FechaInscripcion) BETWEEN 25 AND 35 THEN 2
        WHEN DATEDIFF(YEAR, a.FechaNacimiento, i.FechaInscripcion) BETWEEN 36 AND 50 THEN 3
        ELSE 4
    END;

DECLARE @count_inscripcion INT = @@ROWCOUNT;
PRINT 'BI_FACT_INSCRIPCION: ' + CAST(@count_inscripcion AS VARCHAR(10)) + ' registros';

-- 5.2) FACT_EVALUACION_CURSO Agregado por (Tiempo + Sede + Categoría + Rango Etario)
PRINT 'Poblando BI_FACT_EVALUACION_CURSO...';
INSERT INTO empanadas_indexadas.BI_FACT_EVALUACION_CURSO (
    Tiempo_Key,
    Sede_Key,
    Categoria_Key,
    Rango_Etario_Alumno_Key,
    Cantidad_Evaluaciones,
    Cantidad_Presentes,
    Cantidad_Ausentes,
    Cantidad_Aprobados,
    Suma_Notas,
    Nota_Promedio
)
SELECT
    te.Tiempo_Key,
    ds.Sede_Key,
    dc.Categoria_Key,
    CASE
        WHEN DATEDIFF(YEAR, a.FechaNacimiento, ec.FechaEvaluacion) < 25 THEN 1
        WHEN DATEDIFF(YEAR, a.FechaNacimiento, ec.FechaEvaluacion) BETWEEN 25 AND 35 THEN 2
        WHEN DATEDIFF(YEAR, a.FechaNacimiento, ec.FechaEvaluacion) BETWEEN 36 AND 50 THEN 3
        ELSE 4
    END AS Rango_Etario_Alumno_Key,
    COUNT(*) AS Cantidad_Evaluaciones,
    SUM(CASE WHEN ec.Presente = 1 THEN 1 ELSE 0 END) AS Cantidad_Presentes,
    SUM(CASE WHEN ec.Presente = 0 OR ec.Presente IS NULL THEN 1 ELSE 0 END) AS Cantidad_Ausentes,
    SUM(CASE WHEN ec.Nota >= 4 AND ec.Presente = 1 THEN 1 ELSE 0 END) AS Cantidad_Aprobados,
    SUM(CASE WHEN ec.Presente = 1 THEN ec.Nota ELSE 0 END) AS Suma_Notas,
    AVG(CASE WHEN ec.Presente = 1 THEN CAST(ec.Nota AS DECIMAL(5,2)) ELSE NULL END) AS Nota_Promedio
FROM empanadas_indexadas.EVALUACION_CURSO ec
INNER JOIN empanadas_indexadas.INSCRIPCION i ON ec.Nro_inscripcion = i.Nro_Inscripcion
INNER JOIN empanadas_indexadas.ALUMNO a ON i.Legajo_Alumno = a.Legajo_Alumno
INNER JOIN empanadas_indexadas.CURSO c ON i.Cod_Curso = c.Cod_Curso
INNER JOIN empanadas_indexadas.BI_DIM_TIEMPO te ON te.Fecha = CAST(ec.FechaEvaluacion AS DATE)
INNER JOIN empanadas_indexadas.BI_DIM_SEDE ds ON ds.ID_Sede = c.ID_Sede
LEFT JOIN empanadas_indexadas.BI_DIM_CATEGORIA dc ON dc.ID_Categoria = c.ID_Categoria
WHERE ec.FechaEvaluacion IS NOT NULL
GROUP BY
    te.Tiempo_Key,
    ds.Sede_Key,
    dc.Categoria_Key,
    CASE
        WHEN DATEDIFF(YEAR, a.FechaNacimiento, ec.FechaEvaluacion) < 25 THEN 1
        WHEN DATEDIFF(YEAR, a.FechaNacimiento, ec.FechaEvaluacion) BETWEEN 25 AND 35 THEN 2
        WHEN DATEDIFF(YEAR, a.FechaNacimiento, ec.FechaEvaluacion) BETWEEN 36 AND 50 THEN 3
        ELSE 4
    END;

DECLARE @count_eval_curso INT = @@ROWCOUNT;
PRINT 'BI_FACT_EVALUACION_CURSO: ' + CAST(@count_eval_curso AS VARCHAR(10)) + ' registros';

-- 5.3) FACT_EVALUACION_FINAL
-- 5.3) FACT_EVALUACION_FINAL Agregado por (Tiempo + Sede + Categoría + Rango Etario)
PRINT 'Poblando BI_FACT_EVALUACION_FINAL...';
INSERT INTO empanadas_indexadas.BI_FACT_EVALUACION_FINAL (
    Tiempo_Key,
    Sede_Key,
    Categoria_Key,
    Rango_Etario_Alumno_Key,
    Cantidad_Inscripciones_Final,
    Cantidad_Presentes,
    Cantidad_Ausentes,
    Cantidad_Aprobados,
    Suma_Notas,
    Nota_Promedio,
    Dias_Promedio_Finalizacion
)
SELECT
    te.Tiempo_Key,
    ds.Sede_Key,
    dc.Categoria_Key,
    CASE
        WHEN DATEDIFF(YEAR, a.FechaNacimiento, inf.FechaInscripcion) < 25 THEN 1
        WHEN DATEDIFF(YEAR, a.FechaNacimiento, inf.FechaInscripcion) BETWEEN 25 AND 35 THEN 2
        WHEN DATEDIFF(YEAR, a.FechaNacimiento, inf.FechaInscripcion) BETWEEN 36 AND 50 THEN 3
        ELSE 4
    END AS Rango_Etario_Alumno_Key,
    COUNT(*) AS Cantidad_Inscripciones_Final,
    SUM(CASE WHEN ef.Presente = 1 THEN 1 ELSE 0 END) AS Cantidad_Presentes,
    SUM(CASE WHEN ef.Presente = 0 OR ef.Presente IS NULL THEN 1 ELSE 0 END) AS Cantidad_Ausentes,
    SUM(CASE WHEN ef.Nota >= 4 AND ef.Presente = 1 THEN 1 ELSE 0 END) AS Cantidad_Aprobados,
    SUM(CASE WHEN ef.Presente = 1 THEN ef.Nota ELSE 0 END) AS Suma_Notas,
    AVG(CASE WHEN ef.Presente = 1 THEN CAST(ef.Nota AS DECIMAL(5,2)) ELSE NULL END) AS Nota_Promedio,
    AVG(CAST(DATEDIFF(DAY, c.FechaInicio, ex.Fecha) AS DECIMAL(10,2))) AS Dias_Promedio_Finalizacion
FROM empanadas_indexadas.INSCRIPCION_FINAL inf
INNER JOIN empanadas_indexadas.ALUMNO a ON inf.Legajo_Alumno = a.Legajo_Alumno
INNER JOIN empanadas_indexadas.EXAMEN_FINAL ex ON inf.ID_ExamenFinal = ex.ID_ExamenFinal
INNER JOIN empanadas_indexadas.CURSO c ON ex.Cod_Curso = c.Cod_Curso
LEFT JOIN empanadas_indexadas.EVALUACION_FINAL ef ON ef.Nro_inscripcionFinal = inf.Nro_inscripcionFinal
INNER JOIN empanadas_indexadas.BI_DIM_TIEMPO te ON te.Fecha = CAST(ex.Fecha AS DATE)
INNER JOIN empanadas_indexadas.BI_DIM_SEDE ds ON ds.ID_Sede = c.ID_Sede
LEFT JOIN empanadas_indexadas.BI_DIM_CATEGORIA dc ON dc.ID_Categoria = c.ID_Categoria
WHERE ex.Fecha IS NOT NULL
GROUP BY
    te.Tiempo_Key,
    ds.Sede_Key,
    dc.Categoria_Key,
    CASE
        WHEN DATEDIFF(YEAR, a.FechaNacimiento, inf.FechaInscripcion) < 25 THEN 1
        WHEN DATEDIFF(YEAR, a.FechaNacimiento, inf.FechaInscripcion) BETWEEN 25 AND 35 THEN 2
        WHEN DATEDIFF(YEAR, a.FechaNacimiento, inf.FechaInscripcion) BETWEEN 36 AND 50 THEN 3
        ELSE 4
    END;

DECLARE @count_eval_final INT = @@ROWCOUNT;
PRINT 'BI_FACT_EVALUACION_FINAL: ' + CAST(@count_eval_final AS VARCHAR(10)) + ' registros';

-- 5.4) FACT_PAGO Agregado por (Tiempo + Sede + Categoría + Medio Pago)
PRINT 'Poblando BI_FACT_PAGO...';
INSERT INTO empanadas_indexadas.BI_FACT_PAGO (
    Tiempo_Key,
    Sede_Key,
    Categoria_Key,
    MedioPago_Key,
    Cantidad_Facturas,
    Importe_Total_Facturado,
    Importe_Total_Pagado,
    Cantidad_Facturas_Pagadas,
    Cantidad_Pagos_En_Termino,
    Cantidad_Pagos_Fuera_Termino,
    Importe_Adeudado
)
SELECT
    te.Tiempo_Key,
    ds.Sede_Key,
    dc.Categoria_Key,
    dmp.MedioPago_Key,
    COUNT(DISTINCT f.Nro_Factura) AS Cantidad_Facturas,
    SUM(df.Importe) AS Importe_Total_Facturado,
    SUM(ISNULL(p.Importe, 0)) AS Importe_Total_Pagado,
    COUNT(DISTINCT CASE WHEN p.ID_Pago IS NOT NULL THEN f.Nro_Factura ELSE NULL END) AS Cantidad_Facturas_Pagadas,
    SUM(CASE WHEN p.Fecha IS NOT NULL AND p.Fecha <= f.FechaVencimiento THEN 1 ELSE 0 END) AS Cantidad_Pagos_En_Termino,
    SUM(CASE WHEN p.Fecha IS NOT NULL AND p.Fecha > f.FechaVencimiento THEN 1 ELSE 0 END) AS Cantidad_Pagos_Fuera_Termino,
    SUM(CASE WHEN p.ID_Pago IS NULL THEN df.Importe ELSE 0 END) AS Importe_Adeudado
FROM empanadas_indexadas.FACTURA f
INNER JOIN empanadas_indexadas.DETALLE_FACTURA df ON f.Nro_Factura = df.Nro_Factura
INNER JOIN empanadas_indexadas.BI_DIM_TIEMPO te ON te.Fecha = CAST(f.FechaEmision AS DATE)
LEFT JOIN empanadas_indexadas.PAGO p ON p.Nro_Factura = f.Nro_Factura
LEFT JOIN empanadas_indexadas.BI_DIM_MEDIO_PAGO dmp ON dmp.ID_MedioPago = p.ID_MedioPago
INNER JOIN empanadas_indexadas.CURSO c ON df.Cod_Curso = c.Cod_Curso
INNER JOIN empanadas_indexadas.BI_DIM_SEDE ds ON ds.ID_Sede = c.ID_Sede
LEFT JOIN empanadas_indexadas.BI_DIM_CATEGORIA dc ON dc.ID_Categoria = c.ID_Categoria
WHERE f.FechaEmision IS NOT NULL
GROUP BY
    te.Tiempo_Key,
    ds.Sede_Key,
    dc.Categoria_Key,
    dmp.MedioPago_Key;

DECLARE @count_pago INT = @@ROWCOUNT;
PRINT 'BI_FACT_PAGO: ' + CAST(@count_pago AS VARCHAR(10)) + ' registros';

-- 5.5) FACT_ENCUESTA Agregado por (Tiempo + Sede + Categoría + Rango Etario Profesor + Satisfacción)
PRINT 'Poblando BI_FACT_ENCUESTA...';
INSERT INTO empanadas_indexadas.BI_FACT_ENCUESTA (
    Tiempo_Key,
    Sede_Key,
    Categoria_Key,
    Rango_Etario_Profesor_Key,
    Satisfaccion_Key,
    Cantidad_Respuestas,
    Suma_Notas,
    Nota_Promedio
)
SELECT
    t.Tiempo_Key,
    ds.Sede_Key,
    dc.Categoria_Key,
    CASE
        WHEN DATEDIFF(YEAR, p.FechaNacimiento, e.FechaRegistro) BETWEEN 25 AND 35 THEN 1
        WHEN DATEDIFF(YEAR, p.FechaNacimiento, e.FechaRegistro) BETWEEN 36 AND 50 THEN 2
        ELSE 3
    END AS Rango_Etario_Profesor_Key,
    CASE
        WHEN re.Nota BETWEEN 1 AND 4 THEN 1
        WHEN re.Nota BETWEEN 5 AND 6 THEN 2
        WHEN re.Nota BETWEEN 7 AND 10 THEN 3
        ELSE NULL
    END AS Satisfaccion_Key,
    COUNT(*) AS Cantidad_Respuestas,
    SUM(re.Nota) AS Suma_Notas,
    AVG(CAST(re.Nota AS DECIMAL(5,2))) AS Nota_Promedio
FROM empanadas_indexadas.ENCUESTA e
INNER JOIN empanadas_indexadas.RESPUESTA_ENCUESTA re ON e.ID_Encuesta = re.ID_Encuesta
INNER JOIN empanadas_indexadas.CURSO c ON e.Cod_Curso = c.Cod_Curso
INNER JOIN empanadas_indexadas.PROFESOR p ON c.ID_Profesor = p.ID_Profesor
INNER JOIN empanadas_indexadas.BI_DIM_TIEMPO t ON t.Fecha = CAST(e.FechaRegistro AS DATE)
INNER JOIN empanadas_indexadas.BI_DIM_SEDE ds ON ds.ID_Sede = c.ID_Sede
LEFT JOIN empanadas_indexadas.BI_DIM_CATEGORIA dc ON dc.ID_Categoria = c.ID_Categoria
WHERE e.FechaRegistro IS NOT NULL
  AND re.Nota BETWEEN 1 AND 10
GROUP BY
    t.Tiempo_Key,
    ds.Sede_Key,
    dc.Categoria_Key,
    CASE
        WHEN DATEDIFF(YEAR, p.FechaNacimiento, e.FechaRegistro) BETWEEN 25 AND 35 THEN 1
        WHEN DATEDIFF(YEAR, p.FechaNacimiento, e.FechaRegistro) BETWEEN 36 AND 50 THEN 2
        ELSE 3
    END,
    CASE
        WHEN re.Nota BETWEEN 1 AND 4 THEN 1
        WHEN re.Nota BETWEEN 5 AND 6 THEN 2
        WHEN re.Nota BETWEEN 7 AND 10 THEN 3
        ELSE NULL
    END;

DECLARE @count_encuesta INT = @@ROWCOUNT;
PRINT 'BI_FACT_ENCUESTA: ' + CAST(@count_encuesta AS VARCHAR(10)) + ' registros';
PRINT '';

-- ============================================================================
-- 6) CREACIÓN DE VISTAS PARA LOS 10 INDICADORES
-- ============================================================================

PRINT 'Creando vistas de análisis BI...';

-- VISTA 1: Categorías y turnos más solicitados
-- Top 3 categorías y turnos con mayor cantidad de inscriptos por año por sede
GO
CREATE VIEW empanadas_indexadas.BI_V_Categorias_Turnos_Mas_Solicitados AS
WITH Ranking AS (
    SELECT
        t.Anio,
        s.Sede_Nombre,
        c.Categoria_Nombre,
        tu.Turno_Nombre,
        SUM(f.Cantidad_Inscripciones) AS Total_Inscripciones,
        ROW_NUMBER() OVER (
            PARTITION BY t.Anio, s.Sede_Nombre
            ORDER BY SUM(f.Cantidad_Inscripciones) DESC
        ) AS Ranking_Categoria,
        ROW_NUMBER() OVER (
            PARTITION BY t.Anio, s.Sede_Nombre, tu.Turno_Nombre
            ORDER BY SUM(f.Cantidad_Inscripciones) DESC
        ) AS Ranking_Turno
    FROM empanadas_indexadas.BI_FACT_INSCRIPCION f
    INNER JOIN empanadas_indexadas.BI_DIM_TIEMPO t ON f.Tiempo_Key = t.Tiempo_Key
    INNER JOIN empanadas_indexadas.BI_DIM_SEDE s ON f.Sede_Key = s.Sede_Key
    LEFT JOIN empanadas_indexadas.BI_DIM_CATEGORIA c ON f.Categoria_Key = c.Categoria_Key
    LEFT JOIN empanadas_indexadas.BI_DIM_TURNO tu ON f.Turno_Key = tu.Turno_Key
    GROUP BY t.Anio, s.Sede_Nombre, c.Categoria_Nombre, tu.Turno_Nombre
)
SELECT
    Anio,
    Sede_Nombre,
    Categoria_Nombre,
    Turno_Nombre,
    Total_Inscripciones,
    Ranking_Categoria
FROM Ranking
WHERE Ranking_Categoria <= 3;
GO

-- VISTA 2: Tasa de rechazo de inscripciones
-- Porcentaje de inscripciones rechazadas por mes por sede
GO
CREATE VIEW empanadas_indexadas.BI_V_Tasa_Rechazo_Inscripciones AS
SELECT
    t.Anio,
    t.Mes,
    t.Mes_Nombre,
    s.Sede_Nombre,
    SUM(f.Cantidad_Inscripciones) AS Total_Inscripciones,
    SUM(f.Inscripciones_Rechazadas) AS Total_Rechazadas,
    CASE
        WHEN SUM(f.Cantidad_Inscripciones) > 0
        THEN (SUM(f.Inscripciones_Rechazadas) * 100.0) / SUM(f.Cantidad_Inscripciones)
        ELSE 0
    END AS Porcentaje_Rechazo
FROM empanadas_indexadas.BI_FACT_INSCRIPCION f
INNER JOIN empanadas_indexadas.BI_DIM_TIEMPO t ON f.Tiempo_Key = t.Tiempo_Key
INNER JOIN empanadas_indexadas.BI_DIM_SEDE s ON f.Sede_Key = s.Sede_Key
GROUP BY t.Anio, t.Mes, t.Mes_Nombre, s.Sede_Nombre;
GO

-- VISTA 3: Comparación de desempeño de cursada por sede
-- Porcentaje de evaluaciones aprobadas (nota >= 4) por sede por año
GO
CREATE VIEW empanadas_indexadas.BI_V_Desempeno_Cursada_Sede AS
SELECT
    t.Anio,
    s.Sede_Nombre,
    SUM(f.Cantidad_Presentes) AS Total_Evaluaciones_Presentes,
    SUM(f.Cantidad_Aprobados) AS Total_Aprobadas,
    CASE
        WHEN SUM(f.Cantidad_Presentes) > 0
        THEN (SUM(f.Cantidad_Aprobados) * 100.0) / SUM(f.Cantidad_Presentes)
        ELSE 0
    END AS Porcentaje_Aprobacion
FROM empanadas_indexadas.BI_FACT_EVALUACION_CURSO f
INNER JOIN empanadas_indexadas.BI_DIM_TIEMPO t ON f.Tiempo_Key = t.Tiempo_Key
INNER JOIN empanadas_indexadas.BI_DIM_SEDE s ON f.Sede_Key = s.Sede_Key
GROUP BY t.Anio, s.Sede_Nombre;
GO

-- VISTA 4: Tiempo promedio de finalización de curso
-- Tiempo promedio entre inicio de curso y aprobación del final por categoría por año
GO
CREATE VIEW empanadas_indexadas.BI_V_Tiempo_Finalizacion_Curso AS
SELECT
    t.Anio,
    c.Categoria_Nombre,
    AVG(f.Dias_Promedio_Finalizacion) AS Dias_Promedio_Finalizacion,
    SUM(f.Cantidad_Aprobados) AS Cantidad_Finales_Aprobados
FROM empanadas_indexadas.BI_FACT_EVALUACION_FINAL f
INNER JOIN empanadas_indexadas.BI_DIM_TIEMPO t ON f.Tiempo_Key = t.Tiempo_Key
LEFT JOIN empanadas_indexadas.BI_DIM_CATEGORIA c ON f.Categoria_Key = c.Categoria_Key
WHERE f.Dias_Promedio_Finalizacion IS NOT NULL
GROUP BY t.Anio, c.Categoria_Nombre;
GO

-- VISTA 5: Nota promedio de finales
-- Promedio de nota según rango etario del alumno y categoría por cuatrimestre
GO
CREATE VIEW empanadas_indexadas.BI_V_Nota_Promedio_Finales AS
SELECT
    t.Anio,
    t.Cuatrimestre,
    r.Rango_Descripcion AS Rango_Etario_Alumno,
    c.Categoria_Nombre,
    AVG(f.Nota_Promedio) AS Nota_Promedio,
    SUM(f.Cantidad_Presentes) AS Cantidad_Finales
FROM empanadas_indexadas.BI_FACT_EVALUACION_FINAL f
INNER JOIN empanadas_indexadas.BI_DIM_TIEMPO t ON f.Tiempo_Key = t.Tiempo_Key
LEFT JOIN empanadas_indexadas.BI_DIM_RANGO_ETARIO_ALUMNO r ON f.Rango_Etario_Alumno_Key = r.Rango_Etario_Alumno_Key
LEFT JOIN empanadas_indexadas.BI_DIM_CATEGORIA c ON f.Categoria_Key = c.Categoria_Key
WHERE f.Nota_Promedio IS NOT NULL
GROUP BY t.Anio, t.Cuatrimestre, r.Rango_Descripcion, c.Categoria_Nombre;
GO

-- VISTA 6: Tasa de ausentismo finales
-- Porcentaje de ausentes a finales por cuatrimestre por sede
GO
CREATE VIEW empanadas_indexadas.BI_V_Tasa_Ausentismo_Finales AS
SELECT
    t.Anio,
    t.Cuatrimestre,
    s.Sede_Nombre,
    SUM(f.Cantidad_Inscripciones_Final) AS Total_Inscripciones_Final,
    SUM(f.Cantidad_Ausentes) AS Total_Ausentes,
    CASE
        WHEN SUM(f.Cantidad_Inscripciones_Final) > 0
        THEN (SUM(f.Cantidad_Ausentes) * 100.0) / SUM(f.Cantidad_Inscripciones_Final)
        ELSE 0
    END AS Porcentaje_Ausentismo
FROM empanadas_indexadas.BI_FACT_EVALUACION_FINAL f
INNER JOIN empanadas_indexadas.BI_DIM_TIEMPO t ON f.Tiempo_Key = t.Tiempo_Key
INNER JOIN empanadas_indexadas.BI_DIM_SEDE s ON f.Sede_Key = s.Sede_Key
GROUP BY t.Anio, t.Cuatrimestre, s.Sede_Nombre;
GO

-- VISTA 7: Desvío de pagos
-- Porcentaje de pagos fuera de término por cuatrimestre
GO
CREATE VIEW empanadas_indexadas.BI_V_Desvio_Pagos AS
SELECT
    t.Anio,
    t.Cuatrimestre,
    SUM(f.Cantidad_Facturas_Pagadas) AS Total_Pagos,
    SUM(f.Cantidad_Pagos_Fuera_Termino) AS Pagos_Fuera_Termino,
    CASE
        WHEN SUM(f.Cantidad_Facturas_Pagadas) > 0
        THEN (SUM(f.Cantidad_Pagos_Fuera_Termino) * 100.0) / SUM(f.Cantidad_Facturas_Pagadas)
        ELSE 0
    END AS Porcentaje_Fuera_Termino
FROM empanadas_indexadas.BI_FACT_PAGO f
INNER JOIN empanadas_indexadas.BI_DIM_TIEMPO t ON f.Tiempo_Key = t.Tiempo_Key
GROUP BY t.Anio, t.Cuatrimestre;
GO

-- VISTA 8: Tasa de morosidad financiera mensual
-- Total importes adeudados sobre facturación esperada en el mes
GO
CREATE VIEW empanadas_indexadas.BI_V_Tasa_Morosidad AS
SELECT
    t.Anio,
    t.Mes,
    t.Mes_Nombre,
    SUM(f.Importe_Total_Facturado) AS Facturacion_Total,
    SUM(f.Importe_Adeudado) AS Monto_Adeudado,
    CASE
        WHEN SUM(f.Importe_Total_Facturado) > 0
        THEN (SUM(f.Importe_Adeudado) * 100.0) / SUM(f.Importe_Total_Facturado)
        ELSE 0
    END AS Porcentaje_Morosidad
FROM empanadas_indexadas.BI_FACT_PAGO f
INNER JOIN empanadas_indexadas.BI_DIM_TIEMPO t ON f.Tiempo_Key = t.Tiempo_Key
GROUP BY t.Anio, t.Mes, t.Mes_Nombre;
GO

-- VISTA 9: Ingresos por categoría de cursos
-- Top 3 categorías que generan mayores ingresos por sede por año
GO
CREATE VIEW empanadas_indexadas.BI_V_Ingresos_Por_Categoria AS
WITH Ingresos AS (
    SELECT
        t.Anio,
        s.Sede_Nombre,
        c.Categoria_Nombre,
        SUM(f.Importe_Total_Facturado) AS Ingresos_Totales,
        ROW_NUMBER() OVER (
            PARTITION BY t.Anio, s.Sede_Nombre
            ORDER BY SUM(f.Importe_Total_Facturado) DESC
        ) AS Ranking
    FROM empanadas_indexadas.BI_FACT_PAGO f
    INNER JOIN empanadas_indexadas.BI_DIM_TIEMPO t ON f.Tiempo_Key = t.Tiempo_Key
    INNER JOIN empanadas_indexadas.BI_DIM_SEDE s ON f.Sede_Key = s.Sede_Key
    LEFT JOIN empanadas_indexadas.BI_DIM_CATEGORIA c ON f.Categoria_Key = c.Categoria_Key
    GROUP BY t.Anio, s.Sede_Nombre, c.Categoria_Nombre
)
SELECT
    Anio,
    Sede_Nombre,
    Categoria_Nombre,
    Ingresos_Totales,
    Ranking
FROM Ingresos
WHERE Ranking <= 3;
GO

-- VISTA 10: Índice de satisfacción
-- Índice anual según rango etario de profesores y sede
-- Fórmula: ((%satisfechos - %insatisfechos) + 100) / 2
GO
CREATE VIEW empanadas_indexadas.BI_V_Indice_Satisfaccion AS
SELECT
    t.Anio,
    s.Sede_Nombre,
    r.Rango_Descripcion AS Rango_Etario_Profesor,
    COUNT(*) AS Total_Respuestas,
    SUM(CASE WHEN sat.Bloque_Descripcion = 'Satisfechos' THEN 1 ELSE 0 END) AS Cantidad_Satisfechos,
    SUM(CASE WHEN sat.Bloque_Descripcion = 'Insatisfechos' THEN 1 ELSE 0 END) AS Cantidad_Insatisfechos,
    -- Porcentajes
    (SUM(CASE WHEN sat.Bloque_Descripcion = 'Satisfechos' THEN 1 ELSE 0 END) * 100.0) / COUNT(*) AS Porcentaje_Satisfechos,
    (SUM(CASE WHEN sat.Bloque_Descripcion = 'Insatisfechos' THEN 1 ELSE 0 END) * 100.0) / COUNT(*) AS Porcentaje_Insatisfechos,
    -- Índice de satisfacción
    ((
        (SUM(CASE WHEN sat.Bloque_Descripcion = 'Satisfechos' THEN 1 ELSE 0 END) * 100.0) / COUNT(*)
        -
        (SUM(CASE WHEN sat.Bloque_Descripcion = 'Insatisfechos' THEN 1 ELSE 0 END) * 100.0) / COUNT(*)
    ) + 100) / 2 AS Indice_Satisfaccion
FROM empanadas_indexadas.BI_FACT_ENCUESTA f
INNER JOIN empanadas_indexadas.BI_DIM_TIEMPO t ON f.Tiempo_Key = t.Tiempo_Key
INNER JOIN empanadas_indexadas.BI_DIM_SEDE s ON f.Sede_Key = s.Sede_Key
LEFT JOIN empanadas_indexadas.BI_DIM_RANGO_ETARIO_PROFESOR r ON f.Rango_Etario_Profesor_Key = r.Rango_Etario_Profesor_Key
LEFT JOIN empanadas_indexadas.BI_DIM_SATISFACCION sat ON f.Satisfaccion_Key = sat.Satisfaccion_Key
GROUP BY t.Anio, s.Sede_Nombre, r.Rango_Descripcion;
GO

PRINT 'Vistas de análisis BI creadas exitosamente';
PRINT '';

-- ============================================================================
-- 7) ÍNDICES ADICIONALES PARA OPTIMIZACIÓN
-- ============================================================================

PRINT 'Creando índices adicionales...';

-- Índices en FACT_INSCRIPCION
CREATE INDEX IX_BI_FACT_INSCRIPCION_Tiempo ON empanadas_indexadas.BI_FACT_INSCRIPCION(Tiempo_Key);
CREATE INDEX IX_BI_FACT_INSCRIPCION_Sede ON empanadas_indexadas.BI_FACT_INSCRIPCION(Sede_Key);
CREATE INDEX IX_BI_FACT_INSCRIPCION_Categoria ON empanadas_indexadas.BI_FACT_INSCRIPCION(Categoria_Key);

-- Índices en FACT_EVALUACION_CURSO
CREATE INDEX IX_BI_FACT_EVALUACION_CURSO_Tiempo ON empanadas_indexadas.BI_FACT_EVALUACION_CURSO(Tiempo_Key);
CREATE INDEX IX_BI_FACT_EVALUACION_CURSO_Sede ON empanadas_indexadas.BI_FACT_EVALUACION_CURSO(Sede_Key);

-- Índices en FACT_EVALUACION_FINAL
CREATE INDEX IX_BI_FACT_EVALUACION_FINAL_Tiempo ON empanadas_indexadas.BI_FACT_EVALUACION_FINAL(Tiempo_Key);
CREATE INDEX IX_BI_FACT_EVALUACION_FINAL_Sede ON empanadas_indexadas.BI_FACT_EVALUACION_FINAL(Sede_Key);

-- Índices en FACT_PAGO
CREATE INDEX IX_BI_FACT_PAGO_Tiempo ON empanadas_indexadas.BI_FACT_PAGO(Tiempo_Key);
CREATE INDEX IX_BI_FACT_PAGO_Sede ON empanadas_indexadas.BI_FACT_PAGO(Sede_Key);

-- Índices en FACT_ENCUESTA
CREATE INDEX IX_BI_FACT_ENCUESTA_Tiempo ON empanadas_indexadas.BI_FACT_ENCUESTA(Tiempo_Key);
CREATE INDEX IX_BI_FACT_ENCUESTA_Sede ON empanadas_indexadas.BI_FACT_ENCUESTA(Sede_Key);

PRINT 'Índices creados exitosamente';
PRINT '';

-- ============================================================================
-- 8) RESUMEN FINAL
-- ============================================================================

PRINT '============================================================================';
PRINT 'MIGRACIÓN DE MODELO BI COMPLETADA EXITOSAMENTE';
PRINT '============================================================================';
PRINT '';

-- Calcular counts de dimensiones
DECLARE @dim_tiempo INT, @dim_sede INT, @dim_rango_alu INT, @dim_rango_prof INT;
DECLARE @dim_turno INT, @dim_categoria INT, @dim_mediopago INT, @dim_satisf INT;

SELECT @dim_tiempo = COUNT(*) FROM empanadas_indexadas.BI_DIM_TIEMPO;
SELECT @dim_sede = COUNT(*) FROM empanadas_indexadas.BI_DIM_SEDE;
SELECT @dim_rango_alu = COUNT(*) FROM empanadas_indexadas.BI_DIM_RANGO_ETARIO_ALUMNO;
SELECT @dim_rango_prof = COUNT(*) FROM empanadas_indexadas.BI_DIM_RANGO_ETARIO_PROFESOR;
SELECT @dim_turno = COUNT(*) FROM empanadas_indexadas.BI_DIM_TURNO;
SELECT @dim_categoria = COUNT(*) FROM empanadas_indexadas.BI_DIM_CATEGORIA;
SELECT @dim_mediopago = COUNT(*) FROM empanadas_indexadas.BI_DIM_MEDIO_PAGO;
SELECT @dim_satisf = COUNT(*) FROM empanadas_indexadas.BI_DIM_SATISFACCION;

PRINT 'DIMENSIONES CREADAS Y POBLADAS:';
PRINT '  - BI_DIM_TIEMPO: ' + CAST(@dim_tiempo AS VARCHAR(10)) + ' registros';
PRINT '  - BI_DIM_SEDE: ' + CAST(@dim_sede AS VARCHAR(10)) + ' registros';
PRINT '  - BI_DIM_RANGO_ETARIO_ALUMNO: ' + CAST(@dim_rango_alu AS VARCHAR(10)) + ' registros';
PRINT '  - BI_DIM_RANGO_ETARIO_PROFESOR: ' + CAST(@dim_rango_prof AS VARCHAR(10)) + ' registros';
PRINT '  - BI_DIM_TURNO: ' + CAST(@dim_turno AS VARCHAR(10)) + ' registros';
PRINT '  - BI_DIM_CATEGORIA: ' + CAST(@dim_categoria AS VARCHAR(10)) + ' registros';
PRINT '  - BI_DIM_MEDIO_PAGO: ' + CAST(@dim_mediopago AS VARCHAR(10)) + ' registros';
PRINT '  - BI_DIM_SATISFACCION: ' + CAST(@dim_satisf AS VARCHAR(10)) + ' registros';
PRINT '';

-- Calcular counts de hechos
DECLARE @fact_insc INT, @fact_eval_curso INT, @fact_eval_final INT;
DECLARE @fact_pago INT, @fact_encuesta INT;

SELECT @fact_insc = COUNT(*) FROM empanadas_indexadas.BI_FACT_INSCRIPCION;
SELECT @fact_eval_curso = COUNT(*) FROM empanadas_indexadas.BI_FACT_EVALUACION_CURSO;
SELECT @fact_eval_final = COUNT(*) FROM empanadas_indexadas.BI_FACT_EVALUACION_FINAL;
SELECT @fact_pago = COUNT(*) FROM empanadas_indexadas.BI_FACT_PAGO;
SELECT @fact_encuesta = COUNT(*) FROM empanadas_indexadas.BI_FACT_ENCUESTA;

PRINT 'TABLAS DE HECHOS CREADAS Y POBLADAS:';
PRINT '  - BI_FACT_INSCRIPCION: ' + CAST(@fact_insc AS VARCHAR(10)) + ' registros';
PRINT '  - BI_FACT_EVALUACION_CURSO: ' + CAST(@fact_eval_curso AS VARCHAR(10)) + ' registros';
PRINT '  - BI_FACT_EVALUACION_FINAL: ' + CAST(@fact_eval_final AS VARCHAR(10)) + ' registros';
PRINT '  - BI_FACT_PAGO: ' + CAST(@fact_pago AS VARCHAR(10)) + ' registros';
PRINT '  - BI_FACT_ENCUESTA: ' + CAST(@fact_encuesta AS VARCHAR(10)) + ' registros';
PRINT '';
PRINT 'VISTAS DE ANÁLISIS CREADAS (10):';
PRINT '  1. BI_V_Categorias_Turnos_Mas_Solicitados';
PRINT '  2. BI_V_Tasa_Rechazo_Inscripciones';
PRINT '  3. BI_V_Desempeno_Cursada_Sede';
PRINT '  4. BI_V_Tiempo_Finalizacion_Curso';
PRINT '  5. BI_V_Nota_Promedio_Finales';
PRINT '  6. BI_V_Tasa_Ausentismo_Finales';
PRINT '  7. BI_V_Desvio_Pagos';
PRINT '  8. BI_V_Tasa_Morosidad';
PRINT '  9. BI_V_Ingresos_Por_Categoria';
PRINT ' 10. BI_V_Indice_Satisfaccion';
GO
