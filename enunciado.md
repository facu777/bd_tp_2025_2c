## Índice

  * Introducción
  * Objetivos generales
  * Descripción general
  * Componentes del TP
  * Base de Datos y Modelo de Datos
  * Especificación de casos de uso
  * 1.  Gestión de Publicaciones
  * 2.  Gestión de Ventas
  * 3.  Gestión de Envíos
  * 4.  Gestión de Pagos
  * 5.  Facturación Marketplace
  * Consideraciones
  * Requerimientos del TP
  * General
  * Modelo Transaccional del Sistema
  * Base de Datos
  * Consideraciones
  * Modelo de Inteligencia de Negocios (BI)
  * Base de Datos
  * Especificación del Modelo de BI
  * Implementación
  * General
  * Base de Datos
  * Restricciones
  * Condiciones de Evaluación y Aprobación
  * Testing de Scripts
  * Consultas SQL
  * Sobre los grupos
  * Entregas
  * Fechas de entrega y condiciones
  * Entrega del DER
  * Entrega de Modelo de Datos Relacional y Migración
  * Entrega de BI
  * Condiciones de Entregas
  * Formato de entrega
  * Lugar de envíο
  * Asunto
  * Cuerpo del Mail
  * Adjunto
  * Estructura del archivo zip
  * Readme.txt
  * Estrategia.pdf
  * DER.jpg
  * DER\_BI.jpg
  * \\data
  * Consideración
  * Ayuda y contacto
  * Obtención de herramientas

-----

## Introducción

### Objetivos generales

El presente trabajo práctico persigue los siguientes objetivos generales:

  * Promover la investigación de técnicas de base de datos.
  * Aplicar la teoría vista en la asignatura en una aplicación concreta.
  * Desarrollar y probar distintos algoritmos sobre datos reales.
  * Fomentar la delegación y el trabajo en grupo.

### Descripción general

Mediante este trabajo práctico se intenta simular la implementación de un nuevo sistema.

El mismo permite gestionar distintos cursos que brinda una institución incluyendo las inscripciones de alumnos, cursada y finales.

Permite también la gestión de pagos y encuestas.

La implementación de dicho sistema, requiere previamente realizar la migración de los datos que se tenían registrados hasta el momento.

Para ello es necesario que se reformule el diseño de la base de datos y los procesos, de manera tal que cumplan con los nuevos requerimientos.

Además, se solicita la implementación de un segundo modelo, con sus correspondientes procedimientos y vistas, que pueda ser utilizado para la obtención de indicadores de gestión, análisis de escenarios y proyección para la toma de decisiones.

-----

## Componentes del TP

El alumno recibirá dos componentes y, en base a estos, deberá realizar el modelo y los procedimientos correspondientes.

Los componentes a recibir son:

### Base de Datos y Modelo de Datos

La cátedra provee un script que permite crear un esquema sobre una base de datos en el motor SQL Server 2022. Este incluye una única tabla, llamada maestra, que contiene datos provistos por la cátedra correspondientes al dominio del negocio que se describe en el TP.

Los datos de esta tabla se encuentran desorganizados y no poseen ningún tipo de normalización.

La lógica del negocio está definida, en su mayoría, por la especificación de los principales casos de uso que están implementados actualmente (tabla maestra).

El alumno deberá analizar los datos contenidos en dicha tabla y confeccionar un nuevo modelo de datos que siga todos los estándares de desarrollo de bases de datos explicados durante la cursada.

Si se presentan dudas al respecto, es recomendable consultar al grupo de Google de la materia antes de tomar decisiones incorrectas.

### Especificación de casos de uso

A continuación, se detallan algunas especificaciones de casos de uso relacionados al nuevo sistema, con el objetivo de contextualizar y ayudar al entendimiento de la operación del mismo.

-----

### 1\. Gestión de Inscripciones a Cursos

Esta funcionalidad permitirá gestionar las inscripciones que realicen los alumnos a los cursos.

