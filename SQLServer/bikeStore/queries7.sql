--Crear vista que muestre: empleado, cantidad de órdenes gestionadas, total vendido, porcentaje sobre total global.
CREATE VIEW View_StaffResume AS
	WITH 
		OrdersInfo AS --Query con info sobre los totales de cada orden
			(SELECT ord.orderId, SUM(ordI.quantity*ordI.price) AS TotalNoDis, 
					SUM((ordI.quantity*ordI.price)-(ordI.quantity*ordI.price*(ordI.discount*ordI.quantity))) AS FinalTotal
				FROM Ordeer ord
				LEFT JOIN OrderItem ordI ON ord.orderId = ordI.orderId
				GROUP BY ord.orderId),
		OrdEmpInfo AS --Query con info sobre los totales de cada orden y cantidad, asociados a su correspondiente empleado
			(SELECT st.staffId, 
					COUNT(ord.orderId) AS Orders,
					COALESCE(SUM(ordIn.TotalNoDis), 0) AS NoDiscount, COALESCE(SUM(ordIn.FinalTotal), 0) AS Final
				FROM Staff st
				LEFT JOIN Ordeer ord ON ord.staffId = st.staffId
				LEFT JOIN OrdersInfo ordIn ON ordIn.orderId = ord.orderId
				GROUP BY st.staffId),
		OrdTotal AS --Query con info sobre los totales de ordenes y valores
			(SELECT SUM(Orders) AS TotalOrders, SUM(NoDiscount) AS TotalNoDis, SUM(Final) TotalFinal 
				FROM OrdEmpInfo)
	--Query final con las estadisticas de cada empleado y sus porcentajes
	SELECT ordEmp.staffId, CONCAT_WS(' ', st.firstName, st.lastName) AS EmployeeName,
			ordEmp.Orders, ordEmp.Orders*100/(SELECT TotalOrders FROM OrdTotal) AS OrdsPercentange,
			ordEmp.NoDiscount, ROUND(ordEmp.NoDiscount*100/(SELECT TotalNoDis FROM OrdTotal), 2) AS NoDisPercentange,
			ordEmp.Final, ROUND(ordEmp.Final*100/(SELECT TotalFinal FROM OrdTotal), 2) AS TotalPercentange
	FROM OrdEmpInfo ordEmp
	INNER JOIN Staff st ON st.staffId = ordEmp.staffId;
GO

SELECT * FROM dbo.View_StaffResume
ORDER BY staffId ASC;

--Crear vista que muestre, por cada tienda y categoría, los productos disponibles con su stock.
CREATE VIEW View_StockBYStoreCateg AS 
	WITH 
		stockFullInfo AS 
			(SELECT st.storeName, cat.categoryName, stk.productId, pd.productName, stk.quantity 
			 FROM Store st
			 INNER JOIN Stock stk ON stk.storeId = st.storeId
			 INNER JOIN Product pd ON pd.productId = stk.productId
			 INNER JOIN Category cat ON cat.categoryId = pd.categoryId)
	SELECT DISTINCT storeName, SUM(quantity) OVER (PARTITION BY storeName) AS StoreStock,
	categoryName, SUM(quantity) OVER (PARTITION BY categoryName, storeName) AS CategoryStock
	FROM stockFullInfo
GO

SELECT *
FROM dbo.View_StockBYStoreCateg
ORDER BY storeName ASC, categoryName ASC;

--Crear vista que muestre historial de clientes relacionando clientes, productos comprados y montos totales.
CREATE VIEW View_CustomerHistory AS
	WITH 
		Orders AS --Query con info de la cantidad de productos y precios con descuento aplicado a cada orden
			(SELECT orderId, SUM((quantity*price)-(quantity*price*(discount*quantity))) AS FinalTotal,
					SUM(quantity) AS ProdAmount
			FROM OrderItem
			GROUP BY orderId),
		OrdersInfo AS --Query con info de la cantidad de productos y precios con descuento aplicado a cada orden
			(SELECT ord.orderId, ord.customerId, ords.ProdAmount, ords.FinalTotal
			FROM Ordeer ord
			INNER JOIN Orders ords ON ords.orderId = ord.orderId)
	--Query final que agrupara los datos recolectados previamente de las ordenes y los operara de acuerdo a su cliente
	SELECT cus.customerId, SUM(ordIn.FinalTotal) CustomerTotal, COUNT(ordIn.orderId) AS OrdersAmount,
			SUM(ordIn.ProdAmount) AS ProductsAmount
	FROM Customer cus
	LEFT JOIN OrdersInfo ordIn ON ordIn.customerId = cus.customerId
	GROUP BY cus.customerId;
GO

SELECT CONCAT_WS(' ', cus.firstName, cus.lastName) AS CustomerName, vi.* 
FROM dbo.View_CustomerHistory vi
INNER JOIN Customer cus ON cus.customerId = vi.customerId;

--Crear vista que calcule el porcentaje de participación en ventas de cada tienda.
CREATE VIEW View_StoreParticipation AS
	WITH 
		storeOrds AS
			(SELECT st.storeName, COUNT(ord.orderId) AS Orders
			FROM Store st
			INNER JOIN Ordeer ord ON ord.storeId = st.storeId
			GROUP BY st.storeName)
	SELECT storeName, Orders, Orders*100/(SELECT SUM(Orders) FROM storeOrds) AS StPercentage
	FROM storeOrds;
GO

SELECT * FROM dbo.View_StoreParticipation;