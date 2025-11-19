# Estrategia de Diseño - TP Empanadas Indexadas

## Modelo Transaccional

### Gestión de Inscripciones
- **INSCRIPCION**: Tabla puente entre ALUMNO y CURSO con información específica de la inscripción
- **Estados**: Campo enum que permite seguimiento del estado
- **Fechas**: Separación entre fecha de inscripción y fecha de respuesta
- **3FN**: Todos los atributos dependen completamente de la PK; no se duplican datos de alumno o curso.
- **Migración**: Se crea después de ALUMNO y CURSO para respetar las FKs y asegurar integridad referencial.

### Gestión de Evaluaciones de Curso
- **EVALUACION_CURSO**: Relaciona INSCRIPCION con MODULO para evaluaciones específicas
- **Instancia**: Permite varios intentos por módulo
- **TRABAJO_PRACTICO**: Tabla separada ya que es única por inscripción (no por módulo) (Solo un tp por curso)
- **3FN**: No almacena datos de alumno ni curso directamente; evita redundancia y dependencias transitivas.

### Gestión de Inscripción a Finales
- **EXAMEN_FINAL**: Instancias de finales por curso (fecha, hora, descripción)
- **INSCRIPCION_FINAL**: Tabla puente entre ALUMNO y EXAMEN_FINAL
- Permite varias inscripciones de un alumno a diferentes finales
- **Migración**: Se crea tras CURSO y ALUMNO para cumplir con FKs.
- **3FN**: Todos los atributos dependen completamente de la clave primaria.

### Gestión de Evaluaciones Finales
- **EVALUACION_FINAL**: Relaciona INSCRIPCION_FINAL con PROFESOR
- Permite saber qué profesor corrigió cada final
- **3FN**: Evita redundancia de datos de alumnos, cursos o exámenes finales.

### Gestión de Pagos
- **FACTURA**: Una por alumno con detalle de múltiples cursos
- **DETALLE_FACTURA**: Permite facturación de múltiples cursos por período
- **PAGO**: Pagos con trazabilidad de medio de pago
- **Migración**: FACTURA y DETALLE_FACTURA se crean tras ALUMNO y CURSO; PAGO tras FACTURA y MEDIO_PAGO.
- **3FN**: DETALLE_FACTURA evita dependencia transitoria entre FACTURA y CURSO.

### Gestión de Encuestas
- **ENCUESTA**: Por curso con fecha de registro
- **PREGUNTA_ENCUESTA**: Catálogo reutilizable de preguntas
- **RESPUESTA_ENCUESTA**: Respuestas anónimas con notas numéricas
- **3FN**: RESPUESTA_ENCUESTA depende solo de la PK de la tabla y de las FKs hacia ENCUESTA y PREGUNTA_ENCUESTA.
- **Migración**: Preguntas de la base maestra se insertan primero para poder asignarlas a encuestas.

### Gestión de Datos Maestros y Ubicación
- **PROVINCIA y LOCALIDAD**: Separación de tablas para evitar redundancia y permitir actualización centralizada.
- **SEDE, PROFESOR, ALUMNO**: FK hacia LOCALIDAD para evitar datos repetidos.
- **CURSO**: FK hacia SEDE, PROFESOR, DIA, TURNO, CATEGORIA; asegura integridad y flexibilidad futura.
- **3FN**: Todas las dependencias transitivas eliminadas; datos separados de transacciones.
- **Migración**: Se migran primero las tablas (PROVINCIA, LOCALIDAD, CATEGORIA, DIA, TURNO, MEDIO_PAGO) para que las FKs funcionen correctamente.

## Modelo de Business Intelligence (BI)

### Decisiones del Modelo Dimensional

El modelo dimensional implementado para el sistema de gestión de cursos fue diseñado aplicando el patrón de **esquema en estrella** (star schema).

#### Principios de Diseño Aplicados

1. **Separación entre modelo transaccional y analítico**
   - El modelo BI está completamente separado del modelo transaccional (OLTP)
   - Tablas con prefijo `BI_` para evitar conflictos y facilitar mantenimiento
   - Optimizado para consultas de lectura (OLAP) vs. escrituras transaccionales

