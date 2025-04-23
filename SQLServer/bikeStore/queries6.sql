--Crear un procedimiento que actualice el email de un empleado, validando que el nuevo email no exista.
CREATE PROC U_StaffEmail (@EmplID INT, @newEmail VARCHAR(128)) AS 
BEGIN
	BEGIN TRAN;
	BEGIN TRY 
		UPDATE Staff SET email = @newEmail
			WHERE staffId = @EmplID;
		PRINT CAST(@EmplID AS VARCHAR) + ' has updated his email (' + @newEmail + ')';
		COMMIT TRAN;
	END TRY
	BEGIN CATCH
		--Violaciones de campos unicos
		IF ERROR_NUMBER() = 2627 OR ERROR_NUMBER() = 2601
			PRINT @newEmail + ' already exists';
		ELSE 
			PRINT 'There was an error, operation canceled';
		ROLLBACK TRAN;
	END CATCH
END;
GO

--Error debido a que ya existe
EXEC U_StaffEmail 2, 'fabiola.jackson@bikes.shop';
--Ejecucion correcta
EXEC U_StaffEmail 2, 'mire.copeland@bikes.shop';

--Crear un procedimiento que inserte un nuevo producto validando existencia de categoría y marca.
CREATE PROC I_Product (
	@prodName VARCHAR(128), @brand VARCHAR(128), @category VARCHAR(128), @modelYear INT, @price DECIMAL(10, 2)) 
AS BEGIN
	DECLARE @catId INT = (SELECT categoryId FROM Category WHERE categoryName = @category);
	DECLARE @brId INT = (SELECT brandId FROM Brand WHERE brandName = @brand);
	IF (@catId IS NULL)
		BEGIN
			PRINT @category + ' category doesnt exist, operation canceled';
			RETURN;
		END;
	IF (@brId IS NULL)
		BEGIN
			PRINT @brand + ' brand doesnt exist, operation canceled';
			RETURN;
		END;
	BEGIN TRAN;
	BEGIN TRY 
		INSERT INTO Product
			VALUES (@prodName, @brId, @catId, @modelYear, @price);
		COMMIT TRAN;
	END TRY
	BEGIN CATCH
		PRINT 'There was an error, operation canceled (' + ERROR_MESSAGE() + ')';
		ROLLBACK TRAN;
	END CATCH
END;
GO

--Ejecucion correcta
EXEC I_Product 'Trek Bitch 420', 'Heller', 'Mountain Bikes', 2019, 1299.99;
--Error por marca
EXEC I_Product 'T-Rex Hyper Market', 'Roger', 'Mountain Bikes', 2016, 499.99;
--Error por categoria
EXEC I_Product 'T-Rex Hyper Market Female', 'Electra', 'Beach Bikes', 2012, 199.99;

--Crea un procedimiento que reciba una orden y actualice el stock de cada producto, verificando el stock disponible
-- y en caso de no haberlo cancelar toda la transaccion.
CREATE PROC U_ProductStockOrderCompleted (@orderId INT) AS 
BEGIN
	IF NOT EXISTS (SELECT orderId FROM Ordeer WHERE orderId = @orderId)
		BEGIN
			PRINT 'Order Id (' + CAST(@orderId AS VARCHAR) + ') doesnt exist';
			RETURN;
		END;

	DECLARE @productId INT;
	DECLARE @requested INT;
	DECLARE @stock INT;
	DECLARE @stId INT;
	
	DECLARE prodQuants CURSOR FOR SELECT ordI.productId, ordI.quantity AS Requested, sub.Total AS Stock  
									FROM OrderItem ordI 
									INNER JOIN (SELECT productId, SUM(quantity) AS Total 
												FROM Stock GROUP BY productId) sub 
										ON sub.productId = ordI.productId
									WHERE ordI.orderId = @orderId;
	
	OPEN prodQuants;
	FETCH NEXT FROM prodQuants
	INTO @productId, @requested, @stock;

	BEGIN TRAN;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @stock - @requested < 0
			BEGIN
				PRINT 'Product Id (' + CAST(@productId AS VARCHAR) + ') doesnt have enough stock, order Id (' 
						+ CAST(@orderId AS VARCHAR) + ') needs to be checked';
				ROLLBACK TRAN;
				CLOSE prodQuants;
				DEALLOCATE prodQuants;
				RETURN;
			END;

		SET @stId = (SELECT TOP(1) storeId FROM Stock WHERE productId = @productId ORDER BY quantity DESC)

		UPDATE TOP(1) Stock SET quantity = quantity - @requested
		WHERE productId = @productId AND storeId = @stId;

		FETCH NEXT FROM prodQuants
		INTO @productId, @requested, @stock;
	END;

	COMMIT TRAN;
	CLOSE prodQuants;
	DEALLOCATE prodQuants;
END;
GO

EXEC U_ProductStockOrderCompleted 1;
EXEC U_ProductStockOrderCompleted 124;

--Crear un procedimiento que devuelva estadísticas de ventas por empleado (productos, total en dinero, ordenes).
CREATE PROC S_STORESTATS AS 
BEGIN
	WITH --Cada consulta estara separada con el fin de hacer la consulta "modular"
		available AS 
			(SELECT sto.storeId, COALESCE(SUM(stk.quantity), 0) AS Available
			FROM Store sto LEFT JOIN Stock stk ON stk.storeId = sto.storeId
			GROUP BY sto.storeId),
		sold AS 
			(SELECT sto.storeId, COALESCE(SUM(orI.quantity), 0) AS Sold
			FROM Store sto
			LEFT JOIN Stock stk ON stk.storeId = sto.storeId
			LEFT JOIN OrderItem orI ON orI.productId = stk.productId
			GROUP BY sto.storeId),
		orders AS
			(SELECT sto.storeId, COUNT(ord.orderId) AS TotalOrders
			FROM Store sto LEFT JOIN Ordeer ord ON ord.storeId = sto.storeId
			GROUP BY sto.storeId),
		ordersRev AS 
			(SELECT sto.storeId, SUM(dbo.ORDERTOTAL(ord.orderId)) AS TotalMoney
			FROM Ordeer ord RIGHT JOIN Store sto ON sto.storeId = ord.storeId
			GROUP BY sto.storeId)
	SELECT sto.storeName, av.Available, sl.Sold, ord.TotalOrders, ordR.TotalMoney
	FROM Store sto
	LEFT JOIN available av ON av.storeId = sto.storeId
	LEFT JOIN sold sl ON sl.storeId = sto.storeId
	LEFT JOIN orders ord ON ord.storeId = sto.storeId
	LEFT JOIN ordersRev ordR ON ordR.storeId = sto.storeId;
END;
GO

EXEC S_STORESTATS;