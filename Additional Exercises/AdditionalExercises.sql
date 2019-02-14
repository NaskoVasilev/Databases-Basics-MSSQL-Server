SELECT 
	[Email Provider], 
	COUNT(*) AS [Number Of Users] 
FROM
(SELECT 
	SUBSTRING(Email, CHARINDEX('@', Email) + 1, LEN(Email)) AS [Email Provider]
FROM Users) AS EmailProviders
GROUP BY [Email Provider]
ORDER BY [Number Of Users] DESC, [Email Provider]

SELECT
	g.[Name] AS Game,
	gt.[Name] AS [Game Type],
	u.Username,
	ug.Level,
	ug.Cash,
	c.[Name] AS Charcter
FROM Games AS g
	JOIN UsersGames AS ug ON ug.GameId = g.Id
	JOIN GameTypes AS gt ON gt.Id = g.GameTypeId
	JOIN Users AS u ON u.Id = ug.UserId
	JOIN Characters AS c ON C.Id = ug.CharacterId
ORDER BY ug.Level DESC, u.Username, Game

SELECT  
	u.Username,
	g.[Name],
	COUNT(*) AS [Items Count],
	SUM(i.Price) AS [Items Price]
FROM Items AS i
	JOIN UserGameItems AS ugi ON i.Id = ugi.ItemId
	JOIN UsersGames AS ug ON ugi.UserGameId = ug.Id
	JOIN Users AS u ON u.Id = ug.UserId
	JOIN Games AS g ON g.Id = ug.GameId
GROUP BY u.Username, g.[Name]
	HAVING COUNT(*) >= 10
ORDER BY [Items Count] DESC, [Items Price] DESC, u.Username

SELECT
	u.Username,
	g.[Name] AS [Game],
	MAX(c.[Name]) AS [Character],
	SUM(itemStat.Strength) + MAX(gs.Strength) + MAX(cs.Strength) AS Sterngth,
	SUM(itemStat.Defence) + MAX(gs.Defence) + MAX(cs.Defence) AS Defence,
	SUM(itemStat.Speed) + MAX(gs.Speed) + MAX(cs.Speed) AS Speed,
	SUM(itemStat.Mind) + MAX(gs.Mind) + MAX(cs.Mind) AS Mind,
	SUM(itemStat.Luck) + MAX(gs.Luck) + MAX(cs.Luck) AS Luck
FROM Users AS u
	JOIN UsersGames AS ug ON ug.UserId = u.Id
	JOIN Games AS g ON g.Id = ug.GameId
	JOIN GameTypes AS gt ON gt.Id = g.GameTypeId
	JOIN [Statistics] AS gs ON gs.Id = gt.BonusStatsId
	JOIN Characters AS c ON c.Id = ug.CharacterId
	JOIN [Statistics] AS cs ON cs.Id = c.StatisticId
	JOIN UserGameItems AS ugi ON ugi.UserGameId = ug.Id
	JOIN Items AS i ON i.Id = ugi.ItemId
	JOIN [Statistics] AS itemStat ON itemStat.Id = I.StatisticId
GROUP BY u.Username, g.[Name]
ORDER BY Sterngth DESC, Defence DESC,Speed DESC, Mind DESC, Luck DESC

SELECT
	[Name], [Price], MinLevel, Strength, Defence, Speed, Luck, Mind
FROM Items AS i
	JOIN [Statistics] AS s ON i.StatisticId = s.Id
WHERE s.Luck > (SELECT AVG(Luck) FROM [Statistics])
	AND s.Mind > (SELECT AVG(Mind) FROM [Statistics])
	AND s.Speed > (SELECT AVG(Speed) FROM [Statistics])
ORDER BY [Name]

SELECT
	 i.[Name] AS Item, 
	 i.Price,
	 i.MinLevel,
	 gt.[Name] AS [Forbidden Game Type]  
FROM Items AS i
	LEFT JOIN GameTypeForbiddenItems AS fi ON i.Id = fi.ItemId
	LEFT JOIN GameTypes AS gt ON gt.Id = fi.GameTypeId
ORDER BY [Forbidden Game Type] DESC, i.[Name]

-- Problem 7.	Buy Items for User in Game
DECLARE @userId INT = (SELECT Id FROM Users WHERE Username = 'Alex')
DECLARE @gameId INT = (SELECT Id FROM Games WHERE Name = 'Edinburgh')
DECLARE @userGameId INT = (SELECT Id FROM UsersGames WHERE UserId = @userId AND GameId = @gameId)

UPDATE UsersGames SET Cash -= (SELECT SUM(Price) FROM Items 
WHERE [Name] IN('Blackguard', 'Bottomless Potion of Amplification', 'Eye of Etlich (Diablo III)', 
'Gem of Efficacious Toxin', 'Golden Gorget of Leoric', 'Hellfire Amulet'))
WHERE Id = @userGameId

INSERT INTO UserGameItems(UserGameId, ItemId)
SELECT @userGameId, Id FROM Items WHERE [Name] IN ('Blackguard', 'Bottomless Potion of Amplification', 
'Eye of Etlich (Diablo III)', 'Gem of Efficacious Toxin', 'Golden Gorget of Leoric', 'Hellfire Amulet')


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
WHERE g.[Name] = 'Edinburgh'
ORDER BY i.[Name]