2. **Granularidad de los hechos**
   - Cada hecho representa un **evento atómico** del negocio
   - FACT_INSCRIPCION: Una fila por cada inscripción individual
   - FACT_EVALUACION_CURSO: Una fila por cada evaluación de módulo
   - FACT_EVALUACION_FINAL: Una fila por cada inscripción a final
   - FACT_PAGO: Una fila por cada factura emitida
   - FACT_ENCUESTA: Una fila por cada respuesta de encuesta

3. **Desnormalización controlada**
   - Las dimensiones contienen información desnormalizada para mejorar performance
   - Ejemplo: DIM_SEDE incluye nombre de institución, localidad y provincia en una sola tabla
   - Reduce JOINs necesarios en consultas analíticas

4. **Dimensiones conformadas (Conformed Dimensions)**
   - DIM_TIEMPO: Compartida por todos los hechos, garantiza consistencia temporal
   - DIM_SEDE: Única fuente de verdad para análisis geográficos
   - DIM_CATEGORIA: Clasificación estándar aplicable a múltiples contextos

5. **Role-Playing Dimensions**
   - DIM_TIEMPO se reutiliza con diferentes roles en los hechos:
     * FACT_INSCRIPCION: Tiempo_Inscripcion_Key y Tiempo_Respuesta_Key
     * FACT_EVALUACION_FINAL: Tiempo_Inscripcion_Key, Tiempo_Evaluacion_Key, Tiempo_Inicio_Curso_Key
     * FACT_PAGO: Tiempo_Emision_Key, Tiempo_Vencimiento_Key, Tiempo_Pago_Key

---

### Justificación del Esquema Estrella

#### ¿Por qué Esquema Estrella y no Copo de Nieve (Snowflake)?

Se eligió el **esquema en estrella** sobre el esquema copo de nieve por las siguientes razones:

Estrella
    Menos JOINs (Performance)
    Queries directas (Simplicidad)
    Estructura simple (Mantenimiento)
    Mayor redundancia (Ocupa mas espacio en disco)
    Intuitivo (Comprensible por el usuario)

Copo de Nieve
    Multiples JOINs
    Queries complejas
    Jerarquias complejas
    Menor redundancia (Ocupa menos espacio en disco)
    Requiere conocimiento tecnico para su comprension

---

### Dimensiones

#### DIM_TIEMPO (2,557 registros)
**Propósito:** Dimensión temporal central del modelo, permite análisis por año, cuatrimestre y mes.

**Diseño:**
- **Granularidad:** Nivel día (2020-01-01 a 2026-12-31)
- **Rango extendido:** 7 años para cubrir datos históricos y proyecciones futuras
- **Atributos calculados:**
  - `Cuatrimestre`: CASE WHEN MONTH(Fecha) <= 6 THEN 1 ELSE 2 END
  - `Mes_Nombre`: DATENAME(MONTH, Fecha)
- **Índices:**
  - `IX_BI_DIM_TIEMPO_Anio_Cuatrimestre` (para indicadores 5, 6, 7)
  - `IX_BI_DIM_TIEMPO_Anio_Mes` (para indicadores 2, 8)

**Justificación:**
- Dimensión tipo 1 (SCD Type 1): Los atributos temporales son inmutables
- Pre-poblar 7 años evita gaps en análisis de tendencias
- Permite drill-down: Año > Cuatrimestre > Mes > Día

#### DIM_SEDE (4 registros)
**Propósito:** Análisis geográfico y comparación entre sedes.

**Diseño:**
- **Desnormalización:** Incluye Institución, Localidad y Provincia en una tabla
- **Atributos:**
  - Sede_Nombre, Institucion_Nombre
  - Localidad_Nombre, Provincia_Nombre
- **Índice:** `IX_BI_DIM_SEDE_ID` para join con modelo transaccional

**Justificación:**
- Reduce 3 JOINs a 1 en consultas analíticas
- La cantidad de sedes es pequeña (4), redundancia despreciable
- Indicadores 1, 2, 3, 6, 9, 10 requieren agrupamiento por sede

#### DIM_RANGO_ETARIO_ALUMNO (4 registros)
**Propósito:** Segmentación demográfica de alumnos para análisis de rendimiento.

