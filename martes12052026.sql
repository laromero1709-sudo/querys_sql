----- cte recursivo jerarquico


USE ETL_Demo;
GO

-- Crear tabla de empleados con jerarquía
CREATE TABLE Empleados_Jeraquia (
    EmpleadoID INT PRIMARY KEY,
    Nombre VARCHAR(50),
    GerenteID INT NULL,
    Puesto VARCHAR(50)
);

INSERT INTO Empleados_Jeraquia VALUES
(1, 'Laura Directora', NULL, 'Directora'),
(2, 'Carlos Jefe', 1, 'Jefe de Ventas'),
(3, 'Luis Vendedor', 2, 'Vendedor'),
(4, 'Ana Vendedora', 2, 'Vendedora'),
(5, 'Pedro Jefe', 1, 'Jefe de TI'),
(6, 'Marta Programadora', 5, 'Desarrollador');

-- CTE Recursivo: obtener toda la jerarquía bajo un jefe
WITH Jerarquia AS (
    -- Parte inicial (ancla)
    SELECT 
        EmpleadoID,
        Nombre,
        GerenteID,
        Puesto,
        0 AS Nivel,
        CAST(Nombre AS VARCHAR(500)) AS Ruta
    FROM Empleados_Jeraquia
    WHERE EmpleadoID = 1  -- Empezar desde Laura (Directora)
    
    UNION ALL
    
    -- Parte recursiva (se une a sí misma)
    SELECT 
        e.EmpleadoID,
        e.Nombre,
        e.GerenteID,
        e.Puesto,
        j.Nivel + 1,
        CAST(j.Ruta + ' → ' + e.Nombre AS VARCHAR(500))
    FROM Empleados_Jeraquia e
    INNER JOIN Jerarquia j ON e.GerenteID = j.EmpleadoID
)
SELECT * FROM Jerarquia
ORDER BY Nivel, Nombre;


----Ejercicio 2: CTE con ROW_NUMBER (eliminar duplicados)
-- Crear tabla con duplicados
CREATE TABLE Ventas_Duplicadas (
    VentaID INT,
    Fecha DATE,
    Producto VARCHAR(50),
    Cantidad INT
);

INSERT INTO Ventas_Duplicadas VALUES
(1, '2025-01-01', 'Laptop', 2),
(1, '2025-01-01', 'Laptop', 2),  -- Duplicado exacto
(2, '2025-01-02', 'Mouse', 5),
(2, '2025-01-02', 'Mouse', 5),  -- Duplicado exacto
(3, '2025-01-03', 'Laptop', 1);

-- Ver duplicados
SELECT * FROM Ventas_Duplicadas;

-- CTE para identificar duplicados
WITH Duplicados AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY VentaID, Fecha, Producto, Cantidad ORDER BY (SELECT NULL)) AS rn
    FROM Ventas_Duplicadas
)
-- Eliminar duplicados
DELETE FROM Duplicados WHERE rn > 1;

-- Ver resultado
SELECT * FROM Ventas_Duplicadas;



----- multiples  cte

-- Resumen de ventas usando CTEs múltiples
WITH 
-- CTE 1: Ventas por producto
VentasProducto AS (
    SELECT 
        Producto,
        SUM(Cantidad) AS TotalUnidades,
        SUM(Total) AS TotalVentas
    FROM Ventas_Duplicadas
    GROUP BY Producto
),
-- CTE 2: Promedios generales
Promedios AS (
    SELECT 
        AVG(TotalUnidades) AS PromedioUnidades,
        AVG(TotalVentas) AS PromedioVentas
    FROM VentasProducto
)
-- CTE 3: Combinar y calcular diferencia
SELECT 
    vp.Producto,
    vp.TotalUnidades,
    vp.TotalVentas,
    p.PromedioUnidades,
    vp.TotalUnidades - p.PromedioUnidades AS DiferenciaUnidades,
    CASE 
        WHEN vp.TotalUnidades > p.PromedioUnidades THEN 'Sobre promedio'
        WHEN vp.TotalUnidades < p.PromedioUnidades THEN 'Bajo promedio'
        ELSE 'En promedio'
    END AS Status
FROM VentasProducto vp
CROSS JOIN Promedios p
ORDER BY TotalUnidades DESC;



----- cte multiples



USE ETL_Demo;
GO

