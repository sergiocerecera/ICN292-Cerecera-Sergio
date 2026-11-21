

A partir del modelo de datos implementado en SQLite se desarrollaron consultas orientadas a revisar situaciones que pueden ser útiles para la gestión diaria de Integraltax Servicios Ltda. El objetivo no es solamente comprobar que la base funciona, sino también mostrar que la información almacenada permite responder preguntas concretas sobre pendientes, tiempos de acceso, dependencia de equipos, respaldos y control de versiones.

Las consultas se ejecutaron sobre la base creada con `schema.sql` y poblada mediante `seed.sql`. Los resultados incluidos a continuación corresponden a los datos de prueba actualmente registrados en la base.



Esta consulta permite identificar solicitudes en las que el antecedente no fue encontrado y que continúan abiertas. Además, muestra quién realizó la consulta, qué documento se buscaba y quién quedó responsable del seguimiento.

```sql
SELECT
    c.id_consulta,
    cl.razon_social AS cliente,
    co.nombre AS colaborador,
    td.nombre_tipo AS tipo_documento,
    c.periodo_buscado,
    s.accion,
    r.nombre AS responsable
FROM CONSULTA AS c
JOIN CLIENTE AS cl
    ON cl.id_cliente = c.id_cliente
JOIN COLABORADOR AS co
    ON co.id_colaborador = c.id_colaborador
LEFT JOIN TIPO_DOCUMENTO AS td
    ON td.id_tipo_documento = c.id_tipo_documento
LEFT JOIN SEGUIMIENTO AS s
    ON s.id_consulta = c.id_consulta
   AND s.fecha_resolucion IS NULL
LEFT JOIN COLABORADOR AS r
    ON r.id_colaborador = s.id_responsable
WHERE c.resultado = 'faltante'
  AND c.fecha_hora_fin IS NULL
ORDER BY c.fecha_hora_inicio;
```

**Resultado obtenido**

| id_consulta | cliente | colaborador | tipo_documento | periodo_buscado | accion | responsable |
|---:|---|---|---|---|---|---|
| 9 | Panadería Trigal Sur SpA | Diego Fuentes | Declaración F29 | 2026-11-01 | Solicitar al cliente el F29 correspondiente a noviembre de 2026. | Diego Fuentes |
| 10 | Comercial Los Maitenes SpA | Camila Araya | Declaración F22 | 2026-01-01 | Coordinar la entrega de la declaración anual de renta pendiente. | Camila Araya |

**Interpretación**

En los datos de prueba existen dos consultas que siguen pendientes. La utilidad de esta consulta es que permite visualizar rápidamente qué solicitudes todavía requieren una acción y quién debe hacerse cargo. Esto evita que un faltante quede solamente registrado como una búsqueda fallida y permite darle continuidad hasta que el antecedente sea recibido.



Esta consulta calcula el tiempo transcurrido entre el inicio de una búsqueda y el momento en que el documento fue efectivamente encontrado y puesto a disposición. El cálculo se realiza solamente sobre consultas que terminaron con resultado `entregada`.

```sql
SELECT
    ROUND(
        AVG(
            (julianday(fecha_hora_acceso) - julianday(fecha_hora_inicio))
            * 24 * 60
        ),
        2
    ) AS promedio_minutos,

    MIN(
        ROUND(
            (julianday(fecha_hora_acceso) - julianday(fecha_hora_inicio))
            * 24 * 60,
            2
        )
    ) AS minimo_minutos,

    MAX(
        ROUND(
            (julianday(fecha_hora_acceso) - julianday(fecha_hora_inicio))
            * 24 * 60,
            2
        )
    ) AS maximo_minutos,

    COUNT(*) AS consultas_evaluadas

FROM CONSULTA
WHERE resultado = 'entregada'
  AND fecha_hora_acceso IS NOT NULL;
```

**Resultado obtenido**

| promedio_minutos | minimo_minutos | maximo_minutos | consultas_evaluadas |
|---:|---:|---:|---:|
| 5.11 | 3.00 | 12.00 | 9 |

**Interpretación**

Para las nueve consultas entregadas registradas en la base, el tiempo promedio de acceso fue de aproximadamente 5,11 minutos. El menor tiempo observado fue de 3 minutos y el mayor de 12 minutos. Este resultado permite establecer una referencia para el indicador de tiempo de búsqueda y, posteriormente, comparar si el uso del repositorio centralizado disminuye los tiempos de acceso.



Esta consulta revisa dos aspectos relacionados con el problema inicial de la empresa: cuántas consultas pudieron resolverse sin depender del computador donde originalmente se encontraba el archivo y cuántas quedaron bloqueadas por esa dependencia.

```sql
SELECT
    COUNT(*) AS consultas_entregadas,

    SUM(
        CASE
            WHEN requirio_equipo_origen = 0 THEN 1
            ELSE 0
        END
    ) AS independientes_equipo_origen,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN requirio_equipo_origen = 0 THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS porcentaje_independientes,

    SUM(
        CASE
            WHEN bloqueada_por_equipo = 1 THEN 1
            ELSE 0
        END
    ) AS bloqueadas_por_equipo,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN bloqueada_por_equipo = 1 THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS porcentaje_bloqueadas

FROM CONSULTA
WHERE resultado = 'entregada';
```

