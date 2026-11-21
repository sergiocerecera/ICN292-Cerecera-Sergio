"""Ensayo aislado. Los marcadores técnicos no contienen datos de clientes."""
import json
from pathlib import Path
import sqlite3
import subprocess
import sys
import tempfile
from zipfile import ZipFile


def probar(base):
    db = base / "piloto.sqlite"
    docs = base / "documentos"
    destino = base / "copias"
    docs.mkdir()
    with sqlite3.connect(db) as con:
        con.executescript("""
            CREATE TABLE VERSION_DOCUMENTO(id_documento INTEGER, numero_version INTEGER,
                ruta_almacenamiento TEXT, PRIMARY KEY(id_documento,numero_version));
            CREATE TABLE RESPALDO(id_respaldo INTEGER PRIMARY KEY,fecha_ejecucion TEXT,
                tipo TEXT,estado TEXT);
            CREATE TABLE RESPALDO_DOCUMENTO(id_respaldo INTEGER REFERENCES RESPALDO,
                id_documento INTEGER,resultado_restauracion TEXT,
                PRIMARY KEY(id_respaldo,id_documento));
        """)
        for i in (1, 2):
            ruta = f"prueba-v{i}.txt"
            (docs / ruta).write_text(f"Marcador técnico de la versión {i}.")
            con.execute("INSERT INTO VERSION_DOCUMENTO VALUES(1,?,?)", (i, ruta))
    cmd = [sys.executable, str(Path(__file__).with_name("respaldo.py")), str(db), str(docs), str(destino)]
    ok = json.loads(subprocess.check_output(cmd, text=True))
    assert ok["archivos_evaluados"] == ok["archivos_recuperados"] == 2
    copia = destino / ok["detalle"]
    with ZipFile(copia) as paquete:
        for ruta in docs.iterdir():
            assert paquete.read("archivos/" + ruta.name) == ruta.read_bytes()
    (docs / "prueba-v2.txt").unlink()
    fallo = subprocess.run(cmd, capture_output=True, text=True)
    assert fallo.returncode == 1 and json.loads(fallo.stdout)["estado"] == "fallido"
    assert "ALERTA" in fallo.stderr and list(destino.glob("*.zip")) == [copia]
    with sqlite3.connect(db) as con:
        assert con.execute("SELECT estado FROM RESPALDO ORDER BY id_respaldo").fetchall() == [
            ("exitoso",), ("fallido",)]
        assert con.execute("SELECT * FROM RESPALDO_DOCUMENTO").fetchall() == [(1,1,"correcto")]
    print("OK | Copia restaurada: 2/2 archivos de prueba. Un documento con dos versiones.")
    print("OK | Archivo ausente: alerta, estado fallido y copia anterior conservada.")


if __name__ == "__main__":
    with tempfile.TemporaryDirectory() as temporal:
        probar(Path(temporal))
