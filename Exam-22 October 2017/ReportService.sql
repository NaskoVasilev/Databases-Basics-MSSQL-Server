-- Section 1. DDL (30 pts)
CREATE TABLE Users(
	Id INT PRIMARY KEY IDENTITY,
	Username NVARCHAR(30) NOT NULL UNIQUE, 
	Password  NVARCHAR(50) NOT NULL,
	Name NVARCHAR(50),
	Gender CHAR(1) CHECK(Gender IN('M', 'F')),
	BirthDate DATETIME,
	Age INT,
	Email NVARCHAR(50) NOT NULL
)

CREATE TABLE Departments(
	Id INT PRIMARY KEY IDENTITY,
	Name NVARCHAR(50) NOT NULL
)

CREATE TABLE Employees(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(25),
	LastName NVARCHAR(25),
	Gender CHAR(1) CHECK(Gender IN('M', 'F')),
	BirthDate DATETIME,
	Age INT,
	DepartmentId INT FOREIGN KEY REFERENCES Departments(Id) NOT NULL
)

CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY,
	Name VARCHAR(50) NOT NULL,
	DepartmentId INT FOREIGN KEY REFERENCES Departments(Id) NOT NULL
)

CREATE TABLE Status(
	Id INT PRIMARY KEY IDENTITY,
	Label VARCHAR(30) NOT NULL
)

CREATE TABLE Reports(
	Id INT PRIMARY KEY IDENTITY,
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
	StatusId INT FOREIGN KEY REFERENCES Status(Id) NOT NULL,
	OpenDate DATETIME NOT NULL,
	CloseDate DATETIME,
	Description VARCHAR(200),
	UserId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id)
)

-- Section 2. DML (10 pts)
-- 2.	Insert
INSERT INTO Employees(FirstName, LastName, Gender, BirthDate, DepartmentId) VALUES
('Marlo', 'O’Malley', 'M', '9/21/1958',	1),
('Niki', 'Stanaghan', 'F', '11/26/1969', 4),
('Ayrton', 'Senna', 'M', '03/21/1960', 9),
('Ronnie', 'Peterson', 'M', '02/14/1944', 9),
('Giovanna', 'Amati', 'F', '07/20/1959', 5)

INSERT INTO Reports(CategoryId, StatusId, OpenDate, CloseDate, Description, UserId, EmployeeId) VALUES
(1, 1, '04/13/2017', NULL, 'Stuck Road on Str.133',	6, 2),
(6,  3, '09/05/2015', '12/06/2015', 'Charity trail running', 3, 5),
(14, 2,	'09/07/2015', NULL, 'Falling bricks on Str.58',	5, 2),
(4,	3, '07/03/2017', '07/06/2017', 'Cut off streetlight on Str.11', 1, 1)

-- 3 Update
UPDATE Reports SET StatusId = 2
WHERE StatusId = 1 AND CategoryId = 4

-- 4 Delete
DELETE FROM Reports WHERE StatusId = 4

-- Section 3. Querying (40 pts)
-- 5.	Users by Age
SELECT Username, Age FROM Users
ORDER BY Age, Username DESC

-- 6.	Unassigned Reports
SELECT Description, OpenDate FROM Reports
WHERE EmployeeId IS NULL
ORDER BY OpenDate, Description

-- 7.	Employees & Reports
SELECT e.FirstName, e.LastName, r.Description, FORMAT(r.OpenDate, 'yyyy-MM-dd') FROM Employees AS e
	JOIN Reports AS r ON r.EmployeeId = e.Id
ORDER BY e.Id, r.OpenDate, r.Id


-- 8.	Most reported Category
SELECT 
	c.Name,
	COUNT(r.Id) AS [ReportsNumber]
FROM Categories AS c
	JOIN Reports AS r ON c.Id = r.CategoryId
GROUP BY c.Id, c.Name
ORDER BY ReportsNumber DESC, c.Name

-- 9.	Employees in Category
SELECT 
	c.Name,
	COUNT(e.Id) AS EmployeesCount
