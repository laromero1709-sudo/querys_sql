/* ============================================================
   LABORATORIO SQL SERVER
   INDICES + RENDIMIENTO + EXECUTION PLAN + USUARIOS + PERMISOS

   BASE:
   ETL_Demo

   OBJETIVO:
   1. Analizar una consulta
   2. Crear índices
   3. Medir rendimiento
   4. Analizar Execution Plan
   5. Crear Login
   6. Crear User
   7. Crear Roles
   8. Otorgar permisos
   9. Revocar permisos
   10. Denegar permisos
   ============================================================ */


/* ============================================================
   1. VER ESTRUCTURA ACTUAL
   ============================================================ */

USE ETL_Demo;
GO

SELECT *
FROM Clientes;
GO

SELECT *
FROM AuditoriaClientes;
GO


/* ============================================================
   2. VER INDICES EXISTENTES
   ============================================================ */

SELECT
    t.name AS Tabla,
    i.name AS Indice,
    i.type_desc AS TipoIndice,
    i.is_primary_key AS EsPrimaryKey,
    i.is_unique AS EsUnico
FROM sys.indexes i
INNER JOIN sys.tables t
    ON i.object_id = t.object_id
WHERE t.name IN ('Clientes', 'AuditoriaClientes');
GO


/* ============================================================
   3. MEDIR CONSULTA SIN INDICE
   ============================================================

   Activa estadisticas de IO y TIME.

   Nos interesa observar:
   - logical reads
   - CPU time
   - elapsed time
   ============================================================ */

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT *
FROM Clientes
WHERE Ciudad = 'Toluca';
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO


/* ============================================================
   4. CREAR INDICE EN CIUDAD
   ============================================================

   ¿POR QUE?

   Si buscamos frecuentemente clientes por Ciudad,
   un indice puede ayudar a SQL Server a encontrar
   los registros sin revisar toda la tabla.
   ============================================================ */

CREATE INDEX IX_Clientes_Ciudad
ON Clientes(Ciudad);
GO


/* ============================================================
   5. VOLVER A MEDIR
   ============================================================ */

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT *
FROM Clientes
WHERE Ciudad = 'Toluca';
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO


/* ============================================================
   6. INDICE EN FECHAREGISTRO
   ============================================================ */

CREATE INDEX IX_Clientes_FechaRegistro
ON Clientes(FechaRegistro);
GO


/* ============================================================
   7. CONSULTA QUE PUEDE APROVECHAR FECHAREGISTRO
   ============================================================ */

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT
    ClienteID,
    Nombre,
    Ciudad,
    FechaRegistro
FROM Clientes
WHERE FechaRegistro >= '20260101'
AND FechaRegistro < '20270101';
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO


/* ============================================================
   8. EJEMPLO DE SARGABILITY
   ============================================================

   ESTA FORMA PUEDE DIFICULTAR EL USO DEL INDICE:

       YEAR(FechaRegistro) = 2026

   ============================================================ */

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT *
FROM Clientes
WHERE YEAR(FechaRegistro) = 2026;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO


/* ============================================================
   9. FORMA MAS SARGABLE
   ============================================================ */

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT *
FROM Clientes
WHERE FechaRegistro >= '20260101'
AND FechaRegistro < '20270101';
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO


/* ============================================================
   10. INDICE COMPUESTO
   ============================================================

   Si frecuentemente buscamos:

       Ciudad
       + FechaRegistro

   Podemos crear un indice compuesto.
   ============================================================ */

CREATE INDEX IX_Clientes_Ciudad_Fecha
ON Clientes(Ciudad, FechaRegistro);
GO


/* ============================================================
   11. CONSULTA PARA INDICE COMPUESTO
   ============================================================ */

SELECT
    ClienteID,
    Nombre,
    Ciudad,
    FechaRegistro
FROM Clientes
WHERE Ciudad = 'Toluca'
AND FechaRegistro >= '20260101'
AND FechaRegistro < '20270101';
GO


/* ============================================================
   12. INDEX INCLUDE
   ============================================================

   INCLUDE permite agregar columnas al indice
   que no forman parte de la clave de busqueda.
   ============================================================ */

