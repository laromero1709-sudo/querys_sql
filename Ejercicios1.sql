--USE ETL_Demo;
--GO

---- Verificar que tienes la tabla Ventas
--SELECT * FROM Ventas;

---- Backup completo de ETL_Demo
--BACKUP DATABASE ETL_Demo
--TO DISK = 'C:\Mac\Home\Documents\Portafolio1\ETL_Demo_Full_1.bak'
--WITH INIT, STATS = 10;



--BACKUP DATABASE ETL_Demo
--TO DISK = 'C:\Mac\Home\Documents\Portafolio1\ETL_Demo_Diff_1.bak'
--WITH DIFFERENTIAL, STATS = 10;


--SELECT name, recovery_model_desc
--FROM sys.databases
--WHERE name = 'ETL_Demo';



---- Cambiar ETL_Demo a modo FULL
--ALTER DATABASE ETL_Demo SET RECOVERY FULL;
--GO

---- Verificar el cambio
--SELECT name, recovery_model_desc
--FROM sys.databases
--WHERE name = 'ETL_Demo';



-- Backup FULL obligatorio después del cambio
--BACKUP DATABASE ETL_Demo
--TO DISK = 'C:\Mac\Home\Documents\Portafolio1\ETL_Demo_Full_AfterChange.bak'
--WITH INIT;

--SELECT name, recovery_model_desc
--FROM sys.databases
--WHERE name = 'ETL_Demo';


--USE ETL_Demo;

---- Insertar una venta de prueba
--INSERT INTO Ventas (Fecha, Producto, Cantidad, PrecioUnitario, Total, SucursalID, FechaCarga)
--VALUES ('2025-01-23', 'LOG Prueba', 2, 500, 1000, 1, GETDATE());

---- Verificar que se insertó
--SELECT * FROM Ventas WHERE Producto = 'LOG Prueba';

--BACKUP LOG ETL_Demo
--TO DISK = 'C:\Mac\Home\Documents\Portafolio1\ETL_Demo_Log_1.trn'
--WITH INIT;


---- ejemplo de job
USE msdb;
GO

-- 1. CREAR EL JOB
EXEC sp_add_job
    @job_name = 'Backups_Automaticos_ETL_Demo',
    @enabled = 1,
    @description = 'Job completo: FULL semanal, DIFF diario, LOG cada hora';

-- 2. AGREGAR PASOS AL JOB

---- Paso 1: Backup FULL
--EXEC sp_add_jobstep
--    @job_name = 'Backups_Automaticos_ETL_Demo',
--    @step_name = 'Backup FULL',
--    @step_id = 1,
--    @command = 'BACKUP DATABASE ETL_Demo TO DISK = ''C:\Temp\ETL_Demo_Full.bak'' WITH INIT, STATS = 10',
--    @database_name = 'master',
--    @on_success_action = 3,
--    @on_fail_action = 2;

---- Paso 2: Backup DIFFERENTIAL
--EXEC sp_add_jobstep
--    @job_name = 'Backups_Automaticos_ETL_Demo',
--    @step_name = 'Backup DIFFERENTIAL',
--    @step_id = 2,
--    @command = 'BACKUP DATABASE ETL_Demo TO DISK = ''C:\Temp\ETL_Demo_Diff.bak'' WITH DIFFERENTIAL, STATS = 10',
--    @database_name = 'master',
--    @on_success_action = 3,
--    @on_fail_action = 2;

---- Paso 3: Backup LOG
--EXEC sp_add_jobstep
--    @job_name = 'Backups_Automaticos_ETL_Demo',
--    @step_name = 'Backup LOG',
--    @step_id = 3,
--    @command = 'BACKUP LOG ETL_Demo TO DISK = ''C:\Temp\ETL_Demo_Log.trn'' WITH STATS = 10',
--    @database_name = 'master',
--    @on_success_action = 1,
--    @on_fail_action = 2;

---- 3. CREAR PROGRAMACIONES (SCHEDULES)

---- Programación 1: FULL los domingos a las 2 AM
--EXEC sp_add_schedule
--    @schedule_name = 'Dom_2AM_FULL',
--    @freq_type = 8,
--    @freq_interval = 1,
--    @freq_recurrence_factor = 1,
--    @active_start_time = 20000;

---- Programación 2: DIFF de lunes a sabado a las 2 AM
--EXEC sp_add_schedule
--    @schedule_name = 'Lun_Sab_2AM_DIFF',
--    @freq_type = 8,
--    @freq_interval = 126,
--    @freq_recurrence_factor = 1,
--    @active_start_time = 20000;

---- Programación 3: LOG cada hora de 3 AM a 11 PM
--EXEC sp_add_schedule
--    @schedule_name = 'Cada_Hora_LOG',
--    @freq_type = 4,
--    @freq_interval = 1,
--    @freq_subday_type = 2,
--    @freq_subday_interval = 60,
--    @active_start_time = 30000,
--    @active_end_time = 230000;

