--*************************************************************************--
-- Title: Assignment08
-- Author: SivathanuM
-- Desc: This file demonstrates how to use Stored Procedures
-- Change Log: When,Who,What
-- 2021-03-07,SivathanuM,Created and tested Insert procedures 
-- 2021-03-08,SivathanuM,Created and tested Update procedures 
-- 2021-03-09,SivathanuM,Created and tested Delete procedures 
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment08DB_SivathanuM')
	 Begin 
	  Alter Database [Assignment08DB_SivathanuM] set Single_user With Rollback Immediate;
	  Drop Database Assignment08DB_SivathanuM;
	 End
	Create Database Assignment08DB_SivathanuM;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment08DB_SivathanuM;
Go

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
,[UnitPrice] [money] NOT NULL
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
-- NOTE: We are starting without data this time!

-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, [Count] From dbo.Inventories;
go

/********************************* Questions and Answers *********************************/
-- NOTE:Use the following template to create your stored procedures and plan on this taking ~2-3 hours

-- Question 1 (20 pts): How can you create Insert, Update, and Delete Transactions Store Procedures  
-- for the Categories table?
Create or Alter Procedure pInsCategories (@CategoryName nvarchar(100))
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	Insert Into Categories (CategoryName) Values (@CategoryName);
	-- Transaction Code -- 
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
Go


--Create Procedure pUpdCategories
--< Place Your Code Here!>--
Create or Alter Procedure pUpdCategories 
	(@CategoryID int 
	 ,@CategoryName nvarchar(100) ) 
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	Update Categories Set CategoryName = @CategoryName where CategoryID = @CategoryID;
	If(@@ROWCOUNT > 1) RaisError('Do not change more than one row!', 15,1);	
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
Go

--Create Procedure pDelCategories
Create or Alter Procedure pDelCategories 
	(@CategoryID int 
	)
 AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	Delete from Categories where CategoryID = @CategoryID;
	If(@@ROWCOUNT > 1) RaisError('Do not Delete more than one row!', 15,1);	
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
Go


-- Question 2 (20 pts): How can you create Insert, Update, and Delete Transactions Store Procedures  
-- for the Products table?
--Create Procedure pInsProducts
Create or Alter Procedure pInsProducts 
	(@ProductName nvarchar(100)
	,@CategoryID int
	,@UnitPrice money)
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	Insert Into Products (ProductName,CategoryID,UnitPrice) Values (@ProductName,@CategoryID,@UnitPrice); 
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
Go

--Create Procedure pUpdProducts
Create or Alter Procedure pUpdProducts 
	(@ProductID int 
	,@ProductName nvarchar(100)
	,@CategoryID int 
	,@UnitPrice DECIMAL(5,2))
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	Update Products Set ProductName=@ProductName , CategoryID=@CategoryID , UnitPrice=@UnitPrice where ProductID = @ProductID;
	If(@@ROWCOUNT > 1) RaisError('Do not change more than one row!', 15,1);	
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
Go


--Create Procedure pDelProducts
Create or Alter Procedure pDelProducts 
	(@ProductID int 
	)
 AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	Delete from Products where ProductID = @ProductID;
	If(@@ROWCOUNT > 1) RaisError('Do not Delete more than one row!', 15,1);	
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
Go


-- Question 3 (20 pts): How can you create Insert, Update, and Delete Transactions Store Procedures  
-- for the Employees table?
--Create Procedure pInsEmployees
Create or Alter Procedure pInsEmployees 
	(@EmployeeFirstName varchar(100)
	,@EmployeeLastName varchar(100)
	,@ManagerID int)
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	Insert Into Employees (EmployeeFirstName,EmployeeLastName,ManagerID) Values (@EmployeeFirstName,@EmployeeLastName,@ManagerID); 
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
Go

--Create Procedure pUpdEmployees
Create or Alter Procedure pUpdEmployees
	(@EmployeeID int
	,@EmployeeFirstName varchar(100)
	,@EmployeeLastName varchar(100)
	,@ManagerID int)
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	Update Employees Set EmployeeFirstName=@EmployeeFirstName , EmployeeLastName=@EmployeeLastName , ManagerID=@ManagerID where EmployeeID = @EmployeeID;
	If(@@ROWCOUNT > 1) RaisError('Do not change more than one row!', 15,1);	
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
Go

