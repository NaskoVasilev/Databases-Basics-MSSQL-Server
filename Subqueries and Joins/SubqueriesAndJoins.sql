SELECT TOP(5) 
	e.EmployeeID,	
	e.JobTitle, 
	a.AddressID, 
	a.AddressText 
FROM Employees AS e
	JOIN Addresses AS a ON a.AddressID = e.AddressID
ORDER BY e.AddressID

SELECT TOP(50)
	e.FirstName,
	e.LastName, 
	t.Name AS Town, 
	a.AddressText 
FROM Employees AS e
	JOIN Addresses AS a ON a.AddressID = e.AddressID
	JOIN Towns AS t ON t.TownID = a.TownID
ORDER BY FirstName, LastName

SELECT
	e.EmployeeID,
	e.FirstName, 
	e.LastName,
	d.Name AS DepartmentName
FROM Employees AS e
	JOIN Departments AS d ON d.DepartmentID = e.DepartmentID
WHERE d.Name = 'Sales'
ORDER BY E.EmployeeID

SELECT TOP(5)
	e.EmployeeID,
	e.FirstName, 
	e.Salary,
	d.[Name] AS DepartmentName
FROM Employees AS e
	JOIN Departments AS d ON d.DepartmentID = e.DepartmentID
WHERE e.Salary > 15000
ORDER BY e.DepartmentID

SELECT TOP(3) 
	e.EmployeeID, e.FirstName 
FROM Employees AS e
	LEFT JOIN EmployeesProjects AS ep ON ep.EmployeeID = e.EmployeeID
WHERE ep.ProjectID IS NULL

SELECT
	e.FirstName,
	e.LastName,
	e.HireDate,
	d.[Name] as DeptName
FROM Employees AS e
	JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
WHERE e.HireDate > '1.1.1999' AND d.[Name] IN('Sales', 'Finance')
ORDER BY e.HireDate
    
SELECT TOP(5)
	e.EmployeeID,
	e.FirstName,
	p.[Name] AS ProjectName
FROM Employees AS e
	JOIN EmployeesProjects AS ep ON ep.EmployeeID = e.EmployeeID
	JOIN Projects AS p ON p.ProjectID = ep.ProjectID
WHERE p.StartDate > CONVERT(smalldatetime, '13.08.2002', 103) AND p.EndDate IS NULL
ORDER BY e.EmployeeID

SELECT
	e.EmployeeID,
	e.FirstName,
	IIF(YEAR(p.StartDate) >= 2005, NULL, p.Name) AS ProjectName
FROM Employees AS e
	JOIN EmployeesProjects AS ep ON ep.EmployeeID = e.EmployeeID
	JOIN Projects AS p ON p.ProjectID = ep.ProjectID
WHERE e.EmployeeID = 24

SELECT
	e.EmployeeID,
	e.FirstName,
	m.EmployeeID,
	m.FirstName
FROM Employees AS e
	JOIN Employees AS m ON m.EmployeeID = e.ManagerID
WHERE m.EmployeeID IN(3, 7)
ORDER BY e.EmployeeID

SELECT TOP(50)
	e.EmployeeID,
	CONCAT(e.FirstName, ' ', e.LastName) AS EmployeeName,
	CONCAT(m.FirstName, ' ', m.LastName) AS ManagerName,
	d.[Name] AS DepartmentName
FROM Employees AS e
	JOIN Departments AS d ON d.DepartmentID = e.DepartmentID
	JOIN Employees AS m ON m.EmployeeID = e.ManagerID
ORDER BY e.EmployeeID

SELECT 
	MIN(AverageSalaries) AS MinAverageSalary
FROM
(SELECT 
	DepartmentID, AVG(Salary) AS AverageSalaries 
FROM Employees
GROUP BY DepartmentID) AS AverageSalariesByDepartments

SELECT 
	mc.CountryCode,
	m.MountainRange,
	p.PeakName,
	p.Elevation
FROM Mountains as m
	JOIN Peaks AS p ON p.MountainId = m.Id
	JOIN MountainsCountries AS mc ON mc.MountainId = M.Id
WHERE mc.CountryCode = 'BG' AND p.Elevation > 2835
ORDER BY p.Elevation DESC

