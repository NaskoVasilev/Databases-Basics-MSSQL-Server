CREATE TABLE People(
	Id INT UNIQUE IDENTITY,
	[Name] NVARCHAR(200) NOT NULL,
	Picrure VARBINARY(MAX),
	Height DECIMAL(15, 2),
	[Weight] DECIMAL(15, 2),
	Gender CHAR(1) NOT NULL CHECK(Gender = 'f' OR Gender = 'm'),
	Birthdate DATE NOT NULL,
	Biography NTEXT
)

ALTER TABLE People
ADD CONSTRAINT PK_ID PRIMARY KEY (Id)

INSERT INTO People([Name], Picrure, Height, [Weight], Gender, Birthdate, Biography) VALUES
('Atanas', NULL, 170, 60, 'm', '2001-11-24', 'student'),
('Nasko', NULL, 175, 50, 'm', '2001-11-24', 'teacher'),
('Niki', NULL, 178, 120, 'm', '2001-11-24', 'worker'),
('Denis', NULL, 180, 75, 'm', '2001-11-24', 'developer'),
('Pesho', NULL, 192, 70, 'm', '2001-11-24', 'student')