Por cada inscripción se registra la siguiente información.

  * **Nro. Inscripción:** Identificador único para cada inscripción
  * **Fecha inscripción:** fecha en que se inscribe el alumno
  * **Alumno:** Se registra el alumno que se inscribe, con toda su información (nombre, dni, domicilio, etc.)
  * **Curso:** Curso al que se inscribe el alumno. Los cursos están previamente dados de alta en el sistema con su respectiva información:
      * **Código del Curso:** Identificador único para cada curso
      * **Sede:** La institución tiene varias sedes. Los cursos se dictan por sede.
      * **Profesor:** el profesor que dicta el curso. Se tienen registrados todos los datos del mismo.
      * **Nombre:** nombre del curso
      * **Descripción:** descripción del curso
      * **Categoría:** Los cursos están clasificados por categorías.
      * **Fecha Inicio:** fecha en que comienza el curso
      * **Fecha Fin:** fecha en que finaliza el curso
      * **Duración:** en meses
      * **Dias:** días de la semana que se cursa.
      * **Turno:** Turno en que se dicta el curso. El tuno define el horario del curso. Existen 3 turnos: mañana, tarde y noche.
      * **Precio mensual:** Los cursos se pagan de manera mensual, por los meses que dure el mismo.
      * **Módulos:** El contenido de los cursos está dividido en módulos.
  * **Estado:** Una vez que el alumno se inscribe la institución decide si aprueba o rechaza dicha inscripción. El estado determina si una inscripción está pendiente, aprobada o rechazada.
  * **Fecha respuesta:** Fecha en que se aprueba o rechaza la inscripción.

### 2\. Gestión de Evaluaciones de Curso

Este módulo permitirá gestionar los cursos y las evaluaciones de los alumnos dentro de la cursada de los mismos.

Un curso queda conformado por todos los alumnos cuya inscripción ha sido aprobada.

Para cada curso se van registrando las evaluaciones que se toman a lo largo del mismo.

Las evaluaciones se realizan por módulo.

Por cada evaluación se registra la siguiente información:

  * **Fecha evaluación:** fecha en que se evalúa.
  * **Módulo:** Módulo del curso que se está rindiendo.
  * Por cada alumno del curso se registra:
      * **Leg. Alumno:** alumno que rindió.
      * **Nota:** nota que se sacó.
      * **Presente:** si concurrió o no el alumno a la evaluación
      * **Instancia:** Nro. de vez que rinde el módulo.

Además los alumnos deben realizar y presentar un trabajo práctico. Por cada TP se registra:

  * **Curso:** al que pertenece el TP
  * **Alumno:** al que pertenece el TP
  * **Fecha de evaluación:** fecha en que se evalúa el TP
  * **Nota:** nota del TP

### 3\. Gestión de Inscripción a Finales

Al aprobar la cursada el alumno debe rendir un examen final.

Hay varias instancias de final para cada curso y el alumno se puede inscribir a la que quiera.

Por cada inscripción de alumno se registra:

  * **Nro. Inscripción:** Identificador único para cada inscripción
  * **Fecha Inscripción:** Fecha en que se inscribe el alumno.
  * **Alumno:** Alumno que se inscribe.
  * **Final:** Final al cual se inscribe. Las instancias posibles de final están previamente dadas de alta con la siguiente información principal:
      * **Fecha:** fecha en que se toma el final
      * **Hora:** hora en que se toma el final
      * **Curso:** Curso sobre el cual se toma el final

### 4\. Gestión de Evaluaciones Finales

Al momento de tomar el final se registran las notas de los alumnos.

Por cada evaluación final se registra la siguiente información:

  * **Alumno:** alumno que rindió/inscripto
  * **Presente:** si concurrió o no el alumno a la evaluación
  * **Nota:** nota que se sacó
  * **Profesor:** Profesor que corrigió el final

### 5\. Gestión de Pagos

Este módulo permite registrar y gestionar los pagos de los alumnos.

Todos los meses se generan las facturas a los alumnos que deben pagar, en función de lo que estén cursando.

