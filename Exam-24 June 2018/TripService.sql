-- Section 1. DDL (30 pts)
CREATE TABLE Cities(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(20) NOT NULL,
	CountryCode CHAR(2) NOT NULL
)

CREATE TABLE Hotels(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(30) NOT NULL,
	CityId INT FOREIGN KEY REFERENCES Cities(Id) NOT NULL,
	EmployeeCount INT NOT NULL,
	BaseRate DECIMAL(15, 2)
)

CREATE TABLE Rooms(
	Id INT PRIMARY KEY IDENTITY,
	Price DECIMAL(15, 2) NOT NULL,
	[Type] NVARCHAR(20) NOT NULL,
	Beds INT NOT NULL,
	HotelId INT FOREIGN KEY REFERENCES Hotels(Id) NOT NULL
)

CREATE TABLE Trips(
	Id INT PRIMARY KEY IDENTITY,
	RoomId INT FOREIGN KEY REFERENCES Rooms(Id) NOT NULL,
	BookDate DATE NOT NULL,
	ArrivalDate DATE NOT NULL,
	ReturnDate DATE NOT NULL,
	CancelDate DATE,
	CONSTRAINT CHK_Trips_BookDate CHECK(BookDate < ArrivalDate),
	CONSTRAINT CHK_Trips_ArivalDate CHECK(ArrivalDate < ReturnDate)
)

CREATE TABLE Accounts(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(50) NOT NULL,
	MiddleName NVARCHAR(20),
	LastName NVARCHAR(50) NOT NULL,
	CityId INT FOREIGN KEY REFERENCES Cities(Id) NOT NULL,
	BirthDate DATE NOT NULL,
	Email VARCHAR(100) NOT NULL UNIQUE
)

CREATE TABLE AccountsTrips(
	AccountId INT FOREIGN KEY REFERENCES Accounts(Id) NOT NULL,
	TripId INT FOREIGN KEY REFERENCES Trips(Id) NOT NULL,
	Luggage INT NOT NULL,
	CONSTRAINT CHK_AccountsTrips_Luggage CHECK(Luggage >= 0),
	CONSTRAINT PK_AccountsTrips PRIMARY KEY(AccountId, TripId)
)

-- Section 2. DML (10 pts)
INSERT INTO Accounts VALUES
('John', 'Smith', 'Smith', 34, '1975-07-21', 'j_smith@gmail.com'),
('Gosho', NULL, 'Petrov',	11, '1978-05-16', 'g_petrov@gmail.com'),
('Ivan', 'Petrovich', 'Pavlov', 59, '1849-09-26', 'i_pavlov@softuni.bg'),
('Friedrich', 'Wilhelm', 'Nietzsche', 2, '1844-10-15', 'f_nietzsche@softuni.bg')

INSERT INTO Trips VALUES
(101, '2015-04-12', '2015-04-14', '2015-04-20', '2015-02-02'),
(102, '2015-07-07', '2015-07-15', '2015-07-22', '2015-04-29'),
(103, '2013-07-17', '2013-07-23', '2013-07-24', NULL),
(104, '2012-03-17', '2012-03-31', '2012-04-01', '2012-01-10'),
(109, '2017-08-07', '2017-08-28', '2017-08-29', NULL)
UPDATE Rooms SET Price *= 1.14 WHERE HotelId IN(5, 7, 9)
		 
DELETE AccountsTrips WHERE AccountId = 47

-- Section 3. Querying (40 pts)
-- 5. Bulgarian Cities
SELECT Id, [Name] FROM Cities
WHERE CountryCode = 'BG'
ORDER BY [Name]

-- 6. People Born After 1991
SELECT 
	FirstName  + ISNULL(' ' + MiddleName, '') + ' ' + LastName AS [FullName],
	YEAR(BirthDate) AS [BirthYear]
FROM Accounts
WHERE YEAR(BirthDate) > 1991
ORDER BY BirthYear DESC, FirstName

-- 7. EEE-Mails
SELECT FirstName, LastName, FORMAT(BirthDate, 'MM-dd-yyyy'), c.Name, Email FROM Accounts
JOIN Cities AS c ON c.Id = Accounts.CityId
WHERE Email LIKE 'e%'
ORDER BY c.Name DESC

-- 8. City Statistics
SELECT  
	c.[Name] AS [City],
	COUNT(h.Id) AS [HotelsCount]
FROM Cities AS c
	LEFT JOIN Hotels AS h ON h.CityId = c.Id
GROUP BY c.[Name]
ORDER BY [HotelsCount] DESC, City

-- 9. Expensive First-Class Rooms
SELECT 
	Rooms.Id, 
	Price, 
	h.[Name] AS Hotel, 
	c.[Name] AS [City] 
FROM Rooms
	JOIN Hotels AS h ON h.Id = Rooms.HotelId
	JOIN Cities AS c ON c.Id = h.CityId
WHERE [Type] = 'First Class'
ORDER BY Price DESC, Rooms.Id

-- 10. Longest and Shortest Trips
SELECT
	a.Id,
	a.FirstName + ' ' + a.LastName AS [FullName],
	MAX(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate)) AS LongestTrip,
	MIN(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate)) AS ShortestTrip
FROM Accounts AS a
	JOIN AccountsTrips ON AccountsTrips.AccountId = A.Id
	JOIN Trips AS t ON t.Id = AccountsTrips.TripId
WHERE a.MiddleName IS NULL AND t.CancelDate IS NULL
GROUP BY a.Id, a.FirstName, a.LastName
ORDER BY LongestTrip DESC, a.Id

-- 11. Metropolis
SELECT TOP(5)
	c.Id,
	c.[Name] AS [City],
	c.CountryCode,
	COUNT(a.Id) AS Accounts
FROM Cities AS c
	JOIN Accounts AS a ON a.CityId = c.Id
GROUP BY c.[Name], c.Id, c.CountryCode
ORDER BY Accounts DESC

-- 12. Romantic Getaways
SELECT
	a.Id,
	a.Email,
	c.[Name],
	COUNT(t.Id) AS Trips
FROM Accounts AS a
	JOIN AccountsTrips ON AccountsTrips.AccountId = A.Id
	JOIN Trips AS t ON  t.Id = AccountsTrips.TripId
	JOIN Rooms AS r ON r.Id = t.RoomId
	JOIN Hotels AS h ON h.Id = r.HotelId
	JOIN Cities AS c ON c.Id = h.CityId
WHERE h.CityId = a.CityId
GROUP BY a.Id, a.Email, c.[Name]
ORDER BY Trips DESC, a.Id

-- 13. Lucrative Destinations
SELECT TOP(10)
	c.Id,
	c.[Name], 
	SUM(r.Price + h.BaseRate) AS [Total Revenue],
	COUNT(t.Id) AS [Trips]
FROM Cities AS c
	JOIN Hotels AS h ON h.CityId = c.Id
	JOIN Rooms AS r ON r.HotelId = h.Id
	JOIN Trips AS t ON t.RoomId = r.Id
WHERE YEAR(t.BookDate) = 2016
GROUP BY c.[Name], c.Id
ORDER BY [Total Revenue] DESC, [Trips] DESC