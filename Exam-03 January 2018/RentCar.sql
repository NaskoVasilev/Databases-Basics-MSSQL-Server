-- Section 1. DDL (30 pts)
CREATE TABLE Clients(
	Id INT PRIMARY KEY IDENTITY	,
	FirstName VARCHAR(30) NOT NULL,
	LastName VARCHAR(30) NOT NULL,
	Gender CHAR(1) CHECK(Gender IN('M', 'F')) NOT NULL,
	BirthDate DATETIME,
	CreditCard VARCHAR(30) NOT NULL,
	CardValidity DATETIME,
	Email VARCHAR(50) NOT NULL
)

CREATE TABLE Towns(
	Id INT PRIMARY KEY IDENTITY	,
	Name VARCHAR(50) NOT NULL
)

CREATE TABLE Offices(
	Id INT PRIMARY KEY IDENTITY	,
	Name VARCHAR(40),
	ParkingPlaces INT,
	TownId INT FOREIGN KEY REFERENCES Towns(Id) NOT NULL
)

CREATE TABLE Models(
	Id INT PRIMARY KEY IDENTITY,
	Manufacturer VARCHAR(50) NOT NULL,
	Model VARCHAR(50) NOT NULL,
	ProductionYear DATETIME,
	Seats INT,
	Class VARCHAR(10) NOT NULL,
	Consumption DECIMAL(14, 2) 
)

CREATE TABLE Vehicles(
	Id INT PRIMARY KEY IDENTITY,
	ModelId INT FOREIGN KEY REFERENCES Models(Id) NOT NULL,
	OfficeId INT FOREIGN KEY REFERENCES Offices(Id) NOT NULL,
	Mileage INT
)

CREATE TABLE Orders(
	Id INT PRIMARY KEY IDENTITY,
	ClientId INT FOREIGN KEY REFERENCES Clients(Id) NOT NULL,
	TownId INT FOREIGN KEY REFERENCES Towns(Id) NOT NULL,
	VehicleId INT FOREIGN KEY REFERENCES Vehicles(Id) NOT NULL,
	CollectionDate DATETIME NOT NULL,
	CollectionOfficeId INT FOREIGN KEY REFERENCES Offices(Id) NOT NULL,
	ReturnDate DATETIME,
	ReturnOfficeId INT FOREIGN KEY REFERENCES Offices(Id),
	Bill DECIMAL(14, 2),
	TotalMileage INT
)

-- Section 2. DML (10 pts)
-- 2 Insert
INSERT INTO Models VALUES
('Chevrolet', 'Astro', '2005-07-27 00:00:00.000', 4, 'Economy',	12.60),
('Toyota', 'Solara', '2009-10-15 00:00:00.000',	7, 'Family', 13.80),
('Volvo', 'S40', '2010-10-12 00:00:00.000',	3, 'Average', 11.30),
('Suzuki', 'Swift', '2000-02-03 00:00:00.000', 7, 'Economy', 16.20)

INSERT INTO Orders VALUES
(17, 2,	52,	'2017-08-08', 30,	'2017-09-04',  42,	2360.00, 7434),
(78, 17, 50, '2017-04-22', 10,	'2017-05-09',  12,	2326.00, 7326),
(27, 13, 28, '2017-04-25', 21,	'2017-05-09',  34,	597.00, 1880)

-- 3 Update
UPDATE Models SET Class = 'Luxury' WHERE Consumption > 20

-- Delete
DELETE Orders WHERE ReturnDate IS NULL

-- Section 3. Querying (40 pts)
-- 5. Showroom
SELECT Manufacturer, Model FROM Models
ORDER BY Manufacturer, Id DESC

-- 6. Y Generation
SELECT FirstName, LastName FROM Clients
WHERE YEAR(BirthDate) BETWEEN 1977 AND 1994
ORDER BY FirstName, LastName, Id

-- 7. Spacious Office
SELECT Towns.Name, Offices.Name, Offices.ParkingPlaces FROM Offices
	JOIN Towns ON Towns.Id = Offices.TownId
WHERE ParkingPlaces > 25
ORDER BY Towns.Name, Offices.Id

-- 8. Available Vehicles
SELECT m.Model, m.Seats, v.Mileage FROM Vehicles AS v
	JOIN Models AS m ON v.ModelId = m.Id
WHERE v.Id NOT IN(SELECT VehicleId FROM Orders WHERE ReturnDate IS NULL)
ORDER BY v.Mileage,  m.Seats DESC, m.Id

