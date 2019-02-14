CREATE TABLE Employees(
	Id INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(30) NOT NULL,
	LastName VARCHAR(30) NOT NULL,
	Title VARCHAR(30),
	Notes VARCHAR(255)
)

INSERT INTO Employees(FirstName, LastName, Title, Notes) VALUES
('atanas', 'vasilev', 'title', 'notes'),
('nasko', 'vasilev', 'title', 'notes'),
('pesho', 'vasilev', 'title', 'notes')

CREATE TABLE Customers(
	Id INT PRIMARY KEY IDENTITY,
	AccountNumber INT NOT NULL,
	FirstName VARCHAR(30) NOT NULL,
	LastName VARCHAR(30) NOT NULL,
	PhoneNumber CHAR(10),
	EmergencyName VARCHAR(30),
	EmergencyNumber VARCHAR(10),
	Notes VARCHAR(255)
)

INSERT INTO Customers(AccountNumber, FirstName, LastName, PhoneNumber, 
EmergencyName, EmergencyNumber, Notes) VALUES
(1, 'atanas', 'vasilev', '0884454545', 'em_Name', '112', NULL),
(2, 'atanas1', 'vasilev', '0884454545', 'em_Name', '112', NULL),
(112, 'atanas2', 'vasilev', '0884454545', 'em_Name', '112', NULL)

CREATE TABLE RoomStatus(
	Id INT PRIMARY KEY IDENTITY,
	RoomStatus VARCHAR(20) NOT NULL,
	Notes VARCHAR(255)
)

INSERT INTO RoomStatus(RoomStatus, Notes) VALUES
('occupied', 'note'),
('unoccupied', 'note'),
('room-status', 'note')

CREATE TABLE RoomTypes(
	Id INT PRIMARY KEY IDENTITY,
	RoomType VARCHAR(20) NOT NULL,
	Notes VARCHAR(255)
)

INSERT INTO RoomTypes(RoomType, Notes) VALUES
('room_type', 'note'),
('room_type1', 'note'),
('room_type2', 'note')

CREATE TABLE BedTypes(
	Id INT PRIMARY KEY IDENTITY,
	BedType VARCHAR(20) NOT NULL,
	Notes VARCHAR(255)
)

INSERT INTO BedTypes(BedType, Notes) VALUES
('bed_type', 'note'),
('bed_type1', 'note'),
('bed_type2', 'note')

CREATE TABLE Rooms(
	Id INT PRIMARY KEY IDENTITY,
	RoomNumber INT NOT NULL UNIQUE,
	RoomType INT FOREIGN KEY REFERENCES RoomTypes(Id),
	BedType INT FOREIGN KEY REFERENCES BedTypes(Id),
	Rate INT,
	RoomStatus INT FOREIGN KEY REFERENCES RoomStatus(Id) NOT NULL,
	Notes VARCHAR(255)
)

INSERT INTO Rooms(RoomNumber, RoomType, BedType, Rate, RoomStatus, Notes) VALUES
(12, 1, 1, 10, 1, NULL),
(120, 2, 2, 10, 1, NULL),
(15, 1, 2, 10, 3, NULL)

CREATE TABLE Payments(
	Id INT PRIMARY KEY IDENTITY,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id),
	PaymentDate  DATETIME NOT NULL,
	AccountNumber INT NOT NULL,
	FirstDateOccupied DATETIME NOT NULL,
	LastDateOccupied DATETIME NOT NULL,
	TotalDays INT,
	AmountCharged DECIMAL(15,2) NOT NULL,
	TaxRate DECIMAL(15,2) NOT NULL,
	TaxAmount DECIMAL(15,2) NOT NULL,
	PaymentTotal DECIMAL(15,2) NOT NULL,
	Notes VARCHAR(255)
)

INSERT INTO Payments(EmployeeId, PaymentDate, AccountNumber, FirstDateOccupied, 
LastDateOccupied, TotalDays, AmountCharged, TaxRate, TaxAmount, PaymentTotal, Notes) VALUES
(1, '2019-01-17', 132, '2019-01-17', '2019-01-17', 10, 20, 20, 20, 20, 'note'),
(2, '2019-01-17', 132, '2019-01-17', '2019-01-17', 10, 20, 20, 20, 20, 'note'),
(1, '2019-01-17', 132, '2019-01-11', '2019-01-17', 10, 20, 20, 20, 20, 'note')

CREATE TABLE Occupancies(
	Id INT PRIMARY KEY IDENTITY,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id),
	DateOccupied  DATETIME NOT NULL,
	AccountNumber INT NOT NULL,
	RoomNumber INT NOT NULL,
	RateApplied DECIMAL(15,2) NOT NULL,
	PhoneCharge DECIMAL(15,2) NOT NULL,
	Notes VARCHAR(255)
)

INSERT INTO Occupancies(EmployeeId, DateOccupied, 
AccountNumber, RoomNumber, RateApplied, PhoneCharge, Notes) VALUES
(1, '2019-01-18', 123, 12, 20, 20, NULL),
(1, '2019-01-18', 123, 12, 20, 20, NULL),
(1, '2019-01-18', 123, 12, 20, 20, NULL)