Por cada factura se registra la siguiente información:

  * **Nro. Factura:** identificador único de la factura
  * **Fecha:** fecha de emisión de la factura
  * **Fecha vencimiento:** fecha antes de la cual se debe pagar la factura
  * **Alumno:** alumno al cual se emite la factura
  * **Detalle de Factura:** si el alumno está inscripto en más de un curso se emite una única factura con el detalle:
      * **Curso:** curso a partir del cual se le emite la factura al alumno.
      * **Periodo:** mes/año al que hace referencia la factura
      * **Importe:** Importe correspondiente al curso y al período.
  * **Importe Total:** importe total a pagar

Por cada Pago que realice el alumno se registra:

  * **Id Pago:** identificador único del pago
  * **Factura:** factura a la cual corresponde el pago
  * **Fecha:** fecha en que se realiza el pago.
  * **Importe:** importe total pagado.
  * **Medio de Pago:** medio de pago utilizado

### 6\. Gestión de Encuestas

Este módulo permite gestionar las encuestas realizadas por cada curso.

Una vez finalizado el curso, se realiza una encuesta para que los alumnos puedan completar de manera anónima.

Por cada encuesta completada se registra la siguiente información:

  * **Curso:** curso sobre el cual es la encuesta
  * **Fecha Registro:** fecha en que el alumno completa la encuesta.
  * **Detalle:** la encuesta está compuesta por varias preguntas. Por cada respuesta a cada una de ellas se registra:
      * **Pregunta:** pregunta que se está respondiendo.
      * **Respuesta:** Las respuesta es numérica con un valor posible del 1 al 10
      * **Observaciones:** campo libre que el alumno puede completar con las observaciones que quiera realizar.

### Consideraciones

Cabe aclarar que la especificación de casos es solo un resumen sobre los datos que se encuentran en la tabla maestra, a modo de ilustrar las principales operaciones que se realizan en el sistema y son particularly especiales en el contexto del trabajo práctico.

El alumno debe relevar los restantes campos correspondientes a cada una de las entidades a modelar.

Tener en cuenta que al tratarse de datos **DESNORMALIZADOS** y **DESORGANIZADOS** pueden existir inconsistencias que deberán documentar y poder controlar su impacto en el diseño de la base de datos.

Por ej. DNI duplicados, fechas invertidas o mal cargadas, gestión de ventas que pertenecen a otros vendedores, etc. La resolución de estas inconsistencias **NUNCA** debe llevar a modificar los datos originales o suponer, deducir o inferir causas y motivos.

En los procesos de migración es recurrente encontrarse con estos errores de sistemas anteriores.

La modificación de dichos datos se realizará en otra etapa de desarrollo.

-----

## Requerimientos del TP

### General

El alumno deberá primero, diseñar el nuevo modelo de datos, crear todos los componentes de base de datos y realizar la migración de datos.

Deberá luego implementar un modelo de Inteligencia de Negocios que le permita obtener información puntual para un tablero de control.

### Modelo Transaccional del Sistema

El alumno deberá diseñar el modelo de datos correspondiente y desarrollar un script de base de datos SQL Server que realice la creación de su modelo de datos transaccional y la migración de los datos de la tabla maestra a su propio modelo.

**Base de Datos**
El alumno deberá crear un modelo de datos que organice y normalice los datos de la única tabla provista por la cátedra.

Se debe incluir:

  * Creación de nuevas tablas.
  * Creación de claves primarias y foráneas para relacionar estas tablas.
  * Creación de constraints y triggers sobre estas tablas cuando fuese necesario.
  * Creación de los índices para acceder a los datos de estas tablas de manera eficiente.
  * **Migración de datos:** Se deberán cargar todas las tablas creadas en el nuevo modelo utilizando la totalidad de los datos entregados por la cátedra en la única tabla del modelo anterior. Para realizar este punto deberán utilizarse **Stored Procedures**.
  * Creación de su propio esquema con el nombre del grupo elegido