-- 9. Offices per Town
SELECT
	t.Name,
	COUNT(o.Id) AS Offices
FROM Towns AS t
	JOIN Offices AS o ON o.TownId = t.Id
GROUP BY t.Name
ORDER BY Offices DESC, t.Name

-- 10. Buyers Best Choice 
SELECT m.Manufacturer, m.Model, COUNT(o.Id) AS [TimesOrdered] FROM Models AS m
	RIGHT JOIN Vehicles AS v ON m.Id = v.ModelId
	LEFT JOIN Orders AS o ON o.VehicleId = v.Id
GROUP BY m.Model, m.Manufacturer
ORDER BY [TimesOrdered] DESC, m.Manufacturer DESC, m.Model

-- 11. Kinda Person
SELECT Choice.FullName, Choice.Class FROM
(SELECT
	c.FirstName + ' ' + c.LastName AS FullName,
	m.Class,
	c.Id,
	COUNT(o.Id) AS [Count],
	DENSE_RANK() OVER (PARTITION BY c.Id ORDER BY COUNT(o.Id) DESC) AS [Rank]
FROM Clients AS c
	JOIN Orders AS o ON o.ClientId = c.Id
	JOIN Vehicles AS v ON v.Id = o.VehicleId
	JOIN Models AS m ON m.Id = v.ModelId
GROUP BY c.FirstName, c.LastName, m.Class, c.Id
) AS Choice
WHERE [Rank] = 1
ORDER BY Choice.FullName, Choice.Class, Choice.Id

-- 12. Age Groups Revenue
SELECT 
	temp.AgeGroup,
	SUM(temp.Bill) AS Revenue,
	AVG(temp.TotalMileage) AS AverageMileage
FROM 
(SELECT 
	CASE
	WHEN YEAR(c.BirthDate) BETWEEN 1970 AND 1979 THEN '70''s'
	WHEN YEAR(c.BirthDate) BETWEEN 1980 AND 1989 THEN '80''s'
	WHEN YEAR(c.BirthDate) BETWEEN 1990 AND 1999 THEN '90''s'
	ELSE 'Others'
	END AS AgeGroup,
	o.Bill,
	o.TotalMileage
FROM Orders AS o
	JOIN Clients AS c ON c.Id = o.ClientId
) AS temp
GROUP BY temp.AgeGroup
ORDER BY AgeGroup

-- 13. Consumption in Mind
SELECT Manufacturer, AVG(Consumption) AS [AverageConsumption]
FROM
(SELECT TOP(7)
	m.Manufacturer,
	m.Consumption
FROM Models AS m
	JOIN Vehicles AS v ON v.ModelId = m.Id
	JOIN Orders AS o ON o.VehicleId = v.Id
GROUP BY m.Model, m.Manufacturer, m.Consumption
ORDER BY COUNT(o.Id) DESC) AS temp
GROUP BY Manufacturer
	HAVING AVG(Consumption) BETWEEN 5 AND 15
ORDER BY Manufacturer, [AverageConsumption] DESC

-- 14.	Debt Hunter
SELECT [FullName], Email, Bill, Name FROM
(SELECT
	c.Id,
	c.FirstName + ' ' + c.LastName AS [FullName],
	c.Email,
	o.Bill,
	t.[Name],
	ROW_NUMBER() OVER (PARTITION BY t.Name ORDER BY o.Bill DESC) AS [ClientRank]
FROM Clients AS c
	JOIN Orders AS o ON o.ClientId = c.Id
	JOIN Towns AS t ON T.Id = o.TownId
WHERE c.CardValidity < o.CollectionDate) AS temp
WHERE ClientRank IN(1, 2) AND Bill IS NOT NULL
ORDER BY Name, Bill, Id

-- 15.	Town Statistics
SELECT 
	Name,
	IIF(FLOOR(Males * 100 / ClientsCount) = 0, NULL, FLOOR(Males * 100 / ClientsCount)) AS MalePercent,
	IIF(FLOOR((ClientsCount - Males) * 100 / ClientsCount) = 0, NULL, FLOOR((ClientsCount - Males) * 100 / ClientsCount)) AS MalePercent
