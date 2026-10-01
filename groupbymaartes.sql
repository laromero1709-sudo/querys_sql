USE ETL_Demo;
GO


Select * from  Ventas_Repaso;

DROP TABLE Ventas_Repaso

create table Ventas_Repaso (
VentasID INT IDENTITY(1,1),
Producto VARCHAR(50),
Categoria VARCHAR(50),
Sucursal VARCHAR(50),
Cantidad INT ,
Total DECIMAL(10,2),
Fecha DATE 
)


    --VentaID,
    --Producto,
    --Categoria,
    --Sucursal,
    --Cantidad,
    --Total,
    --Fecha






---- Crear tabla de ventas
--CREATE TABLE Ventas_Repaso (
--    VentaID INT IDENTITY(1,1),
--    Producto VARCHAR(50),
--    Categoria VARCHAR(50),
--    Sucursal VARCHAR(50),
--    Cantidad INT,
--    Total DECIMAL(10,2),
--    Fecha DATE
--);
-----  nombre de los  campos 
    --VentaID,
    --Producto,
    --Categoria,
    --Sucursal,
    --Cantidad,
    --Total,
    --Fecha


select * from  Ventas_Repaso;

--Create table  Ventas_Repaso (
--    VentaID INT IDENTITY(1,1),
--    Producto VARCHAR(50),
--    Categoria VARCHAR(50),
--    Sucursal VARCHAR(50),
--    Cantidad INT,
--    Total DECIMAL(10,2),
--    Fecha DATE

--);


--SELECT * FROM  Ventas_Repaso;


--drop table Ventas_Repaso;

---  REPASO 


--drop table Ventas_Repaso;

--SELECT * FROM  Ventas_Repaso;

--drop table Ventas_Repaso;


create table Ventas_Repaso(
    VentaID INT IDENTITY(1,1),
    Producto VARCHAR(50),
    Categoria VARCHAR(50),
    Sucursal VARCHAR(50),
    Cantidad INT,
    Total DECIMAL(10,2),
    Fecha DATE 
);


SELECT * FROM Ventas_Repaso;


insert into Ventas_Repaso (Producto,Categoria,Sucursal,Cantidad,Total,Fecha)
VALUES('Laptop', 'Electrónica', 'Norte', 2, 30000, '2025-01-01'),
('Laptop', 'Electrónica', 'Sur', 1, 15500, '2025-01-15'),
('Mouse', 'Accesorios', 'Norte', 5, 1500, '2025-01-02'),
('Mouse', 'Accesorios', 'Sur', 3, 900, '2025-01-16'),
('Teclado', 'Accesorios', 'Norte', 2, 1600, '2025-01-03'),
('Teclado', 'Accesorios', 'Centro', 1, 800, '2025-01-17'),
('Monitor', 'Electrónica', 'Sur', 1, 4000, '2025-01-04'),
('Monitor', 'Electrónica', 'Centro', 2, 8000, '2025-01-18');

SELECT * FROM Ventas_Repaso;




-- Insertar datos variados
INSERT INTO Ventas_Repaso (Producto, Categoria, Sucursal, Cantidad, Total, Fecha) VALUES
('Laptop', 'Electrónica', 'Norte', 2, 30000, '2025-01-01'),
('Laptop', 'Electrónica', 'Sur', 1, 15500, '2025-01-15'),
('Mouse', 'Accesorios', 'Norte', 5, 1500, '2025-01-02'),
('Mouse', 'Accesorios', 'Sur', 3, 900, '2025-01-16'),
('Teclado', 'Accesorios', 'Norte', 2, 1600, '2025-01-03'),
('Teclado', 'Accesorios', 'Centro', 1, 800, '2025-01-17'),
('Monitor', 'Electrónica', 'Sur', 1, 4000, '2025-01-04'),
('Monitor', 'Electrónica', 'Centro', 2, 8000, '2025-01-18');

PRINT '=== DATOS ORIGINALES ===';
SELECT * FROM Ventas_Repaso;
GO

-- ============================================
-- NIVEL 1: GROUP BY básico
-- ============================================
PRINT '=== 1. Ventas por Producto (SUM) ===';

Select  Producto,sum(cantidad) as TotalCantidad, sum(total) as totaltotal
from Ventas_Repaso
group by Producto
ORDER BY totaltotal DESC;




SELECT 
    Producto,
    SUM(Cantidad) AS TotalUnidades,
    SUM(Total) AS TotalVentas
FROM Ventas_Repaso
GROUP BY Producto
ORDER BY TotalVentas DESC;
GO

-- ============================================
-- NIVEL 2: GROUP BY con múltiples columnas
-- ============================================
PRINT '=== 2. Ventas por Categoria y Sucursal ===';
Select Categoria,
    Sucursal, SUM(Cantidad) AS TotalUnidades,
    SUM(Total) AS TotalVentas,
    COUNT(*) AS NumeroVentas from Ventas_Repaso
    group by Categoria,
    Sucursal
    ORDER BY Categoria, Sucursal

SELECT 
    Categoria,
    Sucursal,
    SUM(Cantidad) AS TotalUnidades,
    SUM(Total) AS TotalVentas,
    COUNT(*) AS NumeroVentas