**Diseño:**
- **Rangos definidos en enunciado:**
  - <25 (0-24), 25-35, 35-50, >50 (51-NULL)
- **Cálculo en hechos:**
  ```sql
  CASE
    WHEN DATEDIFF(YEAR, FechaNacimiento, EventDate) < 25 THEN 1
    WHEN DATEDIFF(YEAR, FechaNacimiento, EventDate) BETWEEN 25 AND 35 THEN 2
    WHEN DATEDIFF(YEAR, FechaNacimiento, EventDate) BETWEEN 36 AND 50 THEN 3
    ELSE 4
  END
  ```

**Justificación:**
- Dimensión pequeña (4 registros) ideal para lookup
- Edad se calcula contra fecha del evento (no fecha actual)
- Indicador 5 requiere este agrupamiento específico

#### DIM_RANGO_ETARIO_PROFESOR (3 registros)
**Propósito:** Segmentación de profesores para análisis de satisfacción.

**Diseño:**
- **Rangos:** 25-35, 35-50, >50
- **Motivación:** Profesores jóvenes vs. experimentados en evaluaciones

**Justificación:**
- Indicador 10 (índice satisfacción) analiza por rango etario de profesor
- Permite identificar si edad del docente impacta en percepción de alumnos

#### DIM_TURNO (3 registros)
**Propósito:** Análisis de demanda por horario.

**Diseño:**
- **Valores:** Mañana, Tarde, Noche
- **Source:** Modelo transaccional (TURNO)

**Justificación:**
- Indicador 1 requiere top 3 turnos más solicitados
- Facilita análisis de ocupación de aulas por horario

#### DIM_CATEGORIA (5 registros)
**Propósito:** Clasificación de cursos para análisis de performance e ingresos.

**Diseño:**
- **Source:** Modelo transaccional (CATEGORIA)
- **Uso en 6 indicadores:** 1, 4, 5, 9

**Justificación:**
- Permite identificar categorías rentables vs. categorías con alto rechazo

#### DIM_MEDIO_PAGO (4 registros)
**Propósito:** Análisis de preferencias de pago y cobranzas.

**Diseño:**
- **Source:** Modelo transaccional (MEDIO_PAGO)
- **Uso:** FACT_PAGO

**Justificación:**
- Permite análisis de costos de cobro
- Identificar medios de pago asociados a morosidad

#### DIM_SATISFACCION (3 registros)
**Propósito:** Clasificación de encuestas para índice de satisfacción.

**Diseño:**
- **Bloques según enunciado:**
  - Insatisfechos (1-4)
  - Neutrales (5-6)
  - Satisfechos (7-10)
- **Cálculo en FACT_ENCUESTA:**
  ```sql
  CASE
    WHEN re.Nota BETWEEN 1 AND 4 THEN 1
    WHEN re.Nota BETWEEN 5 AND 6 THEN 2
    WHEN re.Nota BETWEEN 7 AND 10 THEN 3
  END
  ```

**Justificación:**
- Dimensión requerida por indicador 10
- Bloques permiten calcular índice: `((%satisfechos - %insatisfechos) + 100) / 2`

---

### Hechos (Facts)

#### FACT_INSCRIPCION (12,838 registros)
**Proceso de negocio:** Inscripciones de alumnos a cursos.

**Granularidad:** Una fila por cada inscripción individual.

**Dimensiones:**
- Tiempo_Inscripcion_Key (cuando se inscribió)
- Tiempo_Respuesta_Key (cuando se aprobó/rechazó)
- Sede_Key, Categoria_Key, Turno_Key, Rango_Etario_Alumno_Key

**Métricas:**
- **Contadores:**
  - Cantidad_Inscripciones (siempre 1, para SUM)
  - Inscripciones_Aprobadas (0 o 1)
  - Inscripciones_Rechazadas (0 o 1)
  - Inscripciones_Pendientes (0 o 1)
- **Calculadas:**
  - Dias_Hasta_Respuesta: DATEDIFF(DAY, FechaInscripcion, FechaRespuesta)
  - Precio_Mensual: Denormalizado para análisis de ingresos

**Indicadores soportados:** 1, 2

