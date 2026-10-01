/* ============================================================
   LABORATORIO FINAL SQL
   TABLAS + RELACIONES + FOREIGN KEY + WINDOW FUNCTIONS

   BASE: ETL_Demo

   OBJETIVOS:
   1. Crear tablas desde cero
   2. PRIMARY KEY
   3. FOREIGN KEY
   4. Relacion 1:N
   5. INSERT respetando integridad referencial
   6. JOIN entre tablas relacionadas
   7. COUNT() OVER()
   8. ROW_NUMBER()
   9. RANK()
   10. DENSE_RANK()
   11. LAG()
   12. LEAD()
   13. SUM() OVER()
   14. AVG() OVER()
   15. PARTITION BY
   16. ORDER BY dentro de OVER()
   ============================================================ */


/* ============================================================
   1. CREAR TABLA CLIENTES
   ============================================================ */

USE ETL_Demo;
GO

IF OBJECT_ID('dbo.ClientesPractica', 'U') IS NOT NULL
    DROP TABLE dbo.ClientesPractica;
GO

CREATE TABLE ClientesPractica
(
    ClienteID INT IDENTITY(1,1)
        CONSTRAINT PK_ClientesPractica
        PRIMARY KEY,

    Nombre VARCHAR(100) NOT NULL,

    Ciudad VARCHAR(75),

    FechaRegistro DATE
        CONSTRAINT DF_ClientesPractica_Fecha
        DEFAULT GETDATE()
);
GO


/* ============================================================
   2. CREAR TABLA VENTAS
   ============================================================ */

IF OBJECT_ID('dbo.VentasPractica', 'U') IS NOT NULL
    DROP TABLE dbo.VentasPractica;
GO

CREATE TABLE VentasPractica
(
    VentaID INT IDENTITY(1,1)
        CONSTRAINT PK_VentasPractica
        PRIMARY KEY,

    Fecha DATE NOT NULL,

    Producto VARCHAR(100) NOT NULL,

    Cantidad INT NOT NULL,

    Precio DECIMAL(10,2) NOT NULL,

    Total AS (Cantidad * Precio),

    ClienteID INT NOT NULL,

    CONSTRAINT FK_VentasPractica_Clientes
        FOREIGN KEY (ClienteID)
        REFERENCES ClientesPractica(ClienteID)
);
GO


/* ============================================================
   3. INSERTAR CLIENTES
   ============================================================ */

INSERT INTO ClientesPractica
(
    Nombre,
    Ciudad,
    FechaRegistro
)
VALUES
('Carlos Lopez', 'Queretaro', '2024-03-10'),
('Ana Martinez', 'Toluca', '2024-04-05'),
('Luis Romero', 'CDMX', '2025-05-02'),
('Pedro Ramirez', 'Toluca', '2026-06-16'),
('Ana Torres', 'Guadalajara', '2026-06-17');
GO


/* ============================================================
   4. VER CLIENTES
   ============================================================ */

SELECT *
FROM ClientesPractica;
GO


/* ============================================================
   5. INSERTAR VENTAS
   ============================================================

   Los ClienteID deben existir en ClientesPractica.

   ============================================================ */

INSERT INTO VentasPractica
(
    Fecha,
    Producto,
    Cantidad,
    Precio,
    ClienteID
)
VALUES
('2026-01-10', 'Laptop', 2, 15000, 1),
('2026-01-11', 'Mouse', 5, 300, 1),
('2026-01-12', 'Teclado', 3, 800, 2),
('2026-01-13', 'Monitor', 1, 4000, 2),
('2026-01-14', 'Laptop', 1, 15500, 3),
('2026-01-15', 'Mouse', 3, 300, 3),
('2026-02-01', 'Laptop', 1, 15000, 4),
('2026-02-02', 'Teclado', 2, 800, 4),
('2026-02-03', 'Monitor', 2, 4000, 5);
GO


/* ============================================================
   6. COMPROBAR RELACION CLIENTES -> VENTAS
   ============================================================ */

SELECT
    c.ClienteID,
    c.Nombre,
    c.Ciudad,
    v.VentaID,
    v.Fecha,
    v.Producto,
    v.Cantidad,
    v.Precio,
    v.Total
FROM ClientesPractica AS c
INNER JOIN VentasPractica AS v
    ON c.ClienteID = v.ClienteID
ORDER BY c.ClienteID;
GO


/* ============================================================
   7. PRUEBA DE FOREIGN KEY
   ============================================================

   ESTA OPERACION DEBE FALLAR.

   ClienteID 999 NO EXISTE.

   ============================================================ */

/*
INSERT INTO VentasPractica
(
    Fecha,
    Producto,
    Cantidad,
    Precio,
    ClienteID
)
VALUES
(
    GETDATE(),
    'Laptop',
    1,
    15000,
    999
);
GO
*/


