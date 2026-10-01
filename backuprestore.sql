/* ============================================================
   LABORATORIO: BACKUP / RESTORE - ETL_Demo
   ============================================================

   TEMAS:
   1. FULL BACKUP
   2. RESTORE VERIFYONLY
   3. RESTORE FILELISTONLY
   4. RESTORE + WITH MOVE
   5. DIFFERENTIAL BACKUP
   6. LOG BACKUP
   7. SIMULACION DE INCIDENTE
   8. RESTORE DE LA BASE
   9. COMPARACION ORIGINAL VS RECOVERY

   IMPORTANTE:
   - Ejecutar sobre ETL_Demo.
   - NO elimina ETL_Demo.
   - Cambia la ruta C:\SQLBackups\ si es necesario.
   ============================================================ */


/* ============================================================
   0. PREPARACION
   ============================================================ */

USE master;
GO

ALTER DATABASE ETL_Demo
SET RECOVERY FULL;
GO

SELECT
    name,
    recovery_model_desc
FROM sys.databases
WHERE name = 'ETL_Demo';
GO


/* ============================================================
   1. FULL BACKUP
   ============================================================

   ¿CUANDO SE USA?

   Es la copia completa de la base.
   Normalmente es el punto de partida de una estrategia
   de recuperacion.

   Resultado esperado:

   ETL_Demo
       ↓
   FULL BACKUP
       ↓
   ETL_Demo_FULL.bak
   ============================================================ */

BACKUP DATABASE ETL_Demo
TO DISK = 'C:\SQLBackups\ETL_Demo_FULL.bak'
WITH
    INIT,
    FORMAT,
    COMPRESSION,
    STATS = 10;
GO


/* ============================================================
   2. RESTORE VERIFYONLY
   ============================================================

   ¿PARA QUE SIRVE?

   NO restaura la base.

   Comprueba que SQL Server pueda leer el backup y que
   el conjunto de backup sea valido.

   No modifica ETL_Demo.
   ============================================================ */

RESTORE VERIFYONLY
FROM DISK = 'C:\SQLBackups\ETL_Demo_FULL.bak';
GO


/* ============================================================
   3. RESTORE FILELISTONLY
   ============================================================

   ¿PARA QUE SIRVE?

   Muestra los archivos que contiene el backup.

   Aqui debemos observar principalmente:

   LogicalName
   PhysicalName
   Type

   Los LogicalName los necesitaremos posteriormente
   para utilizar WITH MOVE.
   ============================================================ */

RESTORE FILELISTONLY
FROM DISK = 'C:\SQLBackups\ETL_Demo_FULL.bak';
GO


/* ============================================================
   4. CREAR BASE DE RECUPERACION
   ============================================================

   No vamos a destruir ETL_Demo.

   Vamos a restaurar el backup como:

   ETL_Demo_Recovery
   ============================================================ */

USE master;
GO

IF DB_ID('ETL_Demo_Recovery') IS NOT NULL
BEGIN
    ALTER DATABASE ETL_Demo_Recovery
    SET SINGLE_USER
    WITH ROLLBACK IMMEDIATE;

    DROP DATABASE ETL_Demo_Recovery;
END;
GO


/* ============================================================
   5. RESTORE + WITH MOVE
   ============================================================

   IMPORTANTE:

   Primero ejecuta RESTORE FILELISTONLY de arriba.

   Supongamos que los LogicalName son:

       ETL_Demo
       ETL_Demo_log

   Si SQL Server te devuelve otros nombres,
   CAMBIALOS en los MOVE.

   WITH MOVE permite restaurar los archivos fisicos
   en una nueva ubicacion/nombre.

   Aqui estamos creando:

       ETL_Demo_Recovery
   ============================================================ */

RESTORE DATABASE ETL_Demo_Recovery
FROM DISK = 'C:\SQLBackups\ETL_Demo_FULL.bak'
WITH
    MOVE 'ETL_Demo'
        TO 'C:\SQLBackups\ETL_Demo_Recovery.mdf',

    MOVE 'ETL_Demo_log'
        TO 'C:\SQLBackups\ETL_Demo_Recovery_log.ldf',

    RECOVERY,
    STATS = 10;
GO


/* ============================================================
   6. COMPROBAR RESTORE
   ============================================================ */

SELECT *
FROM ETL_Demo_Recovery.dbo.Clientes;
GO

