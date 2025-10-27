-- Script de migración desde GD2C2025.gd_esquema.Maestra hacia empanadas_indexadas
-- Ejecutar en SQL Server. Asegurate de tener permisos de INSERT/UPDATE en la DB.
-- Este script intenta poblar las tablas normalizadas a partir de la tabla 'Maestra'.
-- No borra datos existentes: usa checks NOT EXISTS para evitar duplicados.

SET XACT_ABORT ON;
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

-- 2) Localidades (requiere provincia existente)
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

-- 7) Instituciones
INSERT INTO empanadas_indexadas.INSTITUCION (Nombre, RazonSocial, Cuit)
SELECT DISTINCT TRIM(Institucion_Nombre), TRIM(Institucion_RazonSocial), TRIM(Institucion_Cuit)
FROM GD2C2025.gd_esquema.Maestra m
WHERE (Institucion_Nombre IS NOT NULL AND LTRIM(RTRIM(Institucion_Nombre)) <> '')
  AND NOT EXISTS(
    SELECT 1 FROM empanadas_indexadas.INSTITUCION i
    WHERE (i.Cuit IS NOT NULL AND i.Cuit = TRIM(m.Institucion_Cuit))
       OR (i.Nombre = TRIM(m.Institucion_Nombre) AND (i.RazonSocial = TRIM(m.Institucion_RazonSocial) OR i.RazonSocial IS NULL))
);

-- 8) Sedes (mapear institucion y localidad)
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

-- 9) Profesores (usar Dni como natural key si existe)
INSERT INTO empanadas_indexadas.PROFESOR (Dni, Nombre, Apellido, FechaNacimiento, Mail, Direccion, Telefono, ID_Localidad)
SELECT DISTINCT TRIM(m.Profesor_Dni), TRIM(m.Profesor_nombre), TRIM(m.Profesor_Apellido), m.Profesor_FechaNacimiento, TRIM(m.Profesor_Mail), TRIM(m.Profesor_Direccion), TRIM(m.Profesor_Telefono), loc.ID_Localidad
FROM GD2C2025.gd_esquema.Maestra m
LEFT JOIN empanadas_indexadas.PROVINCIA pr ON pr.Nombre = TRIM(m.Profesor_Provincia)
LEFT JOIN empanadas_indexadas.LOCALIDAD loc ON loc.Nombre = TRIM(m.Profesor_Localidad) AND loc.ID_Provincia = pr.ID_Provincia
WHERE (m.Profesor_Dni IS NOT NULL AND LTRIM(RTRIM(m.Profesor_Dni)) <> '')
  AND NOT EXISTS (
    SELECT 1 FROM empanadas_indexadas.PROFESOR p WHERE p.Dni = TRIM(m.Profesor_Dni)
);

-- 10) Alumnos (preservar Legajo si está presente)
-- Activar IDENTITY_INSERT para mantener el Legajo original si existe
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

-- 11) Cursos (preservar Curso_Codigo si existe)
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

-- 12) Modulos
INSERT INTO empanadas_indexadas.MODULO (ID_Curso, Nombre, Descripcion)
SELECT DISTINCT cu.Cod_Curso, TRIM(m.Modulo_Nombre), TRIM(m.Modulo_Descripcion)
FROM GD2C2025.gd_esquema.Maestra m
LEFT JOIN empanadas_indexadas.CURSO cu ON cu.Cod_Curso = m.Curso_Codigo
WHERE m.Modulo_Nombre IS NOT NULL AND LTRIM(RTRIM(m.Modulo_Nombre)) <> ''
  AND NOT EXISTS (SELECT 1 FROM empanadas_indexadas.MODULO mo WHERE mo.Nombre = TRIM(m.Modulo_Nombre) AND mo.ID_Curso = cu.Cod_Curso);

-- 13) Inscripciones (preservar numero si existe)
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

-- 14) Evaluacion curso
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
  -- resolver Nro_inscripcion: usar la que trae Maestra o buscarla por legajo+curso
  AND COALESCE(m.Inscripcion_Numero, ins.Nro_Inscripcion) IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM empanadas_indexadas.EVALUACION_CURSO ec
      WHERE ec.Nro_inscripcion = COALESCE(m.Inscripcion_Numero, ins.Nro_Inscripcion)
        AND ec.FechaEvaluacion = m.Evaluacion_Curso_fechaEvaluacion
        AND ec.Nota = m.Evaluacion_Curso_Nota
  );

-- 15) Trabajo practico
INSERT INTO empanadas_indexadas.TRABAJO_PRACTICO (Nro_inscripcion, FechaEvaluacion, Nota)
SELECT DISTINCT COALESCE(m.Inscripcion_Numero, ins.Nro_Inscripcion) AS Resolved_Nro,
    m.Trabajo_Practico_FechaEvaluacion,
    m.Trabajo_Practico_Nota
FROM GD2C2025.gd_esquema.Maestra m
LEFT JOIN empanadas_indexadas.INSCRIPCION ins ON ins.Legajo_Alumno = m.Alumno_Legajo AND ins.Cod_Curso = m.Curso_Codigo
WHERE m.Trabajo_Practico_Nota IS NOT NULL
  -- resolver Nro_inscripcion: usar la que trae Maestra o buscarla por legajo+curso
  AND COALESCE(m.Inscripcion_Numero, ins.Nro_Inscripcion) IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM empanadas_indexadas.TRABAJO_PRACTICO tp
      WHERE tp.Nro_inscripcion = COALESCE(m.Inscripcion_Numero, ins.Nro_Inscripcion)
        AND tp.Nota = m.Trabajo_Practico_Nota
        AND tp.FechaEvaluacion = m.Trabajo_Practico_FechaEvaluacion
  );

