/*EJEMPLO USANDO WITH*/
go
WITH T1 as (
    SELECT DISTINCT c.boleta, c.clave
    FROM escuela.cursa c
    JOIN escuela.Imparte i ON c.clave = i.clave
    WHERE i.numEmpleado = 'P0000001' AND c.calif >= 6
),
T2 as (
    SELECT DISTINCT clave
    FROM escuela.Imparte
    WHERE numEmpleado = 'P0000001'
),
Cruza as (
    SELECT a.boleta, b.clave
    FROM (SELECT DISTINCT boleta FROM T1) a, T2 b
),
Filtro as (
    SELECT c.boleta, c.clave
    FROM Cruza c
    LEFT JOIN T1 ON c.boleta = T1.boleta AND c.clave = T1.clave
    WHERE T1.boleta IS NULL
)

SELECT boleta FROM T1
EXCEPT
SELECT boleta FROM Filtro