-- Asegurar que la tabla existe con las columnas correctas
CREATE TABLE Ventas_Duplicadas (
    VentaID INT,
    Fecha DATE,
    Producto VARCHAR(50),
    Cantidad INT
);

INSERT INTO Ventas_Duplicadas VALUES
(1, '2025-01-01', 'Laptop', 2),
(1, '2025-01-01', 'Laptop', 2),  -- Duplicado exacto
(2, '2025-01-02', 'Mouse', 5),
(2, '2025-01-02', 'Mouse', 5),  -- Duplicado exacto
(3, '2025-01-03', 'Laptop', 1);

-- ============================================
-- CTEs Múltiples (corregido - sin Total)
-- ============================================

-- CTE 1: Ventas por producto
WITH VentasProducto AS (
    SELECT 
        Producto,
        SUM(Cantidad) AS TotalUnidades
    FROM Ventas_Duplicadas
    GROUP BY Producto
),
-- CTE 2: Promedio general de unidades
Promedios AS (
    SELECT 
        AVG(TotalUnidades) AS PromedioUnidades
    FROM VentasProducto
)
-- CTE 3: Combinar y calcular diferencia
SELECT 
    vp.Producto,
    vp.TotalUnidades,
    p.PromedioUnidades,
    vp.TotalUnidades - p.PromedioUnidades AS DiferenciaUnidades,
    CASE 
        WHEN vp.TotalUnidades > p.PromedioUnidades THEN 'Sobre promedio'
        WHEN vp.TotalUnidades < p.PromedioUnidades THEN 'Bajo promedio'
        ELSE 'En promedio'
    END AS Status
FROM VentasProducto vp
CROSS JOIN Promedios p
ORDER BY TotalUnidades DESC;


---------------------------------------------------------------

USE ETL_Demo;
GO

-- Crear tabla de prueba
CREATE TABLE Ventas_CTE (
    VentaID INT,
    Fecha DATE,
    Producto VARCHAR(50),
    Cantidad INT
);

INSERT INTO Ventas_CTE VALUES
(1, '2025-01-01', 'Laptop', 2),
(2, '2025-01-02', 'Laptop', 1),
(3, '2025-01-03', 'Laptop', 5),
(4, '2025-01-04', 'Mouse', 10),
(5, '2025-01-05', 'Mouse', 3),
(6, '2025-01-06', 'Teclado', 4);

-- Ver datos originales
SELECT '=== DATOS ORIGINALES ===' AS Mensaje;
SELECT * FROM Ventas_CTE ORDER BY Producto, Fecha;

-- ============================================
-- CTE para actualizar solo el registro más reciente de cada producto
-- ============================================
WITH UltimasVentas AS (
    SELECT 
        VentaID,
        Producto,
        Fecha,
        Cantidad,
        ROW_NUMBER() OVER (PARTITION BY Producto ORDER BY Fecha DESC) AS rn
    FROM Ventas_CTE
)
UPDATE UltimasVentas
SET Cantidad = Cantidad * 2
WHERE rn = 1;  -- Solo actualiza el registro más reciente de cada producto

-- Ver resultado después de la actualización
SELECT '=== DATOS ACTUALIZADOS (últimos de cada producto se duplicaron) ===' AS Mensaje;
SELECT * FROM Ventas_CTE ORDER BY Producto, Fecha;

-- ============================================
-- CTE para actualizar múltiples condiciones
-- ============================================
WITH VentasBajas AS (
    SELECT 
        VentaID,
        Producto,
        Cantidad,
        CASE 
            WHEN Cantidad < 3 THEN 'Baja'
            WHEN Cantidad BETWEEN 3 AND 5 THEN 'Media'
            ELSE 'Alta'
        END AS Clasificacion
    FROM Ventas_CTE
)
UPDATE VentasBajas
SET Cantidad = Cantidad + 1
WHERE Clasificacion = 'Baja';  -- Incrementar en 1 las ventas bajas

-- Ver resultado final
SELECT '=== DATOS FINALES (ventas bajas incrementadas en 1) ===' AS Mensaje;
SELECT * FROM Ventas_CTE ORDER BY Producto, Fecha;

-- ============================================
-- CTE para eliminar registros (mantener solo el más reciente por producto)
-- ============================================
WITH MantenerUltimos AS (
    SELECT 
        VentaID,
        Producto,
        Fecha,
        ROW_NUMBER() OVER (PARTITION BY Producto ORDER BY Fecha DESC) AS rn
    FROM Ventas_CTE
)
DELETE FROM MantenerUltimos WHERE rn > 1;

