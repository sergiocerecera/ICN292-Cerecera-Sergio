"""Respaldo y ensayo de recuperación del piloto documental Integraltax."""
import argparse
from collections import defaultdict
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import sqlite3
import sys
import tempfile
import uuid
from zipfile import ZipFile, ZIP_DEFLATED


def digest(path):
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def ejecutar(db, archivos, destino):
    db, archivos, destino = (p.resolve() for p in (db, archivos, destino))
    if not db.is_file() or not archivos.is_dir():
        raise ValueError("Compruebe la base de datos y la carpeta de documentos.")
    if destino.is_relative_to(archivos) or db.is_relative_to(archivos):
        raise ValueError("Separe la base, el repositorio documental y el destino.")
    destino.mkdir(parents=True, exist_ok=True)
    fecha = datetime.now(timezone.utc).isoformat()
    nombre = "respaldo-" + uuid.uuid4().hex + ".zip"
    with sqlite3.connect(db) as registro, tempfile.TemporaryDirectory(dir=destino) as temp:
        raiz = Path(temp)
        registro.execute("PRAGMA foreign_keys=ON")
        filas = {}
        try:
            # El bloqueo reserva la escritura hasta publicar la copia y la bitácora.
            registro.execute("BEGIN IMMEDIATE")
            with sqlite3.connect(db) as lectura, sqlite3.connect(raiz / "base.sqlite") as copia:
                lectura.backup(copia)
                inventario = list(copia.execute(
                    "SELECT id_documento, ruta_almacenamiento FROM VERSION_DOCUMENTO "
                    "ORDER BY id_documento, numero_version"))
            if not inventario:
                raise ValueError("El piloto carece de versiones para ensayar la restauración.")
            hashes = {"base.sqlite": digest(raiz / "base.sqlite")}
            rutas = defaultdict(set)
            with ZipFile(raiz / nombre, "w", ZIP_DEFLATED) as paquete:
                paquete.write(raiz / "base.sqlite", "base.sqlite")
                for documento, ruta in inventario:
                    relativa = Path(ruta)
                    origen = (archivos / relativa).resolve()
                    if relativa.is_absolute() or ".." in relativa.parts or not origen.is_relative_to(archivos):
                        raise ValueError("Ruta documental fuera del repositorio.")
                    if not origen.is_file():
                        raise ValueError(f"Falta el archivo de la versión: {ruta}")
                    clave = "archivos/" + relativa.as_posix()
                    rutas[documento].add(clave)
                    if clave not in hashes:
                        hashes[clave] = digest(origen)
                        paquete.write(origen, clave)
                paquete.writestr("manifest.json", json.dumps(hashes, indent=2))
            with ZipFile(raiz / nombre) as paquete:
                recuperado = raiz / "ensayo"
                paquete.extractall(recuperado)
            with sqlite3.connect(recuperado / "base.sqlite") as ensayo:
                if digest(recuperado / "base.sqlite") != hashes["base.sqlite"] or ensayo.execute(
                        "PRAGMA integrity_check").fetchone() != ("ok",):
                    raise ValueError("Falló la verificación de la base restaurada.")
            verificados = {k: digest(recuperado / k) == v for k, v in hashes.items() if k.startswith("archivos/")}
            filas = {doc: "correcto" if all(verificados[k] for k in claves) else "fallido"
                     for doc, claves in rutas.items()}
            if not all(verificados.values()):
                raise ValueError("El contenido restaurado difiere del archivo de origen.")
            (raiz / nombre).replace(destino / nombre)
            estado, detalle = "exitoso", nombre
        except Exception as error:
            estado, detalle = "fallido", str(error)
        try:
            clave = registro.execute(
                "INSERT INTO RESPALDO(fecha_ejecucion,tipo,estado) VALUES (?,?,?)",
                (fecha, "completo", estado)).lastrowid
            registro.executemany(
                "INSERT INTO RESPALDO_DOCUMENTO(id_respaldo,id_documento,resultado_restauracion) "
                "VALUES (?,?,?)", [(clave, doc, res) for doc, res in filas.items()])
            registro.commit()
        except Exception:
            (destino / nombre).unlink(missing_ok=True)
            raise
        salida = dict(id_respaldo=clave, estado=estado, detalle=detalle)
        if estado == "exitoso":
            salida.update(archivos_evaluados=len(verificados), archivos_recuperados=sum(verificados.values()))
        print(json.dumps(salida, ensure_ascii=False))
        if estado == "fallido":
            print(f"ALERTA respaldo {clave}: {detalle}", file=sys.stderr)
        return estado == "exitoso"


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    for argumento in ("db", "archivos", "destino"):
        parser.add_argument(argumento, type=Path)
    args = parser.parse_args()
    try:
        sys.exit(0 if ejecutar(args.db, args.archivos, args.destino) else 1)
    except (OSError, ValueError, sqlite3.Error) as error:
        sys.exit(f"ALERTA respaldo: {error}")
