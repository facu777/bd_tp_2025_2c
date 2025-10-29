/*
1) DROP TABLE IF EXISTS en orden inverso a dependencias para evitar errores por FKs.
2) Crear schema si no existe.
3) CREATE TABLE en orden que satisface FKs.
4) Migrate tablas de lookup/auxiliares.
5) Migrate tablas core (Institucion, Sede, Profesor, Alumno, Curso, Modulo, Inscripcion).
6) Migrate tablas restantes (Evaluacion_Curso, Trabajo_Practico, Examen_Final, Inscripcion_Final, Evaluacion_Final, Factura, Detalle_Factura, Medio_Pago, Pago, Encuesta, Pregunta_Encuesta, Respuesta_Encuesta).
7) Migrate completo

Cada migrate es un stored procedure aparte con TRY/CATCH y transacciones.
*/

--------------------------------------------------------------------------------
-- 1) Drops (orden inverso)
--------------------------------------------------------------------------------
DROP TABLE IF EXISTS empanadas_indexadas.RESPUESTA_ENCUESTA;
DROP TABLE IF EXISTS empanadas_indexadas.PREGUNTA_ENCUESTA;
DROP TABLE IF EXISTS empanadas_indexadas.ENCUESTA;
DROP TABLE IF EXISTS empanadas_indexadas.PAGO;
DROP TABLE IF EXISTS empanadas_indexadas.MEDIO_PAGO;
DROP TABLE IF EXISTS empanadas_indexadas.DETALLE_FACTURA;
DROP TABLE IF EXISTS empanadas_indexadas.FACTURA;
DROP TABLE IF EXISTS empanadas_indexadas.EVALUACION_FINAL;
DROP TABLE IF EXISTS empanadas_indexadas.INSCRIPCION_FINAL;
DROP TABLE IF EXISTS empanadas_indexadas.EXAMEN_FINAL;
DROP TABLE IF EXISTS empanadas_indexadas.TRABAJO_PRACTICO;
DROP TABLE IF EXISTS empanadas_indexadas.EVALUACION_CURSO;
DROP TABLE IF EXISTS empanadas_indexadas.INSCRIPCION;
DROP TABLE IF EXISTS empanadas_indexadas.MODULO;
DROP TABLE IF EXISTS empanadas_indexadas.CURSO;
DROP TABLE IF EXISTS empanadas_indexadas.ALUMNO;
DROP TABLE IF EXISTS empanadas_indexadas.PROFESOR;
DROP TABLE IF EXISTS empanadas_indexadas.SEDE;
DROP TABLE IF EXISTS empanadas_indexadas.INSTITUCION;
DROP TABLE IF EXISTS empanadas_indexadas.CATEGORIA;
DROP TABLE IF EXISTS empanadas_indexadas.DIA;
DROP TABLE IF EXISTS empanadas_indexadas.TURNO;
DROP TABLE IF EXISTS empanadas_indexadas.LOCALIDAD;
DROP TABLE IF EXISTS empanadas_indexadas.PROVINCIA;

--------------------------------------------------------------------------------
-- 2) Crear schema si no existe
--------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'empanadas_indexadas')
BEGIN
    EXEC('CREATE SCHEMA empanadas_indexadas');
END

