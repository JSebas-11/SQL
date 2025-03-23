--Obtener los 5 empleados que más ventas han realizado.
WITH cte AS (
	SELECT ord.orderId, sta.staffId AS emploId, CONCAT_WS(' ', sta.firstName, sta.lastName) AS emploName
	FROM Ordeer ord
	RIGHT JOIN Staff sta ON sta.staffId = ord.staffId)
SELECT TOP 5 emploId, emploName, COUNT(orderId) AS OrdersNum
FROM cte
GROUP BY emploId, emploName
ORDER BY 3 DESC;

--Mostrar el ingreso total por cada empleado.
WITH collByOrder AS (
	SELECT ordI.orderId, SUM((ordI.price - (ordI.price*ordI.discount)) * ordI.quantity) AS Collected
	FROM OrderItem ordI
	GROUP BY ordI.orderId),
relOrdColl AS (
	SELECT ord.orderId, collByOrder.Collected, ord.staffId
	FROM collByOrder
	RIGHT JOIN Ordeer ord ON ord.orderId = collByOrder.orderId),
relOrdSta AS (
	SELECT staffId, SUM(Collected) AS staffColl
	FROM relOrdColl
	GROUP BY staffId
)
SELECT staff.staffId, CONCAT_WS(' ', staff.firstName, staff.lastName) AS emploName, COALESCE(relOrdSta.staffColl, 0) AS emploCollected 
FROM staff
LEFT JOIN relOrdSta ON relOrdSta.staffId = Staff.staffId
ORDER BY 3 DESC;

--Obtener las órdenes donde el total sea mayor al promedio de todas las órdenes.
WITH cte2 AS (
	SELECT orderId, SUM((price - (price * discount)) * quantity) AS collected
	FROM OrderItem
	GROUP BY orderId)
SELECT * FROM cte2 
WHERE collected > (SELECT AVG(collected) FROM cte2)
ORDER BY 2 DESC;

--Obtener los 3 clientes que han gastado más dinero en la tienda.
WITH cte3 AS(
	SELECT orderId, SUM((price - (price * discount)) * quantity) AS collected
	FROM OrderItem
	GROUP BY orderId),
ordItemOrder AS (
	SELECT ord.orderId, ord.customerId, cte3.collected
	FROM Ordeer ord
	INNER JOIN cte3 ON cte3.orderId = ord.orderId)
SELECT TOP 3 cust.customerId, CONCAT_WS(' ', cust.firstName, Cust.lastName) AS custName, lastCte.orderId, lastCte.collected
FROM Customer cust
INNER JOIN ordItemOrder lastCte ON lastCte.customerId = cust.customerId
ORDER BY collected DESC;

--Identificar productos con más órdenes que stock disponible.
WITH requested AS(
	SELECT productId, SUM(quantity) totalRequested
	FROM OrderItem
	GROUP BY productId),
avaStock AS (
	SELECT productId, SUM(quantity) AS totalAvailable
	FROM Stock
	GROUP BY productId),
prodData AS (
	SELECT prod.productId, prod.productName, COALESCE(req.totalRequested, 0) as requested, COALESCE(aStk.totalAvailable, 0) AS available
	FROM Product prod
	LEFT JOIN requested req ON req.productId = prod.productId
	LEFT JOIN avaStock aStk ON aStk.productId = prod.productId)
SELECT * FROM prodData
WHERE requested > available
ORDER BY requested DESC;

--Obtener productos presentes en varias tiendas y sus nombres.
WITH relProdStore AS (
	SELECT st.storeName, prod.productName, SUM(COALESCE(sto.quantity, 0)) AS quantity
	FROM Product prod
	LEFT JOIN Stock sto ON prod.productId = sto.productId
	LEFT JOIN Store st ON st.storeId = sto.storeId
	GROUP BY productName, storeName)
SELECT productName, storeName, COUNT(storeName) OVER (PARTITION BY productName) AS inStores
FROM relProdStore
ORDER BY productName ASC;

--Mostrar el tiempo promedio entre la orden y el envío de cada empleado.
WITH cte4 AS(
	SELECT staffId, orderDate, shippedDate, DATEDIFF(DAY, orderDate, shippedDate) AS daysDiff
	FROM Ordeer
	WHERE orderDate IS NOT NULL AND shippedDate IS NOT NULL),
diffAvg AS (
	SELECT staffId, AVG(daysDiff) as average
	FROM cte4
	GROUP BY staffId)
SELECT CONCAT_WS(' ', firstName, lastName) AS emploName, diffAvg.average
FROM Staff
LEFT JOIN diffAvg ON diffAvg.staffId = Staff.staffId
ORDER BY average DESC;

--Mostrar cliente y tienda donde el cliente ha realizado 3 compras en la misma.
WITH cte5 AS (
	SELECT customerId, storeId, COUNT(storeId) AS boughts
	FROM Ordeer
	GROUP BY customerId, storeId HAVING COUNT(storeId) = 3)
SELECT CONCAT_WS(' ', Cust.firstName, Cust.lastName) AS custName, st.storeName, cte5.boughts
FROM cte5
INNER JOIN Customer cust ON cust.customerId = cte5.customerId
INNER JOIN Store st ON st.storeId = cte5.storeId;

--Obtener el porcentaje de participación de cada empleado en las ventas totales.
WITH cte6 AS (
	SELECT staffId, (COUNT(orderId) * 100) / (SELECT COUNT(*) FROM Ordeer) AS emploPercentage
	FROM Ordeer
	GROUP BY staffId)
SELECT CONCAT_WS(' ', firstName, lastName) AS emploName, COALESCE(emploPercentage, 0) AS emploPercentage
FROM Staff
LEFT JOIN cte6 ON cte6.staffId = Staff.staffId;

--Mostrar el producto más y menos vendido por cada categoría.
WITH cte7 AS (
	SELECT productId, SUM(quantity) AS quantitySold
	FROM OrderItem
	GROUP BY productId),
relProdQuan AS (
	SELECT cat.categoryName, prod.productName, COALESCE(cte7.quantitySold, 0) AS amountSold
	FROM Product prod
	LEFT JOIN cte7 ON cte7.productId = prod.productId
	LEFT JOIN Category cat ON cat.categoryId = prod.categoryId),
valuesOrdered AS (
	SELECT categoryName,
		DENSE_RANK() OVER (PARTITION BY categoryName ORDER BY amountSold DESC) AS maxRank,
		DENSE_RANK() OVER (PARTITION BY categoryName ORDER BY amountSold ASC) AS minRank,
		productName, amountSold
	FROM relProdQuan)
SELECT categoryName, productName, amountSold
FROM valuesOrdered
WHERE maxRank = 1 OR minRank = 1
ORDER BY categoryName ASC, amountSold DESC;