-- Ver resultado final
SELECT '=== DATOS FINALES (solo el registro más reciente por producto) ===' AS Mensaje;
SELECT * FROM Ventas_CTE ORDER BY Producto;

-- ============================================
-- Limpiar
-- ============================================
DROP TABLE Ventas_CTE;
PRINT '=== EJERCICIO COMPLETADO ===';



------ subconsultas correlacionadas

USE ETL_Demo;
GO

-- Crear tabla de ventas
CREATE TABLE Ventas_Temp (
    VentaID INT,
    Fecha DATE,
    Producto VARCHAR(50),
    Cantidad INT
);

INSERT INTO Ventas_Temp VALUES
(1, '2025-01-01', 'Laptop', 2),
(2, '2025-01-02', 'Laptop', 1),
(3, '2025-01-03', 'Laptop', 5),
(4, '2025-01-04', 'Mouse', 10),
(5, '2025-01-05', 'Mouse', 3),
(6, '2025-01-06', 'Teclado', 4);

-- Subconsulta correlacionada: mostrar productos con ventas mayores al promedio de ese producto
SELECT 
    v1.Producto,
    v1.Fecha,
    v1.Cantidad,
    (SELECT AVG(v2.Cantidad) 
     FROM Ventas_Temp v2 
     WHERE v2.Producto = v1.Producto) AS PromedioProducto
FROM Ventas_Temp v1
WHERE v1.Cantidad > (SELECT AVG(v2.Cantidad) 
                      FROM Ventas_Temp v2 
                      WHERE v2.Producto = v1.Producto)
ORDER BY v1.Producto, v1.Fecha;

-- Limpiar
DROP TABLE Ventas_Temp;



------------------------ pivot 

-- Crear tabla de ventas por mes
CREATE TABLE Ventas_Mensuales (
    Producto VARCHAR(50),
    Anio INT,
    Mes INT,
    Cantidad INT
);

INSERT INTO Ventas_Mensuales VALUES
('Laptop', 2025, 1, 10),
('Laptop', 2025, 2, 15),
('Laptop', 2025, 3, 20),
('Mouse', 2025, 1, 30),
('Mouse', 2025, 2, 25),
('Mouse', 2025, 3, 35),
('Teclado', 2025, 1, 5),
('Teclado', 2025, 2, 8),
('Teclado', 2025, 3, 12);

-- PIVOT: convertir meses en columnas
SELECT *
FROM (
    SELECT Producto, Mes, Cantidad
    FROM Ventas_Mensuales
) AS DatosOrigen
PIVOT (
    SUM(Cantidad)
    FOR Mes IN ([1], [2], [3])
) AS DatosPivot;

-- UNPIVOT: convertir columnas a filas (lo inverso)
WITH PivotData AS (
    SELECT *
    FROM (
        SELECT Producto, Mes, Cantidad
        FROM Ventas_Mensuales
    ) AS DatosOrigen
    PIVOT (
        SUM(Cantidad)
        FOR Mes IN ([1], [2], [3])
    ) AS DatosPivot
)
SELECT Producto, Mes, Cantidad
FROM PivotData
UNPIVOT (
    Cantidad FOR Mes IN ([1], [2], [3])
) AS DatosUnpivot;

-- Limpiar
DROP TABLE Ventas_Mensuales;


---Ejercicio 3: MERGE (INSERT + UPDATE + DELETE)
-- Crear tablas origen y destino
CREATE TABLE Origen_Empleados (
    EmpleadoID INT PRIMARY KEY,
    Nombre VARCHAR(50),
    Salario DECIMAL(10,2)
);

CREATE TABLE Destino_Empleados (
    EmpleadoID INT PRIMARY KEY,
    Nombre VARCHAR(50),
    Salario DECIMAL(10,2)
);

-- Insertar datos
INSERT INTO Origen_Empleados VALUES
(1, 'Luis Romero', 50000),
(2, 'Ana García', 45000),
(3, 'Carlos López', 40000);

INSERT INTO Destino_Empleados VALUES
(1, 'Luis Romero', 48000),  -- Salario diferente (actualizar)
(2, 'Ana García', 45000);    -- Igual (no hacer nada)
-- Empleado 3 no existe en destino (insertar)
-- Empleado 4 no existe en origen (eliminar)

INSERT INTO Destino_Empleados VALUES (4, 'Pedro Gómez', 30000);

