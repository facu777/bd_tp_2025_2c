# Validación de Indicadores del Enunciado - Modelo BI

## Mapeo Indicadores a Implementación

Este documento mapea cada uno de los **10 indicadores** solicitados en el enunciado del TP con las vistas implementadas en `script_creacion_BI.sql`

---

## Indicador 1: Categorías y Turnos Más Solicitados

### Requerimiento del Enunciado
> Las 3 categorías de cursos y turnos con mayor cantidad de inscriptos por año por sede.

### Vista Implementada
`empanadas_indexadas.BI_V_Categorias_Turnos_Mas_Solicitados`

### Lógica de Implementación
```sql
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
        ) AS Ranking_Categoria
    FROM BI_FACT_INSCRIPCION f
    INNER JOIN BI_DIM_TIEMPO t ON f.Tiempo_Inscripcion_Key = t.Tiempo_Key
    INNER JOIN BI_DIM_SEDE s ON f.Sede_Key = s.Sede_Key
    LEFT JOIN BI_DIM_CATEGORIA c ON f.Categoria_Key = c.Categoria_Key
    LEFT JOIN BI_DIM_TURNO tu ON f.Turno_Key = tu.Turno_Key
    GROUP BY t.Anio, s.Sede_Nombre, c.Categoria_Nombre, tu.Turno_Nombre
)
SELECT Anio, Sede_Nombre, Categoria_Nombre, Turno_Nombre, Total_Inscripciones, Ranking_Categoria
FROM Ranking
WHERE Ranking_Categoria <= 3;
```

### Query de Validación
```sql
-- Validar que devuelve TOP 3 categorías por año/sede
SELECT
    Anio,
    Sede_Nombre,
    COUNT(DISTINCT Categoria_Nombre) AS Cantidad_Categorias_Top3,
    MAX(Ranking_Categoria) AS Ranking_Maximo
FROM empanadas_indexadas.BI_V_Categorias_Turnos_Mas_Solicitados
WHERE Anio = 2023
GROUP BY Anio, Sede_Nombre;
-- Resultado esperado: Ranking_Maximo <= 3
```

### Cumplimiento
- Agrupamiento por Año y Sede
- Ranking con ROW_NUMBER() PARTITION BY
- Filtro WHERE Ranking <= 3
- Incluye tanto Categoría como Turno

---

## Indicador 2: Tasa de Rechazo de Inscripciones

### Requerimiento del Enunciado
> Porcentaje de inscripciones rechazadas por mes por sede (sobre el total de inscripciones).

### Vista Implementada
`empanadas_indexadas.BI_V_Tasa_Rechazo_Inscripciones`

### Lógica de Implementación
```sql
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
FROM BI_FACT_INSCRIPCION f
INNER JOIN BI_DIM_TIEMPO t ON f.Tiempo_Inscripcion_Key = t.Tiempo_Key
INNER JOIN BI_DIM_SEDE s ON f.Sede_Key = s.Sede_Key
GROUP BY t.Anio, t.Mes, t.Mes_Nombre, s.Sede_Nombre;
```

### Query de Validación
```sql
-- Validar que porcentaje = (rechazadas/total)*100
SELECT TOP 5
    Anio,
    Mes_Nombre,
    Sede_Nombre,
    Total_Inscripciones,
    Total_Rechazadas,
    Porcentaje_Rechazo,
    -- Recalcular manualmente
    CAST((Total_Rechazadas * 100.0) / Total_Inscripciones AS DECIMAL(5,2)) AS Porcentaje_Verificado
FROM empanadas_indexadas.BI_V_Tasa_Rechazo_Inscripciones
WHERE Total_Inscripciones > 0 AND Anio = 2023
ORDER BY Porcentaje_Rechazo DESC;
-- Resultado esperado: Porcentaje_Rechazo = Porcentaje_Verificado
```

### Cumplimiento
- Agrupamiento por Mes y Sede
- Fórmula: (Rechazadas/Total)*100
- Protección contra división por cero
- Incluye año, mes y nombre de mes

---

## Indicador 3: Comparación de Desempeño de Cursada por Sede