--------------------------------------------------------------------------------
-- 3) CREATEs
--------------------------------------------------------------------------------
CREATE TABLE empanadas_indexadas.PROVINCIA (
    ID_Provincia BIGINT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE empanadas_indexadas.LOCALIDAD (
    ID_Localidad BIGINT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(255) NOT NULL,
    ID_Provincia BIGINT NOT NULL,
    CONSTRAINT UQ_Localidad_Nombre_Provincia UNIQUE (Nombre, ID_Provincia),
    CONSTRAINT FK_Localidad_Provincia FOREIGN KEY (ID_Provincia)
        REFERENCES empanadas_indexadas.PROVINCIA (ID_Provincia)
);

CREATE TABLE empanadas_indexadas.TURNO (
    ID_Turno TINYINT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE empanadas_indexadas.DIA (
    ID_Dia TINYINT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE empanadas_indexadas.CATEGORIA (
    ID_Categoria TINYINT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE empanadas_indexadas.INSTITUCION (
    ID_Institucion BIGINT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(255) NULL,
    RazonSocial NVARCHAR(255) NULL,
    Cuit NVARCHAR(50) NULL
);

CREATE TABLE empanadas_indexadas.SEDE (
    ID_Sede BIGINT IDENTITY(1,1) PRIMARY KEY,
    ID_Institucion BIGINT NOT NULL,
    Nombre NVARCHAR(255) NULL,
    ID_Localidad BIGINT NULL,
    Direccion NVARCHAR(255) NULL,
    Telefono NVARCHAR(50) NULL,
    Mail NVARCHAR(255) NULL,
    CONSTRAINT FK_Sede_Institucion FOREIGN KEY (ID_Institucion)
        REFERENCES empanadas_indexadas.INSTITUCION (ID_Institucion),
    CONSTRAINT FK_Sede_Localidad FOREIGN KEY (ID_Localidad)
        REFERENCES empanadas_indexadas.LOCALIDAD (ID_Localidad)
);

CREATE TABLE empanadas_indexadas.PROFESOR (
    ID_Profesor BIGINT IDENTITY(1,1) PRIMARY KEY,
    Dni NVARCHAR(50) NULL,
    Nombre NVARCHAR(255) NULL,
    Apellido NVARCHAR(255) NULL,
    FechaNacimiento DATETIME2 NULL,
    Mail NVARCHAR(255) NULL,
    Direccion NVARCHAR(255) NULL,
    Telefono NVARCHAR(50) NULL,
    ID_Localidad BIGINT NULL,
    CONSTRAINT FK_Profesor_Localidad FOREIGN KEY (ID_Localidad)
        REFERENCES empanadas_indexadas.LOCALIDAD (ID_Localidad)
);

CREATE TABLE empanadas_indexadas.ALUMNO (
    Legajo_Alumno BIGINT IDENTITY(1,1) PRIMARY KEY,
    Dni BIGINT NULL,
    Nombre NVARCHAR(255) NULL,
    Apellido NVARCHAR(255) NULL,
    FechaNacimiento DATETIME2 NULL,
    Mail NVARCHAR(255) NULL,
    Direccion NVARCHAR(255) NULL,
    Telefono NVARCHAR(50) NULL,
    ID_Localidad BIGINT NULL,
    CONSTRAINT FK_Alumno_Localidad FOREIGN KEY (ID_Localidad)
        REFERENCES empanadas_indexadas.LOCALIDAD (ID_Localidad)
);

CREATE TABLE empanadas_indexadas.CURSO (
    Cod_Curso BIGINT IDENTITY(1,1) PRIMARY KEY,
    ID_Sede BIGINT NOT NULL,
    ID_Profesor BIGINT NOT NULL,
    Nombre NVARCHAR(255) NULL,
    Descripcion NVARCHAR(1000) NULL,
    ID_Categoria TINYINT NULL,
    FechaInicio DATETIME2 NULL,
    FechaFin DATETIME2 NULL,
    DuracionMeses BIGINT NULL,
    ID_Dia TINYINT NULL,
    ID_Turno TINYINT NULL,
    PrecioMensual DECIMAL(18,2) NULL,
    CONSTRAINT FK_Curso_Sede FOREIGN KEY (ID_Sede)
        REFERENCES empanadas_indexadas.SEDE (ID_Sede),
    CONSTRAINT FK_Curso_Profesor FOREIGN KEY (ID_Profesor)
        REFERENCES empanadas_indexadas.PROFESOR (ID_Profesor),
    CONSTRAINT FK_Curso_Categoria FOREIGN KEY (ID_Categoria)
        REFERENCES empanadas_indexadas.CATEGORIA (ID_Categoria),
    CONSTRAINT FK_Curso_Dia FOREIGN KEY (ID_Dia)
        REFERENCES empanadas_indexadas.DIA (ID_Dia),
    CONSTRAINT FK_Curso_Turno FOREIGN KEY (ID_Turno)
        REFERENCES empanadas_indexadas.TURNO (ID_Turno)
);

CREATE TABLE empanadas_indexadas.MODULO (
    ID_Modulo BIGINT IDENTITY(1,1) PRIMARY KEY,
    ID_Curso BIGINT NOT NULL,
    Nombre NVARCHAR(255) NULL,
    Descripcion NVARCHAR(1000) NULL,
    CONSTRAINT FK_Modulo_Curso FOREIGN KEY (ID_Curso)
        REFERENCES empanadas_indexadas.CURSO (Cod_Curso)
);

CREATE TABLE empanadas_indexadas.INSCRIPCION (
    Nro_Inscripcion BIGINT IDENTITY(1,1) PRIMARY KEY,
    Legajo_Alumno BIGINT NOT NULL,
    Cod_Curso BIGINT NOT NULL,
    FechaInscripcion DATETIME2 NULL,
    Estado NVARCHAR(50) NULL,
    FechaRespuesta DATETIME2 NULL,
    CONSTRAINT FK_Inscripcion_Alumno FOREIGN KEY (Legajo_Alumno)
        REFERENCES empanadas_indexadas.ALUMNO (Legajo_Alumno),
    CONSTRAINT FK_Inscripcion_Curso FOREIGN KEY (Cod_Curso)
        REFERENCES empanadas_indexadas.CURSO (Cod_Curso)
);

CREATE TABLE empanadas_indexadas.EVALUACION_CURSO (
    ID_EvaluacionCurso BIGINT IDENTITY(1,1) PRIMARY KEY,
    Nro_inscripcion BIGINT NOT NULL,
    ID_Modulo BIGINT NULL,
    FechaEvaluacion DATETIME2 NULL,
    Nota BIGINT NULL,
    Presente BIT NULL,
    Instancia BIGINT NULL,
    CONSTRAINT FK_EvalCurso_Inscripcion FOREIGN KEY (Nro_inscripcion)
        REFERENCES empanadas_indexadas.INSCRIPCION (Nro_Inscripcion),
    CONSTRAINT FK_EvalCurso_Modulo FOREIGN KEY (ID_Modulo)
        REFERENCES empanadas_indexadas.MODULO (ID_Modulo)
);

CREATE TABLE empanadas_indexadas.TRABAJO_PRACTICO (
    ID_TrabajoPractico BIGINT IDENTITY(1,1) PRIMARY KEY,
    Nro_inscripcion BIGINT NOT NULL,
    FechaEvaluacion DATETIME2 NULL,
    Nota BIGINT NULL,
    CONSTRAINT FK_Trabajo_Inscripcion FOREIGN KEY (Nro_inscripcion)
        REFERENCES empanadas_indexadas.INSCRIPCION (Nro_Inscripcion)
);

CREATE TABLE empanadas_indexadas.EXAMEN_FINAL (
    ID_ExamenFinal BIGINT IDENTITY(1,1) PRIMARY KEY,
    Cod_Curso BIGINT NOT NULL,
    Fecha DATETIME2 NULL,
    Hora NVARCHAR(20) NULL,
    Descripcion NVARCHAR(1000) NULL,
    CONSTRAINT FK_Examen_Curso FOREIGN KEY (Cod_Curso)
        REFERENCES empanadas_indexadas.CURSO (Cod_Curso)
);

CREATE TABLE empanadas_indexadas.INSCRIPCION_FINAL (
    Nro_inscripcionFinal BIGINT IDENTITY(1,1) PRIMARY KEY,
    Legajo_Alumno BIGINT NOT NULL,
    ID_ExamenFinal BIGINT NOT NULL,
    FechaInscripcion DATETIME2 NULL,
    CONSTRAINT FK_InsFinal_Alumno FOREIGN KEY (Legajo_Alumno)
        REFERENCES empanadas_indexadas.ALUMNO (Legajo_Alumno),
    CONSTRAINT FK_InsFinal_Examen FOREIGN KEY (ID_ExamenFinal)
        REFERENCES empanadas_indexadas.EXAMEN_FINAL (ID_ExamenFinal)
);

CREATE TABLE empanadas_indexadas.EVALUACION_FINAL (
    ID_EvaluacionFinal BIGINT IDENTITY(1,1) PRIMARY KEY,
    Nro_inscripcionFinal BIGINT NOT NULL,
    ID_Profesor BIGINT NULL,
    Nota BIGINT NULL,
    Presente BIT NULL,
    CONSTRAINT FK_EvalFinal_InsFinal FOREIGN KEY (Nro_inscripcionFinal)
        REFERENCES empanadas_indexadas.INSCRIPCION_FINAL (Nro_inscripcionFinal),
    CONSTRAINT FK_EvalFinal_Profesor FOREIGN KEY (ID_Profesor)
        REFERENCES empanadas_indexadas.PROFESOR (ID_Profesor)
);

CREATE TABLE empanadas_indexadas.FACTURA (
    Nro_Factura BIGINT IDENTITY(1,1) PRIMARY KEY,
    Legajo_Alumno BIGINT NOT NULL,
    FechaEmision DATETIME2 NULL,
    FechaVencimiento DATETIME2 NULL,
    Total DECIMAL(18,2) NULL,
    CONSTRAINT FK_Factura_Alumno FOREIGN KEY (Legajo_Alumno)
        REFERENCES empanadas_indexadas.ALUMNO (Legajo_Alumno)
);

CREATE TABLE empanadas_indexadas.DETALLE_FACTURA (
    ID_DetalleFactura BIGINT IDENTITY(1,1) PRIMARY KEY,
    Nro_Factura BIGINT NOT NULL,
    Cod_Curso BIGINT NULL,
    PeriodoAnio INT NULL,
    PeriodoMes TINYINT NULL,
    Importe DECIMAL(18,2) NULL,
    CONSTRAINT FK_Detalle_Factura_Factura FOREIGN KEY (Nro_Factura)
        REFERENCES empanadas_indexadas.FACTURA (Nro_Factura),
    CONSTRAINT FK_Detalle_Factura_Curso FOREIGN KEY (Cod_Curso)
        REFERENCES empanadas_indexadas.CURSO (Cod_Curso)
);

CREATE TABLE empanadas_indexadas.MEDIO_PAGO (
    ID_MedioPago BIGINT IDENTITY(1,1) PRIMARY KEY,
    Medio NVARCHAR(100) NULL
);

CREATE TABLE empanadas_indexadas.PAGO (
    ID_Pago BIGINT IDENTITY(1,1) PRIMARY KEY,
    Nro_Factura BIGINT NOT NULL,
    ID_MedioPago BIGINT NULL,
    Fecha DATETIME2 NULL,
    Importe DECIMAL(18,2) NULL,
    CONSTRAINT FK_Pago_Factura FOREIGN KEY (Nro_Factura)
        REFERENCES empanadas_indexadas.FACTURA (Nro_Factura),
    CONSTRAINT FK_Pago_MedioPago FOREIGN KEY (ID_MedioPago)
        REFERENCES empanadas_indexadas.MEDIO_PAGO (ID_MedioPago)
);

CREATE TABLE empanadas_indexadas.ENCUESTA (
    ID_Encuesta BIGINT IDENTITY(1,1) PRIMARY KEY,
    Cod_Curso BIGINT NOT NULL,
    FechaRegistro DATETIME2 NULL,
    Observacion NVARCHAR(1000) NULL,
    CONSTRAINT FK_Encuesta_Curso FOREIGN KEY (Cod_Curso)
        REFERENCES empanadas_indexadas.CURSO (Cod_Curso)
);

CREATE TABLE empanadas_indexadas.PREGUNTA_ENCUESTA (
    ID_PreguntaEncuesta BIGINT IDENTITY(1,1) PRIMARY KEY,
    Pregunta NVARCHAR(1000) NOT NULL
);

CREATE TABLE empanadas_indexadas.RESPUESTA_ENCUESTA (
    ID_RespuestaEncuesta BIGINT IDENTITY(1,1) PRIMARY KEY,
    ID_Encuesta BIGINT NOT NULL,
    ID_PreguntaEncuesta BIGINT NOT NULL,
    Nota BIGINT NULL,
    CONSTRAINT FK_Resp_Encuesta FOREIGN KEY (ID_Encuesta)
        REFERENCES empanadas_indexadas.ENCUESTA (ID_Encuesta),
    CONSTRAINT FK_Resp_Pregunta FOREIGN KEY (ID_PreguntaEncuesta)
        REFERENCES empanadas_indexadas.PREGUNTA_ENCUESTA (ID_PreguntaEncuesta)
);


--------------------------------------------------------------------------------
-- 4) Migrate tablas de lookup/auxiliares
--------------------------------------------------------------------------------
IF OBJECT_ID('empanadas_indexadas.sp_migrate_lookups', 'P') IS NOT NULL
    DROP PROCEDURE empanadas_indexadas.sp_migrate_lookups;
GO

CREATE PROCEDURE empanadas_indexadas.sp_migrate_lookups
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1) Provincias
        INSERT INTO empanadas_indexadas.PROVINCIA (Nombre)
        SELECT DISTINCT TRIM(p.Provincia)
        FROM (
            SELECT Sede_Provincia AS Provincia FROM GD2C2025.gd_esquema.Maestra
            UNION
            SELECT Profesor_Provincia FROM GD2C2025.gd_esquema.Maestra
            UNION
            SELECT Alumno_Provincia FROM GD2C2025.gd_esquema.Maestra
        ) AS p
        WHERE p.Provincia IS NOT NULL
          AND LTRIM(RTRIM(p.Provincia)) <> ''
          AND NOT EXISTS (
            SELECT 1 FROM empanadas_indexadas.PROVINCIA pr WHERE pr.Nombre = TRIM(p.Provincia)
        );

        -- 2) Localidades
        INSERT INTO empanadas_indexadas.LOCALIDAD (Nombre, ID_Provincia)
        SELECT DISTINCT TRIM(l.Nombre), pr.ID_Provincia
        FROM (
            SELECT Sede_Localidad AS Nombre, Sede_Provincia AS Provincia FROM GD2C2025.gd_esquema.Maestra
            UNION
            SELECT Profesor_Localidad, Profesor_Provincia FROM GD2C2025.gd_esquema.Maestra
            UNION
            SELECT Alumno_Localidad, Alumno_Provincia FROM GD2C2025.gd_esquema.Maestra
        ) AS l
        JOIN empanadas_indexadas.PROVINCIA pr ON pr.Nombre = TRIM(l.Provincia)
        WHERE l.Nombre IS NOT NULL
          AND LTRIM(RTRIM(l.Nombre)) <> ''
          AND NOT EXISTS (
            SELECT 1 FROM empanadas_indexadas.LOCALIDAD loc WHERE loc.Nombre = TRIM(l.Nombre) AND loc.ID_Provincia = pr.ID_Provincia
        );

        -- 3) Turnos
        INSERT INTO empanadas_indexadas.TURNO (Nombre)
        SELECT DISTINCT TRIM(Curso_Turno) FROM GD2C2025.gd_esquema.Maestra m
        WHERE Curso_Turno IS NOT NULL AND LTRIM(RTRIM(Curso_Turno)) <> ''
          AND NOT EXISTS (SELECT 1 FROM empanadas_indexadas.TURNO t WHERE t.Nombre = TRIM(m.Curso_Turno));

        -- 4) Dias
        INSERT INTO empanadas_indexadas.DIA (Nombre)
        SELECT DISTINCT TRIM(Curso_Dia) FROM GD2C2025.gd_esquema.Maestra m
        WHERE Curso_Dia IS NOT NULL AND LTRIM(RTRIM(Curso_Dia)) <> ''
          AND NOT EXISTS (SELECT 1 FROM empanadas_indexadas.DIA d WHERE d.Nombre = TRIM(m.Curso_Dia));

        -- 5) Categorias
        INSERT INTO empanadas_indexadas.CATEGORIA (Nombre)
        SELECT DISTINCT TRIM(Curso_Categoria) FROM GD2C2025.gd_esquema.Maestra m
        WHERE Curso_Categoria IS NOT NULL AND LTRIM(RTRIM(Curso_Categoria)) <> ''
          AND NOT EXISTS (SELECT 1 FROM empanadas_indexadas.CATEGORIA c WHERE c.Nombre = TRIM(m.Curso_Categoria));

        -- 6) Medio de pago
        INSERT INTO empanadas_indexadas.MEDIO_PAGO (Medio)
        SELECT DISTINCT TRIM(Pago_MedioPago) FROM GD2C2025.gd_esquema.Maestra m
        WHERE Pago_MedioPago IS NOT NULL AND LTRIM(RTRIM(Pago_MedioPago)) <> ''
          AND NOT EXISTS (SELECT 1 FROM empanadas_indexadas.MEDIO_PAGO mp WHERE mp.Medio = TRIM(m.Pago_MedioPago));

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO


--------------------------------------------------------------------------------
-- 5) Migrate tablas core
--------------------------------------------------------------------------------
IF OBJECT_ID('empanadas_indexadas.sp_migrate_core', 'P') IS NOT NULL
    DROP PROCEDURE empanadas_indexadas.sp_migrate_core;
GO

CREATE PROCEDURE empanadas_indexadas.sp_migrate_core
AS
BEGIN
  SET NOCOUNT ON;
  SET XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Instituciones
        INSERT INTO empanadas_indexadas.INSTITUCION (Nombre, RazonSocial, Cuit)
        SELECT DISTINCT TRIM(Institucion_Nombre), TRIM(Institucion_RazonSocial), TRIM(Institucion_Cuit)
        FROM GD2C2025.gd_esquema.Maestra m
        WHERE (Institucion_Nombre IS NOT NULL AND LTRIM(RTRIM(Institucion_Nombre)) <> '')
          AND NOT EXISTS(
            SELECT 1 FROM empanadas_indexadas.INSTITUCION i
            WHERE (i.Cuit IS NOT NULL AND i.Cuit = TRIM(m.Institucion_Cuit))
               OR (i.Nombre = TRIM(m.Institucion_Nombre) AND (i.RazonSocial = TRIM(m.Institucion_RazonSocial) OR i.RazonSocial IS NULL))
        );

        -- Sedes
        INSERT INTO empanadas_indexadas.SEDE (ID_Institucion, Nombre, ID_Localidad, Direccion, Telefono, Mail)
        SELECT DISTINCT i.ID_Institucion, TRIM(m.Sede_Nombre), loc.ID_Localidad, TRIM(m.Sede_Direccion), TRIM(m.Sede_Telefono), TRIM(m.Sede_Mail)
        FROM GD2C2025.gd_esquema.Maestra m
        LEFT JOIN empanadas_indexadas.INSTITUCION i
            ON (i.Cuit IS NOT NULL AND i.Cuit = TRIM(m.Institucion_Cuit)) OR (i.Nombre = TRIM(m.Institucion_Nombre))
        LEFT JOIN empanadas_indexadas.PROVINCIA pr ON pr.Nombre = TRIM(m.Sede_Provincia)
        LEFT JOIN empanadas_indexadas.LOCALIDAD loc ON loc.Nombre = TRIM(m.Sede_Localidad) AND loc.ID_Provincia = pr.ID_Provincia
        WHERE m.Sede_Nombre IS NOT NULL AND LTRIM(RTRIM(m.Sede_Nombre)) <> ''
          AND NOT EXISTS (
            SELECT 1 FROM empanadas_indexadas.SEDE s WHERE s.Nombre = TRIM(m.Sede_Nombre) AND s.ID_Institucion = i.ID_Institucion
        );

        -- Profesores
        INSERT INTO empanadas_indexadas.PROFESOR (Dni, Nombre, Apellido, FechaNacimiento, Mail, Direccion, Telefono, ID_Localidad)
        SELECT DISTINCT TRIM(m.Profesor_Dni), TRIM(m.Profesor_nombre), TRIM(m.Profesor_Apellido), m.Profesor_FechaNacimiento, TRIM(m.Profesor_Mail), TRIM(m.Profesor_Direccion), TRIM(m.Profesor_Telefono), loc.ID_Localidad
        FROM GD2C2025.gd_esquema.Maestra m
        LEFT JOIN empanadas_indexadas.PROVINCIA pr ON pr.Nombre = TRIM(m.Profesor_Provincia)
        LEFT JOIN empanadas_indexadas.LOCALIDAD loc ON loc.Nombre = TRIM(m.Profesor_Localidad) AND loc.ID_Provincia = pr.ID_Provincia
        WHERE (m.Profesor_Dni IS NOT NULL AND LTRIM(RTRIM(m.Profesor_Dni)) <> '')
          AND NOT EXISTS (SELECT 1 FROM empanadas_indexadas.PROFESOR p WHERE p.Dni = TRIM(m.Profesor_Dni));

        -- Alumnos (preservar Legajo si tiene)
        IF EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'empanadas_indexadas.ALUMNO') AND name = 'Legajo_Alumno')
        BEGIN
            SET IDENTITY_INSERT empanadas_indexadas.ALUMNO ON;
            INSERT INTO empanadas_indexadas.ALUMNO (Legajo_Alumno, Dni, Nombre, Apellido, FechaNacimiento, Mail, Direccion, Telefono, ID_Localidad)
            SELECT DISTINCT m.Alumno_Legajo, m.Alumno_Dni, TRIM(m.Alumno_Nombre), TRIM(m.Alumno_Apellido), m.Alumno_FechaNacimiento, TRIM(m.Alumno_Mail), TRIM(m.Alumno_Direccion), TRIM(m.Alumno_Telefono), loc.ID_Localidad
            FROM GD2C2025.gd_esquema.Maestra m
            LEFT JOIN empanadas_indexadas.PROVINCIA pr ON pr.Nombre = TRIM(m.Alumno_Provincia)
            LEFT JOIN empanadas_indexadas.LOCALIDAD loc ON loc.Nombre = TRIM(m.Alumno_Localidad) AND loc.ID_Provincia = pr.ID_Provincia
            WHERE m.Alumno_Legajo IS NOT NULL
              AND NOT EXISTS (SELECT 1 FROM empanadas_indexadas.ALUMNO a WHERE a.Legajo_Alumno = m.Alumno_Legajo);
            SET IDENTITY_INSERT empanadas_indexadas.ALUMNO OFF;
        END
        ELSE
        BEGIN
            INSERT INTO empanadas_indexadas.ALUMNO (Dni, Nombre, Apellido, FechaNacimiento, Mail, Direccion, Telefono, ID_Localidad)
            SELECT DISTINCT m.Alumno_Dni, TRIM(m.Alumno_Nombre), TRIM(m.Alumno_Apellido), m.Alumno_FechaNacimiento, TRIM(m.Alumno_Mail), TRIM(m.Alumno_Direccion), TRIM(m.Alumno_Telefono), loc.ID_Localidad
            FROM GD2C2025.gd_esquema.Maestra m
            LEFT JOIN empanadas_indexadas.PROVINCIA pr ON pr.Nombre = TRIM(m.Alumno_Provincia)
            LEFT JOIN empanadas_indexadas.LOCALIDAD loc ON loc.Nombre = TRIM(m.Alumno_Localidad) AND loc.ID_Provincia = pr.ID_Provincia
            WHERE (m.Alumno_Dni IS NOT NULL OR m.Alumno_Nombre IS NOT NULL)
              AND NOT EXISTS (SELECT 1 FROM empanadas_indexadas.ALUMNO a WHERE a.Dni = m.Alumno_Dni AND m.Alumno_Dni IS NOT NULL);
        END

        -- Cursos (preservar Curso_Codigo si tiene)
        IF EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'empanadas_indexadas.CURSO') AND name = 'Cod_Curso')
        BEGIN
            SET IDENTITY_INSERT empanadas_indexadas.CURSO ON;
            INSERT INTO empanadas_indexadas.CURSO (Cod_Curso, ID_Sede, ID_Profesor, Nombre, Descripcion, ID_Categoria, FechaInicio, FechaFin, DuracionMeses, ID_Dia, ID_Turno, PrecioMensual)
            SELECT DISTINCT m.Curso_Codigo,
                s.ID_Sede,
                p.ID_Profesor,
                TRIM(m.Curso_Nombre),
                TRIM(m.Curso_Descripcion),
                c.ID_Categoria,
                m.Curso_FechaInicio,
                m.Curso_FechaFin,
                m.Curso_DuracionMeses,
                d.ID_Dia,
                t.ID_Turno,
                m.Curso_PrecioMensual
            FROM GD2C2025.gd_esquema.Maestra m
            LEFT JOIN empanadas_indexadas.SEDE s ON s.Nombre = TRIM(m.Sede_Nombre)
            LEFT JOIN empanadas_indexadas.PROFESOR p ON p.Dni = TRIM(m.Profesor_Dni)
            LEFT JOIN empanadas_indexadas.CATEGORIA c ON c.Nombre = TRIM(m.Curso_Categoria)
            LEFT JOIN empanadas_indexadas.DIA d ON d.Nombre = TRIM(m.Curso_Dia)
            LEFT JOIN empanadas_indexadas.TURNO t ON t.Nombre = TRIM(m.Curso_Turno)
            WHERE m.Curso_Codigo IS NOT NULL
              AND NOT EXISTS (SELECT 1 FROM empanadas_indexadas.CURSO cu WHERE cu.Cod_Curso = m.Curso_Codigo);
            SET IDENTITY_INSERT empanadas_indexadas.CURSO OFF;
        END
        ELSE
        BEGIN
            INSERT INTO empanadas_indexadas.CURSO (ID_Sede, ID_Profesor, Nombre, Descripcion, ID_Categoria, FechaInicio, FechaFin, DuracionMeses, ID_Dia, ID_Turno, PrecioMensual)
            SELECT DISTINCT
                s.ID_Sede,
                p.ID_Profesor,
                TRIM(m.Curso_Nombre),
                TRIM(m.Curso_Descripcion),
                c.ID_Categoria,
                m.Curso_FechaInicio,
                m.Curso_FechaFin,
                m.Curso_DuracionMeses,
                d.ID_Dia,
                t.ID_Turno,
                m.Curso_PrecioMensual
            FROM GD2C2025.gd_esquema.Maestra m
            LEFT JOIN empanadas_indexadas.SEDE s ON s.Nombre = TRIM(m.Sede_Nombre)
            LEFT JOIN empanadas_indexadas.PROFESOR p ON p.Dni = TRIM(m.Profesor_Dni)
            LEFT JOIN empanadas_indexadas.CATEGORIA c ON c.Nombre = TRIM(m.Curso_Categoria)
            LEFT JOIN empanadas_indexadas.DIA d ON d.Nombre = TRIM(m.Curso_Dia)
            LEFT JOIN empanadas_indexadas.TURNO t ON t.Nombre = TRIM(m.Curso_Turno)
            WHERE TRIM(ISNULL(m.Curso_Nombre,'')) <> ''
              AND NOT EXISTS (SELECT 1 FROM empanadas_indexadas.CURSO cu WHERE cu.Nombre = TRIM(m.Curso_Nombre) AND cu.ID_Sede = s.ID_Sede);
        END

        -- Modulos
        INSERT INTO empanadas_indexadas.MODULO (ID_Curso, Nombre, Descripcion)
        SELECT DISTINCT cu.Cod_Curso, TRIM(m.Modulo_Nombre), TRIM(m.Modulo_Descripcion)
        FROM GD2C2025.gd_esquema.Maestra m
        LEFT JOIN empanadas_indexadas.CURSO cu ON cu.Cod_Curso = m.Curso_Codigo
        WHERE m.Modulo_Nombre IS NOT NULL AND LTRIM(RTRIM(m.Modulo_Nombre)) <> ''
          AND NOT EXISTS (SELECT 1 FROM empanadas_indexadas.MODULO mo WHERE mo.Nombre = TRIM(m.Modulo_Nombre) AND mo.ID_Curso = cu.Cod_Curso);

        -- Inscripciones (preservar numero si tiene)
        IF EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'empanadas_indexadas.INSCRIPCION') AND name = 'Nro_Inscripcion')
        BEGIN
            SET IDENTITY_INSERT empanadas_indexadas.INSCRIPCION ON;
            INSERT INTO empanadas_indexadas.INSCRIPCION (Nro_Inscripcion, Legajo_Alumno, Cod_Curso, FechaInscripcion, Estado, FechaRespuesta)
            SELECT DISTINCT m.Inscripcion_Numero, m.Alumno_Legajo, m.Curso_Codigo, m.Inscripcion_Fecha, TRIM(m.Inscripcion_Estado), m.Inscripcion_FechaRespuesta
            FROM GD2C2025.gd_esquema.Maestra m
            WHERE m.Inscripcion_Numero IS NOT NULL
              AND NOT EXISTS (SELECT 1 FROM empanadas_indexadas.INSCRIPCION ins WHERE ins.Nro_Inscripcion = m.Inscripcion_Numero);
            SET IDENTITY_INSERT empanadas_indexadas.INSCRIPCION OFF;
        END
        ELSE
        BEGIN
            INSERT INTO empanadas_indexadas.INSCRIPCION (Legajo_Alumno, Cod_Curso, FechaInscripcion, Estado, FechaRespuesta)
            SELECT DISTINCT m.Alumno_Legajo, m.Curso_Codigo, m.Inscripcion_Fecha, TRIM(m.Inscripcion_Estado), m.Inscripcion_FechaRespuesta
            FROM GD2C2025.gd_esquema.Maestra m
            WHERE m.Alumno_Legajo IS NOT NULL AND m.Curso_Codigo IS NOT NULL
              AND NOT EXISTS (SELECT 1 FROM empanadas_indexadas.INSCRIPCION ins WHERE ins.Legajo_Alumno = m.Alumno_Legajo AND ins.Cod_Curso = m.Curso_Codigo);
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

