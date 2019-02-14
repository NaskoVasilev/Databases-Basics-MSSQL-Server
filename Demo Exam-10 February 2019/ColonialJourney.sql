-- Section 1. DDL (30 pts)
CREATE TABLE Planets(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) NOT NULL
)

CREATE TABLE Spaceports(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	PlanetId INT FOREIGN KEY REFERENCES Planets(Id) NOT NULL
)

CREATE TABLE Spaceships(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	Manufacturer VARCHAR(30) NOT NULL,
	LightSpeedRate INT DEFAULT 0
)

CREATE TABLE Colonists(
	Id INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(20) NOT NULL,
	LastName VARCHAR(20) NOT NULL,
	Ucn VARCHAR(10) UNIQUE NOT NULL,
	BirthDate DATE NOT NULL
)

CREATE TABLE Journeys(
	Id INT PRIMARY KEY IDENTITY,
	JourneyStart DATETIME NOT NULL,
	JourneyEnd DATETIME NOT NULL,
	Purpose VARCHAR(11) CHECK (Purpose IN ('Medical', 'Technical', 'Educational', 'Military')),
	DestinationSpaceportId INT FOREIGN KEY REFERENCES Spaceports(Id) NOT NULL,
	SpaceshipId INT FOREIGN KEY REFERENCES Spaceships(Id) NOT NULL
)

CREATE TABLE TravelCards(
	Id INT PRIMARY KEY IDENTITY,
	CardNumber CHAR(10) UNIQUE NOT  NULL,
	JobDuringJourney VARCHAR(8) CHECK(JobDuringJourney IN('Pilot', 'Engineer', 'Trooper', 'Cleaner', 'Cook')),
	ColonistId INT FOREIGN KEY REFERENCES Colonists(Id) NOT NULL,
	JourneyId INT FOREIGN KEY REFERENCES Journeys(Id) NOT NULL
)

 -- Section 2. DML (10 pts)
 INSERT INTO Planets VALUES
('Mars'),
('Earth'),
('Jupiter'),
('Saturn')

INSERT INTO Spaceships VALUES
('Golf', 'VW', 3),
('WakaWaka', 'Wakanda',	4),
('Falcon9',	'SpaceX', 1),
('Bed',	'Vidolov', 6)

UPDATE Spaceships SET LightSpeedRate += 1
WHERE Id BETWEEN 8 AND 12

DELETE FROM TravelCards WHERE JourneyId IN(1, 2, 3)
DELETE FROM Journeys WHERE Id IN(1, 2, 3)

-- Section 3. Querying (40 pts)
-- 5. Select all travel cards
SELECT CardNumber, JobDuringJourney FROM TravelCards
ORDER BY CardNumber

-- 6. Select all colonists
SELECT Id, FirstName + ' ' + LastName AS [FullName], Ucn FROM Colonists
ORDER BY FirstName, LastName, Id

-- 7. Select all military journeys
SELECT 
	Id, 
	FORMAT(JourneyStart, 'dd/MM/yyyy') AS JourneyStart, 
	FORMAT(JourneyEnd, 'dd/MM/yyyy') AS JourneyEnd
FROM Journeys
WHERE Purpose = 'Military'
ORDER BY JourneyStart

-- 8. Select all pilots
SELECT c.Id, c.FirstName + ' ' + c.LastName AS [FullName] FROM Colonists AS c
	JOIN TravelCards AS tr ON tr.ColonistId = c.Id
WHERE tr.JobDuringJourney = 'Pilot'
ORDER BY c.Id

-- 9. Count colonists
SELECT COUNT(c.Id) AS [COUNT] FROM Colonists AS c
	JOIN TravelCards AS tr ON tr.ColonistId = c.Id
	JOIN Journeys AS j ON j.Id = tr.JourneyId
WHERE j.Purpose = 'Technical'

-- 10. Select the fastest spaceship
SELECT TOP(1) 
	Spaceships.[Name] AS SpaceshipName,
	Spaceports.[Name] AS SpaceportName
FROM Spaceships
	JOIN Journeys ON Journeys.SpaceshipId = Spaceships.Id
	JOIN Spaceports ON Spaceports.Id = Journeys.DestinationSpaceportId
ORDER BY Spaceships.LightSpeedRate DESC

-- 11. Select spaceships with pilots younger than 30 years
SELECT DISTINCT s.[Name], s.Manufacturer FROM Spaceships AS s
	JOIN Journeys AS j ON j.SpaceshipId = s.Id
	JOIN TravelCards AS tc ON tc.JourneyId = j.Id
	JOIN Colonists AS c ON c.Id = tc.ColonistId
WHERE DATEDIFF(YEAR, c.BirthDate, '01/01/2019') < 30 AND tc.JobDuringJourney = 'Pilot'
ORDER BY s.[Name]