SELECT *
FROM ETL_Demo_Recovery.dbo.AuditoriaClientes;
GO


/* ============================================================
   7. DIFFERENTIAL BACKUP
   ============================================================

   ¿CUANDO SE USA?

   Guarda los cambios realizados desde el ultimo FULL.

   Ejemplo:

       FULL
        ↓
       cambios
        ↓
       DIFFERENTIAL

   El siguiente diferencial tambien parte del ultimo FULL.

   No necesitas restaurar todos los diferenciales.
   Normalmente utilizas:

       FULL
       +
       ultimo DIFFERENTIAL
   ============================================================ */


/* Hacemos un cambio para generar informacion nueva */

USE ETL_Demo;
GO

INSERT INTO Clientes
(
    Nombre,
    Ciudad,
    FechaRegistro
)
VALUES
(
    'Cliente Diferencial',
    'Toluca',
    GETDATE()
);
GO


/* Comprobamos */

SELECT *
FROM Clientes
WHERE Nombre = 'Cliente Diferencial';
GO


/* Creamos diferencial */

BACKUP DATABASE ETL_Demo
TO DISK = 'C:\SQLBackups\ETL_Demo_DIFF.bak'
WITH
    DIFFERENTIAL,
    INIT,
    COMPRESSION,
    STATS = 10;
GO


/* ============================================================
   8. LOG BACKUP
   ============================================================

   ¿CUANDO SE USA?

   Se utiliza con una base en FULL o BULK_LOGGED recovery.

   Permite respaldar el transaction log y construir una
   estrategia de recuperacion mas precisa.

   Ejemplo:

       FULL
        ↓
       cambios
        ↓
       LOG BACKUP
        ↓
       mas cambios
        ↓
       LOG BACKUP
   ============================================================ */


/* Hacemos un cambio */

UPDATE Clientes
SET Ciudad = 'CDMX'
WHERE ClienteID = 30;
GO


/* Creamos LOG BACKUP */

BACKUP LOG ETL_Demo
TO DISK = 'C:\SQLBackups\ETL_Demo_LOG_01.trn'
WITH
    INIT,
    COMPRESSION,
    STATS = 10;
GO


/* ============================================================
   9. OTRO CAMBIO
   ============================================================ */

UPDATE Clientes
SET Ciudad = 'Puebla'
WHERE ClienteID = 30;
GO


/* Segundo LOG BACKUP */

BACKUP LOG ETL_Demo
TO DISK = 'C:\SQLBackups\ETL_Demo_LOG_02.trn'
WITH
    INIT,
    COMPRESSION,
    STATS = 10;
GO


/* ============================================================
   10. SIMULAR INCIDENTE
   ============================================================

   IMPORTANTE:

   Este DELETE se ejecuta SIN BEGIN TRANSACTION.

   Por autocommit, la sentencia queda confirmada.

   Por eso un ROLLBACK posterior NO podra recuperar
   el registro.

   Vamos a eliminar ClienteID = 30.

   Primero comprobamos que existe.
   ============================================================ */

SELECT *
FROM Clientes
WHERE ClienteID = 30;
GO


/* DELETE CONFIRMADO */

DELETE FROM Clientes
WHERE ClienteID = 30;
GO


/* Comprobar que desaparecio */

SELECT *
FROM Clientes
WHERE ClienteID = 30;
GO


/* ============================================================
   11. INTENTAR ROLLBACK
   ============================================================

   Esto NO se ejecuta como solucion.

   Si ejecutaras:

       ROLLBACK;

   SQL Server no podria recuperar el cliente porque
   el DELETE ya termino y fue confirmado.

   ROLLBACK sirve para una transaccion que sigue abierta.

   RESTORE sirve para recuperar informacion desde un backup.

   ============================================================ */


/*
ROLLBACK;
*/


/* ============================================================
   12. COMPROBAR QUE ETL_Demo NO TIENE EL CLIENTE
   ============================================================ */

SELECT *
FROM ETL_Demo.dbo.Clientes
WHERE ClienteID = 30;
GO


/* ============================================================
   13. COMPROBAR QUE EL CLIENTE EXISTE EN EL BACKUP
   ============================================================

   La base restaurada antes del DELETE debe conservar
   el cliente 30.

   ============================================================ */