--------------------------------------------------------------------------------
-- 6) Migrate tablas de evaluaciones y finales
--------------------------------------------------------------------------------
IF OBJECT_ID('empanadas_indexadas.sp_migrate_finalize', 'P') IS NOT NULL
    DROP PROCEDURE empanadas_indexadas.sp_migrate_finalize;
GO

CREATE PROCEDURE empanadas_indexadas.sp_migrate_finalize
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Evaluacion curso
        INSERT INTO empanadas_indexadas.EVALUACION_CURSO (Nro_inscripcion, ID_Modulo, FechaEvaluacion, Nota, Presente, Instancia)
        SELECT DISTINCT COALESCE(m.Inscripcion_Numero, ins.Nro_Inscripcion) AS Resolved_Nro,
            mo.ID_Modulo,
            m.Evaluacion_Curso_fechaEvaluacion,
            m.Evaluacion_Curso_Nota,
            m.Evaluacion_Curso_Presente,
            m.Evaluacion_Curso_Instancia
        FROM GD2C2025.gd_esquema.Maestra m
        LEFT JOIN empanadas_indexadas.INSCRIPCION ins ON ins.Legajo_Alumno = m.Alumno_Legajo AND ins.Cod_Curso = m.Curso_Codigo
        LEFT JOIN empanadas_indexadas.MODULO mo ON mo.Nombre = TRIM(m.Modulo_Nombre) AND mo.ID_Curso = m.Curso_Codigo
        WHERE m.Evaluacion_Curso_Nota IS NOT NULL
          AND COALESCE(m.Inscripcion_Numero, ins.Nro_Inscripcion) IS NOT NULL
          AND NOT EXISTS (
              SELECT 1 FROM empanadas_indexadas.EVALUACION_CURSO ec
              WHERE ec.Nro_inscripcion = COALESCE(m.Inscripcion_Numero, ins.Nro_Inscripcion)
                AND ec.FechaEvaluacion = m.Evaluacion_Curso_fechaEvaluacion
                AND ec.Nota = m.Evaluacion_Curso_Nota
          );

        -- Trabajo practico
        INSERT INTO empanadas_indexadas.TRABAJO_PRACTICO (Nro_inscripcion, FechaEvaluacion, Nota)
        SELECT DISTINCT COALESCE(m.Inscripcion_Numero, ins.Nro_Inscripcion) AS Resolved_Nro,
            m.Trabajo_Practico_FechaEvaluacion,
            m.Trabajo_Practico_Nota
        FROM GD2C2025.gd_esquema.Maestra m
        LEFT JOIN empanadas_indexadas.INSCRIPCION ins ON ins.Legajo_Alumno = m.Alumno_Legajo AND ins.Cod_Curso = m.Curso_Codigo
        WHERE m.Trabajo_Practico_Nota IS NOT NULL
          AND COALESCE(m.Inscripcion_Numero, ins.Nro_Inscripcion) IS NOT NULL
          AND NOT EXISTS (
              SELECT 1 FROM empanadas_indexadas.TRABAJO_PRACTICO tp
              WHERE tp.Nro_inscripcion = COALESCE(m.Inscripcion_Numero, ins.Nro_Inscripcion)
                AND tp.Nota = m.Trabajo_Practico_Nota
                AND tp.FechaEvaluacion = m.Trabajo_Practico_FechaEvaluacion
          );

        -- Examen final
        INSERT INTO empanadas_indexadas.EXAMEN_FINAL (Cod_Curso, Fecha, Hora, Descripcion)
        SELECT DISTINCT m.Curso_Codigo, m.Examen_Final_Fecha, TRIM(m.Examen_Final_Hora), TRIM(m.Examen_Final_Descripcion)
        FROM GD2C2025.gd_esquema.Maestra m
        WHERE m.Examen_Final_Fecha IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM empanadas_indexadas.EXAMEN_FINAL ef WHERE ef.Cod_Curso = m.Curso_Codigo AND ef.Fecha = m.Examen_Final_Fecha AND ISNULL(ef.Hora,'') = ISNULL(TRIM(m.Examen_Final_Hora),''));

        -- Inscripcion final
        IF EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'empanadas_indexadas.INSCRIPCION_FINAL') AND name = 'Nro_inscripcionFinal')
        BEGIN
            SET IDENTITY_INSERT empanadas_indexadas.INSCRIPCION_FINAL ON;
            INSERT INTO empanadas_indexadas.INSCRIPCION_FINAL (Nro_inscripcionFinal, Legajo_Alumno, ID_ExamenFinal, FechaInscripcion)
            SELECT DISTINCT m.Inscripcion_Final_Nro, m.Alumno_Legajo, ef.ID_ExamenFinal, m.Inscripcion_Final_Fecha
            FROM GD2C2025.gd_esquema.Maestra m
            LEFT JOIN empanadas_indexadas.EXAMEN_FINAL ef ON ef.Cod_Curso = m.Curso_Codigo AND ef.Fecha = m.Examen_Final_Fecha AND ISNULL(TRIM(ef.Hora),'') = ISNULL(TRIM(m.Examen_Final_Hora),'')
            WHERE m.Inscripcion_Final_Nro IS NOT NULL
              AND NOT EXISTS (SELECT 1 FROM empanadas_indexadas.INSCRIPCION_FINAL inf WHERE inf.Nro_inscripcionFinal = m.Inscripcion_Final_Nro);
            SET IDENTITY_INSERT empanadas_indexadas.INSCRIPCION_FINAL OFF;
        END
        ELSE
        BEGIN
            INSERT INTO empanadas_indexadas.INSCRIPCION_FINAL (Legajo_Alumno, ID_ExamenFinal, FechaInscripcion)
            SELECT DISTINCT m.Alumno_Legajo, ef.ID_ExamenFinal, m.Inscripcion_Final_Fecha
            FROM GD2C2025.gd_esquema.Maestra m
            LEFT JOIN empanadas_indexadas.EXAMEN_FINAL ef ON ef.Cod_Curso = m.Curso_Codigo AND ef.Fecha = m.Examen_Final_Fecha AND ISNULL(TRIM(ef.Hora),'') = ISNULL(TRIM(m.Examen_Final_Hora),'')
            WHERE m.Alumno_Legajo IS NOT NULL
              AND NOT EXISTS (SELECT 1 FROM empanadas_indexadas.INSCRIPCION_FINAL inf WHERE inf.Legajo_Alumno = m.Alumno_Legajo AND inf.ID_ExamenFinal = ef.ID_ExamenFinal);
        END

        -- Evaluacion final
        INSERT INTO empanadas_indexadas.EVALUACION_FINAL (Nro_inscripcionFinal, ID_Profesor, Nota, Presente)
        SELECT DISTINCT COALESCE(m.Inscripcion_Final_Nro, inf.Nro_inscripcionFinal) AS Resolved_Nro,
            p.ID_Profesor,
            m.Evaluacion_Final_Nota,
            m.Evaluacion_Final_Presente
        FROM GD2C2025.gd_esquema.Maestra m
        LEFT JOIN empanadas_indexadas.PROFESOR p ON p.Dni = TRIM(m.Profesor_Dni)
        LEFT JOIN empanadas_indexadas.EXAMEN_FINAL ef ON ef.Cod_Curso = m.Curso_Codigo AND ef.Fecha = m.Examen_Final_Fecha AND ISNULL(TRIM(ef.Hora),'') = ISNULL(TRIM(m.Examen_Final_Hora),'')
        LEFT JOIN empanadas_indexadas.INSCRIPCION_FINAL inf ON inf.Legajo_Alumno = m.Alumno_Legajo AND inf.ID_ExamenFinal = ef.ID_ExamenFinal
        WHERE m.Evaluacion_Final_Nota IS NOT NULL
          AND COALESCE(m.Inscripcion_Final_Nro, inf.Nro_inscripcionFinal) IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM empanadas_indexadas.EVALUACION_FINAL ef2 WHERE ef2.Nro_inscripcionFinal = COALESCE(m.Inscripcion_Final_Nro, inf.Nro_inscripcionFinal) AND ef2.Nota = m.Evaluacion_Final_Nota AND ef2.ID_Profesor = p.ID_Profesor);

        -- Facturas, Detalles y Pagos
        IF EXISTS (SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'empanadas_indexadas.FACTURA') AND name = 'Nro_Factura')
        BEGIN
            SET IDENTITY_INSERT empanadas_indexadas.FACTURA ON;
            INSERT INTO empanadas_indexadas.FACTURA (Nro_Factura, Legajo_Alumno, FechaEmision, FechaVencimiento, Total)
            SELECT DISTINCT m.Factura_Numero, m.Alumno_Legajo, m.Factura_FechaEmision, m.Factura_FechaVencimiento, m.Factura_Total
            FROM GD2C2025.gd_esquema.Maestra m
            WHERE m.Factura_Numero IS NOT NULL
              AND NOT EXISTS (SELECT 1 FROM empanadas_indexadas.FACTURA f WHERE f.Nro_Factura = m.Factura_Numero);
            SET IDENTITY_INSERT empanadas_indexadas.FACTURA OFF;
        END
        ELSE
        BEGIN
            INSERT INTO empanadas_indexadas.FACTURA (Legajo_Alumno, FechaEmision, FechaVencimiento, Total)
            SELECT DISTINCT m.Alumno_Legajo, m.Factura_FechaEmision, m.Factura_FechaVencimiento, m.Factura_Total
            FROM GD2C2025.gd_esquema.Maestra m
            WHERE m.Alumno_Legajo IS NOT NULL
              AND NOT EXISTS (SELECT 1 FROM empanadas_indexadas.FACTURA f WHERE f.Legajo_Alumno = m.Alumno_Legajo AND f.FechaEmision = m.Factura_FechaEmision);
        END

        INSERT INTO empanadas_indexadas.DETALLE_FACTURA (Nro_Factura, Cod_Curso, PeriodoAnio, PeriodoMes, Importe)
        SELECT DISTINCT m.Factura_Numero, m.Curso_Codigo, m.Periodo_Anio, m.Periodo_Mes, m.Detalle_Factura_Importe
        FROM GD2C2025.gd_esquema.Maestra m
        WHERE m.Factura_Numero IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM empanadas_indexadas.DETALLE_FACTURA df WHERE df.Nro_Factura = m.Factura_Numero AND df.Cod_Curso = m.Curso_Codigo AND df.Importe = m.Detalle_Factura_Importe);

        INSERT INTO empanadas_indexadas.PAGO (Nro_Factura, ID_MedioPago, Fecha, Importe)
        SELECT DISTINCT m.Factura_Numero, mp.ID_MedioPago, m.Pago_Fecha, m.Pago_Importe
        FROM GD2C2025.gd_esquema.Maestra m
        LEFT JOIN empanadas_indexadas.MEDIO_PAGO mp ON mp.Medio = TRIM(m.Pago_MedioPago)
        WHERE m.Pago_Importe IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM empanadas_indexadas.PAGO p WHERE p.Nro_Factura = m.Factura_Numero AND p.Importe = m.Pago_Importe AND p.Fecha = m.Pago_Fecha);

        -- Encuestas y respuestas
        INSERT INTO empanadas_indexadas.ENCUESTA (Cod_Curso, FechaRegistro, Observacion)
        SELECT DISTINCT m.Curso_Codigo, m.Encuesta_FechaRegistro, TRIM(m.Encuesta_Observacion)
        FROM GD2C2025.gd_esquema.Maestra m
        WHERE m.Encuesta_FechaRegistro IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM empanadas_indexadas.ENCUESTA e WHERE e.Cod_Curso = m.Curso_Codigo AND e.FechaRegistro = m.Encuesta_FechaRegistro);

        INSERT INTO empanadas_indexadas.PREGUNTA_ENCUESTA (Pregunta)
        SELECT DISTINCT TRIM(q.Pregunta) FROM (
            SELECT Encuesta_Pregunta1 AS Pregunta FROM GD2C2025.gd_esquema.Maestra
            UNION
            SELECT Encuesta_Pregunta2 FROM GD2C2025.gd_esquema.Maestra
            UNION
            SELECT Encuesta_Pregunta3 FROM GD2C2025.gd_esquema.Maestra
            UNION
            SELECT Encuesta_Pregunta4 FROM GD2C2025.gd_esquema.Maestra
        ) q
        WHERE q.Pregunta IS NOT NULL AND LTRIM(RTRIM(q.Pregunta)) <> ''
          AND NOT EXISTS (SELECT 1 FROM empanadas_indexadas.PREGUNTA_ENCUESTA pe WHERE pe.Pregunta = TRIM(q.Pregunta));

        -- Respuestas (1..4)
        INSERT INTO empanadas_indexadas.RESPUESTA_ENCUESTA (ID_Encuesta, ID_PreguntaEncuesta, Nota)
        SELECT e.ID_Encuesta, pe.ID_PreguntaEncuesta, m.Encuesta_Nota1
        FROM GD2C2025.gd_esquema.Maestra m
        JOIN empanadas_indexadas.ENCUESTA e ON e.Cod_Curso = m.Curso_Codigo AND e.FechaRegistro = m.Encuesta_FechaRegistro
        JOIN empanadas_indexadas.PREGUNTA_ENCUESTA pe ON pe.Pregunta = TRIM(m.Encuesta_Pregunta1)
        WHERE m.Encuesta_Pregunta1 IS NOT NULL AND m.Encuesta_Nota1 IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM empanadas_indexadas.RESPUESTA_ENCUESTA r WHERE r.ID_Encuesta = e.ID_Encuesta AND r.ID_PreguntaEncuesta = pe.ID_PreguntaEncuesta AND r.Nota = m.Encuesta_Nota1);

        INSERT INTO empanadas_indexadas.RESPUESTA_ENCUESTA (ID_Encuesta, ID_PreguntaEncuesta, Nota)
        SELECT e.ID_Encuesta, pe.ID_PreguntaEncuesta, m.Encuesta_Nota2
        FROM GD2C2025.gd_esquema.Maestra m
        JOIN empanadas_indexadas.ENCUESTA e ON e.Cod_Curso = m.Curso_Codigo AND e.FechaRegistro = m.Encuesta_FechaRegistro
        JOIN empanadas_indexadas.PREGUNTA_ENCUESTA pe ON pe.Pregunta = TRIM(m.Encuesta_Pregunta2)
        WHERE m.Encuesta_Pregunta2 IS NOT NULL AND m.Encuesta_Nota2 IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM empanadas_indexadas.RESPUESTA_ENCUESTA r WHERE r.ID_Encuesta = e.ID_Encuesta AND r.ID_PreguntaEncuesta = pe.ID_PreguntaEncuesta AND r.Nota = m.Encuesta_Nota2);

        INSERT INTO empanadas_indexadas.RESPUESTA_ENCUESTA (ID_Encuesta, ID_PreguntaEncuesta, Nota)
        SELECT e.ID_Encuesta, pe.ID_PreguntaEncuesta, m.Encuesta_Nota3
        FROM GD2C2025.gd_esquema.Maestra m
        JOIN empanadas_indexadas.ENCUESTA e ON e.Cod_Curso = m.Curso_Codigo AND e.FechaRegistro = m.Encuesta_FechaRegistro
        JOIN empanadas_indexadas.PREGUNTA_ENCUESTA pe ON pe.Pregunta = TRIM(m.Encuesta_Pregunta3)
        WHERE m.Encuesta_Pregunta3 IS NOT NULL AND m.Encuesta_Nota3 IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM empanadas_indexadas.RESPUESTA_ENCUESTA r WHERE r.ID_Encuesta = e.ID_Encuesta AND r.ID_PreguntaEncuesta = pe.ID_PreguntaEncuesta AND r.Nota = m.Encuesta_Nota3);

        INSERT INTO empanadas_indexadas.RESPUESTA_ENCUESTA (ID_Encuesta, ID_PreguntaEncuesta, Nota)
        SELECT e.ID_Encuesta, pe.ID_PreguntaEncuesta, m.Encuesta_Nota4
        FROM GD2C2025.gd_esquema.Maestra m
        JOIN empanadas_indexadas.ENCUESTA e ON e.Cod_Curso = m.Curso_Codigo AND e.FechaRegistro = m.Encuesta_FechaRegistro
        JOIN empanadas_indexadas.PREGUNTA_ENCUESTA pe ON pe.Pregunta = TRIM(m.Encuesta_Pregunta4)
        WHERE m.Encuesta_Pregunta4 IS NOT NULL AND m.Encuesta_Nota4 IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM empanadas_indexadas.RESPUESTA_ENCUESTA r WHERE r.ID_Encuesta = e.ID_Encuesta AND r.ID_PreguntaEncuesta = pe.ID_PreguntaEncuesta AND r.Nota = m.Encuesta_Nota4);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO


