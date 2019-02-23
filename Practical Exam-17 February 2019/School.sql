-- Section 1. DDL (30 pts)
-- Points 30/30

CREATE TABLE Students(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(30) NOT NULL,
	MiddleName NVARCHAR(25),
	LastName NVARCHAR(30) NOT NULL,
	Age INT CHECK(Age > 0) NOT NULL,
	Address NVARCHAR(50),
	Phone NCHAR(10)
)

CREATE TABLE Subjects(
	Id INT PRIMARY KEY IDENTITY,
	Name NVARCHAR(20) NOT NULL,
	Lessons INT CHECK(Lessons > 0) NOT NULL
)

CREATE TABLE StudentsSubjects(
	Id INT PRIMARY KEY IDENTITY,
	StudentId INT FOREIGN KEY REFERENCES Students(Id) NOT NULL,
	SubjectId INT FOREIGN KEY REFERENCES Subjects(Id) NOT NULL,
	Grade DECIMAL(3, 2) CHECK(Grade >= 2 AND Grade <= 6) NOT NULL
)

CREATE TABLE Exams(
	Id INT PRIMARY KEY IDENTITY,
	Date DATETIME,
	SubjectId INT FOREIGN KEY REFERENCES Subjects(Id) NOT NULL
)

CREATE TABLE StudentsExams(
	StudentId INT FOREIGN KEY REFERENCES Students(Id) NOT NULL,
	ExamId INT FOREIGN KEY REFERENCES Exams(Id) NOT NULL,
	Grade DECIMAL(3, 2) CHECK(Grade >= 2 AND Grade <= 6) NOT NULL,
	CONSTRAINT PK_StudentsExams PRIMARY KEY(StudentId, ExamId)
)

CREATE TABLE Teachers(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(20) NOT NULL,
	LastName NVARCHAR(20) NOT NULL,
	Address  NVARCHAR(20) NOT NULL,
	Phone CHAR(10),
	SubjectId INT FOREIGN KEY REFERENCES Subjects(Id) NOT NULL
)

CREATE TABLE StudentsTeachers(
	StudentId INT FOREIGN KEY REFERENCES Students(Id) NOT NULL,
	TeacherId INT FOREIGN KEY REFERENCES Teachers(Id) NOT NULL,
	CONSTRAINT PK_StudentsTeachers PRIMARY KEY(StudentId, TeacherId)
)


-- Section 2. DML (10 pts)

-- 2. Insert
-- Points 3/3
INSERT INTO Teachers VALUES
('Ruthanne', 'Bamb', '84948 Mesta Junction', '3105500146', 6),
('Gerrard', 'Lowin', '370 Talisman Plaza', '3324874824', 2),
('Merrile', 'Lambdin', '81 Dahle Plaza', '4373065154', 5),
('Bert', 'Ivie',	'2 Gateway Circle',	'4409584510', 4)

INSERT INTO Subjects VALUES
('Geometry', 12),
('Health', 10),
('Drama', 7),
('Sports', 9)

-- 3. Update
-- Points 3/3
UPDATE StudentsSubjects SET Grade = 6.00 WHERE SubjectId IN(1, 2) AND Grade >= 5.50

-- 4. Delete
-- Points 4/4
DELETE FROM StudentsTeachers WHERE TeacherId IN(SELECT Id FROM Teachers WHERE Phone LIKE '%72%')
DELETE FROM Teachers WHERE Phone LIKE '%72%'


-- Section 3. Querying (40 pts)

-- 5. Teen Students
-- Points 2/2
SELECT FirstName, LastName, Age FROM Students
WHERE Age >= 12
ORDER BY FirstName, LastName

-- 6. Cool Addresses
-- Points 2/2
SELECT
	CONCAT(FirstName, ' ', MiddleName, ' ', LastName),
	Address
FROM Students
WHERE Address LIKE '%road%'
ORDER BY FirstName, LastName, Address

