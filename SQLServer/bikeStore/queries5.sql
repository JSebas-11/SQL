--Crear una función que devuelva el total de una orden (orderId) y consultarlo para todas las órdenes.
CREATE FUNCTION ORDERTOTAL(@ID INT)
	RETURNS DECIMAL(10, 2) AS
	BEGIN
		RETURN (SELECT SUM((ordI.quantity*ordI.price)) AS Total
				FROM Ordeer ord
				LEFT JOIN OrderItem ordI ON ordI.orderId = ord.	orderId
				GROUP BY ord.orderId HAVING ord.orderId = @ID);
	END;
GO

SELECT *, dbo.ORDERTOTAL(orderId) AS Total
FROM Ordeer;

--Crear una función que concatene el nombre del producto con su categoría y marca, y consultarlo.
CREATE FUNCTION PRODPATH(@ID INT)
	RETURNS VARCHAR(128) AS
	BEGIN
		RETURN (SELECT CONCAT_WS('/', ca.categoryName, br.brandName, pr.productName) AS Concaten
				FROM Product pr
				LEFT JOIN Category ca ON ca.categoryId = pr.categoryId
				LEFT JOIN Brand br ON br.brandId = pr.brandId
				WHERE pr.productId = @ID);
	END;
GO

SELECT productId, dbo.PRODPATH(productId) AS productPath, modelYear, price
FROM Product
ORDER BY productPath ASC;

--Crear una función que calcule los días entre la fecha de orden y la fecha de envío y consultarlo.
CREATE FUNCTION DAYSDIFF(@ID INT)
	RETURNS INT AS
	BEGIN
		RETURN (SELECT DATEDIFF(D, orderDate, shippedDate) AS DaysDifs
				FROM Ordeer
				WHERE orderId = @ID);
	END;
GO

SELECT orderId, orderDate, requiredDate, shippedDate, dbo.DAYSDIFF(orderId) AS DaysDiff
FROM Ordeer
ORDER BY DaysDiff DESC;

--Crear una función que devuelva el nombre completo del cliente (firstName + lastName) y usarla en un listado.
CREATE FUNCTION FULLNAME(@ID INT)
	RETURNS VARCHAR(128) AS
	BEGIN
		RETURN (SELECT CONCAT_WS(' ', firstName, lastName) AS FullName
				FROM Customer
				WHERE customerId = @ID);
	END;
GO

SELECT customerId, dbo.FULLNAME(customerId) AS FullName, city, district 
FROM Customer;

--Crea una función que reciba storeId y devuelva todos los empleados activos de esa tienda.
CREATE FUNCTION ACTIVEMPLOYEES(@ID INT)
	RETURNS TABLE AS
	RETURN (SELECT sta.staffId, sta.firstName, sta.lastName, sto.storeId, sto.storeName
			FROM Staff sta
			INNER JOIN Store sto ON sto.storeId = sta.storeId AND sto.storeId = @ID
			WHERE sta.active = 1);
GO

SELECT * FROM ACTIVEMPLOYEES(1);
SELECT * FROM ACTIVEMPLOYEES(3);

--Crear una función de tabla que devuelva las órdenes cuyo total sea mayor al promedio global.
CREATE FUNCTION ORDGREATAVG()
	RETURNS TABLE AS
	RETURN (SELECT orderId, dbo.ORDERTOTAL(orderId) AS OrdTotal
			FROM Ordeer
			WHERE dbo.ORDERTOTAL(orderId) > (SELECT AVG(dbo.ORDERTOTAL(orderId)) AS tot FROM Ordeer));
GO

SELECT * FROM ORDGREATAVG();

--Crear un procedimiento que devuelva todas las órdenes de un cliente con sus totales, dado su customerId.
CREATE PROC S_CustomerOrders (@CustID INT) AS 
BEGIN
	SELECT orderId, dbo.ORDERTOTAL(orderId) AS Total 
	FROM Ordeer
	WHERE customerId = @CustID;
END;
GO

EXEC S_CustomerOrders 1011;
EXEC S_CustomerOrders 3;
EXEC S_CustomerOrders 983;

--Crear un procedimiento que verifique si una orden supera un umbral (4999.99) y le aplique un descuento (10%).
--Funcion para obtener cantidad de productos de orden
CREATE FUNCTION ORDPRODAMOUNT(@ordID INT)
	RETURNS INT AS
	BEGIN
		RETURN (SELECT SUM(quantity) AS prodQuant
				FROM OrderItem 
				WHERE orderId = @ordID);
	END;
GO

CREATE PROC U_ORDERDISCOUNT (@ordID INT) AS 
BEGIN
	IF NOT EXISTS(SELECT orderId FROM Ordeer WHERE orderId = @ordID)
		BEGIN
			PRINT 'Order with id ' + CAST(@ordID AS VARCHAR) + ' doesnt exist';
			RETURN;
		END;
	--Si la orden si exsite procedemos con el proceso
	DECLARE @total DECIMAL(10, 2) = dbo.ORDERTOTAL(@ordID);
	IF @total < 5000.00
		BEGIN
			PRINT 'Discount wont be applied to this price ' + CAST(@total AS VARCHAR);
			RETURN;
		END;
	--Si la orden cumple el umbral de precio procedemos con el proceso
	DECLARE @amount INT = dbo.ORDPRODAMOUNT(@ordID); --Cantidad de productos
	--Cursor que para hacer una especie de for in
	DECLARE @curItemId INT;
	DECLARE @curdiscount DECIMAL(10, 2);
	DECLARE itemsId CURSOR FOR SELECT itemId, discount FROM OrderItem WHERE orderId = @ordID;
	DECLARE @newDiscount DECIMAL(10, 2) = .1/@amount;
	--Abrir y obtener primera fila del cursor
	OPEN itemsId;
	FETCH NEXT FROM itemsId
	INTO @curItemId, @curdiscount;
	--Mientras hayan filas
	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE OrderItem SET discount = @curdiscount+@newDiscount
		WHERE itemId = @curItemId;
		--Siguiente fila
		FETCH NEXT FROM itemsId 
		INTO @curItemId, @curdiscount;
	END

	--Cerrar y liberar memoria de cursor
	CLOSE itemsId;
	DEALLOCATE itemsId;
END;
GO

--Debe aplicar descuento
EXEC U_ORDERDISCOUNT 458;
--Debe mostrar mensaje de no aplica descuento
EXEC U_ORDERDISCOUNT 3;
--Debe mostrar mensaje de no existe
EXEC U_ORDERDISCOUNT 12334;

SELECT * FROM OrderItem;