--------------------------------------------------------------------------------
-- 7) Migrate todo
--------------------------------------------------------------------------------
IF OBJECT_ID('empanadas_indexadas.sp_migrate_all', 'P') IS NOT NULL
    DROP PROCEDURE empanadas_indexadas.sp_migrate_all;
GO

CREATE PROCEDURE empanadas_indexadas.sp_migrate_all
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        EXEC empanadas_indexadas.sp_migrate_lookups;
        EXEC empanadas_indexadas.sp_migrate_core;
        EXEC empanadas_indexadas.sp_migrate_finalize;
    END TRY
    BEGIN CATCH
        DECLARE @errMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Migration failed: %s', 16, 1, @errMsg);
        THROW;
    END CATCH
END;
GO


-- ============================================================================
-- EJECUTAR MIGRACIÓN
-- ============================================================================

EXEC empanadas_indexadas.sp_migrate_all;

-- ============================================================================

-- CONSULTAS DE VERIFICACION POST-MIGRACION

SELECT 'PROVINCIA' AS Tabla, COUNT(*) AS Filas FROM empanadas_indexadas.PROVINCIA;
SELECT 'LOCALIDAD' AS Tabla, COUNT(*) AS Filas FROM empanadas_indexadas.LOCALIDAD;
SELECT 'TURNO' AS Tabla, COUNT(*) AS Filas FROM empanadas_indexadas.TURNO;
SELECT 'DIA' AS Tabla, COUNT(*) AS Filas FROM empanadas_indexadas.DIA;
SELECT 'CATEGORIA' AS Tabla, COUNT(*) AS Filas FROM empanadas_indexadas.CATEGORIA;
SELECT 'MEDIO_PAGO' AS Tabla, COUNT(*) AS Filas FROM empanadas_indexadas.MEDIO_PAGO;
SELECT 'INSTITUCION' AS Tabla, COUNT(*) AS Filas FROM empanadas_indexadas.INSTITUCION;
SELECT 'SEDE' AS Tabla, COUNT(*) AS Filas FROM empanadas_indexadas.SEDE;
SELECT 'PROFESOR' AS Tabla, COUNT(*) AS Filas FROM empanadas_indexadas.PROFESOR;
SELECT 'ALUMNO' AS Tabla, COUNT(*) AS Filas FROM empanadas_indexadas.ALUMNO;
SELECT 'CURSO' AS Tabla, COUNT(*) AS Filas FROM empanadas_indexadas.CURSO;
SELECT 'MODULO' AS Tabla, COUNT(*) AS Filas FROM empanadas_indexadas.MODULO;
SELECT 'INSCRIPCION' AS Tabla, COUNT(*) AS Filas FROM empanadas_indexadas.INSCRIPCION;
SELECT 'EVALUACION_CURSO' AS Tabla, COUNT(*) AS Filas FROM empanadas_indexadas.EVALUACION_CURSO;
SELECT 'TRABAJO_PRACTICO' AS Tabla, COUNT(*) AS Filas FROM empanadas_indexadas.TRABAJO_PRACTICO;
SELECT 'EXAMEN_FINAL' AS Tabla, COUNT(*) AS Filas FROM empanadas_indexadas.EXAMEN_FINAL;
SELECT 'INSCRIPCION_FINAL' AS Tabla, COUNT(*) AS Filas FROM empanadas_indexadas.INSCRIPCION_FINAL;
SELECT 'EVALUACION_FINAL' AS Tabla, COUNT(*) AS Filas FROM empanadas_indexadas.EVALUACION_FINAL;
SELECT 'FACTURA' AS Tabla, COUNT(*) AS Filas FROM empanadas_indexadas.FACTURA;
SELECT 'DETALLE_FACTURA' AS Tabla, COUNT(*) AS Filas FROM empanadas_indexadas.DETALLE_FACTURA;
SELECT 'PAGO' AS Tabla, COUNT(*) AS Filas FROM empanadas_indexadas.PAGO;
SELECT 'ENCUESTA' AS Tabla, COUNT(*) AS Filas FROM empanadas_indexadas.ENCUESTA;
SELECT 'PREGUNTA_ENCUESTA' AS Tabla, COUNT(*) AS Filas FROM empanadas_indexadas.PREGUNTA_ENCUESTA;
SELECT 'RESPUESTA_ENCUESTA' AS Tabla, COUNT(*) AS Filas FROM empanadas_indexadas.RESPUESTA_ENCUESTA;

