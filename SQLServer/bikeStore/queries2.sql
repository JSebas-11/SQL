--Ejercicio 1: Concatenar fistName and LasName en una sola columna y mostrar su tamaño.
SELECT fullName, LEN(fullName)-1 AS lenName 
FROM
	(SELECT CONCAT_WS(' ', firstName, lastName) AS fullName FROM Customer) sub;

--Ejercicio 2: Mostrar los productos con un precio superior a 999.99.
SELECT * FROM Product WHERE price > 999.99;

--Ejercicio 3: Mostrar el nombre de la tienda y su ciudad, ordenados alfabéticamente por ciudad.
SELECT city, storeName FROM Store
ORDER BY city ASC, storeName ASC;

--Ejercicio 4: Mostrar los clientes que viven en la ciudad de "New York" o "Santa Cruz".
SELECT * FROM Customer
WHERE city = 'New York' OR city = 'Santa Cruz';

--Ejercicio 5: Encontrar todos los productos de la marca "Trek".
SELECT prod.productId, prod.productName, br.brandName, prod.modelYear, prod.price 
FROM Product prod 
INNER JOIN Brand br ON prod.brandId = br.brandId
WHERE br.brandName = 'Trek';

--Ejercicio 6: Encontrar todos los pedidos que fueron enviados entre el 1 de junio de 2016 y el 31 de diciembre de 2016.
SELECT * FROM Ordeer
WHERE shippedDate BETWEEN '2016-06-01' AND '2016-12-31';

--Ejercicio 7: Obtener los 5 productos más caros en la tienda.
SELECT TOP(5) * FROM Product
ORDER BY price DESC;

--Ejercicio 8: Obtener los últimos 10 clientes registrados según su customerId, ordenados de más reciente a más antiguo.
SELECT TOP(10) * FROM Customer
ORDER BY customerId DESC;

--Ejercicio 9: Encontrar los correos electrónicos gmail en la tabla Customer.
SELECT * FROM Customer
WHERE email LIKE '%@gmail%';

--Ejercicio 10: Encontrar los productos que contienen la palabra "mountain" en su nombre.
SELECT * FROM Product
WHERE productName LIKE '%mountain%';

--Ejercicio 11: Obtener la cantidad total de productos disponibles en todas las tiendas.
SELECT storeName, SUM(quantity) AS ProductsNum
FROM
	(SELECT sto.storeName, st.quantity FROM Stock st
	INNER JOIN Store sto ON st.storeId = sto.storeId) sub
GROUP BY storeName;

--Ejercicio 12: Calcular el precio promedio de todos los productos.
SELECT AVG(price) AS totalAvg FROM Product;

--Ejercicio 13: Encontrar el mayor descuento aplicado en cualquier pedido.
SELECT TOP(1) *, price - (price*discount) AS FinalPrice FROM OrderItem
ORDER BY FinalPrice ASC;

--Ejercicio 14: Mostrar cuántos productos hay en cada categoría.

SELECT cat.categoryName, SUM(sto.quantity) AS Amount
FROM Product prod
INNER JOIN Stock sto ON prod.productId = sto.productId
INNER JOIN Category cat ON prod.categoryId = cat.categoryId
GROUP BY cat.categoryName;

--Ejercicio 15: Mostrar cuántos pedidos ha realizado cada cliente, ordenados de mayor a menor.
SELECT fullName, COUNT(orderId) AS orders
FROM 
	(SELECT cus.customerId, CONCAT_WS(' ', cus.firstName, cus.lastName) AS fullName, ord.orderId
	FROM Customer cus
	LEFT JOIN Ordeer ord ON cus.customerId = ord.customerId) sub
GROUP BY fullName
ORDER BY orders DESC;