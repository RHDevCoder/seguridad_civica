-- ======================================
-- Crear la base de datos y usarla
-- Esto crea una base de datos llamada seguridad_civica_db si no existe
-- ======================================
CREATE DATABASE IF NOT EXISTS seguridad_civica_db;
USE seguridad_civica_db;

-- ======================================
-- Tablas
-- ======================================
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS empleados;

CREATE TABLE empleados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    cedula VARCHAR(20) NOT NULL UNIQUE,
    correo VARCHAR(100) NOT NULL UNIQUE,
    contrasena VARCHAR(255) NOT NULL,
    rol ENUM('desarrollador','tecnico','asesor','mensajero','administrativo','gerente') NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    cedula VARCHAR(20) NOT NULL UNIQUE,
    correo VARCHAR(100) NOT NULL UNIQUE,
    contrasena VARCHAR(255) NOT NULL,
    direccion VARCHAR(255) NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE productos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tipo ENUM(
        'alarma','camara','sensor','sirena','control',
        'kit alarma sencilla','kit alarma personalizada',
        'kit camara sencilla','kit camara personalizada','otro'
    ) NOT NULL,
    modelo VARCHAR(100),
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    fecha_ingreso TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ventas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_empleado INT NOT NULL,
    id_cliente INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_empleado) REFERENCES empleados(id) ON DELETE RESTRICT,
    FOREIGN KEY (id_cliente) REFERENCES clientes(id) ON DELETE RESTRICT,
    FOREIGN KEY (id_producto) REFERENCES productos(id) ON DELETE RESTRICT
);

-- ======================================
-- Procedimientos almacenados con delimitadores
-- ======================================
DELIMITER $$

-- crear_venta
DROP PROCEDURE IF EXISTS crear_venta$$
CREATE PROCEDURE crear_venta(
    IN p_id_empleado INT,
    IN p_id_cliente INT,
    IN p_id_producto INT,
    IN p_cantidad INT
)
BEGIN
    DECLARE v_stock INT;
    SELECT stock INTO v_stock FROM productos WHERE id = p_id_producto;
    IF v_stock >= p_cantidad THEN
        INSERT INTO ventas (id_empleado, id_cliente, id_producto, cantidad)
        VALUES (p_id_empleado, p_id_cliente, p_id_producto, p_cantidad);
        UPDATE productos 
        SET stock = stock - p_cantidad 
        WHERE id = p_id_producto;
    ELSE
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Stock insuficiente para realizar la venta';
    END IF;
END$$

-- CRUD Empleados
DROP PROCEDURE IF EXISTS crear_empleado$$
CREATE PROCEDURE crear_empleado(
    IN p_nombre VARCHAR(100),
    IN p_cedula VARCHAR(20),
    IN p_correo VARCHAR(100),
    IN p_contrasena VARCHAR(255),
    IN p_rol VARCHAR(50)
)
BEGIN
    IF EXISTS (SELECT 1 FROM empleados WHERE cedula = p_cedula OR correo = p_correo) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El correo o cédula ya están en uso';
    ELSE
        INSERT INTO empleados (nombre, cedula, correo, contrasena, rol)
        VALUES (p_nombre, p_cedula, p_correo, p_contrasena, p_rol);
    END IF;
END$$

DROP PROCEDURE IF EXISTS obtener_empleados$$
CREATE PROCEDURE obtener_empleados()
BEGIN
    SELECT * FROM empleados;
    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'No hay empleados registrados';
    END IF;
END$$

-- CRUD Clientes
DROP PROCEDURE IF EXISTS crear_cliente$$
CREATE PROCEDURE crear_cliente(
    IN p_nombre VARCHAR(100),
    IN p_cedula VARCHAR(20),
    IN p_correo VARCHAR(100),
    IN p_contrasena VARCHAR(255),
    IN p_direccion VARCHAR(255)
)
BEGIN
    IF EXISTS (SELECT 1 FROM clientes WHERE cedula = p_cedula OR correo = p_correo) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El correo o cédula ya están en uso';
    ELSE
        INSERT INTO clientes (nombre, cedula, correo, contrasena, direccion)
        VALUES (p_nombre, p_cedula, p_correo, p_contrasena, p_direccion);
    END IF;
END$$

DROP PROCEDURE IF EXISTS obtener_clientes$$
CREATE PROCEDURE obtener_clientes()
BEGIN
    SELECT * FROM clientes;
    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'No hay clientes registrados';
    END IF;
END$$

