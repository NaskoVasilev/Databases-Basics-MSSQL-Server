CREATE TABLE Logs(
	LogId INT PRIMARY KEY IDENTITY,
	AccountId INT,
	OldSum DECIMAL(15, 2),
	NewSum DECIMAL(15, 2)
)
GO

CREATE TRIGGER tr_BalanceChange ON Accounts FOR UPDATE
AS
INSERT INTO Logs(AccountId, OldSum, NewSum)
SELECT a.Id, d.Balance, a.Balance 
FROM Accounts AS a
	JOIN deleted AS d ON d.Id = a.Id
GO

CREATE TABLE NotificationEmails(
	Id INT PRIMARY KEY IDENTITY,
	Recipient INT,
	[Subject] VARCHAR(100),
	Body VARCHAR(250)
)
GO

CREATE OR ALTER TRIGGER tr_AddNotification ON Logs FOR INSERT
AS
INSERT INTO NotificationEmails
SELECT
	AccountId,
	'Balance change for account: ' + CAST(AccountId AS VARCHAR(15)) AS [Subject],
	'On ' + FORMAT(GETDATE(),'MMM dd yyyy h:mm') + 'PM' + ' your balance was changed from '
	 + CAST(OldSum AS VARCHAR(15)) + ' to ' + CAST(NewSum AS VARCHAR(15)) +'.'
FROM inserted
GO

CREATE PROCEDURE usp_DepositMoney (@AccountId INT, @MoneyAmount MONEY)
AS
BEGIN TRANSACTION
	IF(@MoneyAmount <= 0)
	BEGIN
		ROLLBACK
 		RETURN
	END

	UPDATE Accounts SET Balance += @MoneyAmount 
	WHERE Id = @AccountId

	IF @@ROWCOUNT <> 1
	BEGIN
		RAISERROR('Invalid account id!', 16, 2)
		ROLLBACK
		RETURN
	END
	COMMIT
GO

CREATE PROCEDURE usp_WithdrawMoney (@AccountId INT, @MoneyAmount MONEY) 
AS
BEGIN TRANSACTION
	IF(@MoneyAmount <= 0)
	BEGIN
		ROLLBACK
		RETURN
	END

	UPDATE Accounts SET Balance -= @MoneyAmount
	WHERE Id = @AccountId

	IF  @@ROWCOUNT != 1
	BEGIN
		RAISERROR('Invalid account!', 16, 2)
		ROLLBACK
		RETURN
	END

	DECLARE @newBalance MONEY = (SELECT Balance FROM Accounts WHERE Id = @AccountId)

	IF(@newBalance < 0)
	BEGIN
		RAISERROR('Not enough money!', 16, 3)
		ROLLBACK
		RETURN
	END
	COMMIT
GO

CREATE PROCEDURE usp_TransferMoney(@SenderId INT, @ReceiverId INT, @Amount MONEY) 
AS
BEGIN TRANSACTION
	BEGIN TRY
		EXEC usp_WithdrawMoney @SenderId, @Amount
	END TRY
	BEGIN CATCH
		RAISERROR('Not enough money or the id is invalid!', 16, 1)
		ROLLBACK 
		RETURN
	END CATCH

	BEGIN TRY
		EXEC usp_DepositMoney @ReceiverId, @Amount
	END TRY
	BEGIN CATCH
		RAISERROR('The account id is invalid!', 16, 1)
		ROLLBACK 
		RETURN
	END CATCH
	COMMIT
GO


-- Queries for Diablo Database
CREATE TRIGGER tr_UserGameItems ON UserGameItems INSTEAD OF INSERT
AS
	INSERT INTO UserGameItems
	SELECT i.Id, ug.Id FROM inserted
		JOIN Items AS i ON i.Id = inserted.ItemId
		JOIN UsersGames AS ug ON ug.Id = inserted.UserGameId
	WHERE ug.Level >= i.MinLevel
GO

UPDATE UsersGames SET Cash += 50000
FROM UsersGames AS ug
	JOIN Users AS u ON u.Id = ug.UserId
	JOIN Games AS g ON g.Id = ug.GameId
WHERE g.[Name] = 'Bali' AND u.Username IN('baleremuda', 'loosenoise', 'inguinalself', 'buildingdeltoid', 'monoxidecos')
GO

CREATE PROCEDURE usp_BuyItem(@Username VARCHAR(30))
AS
DECLARE @userId INT = (SELECT Id FROM Users WHERE Username = @Username)
DECLARE @gameId INT = (SELECT Id FROM Games WHERE Name = 'Bali')
DECLARE @userGameId INT = (SELECT Id FROM UsersGames WHERE GameId = @gameId AND UserId = @userId)
DECLARE @userGameLevel INT = (SELECT Level FROM UsersGames WHERE Id = @userGameId)
DECLARE @counter INT = 255