El alumno deberá entregar el DER del modelo transaccional y un único archivo de Script que al ejecutar realice todos los pasos mencionados anteriormente, en el orden correcto.

Todo el modelo de datos confeccionado por el alumno deberá ser creado y cargado correctamente ejecutando este Script una única vez.

-----

### Consideraciones

Todas las columnas creadas para las nuevas tablas deberán respetar los mismos tipos de datos de las columnas existentes en la tabla principal.

A su vez el alumno podrá crear nuevas columnas, claves e identificadores para satisfacer sus necesidades.

Pero nunca se podrá inventar información, por ejemplo, crear una sucursal o una venta que nunca existió.

Tener en cuenta que **DEBEN** crear su propio esquema con el nombre de su grupo, esto permite que tengan su espacio propio de resolución y no se mezclen y/o utilicen la solución de otro grupo o la propia que tenemos para corrección del trabajo práctico

### Modelo de Inteligencia de Negocios (BI)

En la segunda etapa el alumno deberá generar un archivo de Script que al ejecutarse realice la creación de un nuevo modelo de inteligencia de negocios y que migre los datos de su sistema transaccional a dicho modelo de datos, el cual permitirá acceder a las consultas que administren el tablero de control.

En el mismo se deberá incluir también la generación de las vistas necesarias para resolver las consultas de negocio.

**Base de Datos**
El alumno deberá crear un modelo de datos que organice y genere un modelo de BI los cuales deben soportar la ejecución de consultas simples para resolver las consultas que se definirán más adelante.

Se debe incluir:

  * Creación de nuevas tablas y vistas que componen el modelo de Inteligencia de Negocios propuesto.
  * Creación de claves primarias y foráneas para relacionar estas tablas.
  * **Migración de datos al modelo dimensional:** Cargar todas las tablas creadas en el modelo dimensional utilizando los datos ya migrados al modelo de datos transaccional creado para resolver los casos de uso definidos.

No se debe crear una nueva base de datos para la realización de las tareas anteriormente mencionadas.

Las mismas deben realizarse dentro de la misma base de datos, con un prefijo **BI\_nombre\_de\_tabla**.

El alumno deberá entregar el DER del Modelo de BI y un nuevo archivo de Script, siempre dentro del mismo esquema, que, al ejecutarse, realice todos los pasos mencionados anteriormente, en el orden correcto.

Todo el modelo de datos confeccionado por el alumno deberá ser creado y cargado correctamente ejecutando este Script una única vez.

Todas las columnas creadas para las nuevas tablas deberán respetar los mismos tipos de datos de las columnas existentes en la tabla principal.

A su vez el alumno podrá crear nuevas columnas, claves e identificadores para satisfacer sus necesidades.

### Especificación del Modelo de BI

Teniendo en cuenta el Modelo de Datos transaccional creado, que resuelve la gestión de las pedidos, ventas, compras, y envíos de la fábrica, se deberá generar un nuevo modelo de datos, de Inteligencia de Negocios, que permita unificar la información necesaria para facilitar la creación de los tableros de control a nivel gerencial.

Se deberán considerar como mínimo, las siguientes dimensiones además de las que el alumno considere convenientes:

  * Tiempo: año/cuatrimestre/mes
  * Sede
  * Rango etario alumnos
      * \<25
      * 25-35
      * 35-50
      * > 50
  * Rango etario profesores
      * 25-35
      * 35-50
      * > 50
  * Turnos Cursos
  * Categoría de Cursos
  * Modelo Sillón
  * Medio de Pago
  * Bloques de Satisfacción
      * Satisfechos: Notas entre 7 y 10
      * Neutrales: Notas entre 5 y 6
      * Insatisfechos: Notas entre 1 y 4

En función de estas dimensiones se deberán realizar una serie de vistas que deberán proveer, en forma simple desde consultas directas la siguiente información para los indicadores de negocio:

