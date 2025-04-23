--Crear StoredProcedure que muestre el top X de productos más vendidos por categoría.
CREATE PROC S_SoldestProdByCategory (@amount INT) AS 
BEGIN
	IF @amount < 1
		BEGIN
			PRINT 'Number must be greater than 0';
			RETURN;
		END;
	WITH
		prdSold AS --Query con la cantidad de productos vendidos
			(SELECT ordI.productId, SUM(ordI.quantity) AS Sold
			FROM OrderItem ordI
			GROUP BY ordI.productId),
		prdCat AS --Query con la cantidad de productos vendidos, ademas de la categoria de cada uno
			(SELECT ca.categoryName, pr.productName, COALESCE(ps.Sold, 0) AS solds
			FROM Product pr
			LEFT JOIN prdSold ps ON ps.productId = pr.productId
			LEFT JOIN Category ca ON ca.categoryId = pr.categoryId),
		soldRank AS --Query con los ranks por ventas de cada productto por categoria
			(SELECT categoryName, productName, solds,
			ROW_NUMBER() OVER (PARTITION BY categoryName ORDER BY solds DESC) AS CatRank
			FROM prdCat)
	--Query final donde los rank son filtrados de acuerdo a la ingresado por el user
	SELECT categoryName, productName, solds 
	FROM soldRank 
	WHERE CatRank BETWEEN 1 AND @amount;
END;

EXEC S_SoldestProdByCategory 1;
EXEC S_SoldestProdByCategory 3;
EXEC S_SoldestProdByCategory 0;

--Cada vez que se agregue un nuevo cliente, guarda un log con el id, nombre, email y fecha de creación.
	--Tabla para almacenar los logs
CREATE TABLE CustomerRegistry(
		regId INT PRIMARY KEY IDENTITY(1, 1),
		patId INT UNIQUE,
		fullName VARCHAR(128) NOT NULL,
		email VARCHAR(128) NOT NULL,
		registeredAt DATETIME NOT NULL);
GO
	--Trigger para la tabla
CREATE TRIGGER Customer_AI
	ON Customer AFTER INSERT AS
	BEGIN
		INSERT INTO CustomerRegistry (patId, fullName, email, registeredAt)
			SELECT customerId, CONCAT_WS(' ', firstName, lastName) AS FName, email, GETDATE()
			FROM inserted;
	END;
	--Insercciones de prueba
INSERT INTO Customer VALUES
	('Michael', 'Scott', '(999)547-8754', 'miche.scott@gmail.com', '9696 Dunder St.', 'Scranton', 'Pennsylvania', '16969'),
	('Kyle', 'Broflovski', NULL, 'kyle.brof@gmail.com', NULL, 'South Park', 'Colorado', '00000'),
	('Eric', 'Cartman', NULL, 'suck.dicks@yahoo.com', NULL, 'South Park', 'Colorado', '00000');
    
	--Resultado de las tablas
SELECT * FROM Customer;
SELECT * FROM CustomerRegistry;

--Crear un trigger que impida eliminar empleados que tienen órdenes activas, y registre el intento en una tabla.
CREATE TABLE StaffDelAttempts(
		attId INT PRIMARY KEY IDENTITY(1, 1),
		staffId INT UNIQUE,
		triedAt DATETIME NOT NULL);
GO

CREATE TRIGGER Staff_AD
	ON Staff AFTER DELETE AS
	BEGIN	
		IF (SELECT COUNT(*) FROM deleted) = 1
			BEGIN
				DECLARE @staffDel INT = (SELECT TOP 1 staffId FROM deleted); --Obtener id de empleado eliminado
				PRINT 'Employee with ID ' + CAST(@staffDel AS VARCHAR) + ' cant be deleted, because he/she has active orders';
				ROLLBACK TRAN;
				INSERT INTO StaffDelAttempts VALUES 
					(@staffDel, GETDATE());
			END;
	END;

	--Debe lanzar mensaje ya que el empleado tiene ordenes pendientes
DELETE Staff WHERE staffId = 3;
	--Debe borrarlo ya que el empleado no tiene ordenes pendientes
DELETE Staff WHERE staffId = 5;

SELECT * FROM Staff;
SELECT * FROM StaffDelAttempts;

--Si la cantidad de stock baja por debajo de 5, inserta una alerta en una tabla LowStockAlerts.
CREATE TABLE LowStockAlerts(
		alertId INT PRIMARY KEY IDENTITY(1, 1),
		producId INT UNIQUE,
		currentStock INT NOT NULL);
GO

CREATE TRIGGER Stock_AU
	ON Stock AFTER UPDATE AS
	BEGIN	
		
		DECLARE @productId INT;
		DECLARE @stock INT;
		
		DECLARE stockUpdated CURSOR FOR SELECT productId, quantity FROM inserted;
	
		OPEN stockUpdated;
		FETCH NEXT FROM stockUpdated
		INTO @productId, @stock;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @stock < 5
				BEGIN
					INSERT INTO LowStockAlerts 
						VALUES (@productId, @stock);
				END;
			
			FETCH NEXT FROM stockUpdated
			INTO @productId, @stock;
		END;

		CLOSE stockUpdated;
		DEALLOCATE stockUpdated;
	END;

	--Insertara en tabla LowStockAlerts, ya que el stock sera menor a 5
UPDATE Stock SET quantity = quantity-4 WHERE productId = 7 AND storeId = 1;
	--No insertara en tabla LowStockAlerts, ya que el stock no sera menor a 5
UPDATE Stock SET quantity = quantity-2 WHERE productId = 5 AND storeId = 1;

SELECT * FROM Stock;
SELECT * FROM LowStockAlerts;