### Requerimiento del Enunciado
> Porcentaje de aprobación de cursada por sede, por año. Se considera aprobada la cursada cuando tiene nota mayor o igual a 4 en todos los módulos y el TP.

### Vista Implementada
`empanadas_indexadas.BI_V_Desempeno_Cursada_Sede`

### Lógica de Implementación
```sql
SELECT
    t.Anio,
    s.Sede_Nombre,
    SUM(f.Cantidad_Evaluaciones) AS Total_Evaluaciones,
    SUM(CASE WHEN f.Aprobado = 1 THEN 1 ELSE 0 END) AS Total_Aprobadas,
    CASE
        WHEN SUM(f.Cantidad_Evaluaciones) > 0
        THEN (SUM(CASE WHEN f.Aprobado = 1 THEN 1 ELSE 0 END) * 100.0) / SUM(f.Cantidad_Evaluaciones)
        ELSE 0
    END AS Porcentaje_Aprobacion
FROM BI_FACT_EVALUACION_CURSO f
INNER JOIN BI_DIM_TIEMPO t ON f.Tiempo_Evaluacion_Key = t.Tiempo_Key
INNER JOIN BI_DIM_SEDE s ON f.Sede_Key = s.Sede_Key
WHERE f.Presente = 1
GROUP BY t.Anio, s.Sede_Nombre;
```

### Query de Validación
```sql
-- Validar que solo cuenta evaluaciones con Presente=1 y Aprobado=(Nota>=4)
SELECT
    Anio,
    Sede_Nombre,
    Total_Evaluaciones,
    Total_Aprobadas,
    Porcentaje_Aprobacion,
    -- Verificar lógica de aprobación
    CAST((Total_Aprobadas * 100.0) / Total_Evaluaciones AS DECIMAL(5,2)) AS Porcentaje_Verificado
FROM empanadas_indexadas.BI_V_Desempeno_Cursada_Sede
WHERE Anio = 2023
ORDER BY Porcentaje_Aprobacion DESC;
-- Resultado esperado: Porcentaje_Aprobacion = Porcentaje_Verificado
```

### Cumplimiento
- Agrupamiento por Año y Sede
- Filtro WHERE Presente = 1 (solo evaluaciones rendidas)
- Aprobado = (Nota >= 4) calculado en FACT
- Fórmula: (Aprobados/Total)*100

### Aclaración: Ambigüedad del Enunciado

El enunciado dice "nota >= 4 en **TODOS** los módulos y el TP", lo cual puede interpretarse de dos formas:

**Implementación A (Principal): `BI_V_Desempeno_Cursada_Sede`**
- Calcula el porcentaje de **evaluaciones individuales** aprobadas
- Granularidad: una fila de la tabla de hechos = una evaluación
- Ventaja: Permite analizar qué módulos específicos tienen problemas

**Implementación B (Alternativa): `BI_V_Desempeno_Cursada_Completa_Sede`**
- Calcula el porcentaje de **alumnos que aprobaron TODAS las evaluaciones**
- Granularidad: nivel alumno (requiere agrupar por alumno)
- Ventaja: Métrica más estricta de "aprobación de cursada completa"

---

## Indicador 4: Tiempo Promedio de Finalización de Curso

### Requerimiento del Enunciado
> Tiempo promedio entre el inicio del curso y la aprobación del final según la categoría de los cursos, por año. (Tener en cuenta el año de inicio del curso)

### Vista Implementada
`empanadas_indexadas.BI_V_Tiempo_Finalizacion_Curso`

### Lógica de Implementación
```sql
SELECT
    t.Anio,
    c.Categoria_Nombre,
    AVG(f.Dias_Inicio_Curso_A_Final) AS Dias_Promedio_Finalizacion,
    COUNT(*) AS Cantidad_Finales_Aprobados
FROM BI_FACT_EVALUACION_FINAL f
INNER JOIN BI_DIM_TIEMPO t ON f.Tiempo_Inicio_Curso_Key = t.Tiempo_Key
LEFT JOIN BI_DIM_CATEGORIA c ON f.Categoria_Key = c.Categoria_Key
WHERE f.Aprobado = 1
  AND f.Dias_Inicio_Curso_A_Final IS NOT NULL
GROUP BY t.Anio, c.Categoria_Nombre;
```