**Índices:**
```sql
IX_BI_FACT_INSCRIPCION_Tiempo (Tiempo_Inscripcion_Key)
IX_BI_FACT_INSCRIPCION_Sede (Sede_Key)
IX_BI_FACT_INSCRIPCION_Categoria (Categoria_Key)
```

#### FACT_EVALUACION_CURSO (59,025 registros)
**Proceso de negocio:** Evaluaciones de módulos y TPs durante cursada.

**Granularidad:** Una fila por cada evaluación individual.

**Dimensiones:**
- Tiempo_Evaluacion_Key, Sede_Key, Categoria_Key, Rango_Etario_Alumno_Key

**Métricas:**
- Cantidad_Evaluaciones (siempre 1)
- Nota (1-10)
- Presente (bit)
- Aprobado (bit): `Nota >= 4`

**Indicadores soportados:** 3

**Justificación:**
- Indicador 3 requiere porcentaje de aprobación de cursada
- Modelo permite agrupar por sede/año y calcular: SUM(Aprobado)/COUNT(*)

#### FACT_EVALUACION_FINAL (3,204 registros)
**Proceso de negocio:** Finales rendidos por alumnos.

**Granularidad:** Una fila por cada inscripción a final.

**Dimensiones:**
- Tiempo_Inscripcion_Key (inscripción al final)
- Tiempo_Evaluacion_Key (fecha del examen)
- Tiempo_Inicio_Curso_Key (inicio del curso para calcular tiempo de finalización)
- Sede_Key, Categoria_Key, Rango_Etario_Alumno_Key

**Métricas:**
- Cantidad_Inscripciones_Final (siempre 1)
- Nota, Presente, Aprobado
- Dias_Inicio_Curso_A_Final: DATEDIFF(DAY, FechaInicio, FechaExamen)

**Indicadores soportados:** 4, 5, 6

**Justificación:**
- Indicador 4: Tiempo promedio finalización = AVG(Dias_Inicio_Curso_A_Final)
- Indicador 5: Nota promedio por rango etario y categoría
- Indicador 6: Tasa ausentismo = SUM(CASE WHEN Presente=0)/COUNT(*)

#### FACT_PAGO (59,025 registros)
**Proceso de negocio:** Facturación y cobranzas.

**Granularidad:** Una fila por cada factura emitida (detalle de factura).

**Dimensiones:**
- Tiempo_Emision_Key, Tiempo_Vencimiento_Key, Tiempo_Pago_Key
- Sede_Key, Categoria_Key, MedioPago_Key

**Métricas:**
- Importe_Factura, Importe_Pagado
- Pago_En_Termino (bit): `Fecha_Pago <= FechaVencimiento`
- Dias_Fuera_Termino: DATEDIFF(DAY, FechaVencimiento, Fecha_Pago)
- Factura_Pagada (bit): `ID_Pago IS NOT NULL`

**Indicadores soportados:** 7, 8, 9

**Justificación:**
- Indicador 7: Desvío pagos = SUM(CASE WHEN Pago_En_Termino=0)/COUNT(*)
- Indicador 8: Morosidad = SUM(CASE WHEN Factura_Pagada=0 THEN Importe)/SUM(Importe)
- Indicador 9: Ingresos por categoría = SUM(Importe_Factura) GROUP BY Categoria

#### FACT_ENCUESTA (44,916 registros)
**Proceso de negocio:** Encuestas de satisfacción post-curso.

**Granularidad:** Una fila por cada respuesta individual a pregunta de encuesta.

**Dimensiones:**
- Tiempo_Key, Sede_Key, Categoria_Key
- Rango_Etario_Profesor_Key, Satisfaccion_Key

**Métricas:**
- Cantidad_Respuestas (siempre 1)
- Nota (1-10)

**Indicadores soportados:** 10

**Justificación:**
- Indicador 10: Índice satisfacción calculado con bloque de satisfacción
- Fórmula: `((%satisfechos - %insatisfechos) + 100) / 2`

---

### Métricas Calculadas

