--! Proyecto 1 SQL - Gestión de Base de Datos Empresarial.

--! 1) DDL - Definición de datos.

--? Crea una base de datos llamada empresa_technova.

CREATE DATABASE empresa_technova;

--? Crea una tabla empleados con los campos:
  --? id (INT, PRIMARY KEY)
  --? nombre (VARCHAR(50))
  --? edad (INT)
  --? salario (DECIMAL(10,2))

CREATE TABLE empleados (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL,
  edad INT NOT NULL,
  salario DECIMAL(10,2) NOT NULL
);

--? Añade una nueva columna dirección (VARCHAR(100)) a empleados.

ALTER TABLE empleados
ADD direccion VARCHAR(100) NOT NULL;

--? Crea una tabla departamentos con los campos:
  --? id_dep (INT, PRIMARY KEY)
  --? nombre (VARCHAR(50))
  --? id_empleado (INT, FOREIGN KEY que hace referencia a empleados(id))

CREATE TABLE departamentos (
  id_dep INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL,
  id_empleado INT,
  CONSTRAINT fk_empleado
    FOREIGN KEY (id_empleado)
    REFERENCES empleados(id)
);

--! 2) DML - Manipulación de datos.

--? Inserta tres empleados y dos departamentos.
--? Empleados.

INSERT INTO empleados(nombre, edad, salario, direccion) VALUES
('Juan Iglesias', 33, 2250.00, 'Calle del Olmo 3, A Coruña'),
('Pilar Rodríguez', 48, 3200.00, 'Avenida del Ventisquero de la Condesa 7, Madrid'),
('Jorge Pena', 26, 1330.50, 'Calle Pescadería 23, Pamplona');

--? Departamentos.

INSERT INTO departamentos(nombre, id_empleado) VALUES
('IT', 1),
('Contabilidad', 2);

--? Modifica el salario de un empleado.

UPDATE empleados
SET salario = 1400.60
WHERE nombre = 'Jorge Pena';

--? Elimina al empleado cuyo salario sea inferior a 1500.

DELETE FROM empleados
WHERE salario < 1500;

--! 3) DQL - Consulta de datos.

--? Muestra todos los empleados.

SELECT * FROM empleados;

--? Muestra el nombre y salario de los empleados mayores de 30 años, ordenados por salario descendente.

SELECT nombre, salario
FROM empleados
WHERE edad > 30
ORDER BY salario DESC;

--? Muestra el número de empleados agrupados por edad.

SELECT edad, COUNT(*) AS total
FROM empleados
GROUP BY edad;

--? Muestra la edad y el salario medio de los empleados con salario medio > 1800 (usa GROUP BY y HAVING).

SELECT edad, AVG(salario) AS salario_medio
FROM empleados
GROUP BY edad
HAVING AVG(salario) > 1800
ORDER BY edad DESC;

--? Realiza una JOIN para mostrar el nombre del empleado y el nombre de su departamento.

SELECT empleados.nombre AS empleado, departamentos.nombre AS departamento
FROM empleados
JOIN departamentos ON empleados.id = departamentos.id_empleado;

--! 4) DCL - Control de acceso (básico).

--? Crea un usuario1.

CREATE USER 'usuario1'@'localhost' IDENTIFIED BY 'ChuckNorris';

--? Concede a usuario1 SELECT e INSERT sobre la tabla empleados.

GRANT SELECT, INSERT ON empresa_technova.empleados TO 'usuario1'@'localhost';

--? Revocar el permiso de INSERT a usuario1 (manteniendo SELECT).

REVOKE INSERT ON empresa_technova.empleados FROM 'usuario1'@'localhost';

--! 5) TCL - Control de transacciones.

--? Inicia una transacción.

START TRANSACTION;

--? Inserta un nuevbo empleado.

INSERT INTO empleados(nombre, edad, salario, direccion) VALUES
('Sergio Morín', 30, 1950.89, 'Calle Antracita 64, Cáceres');

--? Crea un SAVEPOINT.

SAVEPOINT savepoint1;

--? Actualiza el salario del nuevo empleado y revierte los cambios hasta el SAVEPOINT.

UPDATE empleados
SET salario = 2000
WHERE nombre = 'Sergio Morín';

ROLLBACK TO savepoint1;

--? Ejecuta COMMIT para confirmar los cambios reales.

COMMIT;

--! 6) Vistas (Views).

--? Crea una vista llamada vista_empleados_activos que muestre:
  --? id, nombre, edad, salario y nombre del departamento (usa JOIN entre empleados y departamentos).
  --? La vista debe excluir empleados con salario < 1500.

CREATE VIEW vista_empleados_activos AS
SELECT
  empleados.id,
  empleados.nombre,
  empleados.edad,
  empleados.salario,
  departamentos.nombre AS departamento
FROM empleados
JOIN departamentos
ON empleados.id = departamentos.id_empleado
WHERE empleados.salario >= 1500;

--? Crea otra vista_resumen_salarios que muestre por edad:
  --? edad, total_empleados y salario_medio (usa COUNT(*) y AVG(salario)).

CREATE VIEW vista_resumen_salarios AS
SELECT
  edad,
  COUNT(*) AS total,
  AVG(salario) AS media_salarial
FROM empleados
GROUP BY edad;

--? Realiza consultas sobre ambas vistas:
  --? Todos los empleados activos ordenados por salario descendente (desde vista_empleados_activos).

SELECT *
FROM vista_empleados_activos
ORDER BY salario DESC;

  --? Edades con salario medio > 2000 desde vista_resumen_salarios.

SELECT *
FROM vista_resumen_salarios
WHERE media_salarial > 2000;

--! 7) Roles y permisos.