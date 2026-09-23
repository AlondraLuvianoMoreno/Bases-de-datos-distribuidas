/* TAREA 1 - UPIITA Telemática
   Asignatura: Bases de Datos Distribuidas
   Alumna: Alondra Luviano Moreno
*/

-- 1. Preparación del entorno
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Escuela')
BEGIN
    CREATE DATABASE Escuela;
END
GO

USE Escuela;
GO

-- 2. Creación de tablas (Esquema básico para que el código funcione)
IF OBJECT_ID('Escuela.Cursa', 'U') IS NOT NULL DROP TABLE Escuela.Cursa;
IF OBJECT_ID('Escuela.Imparte', 'U') IS NOT NULL DROP TABLE Escuela.Imparte;
IF OBJECT_ID('Escuela.Alumno', 'U') IS NOT NULL DROP TABLE Escuela.Alumno;

CREATE TABLE Escuela.Alumno (
    boleta VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(50)
);

CREATE TABLE Escuela.Cursa (
    boleta VARCHAR(10),
    clave INT,
    idGrupo VARCHAR(10),
    semestre VARCHAR(10),
    calif INT,
    FOREIGN KEY (boleta) REFERENCES Escuela.Alumno(boleta)
);

CREATE TABLE Escuela.Imparte (
    numEmpleado VARCHAR(10),
    clave INT,
    idGrupo VARCHAR(10),
    semestre VARCHAR(10)
);

-- 3. Inserción de datos de prueba
INSERT INTO Escuela.Alumno VALUES ('2020630001', 'Alumno A'), ('2020630002', 'Alumno B'), ('2020630003', 'Alumno C');
INSERT INTO Escuela.Imparte VALUES ('P0000001', 102, '1TM2', '20242'), ('P0000001', 103, '1TM3', '20242');
-- Solo el alumno 2020630002 ha cursado con el profesor P0000001
INSERT INTO Escuela.Cursa VALUES ('2020630002', 102, '1TM2', '20242', 8); 
INSERT INTO Escuela.Cursa VALUES ('2020630001', 999, '1TM1', '20241', 10); -- Alumno con otro prof.

---------------------------------------------------------
-- TAREA 1: CONSULTA 3
-- Listar alumnos que NO han cursado materia con P0000001
---------------------------------------------------------

-- OPCIÓN 1: Usando EXCEPT (Resta de conjuntos)
PRINT '--- Solución con EXCEPT ---';
SELECT boleta, nombre FROM Escuela.Alumno
EXCEPT
SELECT al.boleta, al.nombre
FROM Escuela.Alumno al
JOIN Escuela.Cursa c ON al.boleta = c.boleta
JOIN Escuela.Imparte i ON c.clave = i.clave 
    AND c.idGrupo = i.idGrupo 
    AND c.Semestre = i.semestre
WHERE i.numEmpleado = 'P0000001';

-- OPCIÓN 2: Usando NOT IN
PRINT '--- Solución con NOT IN ---';
SELECT boleta, nombre
FROM Escuela.Alumno
WHERE boleta NOT IN (
    SELECT DISTINCT c.boleta
    FROM Escuela.Cursa c
    JOIN Escuela.Imparte i ON c.clave = i.clave 
        AND c.idGrupo = i.idGrupo 
        AND c.Semestre = i.semestre
    WHERE i.numEmpleado = 'P0000001'
);

-- OPCIÓN 3: Usando NOT EXISTS
PRINT '--- Solución con NOT EXISTS ---';
SELECT al.boleta, al.nombre
FROM Escuela.Alumno al
WHERE NOT EXISTS (
    SELECT 1
    FROM Escuela.Cursa c
    JOIN Escuela.Imparte i ON c.clave = i.clave 
        AND c.idGrupo = i.idGrupo 
        AND c.Semestre = i.semestre
    WHERE c.boleta = al.boleta 
      AND i.numEmpleado = 'P0000001'
);

-- OPCIÓN 4: Usando LEFT JOIN e IS NULL
PRINT '--- Solución con LEFT JOIN ---';
SELECT al.boleta, al.nombre
FROM Escuela.Alumno al
LEFT JOIN (
    SELECT DISTINCT c.boleta
    FROM Escuela.Cursa c
    JOIN Escuela.Imparte i ON c.clave = i.clave 
        AND c.idGrupo = i.idGrupo 
        AND c.Semestre = i.semestre
    WHERE i.numEmpleado = 'P0000001'
) AS cursaron ON al.boleta = cursaron.boleta
WHERE cursaron.boleta IS NULL;