-- MERGE: sincronizar Destino con Origen
MERGE INTO Destino_Empleados AS D
USING Origen_Empleados AS O
ON D.EmpleadoID = O.EmpleadoID

WHEN MATCHED AND (D.Nombre != O.Nombre OR D.Salario != O.Salario) THEN
    UPDATE SET D.Nombre = O.Nombre, D.Salario = O.Salario

WHEN NOT MATCHED BY TARGET THEN
    INSERT (EmpleadoID, Nombre, Salario)
    VALUES (O.EmpleadoID, O.Nombre, O.Salario)

WHEN NOT MATCHED BY SOURCE THEN
    DELETE;

-- Ver resultado
SELECT * FROM Destino_Empleados ORDER BY EmpleadoID;

-- Limpiar
DROP TABLE Origen_Empleados;
DROP TABLE Destino_Empleados;

----Ejercicio 4: OUTPUT (devolver filas afectadas)

-- Crear tabla
CREATE TABLE Log_Empleados (
    EmpleadoID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(50),
    Salario DECIMAL(10,2),
    FechaCreacion DATETIME DEFAULT GETDATE()
);

-- INSERT con OUTPUT (devuelve lo que se insertó)
INSERT INTO Log_Empleados (Nombre, Salario)
OUTPUT inserted.*
VALUES ('Luis Romero', 50000),
       ('Ana García', 45000);

-- UPDATE con OUTPUT (devuelve antes y después)
UPDATE Log_Empleados
SET Salario = Salario * 1.10
OUTPUT deleted.Nombre AS Nombre,
       deleted.Salario AS SalarioViejo,
       inserted.Salario AS SalarioNuevo
WHERE Nombre = 'Luis Romero';

-- DELETE con OUTPUT (devuelve lo que se eliminó)
DELETE FROM Log_Empleados
OUTPUT deleted.*
WHERE Nombre = 'Ana García';

-- Limpiar
DROP TABLE Log_Empleados;


--Ejercicio 5: CROSS APPLY (similar a JOIN con funciones)
--sql
-- Crear tabla
CREATE TABLE Clientes_Prueba (
    ClienteID INT,
    Nombre VARCHAR(50)
);

INSERT INTO Clientes_Prueba VALUES
(1, 'Luis'),
(2, 'Ana'),
(3, 'Carlos');

-- Función de tabla que devuelve los 2 primeros caracteres
CREATE FUNCTION dbo.PrimerosDosCaracteres(@Nombre VARCHAR(50))
RETURNS TABLE
AS
RETURN (
    SELECT LEFT(@Nombre, 2) AS Prefijo
);

-- CROSS APPLY (como INNER JOIN)
SELECT c.ClienteID, c.Nombre, ca.Prefijo
FROM Clientes_Prueba c
CROSS APPLY dbo.PrimerosDosCaracteres(c.Nombre) ca;

-- OUTER APPLY (como LEFT JOIN) - siempre devuelve fila aunque la función no devuelva nada
SELECT c.ClienteID, c.Nombre, oa.Prefijo
FROM Clientes_Prueba c
OUTER APPLY dbo.PrimerosDosCaracteres(c.Nombre) oa;

-- Limpiar
DROP FUNCTION dbo.PrimerosDosCaracteres;
DROP TABLE Clientes_Prueba;
--📋 Ejercicio 6: EXCEPT e INTERSECT
--sql
-- Crear tablas
CREATE TABLE Ventas_2024 (Producto VARCHAR(50));
CREATE TABLE Ventas_2025 (Producto VARCHAR(50));

INSERT INTO Ventas_2024 VALUES ('Laptop'), ('Mouse'), ('Teclado'), ('Monitor');
INSERT INTO Ventas_2025 VALUES ('Laptop'), ('Mouse'), ('Impresora'), ('Tablet');

-- INTERSECT: productos vendidos en AMBOS años
SELECT Producto FROM Ventas_2024
INTERSECT
SELECT Producto FROM Ventas_2025;
-- Resultado: Laptop, Mouse

-- EXCEPT: productos vendidos en 2024 pero NO en 2025
SELECT Producto FROM Ventas_2024
EXCEPT
SELECT Producto FROM Ventas_2025;
-- Resultado: Teclado, Monitor

-- EXCEPT: productos vendidos en 2025 pero NO en 2024
SELECT Producto FROM Ventas_2025
EXCEPT
SELECT Producto FROM Ventas_2024;
-- Resultado: Impresora, Tablet

