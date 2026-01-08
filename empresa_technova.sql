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

--? Crea los siguientes roles:
  --? rol_consulta con permisos de lectura.

CREATE ROLE 'rol_consulta';
GRANT SELECT ON empresa_technova.* TO 'rol_consulta';

  --? rol_editor_empleados con permisos de SELECT e INSERT/UPDATE en empleados.

CREATE ROLE 'rol_editor_empleados';
GRANT SELECT, INSERT, UPDATE ON empresa_technova.empleados TO 'rol_editor_empleados';

--? Concede permisos a los roles:
  --? A rol_consulta:
    --? SELECT sobre todas las vistas creadas.

GRANT SELECT ON empresa_technova.vista_empleados_activos TO 'rol_consulta';
GRANT SELECT ON empresa_technova.vista_resumen_salarios TO 'rol_consulta';

    --? SELECT sobre las tablas empleados y departamentos.

GRANT SELECT ON empresa_technova.empleados TO 'rol_consulta';
GRANT SELECT ON empresa_technova.departamentos TO 'rol_consulta';

  -- ? A rol_editor_empleados:
    --? SELECT, INSERT y UPDATE sobre empleados.
    --? (NO conceder DELETE).

GRANT SELECT, INSERT, UPDATE ON empresa_technova.empleados TO 'rol_editor_empleados';

--? Asigna roles a usuarios:
  --? Asigna rol_consulta a usuario1.

GRANT 'rol_consulta' TO 'usuario1'@'localhost';

  --? Crea usuario2 y asígnale rol_editor_empleados.

CREATE USER 'usuario2'@'localhost' IDENTIFIED BY '1234';
GRANT 'rol_editor_empleados' TO 'usuario2'@'localhost';

--? Prueba de permisos:
  --? Con usuario1, verifica que puede consultar vista_empleados_activos pero no puede insertar en empleados.

--? usuario1:
-- Consulta:
SELECT * FROM vista_empleados_activos;
-- Insertar:
INSERT INTO empleados (nombre, edad, salario, direccion) VALUES
('Diego Filgueira', 33, 2467.45, 'Calle Camilo José Cela 45, Pontevedra');

  --? Con uduario2, verifica que puede insertar/actualizar en empleados y consultar las vistas.

--? usuario2:
-- Insertar:
INSERT INTO empleados (nombre, edad, salario, direccion) VALUES
('Diego Filgueira', 33, 2467.45, 'Calle Camilo José Cela 45, Pontevedra');
-- Actualizar:
UPDATE empleados
SET edad = 34
WHERE nombre = 'Diego Filgueira';
-- Consultar:
SELECT * FROM vista_empleados_activos;
SELECT * FROM vista_resumen_salarios;

--? Revocaciones y limpieza:
  --? Revocar rol_editor_empleados de usuario2.

REVOKE 'rol_editor_empleados' FROM 'usuario2'@'localhost';

  --? Revocar rol_consulta de usuario1.

REVOKE 'rol_consulta' FROM 'usuario1'@'localhost';

  --? Revocar de los roles cualquier permiso que concediste sobre las vistas y tablas.

-- rol_consulta:
REVOKE SELECT ON empresa_technova.vista_empleados_activos FROM 'rol_consulta';
REVOKE SELECT ON empresa_technova.vista_resumen_salarios FROM 'rol_consulta';
REVOKE SELECT ON empresa_technova.empleados FROM 'rol_consulta';
REVOKE SELECT ON empresa_technova.departamentos FROM 'rol_consulta';
-- rol_editor_empleados:
REVOKE SELECT, INSERT, UPDATE ON empresa_technova.empleados FROM 'rol_editor_empleados';

  --? Elimina los roles con DROP ROLE.

DROP ROLE 'rol_consulta';
DROP ROLE 'rol_editor_empleados';

--! 8) Triggers.

--? Crea mecanismos automáticos para auditar y controlar reglas de negocio.
--? 1. Tabla de auditorías de salarios:
  --? Crea una tabla empleados_salario_log con los campos:
    --? id_log (INT, PRIMARY KEY, autoincremental si tu SGBD lo permite)
    --? id_empleado (INT)
    --? salario_anterior (DECIMAL(10,2))
    --? salario_nuevo (DECIMAL(10,2))
    --? fecha_cambio (DATETIME o TIMESTAMP)
    --? usuario_bd (VARCHAR(50)) - para guardar el usuario de BD que hizo el cambio (si tu SGBD lo permite con funciones del tipo CURRENT_USER)

