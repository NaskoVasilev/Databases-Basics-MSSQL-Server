USE Gringotts

SELECT COUNT(Id) FROM WizzardDeposits

SELECT 
    DepositGroup,
	MAX(MagicWandSize) AS LongestMagicWand 
FROM WizzardDeposits
GROUP BY DepositGroup

SELECT TOP(2)
    DepositGroup
FROM WizzardDeposits
GROUP BY DepositGroup
ORDER BY AVG(MagicWandSize)

SELECT 
	DepositGroup,
	SUM(DepositAmount) AS TotalSum
FROM WizzardDeposits
WHERE MagicWandCreator = 'Ollivander family'
GROUP BY DepositGroup

SELECT 
	DepositGroup,
	SUM(DepositAmount) AS TotalSum
FROM WizzardDeposits
WHERE MagicWandCreator = 'Ollivander family'
GROUP BY DepositGroup
	HAVING SUM(DepositAmount) < 150000
ORDER BY TotalSum DESC

SELECT 
	DepositGroup, 
	MagicWandCreator,
	MIN(DepositCharge) AS MinDepositCharge
FROM WizzardDeposits
	GROUP BY DepositGroup, MagicWandCreator
ORDER BY MagicWandCreator, DepositGroup

SELECT	
	AgeGroup,
	COUNT(AgeGroup) AS WizzardCount
FROM
(SELECT 
	CASE
		WHEN Age BETWEEN 0 AND 10 THEN '[0-10]'
		WHEN Age BETWEEN 11 AND 20 THEN '[11-20]'
		WHEN Age BETWEEN 21 AND 30 THEN '[21-30]'
		WHEN Age BETWEEN 31 AND 40 THEN '[31-40]'
		WHEN Age BETWEEN 41 AND 50 THEN '[41-50]'
		WHEN Age BETWEEN 51 AND 60 THEN '[51-60]'
		ELSE '[61+]'
	END AS AgeGroup
FROM WizzardDeposits) AS AgeGroupByCount
GROUP BY AgeGroup

SELECT
	SUBSTRING(FirstName, 1, 1) AS FirstLetter
FROM WizzardDeposits
WHERE DepositGroup = 'Troll Chest'
GROUP BY SUBSTRING(FirstName, 1, 1)
ORDER BY FirstLetter

SELECT
	DepositGroup,
	IsDepositExpired,
	AVG(DepositInterest)
FROM WizzardDeposits
WHERE DepositStartDate > '01/01/1985'
GROUP BY DepositGroup , IsDepositExpired
ORDER BY DepositGroup DESC, IsDepositExpired

SELECT
	SUM([Difference]) AS SumDifference
FROM
(SELECT 
	DepositAmount - (SELECT DepositAmount FROM WizzardDeposits AS InnerTable
	WHERE InnerTable.Id = outerTable.Id + 1) AS [Difference]
FROM WizzardDeposits AS outerTable) AS ResultTable

--Other solution
SELECT
	SUM([Difference]) AS DiffernceSum
FROM
(SELECT
	DepositAmount - LEAD(DepositAmount, 1) OVER (ORDER BY Id) AS [Difference]
FROM WizzardDeposits) AS DiffernceTable

USE SoftUni

SELECT
	DepartmentID, 
	SUM(Salary)
FROM Employees
GROUP BY DepartmentID
ORDER BY DepartmentID

SELECT
	DepartmentID, 
	MIN(Salary)
FROM Employees
WHERE DepartmentID IN(2, 5, 7) AND HireDate > '2000-01-01'
GROUP BY DepartmentID
ORDER BY DepartmentID

SELECT * INTO AvargeSalaries
FROM Employees
WHERE Salary > 30000
DELETE FROM AvargeSalaries
WHERE ManagerID = 42
UPDATE AvargeSalaries
SET Salary += 5000
WHERE DepartmentID = 1
SELECT
	DepartmentID,
	AVG(Salary) AS AverageSalary
FROM AvargeSalaries
GROUP BY DepartmentID

SELECT
	DepartmentID,
	MAX(Salary) AS MaxSalary
FROM Employees
GROUP BY DepartmentID
	HAVING MAX(Salary) < 30000 OR MAX(Salary) > 70000

SELECT
	COUNT(Salary)
FROM Employees
WHERE ManagerID IS NULL

SELECT
	DepartmentID,
	Salary
FROM
(SELECT
	DepartmentID,
	Salary,
	DENSE_RANK() OVER(PARTITION BY DepartmentId ORDER BY Salary DESC) AS SalaryRank
FROM Employees) AS RankedTable
WHERE SalaryRank = 3
GROUP BY DepartmentID, Salary

SELECT TOP(10)
	FirstName,
	LastName,
	DepartmentID
FROM Employees AS e
WHERE Salary > (SELECT 
		AVG(Salary)
	FROM Employees AS d
	WHERE e.DepartmentID = d.DepartmentID)