---- 4. ASIGNAR PROGRAMACIONES AL JOB
--EXEC sp_attach_schedule
--    @job_name = 'Backups_Automaticos_ETL_Demo',
--    @schedule_name = 'Dom_2AM_FULL';

--EXEC sp_attach_schedule
--    @job_name = 'Backups_Automaticos_ETL_Demo',
--    @schedule_name = 'Lun_Sab_2AM_DIFF';

--EXEC sp_attach_schedule
--    @job_name = 'Backups_Automaticos_ETL_Demo',
--    @schedule_name = 'Cada_Hora_LOG';

---- 5. ASIGNAR JOB AL SERVIDOR
--EXEC sp_add_jobserver
--    @job_name = 'Backups_Automaticos_ETL_Demo',
--    @server_name = '(local)';
--GO

---- 6. VERIFICAR EL JOB CREADO
--SELECT job_id, name, enabled, date_created
--FROM msdb.dbo.sysjobs
--WHERE name = 'Backups_Automaticos_ETL_Demo';

---- 7. EJECUTAR EL JOB MANUALMENTE (si se necesita)
---- EXEC msdb.dbo.sp_start_job @job_name = 'Backups_Automaticos_ETL_Demo';

---- 8. ELIMINAR EL JOB (si se necesita limpiar)
---- EXEC msdb.dbo.sp_delete_job @job_name = 'Backups_Automaticos_ETL_Demo';


------ ejemplo de job


--1.1 Crear un login a nivel servidor
-- Login para una aplicación .NET
CREATE LOGIN App_Ventas
WITH PASSWORD = 'Ventas2025!',
DEFAULT_DATABASE = ETL_Demo;


--1.2 Crear un usuario en tu base ETL_Demo
USE ETL_Demo;
GO
CREATE USER App_Ventas FOR LOGIN App_Ventas;


--1.3 Verificar que se crearon
--sql
-- Ver logins a nivel servidor
SELECT name, type_desc, is_disabled
FROM sys.sql_logins
WHERE name = 'App_Ventas';

-- Ver usuarios en la base
USE ETL_Demo;
SELECT name, type_desc
FROM sys.database_principals
WHERE name = 'App_Ventas';


-- Solo lectura
ALTER ROLE db_datareader ADD MEMBER App_Ventas;

-- Solo escritura (INSERT, UPDATE, DELETE)
ALTER ROLE db_datawriter ADD MEMBER App_Ventas;



-- Ver qué permisos tiene el usuario
EXEC sp_helprotect @username = 'App_Ventas';



-- Crear rol para auditores (solo ven ciertas tablas)
CREATE ROLE Auditores;

-- Permiso solo a una tabla específica
GRANT SELECT ON Ventas TO Auditores;

-- Denegar permiso a tablas sensibles
DENY SELECT ON Empleados TO Auditores;

-- Asignar usuario al rol
ALTER ROLE Auditores ADD MEMBER App_Ventas;


USE ETL_Demo;
GO

-- Agregar columna CURP a tu tabla Ventas (solo para ejemplo)
ALTER TABLE Ventas ADD CURP VARCHAR(18) NULL;

Select * from Ventas

---- Actualizar algunas filas con datos de ejemplo
--UPDATE Ventas SET CURP = 'GALE800101MDFRRR09' WHERE VentasID = 1;
--UPDATE Ventas SET CURP = 'MAGJ850202MDFRRN07' WHERE VentasID = 2;



----- Paso 2: Aplicar máscara (ocultar datos)
--sql
-- Máscara: muestra primeros 4, luego asteriscos, luego últimos 4
--ALTER TABLE Ventas
--ALTER COLUMN CURP ADD MASKED WITH (FUNCTION = 'partial(4, "******", 4)');



-- Simular un usuario normal (sin permiso UNMASK)
CREATE USER UsuarioNormal WITHOUT LOGIN;
GRANT SELECT ON Ventas TO UsuarioNormal;

-- Ver como usuario normal (ve datos enmascarados)
EXECUTE AS USER = 'UsuarioNormal';
SELECT VentasID, CURP FROM Ventas;
REVERT;

-- Resultado que verá: GALE******RRR09, MAGJ******RN07, ROML******RN09



GRANT UNMASK TO UsuarioNormal;

-- Ahora ve los datos reales
EXECUTE AS USER = 'UsuarioNormal';
SELECT VentasID, CURP FROM Ventas;
REVERT;


SELECT curp FROM Ventas;



USE ETL_Demo;
GO

ALTER TABLE Ventas
ALTER COLUMN CURP DROP MASKED;


SELECT 
    t.name AS Tabla,
    c.name AS Columna,
    c.encryption_type_desc,
    c.encryption_algorithm_name
FROM sys.columns c
JOIN sys.tables t ON c.object_id = t.object_id
WHERE t.name = 'Ventas' AND c.name = 'CURP';

select * from  Ventas

----- encriptada final 
USE ETL_Demo;
GO

