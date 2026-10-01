DROP DATABASE [CorporativoBI];


IF DB_ID('CorporativoBI') IS  NULL
BEGIN 
CREATE DATABASE CorporativoBI;
END
ELSE 
BEGIN 
PRINT 'LA BASE YA EXISTE EN EL SISTEMA'
END 
GO
USE CorporativoBI;
GO
ALTER DATABASE CorporativoBI
SET RECOVERY FULL;
GO
PRINT 'YA ESTAMOS EN LA BASE DE DATOS';
GO


------ TABLA USUARIOS

CREATE TABLE Usuarios(
IdUsuario	INT IDENTITY(1,1) PRIMARY KEY,
Nombre	VARCHAR(100) NOT NULL,
ApellidoPaterno	VARCHAR(100) NOT NULL,
ApellidoMaterno	VARCHAR(100) NOT NULL,
Correo	VARCHAR(150) UNIQUE NOT NULL,
PasswordHash	VARCHAR(255) NOT NULL,
Rol	VARCHAR(50) NOT NULL,
FechaCreacion	DATETIME DEFAULT GETDATE(),
Activo	BIT DEFAULT 1);


✅ constraints nombrados


-----------------------  siguiente  tabla 
CREATE TABLE Clientes(
IdCliente INT IDENTITY(1,1) PRIMARY KEY,
NombreCliente	VARCHAR(150) NOT NULL,
RFC	VARCHAR(13) UNIQUE NOT NULL,
Telefono	VARCHAR(20) NOT NULL,
FechaRegistro	DATETIME DEFAULT GETDATE(),
Activo	BIT DEFAULT 1) ;



--------- 

Create table Ventas(
IdVenta	INT IDENTITY(1,1) PRIMARY KEY,
IdCliente	INT,
FechaVenta	DATETIME DEFAULT GETDATE(),
TotalVenta	DECIMAL(10,2) CHECK(TotalVenta > 0),
MetodoPago	VARCHAR(50) NOT NULL,
Activo	BIT DEFAULT 1,
FOREIGN KEY(IdCliente)
REFERENCES Clientes(IdCliente))



Create table Ventas(
IdVenta	INT IDENTITY(1,1) PRIMARY KEY,
IdCliente	INT,
FechaVenta	DATETIME DEFAULT GETDATE(),
TotalVenta	DECIMAL(10,2) CHECK(TotalVenta > 0),
MetodoPago	VARCHAR(50) NOT NULL,
Activo	BIT DEFAULT 1,
FOREIGN KEY (IdCliente)
REFERENCES Clientes(IdCliente),
FOREIGN KEY (IdCliente)
REFERENCES Clientes(IdCliente)
)


---------
CREATE TABLE Productos(
IdProducto	INT IDENTITY(1,1) PRIMARY KEY,
NombreProducto	VARCHAR(150) NOT NULL,
Precio	DECIMAL(10,2) ,
Stock	INT,
Categoria	VARCHAR(100) NOT NULL,
FechaRegistro	DATETIME DEFAULT GETDATE(),
Activo	BIT DEFAULT 1,
CONSTRAINT CHK_Productos_Precio
CHECK(Precio > 0),
CONSTRAINT CHK_Productos_Stock
CHECK(Stock >= 0),
CONSTRAINT PRUEBAS
CHECK(Stock >= 0)
)













