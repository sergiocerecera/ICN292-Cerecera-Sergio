# 02 - BPMN

## Proceso AS-IS

El proceso actual corresponde a la gestión y recuperación de antecedentes de los clientes de Integraltax Servicios Ltda., empresa que presta servicios contables, tributarios y de remuneraciones.

Actualmente, los documentos son recibidos principalmente mediante canales como correo electrónico y WhatsApp. El colaborador responsable descarga los archivos y normalmente los almacena en su computador personal. Posteriormente, trabaja con ellos utilizando herramientas como Word, Excel o los sistemas especializados de la empresa.

Cuando otro colaborador necesita consultar un antecedente, debe solicitarlo a la persona que lo tiene almacenado. Esta última debe buscarlo entre sus carpetas y enviarlo o permitir el acceso remoto, siempre que su computador se encuentre disponible.

Esta forma de trabajo genera distintos problemas:

- Dependencia de los computadores personales de los colaboradores.
- Dificultad para compartir documentos entre personas que trabajan de manera remota.
- Demoras en la búsqueda y recuperación de antecedentes.
- Riesgo de utilizar versiones desactualizadas.
- Posibilidad de perder información cuando un equipo presenta fallas o no está disponible.
- Falta de un registro centralizado de las consultas y acciones realizadas.

Por lo tanto, el principal problema del proceso actual es la descentralización de la documentación y la dependencia de los equipos individuales para acceder a ella.

## Proceso TO-BE

La propuesta consiste en incorporar un Sistema de Información para la Gestión documental que permita centralizar los antecedentes de los clientes, controlar los permisos de acceso y mantener un historial de versiones.

El sistema complementa las herramientas actuales de remuneraciones y tributación de Integraltax, sin reemplazarlas.

### Recepción de antecedentes

Cuando un cliente envía un documento, el colaborador responsable identifica al cliente, carga el archivo y selecciona su clasificación documental.

El sistema valida los permisos de escritura y los metadatos correspondientes. Si la información está incompleta, se solicita su corrección. Si no existe autorización, se registra el rechazo mediante la bitácora de acciones.

Cuando las validaciones son correctas, el documento queda incorporado al repositorio y se registra su versión correspondiente.

### Consulta de documentos

Cuando un colaborador necesita un antecedente, realiza una búsqueda desde su sesión en el sistema.

Antes de mostrar información sobre el documento, el SIG comprueba que el usuario tenga los permisos necesarios.

Se pueden presentar tres situaciones:

- **Acceso autorizado y documento disponible:** el colaborador puede consultar o descargar la versión vigente.
- **Acceso autorizado, pero documento faltante:** se registra la consulta y se solicita el antecedente al cliente. La directora puede asignar un responsable para realizar el seguimiento.
- **Acceso denegado:** el sistema registra la acción y el motivo del rechazo en BITACORA_ACCION.

Cuando el cliente entrega el documento pendiente, se inicia nuevamente el proceso de recepción.

### Actualización de documentos

Cuando se requiere modificar un antecedente, el sistema valida que el colaborador tenga permiso de escritura.

La actualización genera una nueva versión del documento, conservando las anteriores para mantener el historial y permitir identificar cuál corresponde a la versión vigente.

### Seguimiento de consultas pendientes

Las consultas en las que no se encuentra el documento quedan registradas para evitar que la solicitud se pierda.

La directora puede asignar un responsable y supervisar las acciones necesarias para obtener el antecedente. Una vez resuelta la solicitud, se registra su cierre.

### Respaldo documental

El proceso también contempla una ejecución programada de respaldos.

La rutina desarrollada en Python utiliza la base de datos SQLite y las rutas de las versiones documentales para generar una copia comprimida.

Posteriormente, verifica la integridad de la base de datos y comprueba los archivos recuperados mediante huellas SHA-256.

Si la verificación es correcta, registra el resultado del respaldo. Si se detecta la ausencia de un archivo o una falla, conserva la copia anterior y genera una alerta para que administración técnica revise el problema.

La ejecución se realiza mediante el programador de tareas del sistema operativo.

## Mejoras principales

- Centralización de los documentos en un repositorio común.
- Menor dependencia de los computadores personales.
- Control de permisos de lectura y escritura.
- Registro de consultas, rechazos y acciones realizadas.
- Seguimiento de antecedentes faltantes y asignación de responsables.
- Conservación del historial de versiones.
- Respaldo programado con verificación de integridad y recuperación.

## Diagramas BPMN

Los diagramas permiten comparar el funcionamiento actual con el proceso propuesto para Integraltax.

- **BPMN AS-IS:** representa el proceso actual de recepción, almacenamiento y recuperación de documentos.
- **BPMN TO-BE:** representa el proceso actualizado, incluyendo recepción, consultas, validación de permisos, seguimiento de faltantes y respaldo programado.

El diagrama TO-BE final y su archivo editable se encuentran en la carpeta `assets/` del repositorio, junto con los demás recursos del proyecto.

## Automatización y documentación relacionada

La implementación del respaldo se encuentra desarrollada en Python.

Los archivos principales son:

- `automatizacion/respaldo.py`: rutina de respaldo documental.
- `automatizacion/prueba.py`: pruebas de funcionamiento y recuperación.
- `docs/05-automatizacion-n8n.md`: documentación de la ejecución, configuración y resultados de las pruebas.

La automatización fue probada con dos archivos de prueba. En el ensayo positivo se recuperaron ambos archivos (2/2), mientras que en el ensayo negativo se detectó la ausencia de un archivo, se generó una alerta y se conservó el respaldo anterior.

La prueba demuestra el funcionamiento de la rutina, pero todavía se requiere validar la recuperación con el inventario documental completo de un piloto real.
