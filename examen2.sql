drop database CorporativoBI


IF DB_ID('CorporativoBI') IS NULL
BEGIN
CREATE DATABASE CorporativoBI;
END
ELSE 
BEGIN
PRINT 'YA EXISTE LA BASE DE DATOS';
END
GO
USE CorporativoBI;
GO
ALTER DATABASE CorporativoBI
SET RECOVERY FULL;
GO
PRINT 'YA ESTA EN USO LA BASE';
GO


-------

--DROP TABLE VentasBI;

CREATE TABLE VentasBI (
    VentaID INT IDENTITY(1,1) PRIMARY KEY,
    Fecha DATE NOT NULL,
    ProductoID INT NOT NULL,
    ProductoNombre VARCHAR(100) NOT NULL,
    CategoriaID INT NOT NULL,
    CategoriaNombre VARCHAR(50) NOT NULL,
    ClienteID INT NOT NULL,
    ClienteNombre VARCHAR(100) NOT NULL,
    ClienteCiudad VARCHAR(50) NULL,
    ClienteRegion VARCHAR(50) NULL,
    SucursalID INT NOT NULL,
    SucursalNombre VARCHAR(50) NOT NULL,
    SucursalCiudad VARCHAR(50) NULL,
    VendedorID INT NOT NULL,
    VendedorNombre VARCHAR(100) NOT NULL,
    Cantidad INT NOT NULL CHECK (Cantidad > 0),
    PrecioUnitario DECIMAL(12,2) NOT NULL CHECK (PrecioUnitario > 0),
    Total DECIMAL(12,2) NOT NULL,
    Descuento DECIMAL(5,2) DEFAULT 0 CHECK (Descuento BETWEEN 0 AND 100),
    TotalNeto DECIMAL(12,2),
    MetodoPago VARCHAR(30) NOT NULL,
    Status VARCHAR(20) NOT NULL DEFAULT 'Completada',
    FechaCarga DATETIME NOT NULL DEFAULT GETDATE(),
    FechaActualizacion DATETIME NULL
);