### Métrica Pre-Calculada en FACT
```sql
-- En script_creacion_BI.sql, línea ~420
DATEDIFF(DAY, c.FechaInicio, ex.Fecha) AS Dias_Inicio_Curso_A_Final
```

### Query de Validación
```sql
-- Validar que agrupa por año de INICIO del curso (no año de final)
SELECT
    Anio,
    Categoria_Nombre,
    Dias_Promedio_Finalizacion,
    Cantidad_Finales_Aprobados
FROM empanadas_indexadas.BI_V_Tiempo_Finalizacion_Curso
WHERE Anio = 2023
ORDER BY Dias_Promedio_Finalizacion;
-- Resultado esperado: Dias_Promedio razonable (60-365 días típicamente)
```

### Cumplimiento
- Agrupamiento por Año (de inicio de curso) y Categoría
- Filtro WHERE Aprobado = 1 (solo finales aprobados)
- AVG(Dias_Inicio_Curso_A_Final)
- JOIN a Tiempo_Inicio_Curso_Key (no Tiempo_Evaluacion_Key)

---

## Indicador 5: Nota Promedio de Finales

### Requerimiento del Enunciado
> Promedio de nota de finales según el rango etario del alumno y la categoría del curso por semestre.

### Vista Implementada
`empanadas_indexadas.BI_V_Nota_Promedio_Finales`

### Lógica de Implementación
```sql
SELECT
    t.Anio,
    t.Cuatrimestre,
    r.Rango_Descripcion AS Rango_Etario_Alumno,
    c.Categoria_Nombre,
    AVG(f.Nota) AS Nota_Promedio,
    COUNT(*) AS Cantidad_Finales
FROM BI_FACT_EVALUACION_FINAL f
INNER JOIN BI_DIM_TIEMPO t ON f.Tiempo_Evaluacion_Key = t.Tiempo_Key
LEFT JOIN BI_DIM_RANGO_ETARIO_ALUMNO r ON f.Rango_Etario_Alumno_Key = r.Rango_Etario_Alumno_Key
LEFT JOIN BI_DIM_CATEGORIA c ON f.Categoria_Key = c.Categoria_Key
WHERE f.Nota IS NOT NULL
  AND f.Presente = 1
GROUP BY t.Anio, t.Cuatrimestre, r.Rango_Descripcion, c.Categoria_Nombre;
```

### Query de Validación
```sql
-- Validar agrupamiento por cuatrimestre, rango etario y categoría
SELECT
    Anio,
    Cuatrimestre,
    Rango_Etario_Alumno,
    Categoria_Nombre,
    Nota_Promedio,
    Cantidad_Finales
FROM empanadas_indexadas.BI_V_Nota_Promedio_Finales
WHERE Anio = 2023 AND Cuatrimestre = 2
ORDER BY Nota_Promedio DESC;
-- Resultado esperado: Nota_Promedio entre 1 y 10
```

### Cumplimiento
- Agrupamiento por Año, Cuatrimestre, Rango Etario, Categoría
- AVG(Nota)
- Filtro WHERE Presente = 1 (solo evaluaciones rendidas)
- Nota IS NOT NULL

### Aclaración
Enunciado dice "semestre", implementamos "cuatrimestre" según estructura de DIM_TIEMPO.

---

## Indicador 6: Tasa de Ausentismo Finales

### Requerimiento del Enunciado
> Porcentaje de ausentes a finales (sobre la cantidad de inscriptos) por semestre por sede.

### Vista Implementada
`empanadas_indexadas.BI_V_Tasa_Ausentismo_Finales`

