-- Script DROP/CREATE para gd_esquema
-- Ejecutar en SQL Server (SSMS o sqlcmd). Ajusta "USE <DB>" si corresponde.

-- Script DROP/CREATE para empanadas_indexadas
-- Ejecutar en SQL Server (SSMS o sqlcmd). Ajusta "USE <DB>" si corresponde.

-- USE GD2C2025;

/*
  Estrategia:
  1) DROP TABLE IF EXISTS en orden inverso a dependencias para evitar errores por FKs.
  2) Crear schema si no existe.
  3) CREATE TABLE en orden que satisface FKs.
*/

--------------------------------------------------------------------------------
-- 1) Drops (orden inverso a dependencias)
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
-- 3) CREATEs (orden seguro)
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

-- Fin del script

