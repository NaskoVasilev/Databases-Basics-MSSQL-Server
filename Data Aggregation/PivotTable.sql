SELECT 'Avrage Salary' AS DepartmentName,
		[Production], [Marketing], [Engineering]
FROM (
	SELECT 
	d.[Name],
	e.Salary
	FROM Employees AS e
		JOIN Departments AS d 
		ON d.DepartmentID = e.DepartmentID )
AS DeptmentsBySalary
PIVOT(
	AVG(Salary) FOR [Name] IN ([Production],[Marketing] ,[Engineering])
) AS PIVOTTABLE


