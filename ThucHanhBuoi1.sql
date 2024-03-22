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

-- Cau 8
CREATE VIEW Sales.vw_OrderSummary AS
SELECT YEAR(OrderDate) AS OrderYear, MONTH(OrderDate) AS OrderMonth, SUM(OrderQty * UnitPrice) AS OrderTotal
FROM Sales.SalesOrderDetail sod JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
GROUP BY YEAR(OrderDate), MONTH(OrderDate)

SELECT * FROM Sales.vw_OrderSummary

-- MODULE 4

-- STORED PROCEDURES
-- Cau 1
CREATE PROC TinhTotalDue
@Thang int, @Nam int
AS
BEGIN
	SELECT CustomerID, SUM(TotalDue) AS SumOfTotalDue
	FROM Sales.SalesOrderHeader
	WHERE YEAR(OrderDate) = @Nam AND MONTH(OrderDate) = @Thang
	GROUP BY CustomerID
END

EXEC TinhTotalDue 12, 2002
GO

-- Cau 2
CREATE PROC TinhSalesInYear
@SalesPerson int, @Nam int
AS
BEGIN
	DECLARE @SalesYTD int
	SET @SalesYTD = (SELECT SUM(OrderQty * UnitPrice)
					FROM Sales.SalesPerson sp JOIN Sales.SalesOrderHeader soh ON sp.SalesPersonID = soh.SalesPersonID
						JOIN Sales.SalesOrderDetail sod ON sod.SalesOrderID = soh.SalesOrderID
					WHERE sp.SalesPersonID = @SalesPerson AND YEAR(OrderDate) = @Nam)
	SELECT @SalesYTD AS SaleYearInYear
END

EXEC TinhSalesInYear 281, 2003
GO

-- Cau 3
CREATE PROC DSListPriceKhongQuaMaxPrice
@MaxPrice int
AS
BEGIN
	SELECT ProductID, ListPrice
	FROM Production.Product
	WHERE ListPrice < @MaxPrice
END

EXEC DSListPriceKhongQuaMaxPrice 52
GO

-- Cau 4
CREATE PROC NewBonus
@SalesPerson int
AS
BEGIN
	DECLARE @NewBonus money
	SET @NewBonus = (SELECT SUM(SubTotal) * 0.01
					FROM Sales.SalesPerson sp JOIN Sales.SalesOrderHeader soh ON sp.SalesPersonID = soh.SalesPersonID
					WHERE sp.SalesPersonID = @SalesPerson)
	UPDATE Sales.SalesPerson
	SET Bonus = Bonus + @NewBonus
	WHERE SalesPersonID = @SalesPerson			
END

EXEC NewBonus 281
GO

-- Cau 5
CREATE PROC XemThongTinNhomSP
@Nam int
AS
BEGIN
	SELECT pc.ProductCategoryID, pc.Name, SUM(OrderQty) AS SumOfOty
	FROM Sales.SalesOrderDetail sod JOIN Production.Product p ON sod.ProductID = p.ProductID
		JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
		JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
		JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
	WHERE YEAR(OrderDate) = @Nam
		AND pc.ProductCategoryID = (SELECT TOP 1 pc.ProductCategoryID
					FROM Sales.SalesOrderDetail sod JOIN Production.Product p ON sod.ProductID = p.ProductID
						JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
						JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
						JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
					WHERE YEAR(OrderDate) = @Nam
					GROUP BY pc.ProductCategoryID
					ORDER BY SUM(OrderQty) DESC)
	GROUP BY pc.ProductCategoryID, pc.Name
END

EXEC XemThongTinNhomSP 2002
GO

-- Cau 6
CREATE PROC TongThu
@MaNV int
AS
BEGIN
	DECLARE @TongThu money, @ErrCode int, @ThanhCong bit = 0
	SET @TongThu = (
		SELECT SUM(OrderQty * UnitPrice)
		FROM Sales.SalesPerson sp JOIN Sales.SalesOrderHeader soh ON sp.SalesPersonID = soh.SalesPersonID
		JOIN Sales.SalesOrderDetail sod ON sod.SalesOrderID = soh.SalesOrderID
		WHERE sp.SalesPersonID = @MaNV
		GROUP BY sp.SalesPersonID)

	SET @ThanhCong = 1
	IF (@ThanhCong = 1)
		SELECT @TongThu
	ELSE
		PRINT('Fail')
END

EXEC TongThu 281
GO
-- Cau 6
create procedure TongThu
			@id int,
			@total money output --khai báo tham số output
as
	select @total=sum(TotalDue) from Sales.SalesOrderHeader sales
	where sales.SalesPersonID=@id
	if @total is null
		return 0 --- return 0 nếu không thực hiện thành công ( total = null)

