CREATE TABLE Users(
	Id BIGINT UNIQUE IDENTITY,
	Username VARCHAR(30) NOT NULL UNIQUE,
	[Password] VARCHAR(26) NOT NULL,
	ProfilePicrure VARBINARY CHECK(DATALENGTH(ProfilePicrure) < (1024*900)),
	LastLoginTime DATETIME,
	IsDeleted BIT
)

ALTER TABLE Users
ADD CONSTRAINT PK_Id_Users PRIMARY KEY (Id)

INSERT INTO Users(Username, [Password], ProfilePicrure, LastLoginTime, IsDeleted) VALUES
('atanas', 'password', NULL, NULL, 0),
('atanas1', 'password1', NULL, NULL, 0),
('atanas2', 'password2', NULL, '2019-01-17 12:12:12', 1),
('atanas3', 'password3', NULL, NULL, 0),
('atanas4', 'password4', NULL, NULL, 1)

ALTER TABLE Users
DROP CONSTRAINT PK_Id_Users

ALTER TABLE Users
ADD CONSTRAINT PK_Users PRIMARY KEY(Id, Username)

ALTER TABLE Users
ADD CONSTRAINT CHK_Password CHECK(LEN([Password]) >= 5)

ALTER TABLE Users
ADD DEFAULT GETDATE() FOR LastLoginTime

ALTER TABLE Users
DROP CONSTRAINT PK_Users

ALTER TABLE Users
ADD CONSTRAINT CHK_UsernameLength CHECK(LEN(Username) >= 3)