-- 16) Examen final (crear por curso+fecha+hora+descripcion)
INSERT INTO empanadas_indexadas.EXAMEN_FINAL (Cod_Curso, Fecha, Hora, Descripcion)
SELECT DISTINCT m.Curso_Codigo, m.Examen_Final_Fecha, TRIM(m.Examen_Final_Hora), TRIM(m.Examen_Final_Descripcion)
FROM GD2C2025.gd_esquema.Maestra m
WHERE m.Examen_Final_Fecha IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM empanadas_indexadas.EXAMEN_FINAL ef WHERE ef.Cod_Curso = m.Curso_Codigo AND ef.Fecha = m.Examen_Final_Fecha AND ISNULL(ef.Hora,'') = ISNULL(TRIM(m.Examen_Final_Hora),''));

-- 17) Inscripcion final (preservar nro si existe)
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

-- 18) Evaluacion final
INSERT INTO empanadas_indexadas.EVALUACION_FINAL (Nro_inscripcionFinal, ID_Profesor, Nota, Presente)
SELECT DISTINCT COALESCE(m.Inscripcion_Final_Nro, inf.Nro_inscripcionFinal) AS Resolved_Nro,
    p.ID_Profesor,
    m.Evaluacion_Final_Nota,
    m.Evaluacion_Final_Presente
FROM GD2C2025.gd_esquema.Maestra m
LEFT JOIN empanadas_indexadas.PROFESOR p ON p.Dni = TRIM(m.Profesor_Dni)
-- intentar resolver el examen final al que pertenece la inscripción final
LEFT JOIN empanadas_indexadas.EXAMEN_FINAL ef ON ef.Cod_Curso = m.Curso_Codigo AND ef.Fecha = m.Examen_Final_Fecha AND ISNULL(TRIM(ef.Hora),'') = ISNULL(TRIM(m.Examen_Final_Hora),'')
-- buscar la INSCRIPCION_FINAL por legajo+examen
LEFT JOIN empanadas_indexadas.INSCRIPCION_FINAL inf ON inf.Legajo_Alumno = m.Alumno_Legajo AND inf.ID_ExamenFinal = ef.ID_ExamenFinal
WHERE m.Evaluacion_Final_Nota IS NOT NULL
  -- resolver Nro_inscripcionFinal: usar la que trae Maestra o buscarla por legajo+examen
  AND COALESCE(m.Inscripcion_Final_Nro, inf.Nro_inscripcionFinal) IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM empanadas_indexadas.EVALUACION_FINAL ef2
      WHERE ef2.Nro_inscripcionFinal = COALESCE(m.Inscripcion_Final_Nro, inf.Nro_inscripcionFinal)
        AND ef2.Nota = m.Evaluacion_Final_Nota
        AND ef2.ID_Profesor = p.ID_Profesor
  );

-- 19) Facturas (preservar Nro si existe)
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

-- 20) Detalle factura
INSERT INTO empanadas_indexadas.DETALLE_FACTURA (Nro_Factura, Cod_Curso, PeriodoAnio, PeriodoMes, Importe)
SELECT DISTINCT m.Factura_Numero, m.Curso_Codigo, m.Periodo_Anio, m.Periodo_Mes, m.Detalle_Factura_Importe
FROM GD2C2025.gd_esquema.Maestra m
WHERE m.Factura_Numero IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM empanadas_indexadas.DETALLE_FACTURA df WHERE df.Nro_Factura = m.Factura_Numero AND df.Cod_Curso = m.Curso_Codigo AND df.Importe = m.Detalle_Factura_Importe);

-- 21) Pagos
INSERT INTO empanadas_indexadas.PAGO (Nro_Factura, ID_MedioPago, Fecha, Importe)
SELECT DISTINCT m.Factura_Numero, mp.ID_MedioPago, m.Pago_Fecha, m.Pago_Importe
FROM GD2C2025.gd_esquema.Maestra m
LEFT JOIN empanadas_indexadas.MEDIO_PAGO mp ON mp.Medio = TRIM(m.Pago_MedioPago)
WHERE m.Pago_Importe IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM empanadas_indexadas.PAGO p WHERE p.Nro_Factura = m.Factura_Numero AND p.Importe = m.Pago_Importe AND p.Fecha = m.Pago_Fecha);

-- 22) Encuestas y preguntas/respuestas
-- Insertar encuestas (por curso + fecha)
INSERT INTO empanadas_indexadas.ENCUESTA (Cod_Curso, FechaRegistro, Observacion)
SELECT DISTINCT m.Curso_Codigo, m.Encuesta_FechaRegistro, TRIM(m.Encuesta_Observacion)
FROM GD2C2025.gd_esquema.Maestra m
WHERE m.Encuesta_FechaRegistro IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM empanadas_indexadas.ENCUESTA e WHERE e.Cod_Curso = m.Curso_Codigo AND e.FechaRegistro = m.Encuesta_FechaRegistro);

-- Preguntas (se usan preguntas textuales; evitamos duplicados)
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

-- RESPUESTAS (hasta 4 por fila)
-- Para cada encuesta creada, insertar respuestas si existen
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
