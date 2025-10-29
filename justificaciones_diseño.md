# Justificaciones del Diseño del Modelo de Datos

## Gestión de Inscripciones
- **INSCRIPCION**: Tabla puente entre ALUMNO y CURSO con información específica de la inscripción
- **Estados**: Campo enum que permite seguimiento del estado
- **Fechas**: Separación entre fecha de inscripción y fecha de respuesta

## Gestión de Evaluaciones de Curso
- **EVALUACION_CURSO**: Relaciona INSCRIPCION con MODULO para evaluaciones específicas
- **Instancia**: Permite varios intentos por módulo
- **TRABAJO_PRACTICO**: Tabla separada ya que es única por inscripción (no por módulo) (Solo un tp por curso)

## Gestión de Inscripción a Finales
- **EXAMEN_FINAL**: Instancias de finales por curso (fecha, hora, descripción)
- **INSCRIPCION_FINAL**: Tabla puente entre ALUMNO y EXAMEN_FINAL
- Permite varias inscripciones de un alumno a diferentes finales

## Gestión de Evaluaciones Finales
- **EVALUACION_FINAL**: Relaciona INSCRIPCION_FINAL con PROFESOR
- Permite saber qué profesor corrigió cada final

## Gestión de Pagos
- **FACTURA**: Una por alumno con detalle de múltiples cursos
- **DETALLE_FACTURA**: Permite facturación de múltiples cursos por período
- **PAGO**: Pagos con trazabilidad de medio de pago

## Gestión de Encuestas
- **ENCUESTA**: Por curso con fecha de registro
- **PREGUNTA_ENCUESTA**: Catálogo reutilizable de preguntas
- **RESPUESTA_ENCUESTA**: Respuestas anónimas con notas numéricas
