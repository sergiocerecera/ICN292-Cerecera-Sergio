
PRAGMA foreign_keys = ON;

-- CLIENTES
INSERT INTO CLIENTE VALUES
(1, '76.123.456-7', 'Comercial Los Robles Ltda.', 'Santiago', 1),
(2, '77.234.567-8', 'Servicios del Sur SpA', 'Valparaiso', 1),
(3, '78.345.678-9', 'Transportes Andinos Ltda.', 'Concepcion', 1);

-- COLABORADORES
INSERT INTO COLABORADOR VALUES
(1, 'Ana Torres', 'ana@integraltax.cl', 'Directora', 'Administracion', '2024-01-10', NULL, 1),
(2, 'Carlos Soto', 'carlos@integraltax.cl', 'Contador', 'Contabilidad', '2024-03-15', 1, 1),
(3, 'Maria Lopez', 'maria@integraltax.cl', 'Analista', 'Tributaria', '2024-05-20', 1, 1);

-- CARTERAS
INSERT INTO CARTERA VALUES
(1, 2, 1, 'Contabilidad', '2026-01-01'),
(2, 3, 2, 'Tributaria', '2026-01-01'),
(3, 2, 3, 'Contabilidad', '2026-02-01');

-- TIPOS DE DOCUMENTO
INSERT INTO TIPO_DOCUMENTO VALUES
(1, 'Factura', 'Documento tributario', 'Mensual'),
(2, 'Liquidacion', 'Liquidacion de remuneraciones', 'Mensual'),
(3, 'Balance', 'Balance contable', 'Anual');

-- DOCUMENTOS
INSERT INTO DOCUMENTO VALUES
(1, 1, 1, '2026-01'),
(2, 1, 2, '2026-01'),
(3, 2, 1, '2026-01'),
(4, 2, 3, '2025'),
(5, 3, 1, '2026-02');

-- VERSIONES
INSERT INTO VERSION_DOCUMENTO VALUES
(1, 1, 1, 2, '2026-01-05', 'documentos/1/factura_v1.pdf'),
(2, 1, 2, 2, '2026-01-08', 'documentos/1/factura_v2.pdf'),
(3, 2, 1, 3, '2026-01-10', 'documentos/2/liquidacion_v1.pdf'),
(4, 3, 1, 2, '2026-01-12', 'documentos/3/factura_v1.pdf'),
(5, 4, 1, 3, '2026-01-15', 'documentos/4/balance_v1.pdf'),
(6, 5, 1, 2, '2026-02-05', 'documentos/5/factura_v1.pdf');

-- PERMISOS
INSERT INTO PERMISO VALUES
(1, 2, 1, 'LECTURA', '2026-01-01', 1, 1),
(2, 2, 3, 'ESCRITURA', '2026-01-01', 1, 1),
(3, 3, 2, 'LECTURA', '2026-01-01', 1, 1);

-- CONSULTAS
INSERT INTO CONSULTA VALUES
(1, 2, 1, 1, 1, '2026-01', '2026-02-01 09:00', '2026-02-01 09:04', '2026-02-01 09:05', 'ENTREGADA', NULL, 0, 0, 0),
(2, 3, 2, 1, 3, '2026-01', '2026-02-01 10:00', '2026-02-01 10:06', '2026-02-01 10:08', 'ENTREGADA', NULL, 0, 0, 0),
(3, 2, 3, 1, 5, '2026-02', '2026-02-02 09:00', '2026-02-02 09:05', '2026-02-02 09:07', 'ENTREGADA', NULL, 0, 0, 0),
(4, 3, 1, 2, 2, '2026-01', '2026-02-02 10:00', '2026-02-02 10:04', '2026-02-02 10:06', 'ENTREGADA', NULL, 0, 0, 0),
(5, 2, 2, 1, 3, '2026-02', '2026-02-03 09:00', '2026-02-03 09:05', '2026-02-03 09:07', 'ENTREGADA', NULL, 1, 0, 0),
(6, 3, 1, 3, 4, '2025', '2026-02-03 10:00', '2026-02-03 10:06', '2026-02-03 10:08', 'ENTREGADA', NULL, 0, 0, 0),
(7, 2, 3, 1, 5, '2026-02', '2026-02-04 09:00', '2026-02-04 09:05', '2026-02-04 09:07', 'ENTREGADA', NULL, 0, 0, 0),
(8, 3, 2, 1, 3, '2026-02', '2026-02-04 10:00', '2026-02-04 10:05', '2026-02-04 10:07', 'ENTREGADA', NULL, 0, 0, 0),
(9, 2, 1, 1, 1, '2026-01', '2026-02-05 09:00', '2026-02-05 09:05', '2026-02-05 09:07', 'ENTREGADA', NULL, 0, 0, 0),
(10, 3, 2, 1, 3, '2026-02', '2026-02-05 10:00', NULL, NULL, 'PENDIENTE', NULL, 0, 0, 0),
(11, 2, 3, 1, 5, '2026-02', '2026-02-06 09:00', NULL, NULL, 'PENDIENTE', NULL, 0, 0, 0);

-- RESPALDOS
INSERT INTO RESPALDO VALUES
(1, '2026-02-01', 'COMPLETO', 'EXITOSO', 'Prueba inicial', 'respaldo_01.zip', 2, 2),
(2, '2026-02-02', 'COMPLETO', 'EXITOSO', 'Prueba de recuperación', 'respaldo_02.zip', 2, 2),
(3, '2026-02-03', 'COMPLETO', 'PARCIAL', 'Falta un archivo', 'respaldo_03.zip', 2, 1),
(4, '2026-02-04', 'COMPLETO', 'EXITOSO', 'Nueva ejecución', 'respaldo_04.zip', 2, 2);

-- RESPALDO_DOCUMENTO
INSERT INTO RESPALDO_DOCUMENTO VALUES
(1, 1, 1, 'RECUPERADO'),
(2, 1, 2, 'RECUPERADO'),
(3, 2, 3, 'RECUPERADO'),
(4, 2, 4, 'RECUPERADO'),
(5, 3, 1, 'RECUPERADO'),
(6, 3, 2, 'NO RECUPERADO'),
(7, 4, 3, 'RECUPERADO'),
(8, 4, 4, 'RECUPERADO');

-- SEGUIMIENTOS
INSERT INTO SEGUIMIENTO VALUES
(1, 10, 2, 1, '2026-02-05', 'Solicitar documento al cliente', NULL),
(2, 11, 3, 1, '2026-02-06', 'Solicitar documento al cliente', NULL);

-- BITACORA
INSERT INTO BITACORA_ACCION VALUES
(1, '2026-02-01 09:05', 2, 1, 1, 'CONSULTA', 'AUTORIZADA', NULL),
(2, '2026-02-01 10:08', 3, 2, 3, 'CONSULTA', 'AUTORIZADA', NULL),
(3, '2026-02-02 10:08', 3, 1, 2, 'CONSULTA', 'AUTORIZADA', NULL);
