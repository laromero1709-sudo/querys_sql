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