-- 2) Evaluaciones de curso sin Nro_inscripcion
SELECT m.*
FROM GD2C2025.gd_esquema.Maestra m
LEFT JOIN empanadas_indexadas.INSCRIPCION ins ON ins.Legajo_Alumno = m.Alumno_Legajo AND ins.Cod_Curso = m.Curso_Codigo
WHERE m.Evaluacion_Curso_Nota IS NOT NULL
  AND COALESCE(m.Inscripcion_Numero, ins.Nro_Inscripcion) IS NULL;

-- 3) Trabajos prácticos sin Nro_inscripcion
SELECT m.*
FROM GD2C2025.gd_esquema.Maestra m
LEFT JOIN empanadas_indexadas.INSCRIPCION ins ON ins.Legajo_Alumno = m.Alumno_Legajo AND ins.Cod_Curso = m.Curso_Codigo
WHERE m.Trabajo_Practico_Nota IS NOT NULL
  AND COALESCE(m.Inscripcion_Numero, ins.Nro_Inscripcion) IS NULL;

-- 4) Evaluaciones finales sin Nro_inscripcionFinal
SELECT m.*
FROM GD2C2025.gd_esquema.Maestra m
LEFT JOIN empanadas_indexadas.EXAMEN_FINAL ef ON ef.Cod_Curso = m.Curso_Codigo AND ef.Fecha = m.Examen_Final_Fecha AND ISNULL(TRIM(ef.Hora),'') = ISNULL(TRIM(m.Examen_Final_Hora),'')
LEFT JOIN empanadas_indexadas.INSCRIPCION_FINAL inf ON inf.Legajo_Alumno = m.Alumno_Legajo AND inf.ID_ExamenFinal = ef.ID_ExamenFinal
WHERE m.Evaluacion_Final_Nota IS NOT NULL
  AND COALESCE(m.Inscripcion_Final_Nro, inf.Nro_inscripcionFinal) IS NULL;

