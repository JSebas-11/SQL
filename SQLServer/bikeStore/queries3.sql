--Obtener el promedio de precios de productos por año de modelo.
SELECT modelYear, ROUND(AVG(price), 2) AS AveragePrice
FROM Product
GROUP BY modelYear
ORDER BY modelYear ASC;

--Encontrar los pedidos realizados en diciembre de 2018.
SELECT * FROM Ordeer
WHERE MONTH(shippedDate) = 12 AND YEAR(shippedDate) = 2018;

--Contar clientes por ciudad ordenados descendemente.
SELECT city, COUNT(city) AS NumCustomers FROM Customer
GROUP BY city
ORDER BY 2 DESC;

--Obtener los clientes cuyo apellido empieza con 'M' y termine en 'e' o 'n' y ordenar ascendentemente.
SELECT * FROM Customer
WHERE lastName LIKE 'M%[en]'
ORDER BY lastName ASC;

--Mostrar cantidad de ordenes por tienda ordenados Descendentemente.
SELECT st.storeName, COUNT(ord.orderId) AS AmountOrders
FROM Store st
LEFT JOIN Ordeer ord ON st.storeId = ord.storeId
GROUP BY storeName
ORDER BY 2 DESC;

--Obtener los 3 productos mas vendidos.
SELECT TOP 3 prod.productName, SUM(ordI.quantity) AS AmountSolds
FROM Product prod
LEFT JOIN OrderItem ordI ON ordI.productId = prod.productId
GROUP BY prod.productName
ORDER BY 2 DESC;

--Mostrar los productos que no tuvieron ventas.
SELECT prod.productName, SUM(oi.quantity) AS Solds
FROM Product prod
LEFT JOIN OrderItem oi ON oi.productId = prod.productId
GROUP BY prod.productName HAVING SUM(oi.quantity) IS NULL;

--Obtener el producto mas vendidos por la marca 'Pure Cycles'.
SELECT TOP 1 productName, SUM(quantity) AS Solds
FROM
	(SELECT prod.productId, prod.productName, br.brandName, ordI.quantity
	FROM Product prod
	INNER JOIN Brand br ON br.brandId = prod.brandId
	LEFT JOIN OrderItem ordI ON ordI.productId = prod.productId
	WHERE brandName = 'Pure Cycles') sub
GROUP BY productName
ORDER BY 2 DESC;

--Mostrar cantidad de personas que tiene cada extension de correos.
SELECT Extension, COUNT(Extension) AS Amount
FROM
	(SELECT email, (CASE WHEN email LIKE '%@gmail%' THEN 'Gmail'
						WHEN email LIKE '%@hotmail%' THEN 'Hotmail'
						WHEN email LIKE '%@yahoo%' THEN 'Yahoo'
						ELSE 'Other'
					END) AS Extension
					FROM Customer) sub
GROUP BY Extension
ORDER BY 2 DESC;

--Mostrar los productos con un precio mayor a 2599 en categoria 'Electric Bikes' y marca 'Electra'.
SELECT prod.productId, prod.productName, prod.modelYear, prod.price, cat.categoryName, br.brandName
FROM Product prod
INNER JOIN Category cat ON cat.categoryId = prod.categoryId
INNER JOIN Brand br ON br.brandId = prod.brandId
WHERE prod.price >= 2600 AND cat.categoryName = 'Electric Bikes' AND br.brandName= 'Electra'
ORDER BY price DESC;

--Mostrar las ciudades con mas cantidad de pedidos.
WITH cte AS (
	SELECT cust.city, ord.orderId
	FROM Customer cust
	INNER JOIN Ordeer ord ON ord.customerId = cust.customerId)
SELECT TOP 10 city, COUNT(orderId) AS Orders
FROM cte
GROUP BY city
ORDER BY 2 DESC;

--Calcular el precio mínimo, máximo y promedio de los productos por cada tienda.
WITH cte2 AS (
	SELECT Store.storeName, prod.productName, prod.price 
	FROM Stock
	INNER JOIN Product prod ON prod.productId = Stock.productId
	INNER JOIN Store ON Store.storeId = Stock.storeId)
SELECT storeName, MAX(price) AS Maximum, MIN(price) AS Minimum, AVG(price) AS Average
FROM cte2
GROUP BY storeName;

--Mostrar info de los 3 pedidos con mayor total pagado (precio * cantidad).
WITH cte3 AS (
	SELECT orderId, ((price - (price*discount)) * quantity) AS Collected
	FROM OrderItem)
SELECT TOP 3 orderId, SUM(Collected) AS TotalCollected
FROM cte3
GROUP BY orderId
ORDER BY 2 DESC;

--Encontrar total recaudado por categoria.
WITH cte4 AS (
	SELECT cat.categoryName, prod.productName, ((ordI.price - (ordI.price * ordI.discount)) * ordI.quantity) AS ProdCollected
	FROM Product prod
	LEFT JOIN OrderItem ordI ON ordI.productId = prod.productId
	INNER JOIN Category cat ON cat.categoryId = prod.categoryId)
SELECT categoryName, SUM(ProdCollected) AS CatCollected  
FROM cte4
GROUP BY categoryName
ORDER BY 2 DESC;

--Obtener la cantidad total de cada producto por cada tienda.
WITH cte5 AS (
	SELECT store.storeName, prod.productName, Stock.quantity
	FROM Stock
	RIGHT JOIN Product prod ON prod.productId = Stock.productId
	INNER JOIN Store ON Store.storeId = Stock.storeId)
SELECT DISTINCT storeName, productName, SUM(quantity) OVER (PARTITION BY productName) AS ProdStock, SUM(quantity) OVER (PARTITION BY storeName) AS StoreStock 
FROM cte5
ORDER BY storeName ASC, ProdStock DESC;