FROM Categories AS c
	LEFT JOIN Departments AS d ON d.Id = c.DepartmentId
	LEFT JOIN Employees AS e ON e.DepartmentId = d.Id
GROUP BY c.Id, c.Name
ORDER BY c.Name

-- 10.	Users per Employee 
SELECT
	e.FirstName + ' ' + e.LastName AS FullName,
	COUNT(r.UserId) AS [Users Number]
FROM Employees AS e
	LEFT JOIN Reports AS r ON r.EmployeeId = e.Id
GROUP BY e.Id, e.FirstName, e.LastName
ORDER BY [Users Number] DESC, FullName

-- 11.	Emergency Patrol
SELECT r.OpenDate, r.Description, u.Email FROM Reports r
	JOIN Categories AS c ON c.Id = r.CategoryId
	JOIN Users AS u ON u.Id = r.UserId
WHERE r.CloseDate IS NULL AND LEN(r.Description) > 20 AND r.Description LIKE '%str%'
AND c.DepartmentId IN(SELECT Id FROM Departments WHERE Name IN('Infrastructure', 'Emergency', 'Roads Maintenance'))
ORDER BY r.OpenDate, u.Email, u.Id

-- 12.	Birthday Report
SELECT DISTINCT c.Name FROM Categories AS c
	JOIN Reports AS r ON r.CategoryId = c.Id
	JOIN Users AS u ON u.Id = r.UserId
WHERE MONTH(u.BirthDate) = MONTH(r.OpenDate) AND DAY(u.BirthDate) = DAY(r.OpenDate)
ORDER BY c.Name

-- 13.	Numbers Coincidence
SELECT Username FROM
(SELECT
	Username,
	Id,
	CASE
	WHEN  Username LIKE '[0-9]%' THEN CONVERT(INT, SUBSTRING(Username, 1, 1))
	WHEN  Username LIKE '%[0-9]' THEN CONVERT(INT, SUBSTRING(Username, LEN(Username) , 1))
	END AS [Digit]
FROM Users
WHERE Username LIKE '[0-9]%' OR Username LIKE '%[0-9]') UsersByDigit
WHERE (SELECT COUNT(*) FROM Reports WHERE UserId = UsersByDigit.Id AND CategoryId = UsersByDigit.Digit) > 0
ORDER BY Username

-- 14.	Open/Closed Statistics
SELECT
	Projects.FullName,
	CONCAT(Projects.ClosedProjets, '/', [AllProjets])
FROM
(SELECT
	e.FirstName + ' ' + e.LastName AS [FullName],
	(SELECT COUNT(*) FROM Reports WHERE EmployeeId = e.Id AND CloseDate IS NOT NULL AND YEAR(OpenDate) <= 2016 AND YEAR(CloseDate) = 2016) AS [ClosedProjets],
	(SELECT COUNT(*) FROM Reports WHERE EmployeeId = e.Id AND YEAR(OpenDate) = 2016) AS [AllProjets]
FROM Employees AS e) AS Projects
WHERE [AllProjets] > 0
ORDER BY FullName

-- 15.	Average Closing Time
SELECT 
	Name,
	CASE 
	WHEN Duration = 0 THEN 'no info'
	ELSE CONVERT(VARCHAR(10), Duration / (SELECT COUNT(*) FROM Reports AS r
						JOIN Categories AS c ON c.Id = r.CategoryId
						JOIN Departments AS d ON d.Id = c.DepartmentId
						WHERE r.CloseDate IS NOT NULL AND d.Id = temp.Id))
	END
FROM
(SELECT
	d.Name,
	d.Id,
	SUM(IIF(CloseDate IS NOT NULL, DATEDIFF(DAY, r.OpenDate, r.CloseDate), 0)) AS Duration
FROM Departments AS d
	JOIN Categories AS c ON c.DepartmentId = d.Id
	JOIN Reports AS r ON r.CategoryId = c.Id
GROUP BY d.Name, d.Id) AS temp
ORDER BY Name