#### 1. Rangos Etarios Dinámicos
**Implementación:**
```sql
CASE
  WHEN DATEDIFF(YEAR, FechaNacimiento, EventDate) < 25 THEN 1
  WHEN DATEDIFF(YEAR, FechaNacimiento, EventDate) BETWEEN 25 AND 35 THEN 2
  WHEN DATEDIFF(YEAR, FechaNacimiento, EventDate) BETWEEN 36 AND 50 THEN 3
  ELSE 4
END
```

**Justificación:**
- La edad se calcula contra la fecha del evento, no la fecha actual
- Garantiza historicidad: un alumno de 24 años en 2020 se mantiene en rango <25
- Evita recalcular dimensión con cada consulta

#### 2. Aprobado (Nota >= 4)
**Implementación:**
```sql
CASE WHEN Nota >= 4 THEN 1 ELSE 0 END
```

**Justificación:**
- Precalculado en hechos para evitar CASE en agregaciones
- SUM(Aprobado)/COUNT(*) calcula porcentaje sin subqueries
- Índices sobre columna calculada mejoran performance

#### 3. Pago en Término
**Implementación:**
```sql
CASE WHEN Fecha_Pago <= FechaVencimiento THEN 1 ELSE 0 END
```

**Justificación:**
- Indicador 7 requiere porcentaje de pagos fuera de término
- Métrica binaria facilita agregación: SUM(Pago_En_Termino)/COUNT(*)

#### 4. Factura Pagada
**Implementación:**
```sql
CASE WHEN ID_Pago IS NOT NULL THEN 1 ELSE 0 END
```

**Justificación:**
- Indicador 8 (morosidad) requiere identificar facturas impagas
- SUM(CASE WHEN Factura_Pagada=0 THEN Importe) calcula adeudado

#### 5. Bloques de Satisfacción
**Implementación:**
```sql
CASE
  WHEN Nota BETWEEN 1 AND 4 THEN 1  -- Insatisfechos
  WHEN Nota BETWEEN 5 AND 6 THEN 2  -- Neutrales
  WHEN Nota BETWEEN 7 AND 10 THEN 3 -- Satisfechos
END
```

**Justificación:**
- Requerido por enunciado para indicador 10
- Lookup en DIM_SATISFACCION evita hardcodear rangos en queries
- Facilita modificar bloques sin cambiar vistas

#### 6. Índice de Satisfacción
**Implementación:**
```sql
((
  (SUM(CASE WHEN Bloque='Satisfechos' THEN 1 ELSE 0 END) * 100.0) / COUNT(*)
  -
  (SUM(CASE WHEN Bloque='Insatisfechos' THEN 1 ELSE 0 END) * 100.0) / COUNT(*)
) + 100) / 2
```

**Justificación:**
- Fórmula especificada en enunciado
- Rango 0-100 (0% satisfechos - 100% insatisfechos = -100 => índice 0)
- Rango 0-100 (100% satisfechos - 0% insatisfechos = 100 => índice 100)

---

## Decisiones de Diseño y Ambigüedades del Enunciado

### Indicador 3: Comparación de Desempeño de Cursada por Sede

**Enunciado:**
> "Porcentaje de aprobación de cursada por sede, por año. Se considera aprobada la cursada de un alumno cuando tiene nota mayor o igual a 4 en todos los módulos y el TP."

El enunciado puede interpretarse de dos formas diferentes:

#### Interpretación A: Tasa de Aprobación de Evaluaciones Individuales (IMPLEMENTACIÓN PRINCIPAL)

**Vista:** `BI_V_Desempeno_Cursada_Sede`

**Definición:** Porcentaje de evaluaciones (módulos y TPs) que fueron aprobadas (nota >= 4) sobre el total de evaluaciones rendidas.

**Ejemplo:**
```
Sede Norte, 2023:
- Total evaluaciones rendidas: 1000 (800 módulos + 200 TPs)
- Evaluaciones aprobadas (nota >= 4): 750 (600 módulos + 150 TPs)
- Porcentaje: 75%
```
**Mantiene granularidad dimensional:** Coherente con el diseño de `FACT_EVALUACION_CURSO` donde cada fila = una evaluación

---

#### Interpretación B: Tasa de Aprobación de Cursada Completa (IMPLEMENTACIÓN ALTERNATIVA)