/* ============================================================
   8. COUNT() OVER()
   ============================================================

   ¿CUANTAS VENTAS TIENE CADA CLIENTE?

   IMPORTANTE:

   COUNT() con GROUP BY reduce las filas.

   COUNT() OVER() mantiene las filas.

   ============================================================ */

SELECT
    ClienteID,
    VentaID,
    Producto,
    Total,

    COUNT(*) OVER(
        PARTITION BY ClienteID
    ) AS CantidadVentasCliente

FROM VentasPractica
ORDER BY ClienteID;
GO


/* ============================================================
   9. SUM() OVER()
   ============================================================

   TOTAL ACUMULADO POR CLIENTE.

   ============================================================ */

SELECT
    ClienteID,
    VentaID,
    Fecha,
    Producto,
    Total,

    SUM(Total) OVER(
        PARTITION BY ClienteID
        ORDER BY Fecha, VentaID
    ) AS TotalAcumulado

FROM VentasPractica
ORDER BY ClienteID, Fecha, VentaID;
GO


/* ============================================================
   10. SUM() OVER() SIN PARTITION
   ============================================================

   ACUMULADO GENERAL DE TODAS LAS VENTAS.

   ============================================================ */

SELECT
    VentaID,
    Fecha,
    Producto,
    Total,

    SUM(Total) OVER(
        ORDER BY Fecha, VentaID
    ) AS TotalAcumuladoGeneral

FROM VentasPractica
ORDER BY Fecha, VentaID;
GO


/* ============================================================
   11. AVG() OVER()
   ============================================================ */

SELECT
    ClienteID,
    VentaID,
    Producto,
    Total,

    AVG(Total) OVER(
        PARTITION BY ClienteID
    ) AS PromedioVentaCliente

FROM VentasPractica
ORDER BY ClienteID;
GO


/* ============================================================
   12. ROW_NUMBER()
   ============================================================

   NUMERAR LAS VENTAS DE CADA CLIENTE.

   ============================================================ */

SELECT
    ClienteID,
    VentaID,
    Fecha,
    Producto,
    Total,

    ROW_NUMBER() OVER(
        PARTITION BY ClienteID
        ORDER BY Fecha
    ) AS NumeroVenta

FROM VentasPractica
ORDER BY ClienteID, Fecha;
GO


/* ============================================================
   13. RANK()
   ============================================================

   RANKING DE VENTAS POR CLIENTE.

   ============================================================ */

SELECT
    ClienteID,
    VentaID,
    Producto,
    Total,

    RANK() OVER(
        PARTITION BY ClienteID
        ORDER BY Total DESC
    ) AS RankingVenta

FROM VentasPractica
ORDER BY ClienteID, RankingVenta;
GO


/* ============================================================
   14. DENSE_RANK()
   ============================================================ */

SELECT
    ClienteID,
    VentaID,
    Producto,
    Total,

    DENSE_RANK() OVER(
        PARTITION BY ClienteID
        ORDER BY Total DESC
    ) AS RankingVenta

FROM VentasPractica
ORDER BY ClienteID, RankingVenta;
GO


/* ============================================================
   15. LAG()
   ============================================================

   VER LA VENTA ANTERIOR DEL MISMO CLIENTE.

   ============================================================ */

SELECT
    ClienteID,
    VentaID,
    Fecha,
    Producto,
    Total,

    LAG(Total) OVER(
        PARTITION BY ClienteID
        ORDER BY Fecha, VentaID
    ) AS VentaAnterior

FROM VentasPractica
ORDER BY ClienteID, Fecha, VentaID;
GO


/* ============================================================
   16. LEAD()
   ============================================================

   VER LA SIGUIENTE VENTA DEL MISMO CLIENTE.

   ============================================================ */

SELECT
    ClienteID,
    VentaID,
    Fecha,
    Producto,
    Total,

    LEAD(Total) OVER(
        PARTITION BY ClienteID
        ORDER BY Fecha, VentaID
    ) AS VentaSiguiente

FROM VentasPractica
ORDER BY ClienteID, Fecha, VentaID;
GO


/* ============================================================
   17. COMPARAR VENTA ACTUAL VS ANTERIOR
   ============================================================ */

SELECT
    ClienteID,
    VentaID,
    Fecha,
    Producto,
    Total,

    LAG(Total) OVER(
        PARTITION BY ClienteID
        ORDER BY Fecha, VentaID
    ) AS VentaAnterior,

    Total -
    LAG(Total) OVER(
        PARTITION BY ClienteID
        ORDER BY Fecha, VentaID
    ) AS Diferencia