-- 7. 42 Phones
-- Points 2/2
SELECT FirstName, Address, Phone FROM Students
WHERE MiddleName IS NOT NULL AND Phone LIKE '42%' 
ORDER BY FirstName

-- 8. Students Teachers
-- Points 2/2
SELECT
	s.FirstName,
	s.LastName,
	COUNT(st.TeacherId) AS [TeachersCount]
FROM Students AS s
	LEFT JOIN StudentsTeachers AS st ON st.StudentId = s.Id
	LEFT JOIN Teachers AS t ON t.Id = st.TeacherId
GROUP BY s.FirstName, s.LastName

-- 9. Subjects with Students
-- Points 3/3
SELECT
	t.FirstName + ' ' + t.LastName AS [FullName],
	CONCAT(s.Name, '-', s.Lessons) AS [Subjects],
	COUNT(st.StudentId) AS Students
FROM Teachers AS t
	JOIN Subjects AS s ON s.Id = t.SubjectId
	JOIN StudentsTeachers AS st ON st.TeacherId = t.Id
GROUP BY t.FirstName, t.LastName, s.Name, s.Lessons
ORDER BY Students DESC, [FullName], [Subjects]

-- 10. Students to Go
-- Points 3/3
SELECT s.FirstName + ' ' + s.LastName AS [FullName] FROM Students AS s
	LEFT JOIN StudentsExams AS se ON se.StudentId = s.Id
WHERE se.ExamId IS NULL
ORDER BY [FullName]

-- 11. Busiest Teachers
-- Points 3/3
SELECT TOP(10)
	t.FirstName,
	t.LastName,
	COUNT(st.StudentId) AS [StudentsCount]
FROM Teachers AS t 
	JOIN StudentsTeachers AS st ON st.TeacherId = t.Id
GROUP BY t.FirstName, t.LastName
ORDER BY [StudentsCount] DESC, t.FirstName, t.LastName

-- 12. Top Students
-- Points 3/3
SELECT TOP(10)
	s.FirstName,
	s.LastName,
	FORMAT(AVG(se.Grade), 'N2') AS Grade
FROM Students AS s
	JOIN StudentsExams AS se ON se.StudentId = s.Id
GROUP BY s.FirstName, s.LastName
ORDER BY Grade DESC, s.FirstName, s.LastName

-- 13. Second Highest Grade
-- Points 5/5
SELECT RankedStudents.FirstName, RankedStudents.LastName, RankedStudents.Grade FROM
(SELECT
	s.FirstName, 
	s.LastName,
	ss.Grade,
	ROW_NUMBER() OVER(PARTITION BY s.Id ORDER BY ss.Grade DESC) GradeRank
FROM Students AS s	
	JOIN StudentsSubjects AS ss ON ss.StudentId = s.Id) AS RankedStudents
WHERE RankedStudents.GradeRank = 2
ORDER BY RankedStudents.FirstName, RankedStudents.LastName

-- 14. Not So In The Studying
-- Points 3/3
SELECT
	CONCAT(FirstName, ' ', ISNULL(MiddleName + ' ', ''), LastName) AS [FullName]
FROM Students 
WHERE Id NOT IN(SELECT StudentId FROM StudentsSubjects)
ORDER BY FullName

-- 15. Top Student per Teacher
-- Points 6/6
SELECT [TeacherName], [SubjectName], [StudentName], Grade 
FROM
(SELECT
	[TeacherName],
	[SubjectName], 
	[StudentName],
	ROW_NUMBER() OVER(PARTITION BY [TeacherId] ORDER BY Grade DESC) AS StudentRank,
	FORMAT(Grade, 'N2') AS Grade
FROM 
(SELECT
	t.Id AS [TeacherId],
	t.FirstName + ' ' + t.LastName AS [TeacherName],
	ts.Name AS [SubjectName],
	s.FirstName + ' ' + s.LastName AS [StudentName],
	AVG(ss.Grade) AS Grade
FROM Teachers AS t
	JOIN Subjects AS ts ON ts.Id = t.SubjectId
	JOIN StudentsTeachers AS st ON st.TeacherId = t.Id
	JOIN Students AS s ON s.Id = st.StudentId
	JOIN StudentsSubjects AS ss ON ss.StudentId = s.Id
WHERE ss.SubjectId = ts.Id
GROUP BY t.Id, t.FirstName, t.LastName, ts.Id, ts.Name, s.Id, s.FirstName, s.LastName) AS temp)
AS RankedStudents
WHERE RankedStudents.StudentRank = 1
ORDER BY [SubjectName], [TeacherName], Grade