-- ============================================
-- 1. CREAR TABLA DE PRUEBA (con datos normales, nada de Always Encrypted)
-- ============================================
PRINT '=== CREANDO TABLA DE PRUEBA ===';
CREATE TABLE PruebaEncriptacion (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(50),
    CURP_Original VARCHAR(18),      -- Texto plano normal
    CURP_Encriptada VARBINARY(256)   -- Aquí guardaremos el CURP encriptado
);
GO

-- ============================================
-- 2. INSERTAR DATOS DE PRUEBA (texto plano normal)
-- ============================================
PRINT '=== INSERTANDO DATOS DE PRUEBA ===';
INSERT INTO PruebaEncriptacion (Nombre, CURP_Original) VALUES
('Luis Romero', 'GALE800101MDFRRR09'),
('Ana García', 'MAGJ850202MDFRRN07'),
('Carlos López', 'ROML861015HDFRRN09'),
('Marta Pérez', 'PERE900101HDFRRN09');
GO

-- ============================================
-- 3. VER DATOS ANTES DE ENCRIPTAR
-- ============================================
PRINT '=== DATOS ANTES DE ENCRIPTAR ===';
SELECT ID, Nombre, CURP_Original, CURP_Encriptada FROM PruebaEncriptacion;
GO

-- ============================================
-- 4. CREAR CLAVE SIMÉTRICA
-- ============================================
PRINT '=== CREANDO CLAVE SIMÉTRICA ===';
CREATE SYMMETRIC KEY ClavePrueba
WITH ALGORITHM = AES_256
ENCRYPTION BY PASSWORD = 'MiClaveSegura123!';
GO

-- ============================================
-- 5. ENCRIPTAR LOS DATOS (usando la clave simétrica)
-- ============================================
PRINT '=== ENCRIPTANDO DATOS ===';
OPEN SYMMETRIC KEY ClavePrueba
DECRYPTION BY PASSWORD = 'MiClaveSegura123!';

UPDATE PruebaEncriptacion
SET CURP_Encriptada = EncryptByKey(Key_GUID('ClavePrueba'), CURP_Original);

CLOSE SYMMETRIC KEY ClavePrueba;
GO

-- ============================================
-- 6. VER DATOS ENCRIPTADOS (CURP_Encriptada se ve como bytes)
-- ============================================
PRINT '=== DATOS ENCRIPTADOS (CURP_Encriptada son bytes ilegibles) ===';
SELECT 
    ID, 
    Nombre, 
    CURP_Original AS TextoPlano,
    CURP_Encriptada AS Encriptado_Bytes
FROM PruebaEncriptacion;
GO

-- ============================================
-- 7. DESENCRIPTAR Y LEER LOS DATOS
-- ============================================
PRINT '=== DATOS DESENCRIPTADOS ===';
OPEN SYMMETRIC KEY ClavePrueba
DECRYPTION BY PASSWORD = 'MiClaveSegura123!';

SELECT 
    ID,
    Nombre,
    CURP_Original AS Original_Visible,
    CONVERT(VARCHAR, DecryptByKey(CURP_Encriptada)) AS CURP_Desencriptada,
    'Desencriptado correctamente' AS Estado
FROM PruebaEncriptacion;

CLOSE SYMMETRIC KEY ClavePrueba;
GO

-- ============================================
-- 8. DEMOSTRAR QUE SIN LA CLAVE NO SE PUEDE LEER
-- ============================================
PRINT '=== INTENTO DE LEER SIN ABRIR LA CLAVE (debe fallar o mostrar NULL) ===';
SELECT 
    ID,
    CONVERT(VARCHAR, DecryptByKey(CURP_Encriptada)) AS SinAbrirClave
FROM PruebaEncriptacion;
GO

-- ============================================
-- 9. ESTADÍSTICAS
-- ============================================
PRINT '=== ESTADÍSTICAS ===';
SELECT 
    COUNT(*) AS TotalRegistros,
    SUM(CASE WHEN CURP_Encriptada IS NOT NULL THEN 1 ELSE 0 END) AS RegistrosEncriptados
FROM PruebaEncriptacion;
GO

-- ============================================
-- 10. LIMPIAR (opcional - ejecuta si quieres borrar la tabla de prueba)
-- ============================================
PRINT '=== LIMPIANDO TABLA DE PRUEBA ===';
DROP SYMMETRIC KEY ClavePrueba;
DROP TABLE PruebaEncriptacion;
PRINT '=== PROCESO COMPLETADO EXITOSAMENTE ===';
GO
----------------------------------------- encriptada  final 


---------------------------------   tiggers
USE ETL_Demo;
GO

CREATE TABLE Auditoria_Ventas (
    AuditoriaID INT IDENTITY(1,1) PRIMARY KEY,
    Usuario VARCHAR(100),
    Fecha DATETIME DEFAULT GETDATE(),
    Accion VARCHAR(20),
    Tabla VARCHAR(50),
    RegistroID INT,
    DatosViejos VARCHAR(MAX),
    DatosNuevos VARCHAR(MAX)
);