-- 5) Inscripciones esperadas en INSCRIPCION que no fueron creadas
SELECT DISTINCT m.Alumno_Legajo, m.Curso_Codigo
FROM GD2C2025.gd_esquema.Maestra m
LEFT JOIN empanadas_indexadas.INSCRIPCION ins ON ins.Legajo_Alumno = m.Alumno_Legajo AND ins.Cod_Curso = m.Curso_Codigo
WHERE m.Alumno_Legajo IS NOT NULL AND m.Curso_Codigo IS NOT NULL
  AND ins.Nro_Inscripcion IS NULL;

-- 6) Cursos referenciados en Maestra que no existen en empanadas_indexadas.CURSO
SELECT DISTINCT m.Curso_Codigo, m.Curso_Nombre
FROM GD2C2025.gd_esquema.Maestra m
LEFT JOIN empanadas_indexadas.CURSO c ON c.Cod_Curso = m.Curso_Codigo OR (c.Nombre = TRIM(m.Curso_Nombre))
WHERE TRIM(ISNULL(m.Curso_Nombre,'')) <> '' AND (c.Cod_Curso IS NULL);

-- 7) Profesores en Maestra sin match en empanadas_indexadas.PROFESOR (por DNI)
SELECT DISTINCT m.Profesor_Dni, m.Profesor_nombre, m.Profesor_Apellido
FROM GD2C2025.gd_esquema.Maestra m
LEFT JOIN empanadas_indexadas.PROFESOR p ON p.Dni = TRIM(m.Profesor_Dni)
WHERE (m.Profesor_Dni IS NOT NULL AND LTRIM(RTRIM(m.Profesor_Dni)) <> '') AND p.ID_Profesor IS NULL;

-- 8) Alumnos en Maestra sin match en empanadas_indexadas.ALUMNO (por Legajo o DNI)
SELECT DISTINCT m.Alumno_Legajo, m.Alumno_Dni, m.Alumno_Nombre, m.Alumno_Apellido
FROM GD2C2025.gd_esquema.Maestra m
LEFT JOIN empanadas_indexadas.ALUMNO a ON a.Legajo_Alumno = m.Alumno_Legajo OR (a.Dni = m.Alumno_Dni AND m.Alumno_Dni IS NOT NULL)
WHERE m.Alumno_Legajo IS NOT NULL OR m.Alumno_Dni IS NOT NULL;