-- 16. Average Grade per Subject
-- Points 3/3
SELECT
	s.Name,
	AVG(ss.Grade) AS [AverageGrade]
FROM Subjects AS s
	JOIN StudentsSubjects AS ss ON ss.SubjectId = s.Id
GROUP BY s.Id, s.Name
ORDER BY s.Id

-- 17. Exams Information
-- Points 3/3
SELECT
	IIF(e.Date IS NULL, 'TBA', CONCAT('Q', DATEPART(QUARTER, e.Date))) AS [Quarter],
	s.Name, 
	COUNT(se.StudentId) AS [StudentsCount]
FROM Exams AS e
	JOIN Subjects AS s ON s.Id = e.SubjectId
	JOIN StudentsExams AS se ON se.ExamId = e.Id
WHERE se.Grade >= 4.00
GROUP BY IIF(e.Date IS NULL, 'TBA', CONCAT('Q', DATEPART(QUARTER, e.Date))), s.Name
ORDER BY [Quarter] 
GO

-- Section 4. Programmability (20 pts)

-- 18. Exam Grades
-- Points 8/8
CREATE FUNCTION udf_ExamGradesToUpdate(@studentId INT, @grade DECIMAL(3, 2))
RETURNS VARCHAR(100)
AS
BEGIN
	DECLARE @studentFirstName NVARCHAR(30) = (SELECT FirstName FROM Students WHERE Id = @studentId)

	IF(@studentFirstName IS NULL)
	BEGIN
		RETURN 'The student with provided id does not exist in the school!'
	END

	IF(@grade > 6.00)
	BEGIN
		RETURN 'Grade cannot be above 6.00!'
	END

	DECLARE @gradesCount INT = (SELECT COUNT(se.ExamId) FROM Students AS s
								JOIN StudentsExams AS se ON se.StudentId =  s.Id
								WHERE s.Id = @studentId AND se.Grade BETWEEN @grade AND @grade + 0.5 )

	RETURN CONCAT('You have to update ', @gradesCount, ' grades for the student ', @studentFirstName)
END
GO

-- 19. Exclude from school
-- Points 8/8
CREATE PROCEDURE usp_ExcludeFromSchool(@StudentId INT)
AS
BEGIN
	DECLARE @id INT = (SELECT Id FROM Students WHERE Id = @StudentId)

	IF(@id IS NULL)
	BEGIN
		RAISERROR('This school has no student with the provided id!', 16, 1)
		RETURN
	END

	DELETE FROM StudentsExams WHERE StudentId = @StudentId
	DELETE FROM StudentsSubjects WHERE StudentId = @StudentId
	DELETE FROM StudentsTeachers WHERE StudentId = @StudentId
	DELETE FROM Students WHERE Id = @StudentId
END
GO

-- 20. Deleted Student
-- Points 4/4

-- “ExcludedStudents” with columns (StudentId, StudentName). 
CREATE TABLE ExcludedStudents(
	StudentId INT,
	StudentName NVARCHAR(30)
)
GO

CREATE TRIGGER tr_AfetrDeleteStudent ON Students FOR DELETE
AS
INSERT INTO ExcludedStudents(StudentId, StudentName)
SELECT Id, FirstName + ' ' + LastName FROM deleted