**Resultado obtenido**

| consultas_entregadas | independientes_equipo_origen | porcentaje_independientes | bloqueadas_por_equipo | porcentaje_bloqueadas |
|---:|---:|---:|---:|---:|
| 9 | 7 | 77.78 | 1 | 11.11 |

**Interpretación**

De las nueve consultas entregadas, siete se resolvieron sin depender del computador de origen, lo que representa un 77,78 %. Además, una de las consultas registró una interrupción asociada al equipo de origen, equivalente a un 11,11 % de las consultas evaluadas. Estos valores permiten observar de manera directa si la solución propuesta logra disminuir la dependencia de computadores individuales, que corresponde a uno de los principales problemas detectados en el proceso actual.


La siguiente consulta permite revisar el estado de cada respaldo y calcular qué porcentaje de los archivos evaluados pudo recuperarse correctamente.

```sql
SELECT
    id_respaldo,
    fecha_ejecucion,
    estado,
    archivos_evaluados,
    archivos_recuperados,
    ROUND(
        100.0 * archivos_recuperados
        / NULLIF(archivos_evaluados, 0),
        2
    ) AS porcentaje_recuperacion
FROM RESPALDO
ORDER BY fecha_ejecucion;
```

**Resultado obtenido**

| id_respaldo | fecha_ejecucion | estado | archivos_evaluados | archivos_recuperados | porcentaje_recuperacion |
|---:|---|---|---:|---:|---:|
| 1 | 2026-11-10T23:00:00Z | exitoso | 20 | 20 | 100.00 |
| 2 | 2026-11-17T23:00:00Z | exitoso | 20 | 20 | 100.00 |
| 3 | 2026-11-18T23:00:00Z | fallido | 20 | 17 | 85.00 |
| 4 | 2026-11-20T23:00:00Z | exitoso | 20 | 20 | 100.00 |

**Interpretación**

Tres de los cuatro respaldos registrados lograron recuperar la totalidad de los archivos evaluados. La ejecución del 18 de noviembre presentó una recuperación de 85 %, lo que permite identificar claramente una situación que requiere revisión. Registrar estos resultados en la base permite no limitar el respaldo a la existencia de una copia, sino también verificar si los archivos pueden recuperarse correctamente.


Como consulta complementaria, se revisaron los documentos que han tenido actualizaciones. Esto permite comprobar que el sistema mantiene un historial en lugar de reemplazar directamente el archivo anterior.

```sql
SELECT
    cl.razon_social AS cliente,
    d.titulo,
    COUNT(v.id_version) AS versiones_registradas,
    MAX(v.numero_version) AS version_vigente
FROM DOCUMENTO AS d
JOIN CLIENTE AS cl
    ON cl.id_cliente = d.id_cliente
JOIN VERSION_DOCUMENTO AS v
    ON v.id_documento = d.id_documento
GROUP BY
    d.id_documento,
    cl.razon_social,
    d.titulo
HAVING COUNT(v.id_version) > 1
ORDER BY
    cl.razon_social,
    d.titulo;
```

**Resultado obtenido**

| cliente | titulo | versiones_registradas | version_vigente |
|---|---|---:|---:|
| Comercial Los Maitenes SpA | Liquidaciones de sueldo - octubre 2026 | 2 | 2 |
| Transportes Valle Claro Ltda. | Declaración F29 - septiembre 2026 | 2 | 2 |

**Interpretación**

En los datos cargados existen dos documentos con más de una versión. En ambos casos la versión más reciente corresponde a la número 2. Esto permite comprobar que las actualizaciones se registran como nuevas versiones y que el historial anterior permanece disponible, manteniendo trazabilidad sobre los cambios realizados.



Las consultas desarrolladas muestran que la base de datos permite apoyar distintas decisiones operativas del SIG. Por una parte, se pueden detectar consultas pendientes y asignar responsables para su seguimiento. Por otra, es posible medir el tiempo de acceso a los antecedentes, observar la dependencia respecto del computador de origen y revisar la efectividad de los respaldos.

Además, el registro de versiones permite conservar el historial documental sin reemplazar los antecedentes anteriores. En conjunto, estas consultas permiten transformar los registros almacenados por el sistema en información útil para controlar el funcionamiento del proceso y evaluar si la solución propuesta efectivamente mejora la disponibilidad, trazabilidad y continuidad de la información.


Para reproducir los resultados:

1. Crear una base SQLite vacía.
2. Ejecutar `schema.sql`.
3. Ejecutar `seed.sql`.
4. Ejecutar las consultas anteriores en DB Browser for SQLite o en otro cliente compatible con SQLite.

Los resultados mostrados en este archivo corresponden al contenido actual de `seed.sql`.