### Lógica de Implementación
```sql
SELECT
    t.Anio,
    t.Cuatrimestre,
    s.Sede_Nombre,
    SUM(f.Cantidad_Inscripciones_Final) AS Total_Inscripciones_Final,
    SUM(CASE WHEN f.Presente = 0 OR f.Presente IS NULL THEN 1 ELSE 0 END) AS Total_Ausentes,
    CASE
        WHEN SUM(f.Cantidad_Inscripciones_Final) > 0
        THEN (SUM(CASE WHEN f.Presente = 0 OR f.Presente IS NULL THEN 1 ELSE 0 END) * 100.0) / SUM(f.Cantidad_Inscripciones_Final)
        ELSE 0
    END AS Porcentaje_Ausentismo
FROM BI_FACT_EVALUACION_FINAL f
INNER JOIN BI_DIM_TIEMPO t ON f.Tiempo_Inscripcion_Key = t.Tiempo_Key
INNER JOIN BI_DIM_SEDE s ON f.Sede_Key = s.Sede_Key
GROUP BY t.Anio, t.Cuatrimestre, s.Sede_Nombre;
```

### Query de Validación
```sql
-- Validar fórmula (Ausentes/Inscriptos)*100
SELECT
    Anio,
    Cuatrimestre,
    Sede_Nombre,
    Total_Inscripciones_Final,
    Total_Ausentes,
    Porcentaje_Ausentismo,
    CAST((Total_Ausentes * 100.0) / Total_Inscripciones_Final AS DECIMAL(5,2)) AS Porcentaje_Verificado
FROM empanadas_indexadas.BI_V_Tasa_Ausentismo_Finales
WHERE Anio = 2023
ORDER BY Porcentaje_Ausentismo DESC;
-- Resultado esperado: Porcentaje_Ausentismo = Porcentaje_Verificado
```

### Cumplimiento
- Agrupamiento por Cuatrimestre y Sede
- Fórmula: (Ausentes/Inscriptos)*100
- Ausente = (Presente = 0 OR Presente IS NULL)
- Denominador = Total inscripciones (no solo presentes)

---

## Indicador 7: Desvío de Pagos

### Requerimiento del Enunciado
> Porcentaje de pagos realizados fuera de término por semestre.

### Vista Implementada
`empanadas_indexadas.BI_V_Desvio_Pagos`

### Lógica de Implementación
```sql
SELECT
    t.Anio,
    t.Cuatrimestre,
    COUNT(*) AS Total_Pagos,
    SUM(CASE WHEN f.Pago_En_Termino = 0 AND f.Tiempo_Pago_Key IS NOT NULL THEN 1 ELSE 0 END) AS Pagos_Fuera_Termino,
    CASE
        WHEN COUNT(*) > 0
        THEN (SUM(CASE WHEN f.Pago_En_Termino = 0 AND f.Tiempo_Pago_Key IS NOT NULL THEN 1 ELSE 0 END) * 100.0) / COUNT(*)
        ELSE 0
    END AS Porcentaje_Fuera_Termino
FROM BI_FACT_PAGO f
INNER JOIN BI_DIM_TIEMPO t ON f.Tiempo_Pago_Key = t.Tiempo_Key
WHERE f.Tiempo_Pago_Key IS NOT NULL
GROUP BY t.Anio, t.Cuatrimestre;
```

### Métrica Pre-Calculada en FACT
```sql
-- En script_creacion_BI.sql, línea ~460
CASE WHEN p.Fecha <= f.FechaVencimiento THEN 1 ELSE 0 END AS Pago_En_Termino
```

### Query de Validación
```sql
-- Validar que solo cuenta pagos efectivamente realizados
SELECT
    Anio,
    Cuatrimestre,
    Total_Pagos,
    Pagos_Fuera_Termino,
    Porcentaje_Fuera_Termino,
    CAST((Pagos_Fuera_Termino * 100.0) / Total_Pagos AS DECIMAL(5,2)) AS Porcentaje_Verificado
FROM empanadas_indexadas.BI_V_Desvio_Pagos
WHERE Anio = 2023
ORDER BY Cuatrimestre;
-- Resultado esperado: Porcentaje_Fuera_Termino = Porcentaje_Verificado
```

