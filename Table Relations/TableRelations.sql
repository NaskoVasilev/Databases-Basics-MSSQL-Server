-- Problem 1.	One-To-One Relationship
CREATE TABLE Passports(
	Id INT PRIMARY KEY,
	PassportNumber VARCHAR(10)
)

INSERT  INTO Passports VALUES
(101, 'N34FG21B'),
(102, 'K65LO4R7'),
(103, 'ZE657QP2')

CREATE TABLE Persons (
	PersonID INT NOT NULL,
	FirstName NVARCHAR(30),
	Salary DECIMAL(15,2),
	PassportID INT
)

INSERT INTO Persons VALUES
(1, 'Roberto', 43300.00, 102),
(2, 'Tom', 56100.00, 103),
(3, 'Yana', 60200.00, 101)

ALTER TABLE Persons
ADD CONSTRAINT PK_Persons PRIMARY KEY(PersonID)

ALTER TABLE Persons
ADD CONSTRAINT FK_Passports_Persons FOREIGN KEY(PassportID)
REFERENCES Passports(Id)

-- Problem 2.	One-To-Many Relationship
CREATE TABLE Models(
	ModelID INT NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,
	ManufacturerID INT
)

INSERT INTO Models VALUES
(101, 'X1', 1),
(102, 'i6', 1),
(103, 'Model S', 2),
(104, 'Model X', 2),
(105, 'Model 3', 2),
(106, 'Nova', 3)

CREATE TABLE Manufacturers(
	ManufacturerID INT NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,
	EstablishedOn DATE
)

INSERT INTO Manufacturers VALUES
(1, 'BMW', '07/03/1916'),
(2, 'Tesla', '01/01/2003'),
(3, 'Lada', '01/05/1966')

ALTER TABLE Manufacturers
ADD CONSTRAINT PK_Manufacturers PRIMARY KEY(ManufacturerID)

ALTER TABLE Models
ADD CONSTRAINT PK_Models PRIMARY KEY(ModelID) 

ALTER TABLE Models
ADD CONSTRAINT FK_Models_Manufacturers
FOREIGN KEY(ManufacturerID) REFERENCES Manufacturers(ManufacturerID)

-- Problem 3.	Many-To-Many Relationship
CREATE TABLE Students(
	StudentID INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(30) NOT NULL,
)

INSERT INTO Students(FirstName) VALUES
('Mila'),
('Toni'),
('Ron')

CREATE TABLE Exams(
	ExamID INT PRIMARY KEY,
	[Name] VARCHAR(30)
)

INSERT INTO Exams VALUES
(101, 'SpringMVC'),
(102, 'Neo4j'),
(103, 'Oracle 11g')

CREATE TABLE StudentsExams(
	StudentID INT FOREIGN KEY REFERENCES Students(StudentID) NOT NULL,
	ExamID INT FOREIGN KEY REFERENCES Exams(ExamID) NOT NULL
)

ALTER TABLE StudentsExams
ADD CONSTRAINT PK_StudentsExams PRIMARY KEY(StudentID, ExamID)

INSERT INTO StudentsExams VALUES
(1, 101),
(1, 102),
(2, 101),
(3, 103),
(2, 102),
(2, 103)


-- Problem 4.  Self-Referencing
CREATE TABLE Teachers(
	TeacherID INT PRIMARY KEY,
	[Name] VARCHAR(30) NOT NULL,
	ManagerID INT FOREIGN KEY REFERENCES Teachers(TeacherID)
)

INSERT INTO Teachers VALUES
(101, 'John', NULL),
(102, 'Maya', 106),
(103, 'Siliva', 106),
(104, 'Ted', 105),
(105, 'Matk', 101),
(106, 'Grata', 101)

-- Problem 5.	Online Store Database
CREATE TABLE ItemTypes(
	ItemTypeID INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Items(
	ItemID INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	ItemTypeID INT FOREIGN KEY REFERENCES  ItemTypes(ItemTypeID)
)

CREATE TABLE Cities(
	CityID INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Customers(
	CustomerID INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	Birthday VARCHAR(50),
	CityID INT FOREIGN KEY REFERENCES Cities(CityID)
)

CREATE TABLE Orders(
	OrderID INT PRIMARY KEY IDENTITY,
	CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID)
)

CREATE TABLE OrderItems(
	OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
	ItemID INT FOREIGN KEY REFERENCES Items(ItemID),
	CONSTRAINT PK_OrderItems PRIMARY KEY(OrderID, ItemID)
)

--Problem 6.	University Database
CREATE TABLE Majors(
	MajorID INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Students(
	StudentID INT PRIMARY KEY IDENTITY,
	StudentNumber VARCHAR(50) NOT NULL,
	StudentName VARCHAR(50) NOT NULL,
	MajorID INT FOREIGN KEY REFERENCES Majors(MajorID) 
)

CREATE TABLE Payments(
	PaymentID INT PRIMARY KEY IDENTITY,
	PaymentDate DATETIME,
	PaymentAmmount DECIMAL(15,2),
	StudentID INT FOREIGN KEY REFERENCES Students(StudentID) 
)

CREATE TABLE Subjects(
	SubjectID INT PRIMARY KEY IDENTITY,
	SubjectName VARCHAR(50) NOT NULL
)

CREATE TABLE Agenda(
	StudentID INT FOREIGN KEY REFERENCES Students(StudentID),
	SubjectID INT FOREIGN KEY REFERENCES Subjects(SubjectID),
	CONSTRAINT PK_Agenda PRIMARY KEY(StudentID, SubjectID)
)

--Problem 9.  *Peaks in Rila
SELECT MountainRange, PeakName, Elevation FROM Mountains AS m
	JOIN Peaks AS p ON m.Id = p.MountainId
WHERE MountainRange = 'Rila'
ORDER BY Elevation DESC

