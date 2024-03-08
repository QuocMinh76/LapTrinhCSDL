-- MODULE 1

CREATE DATABASE SmallWorks
ON PRIMARY
(
	NAME = 'SmallWorksPrimary',
	FILENAME = 'D:\SmallWorks.mdf',
	SIZE = 10MB,
	FILEGROWTH = 20%,
	MAXSIZE = 50MB
),
FILEGROUP SWUserData1
(
	NAME = 'SmallWorksData1',
	FILENAME = 'D:\SmallWorksData1.ndf',
	SIZE = 10MB,
	FILEGROWTH = 20%,
	MAXSIZE = 50MB
),
FILEGROUP SWUserData2
(
	NAME = 'SmallWorksData2',
	FILENAME = 'D:\SmallWorksData2.ndf',
	SIZE = 10MB,
	FILEGROWTH = 20%,
	MAXSIZE = 50MB
)
LOG ON
(
	NAME = 'SmallWorks_log',
	FILENAME = 'D:\SmallWorks_log.ldf',
	SIZE = 10MB,
	FILEGROWTH = 10%,
	MAXSIZE = 20MB	
)
GO

-- MODULE 2

USE AdventureWorks
GO

-- Cau 1
SELECT sod.SalesOrderID, OrderDate, SUM(OrderQty * UnitPrice) AS SubTotal
FROM Sales.SalesOrderDetail sod JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
WHERE YEAR(OrderDate) = 2001 AND MONTH(OrderDate) = 8
GROUP BY sod.SalesOrderID, OrderDate
HAVING SUM(OrderQty * UnitPrice) > 7000

-- Cau 2
SELECT st.TerritoryID, COUNT(c.CustomerID) AS CountOfCust, SUM(OrderQty * UnitPrice) AS SubTotal
FROM Sales.SalesOrderDetail sod JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
		JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
		JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
WHERE CountryRegionCode = 'US'
GROUP BY st.TerritoryID

-- Cau 3
SELECT sod.SalesOrderID, CarrierTrackingNumber, SUM(OrderQty * UnitPrice) AS SubTotal
FROM Sales.SalesOrderDetail sod JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
WHERE CarrierTrackingNumber LIKE '4BD%'
GROUP BY sod.SalesOrderID, CarrierTrackingNumber

-- Cau 4
SELECT p.ProductID, Name, AVG(OrderQty) AS AverageOfQty
FROM Sales.SalesOrderDetail sod JOIN Production.Product p ON sod.ProductID = p.ProductID
WHERE UnitPrice < 25
GROUP BY p.ProductID, Name
HAVING AVG(OrderQty) > 5

-- Cau 5
SELECT Title, COUNT(*) AS CountOfPerson
FROM HumanResources.Employee
GROUP BY Title
HAVING COUNT(*) > 20

-- Cau 6
SELECT v.VendorID, Name, ProductID, SUM(OrderQty) AS SumOfQty, SUM(OrderQty * UnitPrice) AS SubTotal
FROM Purchasing.PurchaseOrderDetail pod JOIN Purchasing.PurchaseOrderHeader poh ON pod.PurchaseOrderID = poh.PurchaseOrderID
		JOIN Purchasing.Vendor v ON v.VendorID = poh.VendorID
WHERE Name LIKE '%Bicycles'
GROUP BY v.VendorID, Name, ProductID
HAVING SUM(OrderQty * UnitPrice) > 800000

-- Cau 7
SELECT p.ProductID, Name, COUNT(sod.SalesOrderID) AS CountOfOrderID, SUM(OrderQty * UnitPrice) AS SubTotal
FROM Sales.SalesOrderDetail sod JOIN Production.Product p ON sod.ProductID = p.ProductID
		JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
WHERE DATEPART(q, OrderDate) = 1 AND YEAR(OrderDate) = 2003
GROUP BY p.ProductID, Name
HAVING COUNT(soh.SalesOrderID) > 50 AND SUM(OrderQty * UnitPrice) > 5000