SELECT *
FROM ETL_Demo_Recovery.dbo.Clientes
WHERE ClienteID = 30;
GO


/* ============================================================
   14. RECUPERAR EL REGISTRO

   Aqui hacemos INSERT SELECT desde la base restaurada
   hacia la base original.

   IMPORTANTE:

   Como ClienteID es IDENTITY, para poder conservar
   exactamente el ClienteID = 30 utilizamos IDENTITY_INSERT.

   ============================================================ */

USE ETL_Demo;
GO

SET IDENTITY_INSERT Clientes ON;
GO

INSERT INTO Clientes
(
    ClienteID,
    Nombre,
    Ciudad,
    FechaRegistro
)
SELECT
    ClienteID,
    Nombre,
    Ciudad,
    FechaRegistro
FROM ETL_Demo_Recovery.dbo.Clientes
WHERE ClienteID = 30
AND NOT EXISTS
(
    SELECT 1
    FROM ETL_Demo.dbo.Clientes
    WHERE ClienteID = 30
);
GO

SET IDENTITY_INSERT Clientes OFF;
GO


/* ============================================================
   15. COMPROBAR RECUPERACION
   ============================================================ */

SELECT *
FROM ETL_Demo.dbo.Clientes
WHERE ClienteID = 30;
GO


/* ============================================================
   16. COMPROBAR AUDITORIA
   ============================================================

   OJO:

   Al insertar nuevamente el cliente recuperado,
   el trigger INSERT puede generar una nueva auditoria.

   Esto es diferente de recuperar historicamente
   la auditoria original.

   ============================================================ */

SELECT *
FROM ETL_Demo.dbo.AuditoriaClientes
WHERE ClienteID = 30
ORDER BY AuditoriaID;
GO


/* ============================================================
   17. COMPARAR ORIGINAL VS RECOVERY
   ============================================================ */

SELECT
    'ETL_Demo' AS BaseDatos,
    ClienteID,
    Nombre,
    Ciudad,
    FechaRegistro
FROM ETL_Demo.dbo.Clientes
WHERE ClienteID = 30

UNION ALL

SELECT
    'ETL_Demo_Recovery' AS BaseDatos,
    ClienteID,
    Nombre,
    Ciudad,
    FechaRegistro
FROM ETL_Demo_Recovery.dbo.Clientes
WHERE ClienteID = 30;
GO


/* ============================================================
   18. VER ARCHIVOS CREADOS
   ============================================================ */

SELECT
    name AS BaseDatos,
    physical_name,
    type_desc
FROM sys.master_files
WHERE database_id IN
(
    DB_ID('ETL_Demo'),
    DB_ID('ETL_Demo_Recovery')
);
GO


/* ============================================================
   19. RESUMEN CONCEPTUAL
   ============================================================

   FULL BACKUP
   ------------
   Copia completa de la base.

   DIFFERENTIAL BACKUP
   -------------------
   Cambios desde el ultimo FULL.

   LOG BACKUP
   ----------
   Cambios registrados en el transaction log.

   RESTORE
   -------
   Recupera una base desde un backup.

   RESTORE VERIFYONLY
   ------------------
   Comprueba que el backup sea valido/legible.
   NO restaura.

   RESTORE FILELISTONLY
   -------------------
   Muestra los archivos contenidos en el backup.

   WITH MOVE
   ---------
   Permite restaurar los archivos en otra ubicacion/nombre.

   ROLLBACK
   --------
   Deshace una transaccion que aun no ha sido confirmada.

   ============================================================ */


/* ============================================================
   20. CONSULTA FINAL
   ============================================================ */

SELECT
    'FULL BACKUP' AS Concepto,
    'Copia completa de la base' AS Descripcion

UNION ALL

SELECT
    'DIFFERENTIAL BACKUP',
    'Cambios desde el ultimo FULL'

UNION ALL

SELECT
    'LOG BACKUP',
    'Respaldo del transaction log'

UNION ALL

SELECT
    'RESTORE',
    'Recuperar una base desde un backup'

UNION ALL

SELECT
    'RESTORE VERIFYONLY',
    'Validar un backup sin restaurarlo'

UNION ALL

SELECT
    'RESTORE FILELISTONLY',
    'Ver archivos incluidos en el backup'

UNION ALL

SELECT
    'WITH MOVE',
    'Cambiar ubicacion de archivos durante RESTORE';
GO