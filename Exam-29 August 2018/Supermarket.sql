-- Section 1. DDL (30 pts)
CREATE TABLE Categories (
	Id INT PRIMARY KEY IDENTITY,
	[Name]  NVARCHAR(30) NOT NULL
)

CREATE TABLE Items (
	Id INT PRIMARY KEY IDENTITY,
	[Name]  NVARCHAR(30) NOT NULL,
	Price DECIMAL(15, 2) NOT NULL,
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL
)

CREATE TABLE Employees (
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	Phone CHAR(12) NOT NULL,
	Salary DECIMAL(15, 2) NOT NULL
)

CREATE TABLE Orders (
	Id INT PRIMARY KEY IDENTITY,
	[DateTime] DATETIME NOT NULL,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL
)

CREATE TABLE OrderItems(
	OrderId INT FOREIGN KEY REFERENCES Orders(Id) NOT NULL,
	ItemId INT FOREIGN KEY REFERENCES Items(Id) NOT NULL,
	Quantity INT CHECK(Quantity >= 1) NOT NULL
	CONSTRAINT PK_OrederItems PRIMARY KEY(OrderId, ItemId)
)

CREATE TABLE Shifts (
	Id INT IDENTITY NOT NULL,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL,
	CheckIn DATETIME NOT NULL,
	CheckOut DATETIME NOT NULL
	CONSTRAINT PK_Shifts PRIMARY KEY(Id, EmployeeId)
)

ALTER TABLE Shifts
ADD CONSTRAINT CH_CheckIn_CheckOut_Shifts CHECK(CheckIn < CheckOut)

-- Section 2. DML (10 pts)
INSERT INTO Employees(FirstName, LastName, Phone, Salary) VALUES
('Stoyan', 'Petrov', '888-785-8573', 500.25),
('Stamat', 'Nikolov', '789-613-1122', 999995.25),
('Evgeni', 'Petkov', '645-369-9517', 1234.51),
('Krasimir', 'Vidolov', '321-471-9982', 50.25)

INSERT INTO Items(Name, Price, CategoryId) VALUES
('Tesla battery', 154.25, 8),
('Chess', 30.25, 8),
('Juice', 5.32,	1),
('Glasses',	10, 8),
('Bottle of water',	1, 1)

UPDATE Items SET Price *= 1.27
WHERE CategoryId IN(1, 2, 3)

DELETE FROM OrderItems WHERE OrderId = 48
DELETE FROM Orders WHERE Id = 48

-- Section 3. Querying (40 pts)
SELECT Id, FirstName FROM Employees
WHERE Salary > 6500
ORDER BY FirstName, Id

SELECT 
	CONCAT(FirstName, ' ', LastName) AS [FullName],
	Phone AS [Phone Number]
FROM Employees
WHERE Phone LIKE '3%'
ORDER BY FirstName, Phone

SELECT 
	e.FirstName,
	e.LastName,
	COUNT(e.Id) AS [Count]
FROM Employees AS e
	JOIN Orders AS o ON o.EmployeeId = e.Id
GROUP BY e.Id, e.FirstName, e.LastName
ORDER BY [Count] DESC, e.FirstName

SELECT
	e.FirstName,
	e.LastName,
	AVG(DATEDIFF(HOUR, s.CheckIn, s.CheckOut)) AS [Work hours]
FROM Employees AS e
	JOIN Shifts AS s ON s.EmployeeId = e.Id
GROUP BY e.Id, e.FirstName, e.LastName
	HAVING AVG(DATEDIFF(HOUR, s.CheckIn, s.CheckOut)) > 7
ORDER BY [Work hours] DESC,	e.Id

SELECT TOP(1)
	oi.OrderId,
	SUM(oi.Quantity * i.Price) AS [TotalPrice]
FROM OrderItems AS oi
	JOIN Items AS i ON i.Id = oi.ItemId
GROUP BY oi.OrderId
ORDER BY [TotalPrice] DESC