-- CRUD Productos
DROP PROCEDURE IF EXISTS crear_producto$$
CREATE PROCEDURE crear_producto(
    IN p_nombre VARCHAR(100),
    IN p_tipo VARCHAR(50),
    IN p_modelo VARCHAR(100),
    IN p_descripcion TEXT,
    IN p_precio DECIMAL(10,2),
    IN p_stock INT
)
BEGIN
    INSERT INTO productos (nombre, tipo, modelo, descripcion, precio, stock)
    VALUES (p_nombre, p_tipo, p_modelo, p_descripcion, p_precio, p_stock);
END$$

DROP PROCEDURE IF EXISTS obtener_productos$$
CREATE PROCEDURE obtener_productos()
BEGIN
    SELECT * FROM productos;
    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'No hay productos registrados';
    END IF;
END$$

-- CRUD Ventas
DROP PROCEDURE IF EXISTS obtener_ventas$$
CREATE PROCEDURE obtener_ventas()
BEGIN
    SELECT v.id,
           e.nombre AS empleado,
           c.nombre AS cliente,
           c.direccion AS direccion_instalacion,
           p.nombre AS producto,
           v.cantidad,
           v.fecha
    FROM ventas v
    JOIN empleados e ON v.id_empleado = e.id
    JOIN clientes c ON v.id_cliente = c.id
    JOIN productos p ON v.id_producto = p.id;
    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'No hay ventas registradas';
    END IF;
END$$

DELIMITER ;

-- ======================================
-- Insertar datos de prueba
-- ======================================

-- 5 clientes de prueba
INSERT INTO clientes (nombre, cedula, correo, contrasena, direccion) VALUES
  ('Juan Pérez','10000001','juan1@example.com','1234','Calle 1 #10-10'),
  ('Laura Gómez','10000002','laura2@example.com','5678','Calle 2 #20-20'),
  ('Carlos Ruiz','10000003','carlos3@example.com','9012','Calle 3 #30-30'),
  ('Ana Martínez','10000004','ana4@example.com','3456','Calle 4 #40-40'),
  ('David Torres','10000005','david5@example.com','7890','Calle 5 #50-50');

-- 1 empleado por rol (6 en total)
INSERT INTO empleados (nombre, cedula, correo, contrasena, rol) VALUES
  ('Pedro Dev','20000001','pedro.dev@example.com','abcd','desarrollador'),
  ('Luis Técnico','20000002','luis.tecnico@example.com','efgh','tecnico'),
  ('Marta Asesora','20000003','marta.asesora@example.com','ijkl','asesor'),
  ('Sergio Mensajero','20000004','sergio.mensajero@example.com','mnop','mensajero'),
  ('Julia Admin','20000005','julia.admin@example.com','qrst','administrativo'),
  ('Carlos Gerente','20000006','carlos.gerente@example.com','uvwx','gerente');

-- 1 producto por cada tipo (10 en total)
INSERT INTO productos (nombre, tipo, modelo, descripcion, precio, stock) VALUES
  ('Alarma Básica','alarma','A100','Sistema básico',150.00,10),
  ('Cámara HD','camara','C200','Vigilancia HD',200.00,10),
  ('Sensor Movimiento','sensor','S300','Movimiento interior',80.00,10),
  ('Sirena Potente','sirena','SR400','Alto volumen',100.00,10),
  ('Control Remoto','control','CR500','Control inalámbrico',50.00,10),
  ('Kit Alarma Sencilla','kit alarma sencilla','KAS600','Sensores+sirena',300.00,10),
  ('Kit Alarma Personalizada','kit alarma personalizada','KAP700','Configurable',450.00,10),
  ('Kit Cámara Sencilla','kit camara sencilla','KCS800','Cámara+cables',320.00,10),
  ('Kit Cámara Personalizada','kit camara personalizada','KCP900','Múltiples cámaras',500.00,10),
  ('Producto Extra','otro','X1000','Artículo extra',120.00,10);

-- 5 ventas de ejemplo
CALL crear_venta(1,1,1,1);  -- Pedro Dev vende Alarma Básica a Juan Pérez
CALL crear_venta(2,2,2,1);  -- Luis Técnico vende Cámara HD a Laura Gómez
CALL crear_venta(3,3,3,1);  -- Marta Asesora vende Sensor Movimiento a Carlos Ruiz
CALL crear_venta(4,4,4,1);  -- Sergio Mensajero vende Sirena Potente a Ana Martínez
CALL crear_venta(5,5,5,1);  -- Julia Admin vende Control Remoto a David Torres

-- Verificación
SELECT COUNT(*) AS total_clientes  FROM clientes;
SELECT COUNT(*) AS total_empleados FROM empleados;
SELECT COUNT(*) AS total_productos FROM productos;
SELECT COUNT(*) AS total_ventas    FROM ventas;