CREATE TRIGGER trg_Ventas_Audit_Insert
ON Ventas
AFTER INSERT
AS
BEGIN
    INSERT INTO Auditoria_Ventas (Usuario, Accion, Tabla, RegistroID, DatosNuevos)
    SELECT 
        SYSTEM_USER,
        'INSERT',
        'Ventas',
        inserted.VentasID,
        'Producto: ' + inserted.Producto + ', Cantidad: ' + CAST(inserted.Cantidad AS VARCHAR)
    FROM inserted;
END;

CREATE TRIGGER trg_Ventas_Audit_Update
ON Ventas
AFTER UPDATE
AS
BEGIN
    INSERT INTO Auditoria_Ventas (Usuario, Accion, Tabla, RegistroID, DatosViejos, DatosNuevos)
    SELECT 
        SYSTEM_USER,
        'UPDATE',
        'Ventas',
        inserted.VentasID,
        'Cantidad vieja: ' + CAST(deleted.Cantidad AS VARCHAR),
        'Cantidad nueva: ' + CAST(inserted.Cantidad AS VARCHAR)
    FROM inserted
    INNER JOIN deleted ON inserted.VentasID = deleted.VentasID
    WHERE inserted.Cantidad != deleted.Cantidad;
END;


CREATE TRIGGER trg_Ventas_Audit_Delete
ON Ventas
AFTER DELETE
AS
BEGIN
    INSERT INTO Auditoria_Ventas (Usuario, Accion, Tabla, RegistroID, DatosViejos)
    SELECT 
        SYSTEM_USER,
        'DELETE',
        'Ventas',
        deleted.VentasID,
        'Producto: ' + deleted.Producto + ', Cantidad: ' + CAST(deleted.Cantidad AS VARCHAR)
    FROM deleted;
END;



-- Probar INSERT
INSERT INTO Ventas (Fecha, Producto, Cantidad, PrecioUnitario, Total, SucursalID, FechaCarga)
VALUES (GETDATE(), 'AuditoriaTest', 5, 100, 500, 1, GETDATE());

-- Probar UPDATE
UPDATE Ventas SET Cantidad = 10 WHERE Producto = 'AuditoriaTest';

-- Probar DELETE
DELETE FROM Ventas WHERE Producto = 'AuditoriaTest';


SELECT * FROM Auditoria_Ventas ORDER BY Fecha DESC;


-------------------------------- tiggers



SELECT 
    name AS TriggerName,
    OBJECT_NAME(parent_id) AS TableName,
    is_disabled,
    create_date
FROM sys.triggers
WHERE parent_class = 1;  -- Triggers de tabla


-- Deshabilitar un trigger
DISABLE TRIGGER trg_Ventas_Audit_Insert ON Ventas;

-- Habilitar un trigger
ENABLE TRIGGER trg_Ventas_Audit_Insert ON Ventas;

-- Eliminar un trigger
DROP TRIGGER trg_Ventas_Audit_Insert;




------ datos  sucios.
USE ETL_Demo;
GO

-- Crear tabla con problemas de calidad
CREATE TABLE Clientes_Sucios (
    ClienteID INT,
    Nombre VARCHAR(50),
    Email VARCHAR(100),
    Telefono VARCHAR(15),
    Edad INT,
    FechaRegistro DATE
);

-- Insertar datos con problemas
INSERT INTO Clientes_Sucios VALUES
(1, 'Luis Romero', 'luis@email.com', '7221234567', 35, '2024-01-15'),
(1, 'Luis Romero', 'luis@email.com', '7221234567', 35, '2024-01-15'),  -- DUPLICADO exacto
(2, 'Ana García', 'ana@email.com', '7222345678', -5, '2024-02-20'),     -- EDAD negativa
(3, 'Carlos López', NULL, '7223456789', 150, '2024-03-10'),              -- EMAIL nulo, EDAD inválida
(4, '', 'invalido', '123', 25, '2024-04-05'),                           -- NOMBRE vacío, EMAIL inválido
(5, 'Marta Pérez', 'marta@email.com', NULL, 30, '2024-05-01'),           -- TELEFONO nulo
(6, 'Pedro Gómez', 'pedro@email.com', '7224567890', 17, '2024-06-10'),   -- EDAD menor (17 años, válido)
(7, 'Laura Díaz', 'laura@email.com', '7225678901', 65, '2024-07-20');    -- Dato correcto




select * from Clientes_Sucios;



------ data profiling server 

-- 1. Contar registros totales
SELECT COUNT(*) AS TotalRegistros FROM Clientes_Sucios;

