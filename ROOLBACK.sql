USE ETL_Demo;
GO

/* =========================================================
   BUENA PRACTICA PARA UN DELETE CRITICO
   ========================================================= */

/* 1. PRIMERO: comprobar qué vamos a eliminar */

SELECT *
FROM Clientes
WHERE ClienteID = 30;


/* 2. INICIAR TRANSACCION */

BEGIN TRANSACTION;


/* 3. EJECUTAR EL DELETE */

DELETE FROM Clientes
WHERE ClienteID = 30;


/* 4. COMPROBAR CUANTOS REGISTROS AFECTAMOS */

SELECT @@ROWCOUNT AS RegistrosEliminados;


/* 5. VERIFICAR EL RESULTADO */

SELECT *
FROM Clientes
WHERE ClienteID = 30;


/* 6. REVISAR LA AUDITORIA DEL TRIGGER */

SELECT *
FROM AuditoriaClientes
WHERE ClienteID = 30;


/* =========================================================
   SI DESCUBRES QUE FUE UN ERROR:
   EJECUTAS ROLLBACK
   ========================================================= */

/*
ROLLBACK;

SELECT *
FROM Clientes
WHERE ClienteID = 30;

SELECT *
FROM AuditoriaClientes
WHERE ClienteID = 30;
*/


/* =========================================================
   SI TODO ESTÁ CORRECTO:
   EJECUTAS COMMIT
   ========================================================= */

/*
COMMIT;
*/