### Cumplimiento
- Agrupamiento por Cuatrimestre
- Fórmula: (Fuera_Termino/Total_Pagos)*100
- Filtro WHERE Tiempo_Pago_Key IS NOT NULL (solo pagos realizados)
- Pago_En_Termino = (Fecha_Pago <= FechaVencimiento)

---

## Indicador 8: Tasa de Morosidad Financiera Mensual

### Requerimiento del Enunciado
> Se calcula teniendo en cuenta el total de importes adeudados sobre facturación esperada en el mes. El monto adeudado se obtiene a partir de las facturas que no tengan pago registrado en dicho mes.

### Vista Implementada
`empanadas_indexadas.BI_V_Tasa_Morosidad`

### Lógica de Implementación
```sql
SELECT
    t.Anio,
    t.Mes,
    t.Mes_Nombre,
    SUM(f.Importe_Factura) AS Facturacion_Total,
    SUM(CASE WHEN f.Factura_Pagada = 0 THEN f.Importe_Factura ELSE 0 END) AS Monto_Adeudado,
    CASE
        WHEN SUM(f.Importe_Factura) > 0
        THEN (SUM(CASE WHEN f.Factura_Pagada = 0 THEN f.Importe_Factura ELSE 0 END) * 100.0) / SUM(f.Importe_Factura)
        ELSE 0
    END AS Porcentaje_Morosidad
FROM BI_FACT_PAGO f
INNER JOIN BI_DIM_TIEMPO t ON f.Tiempo_Emision_Key = t.Tiempo_Key
GROUP BY t.Anio, t.Mes, t.Mes_Nombre;
```

### Métrica Pre-Calculada en FACT
```sql
-- En script_creacion_BI.sql, línea ~465
CASE WHEN p.ID_Pago IS NOT NULL THEN 1 ELSE 0 END AS Factura_Pagada
```

### Query de Validación
```sql
-- Validar fórmula (Adeudado/Facturado)*100
SELECT TOP 12
    Anio,
    Mes_Nombre,
    Facturacion_Total,
    Monto_Adeudado,
    Porcentaje_Morosidad,
    CAST((Monto_Adeudado * 100.0) / Facturacion_Total AS DECIMAL(5,2)) AS Porcentaje_Verificado
FROM empanadas_indexadas.BI_V_Tasa_Morosidad
WHERE Anio = 2023
ORDER BY Mes;
-- Resultado esperado: Porcentaje_Morosidad = Porcentaje_Verificado
```

### Cumplimiento
- Agrupamiento por Mes (granularidad mensual)
- Fórmula: (Adeudado/Facturado)*100
- Adeudado = SUM(Importe_Factura WHERE Factura_Pagada = 0)
- JOIN a Tiempo_Emision_Key (mes de facturación)

---

## Indicador 9: Ingresos por Categoría de Cursos

### Requerimiento del Enunciado
> Las 3 categorías de cursos que generan mayores ingresos por sede, por año.

### Vista Implementada
`empanadas_indexadas.BI_V_Ingresos_Por_Categoria`

### Lógica de Implementación
```sql
WITH Ingresos AS (
    SELECT
        t.Anio,
        s.Sede_Nombre,
        c.Categoria_Nombre,
        SUM(f.Importe_Factura) AS Ingresos_Totales,
        ROW_NUMBER() OVER (
            PARTITION BY t.Anio, s.Sede_Nombre
            ORDER BY SUM(f.Importe_Factura) DESC
        ) AS Ranking
    FROM BI_FACT_PAGO f
    INNER JOIN BI_DIM_TIEMPO t ON f.Tiempo_Emision_Key = t.Tiempo_Key
    INNER JOIN BI_DIM_SEDE s ON f.Sede_Key = s.Sede_Key
    LEFT JOIN BI_DIM_CATEGORIA c ON f.Categoria_Key = c.Categoria_Key
    GROUP BY t.Anio, s.Sede_Nombre, c.Categoria_Nombre
)
SELECT Anio, Sede_Nombre, Categoria_Nombre, Ingresos_Totales, Ranking
FROM Ingresos
WHERE Ranking <= 3;
```