--Create Procedure pDelEmployees
Create or Alter Procedure pDelEmployees 
	(@EmployeeID int 
	)
 AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	Delete from Employees where EmployeeID = @EmployeeID;
	If(@@ROWCOUNT > 1) RaisError('Do not Delete more than one row!', 15,1);	
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
Go

-- Question 4 (20 pts): How can you create Insert, Update, and Delete Transactions Store Procedures  
-- for the Inventories table?
--Create Procedure pInsInventories
Create or Alter Procedure pInsInventories 
	(@InventoryDate date
	,@EmployeeID int
	,@ProductID int
	,@Count int)
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	Insert Into Inventories (InventoryDate,EmployeeID,ProductID,[Count]) Values (@InventoryDate,@EmployeeID,@ProductID,@Count); 
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
Go

--Create Procedure pUpdInventories
Create or Alter Procedure pUpdInventories
	(@InventoryID int
	,@InventoryDate date
	,@EmployeeID int
	,@ProductID int
	,@Count int)
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	Update Inventories Set InventoryDate=@InventoryDate,EmployeeID=@EmployeeID,ProductID=@ProductID,[Count]=@Count
		where InventoryID=@InventoryID;
	If(@@ROWCOUNT > 1) RaisError('Do not change more than one row!', 15,1);	
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
Go

--Create Procedure pDelInventories
Create or Alter Procedure pDelInventories
	(@InventoryID int 
	)
 AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	Delete from Inventories where InventoryID = @InventoryID;
	If(@@ROWCOUNT > 1) RaisError('Do not Delete more than one row!', 15,1);	
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
Go

-- Question 5 (20 pts): How can you Execute each of your Insert, Update, and Delete stored procedures? 
-- Include custom messages to indicate the status of each sproc's execution.

-- To Help you, I am providing this template:
/*
Declare @Status int;
Exec @Status = <SprocName>
                @ParameterName = 'A'
Select Case @Status
  When +1 Then '<TableName> Insert was successful!'
  When -1 Then '<TableName> Insert failed! Common Issues: Duplicate Data'
  End as [Status];
Select * From <ViewName> Where ColID = 1;
go
*/


--< Test Insert Sprocs >--
-- Test [dbo].[pInsCategories]
Declare @Status int;
Exec @Status = pInsCategories @CategoryName='A';               
Select Case @Status
  When +1 Then 'Categories Insert was successful!'
  When -1 Then 'Categories Insert failed! Common Issues: Duplicate Data'
  End as [Status];
Select * From vCategories Where CategoryID = @@IDENTITY;
Go


-- Test [dbo].[pInsProducts]
Declare @Status int;
Exec @Status = pInsProducts 
	@ProductName='A'
	,@CategoryID=1
	,@UnitPrice=9.99
	;               
Select Case @Status
  When +1 Then 'Products Insert was successful!'
  When -1 Then 'Products Insert failed! Common Issues: Duplicate Data'
  End as [Status];
Select ProductID,ProductName,CategoryID,cast(UnitPrice as DECIMAL(4,2)) From vProducts Where ProductID = @@IDENTITY;
Go

-- Test [dbo].[pInsEmployees]
Declare @Status int;
Exec @Status = pInsEmployees 
	@EmployeeFirstName='Abe'
	,@EmployeeLastName='Archer'
	,@ManagerID=1
	;               
Select Case @Status
  When +1 Then 'Employees Insert was successful!'
  When -1 Then 'Employees Insert failed! Common Issues: Duplicate Data'
  End as [Status];
Select * From vEmployees Where EmployeeID = @@IDENTITY;
Go
-- Test [dbo].[pInsInventories]
Declare @Status int;
Exec @Status = pInsInventories 
	@InventoryDate='2017-01-01'
	,@EmployeeID=1
	,@Count=42
	,@ProductID=1
	;               