CREATE TABLE empleados_salario_log (
  id_log INT AUTO_INCREMENT PRIMARY KEY,
  id_empleado INT NOT NULL,
  salario_anterior DECIMAL(10,2) NOT NULL,
  salario_nuevo DECIMAL(10,2) NOT NULL,
  fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  usuario_bd VARCHAR(50) DEFAULT CURRENT_USER
);

--? 2. Trigger de auditoría en UPDATE de salario:
  --? Crea un TRIGGER AFTER UPDATE sobre la tabla empleados que:
    --? Se dispare solo cuando el salario cambie.
    --? Inserte un registro en empleados_salario_log con:
      --? id del empleado
      --? salario anterior
      --? salario nuevo
      --? fecha/hora del cambio
      --? usuario de BD que realizó la operación.

DELIMITER $$

CREATE TRIGGER trg_auditoria_salario
AFTER UPDATE ON empleados
FOR EACH ROW
BEGIN
  IF OLD.salario <> NEW.salario THEN
    INSERT INTO empleados_salario_log (
      id_empleado,
      salario_anterior,
      salario_nuevo,
      fecha_cambio,
      usuario_bd
    )
    VALUES (
      NEW.id,
      OLD.salario,
      NEW.salario,
      CURRENT_TIMESTAMP,
      CURRENT_USER()
    );
  END IF;
END$$

DELIMITER;

  --? Realiza un UPDATE de salario sobre algún empleado y verifica que el trigger ha insertado el registro en la tabla de log.

UPDATE empleados
SET salario = 3350.33
WHERE nombre = 'Juan Iglesias';

--? 3. Trigger de control de salario mínimo en INSERT:
  --? Crea un TRIGGER BEFORE INSERT sobre empleados que:
    --? Verifique que el salario del nuevo empleado sea como mínimo 1000.
    --? Si el salario es menor de 1000, realiza una de estas dos acciones (elige una, segñun tu SGBD):
      --? Ajusta el salario automáticamente a 1000, o
      --? Lanza un error que impida la inserción.

DELIMITER $$

CREATE TRIGGER trg_insert_salario_min
BEFORE INSERT ON empleados
FOR EACH ROW
BEGIN
  IF NEW.salario < 1000 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'No se puede insertar un empleado con salario inferior a 1000';
  END IF;
END$$

DELIMITER;

  --? Prueba el trigger intentando insertar un empleado con salario 800 y verifica el comportamiento.

INSERT INTO empleados (nombre, edad, salario, direccion)
VALUES ('Marco López', 41, 683.00, 'Avenida del Mirador de la Reina, Madrid');

--? 4. Trigger en DELETE:
  --? Crea un TRIGGER BEFORE DELETE en empleados que:
    --? Inserte en una tabla empleados_borrados (que debes crear) los datos básicos del empleado eliminado (id, nombre, edad, salario, fecha_borrado).

-- Tabla empleadop_borrados:
CREATE TABLE empleados_borrados  (
  id_log INT AUTO_INCREMENT PRIMARY KEY,
  id INT NOT NULL,
  nombre VARCHAR(30) NOT NULL,
  edad INT NOT NULL,
  salario DECIMAL(10,2) NOT NULL,
  fecha_borrado TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Trigger de auditoría para empleados eliminados:
DELIMITER $$

CREATE TRIGGER trg_auditoria_delete_empleados
BEFORE DELETE ON empleados
FOR EACH ROW
BEGIN
  INSERT INTO empleados_borrados (
    id,
    nombre,
    edad,
    salario,
    fecha_borrado
  )
  VALUES (
    OLD.id,
    OLD.nombre,
    OLD.edad,
    OLD.salario,
    CURRENT_TIMESTAMP
  );
END$$

DELIMITER;

  --? Elimina a un empleado y comprueba que aparece en empleados_borrados.

INSERT INTO empleados (nombre, edad, salario, direccion)
VALUES ('Santiago Perea', 51, 2652.00, 'Calle Musgo 1, Toledo');

DELETE FROM empleados
WHERE nombre = 'Santiago Perea';

SELECT * FROM empleados_borrados
WHERE nombre = 'Santiago Perea';

--! 9) Índices.