-- PART II – Queries for Geography Database
SELECT 
	p.PeakName, 
	m.MountainRange AS Mountain, 
	p.Elevation 
FROM Peaks AS p
	JOIN Mountains AS m ON p.MountainId = m.Id
ORDER BY p.Elevation DESC, p.PeakName

SELECT 
	p.PeakName, 
	m.MountainRange AS Mountain, 
	c.CountryName,
	con.ContinentName
FROM Peaks AS p
	JOIN Mountains AS m ON p.MountainId = m.Id
	JOIN MountainsCountries AS mc ON mc.MountainId = m.Id
	JOIN Countries AS c ON c.CountryCode = mc.CountryCode
	JOIN Continents AS con ON con.ContinentCode = c.ContinentCode
ORDER BY p.PeakName, c.CountryName

SELECT
	c.CountryName,
	Continents.ContinentName,
	IIF(COUNT(cr.RiverId) IS NULL, 0, COUNT(cr.RiverId))  AS [RiversCount],
	IIF(SUM(r.Length) IS NULL, 0, SUM(r.Length)) AS [TotalLength]
FROM Countries AS c
	JOIN Continents ON Continents.ContinentCode = c.ContinentCode
	LEFT JOIN CountriesRivers AS cr ON cr.CountryCode = c.CountryCode
	LEFT JOIN Rivers AS r ON r.Id = cr.RiverId
GROUP BY Continents.ContinentName, c.CountryName
ORDER BY [RiversCount] DESC, [TotalLength] DESC, c.CountryName

SELECT 
	Currencies.CurrencyCode,
	Currencies.[Description] AS [Currency],
	COUNT(c.CountryCode) AS NumberOfCountries
FROM Countries AS c
	RIGHT JOIN Currencies ON Currencies.CurrencyCode = c.CurrencyCode
GROUP BY Currencies.[Description], Currencies.CurrencyCode
ORDER BY NumberOfCountries DESC, Currencies.[Description]

SELECT 
	c.ContinentName,
	SUM(CAST(Countries.AreaInSqKm AS BIGINT)) AS CountriesArea,
	SUM(CAST(Countries.Population AS BIGINT)) AS CountriesPopulation
FROM Continents AS c
	JOIN Countries ON Countries.ContinentCode = c.ContinentCode
GROUP BY c.ContinentName
ORDER BY CountriesPopulation DESC

CREATE TABLE Monasteries(
	Id INT PRIMARY KEY IDENTITY, 
	[Name] VARCHAR(250) NOT NULL, 
	CountryCode CHAR(2) FOREIGN KEY REFERENCES Countries(CountryCode) NOT NULL
)

INSERT INTO Monasteries([Name], CountryCode) VALUES
('Rila Monastery “St. Ivan of Rila”', 'BG'), 
('Bachkovo Monastery “Virgin Mary”', 'BG'),
('Troyan Monastery “Holy Mother''s Assumption”', 'BG'),
('Kopan Monastery', 'NP'),
('Thrangu Tashi Yangtse Monastery', 'NP'),
('Shechen Tennyi Dargyeling Monastery', 'NP'),
('Benchen Monastery', 'NP'),
('Southern Shaolin Monastery', 'CN'),
('Dabei Monastery', 'CN'),
('Wa Sau Toi', 'CN'),
('Lhunshigyia Monastery', 'CN'),
('Rakya Monastery', 'CN'),
('Monasteries of Meteora', 'GR'),
('The Holy Monastery of Stavronikita', 'GR'),
('Taung Kalat Monastery', 'MM'),
('Pa-Auk Forest Monastery', 'MM'),
('Taktsang Palphug Monastery', 'BT'),
('Sümela Monastery', 'TR')

ALTER TABLE Countries
ADD IsDeleted BIT DEFAULT 0

UPDATE Countries SET IsDeleted = 1
FROM Countries
WHERE (SELECT COUNT(*) FROM CountriesRivers WHERE CountriesRivers.CountryCode = Countries.CountryCode) > 3
	
SELECT m.[Name] AS Monastery, c.CountryName FROM Monasteries AS m
	JOIN Countries AS c ON c.CountryCode = m.CountryCode
WHERE c.IsDeleted = 0
ORDER BY Monastery

UPDATE Countries SET CountryName = 'Burma'
WHERE CountryName = 'Myanmar'

INSERT INTO Monasteries(Name, CountryCode)
SELECT 'Hanga Abbey', CountryCode FROM Countries WHERE CountryName = 'Tanzania'

INSERT INTO Monasteries(Name, CountryCode)
SELECT 'Myin-Tin-Daik', CountryCode FROM Countries WHERE CountryName = 'Myanmar'

SELECT
	Continents.ContinentName,
	c.CountryName,
	COUNT(m.Id) AS MonasteriesCount
FROM Countries AS c
	JOIN Continents ON Continents.ContinentCode = c.ContinentCode
	LEFT JOIN Monasteries AS m ON m.CountryCode = c.CountryCode
WHERE c.IsDeleted = 0
GROUP BY Continents.ContinentName, c.CountryName
ORDER BY MonasteriesCount DESC, c.CountryName