CREATE INDEX IX_Clientes_Ciudad_Include
ON Clientes(Ciudad)
INCLUDE (Nombre, FechaRegistro);
GO


/* ============================================================
   13. EXECUTION PLAN
   ============================================================

   En SSMS:

   CTRL + M

   Despues ejecuta:

   SELECT *
   FROM Clientes
   WHERE Ciudad = 'Toluca';

   Observa:

   - Index Seek
   - Index Scan
   - Table Scan
   - Key Lookup
   - Cost
   - Estimated Rows
   - Actual Rows

   ============================================================ */

SELECT *
FROM Clientes
WHERE Ciudad = 'Toluca';
GO


/* ============================================================
   14. ACTUAL EXECUTION PLAN POR COMANDO
   ============================================================

   Tambien puedes utilizar:

   SET STATISTICS XML ON

   SSMS generara informacion del plan.
   ============================================================ */

SET STATISTICS XML ON;
GO

SELECT *
FROM Clientes
WHERE Ciudad = 'Toluca';
GO

SET STATISTICS XML OFF;
GO


/* ============================================================
   15. VER TAMANO Y FILAS DE TABLAS
   ============================================================ */

EXEC sp_spaceused 'Clientes';
GO

EXEC sp_spaceused 'AuditoriaClientes';
GO


/* ============================================================
   16. VER INDICES Y FRAGMENTACION
   ============================================================ */

SELECT
    OBJECT_NAME(object_id) AS Tabla,
    index_id,
    avg_fragmentation_in_percent,
    page_count
FROM sys.dm_db_index_physical_stats
(
    DB_ID('ETL_Demo'),
    OBJECT_ID('dbo.Clientes'),
    NULL,
    NULL,
    'LIMITED'
);
GO


/* ============================================================
   17. REORGANIZE
   ============================================================

   Para fragmentacion moderada.

   ============================================================ */

/*
ALTER INDEX IX_Clientes_Ciudad
ON Clientes
REORGANIZE;
GO
*/


/* ============================================================
   18. REBUILD
   ============================================================

   Para fragmentacion mas alta.

   NO ejecutarlo indiscriminadamente en produccion.

   ============================================================ */

/*
ALTER INDEX IX_Clientes_Ciudad
ON Clientes
REBUILD;
GO
*/


/* ============================================================
   19. CREAR LOGIN
   ============================================================

   ESTO SE EJECUTA EN MASTER.

   El LOGIN pertenece al servidor.

   ============================================================ */

USE master;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.server_principals
    WHERE name = 'UsuarioETL'
)
BEGIN

    CREATE LOGIN UsuarioETL
    WITH PASSWORD = 'SqlServer_Practica_2026!';

END;
GO


/* ============================================================
   20. VER LOGIN
   ============================================================ */

SELECT
    name,
    type_desc,
    is_disabled
FROM sys.server_principals
WHERE name = 'UsuarioETL';
GO


/* ============================================================
   21. CREAR USER DENTRO DE ETL_Demo
   ============================================================ */

USE ETL_Demo;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'UsuarioETL'
)
BEGIN

    CREATE USER UsuarioETL
    FOR LOGIN UsuarioETL;

END;
GO


/* ============================================================
   22. VER USER
   ============================================================ */

SELECT
    name,
    type_desc
FROM sys.database_principals
WHERE name = 'UsuarioETL';
GO


/* ============================================================
   23. CREAR ROL PERSONALIZADO
   ============================================================ */

IF NOT EXISTS
(
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'RolConsultaClientes'
)
BEGIN

    CREATE ROLE RolConsultaClientes;

END;
GO


/* ============================================================
   24. DAR PERMISO SELECT SOBRE CLIENTES
   ============================================================ */

GRANT SELECT
ON dbo.Clientes
TO RolConsultaClientes;
GO


/* ============================================================
   25. AGREGAR USUARIO AL ROL
   ============================================================ */

ALTER ROLE RolConsultaClientes
ADD MEMBER UsuarioETL;
GO


