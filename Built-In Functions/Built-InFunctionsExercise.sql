--Queries for SoftUni Database
USE SoftUni

SELECT FirstName, LastName 
FROM Employees
WHERE FirstName LIKE 'Sa%'

SELECT FirstName, LastName 
FROM Employees
WHERE LastName LIKE '%ei%'

SELECT FirstName
FROM Employees
WHERE DepartmentID IN(3, 10)
AND DATEPART(YEAR, HireDate) BETWEEN 1995 AND 2005

SELECT FirstName, LastName 
FROM Employees
WHERE JobTitle NOT LIKE '%engineer%'

SELECT [Name] FROM Towns
WHERE LEN([Name]) BETWEEN 5 AND 6
ORDER BY [Name]

--letters M, K, B or E
SELECT TownID, [Name] FROM Towns
WHERE [Name] LIKE '[MKBE]%'
ORDER BY [Name]

SELECT TownID, [Name] FROM Towns
WHERE [Name] LIKE '[^RBD]%'
ORDER BY [Name]

CREATE VIEW v_EmployeesHiredAfter2000 AS
SELECT FirstName, LastName 
FROM Employees
WHERE YEAR(HireDate) > 2000

SELECT FirstName, LastName 
FROM Employees
WHERE LEN(LastName) = 5

SELECT 
	EmployeeID, 
	FirstName, 
	LastName, 
	Salary,
	DENSE_RANK() OVER (PARTITION BY Salary ORDER BY EmployeeID) AS [Rank]
FROM Employees
WHERE Salary BETWEEN 10000 AND 50000
ORDER BY Salary DESC

SELECT * FROM
(
	SELECT 
		EmployeeID, 
		FirstName, 
		LastName, 
		Salary,
		DENSE_RANK() OVER (PARTITION BY Salary ORDER BY EmployeeID) AS [Rank]
	FROM Employees
	WHERE Salary BETWEEN 10000 AND 50000
) as rankTable
WHERE [Rank] = 2
ORDER BY Salary DESC


--Queries for Geography Database 
USE Geography

SELECT CountryName, IsoCode 
FROM Countries
WHERE LEN(CountryName) - LEN(REPLACE(CountryName, 'A', '')) >= 3
ORDER BY IsoCode

SELECT
    Peaks.PeakName,
    Rivers.RiverName,
	LOWER(Peaks.PeakName + SUBSTRING(Rivers.RiverName, 2 , LEN(Rivers.RiverName))) AS Mix
FROM Peaks
INNER JOIN Rivers
ON SUBSTRING(Peaks.PeakName, LEN(Peaks.PeakName), 1) = LOWER(SUBSTRING(Rivers.RiverName, 1, 1))
ORDER BY Mix


--Queries for Diablo Database
USE Diablo

SELECT TOP(50) 
	[Name], 
	FORMAT([Start], 'yyyy-MM-dd') AS [Start]
FROM Games
WHERE YEAR([Start]) BETWEEN 2011 AND 2012
ORDER BY [Start], [Name]

SELECT 
	Username,
	SUBSTRING(Email, CHARINDEX('@', Email) + 1, LEN(Email)) AS [Email Provider]
FROM Users 
ORDER BY [Email Provider], Username

SELECT 
	Username,
	IpAddress
FROM Users 
WHERE IpAddress LIKE '___.1%.%.___'
ORDER BY Username

SELECT 
	[Name] AS [Game],
	CASE
		WHEN DATEPART(HOUR, [Start]) >= 0 AND  DATEPART(HOUR, [Start]) < 12 THEN 'Morning'
		WHEN DATEPART(HOUR, [Start]) >= 12 AND  DATEPART(HOUR, [Start]) < 18 THEN 'Afternoon'
		WHEN DATEPART(HOUR, [Start]) >= 18 AND  DATEPART(HOUR, [Start]) < 24 THEN 'Evening'
	END AS [Part of the Day],
	CASE 
		WHEN Duration <= 3 THEN 'Extra Short' 
		WHEN Duration BETWEEN 4 AND 6 THEN 'Short' 
		WHEN Duration > 6 THEN 'Long'
		WHEN Duration IS NULL THEN 'Extra Long'
	END AS [Duration]
FROM Games
ORDER BY [Name], Duration, [Part of the Day]

SELECT 
	ProductName, 
	OrderDate ,
	DATEADD(DAY, 3, OrderDate) AS [Pay Due],
	DATEADD(MONTH, 1, OrderDate) AS [Deliver Due]
FROM Orders

CREATE TABLE People(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(30) NOT NULL,
	Birthdate DATETIME NOT NULL
)

INSERT INTO People(Name, Birthdate) VALUES
('Victor', '2000-12-07 00:00:00.000'),
('Steven', '1992-09-10 00:00:00.000'),
('Stephen', '1910-09-19 00:00:00.000'),
('John', '2010-01-06 00:00:00.000')

SELECT 
	[Name],
	DATEDIFF(YEAR, Birthdate, GETDATE()) AS [Age in Years],
	DATEDIFF(MONTH, Birthdate, GETDATE()) AS [Age in Months],
	DATEDIFF(DAY, Birthdate, GETDATE()) AS [Age in Days],
	DATEDIFF(MINUTE, Birthdate, GETDATE()) AS [Age in Minutes]
FROM People