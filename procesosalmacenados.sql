---- CTE
WITH DATOS  AS (
Select * from Clientes
)

Select * from DATOS

---- CTE 


---- delete view
drop view [dbo].[uvclientes34]
drop view [dbo].[vu_clientes9]
----- delete  view

---- vista nueva 
CREATE VIEW uv_clientes_demo
as 
Select * from uv_clientes_demo
----- vista nueva


---- drop store
drop procedure  [dbo].[ciudad]
drop procedure [dbo].[ciudadfecha]
drop procedure [dbo].[verdata]
---- drop store


------ Primer store procedure 
CREATE PROCEDURE  verdatos
as
BEGIN
SELECT ClienteID,Nombre,Ciudad,FechaRegistro FROM  Clientes
END;

EXEC verdatos;
------ Primer store procedure 


------ SEGUNDO STORE PROCEDURE 
--@
CREATE PROCEDURE ciudadm
@ciudad varchar(75)
as
begin 
SELECT ClienteID,Nombre,Ciudad,FechaRegistro FROM  Clientes
where Ciudad=@ciudad;
end;

exec ciudadm
@ciudad='Toluca'
------- SEGUNDO STORE PROCEDURE 

--------------- TERCER PROCEDURE
CREATE PROCEDURE ciudadfecha
@ciudad varchar(75),@fecha date 
as
begin
SELECT ClienteID,Nombre,Ciudad,FechaRegistro FROM  Clientes
where Ciudad=@ciudad and FechaRegistro=@fecha;
end;

exec ciudadfecha
@ciudad='Toluca',@fecha='2024-04-05'

--------------- TERCER PROCEDURE

--- drop trigger
drop trigger [trg_Clientes_Insert]
drop trigger [trg_Clientes_update]
drop trigger [trg_Clientes_delete]
-- drop trigger 


---- trigger insert
CREATE TRIGGER trg_Clientes_Insert
on clientes 
AFTER INSERT
AS
BEGIN
INSERT INTO AuditoriaClientes(
ClienteID,Nombre,Ciudad,Operacion
)
SELECT ClienteID,Nombre,Ciudad,'INSERT' FROM inserted
END;

--- trigger insert

--- trigger update

CREATE TRIGGER trg_Clientes_Update
on clientes 
AFTER UPDATE
AS
BEGIN
INSERT INTO AuditoriaClientes(
ClienteID,Nombre,Ciudad,Operacion
)
SELECT ClienteID,Nombre,Ciudad,'UPDATE' FROM inserted
END;

--- trigger update

--- trigger delete
CREATE TRIGGER trg_Clientes_Delete
on clientes 
AFTER DELETE
AS
BEGIN
INSERT INTO AuditoriaClientes(
ClienteID,Nombre,Ciudad,Operacion
)
SELECT ClienteID,Nombre,Ciudad,'DELETE' FROM deleted
END;
--- trigger delete




------------------ ejemplos 

-- ==========================================
-- INSERT - Probar Trigger INSERT
-- ==========================================

INSERT INTO Clientes
(
    Nombre,
    Ciudad,
    FechaRegistro
)
VALUES
(
    'Ana Torres',
    'Guadalajara',
    GETDATE()
);


-- Validar INSERT
SELECT *
FROM Clientes
WHERE ClienteID = 18;



-- ==========================================
-- UPDATE - Probar Trigger UPDATE
-- ==========================================

UPDATE Clientes
SET 
    Nombre = 'Ana Torres Ramirez',
    Ciudad = 'Monterrey'
WHERE ClienteID = 20;


-- Validar UPDATE
SELECT *
FROM Clientes
WHERE ClienteID = 18;



-- ==========================================
-- DELETE - Probar Trigger DELETE
-- ==========================================

DELETE FROM Clientes
WHERE ClienteID = 20;


---- Validar DELETE
--SELECT *
--FROM Clientes
--WHERE ClienteID = 20;

Select * from [dbo].[AuditoriaClientes]


--------------------PIVOT

SELECT * FROM (
select producto,total  from ventas 
) as data
PIVOT
(
SUM(TOTAL)
FOR PRODUCTO IN
(
[Laptop],
[LOG Prueba],
[Monitor],
[Mouse],
[Teclado]
)
) AS PIVOTABLE;