-- Crear la base de datos llamada MyDatabase
CREATE DATABASE MyDatabase;
GO

-- Seleccionar y usar la base de datos recién creada
USE MyDatabase;
GO

-- Crear la tabla Employees con las siguientes columnas:
-- EmployeeID: Identificador único y clave primaria (auto-incremental)
-- Name: Nombre del empleado (cadena de texto, no permite valores nulos)
-- Position: Cargo del empleado (cadena de texto, no permite valores nulos)
-- Salary: Salario del empleado (número decimal, no permite valores nulos)
CREATE TABLE Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL,
    Position NVARCHAR(50) NOT NULL,
    Salary DECIMAL(10, 2) NOT NULL
);
GO

-- Insertar registros de ejemplo en la tabla Employees
-- Estos registros simulan empleados con diferentes cargos y salarios
INSERT INTO Employees (Name, Position, Salary)
VALUES 
('John Doe', 'Manager', 75000.00),
('Jane Smith', 'Manager', 80000.00),
('Alice Brown', 'Developer', 60000.00),
('Bob White', 'Tester', 45000.00),
('Charlie Green', 'Developer', 62000.00),
('Eve Black', 'Manager', 85000.00);
GO

-- Consultar todos los datos de la tabla Employees para verificar los registros iniciales
SELECT * FROM Employees;
GO

-- Crear una copia de seguridad completa de la base de datos MyDatabase
-- El archivo se guarda en la ruta especificada (asegúrate de que la carpeta exista)
BACKUP DATABASE MyDatabase
TO DISK = 'C:\Backups\MyDatabase.bak'
WITH FORMAT, MEDIANAME = 'SQLServerBackups', NAME = 'Full Backup of MyDatabase';
GO

-- Consultar los registros de empleados con el cargo 'Manager' antes de realizar la actualización
SELECT EmployeeID, Name, Position, Salary
FROM Employees
WHERE Position = 'Manager';
GO

-- Crear una tabla temporal para almacenar los valores antes de la actualización
CREATE TABLE #BeforeUpdate (
    EmployeeID INT,
    Name NVARCHAR(50),
    Position NVARCHAR(50),
    Salary DECIMAL(10, 2)
);
GO

-- Insertar los registros actuales (antes de la actualización) en la tabla temporal
INSERT INTO #BeforeUpdate (EmployeeID, Name, Position, Salary)
SELECT EmployeeID, Name, Position, Salary
FROM Employees
WHERE Position = 'Manager';
GO

-- Incrementar en un 10% el salario de todos los empleados con el cargo 'Manager'
UPDATE Employees
SET Salary = Salary * 1.10
WHERE Position = 'Manager';
GO

-- Mostrar los valores antes y después de la actualización en una consulta unificada
SELECT 
    b.EmployeeID AS EmployeeID_Before,
    b.Name AS Name_Before,
    b.Position AS Position_Before,
    b.Salary AS Salary_Before,
    e.EmployeeID AS EmployeeID_After,
    e.Name AS Name_After,
    e.Position AS Position_After,
    e.Salary AS Salary_After
FROM #BeforeUpdate b
JOIN Employees e ON b.EmployeeID = e.EmployeeID
WHERE b.Position = 'Manager';
GO

-- Eliminar la tabla temporal después de usarla
DROP TABLE #BeforeUpdate;
GO

-- Restaurar la base de datos desde la copia de seguridad para devolverla a su estado original
-- Cambiar la base de datos a modo de usuario único y cerrar conexiones activas
USE master;
GO
ALTER DATABASE MyDatabase SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

-- Restaurar la base de datos usando el archivo de respaldo creado anteriormente
RESTORE DATABASE MyDatabase
FROM DISK = 'C:\Backups\MyDatabase.bak'
WITH REPLACE;
GO

-- Cambiar la base de datos nuevamente a modo multiusuario
ALTER DATABASE MyDatabase SET MULTI_USER;
GO

-- Consultar los datos para confirmar que la restauración devolvió la base de datos a su estado original
SELECT EmployeeID, Name, Position, Salary
FROM Employees
WHERE Position = 'Manager';
GO