FROM VentasPractica
ORDER BY ClienteID, Fecha, VentaID;
GO


/* ============================================================
   18. WINDOW FUNCTION + CLIENTES
   ============================================================

   MOSTRAR:

   Cliente
   Ciudad
   Venta
   Ranking de la venta

   ============================================================ */

SELECT
    c.ClienteID,
    c.Nombre,
    c.Ciudad,

    v.VentaID,
    v.Producto,
    v.Total,

    ROW_NUMBER() OVER(
        PARTITION BY c.ClienteID
        ORDER BY v.Total DESC
    ) AS RankingCliente

FROM ClientesPractica AS c
INNER JOIN VentasPractica AS v
    ON c.ClienteID = v.ClienteID

ORDER BY c.ClienteID, RankingCliente;
GO


/* ============================================================
   19. ENCONTRAR LA VENTA MAS ALTA DE CADA CLIENTE
   ============================================================

   Aqui usamos ROW_NUMBER() dentro de un CTE.

   ============================================================ */

WITH VentasRankeadas AS
(
    SELECT
        c.ClienteID,
        c.Nombre,
        c.Ciudad,
        v.VentaID,
        v.Producto,
        v.Total,

        ROW_NUMBER() OVER(
            PARTITION BY c.ClienteID
            ORDER BY v.Total DESC
        ) AS rn

    FROM ClientesPractica AS c

    INNER JOIN VentasPractica AS v
        ON c.ClienteID = v.ClienteID
)

SELECT
    ClienteID,
    Nombre,
    Ciudad,
    VentaID,
    Producto,
    Total
FROM VentasRankeadas
WHERE rn = 1;
GO


/* ============================================================
   20. RESUMEN POR CLIENTE SIN PERDER LAS FILAS
   ============================================================ */

SELECT
    c.ClienteID,
    c.Nombre,
    c.Ciudad,
    v.VentaID,
    v.Producto,
    v.Total,

    COUNT(*) OVER(
        PARTITION BY c.ClienteID
    ) AS NumeroVentas,

    SUM(v.Total) OVER(
        PARTITION BY c.ClienteID
    ) AS TotalCliente,

    AVG(v.Total) OVER(
        PARTITION BY c.ClienteID
    ) AS PromedioCliente

FROM ClientesPractica AS c

INNER JOIN VentasPractica AS v
    ON c.ClienteID = v.ClienteID

ORDER BY c.ClienteID;
GO


/* ============================================================
   21. DIFERENCIA ENTRE GROUP BY Y WINDOW FUNCTION
   ============================================================ */


/* GROUP BY:
   REDUCE LAS FILAS
*/

SELECT
    ClienteID,
    COUNT(*) AS CantidadVentas,
    SUM(Total) AS TotalCliente
FROM VentasPractica
GROUP BY ClienteID;
GO


/* WINDOW:
   MANTIENE LAS FILAS
*/

SELECT
    ClienteID,
    VentaID,
    Producto,
    Total,

    COUNT(*) OVER(
        PARTITION BY ClienteID
    ) AS CantidadVentas,

    SUM(Total) OVER(
        PARTITION BY ClienteID
    ) AS TotalCliente

FROM VentasPractica;
GO


/* ============================================================
   22. LIMPIEZA OPCIONAL
   ============================================================

   NO EJECUTAR SI QUIERES CONSERVAR EL LABORATORIO.

   ============================================================ */

/*
DROP TABLE VentasPractica;
DROP TABLE ClientesPractica;
GO
*/


/* ============================================================
   CONCEPTOS QUE DEBES PODER EXPLICAR DESPUES DEL LABORATORIO

   PRIMARY KEY
   ------------
   Identifica un registro de forma unica.

   FOREIGN KEY
   -----------
   Mantiene la integridad referencial entre tablas.

   1:N
   ---
   Un cliente puede tener muchas ventas.

   OVER()
   -------
   Permite calcular sobre un conjunto de filas
   sin eliminar las filas originales.

   PARTITION BY
   ------------
   Divide las filas en grupos para el calculo.

   ORDER BY dentro de OVER()
   -------------------------
   Define el orden utilizado por la funcion.

   ROW_NUMBER()
   ------------
   Numera filas.

   RANK()
   ------
   Ranking con saltos en empates.

   DENSE_RANK()
   ------------
   Ranking sin saltos.

   LAG()
   -----
   Obtiene el registro anterior.

   LEAD()
   ------
   Obtiene el registro siguiente.

   SUM() OVER()
   ------------
   Acumulados o totales por ventana.

   AVG() OVER()
   ------------
   Promedios por ventana.

   COUNT() OVER()
   --------------
   Conteos por ventana sin eliminar filas.

   ============================================================ */