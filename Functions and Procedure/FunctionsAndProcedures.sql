CREATE PROCEDURE usp_GetEmployeesSalaryAbove35000
AS
	SELECT FirstName, LastName FROM Employees
	WHERE Salary  > 35000
GO

CREATE PROCEDURE usp_GetEmployeesSalaryAboveNumber (@Salary DECIMAL(18, 4))
AS
	SELECT FirstName, LastName FROM Employees
	WHERE Salary >= @Salary
GO

CREATE PROCEDURE usp_GetTownsStartingWith(@Begining VARCHAR(20))
AS
	SELECT [Name] FROM Towns
	WHERE LOWER([Name]) LIKE @Begining + '%'
GO

CREATE PROCEDURE usp_GetEmployeesFromTown (@TownName VARCHAR(20))
AS
	SELECT FirstName, LastName FROM Employees AS e
		JOIN Addresses AS a ON a.AddressID = e.AddressID
		JOIN Towns AS t ON t.TownID = a.TownID
	WHERE t.[Name] = @TownName
GO

CREATE FUNCTION ufn_GetSalaryLevel(@Salary DECIMAL(18,4))
RETURNS VARCHAR(7)
AS
BEGIN
	DECLARE @salaryLevel VARCHAR(7)

	IF(@Salary < 30000)
	BEGIN 
		SET @salaryLevel = 'Low'
	END
	ELSE IF(@Salary <= 50000)
	BEGIN 
		SET @salaryLevel = 'Average'
	END
	ELSE
	BEGIN 
		SET @salaryLevel = 'High'
	END

	RETURN @salaryLevel
END
GO

CREATE PROCEDURE usp_EmployeesBySalaryLevel(@SalaryLevel VARCHAR(7))
AS
	SELECT FirstName, LastName FROM Employees
	WHERE dbo.ufn_GetSalaryLevel(Salary) = @SalaryLevel
GO

CREATE FUNCTION ufn_IsWordComprised(@SetOfLetter VARCHAR(30), @Word VARCHAR(30)) 
RETURNS BIT
AS
BEGIN
	SET @SetOfLetter = LOWER(@SetOfLetter)
	SET @Word = LOWER(@Word)
	DECLARE @result BIT 
	SET @result = 1
	DECLARE @wordLength INT
	SET @wordLength = LEN(@Word)
	DECLARE @index INT
	SET @index = 1
	DECLARE @letter CHAR(1)
	DECLARE @letterIndex INT

	WHILE @index <= @wordLength
	BEGIN
		SET @letter = SUBSTRING(@Word, @index, 1)
		SET @letterIndex = CHARINDEX(@letter, @SetOfLetter)
		IF(@letterIndex <= 0)
		BEGIN
			SET @result = 0
			BREAK
		END
		SET @index+=1
	END

	RETURN @result
END
GO

CREATE PROCEDURE usp_DeleteEmployeesFromDepartment (@DepartmentId INT)
AS
DELETE FROM EmployeesProjects
WHERE EmployeeID IN(SELECT EmployeeID FROM Employees WHERE DepartmentID = @DepartmentId)

ALTER TABLE Departments
ALTER COLUMN ManagerID INT

UPDATE Employees SET ManagerID = NULL
WHERE ManagerID IN (SELECT EmployeeID FROM Employees WHERE DepartmentID = @DepartmentId)

UPDATE Departments SET ManagerID = NULL
WHERE ManagerID IN(SELECT EmployeeID FROM Employees WHERE DepartmentID = @DepartmentId)

DELETE FROM Employees
WHERE DepartmentID = @DepartmentId

DELETE FROM Departments
WHERE DepartmentID = @DepartmentId

SELECT COUNT(EmployeeID) FROM Employees
WHERE DepartmentID = @DepartmentId
GO

CREATE PROCEDURE usp_GetHoldersFullName 
AS
SELECT FirstName + ' ' + LastName FROM AccountHolders AS [Full Name]
GO

CREATE PROCEDURE usp_GetHoldersWithBalanceHigherThan (@Money DECIMAL(18,4))
AS
SELECT FirstName, LastName FROM AccountHolders AS ah
	JOIN Accounts AS a ON a.AccountHolderId = ah.Id
GROUP BY ah.Id, ah.FirstName, ah.LastName
	HAVING SUM(a.Balance) > @Money
ORDER BY FirstName, LastName
GO

CREATE FUNCTION ufn_CalculateFutureValue(@Sum DECIMAL(18, 4), @YearlyIntersetRate FLOAT, @Years INT)
RETURNS DECIMAL(18, 4)
AS
BEGIN 
	RETURN @Sum * POWER((1 + @YearlyIntersetRate), @Years)
END
GO

CREATE PROCEDURE usp_CalculateFutureValueForAccount(@AccountId INT, @InterstRate FLOAT)
AS
	SELECT 
		a.Id, 
		ah.FirstName, 
		ah.LastName,
		a.Balance,
		dbo.ufn_CalculateFutureValue(a.Balance, @InterstRate, 5) AS [Balance in 5 years]
	FROM AccountHolders AS ah
		JOIN Accounts AS a ON a.AccountHolderId = ah.Id
	WHERE a.Id = @AccountId
GO

CREATE FUNCTION ufn_CashInUsersGames(@GameName VARCHAR(20))
RETURNS TABLE
AS
RETURN(
SELECT SUM(InnerTable.Cash) AS SumCash FROM
(SELECT 
	g.[Name], 
	ug.Cash,
	ROW_NUMBER() OVER (ORDER BY ug.Cash DESC) AS RowNumber
	FROM Games AS g
	JOIN UsersGames AS ug ON g.Id = ug.GameId
WHERE g.[Name] = @GameName
) AS InnerTable
WHERE InnerTable.RowNumber % 2 = 1)