# Justificaciones del Diseño del Modelo de Datos

## Gestión de Inscripciones
- **INSCRIPCION**: Tabla puente entre ALUMNO y CURSO con información específica de la inscripción
- **Estados**: Campo enum que permite seguimiento del estado
- **Fechas**: Separación entre fecha de inscripción y fecha de respuesta
- **3FN**: Todos los atributos dependen completamente de la PK; no se duplican datos de alumno o curso.
- **Migración**: Se crea después de ALUMNO y CURSO para respetar las FKs y asegurar integridad referencial.

## Gestión de Evaluaciones de Curso
- **EVALUACION_CURSO**: Relaciona INSCRIPCION con MODULO para evaluaciones específicas
- **Instancia**: Permite varios intentos por módulo
- **TRABAJO_PRACTICO**: Tabla separada ya que es única por inscripción (no por módulo) (Solo un tp por curso)
- **3FN**: No almacena datos de alumno ni curso directamente; evita redundancia y dependencias transitivas.

## Gestión de Inscripción a Finales
- **EXAMEN_FINAL**: Instancias de finales por curso (fecha, hora, descripción)
- **INSCRIPCION_FINAL**: Tabla puente entre ALUMNO y EXAMEN_FINAL
- Permite varias inscripciones de un alumno a diferentes finales
- **Migración**: Se crea tras CURSO y ALUMNO para cumplir con FKs.
- **3FN**: Todos los atributos dependen completamente de la clave primaria.

## Gestión de Evaluaciones Finales
- **EVALUACION_FINAL**: Relaciona INSCRIPCION_FINAL con PROFESOR
- Permite saber qué profesor corrigió cada final
- **3FN**: Evita redundancia de datos de alumnos, cursos o exámenes finales.

## Gestión de Pagos
- **FACTURA**: Una por alumno con detalle de múltiples cursos
- **DETALLE_FACTURA**: Permite facturación de múltiples cursos por período
- **PAGO**: Pagos con trazabilidad de medio de pago
- **Migración**: FACTURA y DETALLE_FACTURA se crean tras ALUMNO y CURSO; PAGO tras FACTURA y MEDIO_PAGO.
- **3FN**: DETALLE_FACTURA evita dependencia transitoria entre FACTURA y CURSO.

## Gestión de Encuestas
- **ENCUESTA**: Por curso con fecha de registro
- **PREGUNTA_ENCUESTA**: Catálogo reutilizable de preguntas
- **RESPUESTA_ENCUESTA**: Respuestas anónimas con notas numéricas
- **3FN**: RESPUESTA_ENCUESTA depende solo de la PK de la tabla y de las FKs hacia ENCUESTA y PREGUNTA_ENCUESTA.
- **Migración**: Preguntas de la base maestra se insertan primero para poder asignarlas a encuestas.

## Gestión de Datos Maestros y Ubicación
- **PROVINCIA y LOCALIDAD**: Separación de tablas para evitar redundancia y permitir actualización centralizada.
- **SEDE, PROFESOR, ALUMNO**: FK hacia LOCALIDAD para evitar datos repetidos.
- **CURSO**: FK hacia SEDE, PROFESOR, DIA, TURNO, CATEGORIA; asegura integridad y flexibilidad futura.
- **3FN**: Todas las dependencias transitivas eliminadas; datos separados de transacciones.
- **Migración**: Se migran primero las tablas (PROVINCIA, LOCALIDAD, CATEGORIA, DIA, TURNO, MEDIO_PAGO) para que las FKs funcionen correctamente.