-- 2. Detectar nulos por columna
SELECT 
    COUNT(*) AS Total,
    SUM(CASE WHEN Nombre IS NULL OR Nombre = '' THEN 1 ELSE 0 END) AS Nombre_Nulos,
    SUM(CASE WHEN Email IS NULL OR Email = '' THEN 1 ELSE 0 END) AS Email_Nulos,
    SUM(CASE WHEN Telefono IS NULL OR Telefono = '' THEN 1 ELSE 0 END) AS Telefono_Nulos,
    SUM(CASE WHEN Edad IS NULL THEN 1 ELSE 0 END) AS Edad_Nulos,
    SUM(CASE WHEN FechaRegistro IS NULL THEN 1 ELSE 0 END) AS Fecha_Nulos
FROM Clientes_Sucios;

-- 3. Detectar duplicados
SELECT 
    ClienteID, Nombre, Email, Telefono, Edad, FechaRegistro,
    COUNT(*) AS CantidadDuplicados
FROM Clientes_Sucios
GROUP BY ClienteID, Nombre, Email, Telefono, Edad, FechaRegistro
HAVING COUNT(*) > 1;

-- 4. Detectar valores fuera de rango
SELECT 
    'Edad negativa o > 120' AS Problema,
    COUNT(*) AS Cantidad
FROM Clientes_Sucios
WHERE Edad < 0 OR Edad > 120

UNION ALL

SELECT 
    'Email sin @' AS Problema,
    COUNT(*) AS Cantidad
FROM Clientes_Sucios
WHERE Email IS NOT NULL AND Email NOT LIKE '%@%'

UNION ALL

SELECT 
    'Teléfono muy corto' AS Problema,
    COUNT(*) AS Cantidad
FROM Clientes_Sucios
WHERE Telefono IS NOT NULL AND LEN(Telefono) < 10;


---- limpiar datos -- 1. Eliminar duplicados (dejar solo uno)
WITH Duplicados AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY ClienteID ORDER BY (SELECT NULL)) AS rn
    FROM Clientes_Sucios
)
DELETE FROM Duplicados WHERE rn > 1;

-- 2. Corregir edades negativas o inválidas
UPDATE Clientes_Sucios SET Edad = NULL WHERE Edad < 0 OR Edad > 120;

-- 3. Corregir emails inválidos
UPDATE Clientes_Sucios SET Email = NULL WHERE Email NOT LIKE '%@%';

-- 4. Corregir teléfonos (dejar NULL si no cumple)
UPDATE Clientes_Sucios SET Telefono = NULL WHERE LEN(Telefono) < 10;

-- 5. Corregir nombres vacíos
UPDATE Clientes_Sucios SET Nombre = NULL WHERE Nombre = '';

-- 6. Eliminar registros sin información mínima
DELETE FROM Clientes_Sucios WHERE Nombre IS NULL;


---- contraints  

-- 1. PRIMARY KEY (evita duplicados)
ALTER TABLE Clientes_Sucios
ADD CONSTRAINT PK_Clientes PRIMARY KEY (ClienteID);
-- ERROR: Hay duplicados, hay que limpiar primero

-- 2. UNIQUE (evita emails repetidos)
ALTER TABLE Clientes_Sucios
ADD CONSTRAINT UQ_Clientes_Email UNIQUE (Email);
-- Primero hay que manejar nulos y duplicados

-- 3. CHECK (rango de edad válido)
ALTER TABLE Clientes_Sucios
ADD CONSTRAINT CK_Clientes_Edad CHECK (Edad BETWEEN 0 AND 120);

-- 4. CHECK (email válido)
ALTER TABLE Clientes_Sucios
ADD CONSTRAINT CK_Clientes_Email CHECK (Email LIKE '%@%');

-- 5. NOT NULL
ALTER TABLE Clientes_Sucios
ALTER COLUMN Nombre VARCHAR(50) NOT NULL;



----- foringer key 


--Ejercicio 4: Integridad referencial (FOREIGN KEY)
--Crear tabla de sucursales
--sql
CREATE TABLE Sucursales_Prueba (
    SucursalID INT PRIMARY KEY,
    NombreSucursal VARCHAR(50),
    Ciudad VARCHAR(50)
);

INSERT INTO Sucursales_Prueba VALUES
(1, 'Sucursal Norte', 'Toluca'),
(2, 'Sucursal Sur', 'CDMX'),
(3, 'Sucursal Oriente', 'Querétaro');
--Agregar columna SucursalID a Clientes_Sucios
--sql
ALTER TABLE Clientes_Sucios ADD SucursalID INT;

-- Actualizar algunos clientes
UPDATE Clientes_Sucios SET SucursalID = 1 WHERE ClienteID = 1;
UPDATE Clientes_Sucios SET SucursalID = 2 WHERE ClienteID = 2;
UPDATE Clientes_Sucios SET SucursalID = 3 WHERE ClienteID = 3;
UPDATE Clientes_Sucios SET SucursalID = 4 WHERE ClienteID = 4; -- Sucursal 4 NO existe (violará FK)
--Agregar FOREIGN KEY
--sql
ALTER TABLE Clientes_Sucios
ADD CONSTRAINT FK_Clientes_Sucursal
FOREIGN KEY (SucursalID) REFERENCES Sucursales_Prueba(SucursalID);
--Detectar huérfanos (valores que violan FK)
--sql
SELECT * FROM Clientes_Sucios
WHERE SucursalID IS NOT NULL 
  AND SucursalID NOT IN (SELECT SucursalID FROM Sucursales_Prueba);