SELECT 
	mc.CountryCode,
	COUNT(mc.CountryCode) AS MountainRanges
FROM Mountains AS m
	JOIN MountainsCountries AS mc ON m.Id = mc.MountainId
WHERE mc.CountryCode IN('BG', 'RU', 'US')
GROUP BY mc.CountryCode

SELECT TOP(5)
	c.CountryName, r.RiverName
FROM Rivers AS r
	JOIN CountriesRivers AS cr ON cr.RiverId = r.Id
	RIGHT JOIN Countries AS c ON c.CountryCode = cr.CountryCode
WHERE c.ContinentCode = 'AF'
ORDER BY c.CountryName

SELECT 
	ContinentCode,
	CurrencyCode,
	CurrencyUsage
FROM (
	SELECT 
		ContinentCode, 
		CurrencyCode, 
		COUNT(CountryCode) AS CurrencyUsage,
		DENSE_RANK() OVER (PARTITION BY ContinentCode ORDER BY COUNT(CountryCode) DESC) AS CurrencyRank
	FROM Countries
	GROUP BY ContinentCode, CurrencyCode
		HAVING COUNT(CountryCode) > 1 ) AS RankedCurrencies
WHERE CurrencyRank = 1
ORDER BY ContinentCode

SELECT COUNT(CountryCode) AS CountryCode FROM
(SELECT c.CountryCode FROM Countries AS c
	LEFT JOIN MountainsCountries AS mc ON mc.CountryCode = c.CountryCode
WHERE mc.CountryCode IS NULL) AS CountriesWithoutMountains

SELECT TOP(5)
	CountryName,
	(SELECT MAX(HighestPeaks.Elevation) FROM
		(SELECT p.Elevation FROM Countries AS c
			JOIN MountainsCountries AS mc ON mc.CountryCode = c.CountryCode
			JOIN Peaks AS p ON p.MountainId = mc.MountainId
		WHERE c.CountryName = Countries.CountryName) AS HighestPeaks)  AS HighestPeakElevation,
	(SELECT MAX(LongestRivers.Length) FROM
		(SELECT r.Length FROM Countries AS c
			JOIN CountriesRivers AS cr ON cr.CountryCode = c.CountryCode
			JOIN Rivers AS r ON r.Id = cr.RiverId
		WHERE c.CountryName = Countries.CountryName) AS LongestRivers) AS LongestRiverLength
FROM Countries
ORDER BY HighestPeakElevation DESC, LongestRiverLength DESC

SELECT TOP(5)
	c.CountryName,
	MAX(p.Elevation) AS HighestPeakElevation,
	MAX(r.Length) AS LongestRiverLength
FROM Countries AS c
	LEFT JOIN MountainsCountries AS mc ON mc.CountryCode = c.CountryCode
	LEFT JOIN Mountains AS m ON m.Id = mc.MountainId
	LEFT JOIN Peaks AS p ON p.MountainId = m.Id
	LEFT JOIN CountriesRivers AS cr ON cr.CountryCode = c.CountryCode
	LEFT JOIN Rivers AS r ON r.Id = cr.RiverId
GROUP BY c.CountryName
ORDER BY HighestPeakElevation DESC, LongestRiverLength DESC

SELECT TOP(5)
	CountryName,
	ISNULL(PeakName, '(no highest peak)') AS [Highest Peak Name],
	ISNULL(Elevation, 0) AS [Highest Peak Elevation],
	ISNULL(MountainRange, '(no mountain)') AS [Mountain]
FROM
(SELECT 
	c.CountryName,
	p.PeakName,
	MAX(p.Elevation) AS Elevation,
	DENSE_RANK() OVER (PARTITION BY CountryName ORDER BY MAX(p.Elevation) DESC) AS ElevationRank,
	m.MountainRange
FROM Countries AS c
	LEFT JOIN MountainsCountries AS mc ON mc.CountryCode = c.CountryCode
	LEFT JOIN Mountains AS m ON m.Id = mc.MountainId
	LEFT JOIN Peaks AS p ON p.MountainId = m.Id
GROUP BY c.CountryName, p.PeakName, m.MountainRange
) AS HighestPeaks
WHERE HighestPeaks.ElevationRank = 1
ORDER BY CountryName, [Highest Peak Name]