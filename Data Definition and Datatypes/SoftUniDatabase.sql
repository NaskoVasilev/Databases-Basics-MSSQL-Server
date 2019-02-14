CREATE TABLE Towns(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(30) NOT NULL
)

CREATE TABLE Addresses(
	Id INT PRIMARY KEY IDENTITY,
	AddressText NVARCHAR(150) NOT NULL,
	TownId INT CONSTRAINT FK_Adresses_Towns FOREIGN KEY REFERENCES Towns(Id)
)

CREATE TABLE Departments(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(30) NOT NULL
)

CREATE TABLE Employees(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(30) NOT NULL,
	MiddleName NVARCHAR(30) NOT NULL,
	LastName NVARCHAR(30) NOT NULL,
	JobTitle NVARCHAR(70) NOT NULL,
	DepartmentId INT CONSTRAINT FK_Employees_Departments FOREIGN KEY REFERENCES Departments(Id) NOT NULL,
	HireDate DATETIME NOT NULL,
	Salary DECIMAL(15,2) NOT NULL,
	AddressId INT CONSTRAINT FK_Employees_Addresses FOREIGN KEY REFERENCES Addresses(Id),
)

INSERT INTO Towns([Name]) VALUES
('Sofia'),
('Plovdiv'),
('Varna'),
('Burgas')

INSERT INTO Departments([Name]) VALUES
('Engineering'),
('Sales'),
('Marketing'),
('Software Development'),
('Quality Assurance')

INSERT INTO Employees(FirstName, MiddleName, LastName, JobTitle,DepartmentId, HireDate, Salary) VALUES
('Ivan', 'Ivanov', 'Ivanov', 'Senior Engineer', 1, '2004-03-02', 4000.00),
('Petar', 'Petrov', 'Petrov', '.NET Developer', 4, '2013-01-02', 3500.00),
('Maria', 'Petrova', 'Ivanova', 'Intern', 5, '2013-01-02', 525.25),
('Georgi', 'Teziev', 'Ivanov', 'CEO', 2, '2013-01-02', 3000.00),
('Peter', 'Pan', 'Pan', 'Intern', 3, '2013-01-02', 599.88)

SELECT [Name] FROM Towns	
ORDER BY [Name] ASC
SELECT [Name] FROM Departments
ORDER BY [Name] ASC
SELECT FirstName, LastName, JobTitle, Salary FROM Employees
ORDER BY Salary DESC

UPDATE Employees
SET Salary *= 1.1

SELECT Salary FROM Employees
