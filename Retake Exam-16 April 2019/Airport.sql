-- Section 1. DDL (30 pts)
-- 30/30 points
CREATE TABLE Planes(
	Id INT PRIMARY KEY IDENTITY	,
	[Name] VARCHAR(30) NOT NULL,
	Seats INt NOT NULL,
	[Range] INT NOT NULL
)

CREATE TABLE Flights(
	Id INT PRIMARY KEY IDENTITY	,
	DepartureTime DATETIME,
	ArrivalTime DATETIME,
	Origin VARCHAR(50) NOT NULL,
	Destination VARCHAR(50) NOT NULL,
	PlaneId INT FOREIGN KEY REFERENCES Planes(Id) NOT NULL
)

CREATE TABLE Passengers(
	Id INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(30) NOT NULL,
	LastName VARCHAR(30) NOT NULL,
	Age INT NOT NULL,
	Address VARCHAR(30) NOT NULL,
	PassportId CHAR(11) NOT NULL,
)

CREATE TABLE LuggageTypes(
	Id INT PRIMARY KEY IDENTITY	,
	[Type] VARCHAR(30) NOT NULL,
)

CREATE TABLE Luggages(
	Id INT PRIMARY KEY IDENTITY	,
	LuggageTypeId INT FOREIGN KEY REFERENCES LuggageTypes(Id) NOT NULL,
	PassengerId INT FOREIGN KEY REFERENCES Passengers(Id) NOT NULL
)

CREATE TABLE Tickets(
	Id INT PRIMARY KEY IDENTITY	,
	PassengerId INT FOREIGN KEY REFERENCES Passengers(Id) NOT NULL,
	FlightId INT FOREIGN KEY REFERENCES Flights(Id) NOT NULL,
	LuggageId INT FOREIGN KEY REFERENCES Luggages(Id) NOT NULL,
	Price DECIMAL(18, 2) NOT NULL
)

-- Section 2. DML (10 pts)
-- Insert
-- 3/3 points
INSERT INTO Planes(Name, Seats, Range) VALUES
('Airbus 336', 112, 5132),
('Airbus 330', 432, 5325),
('Boeing 369', 231, 2355),
('Stelt 297', 254, 2143),
('Boeing 338', 165, 5111),
('Airbus 558', 387, 1342),
('Boeing 128', 345, 5541)

INSERT INTO LuggageTypes(Type) VALUES
('Crossbody Bag'),
('School Backpack'),
('Shoulder Bag')

-- Update
-- 3/3 points
UPDATE Tickets SET Price*=1.13 WHERE FlightId = 41

-- Delete
-- 4/4 points
DELETE Tickets WHERE FlightId IN (SELECT Id FROM Flights WHERE Destination = 'Ayn Halagim')
DELETE Flights WHERE Destination = 'Ayn Halagim'

-- Section 3. Querying (40 pts)
-- 5. Trips - 2/2 points
SELECT Origin, Destination FROM Flights
ORDER BY Origin, Destination

-- 6. The "Tr" Planes - 2/2 points 
SELECT * FROM Planes
WHERE Name LIKE '%tr%'
ORDER BY Id, Name, Seats, Range

-- 7. Flight Profits - 2/2 points
SELECT FlightId, SUM(Price) AS	Price FROM Tickets
GROUP BY FlightId
ORDER BY Price DESC, FlightId 

-- 8.	Passengers and Prices - 2/2 points
SELECT TOP(10) p.FirstName, p.LastName, t.Price AS Price FROM Passengers AS p
	JOIN Tickets AS t ON t.PassengerId = p.Id
ORDER BY Price DESC, FirstName , LastName

-- 9. Most Used Luggage's - points 3/3
SELECT lt.Type, COUNT(l.Id) AS MostUsedLuggage FROM LuggageTypes AS lt
	JOIN Luggages AS l  ON l.LuggageTypeId = lt.Id
GROUP BY lt.Type
ORDER BY MostUsedLuggage DESC, Type

-- 10. Passenger Trips - 2/2 points
SELECT  
	p.FirstName + ' ' + p.LastName AS FullName,
	f.Origin,
	f.Destination
FROM Passengers AS p 
	JOIN Tickets AS t ON t.PassengerId = p.Id
	JOIN Flights AS f ON f.Id = t.FlightId
ORDER BY FullName, Origin, Destination

-- 11. Non Adventures People - 2/2 points
SELECT Passengers.FirstName, Passengers.LastName, Passengers.Age FROM Passengers
	LEFT JOIN Tickets ON Tickets.PassengerId = Passengers.Id
