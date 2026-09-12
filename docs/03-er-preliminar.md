# 03 - Modelo ER preliminar

## Descripción

El modelo entidad-relación (ER) se construyó a partir del problema de gestión documental de Integraltax y del proceso TO-BE.

El objetivo es representar la información necesaria para centralizar los documentos de clientes, controlar los accesos, registrar las consultas y realizar respaldos.

## Entidades principales

- **COLABORADOR:** personas que utilizan el sistema.
- **CLIENTE:** clientes cuyos antecedentes serán almacenados.
- **CARTERA:** permite relacionar clientes con los colaboradores responsables.
- **TIPO_DOCUMENTO:** clasifica los documentos almacenados.
- **DOCUMENTO:** representa cada documento asociado a un cliente.
- **VERSION_DOCUMENTO:** permite mantener las distintas versiones de un documento.
- **PERMISO:** controla el acceso de los usuarios a la documentación.
- **CONSULTA:** registra las búsquedas o consultas realizadas.
- **RESPALDO:** representa los respaldos realizados por el sistema.
- **RESPALDO_DOCUMENTO:** relaciona los documentos con los respaldos correspondientes.

## Relación con el problema

El modelo busca solucionar principalmente la dispersión de documentos entre computadores individuales. Para esto, las entidades DOCUMENTO y VERSION_DOCUMENTO permiten centralizar y controlar los archivos.

Las entidades PERMISO y CONSULTA permiten controlar quién accede a la información y mantener trazabilidad de las consultas.

Finalmente, RESPALDO y RESPALDO_DOCUMENTO permiten representar el respaldo de la documentación y su posterior recuperación.

## Diagrama ER

El diagrama entidad-relación preliminar corresponde al modelo desarrollado para la Entrega 1. En la Entrega 2 este modelo será utilizado como base para la implementación de la base de datos.