FROM Ventas_Repaso
GROUP BY Categoria, Sucursal
ORDER BY Categoria, Sucursal;
GO

-- ============================================
-- NIVEL 3: GROUP BY con múltiples agregaciones
-- ============================================
PRINT '=== 3. Estadísticas completas por Producto ===';

Select Producto,Count(*) as NumeroVentas, sum(Cantidad) as TotalUnidades
,avg(cantidad) as Promediocantidades, min(total) as Ventaminima,max(total) as Ventamaxima,sum(total) TotalVentas
from Ventas_Repaso
group by Producto
ORDER BY TotalVentas DESC;


SELECT 
    Producto,
    COUNT(*) AS NumeroVentas,
    SUM(Cantidad) AS TotalUnidades,
    AVG(Cantidad) AS PromedioUnidades,
    MIN(Total) AS VentaMinima,
    MAX(Total) AS VentaMaxima,
    SUM(Total) AS TotalVentas
FROM Ventas_Repaso
GROUP BY Producto
ORDER BY TotalVentas DESC;
GO

-- ============================================
-- NIVEL 4: HAVING básico (filtrar después de agrupar)
-- ============================================
PRINT '=== 4. Productos con ventas totales > 10000 ===';
SELECT 
    Producto,
    SUM(Total) AS TotalVentas
FROM Ventas_Repaso
GROUP BY Producto
HAVING SUM(Total) > 10000
ORDER BY TotalVentas DESC;
GO

Select Producto, sum(Total) as totalventas from Ventas_Repaso
group by Producto
having sum(Total)> 10000
Order by totalventas desc;

-- ============================================
-- NIVEL 5: WHERE vs HAVING (diferencia clave)
-- ============================================
PRINT '=== 5. WHERE filtra ANTES de agrupar, HAVING filtra DESPUÉS ===';

-- WHERE: solo ventas del Norte (filtra filas antes de agrupar)
PRINT '--- WHERE (solo Sucursal = Norte) ---';
SELECT 
    Producto,
    SUM(Total) AS TotalVentasNorte
FROM Ventas_Repaso
WHERE Sucursal = 'Norte'
GROUP BY Producto
ORDER BY TotalVentasNorte DESC;

-- HAVING: todas las sucursales, pero solo productos con TotalVentas > 8000
PRINT '--- HAVING (TotalVentas > 8000) ---';

Select Producto,sum(total) as Totalventas from Ventas_Repaso
group by Producto
having sum(total) > 8000
order by Totalventas

SELECT 
    Producto,
    SUM(Total) AS TotalVentas
FROM Ventas_Repaso
GROUP BY Producto
HAVING SUM(Total) > 8000
ORDER BY TotalVentas DESC;
GO

-- ============================================
-- NIVEL 6: HAVING con COUNT
-- ============================================
PRINT '=== 6. Productos vendidos en más de 1 sucursal ===';

Select Producto, 
Count(distinct Sucursal) as NumeroSucursales,
sum(Cantidad) as TotalUnidades
from Ventas_Repaso
Group  by Producto
having Count(distinct Sucursal) > 1
ORDER BY NumeroSucursales DESC;



SELECT 
    Producto,
    COUNT(DISTINCT Sucursal) AS NumeroSucursales,
    SUM(Cantidad) AS TotalUnidades
FROM Ventas_Repaso
GROUP BY Producto
HAVING COUNT(DISTINCT Sucursal) > 1
ORDER BY NumeroSucursales DESC;
GO



-- ============================================
-- NIVEL 7: Ejercicio combinado - PRODUCTOS TOP
-- ============================================
PRINT '=== 7. Productos TOP por ventas (solo categoría Accesorios) ===';
-- Filtra por categoría (WHERE) y luego por ventas > 2000 (HAVING)
SELECT 
    Producto,
    SUM(Cantidad) AS TotalUnidades,
    SUM(Total) AS TotalVentas
FROM Ventas_Repaso
WHERE Categoria = 'Accesorios'
GROUP BY Producto
HAVING SUM(Total) > 2000
ORDER BY TotalVentas DESC;
GO

Select Producto ,
sum(Cantidad) as TotalUnidades,
sum(Total) as Totalventas
from  Ventas_Repaso
where categoria='Accesorios'
group by Producto
HAVING SUM(Total) > 2000
ORDER BY TotalVentas DESC;




-- ============================================
-- NIVEL 8: Ejercicio - Resumen por mes
-- ============================================
PRINT '=== 8. Ventas por mes (solo meses con ventas > 20000) ===';
SELECT 
    YEAR(Fecha) AS Anio,
    MONTH(Fecha) AS Mes,
    SUM(Total) AS TotalVentas,
    COUNT(*) AS NumeroVentas
FROM Ventas_Repaso
GROUP BY YEAR(Fecha), MONTH(Fecha)
HAVING SUM(Total) > 20000
ORDER BY Anio, Mes;
GO



Select year(fecha) as Anio, month(fecha) as Mes,
Sum(Total) as TotalVentas, Count(*) as NumeroVentas
from Ventas_Repaso
Group  by year(fecha), month(fecha)
having sum(Total)>20000
Order by anio,Mes;

-- ============================================
-- Limpiar
-- ============================================
DROP TABLE Ventas_Repaso;
PRINT '=== REPASO COMPLETADO ===';
GO