1.  **Categorías y turnos más solicitados.** Las 3 categorías de cursos y turnos con mayor cantidad de inscriptos por año por sede.
2.  **Tasa de rechazo de inscripciones:** Porcentaje de inscripciones rechazadas por mes por sede (sobre el total de inscripciones).
3.  **Comparación de desempeño de cursada por sede:** Porcentaje de aprobación de cursada por sede, por año. Se considera aprobada la cursada de un alumno cuando tiene nota mayor o igual a 4 en todos los módulos y el TP.
4.  **Tiempo promedio de finalización de curso:** Tiempo promedio entre el inicio del curso y la aprobación del final según la categoría de los cursos, por año. (Tener en cuenta el año de inicio del curso)
5.  **Nota promedio de finales.** Promedio de nota de finales según el rango etario del alumno y la categoría del curso por semestre.
6.  **Tasa de ausentismo finales:** Porcentaje de ausentes a finales (sobre la cantidad de inscriptos) por semestre por sede.
7.  **Desvío de pagos:** Porcentaje de pagos realizados fuera de término por semestre.
8.  **Tasa de Morosidad Financiera mensual.** Se calcula teniendo en cuenta el total de importes adeudados sobre facturación esperada en el mes. El monto adeudado se obtiene a partir de las facturas que no tengan pago registrado en dicho mes.
9.  **Ingresos por categoría de cursos:** Las 3 categorías de cursos que generan mayores ingresos por sede, por año.
10. **Índice de satisfacción.** Índice de satisfacción anual, según rango etario de los profesores y sede. El índice de satisfacción es igual a `((%satisfechos - %insatisfechos) + 100) / 2`. Teniendo en cuenta que:
      * Satisfechos: Notas entre 7 y 10
      * Neutrales: Notas entre 5 y 6
      * Insatisfechos: Notas entre 1 y 4

-----

## Implementación

### General

A continuación, se detalla la implementación de cada componente.

### Base de Datos

El alumno debe instalar el motor de base de datos SQL Server.

Una vez instalado el motor de base de datos se deberá instalar la herramienta cliente de trabajo: "Microsoft SQL Server Management Studio Express" para SQL Server 2019. Ejecutar esta aplicación e ingresar los datos del usuario "sa" creado anteriormente (en modo "Autenticación de SQL Server").

Dentro del "Management Studio" deberá crear una nueva base de datos con los parámetros por defecto y nombre de base "GD2C2025".

Una vez que se encuentra la base de datos creada y configurada con el usuario, es necesario ejecutar los dos scripts provistos.

Para ello se debe ejecutar un comando de consola de SQL Server llamada "sqlcmd".

Este comando debe ejecutar en orden los siguientes dos archivos:

  * **gd\_esquema.Schema.sql:** Este archivo genera un esquema llamado "gd\_esquema" dentro de la base de datos y lo asigna al usuario "gd".
  * **gd\_esquema.Maestra.Table.sql:** Este archivo crea la tabla principal del trabajo práctico y la carga con los datos correspondientes. El archivo posee un volumen significante y no puede ser ejecutado desde el "Managment Studio".

La cátedra provee un archivo BATCH para ejecutar esta operación, denominado "EjecutarScriptTablaMaestra.bat".

Haciendo doble clic sobre el mismo se ejecutan ambos archivos ("gd\_esquema.Schema.sql" y "gd\_esquema.Maestra.Table.sql") a través del modo consola.

El Script necesita aproximadamente 40 minutos para finalizar su ejecución.

> sqlcmd -S \<Servidor\\Instancia\>-U \<Nombre\_de\_usuario\>-P \<Password\> -i \<Nombre\_del\_archivo1\>,\<Nombre\_del\_archivo2\> -a 32767

**Ejemplo:**

> sqlcmd -S localhost\\SQLSERVER2019 -U gd -P gd2019 -i gd\_esquema.Schema.sql,gd\_esquema.Maestra.Table.sql -a 32767 -0 resultado\_output.txt

