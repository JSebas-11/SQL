--Show the content in every table
SELECT * FROM Brand;
SELECT * FROM Category;
SELECT * FROM Customer;
SELECT * FROM Ordeer;
SELECT * FROM OrderItem;
SELECT * FROM Product;
SELECT * FROM Staff;
SELECT * FROM Stock;
SELECT * FROM Store;

--Show tables' name and its amount of rows
SELECT infoTable.name AS TableName, sub.rowsNum
FROM (
    SELECT OBJECT_ID('Customer') AS id, COUNT(*) AS rowsNum FROM Customer
    UNION ALL
    SELECT OBJECT_ID('Category'), COUNT(*) FROM Category
    UNION ALL
    SELECT OBJECT_ID('Brand'), COUNT(*) FROM Brand
    UNION ALL
    SELECT OBJECT_ID('Product'), COUNT(*) FROM Product
    UNION ALL
    SELECT OBJECT_ID('Store'), COUNT(*) FROM Store
    UNION ALL
    SELECT OBJECT_ID('Stock'), COUNT(*) FROM Stock
    UNION ALL
    SELECT OBJECT_ID('Staff'), COUNT(*) FROM Staff
    UNION ALL
    SELECT OBJECT_ID('Ordeer'), COUNT(*) FROM Ordeer
    UNION ALL
    SELECT OBJECT_ID('OrderItem'), COUNT(*) FROM OrderItem
) AS sub
INNER JOIN sys.objects AS infoTable ON infoTable.object_id = sub.id;
