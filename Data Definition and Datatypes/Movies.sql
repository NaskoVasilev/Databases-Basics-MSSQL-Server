CREATE TABLE Directors(
	Id INT PRIMARY KEY IDENTITY,
	DirectorName VARCHAR(50) NOT NULL,
	Notes VARCHAR(255)
)

INSERT INTO Directors(DirectorName, Notes) VALUES
('PESHO','just a note'),
('PESHO1',NULL),
('PESHO2','just a note1'),
('PESHO3','just a note2'),
('PESHO4','just a note3')

CREATE TABLE Genres(
	Id INT PRIMARY KEY IDENTITY,
	GenreName VARCHAR(30) NOT NULL,
	Notes VARCHAR(255)
)

INSERT INTO Genres(GenreName, Notes) VALUES
('action','just a note'),
('thriler','note4'),
('drama','note1'),
('comedy','note2'),
('fantasy','note3')

CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY,
	CategoryName VARCHAR(40) NOT NULL,
	Notes VARCHAR(255)
)

INSERT INTO Categories(CategoryName, Notes) VALUES
('categoty1','just a note'),
('categoty2','note4'),
('categoty3','note1'),
('categoty4','note2'),
('categoty5','note3')

CREATE TABLE Movies(
	Id INT PRIMARY KEY IDENTITY,
	Title VARCHAR(50) NOT NULL,
	DirectorId INT FOREIGN KEY REFERENCES Directors(Id) NOT NULL,
	CopyrightYear DATE,
	[Length] INT NOT NULL,
	GenreId INT FOREIGN KEY REFERENCES Genres(Id) NOT NULL,
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
	Rating INT,
	Notes VARCHAR(255)
)

INSERT INTO Movies(Title, DirectorId, CopyrightYear, [Length], 
GenreId, CategoryId, Rating, Notes) VALUES
('title1', 1, '2018-12-11', 100, 5, 1, 7, 'note1'),
('title2', 2, '2018-12-10', 100, 4, 2, 7, 'note2'),
('title3', 3, '2018-12-09', 120, 3, 3, 7, 'note3'),
('title4', 4, '2018-12-11', 100, 2, 4, 7, 'note1'),
('title5', 5, '2018-12-12', 100, 1, 5, 7, 'note1')