-- UNION vs UNION ALL vs EXCEPT vs INTERSECT
SELECT 'UNION' AS Tipo, 'todos, sin duplicados' AS Explicacion
UNION ALL
SELECT 'UNION ALL', 'todos, con duplicados'
UNION ALL
SELECT 'EXCEPT', 'lo que está en A pero no en B'
UNION ALL
SELECT 'INTERSECT', 'lo que está en A y en B';

-- Limpiar
DROP TABLE Ventas_2024;
DROP TABLE Ventas_2025;


-------------------------------------   joins

USE ETL_Demo;
GO

-- Crear tablas de ejemplo
CREATE TABLE Clientes_JOIN (
    ClienteID INT PRIMARY KEY,
    Nombre VARCHAR(50)
);

CREATE TABLE Pedidos_JOIN (
    PedidoID INT PRIMARY KEY,
    ClienteID INT,
    Producto VARCHAR(50),
    Monto DECIMAL(10,2)
);

-- Insertar datos
INSERT INTO Clientes_JOIN VALUES
(1, 'Luis Romero'),
(2, 'Ana García'),
(3, 'Carlos López'),
(4, 'Marta Pérez');  -- Cliente sin pedidos

INSERT INTO Pedidos_JOIN VALUES
(101, 1, 'Laptop', 15000),
(102, 1, 'Mouse', 300),
(103, 2, 'Teclado', 800),
(104, 2, 'Monitor', 4000),
(105, 3, 'Laptop', 15500);
-- Cliente 4 no tiene pedidos
-- Pedido 106 tiene ClienteID 99 que no existe en Clientes

INSERT INTO Pedidos_JOIN VALUES (106, 99, 'Producto Huérfano', 1000);

-- ============================================
-- 1. INNER JOIN (solo coincidencias)
-- ============================================
SELECT '=== INNER JOIN ===' AS Mensaje;
SELECT c.ClienteID, c.Nombre, p.PedidoID, p.Producto, p.Monto
FROM Clientes_JOIN c
INNER JOIN Pedidos_JOIN p ON c.ClienteID = p.ClienteID;
-- Resultado: Clientes 1,2,3 (Marta Pérez no aparece, Pedido 106 no aparece)

-- ============================================
-- 2. LEFT JOIN (todos los clientes, tengan o no pedidos)
-- ============================================
SELECT '=== LEFT JOIN ===' AS Mensaje;
SELECT c.ClienteID, c.Nombre, p.PedidoID, p.Producto, p.Monto
FROM Clientes_JOIN c
LEFT JOIN Pedidos_JOIN p ON c.ClienteID = p.ClienteID;
-- Resultado: Clientes 1,2,3 con pedidos, Cliente 4 con NULL en pedidos

-- ============================================
-- 3. RIGHT JOIN (todos los pedidos, tengan o no cliente)
-- ============================================
SELECT '=== RIGHT JOIN ===' AS Mensaje;
SELECT c.ClienteID, c.Nombre, p.PedidoID, p.Producto, p.Monto
FROM Clientes_JOIN c
RIGHT JOIN Pedidos_JOIN p ON c.ClienteID = p.ClienteID;
-- Resultado: Pedidos 101-105 con clientes, Pedido 106 con NULL en cliente

-- ============================================
-- 4. FULL OUTER JOIN (todos los registros de ambas tablas)
-- ============================================
SELECT '=== FULL OUTER JOIN ===' AS Mensaje;
SELECT c.ClienteID, c.Nombre, p.PedidoID, p.Producto, p.Monto
FROM Clientes_JOIN c
FULL OUTER JOIN Pedidos_JOIN p ON c.ClienteID = p.ClienteID;

-- ============================================
-- 5. CROSS JOIN (producto cartesiano)
-- ============================================
SELECT '=== CROSS JOIN (primeros 5) ===' AS Mensaje;
SELECT TOP 5 c.Nombre, p.Producto
FROM Clientes_JOIN c
CROSS JOIN Pedidos_JOIN p;
-- Resultado: Cada cliente con cada pedido

-- ============================================
-- 6. SELF JOIN (una tabla se une a sí misma)
-- ============================================
ALTER TABLE Clientes_JOIN ADD ReferidoPor INT NULL;
UPDATE Clientes_JOIN SET ReferidoPor = 1 WHERE ClienteID IN (2,3);

