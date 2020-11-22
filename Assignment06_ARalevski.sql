--*************************************************************************--
-- Title: Assignment06
-- Author: ARalevski
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2020-11-20,ARalevski,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_ARalevski')
	 Begin 
	  Alter Database [Assignment06DB_ARalevski] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_ARalevski;
	 End
	Create Database Assignment06DB_ARalevski;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_ARalevski;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5 pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

Go
Create --Drop
View vCategories
With SCHEMABINDING
AS
    SELECT
    CategoryID
    ,CategoryName
    From dbo.Categories;
go

Create --Drop
View vProducts
With SCHEMABINDING
AS
    SELECT
    ProductID
    ,ProductName
    ,CategoryID
    ,UnitPrice
    From dbo.Products;
go

Create --Drop
View vEmployees
With SCHEMABINDING
AS
    SELECT
    EmployeeID
    ,EmployeeFirstName
    ,EmployeeLastName
    ,ManagerID
    From dbo.Employees;
go

Create --Drop
View vInventories
With SCHEMABINDING
AS
    SELECT
    InventoryID
    ,InventoryDate
    ,EmployeeID
    ,ProductID
    ,[Count]
    From dbo.Inventories;
go

-- Question 2 (5 pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Use Assignment06DB_ARalevski
Deny Select Categories to Public;
Grant Select on vCategories to Public;

Deny Select Products to Public;
Grant Select on vProducts to Public;

Deny Select Employees to Public;
Grant Select on vEmployees to Public;

Deny Select Inventories to Public;
Grant Select on vInventories to Public;


-- Question 3 (10 pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00

Go
Create View vProductsByCategories
AS
Select TOP 10000000
    CategoryName, ProductName, UnitPrice
    From Categories Join Products
    On Categories.CategoryID = Products.CategoryID
Order By UnitPrice
GO
Select * From vProductsByCategories;
go


-- Question 4 (10 pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83

Go
Create View vInventoriesByProductsByDates
AS
Select TOP 10000000
    ProductName, [Count], InventoryDate
    From Inventories Join Products
    On Inventories.ProductID = Products.ProductID
Order By ProductName, InventoryDate, [Count]
GO
Select * From vInventoriesByProductsByDates;
go

-- Question 5 (10 pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth

Go
Create View vInventoriesByEmployeesByDates
With SCHEMABINDING
AS
Select TOP 10000000
    InventoryDate, [EmployeeName] = EmployeeFirstName +' '+ EmployeeLastName
From dbo.Inventories Join dbo.Employees
    On Inventories.EmployeeID = Employees.EmployeeID
Group By InventoryDate, EmployeeFirstName +' '+ EmployeeLastName
Order By InventoryDate
Select * From dbo.vInventoriesByEmployeesByDates;
go


-- Question 6 (10 pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54

Go
Create View vInventoriesByProductsByCategories
With SCHEMABINDING
AS
Select TOP 10000000
    CategoryName, ProductName, InventoryDate, [Count]
	From dbo.Categories 
	Join dbo.Products
    On Categories.CategoryID = Products.CategoryID
	Join dbo.Inventories
	On Products.ProductID = Inventories.ProductID
Order By CategoryName, ProductName, InventoryDate, [Count]
go
Select * From dbo.vInventoriesByProductsByCategories;
go

-- Question 7 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan

Create View vInventoriesByProductsByEmployees
With SCHEMABINDING
AS
Select TOP 10000000
    CategoryName, ProductName, InventoryDate, [Count], [EmployeeName] = EmployeeFirstName +' '+ EmployeeLastName
	From dbo.Categories 
	Join dbo.Products
    On Categories.CategoryID = Products.CategoryID
	Join dbo.Inventories
	On Products.ProductID = Inventories.ProductID
	Join dbo.Employees
	On Inventories.EmployeeID = Employees.EmployeeID
Order By InventoryDate, CategoryName, ProductName, [EmployeeName]
GO
Select * From vInventoriesByProductsByEmployees;
go

-- Question 8 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King

Create View vInventoriesForChaiAndChangByEmployees
With SCHEMABINDING
AS
Select TOP 10000000
    CategoryName, ProductName, InventoryDate, [Count], [EmployeeName] = EmployeeFirstName +' '+ EmployeeLastName
	From dbo.Categories 
	Join dbo.Products
    On Categories.CategoryID = Products.CategoryID
	Join dbo.Inventories
	On Products.ProductID = Inventories.ProductID
	Join dbo.Employees
	On Inventories.EmployeeID = Employees.EmployeeID
	Where ProductName IN
		(Select ProductName
		from dbo.Products
		Where ProductName = 'Chai'
		or ProductName = 'Chang')
Order By InventoryDate, CategoryName, ProductName
go
Select * From vInventoriesForChaiAndChangByEmployees;
go
-- Question 9 (10 pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan

Create View vEmployeesByManager
With SCHEMABINDING
AS
Select TOP 10000000
[Manager] = Mgr.EmployeeFirstName +' '+ Mgr.EmployeeLastName,
[Employee] = Emp.EmployeeFirstName +' '+ Emp.EmployeeLastName
 From dbo.Employees as Emp 
  Inner Join dbo.Employees as Mgr
   On Emp.ManagerID = Mgr.EmployeeID
 Order By [Manager];   
go
Select * From vEmployeesByManager;
go

-- Question 10 (10 pts): How can you create one view to show all the data from all four 
-- BASIC Views?

-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan

Create View vInventoriesByProductsByCategoriesByEmployees
With SCHEMABINDING
AS
Select
c.CategoryID,CategoryName,
p.ProductID,ProductName,UnitPrice,
InventoryID,InventoryDate,[Count],
e.EmployeeID,[Employee] = e.EmployeeFirstName +' '+ e.EmployeeLastName,[Manager] = Mgr.EmployeeFirstName +' '+ Mgr.EmployeeLastName
From dbo.Categories as c
	Join dbo.Products as p
    On c.CategoryID = p.CategoryID
	Join dbo.Inventories as i
	On p.ProductID = i.ProductID
	Join dbo.Employees as e
	On i.EmployeeID = e.EmployeeID
    Inner Join dbo.Employees as Mgr
   On e.ManagerID = Mgr.EmployeeID
go
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]
go

-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]
/***************************************************************************************/