SELECT TOP(10)
	oi.OrderId,
	MAX(i.Price) AS [ExpensivePrice],
	MIN(i.Price) AS [CheapPrice]
FROM OrderItems AS oi
	JOIN Items AS i ON i.Id = oi.ItemId
GROUP BY oi.OrderId
ORDER BY [ExpensivePrice] DESC, oi.OrderId

SELECT DISTINCT e.Id, e.FirstName, e.LastName FROM Employees AS e
	JOIN Orders AS o ON o.EmployeeId = e.Id
ORDER BY e.Id

SELECT DISTINCT e.Id, e.FirstName + ' ' + e.LastName AS [FullName]
FROM Employees AS e
	JOIN Shifts AS s ON s.EmployeeId = e.Id
WHERE DATEDIFF(HOUR, s.CheckIn, s.CheckOut) < 4 
ORDER BY e.Id

SELECT TOP(10)
	e.FirstName + ' ' + e.LastName AS [Full Name],
	SUM(i.Price * oi.Quantity) AS [Total Price],
	SUM(oi.Quantity) AS [Items Count]
FROM Employees AS e
	JOIN Orders AS o ON e.Id = o.EmployeeId
	JOIN OrderItems AS oi ON oi.OrderId = o.Id
	JOIN Items AS i ON i.Id = oi.ItemId
WHERE o.DateTime < '2018-06-15'
GROUP BY e.Id, e.FirstName, e.LastName
ORDER BY [Total Price] DESC, [Items Count] DESC

SELECT
	CONCAT(e.FirstName, ' ', e.LastName) AS [FullName],
	DATENAME(WEEKDAY, s.CheckIn) AS [Day of week]
FROM Employees AS e
	JOIN Shifts AS s ON e.Id = s.EmployeeId
	LEFT JOIN Orders AS o ON o.EmployeeId = e.Id
WHERE o.Id IS NULL AND DATEDIFF(HOUR, s.CheckIn, s.CheckOut) > 12
ORDER BY e.Id

SELECT
	BestOrders.FullName,
	DATEDIFF(HOUR, s.CheckIn, s.CheckOut) AS [WorkHours],
	BestOrders.TotalPrice
FROM 
(SELECT
	e.Id,
	o.[DateTime],
	CONCAT(e.FirstName, ' ', e.LastName) AS [FullName],
	SUM(i.Price * oi.Quantity) AS [TotalPrice],
	ROW_NUMBER() OVER (PARTITION BY e.id ORDER BY SUM(i.Price * oi.Quantity) DESC) AS [Rank]
FROM Employees AS e
	JOIN Orders AS o ON e.Id = o.EmployeeId
	JOIN OrderItems AS oi ON oi.OrderId = o.Id
	JOIN Items AS i ON i.Id = oi.ItemId
GROUP BY e.Id, e.LastName, e.FirstName, o.Id, o.[DateTime]) AS BestOrders
	JOIN Shifts AS s ON s.EmployeeId = BestOrders.Id
WHERE BestOrders.[Rank] = 1 AND BestOrders.[DateTime] BETWEEN s.CheckIn AND s.CheckOut
ORDER BY FullName, WorkHours DESC, TotalPrice DESC

SELECT 
	DATEPART(DAY, o.[DateTime]) AS [Day],
	FORMAT(AVG(i.Price * oi.Quantity), 'N2') AS [TotalProfit]
FROM Orders AS o
	JOIN OrderItems AS oi ON o.Id = oi.OrderId
	JOIN Items AS i ON I.Id = OI.ItemId
GROUP BY DATEPART(DAY, o.[DateTime])
ORDER BY [Day]

SELECT
	i.[Name] AS [Item],
	c.[Name] AS [Category],
	SUM(oi.Quantity) AS [Count],
	SUM(oi.Quantity * i.Price) AS [TotalPrice]