WHERE Tickets.Id IS NULL
GROUP BY Passengers.FirstName, Passengers.LastName, Passengers.Age
ORDER BY Passengers.Age DESC, Passengers.FirstName, Passengers.LastName

-- 12. Lost Luggage's - 3/3 points
SELECT p.PassportId, p.Address FROM Passengers AS p
	LEFT JOIN Luggages AS l ON l.PassengerId = p.Id
WHERE l.Id IS NULL
GROUP BY p.PassportId, p.Address
ORDER BY p.PassportId, p.Address

-- 13. Count of Trips - points 3/3
SELECT p.FirstName, p.LastName, COUNT(t.Id) AS Trips FROM Passengers AS p
	LEFT JOIN Tickets AS t ON t.PassengerId = p.Id
GROUP BY p.FirstName, p.LastName
ORDER BY Trips DESC, p.FirstName, p.LastName

-- 14. Full Info - 4/4 points
SELECT
	p.FirstName + ' ' + p.LastName AS FullName,
	Planes.Name,
	f.Origin + ' - ' + f.Destination AS [Trip],
	lt.Type
FROM Passengers AS p
	JOIN Tickets AS t ON t.PassengerId = p.Id
	JOIN Flights AS f ON f.Id = t.FlightId
	JOIN Planes ON Planes.Id = f.PlaneId
	JOIN Luggages AS l ON l.Id = t.LuggageId
	JOIN LuggageTypes AS lt ON lt.Id = l.LuggageTypeId
ORDER BY FullName, Planes.Name, f.Origin, f.Destination, lt.Type

-- 15. Most Expensive Trips - points 6/6
SELECT
	p.FirstName,
	p.LastName,
	(SELECT TOP(1) Destination FROM Flights AS f
	JOIN Tickets AS t ON t.FlightId = f.Id
	WHERE t.PassengerId = p.Id
	ORDER BY t.Price DESC) AS Destination,
	MAX(t.Price) AS Price
FROM Passengers AS p
	JOIN Tickets AS t ON t.PassengerId = p.Id
	JOIN Flights AS f ON f.Id = t.FlightId
GROUP BY p.FirstName, p.LastName, p.Id
ORDER BY Price DESC,  p.FirstName, p.LastName, Destination
	
-- 16. Destinations Info - 4/4 points
SELECT
	f.Destination,
	COUNT(t.Id) AS Trips
FROM Flights AS f
	LEFT JOIN Tickets AS t ON t.FlightId = f.Id
GROUP BY f.Destination
ORDER BY Trips DESC, f.Destination

-- 17. PSP - points - 5/5
SELECT
	p.Name,
	p.Seats,
	COUNT(t.Id) AS PassengersCount
FROM Planes AS p
	LEFT JOIN Flights AS f ON f.PlaneId = p.Id
	LEFT JOIN Tickets AS t ON t.FlightId = f.Id
GROUP BY p.Id, p.Name, p.Seats
ORDER BY PassengersCount DESC, p.Name, p.Seats 
GO
-- Section 4. Programmability (20 pts)
-- 18.	Vacation - points - 8/8
CREATE FUNCTION udf_CalculateTickets(@origin VARCHAR(30), @destination VARCHAR(30), @peopleCount INT)
RETURNS VARCHAR(MAX)
AS 
BEGIN
	IF(@peopleCount <= 0)
	BEGIN
		RETURN 'Invalid people count!'
	END

	DECLARE @id INT = (SELECT TOP(1) Id FROM Flights WHERE Origin = @origin AND Destination = @destination)
	IF(@id IS NULL)
	BEGIN
		RETURN 'Invalid flight!'
	END

	DECLARE @price DECIMAL(18, 2) = (SELECT TOP(1) Price FROM Tickets WHERE FlightId = @id)
	RETURN 'Total price ' + CAST(@price * @peopleCount AS VARCHAR(MAX))
END
GO

-- 19. Wrong Data - points - 7/7
CREATE PROCEDURE usp_CancelFlights
AS 
BEGIN
	UPDATE Flights SET DepartureTime = NULL, ArrivalTime = NULL
	WHERE  DATEDIFF(Second, DepartureTime, ArrivalTime) > 0
END

CREATE TABLE DeletedPlanes(	
	Id INT NOT NULL,
	[Name] VARCHAR(30) NOT NULL,
	Seats INt NOT NULL,
	[Range] INT NOT NULL
)

-- 20. Deleted Planes - points - 5/5
CREATE TRIGGER tr_OnDeletePlane ON Planes AFTER DELETE
AS
	INSERT INTO DeletedPlanes(Id, Name, Seats, Range)
	SELECT Id, Name, Seats, Range FROM deleted