-- Cau 8
SELECT c.ContactID, (FirstName + ' ' + LastName) AS FullName, COUNT(sod.SalesOrderID) AS CountOfOrders
FROM Sales.SalesOrderHeader soh JOIN Person.Contact c ON soh.ContactID = c.ContactID
		JOIN Sales.SalesOrderDetail sod ON sod.SalesOrderID = soh.SalesOrderID
WHERE YEAR(OrderDate) = 2002 OR YEAR(OrderDate) = 2003
GROUP BY c.ContactID, (FirstName + ' ' + LastName)
HAVING COUNT(sod.SalesOrderID) > 25

-- MODULE 3

-- Cau 1
CREATE VIEW vw_Product AS
SELECT p.ProductID, Name, Color, Size, p.StandardCost, EndDate, StartDate
FROM Production.Product p JOIN Production.ProductCostHistory pch ON p.ProductID = pch.ProductID

SELECT * FROM vw_Product

-- Cau 2
CREATE VIEW List_Product_View AS
SELECT p.ProductID, Name, COUNT(sod.SalesOrderID) AS CountOfOrderID, SUM(OrderQty * UnitPrice) AS SubTotal
FROM Sales.SalesOrderDetail sod JOIN Production.Product p ON sod.ProductID = p.ProductID
		JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
WHERE DATEPART(q, OrderDate) = 2 AND YEAR(OrderDate) = 2002
GROUP BY p.ProductID, Name
HAVING SUM(OrderQty * UnitPrice) > 10000

SELECT * FROM List_Product_View

-- Cau 3
CREATE VIEW vw_CustomerTotals AS
SELECT c.CustomerID, YEAR(OrderDate) AS OrderYear, MONTH(OrderDate) AS OrderMonth, SUM(TotalDue) AS SumOfTotalDue
FROM Sales.SalesOrderDetail sod JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
		JOIN Sales.Customer c ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID, YEAR(OrderDate), MONTH(OrderDate)

SELECT * FROM vw_CustomerTotals

-- Cau 4
CREATE VIEW TotalQuantity AS
SELECT sp.SalesPersonID, YEAR(OrderDate) AS OrderYear, SUM(OrderQty) AS SumOfOrderQty
FROM Sales.SalesOrderDetail sod JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
		JOIN Sales.SalesPerson sp ON sp.SalesPersonID = soh.SalesPersonID
GROUP BY sp.SalesPersonID, YEAR(OrderDate)

-- Cau 5
CREATE VIEW ListCustomer_view AS
SELECT c.ContactID, (FirstName + ' ' + LastName) AS FullName, COUNT(sod.SalesOrderID) AS CountOfOrders
FROM Sales.SalesOrderHeader soh JOIN Person.Contact c ON soh.ContactID = c.ContactID
		JOIN Sales.SalesOrderDetail sod ON sod.SalesOrderID = soh.SalesOrderID
WHERE YEAR(OrderDate) = 2001 OR YEAR(OrderDate) = 2002
GROUP BY c.ContactID, (FirstName + ' ' + LastName)
HAVING COUNT(sod.SalesOrderID) > 25

SELECT * FROM ListCustomer_view

-- Cau 6
CREATE VIEW ListProduct_view AS
SELECT p.ProductID, Name, SUM(OrderQty) AS SumOfOrderQty, YEAR(OrderDate) AS Year
FROM Sales.SalesOrderDetail sod JOIN Production.Product p ON sod.ProductID = p.ProductID
		JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
WHERE Name LIKE 'Bike%' OR Name LIKE 'Sport%'
GROUP BY p.ProductID, Name, YEAR(OrderDate)
HAVING SUM(OrderQty) > 500

SELECT * FROM ListProduct_view

-- Cau 7
CREATE VIEW List_Department_View AS
SELECT d.DepartmentID, Name, AVG(Rate) AS AvgOfRate
FROM HumanResources.Department d JOIN HumanResources.EmployeeDepartmentHistory edh ON d.DepartmentID = edh.DepartmentID
		JOIN HumanResources.EmployeePayHistory eph ON eph.EmployeeID = edh.EmployeeID
GROUP BY d.DepartmentID, Name
HAVING AVG(Rate) > 30

SELECT * FROM List_Department_View