-- 12. Select all educational mission planets and spaceports
SELECT
	p.[Name] AS PlanetName,
	s.[Name] AS [SpaceportName]
FROM Planets AS p
	JOIN Spaceports AS s ON p.Id = s.PlanetId
	JOIN Journeys AS j ON s.Id = j.DestinationSpaceportId
WHERE j.Purpose = 'Educational'
ORDER BY s.[Name] DESC

-- 13. Select all planets and their journey count
SELECT
	p.[Name] AS PlanetName,
	COUNT(j.Id) AS [JourneysCount]
FROM Planets AS p
	JOIN Spaceports AS s ON p.Id = s.PlanetId
	JOIN Journeys AS j ON s.Id = j.DestinationSpaceportId
GROUP BY p.[Name] 
ORDER BY JourneysCount DESC, p.[Name]

-- 14. Select the shortest journey
SELECT TOP(1)
	j.Id,
	p.[Name] AS PlanetName,
	s.[Name] AS SpaceportName,
	j.Purpose AS JourneyPurpose
FROM Planets AS p
	JOIN Spaceports AS s ON p.Id = s.PlanetId
	JOIN Journeys AS j ON s.Id = j.DestinationSpaceportId
ORDER BY DATEDIFF(SECOND, j.JourneyStart, j.JourneyEnd)

-- 15. Select the less popular job
SELECT TOP(1)
	j.Id,
	tc.JobDuringJourney
FROM Journeys AS j
	JOIN  TravelCards AS tc ON tc.JourneyId = j.Id
WHERE j.Id = (SELECT TOP(1) Id FROM Journeys
	ORDER BY DATEDIFF(SECOND, JourneyStart, JourneyEnd) DESC)
GROUP BY tc.JobDuringJourney, j.Id
ORDER BY COUNT(tc.Id)

-- 16. Select Second Oldest Important Colonist
SELECT * FROM
(SELECT 
	tr.JobDuringJourney, 
	c.FirstName + ' ' + c.LastName AS [FullName],
	RANK() OVER(PARTITION BY tr.JobDuringJourney ORDER BY c.BirthDate) AS [Rank]
FROM Colonists AS c
	JOIN TravelCards AS tr ON tr.ColonistId = c.Id
	JOIN Journeys AS j ON j.Id = tr.JourneyId) AS RankedColinists
WHERE [Rank] = 2

-- 17. Planets and Spaceports
SELECT 
	p.[Name],
	COUNT(s.Id) AS [Count]
FROM Planets AS p
	LEFT JOIN Spaceports AS s ON s.PlanetId = p.Id
GROUP BY p.[Name]
ORDER BY [Count] DESC, p.[Name]

-- Section 4. Programmability (20 pts)
CREATE FUNCTION udf_GetColonistsCount(@PlanetName VARCHAR (30)) 
RETURNS INT
AS
BEGIN
	RETURN (SELECT COUNT(c.Id) FROM Planets AS p
		JOIN Spaceports AS s ON s.PlanetId = p.Id
		JOIN Journeys AS j ON j.DestinationSpaceportId = s.Id
		JOIN TravelCards AS tc ON tc.JourneyId = j.Id
		JOIN Colonists AS c ON c.Id = tc.ColonistId
	WHERE p.[Name] = @PlanetName)
END
GO

-- 19. Change Journey Purpose
CREATE PROCEDURE usp_ChangeJourneyPurpose(@JourneyId INT, @NewPurpose VARCHAR(11))
AS
BEGIN
	BEGIN TRANSACTION
	DECLARE @journeyPurpose VARCHAR(11)  = (SELECT Purpose FROM Journeys WHERE Id = @JourneyId)
	IF(@journeyPurpose IS NULL)
	BEGIN
		ROLLBACK
		RAISERROR('The journey does not exist!', 16, 1)
		RETURN
	END

	IF(@NewPurpose = @journeyPurpose)
	BEGIN
		ROLLBACK
		RAISERROR('You cannot change the purpose!', 16, 2)
		RETURN
	END

	UPDATE Journeys SET Purpose = @NewPurpose WHERE Id = @JourneyId
	COMMIT
END
GO

-- 20. Deleted Journeys
CREATE TABLE DeletedJourneys(
	Id INT PRIMARY KEY,	
	JourneyStart DATETIME NOT NULL, 
	JourneyEnd DATETIME NOT NULL, 
	Purpose VARCHAR(11) CHECK (Purpose IN ('Medical', 'Technical', 'Educational', 'Military')), 
	DestinationSpaceportId INT NOT NULL, 
	SpaceshipId INT NOT NULL
) 
GO

CREATE TRIGGER TR_OnJourneyDelete ON Journeys FOR DELETE
AS
	INSERT INTO DeletedJourneys
	SELECT * FROM deleted