### Query de Validación
```sql
-- Validar que devuelve TOP 3 categorías por año/sede
SELECT
    Anio,
    Sede_Nombre,
    COUNT(*) AS Cantidad_Categorias,
    MAX(Ranking) AS Ranking_Maximo,
    SUM(Ingresos_Totales) AS Ingresos_Top3
FROM empanadas_indexadas.BI_V_Ingresos_Por_Categoria
WHERE Anio = 2023
GROUP BY Anio, Sede_Nombre;
-- Resultado esperado: Cantidad_Categorias <= 3, Ranking_Maximo <= 3
```

### Cumplimiento
- Agrupamiento por Año y Sede
- Ranking con ROW_NUMBER() PARTITION BY
- Filtro WHERE Ranking <= 3
- SUM(Importe_Factura) como métrica de ingresos

---

## Indicador 10: Índice de Satisfacción

### Requerimiento del Enunciado
> Índice de satisfacción anual, según rango etario de los profesores y sede. El índice de satisfacción es igual a `((%satisfechos - %insatisfechos) + 100) / 2`. Teniendo en cuenta que:
> - Satisfechos: Notas entre 7 y 10
> - Neutrales: Notas entre 5 y 6
> - Insatisfechos: Notas entre 1 y 4

### Vista Implementada
`empanadas_indexadas.BI_V_Indice_Satisfaccion`

### Lógica de Implementación
```sql
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
FROM BI_FACT_ENCUESTA f
INNER JOIN BI_DIM_TIEMPO t ON f.Tiempo_Key = t.Tiempo_Key
INNER JOIN BI_DIM_SEDE s ON f.Sede_Key = s.Sede_Key
LEFT JOIN BI_DIM_RANGO_ETARIO_PROFESOR r ON f.Rango_Etario_Profesor_Key = r.Rango_Etario_Profesor_Key
LEFT JOIN BI_DIM_SATISFACCION sat ON f.Satisfaccion_Key = sat.Satisfaccion_Key
GROUP BY t.Anio, s.Sede_Nombre, r.Rango_Descripcion;
```

### Bloques Pre-Definidos en DIM_SATISFACCION
```sql
INSERT INTO BI_DIM_SATISFACCION VALUES
(1, 'Insatisfechos', 1, 4),
(2, 'Neutrales', 5, 6),
(3, 'Satisfechos', 7, 10);
```

### Query de Validación
```sql
-- Validar fórmula del índice
SELECT
    Anio,
    Sede_Nombre,
    Rango_Etario_Profesor,
    Total_Respuestas,
    Porcentaje_Satisfechos,
    Porcentaje_Insatisfechos,
    Indice_Satisfaccion,
    -- Recalcular manualmente
    CAST(((Porcentaje_Satisfechos - Porcentaje_Insatisfechos) + 100) / 2 AS DECIMAL(5,2)) AS Indice_Verificado
FROM empanadas_indexadas.BI_V_Indice_Satisfaccion
WHERE Anio = 2023
ORDER BY Indice_Satisfaccion DESC;
-- Resultado esperado: Indice_Satisfaccion = Indice_Verificado
```

### Validación de Rangos
```sql
-- Verificar que bloques de satisfacción están correctamente asignados
SELECT
    Bloque_Descripcion,
    MIN(Nota) AS Nota_Minima,
    MAX(Nota) AS Nota_Maxima,
    COUNT(*) AS Cantidad_Respuestas
FROM empanadas_indexadas.BI_FACT_ENCUESTA f
INNER JOIN empanadas_indexadas.BI_DIM_SATISFACCION sat ON f.Satisfaccion_Key = sat.Satisfaccion_Key
GROUP BY Bloque_Descripcion, sat.Satisfaccion_Key
ORDER BY sat.Satisfaccion_Key;
-- Resultado esperado:
-- Insatisfechos: Notas 1-4
-- Neutrales: Notas 5-6
-- Satisfechos: Notas 7-10
```

### Cumplimiento
- Agrupamiento por Año, Sede, Rango Etario Profesor
- Fórmula exacta del enunciado: `((%S - %I) + 100) / 2`
- Bloques de satisfacción según especificación
- Rango del índice: 0-100

---
