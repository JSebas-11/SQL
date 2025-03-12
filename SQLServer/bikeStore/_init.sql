/*File created by JSEBAS-11 (https://github.com/JSebas-11) in order to practice SQL Queries
Datasets taken from: https://www.kaggle.com/datasets/dillonmyrick/bike-store-sample-database/data
In this file we are going to create database, tables and relation amoung them*/

--DATABASE Creation
CREATE DATABASE BikeStore;
GO
USE BikeStore;
GO
--TABLES creation
CREATE TABLE Customer(
    customerId INT PRIMARY KEY IDENTITY(1,1),
    firstName VARCHAR(64) NOT NULL,
    lastName VARCHAR(64) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(128) UNIQUE,
    street VARCHAR(64),
    city VARCHAR(64),
    district VARCHAR(64),
    zipCode VARCHAR(20)
);
GO
CREATE TABLE Category(
    categoryId INT PRIMARY KEY IDENTITY(1,1),
    categoryName VARCHAR(128) NOT NULL
);
GO
CREATE TABLE Brand(
    brandId INT PRIMARY KEY IDENTITY(1,1),
    brandName VARCHAR(128) NOT NULL
);
GO
CREATE TABLE Product(
    productId INT PRIMARY KEY IDENTITY(1,1),
    productName VARCHAR(128) NOT NULL,
    brandId INT,
    categoryId INT,
    modelYear INT,
    price DECIMAL(10, 2),

    CONSTRAINT FK_Product_Brand FOREIGN KEY (brandId)
        REFERENCES Brand(brandId) ON DELETE SET NULL,
    CONSTRAINT FK_Product_Category FOREIGN KEY (categoryId)
        REFERENCES Category(categoryId) ON DELETE SET NULL
);
GO
CREATE TABLE Store(
    storeId INT PRIMARY KEY IDENTITY(1,1),
    storeName VARCHAR(64) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(128) UNIQUE,
    street VARCHAR(64),
    city VARCHAR(64),
    district VARCHAR(64),
    zipCode VARCHAR(20)
);
GO
CREATE TABLE Stock(
    storeId INT,
    productId INT,
    quantity INT NOT NULL,

    CONSTRAINT FK_Stock_Store FOREIGN KEY (storeId)
        REFERENCES Store(storeId) ON DELETE CASCADE,
    CONSTRAINT FK_Stock_Product FOREIGN KEY (productId)
        REFERENCES Product(productId) ON DELETE CASCADE
);
GO
CREATE TABLE Staff(
    staffId INT PRIMARY KEY IDENTITY(1,1),
    firstName VARCHAR(64) NOT NULL,
    lastName VARCHAR(64) NOT NULL,
    email VARCHAR(128) UNIQUE,
    phone VARCHAR(20) NOT NULL UNIQUE,
    active TINYINT,
    storeId INT,
    managerId INT,

    CONSTRAINT FK_Staff_Store FOREIGN KEY (storeId)
        REFERENCES Store(storeId) ON DELETE SET NULL
);
GO
CREATE TABLE Ordeer(
    orderId INT PRIMARY KEY IDENTITY(1,1),
    customerId INT,
    orderStatus INT NOT NULL,
    orderDate DATE NOT NULL,
    requiredDate DATE NOT NULL,
    shippedDate DATE,
    storeId INT,
    staffId INT,

    CONSTRAINT FK_Order_Customer FOREIGN KEY (customerId)
        REFERENCES Customer(customerId) ON DELETE CASCADE,
    CONSTRAINT FK_Order_Store FOREIGN KEY (storeId) 
        REFERENCES Store(storeId) ON DELETE SET NULL,
    CONSTRAINT FK_Order_Staff FOREIGN KEY (staffId) 
        REFERENCES Staff(staffId) ON DELETE SET NULL
)
GO
CREATE TABLE OrderItem(
    itemId INT PRIMARY KEY IDENTITY(1,1),
    orderId INT,
    productId INT,
    quantity INT,
    price DECIMAL(10, 2),
    discount DECIMAL(10, 2),

    CONSTRAINT FK_OrderItem_Order FOREIGN KEY (orderId)
        REFERENCES Ordeer(orderId) ON DELETE CASCADE,
    CONSTRAINT FK_OrderItem_Product FOREIGN KEY (productId) 
        REFERENCES Product(productId) ON DELETE SET NULL
)
GO