--📋 Ejercicio 5: Limpiar todo
--sql
-- Eliminar tabla de prueba
DROP TABLE Clientes_Sucios;
DROP TABLE Sucursales_Prueba;


----- index
USE ETL_Demo;
GO

-- ============================================
-- 1. CREAR TABLA DE PRUEBA CON DATOS DUPLICADOS
-- ============================================
PRINT '=== CREANDO TABLA DE PRUEBA ===';
CREATE TABLE Clientes_Unicos (
    ClienteID INT,
    Nombre VARCHAR(50),
    Email VARCHAR(100),
    Telefono VARCHAR(15),
    Activo BIT DEFAULT 1
);

INSERT INTO Clientes_Unicos (ClienteID, Nombre, Email, Telefono) VALUES
(1, 'Luis Romero', 'luis@mail.com', '7221234567'),
(2, 'Ana García', 'ana@mail.com', '7222345678'),
(3, 'Carlos López', 'luis@mail.com', '7223456789'),  -- Email duplicado!
(4, 'Marta Pérez', 'marta@mail.com', '7224567890'),
(5, 'Pedro Gómez', 'pedro@mail.com', '7225678901');

PRINT '=== DATOS INICIALES (CON DUPLICADO EN EMAIL) ===';
SELECT * FROM Clientes_Unicos;
GO

-- ============================================
-- 2. INTENTAR CREAR UNIQUE INDEX (FALLARÁ POR DUPLICADOS)
-- ============================================
PRINT '=== INTENTANDO CREAR UNIQUE INDEX (DEBE FALLAR) ===';
BEGIN TRY
    CREATE UNIQUE INDEX UQ_Clientes_Unicos_Email 
    ON Clientes_Unicos(Email);
    PRINT 'ÍNDICE CREADO CORRECTAMENTE';
END TRY
BEGIN CATCH
    PRINT 'ERROR: No se puede crear índice único porque hay emails duplicados';
    PRINT ERROR_MESSAGE();
END CATCH
GO

-- ============================================
-- 3. DETECTAR Y ELIMINAR DUPLICADOS
-- ============================================
PRINT '=== DETECTANDO DUPLICADOS ===';
SELECT Email, COUNT(*) AS Cantidad
FROM Clientes_Unicos
GROUP BY Email
HAVING COUNT(*) > 1;

PRINT '=== ELIMINANDO DUPLICADOS ===';
WITH Duplicados AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY Email ORDER BY ClienteID) AS rn
    FROM Clientes_Unicos
)
DELETE FROM Duplicados WHERE rn > 1;

PRINT '=== DATOS DESPUÉS DE LIMPIAR DUPLICADOS ===';
SELECT * FROM Clientes_Unicos;
GO

-- ============================================
-- 4. CREAR UNIQUE INDEX (AHORA SÍ FUNCIONA)
-- ============================================
PRINT '=== CREANDO UNIQUE INDEX EN EMAIL ===';
CREATE UNIQUE INDEX UQ_Clientes_Unicos_Email 
ON Clientes_Unicos(Email);
PRINT 'ÍNDICE ÚNICO CREADO EXITOSAMENTE';
GO

-- ============================================
-- 5. VERIFICAR EL ÍNDICE ÚNICO (EVITA DUPLICADOS)
-- ============================================
PRINT '=== INTENTANDO INSERTAR EMAIL DUPLICADO (DEBE FALLAR) ===';
BEGIN TRY
    INSERT INTO Clientes_Unicos (ClienteID, Nombre, Email, Telefono)
    VALUES (6, 'Nuevo Usuario', 'luis@mail.com', '7226789012');
    PRINT 'INSERTADO CORRECTAMENTE';
END TRY
BEGIN CATCH
    PRINT 'ERROR: No se puede insertar email duplicado (UNIQUE INDEX lo impide)';
    PRINT ERROR_MESSAGE();
END CATCH
GO

-- ============================================
-- 6. CREAR UNIQUE INDEX CON MÚLTIPLES COLUMNAS
-- ============================================
PRINT '=== CREANDO UNIQUE INDEX COMPUESTO (ClienteID + Email) ===';
CREATE UNIQUE INDEX UQ_Clientes_Unicos_ClienteEmail 
ON Clientes_Unicos(ClienteID, Email);
PRINT 'ÍNDICE COMPUESTO CREADO';
GO