/* ============================================================
   26. COMPROBAR PERMISOS
   ============================================================ */

SELECT
    USER_NAME(grantee_principal_id) AS Usuario,
    permission_name,
    state_desc,
    OBJECT_NAME(major_id) AS Objeto
FROM sys.database_permissions
WHERE grantee_principal_id =
      DATABASE_PRINCIPAL_ID('RolConsultaClientes');
GO


/* ============================================================
   27. EJEMPLO DE PERMISO SELECT DIRECTO
   ============================================================ */

GRANT SELECT
ON dbo.AuditoriaClientes
TO UsuarioETL;
GO


/* ============================================================
   28. REVOCAR PERMISO
   ============================================================

   REVOKE elimina el permiso otorgado.

   ============================================================ */

REVOKE SELECT
ON dbo.AuditoriaClientes
FROM UsuarioETL;
GO


/* ============================================================
   29. DENEGAR PERMISO
   ============================================================

   DENY bloquea explicitamente el permiso.

   ============================================================ */

DENY DELETE
ON dbo.Clientes
TO UsuarioETL;
GO


/* ============================================================
   30. DIFERENCIA ENTRE GRANT / REVOKE / DENY
   ============================================================

   GRANT
   -----
   Permite.

   REVOKE
   ------
   Quita un permiso previamente otorgado.

   DENY
   ----
   Niega explicitamente.

   ============================================================ */


/* ============================================================
   31. CREAR ROL DE SOLO LECTURA
   ============================================================ */

IF NOT EXISTS
(
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'RolSoloLectura'
)
BEGIN

    CREATE ROLE RolSoloLectura;

END;
GO

ALTER ROLE db_datareader
ADD MEMBER UsuarioETL;
GO


/* ============================================================
   32. VER ROLES DEL USUARIO
   ============================================================ */

SELECT
    u.name AS Usuario,
    r.name AS Rol
FROM sys.database_role_members drm
INNER JOIN sys.database_principals r
    ON drm.role_principal_id = r.principal_id
INNER JOIN sys.database_principals u
    ON drm.member_principal_id = u.principal_id
WHERE u.name = 'UsuarioETL';
GO


/* ============================================================
   33. BUENA PRACTICA:
       NO DAR db_owner SIN NECESIDAD
   ============================================================

   EVITAR:

       ALTER ROLE db_owner
       ADD MEMBER UsuarioETL;

   Porque db_owner tiene control total sobre la base.

   Mejor:

       GRANT SELECT
       GRANT EXECUTE
       GRANT INSERT
       GRANT UPDATE

   solamente cuando realmente sea necesario.
   ============================================================ */


/* ============================================================
   34. CREAR PROCEDIMIENTO PARA CONSULTA
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.VerClientesToluca
AS
BEGIN

    SELECT
        ClienteID,
        Nombre,
        Ciudad,
        FechaRegistro
    FROM dbo.Clientes
    WHERE Ciudad = 'Toluca';

END;
GO


/* ============================================================
   35. DAR EXECUTE AL USUARIO
   ============================================================ */

GRANT EXECUTE
ON dbo.VerClientesToluca
TO UsuarioETL;
GO


/* ============================================================
   36. CONSULTAR EL PROCEDIMIENTO
   ============================================================ */

EXEC dbo.VerClientesToluca;
GO


/* ============================================================
   37. RESUMEN FINAL
   ============================================================

   RENDIMIENTO
   -----------
   SET STATISTICS IO ON
   SET STATISTICS TIME ON

   EXECUTION PLAN
   --------------
   CTRL + M

   INDICES
   -------
   CREATE INDEX
   INCLUDE
   REORGANIZE
   REBUILD

   SARGABILITY
   -----------
   Evitar funciones sobre columnas indexadas
   cuando sea posible.

   SEGURIDAD
   ---------
   LOGIN
   USER
   ROLE

   PERMISOS
   --------
   GRANT
   REVOKE
   DENY

   BUENA PRACTICA
   --------------
   Principio de minimo privilegio.

   Dar al usuario solamente los permisos
   que realmente necesita.

   ============================================================ */