---test procedure
declare @tong money;
exec dbo.TongThu @id=277, @total=@tong output
select @tong
go


-- Cau 7
CREATE PROC XemCuaHangMuaNhieuNhat
@Nam int
AS
BEGIN
	SELECT s.Name, SUM(OrderQty * UnitPrice) AS TongTien
	FROM Sales.Store s JOIN Sales.SalesOrderHeader soh ON s.CustomerID = soh.CustomerID
		JOIN Sales.SalesOrderDetail sod ON sod.SalesOrderID = soh.SalesOrderID
	WHERE YEAR(OrderDate) = @Nam
		AND s.CustomerID = (SELECT TOP 1 s.CustomerID
					FROM Sales.Store s JOIN Sales.SalesOrderHeader soh ON s.CustomerID = soh.CustomerID
						JOIN Sales.SalesOrderDetail sod ON sod.SalesOrderID = soh.SalesOrderID
					WHERE YEAR(OrderDate) = @Nam
					GROUP BY s.CustomerID
					ORDER BY SUM(OrderQty * UnitPrice) DESC)
	GROUP BY s.Name
END

EXEC XemCuaHangMuaNhieuNhat 2001
GO

-- Cau 8
CREATE PROC Sp_InsertProduct -- ma tu tang
@Name nvarchar(50), @PN nvarchar(25), @MF bit, @FGF bit, @SSL smallint,
	@RP smallint, @SC smallint, @LP smallint, @DTM int, @PSC int, @SSD datetime --, @ProductID
AS
BEGIN
	-- Neu muon them ma bi IDENTITY_INSERT chan thi co the mo cai nay on, them xong thi off (Khong khuyen khich lam cach nay)
	--SET IDENTITY_INSERT Production.Product ON
	INSERT INTO Production.Product(Name, ProductNumber, MakeFlag, FinishedGoodsFlag, SafetyStockLevel,
			ReorderPoint, StandardCost, ListPrice, DaysToManufacture, ProductSubcategoryID, SellStartDate) --, ProductID)
	VALUES (@Name, @PN, @MF, @FGF, @SSL, @RP, @SC, @LP, @DTM, @PSC, @SSD) --, @ProductID)
	--SET IDENTITY_INSERT Production.Product OFF
END

EXEC Sp_InsertProduct 'abc', 'ahihi', 0, 0, 1000, 750, 0.00, 0.00, 1, 2, '2024-03-22 00:00:00.000'

DELETE FROM Production.Product WHERE ProductID = 1001
GO

-- SCALAR FUNCTION
-- Cau 1
CREATE FUNCTION CountOfEmployees(@MaPB smallint)
RETURNS int
AS
BEGIN
	RETURN (SELECT COUNT(edh.EmployeeID)
			FROM HumanResources.EmployeeDepartmentHistory edh
				JOIN HumanResources.Department d ON edh.DepartmentID = d.DepartmentID
			WHERE d.DepartmentID = @MaPB
			GROUP BY d.DepartmentID)
END
GO

SELECT d.DepartmentID, d.Name, dbo.CountOfEmployees(d.DepartmentID) AS CountOfEmp
FROM HumanResources.EmployeeDepartmentHistory edh
	JOIN HumanResources.Department d ON edh.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentID, d.Name
GO

-- Cau 2
CREATE FUNCTION InventoryProd(@ProductID int, @LocationID smallint)
RETURNS smallint
AS
BEGIN
	RETURN (SELECT Quantity
			FROM Production.ProductInventory
			WHERE ProductID = @ProductID AND LocationID = @LocationID)
END
GO

SELECT ppi.ProductID, ppi.LocationID, dbo.InventoryProd(ppi.ProductID, ppi.LocationID) AS SLTonKho
FROM Production.ProductInventory ppi
GO

-- Cau 3
ALTER FUNCTION SubTotalOfEmp(@EmplID int, @MonthOrder int, @YearOrder int)
RETURNS money
AS
BEGIN
	RETURN (SELECT SUM(SubTotal)
			FROM Sales.SalesOrderHeader
			WHERE SalesPersonID = @EmplID 
				AND YEAR(OrderDate) = @YearOrder
				AND MONTH(OrderDate) = @MonthOrder
			GROUP BY SalesPersonID)
END
GO

SELECT soh.SalesPersonID, MONTH(soh.OrderDate), YEAR(soh.OrderDate), dbo.SubTotalOfEmp(soh.SalesPersonID, MONTH(soh.OrderDate), YEAR(soh.OrderDate)) AS TongDoanhThu
FROM Sales.SalesOrderHeader soh
GROUP BY soh.SalesPersonID, MONTH(soh.OrderDate), YEAR(soh.OrderDate)
ORDER BY MONTH(soh.OrderDate), YEAR(soh.OrderDate)
GO