**ACLARACIÓN:** Una aclaración respecto a la autenticación del usuario. En caso de haber seleccionado la "Autenticación de Windows", durante la configuración de la base de datos, al script anteriormente mencionado no debe agregarse "-U \<Nombre\_de\_usuario\> -P \<Password\>" dado que solamente se utilizará en el caso de que la base de datos este configurada como autenticación mixta, por eso debe especificarse explícitamente el usuario y contraseña.

Luego de cargados todos los datos de la tabla maestra, el alumno deberá crear su propio esquema dentro de la base de datos.

El nombre del esquema deberá ser igual al nombre del grupo registrado en la materia (el proceso de registración se explica más adelante).

El nombre del esquema debe ser en mayúsculas, sin espacios y separado por guiones bajos.

Ejemplo "Los mejores" debe ser "LOS\_MEJORES".

Todas las tablas, stored procedures, vistas, triggers y otros objetos de base de datos nuevos que cree el alumno deberán pertenecer a este esquema creado.

Si la solución entregada posee objetos de base de datos por fuera del esquema con el nombre del grupo, el TP será rechazado sin evaluar su funcionalidad.

Con esta configuración el alumno está listo para empezar la implementación de la parte de base de datos.

### Restricciones

El motor de base de datos deberá ser Microsoft SQL Server 2019. Tanto la versión Express, como la versión full sirven para realizar el trabajo.

No podrá utilizarse ninguna herramienta auxiliar que ayude a realizar la migración de datos.

Tampoco podrá desarrollarse una aplicación personalizada para la migración de datos.

La misma deberá ser efectuada en código T-SQL en el archivo de script "script\_creacion\_inicial.sql".

-----

## Condiciones de Evaluación y Aprobación

### Testing de Scripts

El alumno entregará a lo largo del TP dos scripts:

  * **Script de base de datos transaccional (script\_creacion\_inicial.sql)** con todo lo necesario para crear su modelo transaccional y cargarlo con los datos correspondientes.
  * **Script de base de datos BI (script\_creacion\_Bl.sql)** con todo lo necesario para crear el modelo de BI, poblarlo correctamente y crear las vistas solicitadas sobre el mismo.

La cátedra probará el Trabajo Práctico en el siguiente orden:

1.  Se dispondrá de una base de datos limpia igual a la original entregada a los alumnos.
2.  Se ejecutará el archivo **script\_creacion\_inicial.sql**. proporcionado por el alumno. Este archivo deberá tener absolutamente todo lo necesario para crear y cargar el modelo de datos correspondiente. Toda la ejecución deberá realizarse en orden y sin ningún tipo de error ni warning.
3.  Se ejecutará el archivo **script\_creacion\_Bl.sql** proporcionado por el alumno. Este archivo deberá tener absolutamente todo lo necesario para crear y cargar el modelo de BI. Toda la ejecución deberá realizarse en orden y sin ningún tipo de error ni warning.

Los archivos "script\_creacion\_inicial.sql" y "script\_creacion\_Bl.sql deben contener todo lo necesario para crear el modelo de datos correspondiente y cargarlo con los datos. Si el alumno utilizó alguna herramienta auxiliar o programa customizado, el mismo no será utilizado por la cátedra.

Si en su ejecución se produjeran errores, el trabajo práctico será rechazado sin continuar su evaluación.

Todos los objetos de base de datos creados por el usuario deben pertenecer al esquema de base de datos creado con el nombre del grupo.

Si esta restricción no se cumple el trabajo práctico será rechazado sin continuar su evaluación.

También deberán ser considerados criterios de performance a la hora de crear relaciones e índices en las tablas.

### Consultas SQL

Todas las consultas SQL que haga la aplicación serán evaluadas de acuerdo al estándar de programación SQL explicado en clase.

La performance de las mismas será tenida en cuenta a la hora de fijar la nota.

-----

## Entregas

### Fechas de entrega y condiciones

A continuación se detallan las entregas que deberán realizarse y cuáles son las condiciones generales y específicas para cada una de ellas.

