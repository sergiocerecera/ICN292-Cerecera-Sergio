# 01 - Requerimientos

Los requerimientos se definieron a partir del problema de gestión documental identificado en Integraltax. El sistema busca centralizar, organizar y facilitar el acceso a la documentación de los clientes.

## Requerimientos funcionales

| ID | Requerimiento | Prioridad |
|---|---|---|
| RF01 | Gestionar usuarios, identificando a cada usuario para asociar sus acciones y permisos. | Must |
| RF02 | Registrar y gestionar la información de los clientes a los que se asociarán los documentos. | Must |
| RF03 | Cargar y almacenar documentos asociados a un cliente en un repositorio centralizado. | Must |
| RF04 | Clasificar y organizar los documentos según cliente, tipo de documento y período. | Must |
| RF05 | Buscar documentos utilizando criterios asociados a la información registrada. | Must |
| RF06 | Permitir que los usuarios autorizados consulten y descarguen los documentos almacenados. | Must |
| RF07 | Gestionar permisos de acceso a la documentación según el usuario. | Must |
| RF08 | Gestionar las distintas versiones de un documento y mantener disponible su historial. | Should |

## Requerimientos no funcionales

| ID | Atributo | Requerimiento / criterio | Prioridad |
|---|---|---|---|
| RNF01 | Seguridad | El sistema deberá restringir el acceso a la documentación según los permisos asignados a cada usuario. | Must |
| RNF02 | Disponibilidad | La documentación deberá estar disponible para los usuarios autorizados sin depender del computador donde originalmente fue almacenada. | Must |
| RNF03 | Rendimiento | La consulta de un documento deberá realizarse en un tiempo máximo de 60 segundos. | Must |
| RNF04 | Respaldo | El sistema deberá permitir recuperar al menos el 95% de los archivos desde una copia de respaldo ante una pérdida de información. | Must |
| RNF05 | Usabilidad | Las funciones principales del sistema deberán poder ser utilizadas por los colaboradores sin requerir conocimientos técnicos especializados. | Should |

## Priorización MoSCoW

Se consideraron como **Must Have** los requerimientos necesarios para contar con una primera versión funcional del sistema.

**Must Have:** RF01, RF02, RF03, RF04, RF05, RF06, RF07, RNF01, RNF02, RNF03 y RNF04.

**Should Have:** RF08 y RNF05.