Select Case @Status
  When +1 Then 'Inventories Insert was successful!'
  When -1 Then 'Inventories Insert failed! Common Issues: Duplicate Data'
  End as [Status];
Select * From vInventories Where InventoryID = @@IDENTITY;
Go

--< Test Update Sprocs >--
Declare @Status int;
Exec @Status = pUpdCategories 
	@CategoryID=1
	,@CategoryName='B' ;               
Select Case @Status
  When +1 Then 'Categories Update was successful!'
  When -1 Then 'Categories Update failed! Common Issues: Duplicate Data'
  End as [Status];
Select * From vCategories Where CategoryID = 1;
Go


-- Test [dbo].[pUpdProducts]
Declare @Status int;
Exec @Status = pUpdProducts 
	@ProductID=1
	,@ProductName='B'
	,@CategoryID=1	
	,@UnitPrice=$1 ;               
Select Case @Status
  When +1 Then 'Products Update was successful!'
  When -1 Then 'Products Update failed! Common Issues: Duplicate Data'
  End as [Status];
Select ProductID,ProductName,CategoryID,cast(UnitPrice as DECIMAL(4,2)) From vProducts Where ProductID = 1;
Go

-- Test [dbo].[pUpdEmployees]
Declare @Status int;
Exec @Status = pUpdEmployees
	@EmployeeID=1
	,@EmployeeFirstName='Abe'
	,@EmployeeLastName='Arch'
	,@ManagerID=1
	;
Select Case @Status
  When +1 Then 'Employees Update was successful!'
  When -1 Then 'Employees Update failed! Common Issues: Duplicate Data'
  End as [Status];
Select * From vEmployees Where EmployeeID = 1;
Go

-- Test [dbo].[pUpdInventories]
Declare @Status int;
Exec @Status = pUpdInventories
	@InventoryID=1
	,@InventoryDate='2017-01-02'
	,@EmployeeID=1
	,@ProductID=1
	,@Count=43
	;
Select Case @Status
  When +1 Then 'Inventories Update was successful!'
  When -1 Then 'Inventories Update failed! Common Issues: Duplicate Data'
  End as [Status];
Select * From vInventories Where InventoryID = 1;
Go

--< Test Delete Sprocs >--
-- Test [dbo].[pDelInventories]
Declare @Status int;
Exec @Status = pDelInventories
                @InventoryID = @@IDENTITY
Select Case @Status
  When +1 Then 'Inventories Delete was successful!'
  When -1 Then 'Inventories Delete failed! Common Issues: Foreign Key Violation'
  End as [Status]; -- Will be Null unless we add a Return Code to this Sproc!
Select * From vInventories Where InventoryID = @@IDENTITY;
go


-- Test [dbo].[pDelEmployees]
Declare @Status int;
Exec @Status = pDelEmployees
                @EmployeeID = @@IDENTITY
Select Case @Status
  When +1 Then 'Employees Delete was successful!'
  When -1 Then 'Employees Delete failed! Common Issues: Foreign Key Violation'
  End as [Status]; -- Will be Null unless we add a Return Code to this Sproc!
Select * From vEmployees Where EmployeeID = @@IDENTITY;
go

-- Test [dbo].[pDelProducts]
Declare @Status int;
Exec @Status = pDelProducts
                @ProductID = @@IDENTITY
Select Case @Status
  When +1 Then 'Products Delete was successful!'
  When -1 Then 'Products Delete failed! Common Issues: Foreign Key Violation'
  End as [Status]; -- Will be Null unless we add a Return Code to this Sproc!
Select * From vProducts Where ProductID = @@IDENTITY;
go

-- Test [dbo].[pDelCategories]
Declare @Status int;
Exec @Status = pDelCategories
                @CategoryId = @@IDENTITY
Select Case @Status
  When +1 Then 'Categories Delete was successful!'
  When -1 Then 'Categories Delete failed! Common Issues: Foreign Key Violation'
  End as [Status]; -- Will be Null unless we add a Return Code to this Sproc!
Select * From vCategories Where CategoryID = @@IDENTITY;
go

--{ IMPORTANT!!! }--
-- To get full credit, your script must run without having to highlight individual statements!!!  

/***************************************************************************************/