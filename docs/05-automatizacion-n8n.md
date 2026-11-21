# Automatización del respaldo documental

El flujo usa **Python 3.11 o superior, SQLite y el programador del sistema**. Es la herramienta equivalente a n8n contemplada en la sección F.4 de la E1. Su entrada es el inventario de versiones del SIG. Su salida es una copia recuperable y el resultado de la ejecución. El código utiliza solo la biblioteca estándar.

[Flujo ejecutable](../automatizacion/respaldo.py) · [Prueba reproducible](../automatizacion/prueba.py) · [BPMN, recorrido de respaldo](02-bpmn.md)

| Paso del BPMN | Qué hace el flujo |
|---|---|
| Horario programado | El programador invoca el mismo comando que usa la prueba manual. |
| Copiar base y archivos versionados | Reserva la escritura de SQLite, obtiene una instantánea y lee todas las rutas de VERSION_DOCUMENTO. Incluye versiones históricas y vigentes. Calcula SHA-256 de los archivos y de la base. |
| Ensayar restauración y verificar archivos | Extrae el ZIP en una carpeta temporal separada. Abre la base recuperada, ejecuta la comprobación de integridad y compara los contenidos mediante sus hashes. La base activa permanece en su lugar. |
| Publicar copia y registrar éxito | Publica el ZIP en el destino con nombre único. Registra la ejecución y un resultado por documento. Un documento es correcto cuando se recuperan todas sus rutas. |
| Registrar falla y emitir alerta | Una ruta ausente o una diferencia de contenido impide publicar el paquete. El programa informa el motivo por la salida de error y termina con código 1. Registra el estado fallido cuando la base permite escribir. |
| Revisar alerta y corregir causa | Administración técnica revisa la salida, recupera el archivo fuente o resuelve el problema del destino y vuelve a ejecutar el comando. Cada intento genera su propio registro si la base está disponible. |

## Reproducir desde la raíz del repositorio

1. Comprobar la instalación con `python3 --version`. En Windows se puede usar `py -3.11` en los comandos.
2. Ejecutar la prueba aislada. Crea un directorio temporal con un documento técnico de dos versiones, invoca el flujo, comprueba la recuperación y después retira un archivo para activar la falla controlada. Verifica el código de salida, la alerta, las filas de la bitácora y la conservación de la copia anterior. Al terminar elimina únicamente su directorio temporal.

   ```bash
   python3 automatizacion/prueba.py
   ```

   Salida comprobada durante la preparación del punto 2:

   ```text
   OK | Copia restaurada: 2/2 archivos de prueba. Un documento con dos versiones.
   OK | Archivo ausente: alerta, estado fallido y copia anterior conservada.
   ```

3. Para el piloto del grupo, cargar primero su esquema y sus datos. Ajustar las tres rutas del comando siguiente. La primera debe apuntar a la base existente; la segunda, al directorio raíz de archivos reales del piloto; la tercera, al destino de copias, idealmente en una unidad independiente. Detener las cargas de archivos durante el ensayo. La reserva de SQLite bloquea las escrituras en la base; no impide cambios directos en el sistema de archivos.

   ```bash
   python3 automatizacion/respaldo.py /ruta/piloto.sqlite /ruta/documentos /ruta/copias
   ```

4. Comprobar que el JSON devuelto identifica la ejecución y el ZIP. Dentro del ZIP quedan `base.sqlite`, `archivos/` y `manifest.json`. La base copiada refleja el instante anterior al registro del propio respaldo. Consultar la base **activa** para verificar la bitácora:

   ```sql
   SELECT id_respaldo, fecha_ejecucion, tipo, estado
   FROM RESPALDO ORDER BY id_respaldo DESC;
   SELECT id_respaldo, id_documento, resultado_restauracion
   FROM RESPALDO_DOCUMENTO ORDER BY id_respaldo DESC, id_documento;
   ```

5. Para repetir automáticamente en Linux, abrir `crontab -e` en el equipo del piloto. Este ejemplo usa las 20:00, hora local. Sustituir todas las rutas y crear previamente la carpeta de registros. La salida normal deja el identificador y los conteos; la de error queda en el archivo de alertas que revisa administración técnica.

   ```cron
   0 20 * * * /ruta/python3 /ruta/repo/automatizacion/respaldo.py /ruta/piloto.sqlite /ruta/documentos /ruta/copias >> /ruta/registros/respaldos.log 2>> /ruta/registros/alertas.log
   ```

   En Windows, crear una tarea diaria en el Programador de tareas. Como programa usar el ejecutable de Python y como argumentos pasar las cuatro rutas entre comillas (script, base, documentos y copias). Para conservar los avisos, ejecutar el comando desde un archivo de comandos que redirija la salida normal y la de error a archivos de registro.

## Contrato con el esquema E2

La lectura usa `VERSION_DOCUMENTO(id_documento, numero_version, ruta_almacenamiento)`; cada ruta debe ser relativa a la raíz documental y referirse a contenido estable. Se escribe en `RESPALDO(id_respaldo, fecha_ejecucion, tipo, estado)` y `RESPALDO_DOCUMENTO(id_respaldo, id_documento, resultado_restauracion)`. Se espera una PK entera autogenerada para el respaldo. El script usa fecha UTC, tipo `completo`, estados `exitoso` y `fallido`, y resultados `correcto` o `fallido`. Si la carga falla antes de evaluar los archivos, la bitácora de ejecución registra el error sin atribuir un resultado de restauración a documentos sin evaluar. Un problema de acceso a la propia base solo puede informarse por la salida de error.

**K3 y alcance de la prueba.** K3 = 100 × archivos recuperados correctamente / archivos evaluados. En el ensayo positivo se recuperaron ambas rutas (2/2). En el ensayo de archivo ausente, la copia falla antes de la restauración y K3 no se calcula. La meta RNF04 de la E1 es al menos 95 %. Estos dos marcadores permiten demostrar la mecánica; el cumplimiento en Integraltax requiere repetir la prueba con el inventario del piloto. El ZIP incluye los archivos referenciados por versiones. La prueba aislada utiliza el contrato de la E1; el esquema SQL definitivo, el destino independiente y la programación deben comprobarse en el equipo del grupo.