**Vista:** `BI_V_Desempeno_Cursada_Completa_Sede`

**Definición:** Porcentaje de alumnos que aprobaron TODAS las evaluaciones (todos los módulos y el TP con nota >= 4) sobre el total de alumnos que cursaron.

**Ejemplo:**
```
Sede Norte, 2023:
- Total alumnos que cursaron: 100
- Alumnos con TODAS evaluaciones aprobadas: 60
- Porcentaje: 60%
```
**Interpretación literal:** Lee el enunciado como "el alumno aprobó cuando tiene nota >= 4 en TODOS"

**Métrica de éxito:** Mide realmente cuántos alumnos completaron exitosamente la cursada

## Optimizaciones de Performance

#### 1. Índices en Claves Foráneas
```sql
-- En tablas de hechos
CREATE INDEX IX_BI_FACT_X_Tiempo ON BI_FACT_X(Tiempo_Key);
CREATE INDEX IX_BI_FACT_X_Sede ON BI_FACT_X(Sede_Key);
CREATE INDEX IX_BI_FACT_X_Categoria ON BI_FACT_X(Categoria_Key);
```

**Impacto:**
- Reduce scan de tabla completa en agregaciones
- Acelera JOINs con dimensiones
- Mejora performance de GROUP BY y WHERE

#### 2. Índices Compuestos en DIM_TIEMPO
```sql
CREATE INDEX IX_BI_DIM_TIEMPO_Anio_Cuatrimestre ON BI_DIM_TIEMPO(Anio, Cuatrimestre);
CREATE INDEX IX_BI_DIM_TIEMPO_Anio_Mes ON BI_DIM_TIEMPO(Anio, Mes);
```

**Impacto:**
- Indicadores 5, 6, 7 filtran por cuatrimestre: índice compuesto evita doble lookup
- Indicadores 2, 8 filtran por mes: cubre query completo

#### 3. Vistas Materializadas (Futuro)
**Candidatos:**
- `BI_V_Categorias_Turnos_Mas_Solicitados`: CTE con ROW_NUMBER
- `BI_V_Indice_Satisfaccion`: Agregaciones complejas

**Justificación:**
- Las 10 vistas actuales son **no materializadas** (ejecutan query cada vez)
- Para dashboards en tiempo real, materializar TOP queries reduciría latencia
- Trade-off: espacio en disco vs. velocidad de consulta

---

## Validación de Indicadores

### Mapeo Enunciado a Vistas BI

| # | Indicador del Enunciado | Vista Implementada | Validación |
|---|-------------------------|-------------------|------------|
| 1 | Categorías y turnos más solicitados | `BI_V_Categorias_Turnos_Mas_Solicitados` | ROW_NUMBER() PARTITION BY Año/Sede |
| 2 | Tasa de rechazo de inscripciones | `BI_V_Tasa_Rechazo_Inscripciones` | (Rechazadas/Total)*100 por mes/sede |
| 3 | Comparación desempeño cursada por sede | `BI_V_Desempeno_Cursada_Sede` | (Aprobados/Total)*100 WHERE Presente=1 |
| 4 | Tiempo promedio finalización curso | `BI_V_Tiempo_Finalizacion_Curso` | AVG(Dias_Inicio_A_Final) WHERE Aprobado=1 |
| 5 | Nota promedio finales | `BI_V_Nota_Promedio_Finales` | AVG(Nota) GROUP BY Rango/Categoria/Cuatrimestre |
| 6 | Tasa ausentismo finales | `BI_V_Tasa_Ausentismo_Finales` | (Ausentes/Total)*100 por cuatrimestre/sede |
| 7 | Desvío de pagos | `BI_V_Desvio_Pagos` | (Fuera_Termino/Total)*100 por cuatrimestre |
| 8 | Tasa morosidad financiera | `BI_V_Tasa_Morosidad` | (Adeudado/Facturado)*100 por mes |
| 9 | Ingresos por categoría | `BI_V_Ingresos_Por_Categoria` | ROW_NUMBER() TOP 3 por año/sede |
| 10 | Índice de satisfacción | `BI_V_Indice_Satisfaccion` | ((%S - %I) + 100) / 2 por rango/sede/año |

---