--? 1. Índice por edad en empleados:
  --? Crea un índice llamado idx_empleados_edad sobre la columna edad de la tabla empleados.
  --? Realiza una consulta que agrupe por edad y observa (si tu SGBD lo permite) el plan de ejecución antes y despuñes de crear el índice.

-- Consulta sin índice y explicación:
EXPLAIN
SELECT edad, COUNT(*) AS total
FROM empleados
GROUP BY edad;

-- Creación del índice:
CREATE INDEX idx_empleados_edad
ON empleados(edad);

-- Consulta con el índice:
EXPLAIN
SELECT edad, COUNT(*) AS total
FROM empleados
GROUP BY edad;

--* La diferencia en la utilización de índices en bases de datos con tablas tan pequeñas no es observable en términos de tiempo de ejecución de las diferentes consultas, pero sí puede apreciarse en cuanto al plan de ejecución.

--? 2. Índice en salario para consultas de rango:
  --? Crea un índice idx_empleados_salario sobre la columna salario.
  --? Ejecuta varias consultas que filtren por rangos de salario (por ejemplo, WHERE salario BETWEEN 1500 AND 2500) y observa la mejora.

-- Consulta sin índice y explicación:
EXPLAIN
SELECT id, nombre, direccion, salario
FROM empleados
WHERE salario BETWEEN 3000 AND 3500;

-- Creación del índice:
CREATE INDEX idx_empleados_salario
ON empleados(salario);

--* SHOW INDEX FROM empleados;
--* Para comporobar si el índice sobre la tabla "empleados" se han creado correctamente.

-- Consulta con el índice:
EXPLAIN
SELECT id, nombre, direccion, salario
FROM empleados
WHERE salario BETWEEN 3000 AND 3500;

/* 
Prueba:
SELECT nombre, edad, salario
FROM empleados
WHERE salario >= 3000 AND salario <= 3500;

SELECT nombre, direccion, salario
FROM empleados
WHERE salario > 1500 AND salario <=3000;
*/

--? 3. Índice único en nombre de departamento:
  --? Crea un índice único. idx_departamentos_nombre_unique sobre la columna nombre de la tabla departamentos para evitar nombres de departamento duplicados.

CREATE UNIQUE INDEX idx_departamentos_nombre_unique
ON departamentos(nombre);

--* SHOW INDEX FROM departamentos;
--* Para comporobar si el índice sobre la tabla "departamentos" se han creado correctamente.
--* Mediante un índice UNIQUE garantizamos la integridad de los datos. Entre las características:
  --* Mejora búsquedas en esa columna.
  --* Garantiza unicidad.
  --* Es preferible a validar duplicados manualmente con SELECT.

  --? Intenta insertar un departamento con un nombre ya existente y comprueba que el SGBD no lo permite.

INSERT INTO departamentos (id_dep, nombre, id_empleado)
VALUES (1, 'IT', 3);

--? 4. Índice compuesto:
  --? Crea un índice compuesto idx_empleados_edad_salario sobre (edad, salario).

CREATE INDEX idx_empleados_edad_salario
ON empleados(edad, salario);

--* El índice sigue el orden indicado (en este caso, primero edad y en segundo término salario).

  --? Realiza una consulta que filtre por edad y ordene por salario y comprueba el uso del índice (si tu SGBD permite ver el plan de ejecución).

-- Con EXPLAIN:
EXPLAIN
SELECT nombre, edad, salario
FROM empleados
WHERE edad = 36
ORDER BY salario;

-- Sin EXPLAIN:
SELECT nombre, edad, salario
FROM empleados
WHERE edad = 36
ORDER BY salario;

--! 10) Copias de seguridad y restauración (Backup & Recovery).

--? Define y documenta cómo harías las copias de seguridad de la base de datos de empresa_technova.
--? Restauración de la base de datos desde un backup.
  --? Escribe el comando que utilizarías para restaurar la base de datos empresa_technova a partir del fichero backup generado.
  --? Explica brevemente en qué situaciones usarías esta restauración.