FROM Items AS i
	LEFT JOIN OrderItems AS oi ON oi.ItemId = i.Id
	JOIN Categories AS c ON c.Id = i.CategoryId
GROUP BY i.[Name], c.[Name]
ORDER BY [TotalPrice] DESC, [Count] DESC
GO

-- Section 4. Programmability (20 pts)
CREATE FUNCTION udf_GetPromotedProducts(@CurrentDate DATETIME, @StartDate DATETIME, @EndDate DATETIME, @Discount INT, @FirstItemId INT, @SecondItemId INT, @ThirdItemId INT)
RETURNS NVARCHAR(250)
AS
BEGIN
	DECLARE @firstItemName NVARCHAR(30) = (SELECT [Name] FROM Items WHERE Id = @FirstItemId)
	DECLARE @secondItemName NVARCHAR(30) = (SELECT [Name] FROM Items WHERE Id = @SecondItemId)
	DECLARE @thirdItemName NVARCHAR(30) = (SELECT [Name] FROM Items WHERE Id = @ThirdItemId)

	IF(@firstItemName IS NULL OR @secondItemName IS NULL OR @thirdItemName IS NULL)
	BEGIN 
		RETURN 'One of the items does not exists!' 
	END

	IF(@CurrentDate NOT BETWEEN @StartDate AND @EndDate)
	BEGIN
		RETURN 'The current date is not within the promotion dates!'
	END

	DECLARE @firstItemPrice DECIMAL(15, 2) = (SELECT Price FROM Items WHERE Id = @FirstItemId)
	DECLARE @secondItemPrice DECIMAL(15, 2) = (SELECT Price FROM Items WHERE Id = @SecondItemId)
	DECLARE @thirdItemPrice DECIMAL(15, 2) = (SELECT Price FROM Items WHERE Id = @ThirdItemId)
	DECLARE @multiplier DECIMAL(15, 2) = @discount / CAST(100 AS DECIMAL(15, 2))
	DECLARE @firstItemNewPrice DECIMAL(15, 2) = @firstItemPrice - @firstItemPrice * @multiplier
	DECLARE @secondItemNewPrice DECIMAL(15, 2) = @secondItemPrice - @secondItemPrice * @multiplier
	DECLARE @thirdItemNewPrice DECIMAL(15, 2) = @thirdItemPrice - @thirdItemPrice * @multiplier

	RETURN CONCAT(@firstItemName, ' price: ', CAST(@firstItemNewPrice AS VARCHAR(20)), ' <-> ', @secondItemName, ' price: ',CAST(@secondItemNewPrice AS VARCHAR(20)),' <-> ', @thirdItemName, ' price: ',  CAST(@thirdItemNewPrice AS VARCHAR(20)))
END
GO

CREATE PROCEDURE usp_CancelOrder(@OrderId INT, @CancelDate DATETIME)
AS
BEGIN
BEGIN TRANSACTION
	DECLARE @orderDate DATETIME = (SELECT [DateTime] FROM Orders WHERE Id = @OrderId)

	IF(@orderDate IS NULL)
	BEGIN
		ROLLBACK
		RAISERROR('The order does not exist!', 16, 1)
		RETURN
	END

	IF(DATEDIFF(DAY, @orderDate, @CancelDate) > 3)
	BEGIN
		ROLLBACK
		RAISERROR('You cannot cancel the order!', 16, 2)
		RETURN
	END

	DELETE FROM OrderItems WHERE OrderId = @OrderId
	DELETE FROM Orders WHERE Id = @OrderId
	COMMIT
END
GO

CREATE TABLE DeletedOrders (
	OrderId INT, 
	ItemId INT, 
	ItemQuantity INT
)

CREATE TRIGGER tr_AfterDelete ON OrderItems FOR DELETE
AS
	INSERT INTO DeletedOrders(OrderId, ItemId, ItemQuantity)
	SELECT OrderId, ItemId, Quantity FROM deleted