-- 16.	Favorite Categories
SELECT
	DepartmentName,
	CategoryName,
	CONVERT(INT, ROUND(CONVERT(DECIMAL(3, 0), 100) * Reports  / (SELECT COUNT(r.Id) FROM Categories AS c
	JOIN Departments AS d ON d.Id = c.DepartmentId
	JOIN Reports as r on r.CategoryId = c.Id
	WHERE d.Id = ReportsCount.DepartmentId), 0)) AS Percentage
FROM
(SELECT
	d.Id AS DepartmentId,
	d.Name AS DepartmentName,
	c.Id as CategoryId,
	c.Name AS CategoryName,
	COUNT(r.Id) AS Reports
FROM Departments AS d 
	JOIN Categories AS c ON c.DepartmentId = d.Id
	JOIN Reports AS r ON r.CategoryId = c.Id
GROUP BY c.Id, c.Name, d.Id, d.Name) AS ReportsCount
ORDER BY DepartmentName, CategoryName, Percentage
GO

-- Section 4. Programmability (14 pts)
-- 17.	Employee’s Load
CREATE FUNCTION udf_GetReportsCount(@employeeId INT, @statusId INT) 
RETURNS INT
AS
BEGIN
	RETURN (SELECT COUNT(Id) FROM Reports 
			WHERE EmployeeId = @employeeId AND StatusId = @statusId)
END
GO

-- 18.	Assign Employee
CREATE PROCEDURE usp_AssignEmployeeToReport(@employeeId INT, @reportId INT)
AS
BEGIN
	DECLARE @employeeDepartmentId INT = (SELECT DepartmentId FROM Employees WHERE Id = @employeeId)
	DECLARE @reportDepartmentId INT = (SELECT c.DepartmentId FROM Reports AS r
										JOIN Categories AS c ON c.Id = r.CategoryId 
										WHERE r.Id = @reportId)

	IF(@employeeDepartmentId <> @reportDepartmentId)
	BEGIN
		RAISERROR('Employee doesn''t belong to the appropriate department!', 16, 1)
	END

	UPDATE Reports SET EmployeeId = @employeeId
	WHERE Id = @reportId
END
GO

--Create a trigger which changes the StatusId to “completed” of each report after a CloseDate is entered for the report.
CREATE TRIGGER tr_CompleteProject ON Reports FOR UPDATE
AS
    DECLARE @oldCloseDate DATETIME = (SELECT TOP(1) CloseDate FROM deleted)
    DECLARE @newCloseDate DATETIME = (SELECT TOP(1) CloseDate FROM inserted)
	DECLARE @reportId INT = (SELECT TOP(1) Id FROM inserted)

	IF(@oldCloseDate = @newCloseDate OR @newCloseDate IS NULL)
	RETURN

	UPDATE Reports SET StatusId = (SELECT Id FROM Status WHERE Label = 'completed')
	WHERE Id = @reportId
GO

-- 20.	Categories Revision
SELECT 
	c.Name,
	COUNT(r.Id) AS ReportsNumber,
	CASE 
	WHEN InProgressCount > WaitingCount THEN 'in progress'
	WHEN InProgressCount < WaitingCount THEN 'waiting'
	ELSE 'equal'
	END AS MainStatus
FROM Categories AS c
	JOIN Reports AS r ON r.CategoryId = c.Id
	JOIN Status AS s ON s.Id = r.StatusId
	JOIN(SELECT 
			ir.CategoryId,
			SUM(CASE WHEN ins.Label = 'waiting' THEN 1 ELSE 0 END) AS WaitingCount,
			SUM(CASE WHEN ins.Label = 'in progress' THEN 1 ELSE 0 END) AS InProgressCount
		FROM Reports AS ir
			JOIN Status AS ins ON ir.StatusId = ins.Id
		WHERE ins.Label IN('waiting', 'in progress')
		GROUP BY ir.CategoryId) AS cs ON cs.CategoryId = c.Id
WHERE s.Label IN('waiting', 'in progress')
GROUP BY c.Name, 
	CASE 
	WHEN InProgressCount > WaitingCount THEN 'in progress'
	WHEN InProgressCount < WaitingCount THEN 'waiting'
    ELSE 'equal' END
ORDER BY c.Name, ReportsNumber, MainStatus