FROM
(SELECT 
	t.Name,
	t.Id,
	COUNT(c.Id) AS ClientsCount,
	(SELECT COUNT(*) FROM Clients AS nc
		JOIN Orders AS no ON no.ClientId = nc.Id
		JOIN Towns AS nt ON nt.Id = no.TownId
		WHERE nt.Name = t.Name AND nc.Gender = 'M') AS Males
FROM Orders AS o
	JOIN Towns AS t ON t.Id = o.TownId
	JOIN Clients AS c ON c.Id = o.ClientId
GROUP BY t.Name, t.Id) AS temp
ORDER BY Name, Id

-- 16.	Home Sweet Home
WITH CTE_RankedVehicles(OfficeId, ReturnOfficeId, VehicleId, Manufacturer, Model)
AS
(SELECT OfficeId, ReturnOfficeId, Id, Manufacturer, Model FROM
	(SELECT
		DENSE_RANK() OVER(PARTITION BY v.Id ORDER BY o.CollectionDate DESC) AS [VehicleRank],
		v.OfficeId,
		o.ReturnOfficeId,
		v.Id,
		m.Manufacturer,
		m.Model
	FROM Models AS m
		JOIN Vehicles AS v ON v.ModelId = m.Id
		LEFT JOIN Orders AS o ON o.VehicleId = v.Id) AS LatestUsedVehicle
	WHERE [VehicleRank] = 1
)

SELECT
	CONCAT(Manufacturer, ' - ', Model) AS Vehicle,
	CASE
	WHEN (SELECT COUNT(*) FROM Orders WHERE VehicleId = CTE_RankedVehicles.VehicleId) = 0 OR OfficeId = ReturnOfficeId THEN 'home'
	WHEN ReturnOfficeId IS NULL THEN 'on a rent'
	WHEN ReturnOfficeId <> OfficeId THEN (SELECT CONCAT(t.Name, ' - ', o.Name) FROM Offices AS o 
											JOIN Towns AS t ON t.Id = o.TownId
											WHERE o.Id = ReturnOfficeId)
	END AS Location
FROM CTE_RankedVehicles
ORDER BY Vehicle, CTE_RankedVehicles.VehicleId

-- Section 4. Programmability (14 pts)
-- 17.	Find My Ride
CREATE FUNCTION udf_CheckForVehicle(@townName NVARCHAR(50), @seatsNumber INT) 
RETURNS NVARCHAR(100)
AS
BEGIN
	DECLARE @vehicle TABLE(OfficeName  NVARCHAR(50), ModelName  NVARCHAR(50))
	INSERT INTO @vehicle 
	SELECT TOP(1) o.Name, m.Model FROM Vehicles AS v
		JOIN Models AS m ON m.Id = v.ModelId
		JOIN Offices AS o ON o.Id = v.OfficeId
		JOIN Towns AS t ON t.Id = o.TownId
	WHERE t.Name = @townName AND m.Seats = @seatsNumber
	ORDER BY o.Name

	IF((SELECT COUNT(*) FROM @vehicle) = 0)
	BEGIN
		RETURN 'NO SUCH VEHICLE FOUND'
	END

	RETURN (SELECT OfficeName + ' - ' + ModelName FROM @vehicle)
END
GO

-- 18.	Move a Vehicle
CREATE PROCEDURE usp_MoveVehicle(@vehicleId INT, @officeId INT)
AS
BEGIN
	DECLARE @targetOfficeSlots INT = (SELECT ParkingPlaces FROM Offices WHERE Id = @officeId )
	DECLARE @occupiedSlots INT = (SELECT COUNT(*) FROM Vehicles
									JOIN Offices ON Offices.Id = Vehicles.OfficeId AND Offices.Id = @officeId)

	IF(@targetOfficeSlots <= @occupiedSlots)
	BEGIN
		RAISERROR('Not enough room in this office!', 16, 2)
		RETURN
	END

	UPDATE Vehicles SET OfficeId = @officeId
	WHERE Id = @vehicleId
END
GO

-- 19.	Move the Tally
CREATE  TRIGGER tr_OnUdateTotalMilage ON Orders FOR UPDATE
AS
DECLARE @orderId INT = (SELECT Id FROM deleted WHERE TotalMileage IS NULL)
IF(@orderId IS  NULL)
RETURN

DECLARE @mileage INT = (select TotalMileage FROM inserted WHERE Id = @orderId)
DECLARE @vehicleId INT = (select VehicleId FROM inserted WHERE Id = @orderId)
UPDATE Vehicles SET Mileage += @mileage
WHERE Id = @vehicleId