**Entrega del DER**
En esta primera entrega deberá enviarse solamente el DER del sistema en un archivo formato imagen, preferentemente JPG, el cual debe estar realizado con una herramienta acorde y ser netamente legible, no pixelado, con todas sus relaciones y campos que componen la entidad.

No se aceptarán imágenes de DER realizado a mano, en lápiz, birome, etc.

**Fecha:** 02/10/2025 hasta las 12:00hs del mediodía (GMT 3:00 Buenos Aires).

En caso de que el DER no sea correcto, los errores serán informados en la corrección y deberán ser resueltos para la entrega del MODELO RELACIONAL.

Esto quiere decir que no hay reentrega específica del DER.

La motivación de esta entrega es la corrección de errores en el modelado de la base de datos antes del proceso de migración.

**Entrega de Modelo de Datos Relacional y Migración**
En esta entrega se deberán enviar:

  * El script de creación y migración de datos (un único script) del modelo relacional según el formato especificado en la sección de formato de entrega del presente documento.
  * DER del modelo correspondiente (Corregido en el caso que corresponda)
  * Documento de estrategia que respalde las decisiones tomadas.

Modelo de datos y migración
**Fecha:** 30/10/2025 hasta las 12:00hs del mediodía (GMT 3:00 Buenos Aires).

**Entrega de BI**
En esta entrega se deberán enviar:

  * DER del modelo relacional (Corregido en el caso que corresponda)
  * El script de creación del modelo relacional y migración de datos (Corregido en el caso que corresponda)
  * DER del modelo de BI correspondiente.
  * El script de creación y carga de datos (un único script) del modelo de BI según el formato especificado en la sección de formato de entrega del presente documento.
  * Documento de estrategia actualizado que respalde las decisiones tomadas.

Entrega del Modelo de BI y la carga de datos
**Fecha:** 21/11/2025 hasta las 12:00hs del mediodía (GMT 3:00 Buenos Aires).

### Condiciones de Entregas

  * Para cada entrega existe una sola fecha de entrega posible como límite.
  * En el caso del DER solo existe una única entrega, es decir, una vez corregido no hay re entregas intermedias.
  * Si al momento de recibir la corrección deben realizar modificaciones, las mismas serán observadas al momento de entregar la migración del modelo relacional.
  * Existen **SOLO 2 (dos) posibilidades de re entrega** en total, independientemente si se trata del modelo relacional o el modelo de BI.
  * Tanto la entrega del Modelo Relacional como el Modelo BI deben contar con un DER que respalde el modelo y facilite su corrección e interpretación, además de los comentarios que crean necesarios en el apartado de estrategia.
  * La entrega del TP es grupal y la responsabilidad es de todos los integrantes del grupo para llegar en fecha.
  * Los TPs entregados luego del horario indicado, se considerarán fuera de término perdiendo así una posibilidad de entrega y restándole un instancia de presentación.
  * Las 2(dos) instancias de reentrega disponibles no tienen fecha asignada y serán determinadas por el equipo para entregar cuando consideren, bajo responsabilidad de los alumnos, siempre y cuando no exceda la fecha final del TP.
  * Una vez entregado el TP, el periodo de corrección es aproximadamente de 7 días.
  * Este factor puede variar dependiendo de la cantidad de TPs entregados en ese momento.
  * Por lo cual, se recomienda tenerlo en cuenta para la fecha final de entrega del trabajo.
  * Si llegaran a realizar una sola entrega del TP, cercana a la última fecha (menor a 7 días), es netamente responsabilidad del grupo y solo contarán con esa entrega habiendo perdido las chances anteriormente descritas, es decir, única entrega sin posibilidad de re entrega.
  * Cualquier indicio de copia (similitudes de edición, bloques de código, mismas descripciones, comentarios, etc.) será penado con la pérdida de la materia, aun así, tengan los parciales aprobados.
  * Se supone que el TP tiene carácter de parcial y es una producción propia del grupo.

**Fecha Final**
La última fecha para recepción de TP es el día **05/12/2025**