SELECT '=== SELF JOIN ===' AS Mensaje;
SELECT 
    c1.Nombre AS Cliente,
    c2.Nombre AS ReferidoPor
FROM Clientes_JOIN c1
LEFT JOIN Clientes_JOIN c2 ON c1.ReferidoPor = c2.ClienteID;

-- Limpiar
DROP TABLE Clientes_JOIN;
DROP TABLE Pedidos_JOIN;


----  Ejercicio 2: GROUP BY con HAVING
--sql
-- Crear tabla de ventas
CREATE TABLE Ventas_GroupBy (
    VentaID INT IDENTITY(1,1),
    Producto VARCHAR(50),
    Categoria VARCHAR(50),
    Sucursal VARCHAR(50),
    Cantidad INT,
    Total DECIMAL(10,2)
);

INSERT INTO Ventas_GroupBy (Producto, Categoria, Sucursal, Cantidad, Total) VALUES
('Laptop', 'Electrónica', 'Norte', 2, 30000),
('Laptop', 'Electrónica', 'Sur', 1, 15500),
('Mouse', 'Accesorios', 'Norte', 5, 1500),
('Mouse', 'Accesorios', 'Sur', 3, 900),
('Teclado', 'Accesorios', 'Norte', 2, 1600),
('Teclado', 'Accesorios', 'Sur', 1, 800),
('Monitor', 'Electrónica', 'Norte', 1, 4000),
('Monitor', 'Electrónica', 'Sur', 2, 8000);

-- ============================================
-- 1. GROUP BY básico (suma por producto)
-- ============================================
SELECT '=== Ventas por Producto ===' AS Mensaje;
SELECT 
    Producto,
    SUM(Cantidad) AS TotalUnidades,
    SUM(Total) AS TotalVentas
FROM Ventas_GroupBy
GROUP BY Producto
ORDER BY TotalVentas DESC;

-- ============================================
-- 2. GROUP BY con múltiples columnas
-- ============================================
SELECT '=== Ventas por Categoria y Sucursal ===' AS Mensaje;
SELECT 
    Categoria,
    Sucursal,
    SUM(Cantidad) AS TotalUnidades,
    SUM(Total) AS TotalVentas
FROM Ventas_GroupBy
GROUP BY Categoria, Sucursal
ORDER BY Categoria, Sucursal;

-- ============================================
-- 3. GROUP BY con HAVING (filtrar después de agrupar)
-- ============================================
SELECT '=== Categorías con ventas totales > 10000 ===' AS Mensaje;
SELECT 
    Categoria,
    SUM(Total) AS TotalVentas
FROM Ventas_GroupBy
GROUP BY Categoria
HAVING SUM(Total) > 10000;

-- ============================================
-- 4. GROUP BY con HAVING y WHERE combinados
-- ============================================
SELECT '=== Productos con más de 2 unidades vendidas solo en Norte ===' AS Mensaje;
SELECT 
    Producto,
    Sucursal,
    SUM(Cantidad) AS TotalUnidades
FROM Ventas_GroupBy
WHERE Sucursal = 'Norte'  -- Filtra antes de agrupar
GROUP BY Producto, Sucursal
HAVING SUM(Cantidad) > 2  -- Filtra después de agrupar
ORDER BY TotalUnidades DESC;

-- ============================================
-- 5. COUNT con GROUP BY y HAVING
-- ============================================
SELECT '=== Productos vendidos en más de 1 sucursal ===' AS Mensaje;
SELECT 
    Producto,
    COUNT(DISTINCT Sucursal) AS NumeroSucursales,
    SUM(Cantidad) AS TotalUnidades
FROM Ventas_GroupBy
GROUP BY Producto
HAVING COUNT(DISTINCT Sucursal) > 1;

-- ============================================
-- 6. GROUP BY con funciones de agregación múltiples
-- ============================================
SELECT '=== Estadísticas por Producto ===' AS Mensaje;
SELECT 
    Producto,
    COUNT(*) AS NumeroVentas,
    SUM(Cantidad) AS TotalUnidades,
    AVG(Cantidad) AS PromedioUnidades,
    MIN(Total) AS VentaMinima,
    MAX(Total) AS VentaMaxima,
    SUM(Total) AS TotalVentas
FROM Ventas_GroupBy
GROUP BY Producto
ORDER BY TotalVentas DESC;

-- Limpiar
DROP TABLE Ventas_GroupBy;