-- ============================================
-- 7. CREAR UNIQUE INDEX FILTRADO (SOLO PARA ACTIVOS)
-- ============================================
PRINT '=== CREANDO UNIQUE INDEX FILTRADO (solo clientes activos) ===';
CREATE UNIQUE INDEX UQ_Clientes_Unicos_Email_Activos 
ON Clientes_Unicos(Email)
WHERE Activo = 1;
PRINT 'ÍNDICE FILTRADO CREADO';
GO

-- ============================================
-- 8. CREAR UNIQUE INDEX CON INCLUDE (MEJORA RENDIMIENTO)
-- ============================================
PRINT '=== CREANDO UNIQUE INDEX CON INCLUDE ===';
CREATE UNIQUE INDEX UQ_Clientes_Unicos_Email_Include 
ON Clientes_Unicos(Email)
INCLUDE (Nombre, Telefono);
PRINT 'ÍNDICE CON INCLUDE CREADO';
GO

-- ============================================
-- 9. VER TODOS LOS ÍNDICES DE LA TABLA
-- ============================================
PRINT '=== ÍNDICES DE LA TABLA Clientes_Unicos ===';
SELECT 
    i.name AS IndexName,
    i.is_unique,
    i.is_unique_constraint,
    i.is_filtered,
    i.filter_definition,
    STRING_AGG(c.name, ',') AS Columnas
FROM sys.indexes i
LEFT JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
LEFT JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE i.object_id = OBJECT_ID('Clientes_Unicos')
  AND i.name IS NOT NULL
GROUP BY i.name, i.is_unique, i.is_unique_constraint, i.is_filtered, i.filter_definition
ORDER BY i.name;
GO

-- ============================================
-- 10. PROBAR BÚSQUEDAS (EL ÍNDICE ACELERA LAS CONSULTAS)
-- ============================================
PRINT '=== CONSULTA QUE USA EL ÍNDICE ÚNICO ===';
SET STATISTICS TIME ON;
SELECT * FROM Clientes_Unicos WHERE Email = 'ana@mail.com';
SET STATISTICS TIME OFF;
GO

-- ============================================
-- 11. ELIMINAR ÍNDICES Y LIMPIAR
-- ============================================
PRINT '=== ELIMINANDO ÍNDICES ===';
DROP INDEX IF EXISTS UQ_Clientes_Unicos_Email ON Clientes_Unicos;
DROP INDEX IF EXISTS UQ_Clientes_Unicos_ClienteEmail ON Clientes_Unicos;
DROP INDEX IF EXISTS UQ_Clientes_Unicos_Email_Activos ON Clientes_Unicos;
DROP INDEX IF EXISTS UQ_Clientes_Unicos_Email_Include ON Clientes_Unicos;
PRINT 'ÍNDICES ELIMINADOS';
GO

-- ============================================
-- 12. LIMPIAR TABLA DE PRUEBA
-- ============================================
PRINT '=== ELIMINANDO TABLA DE PRUEBA ===';
DROP TABLE Clientes_Unicos;
PRINT 'TABLA ELIMINADA';
GO

PRINT '=== PROCESO COMPLETADO EXITOSAMENTE ===';




------   try cath 

USE ETL_Demo;
GO

-- ============================================
-- 1. CREAR TABLA CON CONSTRAINTS
-- ============================================
CREATE TABLE Productos_Calidad (
    ProductoID INT PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    Precio DECIMAL(10,2) CHECK (Precio > 0),
    CodigoBarras VARCHAR(13) UNIQUE
);

-- ============================================
-- 2. PROCEDIMIENTO CON TRY...CATCH PARA INSERTAR
-- ============================================
CREATE PROCEDURE sp_InsertarProducto
    @ProductoID INT,
    @Nombre VARCHAR(50),
    @Precio DECIMAL(10,2),
    @CodigoBarras VARCHAR(13)
AS
BEGIN
    BEGIN TRY
        -- Intentar insertar
        INSERT INTO Productos_Calidad (ProductoID, Nombre, Precio, CodigoBarras)
        VALUES (@ProductoID, @Nombre, @Precio, @CodigoBarras);
        
        PRINT '✅ Producto insertado correctamente';
    END TRY
    BEGIN CATCH
        -- Capturar el error
        PRINT '❌ Error al insertar producto:';
        PRINT '   Número de error: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT '   Mensaje: ' + ERROR_MESSAGE();
        
        -- Identificar qué constraint se violó
        IF ERROR_NUMBER() = 2627  -- Violación de PRIMARY KEY o UNIQUE
            PRINT '   ➜ Problema: ProductoID o Código de Barras ya existe';
        ELSE IF ERROR_NUMBER() = 547  -- Violación de CHECK o FOREIGN KEY
            PRINT '   ➜ Problema: Precio inválido (debe ser mayor a 0) o FOREIGN KEY fallida';
        ELSE IF ERROR_NUMBER() = 515  -- Violación de NOT NULL
            PRINT '   ➜ Problema: El campo Nombre no puede estar vacío';
        ELSE
            PRINT '   ➜ Problema: Error no identificado';
    END CATCH
END;
GO

