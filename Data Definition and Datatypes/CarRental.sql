CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY,
	CategoryName VARCHAR(50) NOT NULL UNIQUE,
	DailyRate INT,
	WeeklyRate INT,
	MonthlyRate INT,
	WeekendRate INT,
)

INSERT INTO Categories(CategoryName, DailyRate, WeeklyRate, MonthlyRate, WeekendRate) VALUES
('categoty1', 1, 2, 3, 4),
('categoty12', 1, 2, 3, 4),
('categoty13', 1, 2, 3, 4)

CREATE TABLE Cars(
	Id INT PRIMARY KEY IDENTITY,
	PlateNumber INT,
	Manufacturer VARCHAR(50) NOT NULL,
	Model VARCHAR(50) NOT NULL,
	CarYear DATE NOT NULL,
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
	Doors SMALLINT,
	Picture VARBINARY,
	Condition VARCHAR(255),
	Available BIT NOT NULL
)

INSERT INTO Cars(PlateNumber, Manufacturer, Model, CarYear, CategoryId, Doors, Picture,
Condition, Available) VALUES
(1, 'mercedes', 'c220', '2005-12-24', 1, 4, NULL, 'good', 1),
(5, 'mercedes', 'c270', '2005-12-24', 2, 2, NULL, 'good', 0),
(22025, 'mercedes', 'c180', '2005-12-24', 3, 4, NULL, 'good', 1)

CREATE TABLE Employees(
	Id INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	Title VARCHAR(50),
	Notes VARCHAR(255),
)

INSERT INTO Employees(FirstName, LastName, Title, Notes) VALUES
('Atanas', 'Vasilev', NUll, NUll),
('Nasko', 'Vasilev', NUll, NUll),
('Georgi', 'Vasilev', NUll, NUll)

CREATE TABLE Customers(
	Id INT PRIMARY KEY IDENTITY,
	DriverLicenceNumber INT NOT NULL,
	FullName VARCHAR(120) NOT NULL,
	[Address] VARCHAR(255) NOT NULL, 
	City VARCHAR(50),
	ZIPCode VARCHAR(50) NOT NULL,
	Notes VARCHAR(255) NOT NULL
)

INSERT INTO Customers(DriverLicenceNumber, FullName, [Address], City, ZIPCode, Notes) VALUES
(12, 'nasko', 'address1', 'plovdiv', 'dwsdsdw', 'note'),
(24, 'nasko', 'address2', 'plovdiv', 'dws54dsdw', 'note2'),
(1542, 'nasko', 'address3', 'plovdiv', 'dw545sdsdw', 'note')

CREATE TABLE RentalOrders(
	Id INT PRIMARY KEY IDENTITY,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL,
	CustomerId INT FOREIGN KEY REFERENCES Customers(Id) NOT NULL,
	CarId INT FOREIGN KEY REFERENCES Cars(Id) NOT NULL,
	TankLevel INT NOT NULL,
	KilometrageStart DECIMAL(15,2) NOT NULL,
	KilometrageEnd DECIMAL(15,2) NOT NULL,
	TotalKilometrage AS KilometrageEnd - KilometrageStart,
	StartDate DATETIME NOT NULL,
	EndDate DATETIME NOT NULL,
	TotalDays AS EndDate - StartDate,
	RateApplied INT,
	TaxRate INT NOT NULL,
	OrderStatus VARCHAR(30) NOT NULL,
	Notes VARCHAR(255)
)

INSERT INTO RentalOrders(EmployeeId, CustomerId, CarId, TankLevel,
KilometrageStart, KilometrageEnd, StartDate, EndDate, RateApplied, TaxRate, OrderStatus, Notes) VALUES
(1, 3, 1, 12, 150, 250, '2019-01-17', '2019-01-18', 10, 10, 'in progress', NULL),
(2, 2, 2, 12, 150, 250, '2019-01-17', '2019-01-18', 10, 10, 'in progress', NULL),
(1, 2, 1, 12, 150, 250, '2019-01-17', '2019-01-18', 10, 10, 'in progress', NULL)