WHILE(@counter <= 539)
BEGIN
	DECLARE @userGameCash MONEY = (SELECT Cash FROM UsersGames WHERE Id = @userGameId)
	DECLARE @itemPrice MONEY = (SELECT Price FROM Items WHERE Id = @counter)
	DECLARE @itemLevel INT = (SELECT MinLevel FROM Items WHERE Id = @counter)

	IF(@userGameCash >= @itemPrice AND @itemLevel <= @userGameLevel)
	BEGIN
		UPDATE UsersGames SET Cash -= @itemPrice
		WHERE Id = @userGameId
		INSERT INTO UserGameItems VALUES(@counter, @userGameId)
	END

	SET @counter += 1

	IF(@counter = 300)
	BEGIN
		SET @counter = 501
	END
END
GO

EXECUTE usp_BuyItem 'baleremuda'
EXECUTE usp_BuyItem 'loosenoise'
EXECUTE usp_BuyItem 'inguinalself'
EXECUTE usp_BuyItem 'buildingdeltoid'
EXECUTE usp_BuyItem 'monoxidecos'

SELECT
	u.Username,
	g.[Name],
	ug.Cash,
	i.[Name] 
FROM Users AS u
	JOIN UsersGames AS ug ON ug.UserId = u.Id
	JOIN Games AS g ON g.Id = ug.GameId
	JOIN UserGameItems AS ugi ON ugi.UserGameId = ug.Id
	JOIN Items AS i ON i.Id = ugi.ItemId
WHERE g.[Name] = 'Bali'
ORDER BY u.Username, i.[Name]
GO

--Massive Shopping
DECLARE @userId INT = (SELECT Id FROM Users WHERE Username = 'Stamat')
DECLARE @gameId INT = (SELECT Id FROM Games WHERE Name = 'Safflower')
DECLARE @userGameId INT = (SELECT Id FROM UsersGames WHERE UserId = @userId AND GameId = @gameId)
DECLARE @itemsTotalPrice MONEY = (SELECT SUM(Price) FROM Items WHERE MinLevel BETWEEN 11 AND 12)
DECLARE @userCash MONEY = (SELECT Cash FROM UsersGames WHERE Id = @userGameId)

IF(@userCash >= @itemsTotalPrice)
BEGIN
BEGIN TRANSACTION 
	UPDATE UsersGames SET Cash -= @itemsTotalPrice
	WHERE Id = @userGameId

	INSERT INTO UserGameItems(UserGameId, ItemId)
	SELECT @userGameId, Items.Id FROM Items
	WHERE  MinLevel BETWEEN 11 AND 12

	COMMIT
END

SET @itemsTotalPrice = (SELECT SUM(Price) FROM Items WHERE MinLevel BETWEEN 19 AND 21)
SET @userCash = (SELECT Cash FROM UsersGames WHERE Id = @userGameId)

IF(@userCash >= @itemsTotalPrice)
BEGIN
BEGIN TRANSACTION 
	UPDATE UsersGames SET Cash -= @itemsTotalPrice
	WHERE Id = @userGameId

	INSERT INTO UserGameItems(UserGameId, ItemId)
	SELECT @userGameId, Items.Id FROM Items
	WHERE  MinLevel BETWEEN 11 AND 12

	COMMIT
END

SELECT
	i.[Name] AS [Item Name]
FROM Users AS u
	JOIN UsersGames AS ug ON ug.UserId = u.Id
	JOIN Games AS g ON g.Id = ug.GameId
	JOIN UserGameItems AS ugi ON ugi.UserGameId = ug.Id
	JOIN Items AS i ON i.Id = ugi.ItemId
WHERE u.Username = 'Stamat' AND g.Name = 'Safflower'
ORDER BY [Item Name]
GO

-- SoftUni database
CREATE PROCEDURE usp_AssignProject(@emloyeeId INT, @projectID INT) 
AS
BEGIN
	DECLARE	@employeeProjects INT = (SELECT COUNT(*) FROM EmployeesProjects WHERE EmployeeID = @emloyeeId)
	IF(@employeeProjects >= 3)
	BEGIN
		RAISERROR('The employee has too many projects!', 16, 1)
		RETURN
	END
	INSERT INTO EmployeesProjects(EmployeeID, ProjectID) VALUES(@emloyeeId, @projectID)
END
GO

CREATE TABLE Deleted_Employees(
	EmployeeId INT PRIMARY KEY IDENTITY, 
	FirstName VARCHAR(30), 
	LastName VARCHAR(30), 
	MiddleName VARCHAR(30), 
	JobTitle VARCHAR(30),
    DepartmentId INT, 
	Salary DECIMAL(15, 2)
) 
GO

CREATE TRIGGER tr_DeleteEmployee ON Employees 
FOR DELETE
AS
	INSERT INTO Deleted_Employees(FirstName, LastName, MiddleName, JobTitle, DepartmentId, Salary)
	SELECT FirstName, LastName, MiddleName, JobTitle, DepartmentID, Salary FROM deleted