-- ============================================
-- 3. PROBAR EL PROCEDIMIENTO
-- ============================================

PRINT '=== CASO 1: INSERTAR PRODUCTO VÁLIDO ===';
EXEC sp_InsertarProducto 1, 'Laptop', 15000, '1234567890123';

PRINT '=== CASO 2: INSERTAR PRODUCTO CON MISMO ID (PRIMARY KEY) ===';
EXEC sp_InsertarProducto 1, 'Mouse', 300, '1234567890999';

PRINT '=== CASO 3: INSERTAR PRODUCTO CON PRECIO NEGATIVO (CHECK) ===';
EXEC sp_InsertarProducto 2, 'Teclado', -500, '9876543210987';

PRINT '=== CASO 4: INSERTAR PRODUCTO CON NOMBRE NULL (NOT NULL) ===';
EXEC sp_InsertarProducto 3, NULL, 800, '5555555555555';

PRINT '=== CASO 5: INSERTAR PRODUCTO CON MISMO CÓDIGO (UNIQUE) ===';
EXEC sp_InsertarProducto 3, 'Teclado', 800, '1234567890123';

-- ============================================
-- 4. VER QUE PRODUCTOS SE INSERTARON
-- ============================================
SELECT * FROM Productos_Calidad;
GO

-- ============================================
-- 5. PROCEDIMIENTO CON TRANSACCIÓN (ROLLBACK EN ERROR)
-- ============================================
CREATE PROCEDURE sp_InsertarProducto_Seguro
    @ProductoID INT,
    @Nombre VARCHAR(50),
    @Precio DECIMAL(10,2),
    @CodigoBarras VARCHAR(13)
AS
BEGIN
    BEGIN TRANSACTION;
    
    BEGIN TRY
        INSERT INTO Productos_Calidad (ProductoID, Nombre, Precio, CodigoBarras)
        VALUES (@ProductoID, @Nombre, @Precio, @CodigoBarras);
        
        COMMIT TRANSACTION;
        PRINT '✅ Producto insertado y transacción confirmada';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT '❌ Error - Transacción deshecha (ROLLBACK)';
        PRINT '   Motivo: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- ============================================
-- 6. PROBAR TRANSACCIÓN
-- ============================================
PRINT '=== PROBANDO TRANSACCIÓN SEGURA ===';
EXEC sp_InsertarProducto_Seguro 10, 'Monitor', 5000, '1111111111111';  -- Válido
EXEC sp_InsertarProducto_Seguro 10, 'Monitor Duplicado', 5000, '2222222222222';  -- ID duplicado falla
GO

-- ============================================
-- 7. TABLA DE AUDITORÍA DE ERRORES
-- ============================================
CREATE TABLE Auditoria_Errores (
    ErrorID INT IDENTITY(1,1) PRIMARY KEY,
    Fecha DATETIME DEFAULT GETDATE(),
    Usuario VARCHAR(100) DEFAULT SYSTEM_USER,
    NumeroError INT,
    MensajeError VARCHAR(500),
    Procedimiento VARCHAR(100)
);
GO

-- ============================================
-- 8. PROCEDIMIENTO CON AUDITORÍA DE ERRORES
-- ============================================
CREATE PROCEDURE sp_InsertarProducto_ConAuditoria
    @ProductoID INT,
    @Nombre VARCHAR(50),
    @Precio DECIMAL(10,2),
    @CodigoBarras VARCHAR(13)
AS
BEGIN
    BEGIN TRY
        INSERT INTO Productos_Calidad (ProductoID, Nombre, Precio, CodigoBarras)
        VALUES (@ProductoID, @Nombre, @Precio, @CodigoBarras);
        PRINT '✅ Insertado correctamente';
    END TRY
    BEGIN CATCH
        -- Guardar error en tabla de auditoría
        INSERT INTO Auditoria_Errores (NumeroError, MensajeError, Procedimiento)
        VALUES (ERROR_NUMBER(), ERROR_MESSAGE(), 'sp_InsertarProducto_ConAuditoria');
        
        PRINT '❌ Error registrado en auditoría';
    END CATCH
END;
GO

-- ============================================
-- 9. PROBAR AUDITORÍA
-- ============================================
EXEC sp_InsertarProducto_ConAuditoria 20, 'Producto Bueno', 100, '9999999999999';  -- Válido
EXEC sp_InsertarProducto_ConAuditoria 20, 'Producto Malo', 100, '9999999999999';    -- ID duplicado

PRINT '=== REGISTROS DE ERRORES ===';
SELECT * FROM Auditoria_Errores;
GO

-- ============================================
-- 10. LIMPIAR
-- ============================================
DROP PROCEDURE sp_InsertarProducto;
DROP PROCEDURE sp_InsertarProducto_Seguro;
DROP PROCEDURE sp_InsertarProducto_ConAuditoria;
DROP TABLE Productos_Calidad;
DROP TABLE Auditoria_Errores;
PRINT '=== LIMPIEZA COMPLETADA ===';