-- 3 Instructions
-- 3.1 Create the Database and Schemas
-- Create the KinetEcoDW Database
CREATE DATABASE KinetEcoDW;
GO
-- Use the new database
USE KinetEcoDW;
GO
-- Create the Dimension and Fact Schemas
CREATE SCHEMA Dimension;
GO

CREATE SCHEMA Fact;
GO


-- 3.2 Design Dimension Tables
-- Create Date Dimension Table
CREATE TABLE Dimension.Date (
    DateKey int NOT NULL,
    FullDate date NOT NULL,
    DayName nvarchar(9) NOT NULL,
    DayNumber tinyint NOT NULL,
    MonthName varchar(9) NOT NULL,
    MonthNumber tinyint NOT NULL,
    QuarterNumber tinyint NOT NULL,
    Year int NOT NULL
	CONSTRAINT PK_Date PRIMARY KEY CLUSTERED (
        DateKey ASC
    )
);

-- Create Customer Dimension Table
CREATE TABLE Dimension.Customer (
    CustomerKey int IDENTITY (1,1) NOT NULL,
    CustomerAlternateKey int NOT NULL,
    FirstName nvarchar(50) NOT NULL,
    LastName nvarchar(50) NOT NULL,
    FullName nvarchar(100) NOT NULL,
    City nvarchar(50) NOT NULL,
    State char(2) NOT NULL,
    Statename nvarchar(20) NOT NULL,
    Zip char(5) NOT NULL
	CONSTRAINT PK_Customer PRIMARY KEY CLUSTERED (
        CustomerKey ASC
    )
);


-- 3.3 Design Fact Table
-- Create Fact Table Orders
CREATE TABLE Fact.Orders (
    OrderID int IDENTITY (1,1) NOT NULL,
    DateKey int NOT NULL,
    CustomerKey int NOT NULL,
    OrderTotal money NOT NULL

    CONSTRAINT PK_Orders PRIMARY KEY CLUSTERED (
        OrderID ASC
    )
);


-- 3.4 Create Indexed View
-- Drop the view if it exists
IF OBJECT_ID('dbo.OrdersByDate', 'V') IS NOT NULL
DROP VIEW OrdersByDate;
GO

-- Create Indexed View OrdersByDate with SCHEMABINDING
CREATE VIEW OrdersByDate
WITH SCHEMABINDING
AS
SELECT 
    d.Year,
    d.MonthName,
    COUNT_BIG(*) AS OrderCount,
    SUM(ISNULL(o.OrderTotal, 0)) AS TotalOrderAmount

FROM Fact.Orders o JOIN Dimension.Date d 
ON o.DateKey = d.DateKey

GROUP BY 
    d.Year,
    d.MonthName;
GO

-- Create Unique Clustered Index on the OrdersByDate View
CREATE UNIQUE CLUSTERED INDEX IDX_OrdersByDate
ON OrdersByDate (Year, MonthName);
GO


-- 4 Deliverables
-- Sample data for Date, Customer, and Orders tables.
-- Insert Sample Data into Dimension.Date
INSERT INTO Dimension.Date (DateKey, FullDate, DayName, DayNumber, MonthName, MonthNumber, QuarterNumber, Year)
VALUES 
(1, '2024-01-01', 'Monday', 1, 'January', 1, 1, 2024),
(2, '2024-02-01', 'Thursday', 1, 'February', 2, 1, 2024);
GO

-- Insert Sample Data into Dimension.Customer
INSERT INTO Dimension.Customer (CustomerAlternateKey, FirstName, LastName, FullName, City, State, Statename, Zip)
VALUES 
(101, 'John', 'Doe', 'John Doe', 'New York', 'NY', 'New York', '10001'),
(102, 'Jane', 'Smith', 'Jane Smith', 'Los Angeles', 'CA', 'California', '90001');
GO

-- Insert Sample Data into Fact.Orders
INSERT INTO Fact.Orders (DateKey, CustomerKey, OrderTotal)
VALUES 
(1, 1, 1500.00),
(2, 2, 800.00);
GO


-- Queries Demonstrating Performance Benefits
-- 1. Without Indexed View
SELECT 
    d.Year,
    d.MonthName,
    COUNT(*) AS OrderCount,
    SUM(o.OrderTotal) AS TotalOrderAmount
FROM 
    Fact.Orders o
    JOIN Dimension.Date d ON o.DateKey = d.DateKey
GROUP BY 
    d.Year,
    d.MonthName;
GO

-- 2. With Indexed View
-- Query Using Indexed View: Retrieves precomputed results
SELECT 
    Year,
    MonthName,
    OrderCount,
    TotalOrderAmount
FROM dbo.OrdersByDate;
GO

