-- CreaDb.SQL
-- Date : 13.01.2021
-- Author : ENR_ISC_SGI

USE master
GO

-- Supprimer la DB si elle existe déjà
IF (EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = 'Tournois_eSport'))
BEGIN
	USE master
	ALTER DATABASE Tournois_eSport SET SINGLE_USER WITH ROLLBACK IMMEDIATE; -- Disconnect users the hard way (we cannot drop the db if someone's connected)
	DROP DATABASE Tournois_eSport -- Destroy it
END
GO

-- Création du répertoire
CREATE TABLE #ResultSet (Directory varchar(200)) -- Temporary table (name starts with #) -> will be automatically destroyed at the end of the session

INSERT INTO #ResultSet EXEC master.sys.xp_subdirs 'c:\' -- Stored procedure that lists subdirectories

IF NOT EXISTS (Select * FROM #ResultSet where Directory = 'DATA')
	EXEC master.sys.xp_create_subdir 'C:\DATA\' -- create DATA

DELETE FROM #ResultSet -- start over for MSSQL subdir
INSERT INTO #ResultSet EXEC master.sys.xp_subdirs 'c:\DATA'

IF NOT EXISTS (Select * FROM #ResultSet where Directory = 'MSSQL')
	EXEC master.sys.xp_create_subdir 'C:\DATA\MSSQL'

DROP TABLE #ResultSet -- Explicitely delete it because the script may be executed multiple times during the same session
GO

-- Création de la DB 
CREATE DATABASE Tournois_eSport ON  PRIMARY 
( NAME = 'Tournois_eSport_data', FILENAME = 'C:\DATA\MSSQL\Tournois_eSport.mdf' , SIZE = 20480KB , MAXSIZE = 51200KB , FILEGROWTH = 1024KB )
 LOG ON 
( NAME = 'Tournois_eSport_log', FILENAME = 'C:\DATA\MSSQL\Tournois_eSport.ldf' , SIZE = 10240KB , MAXSIZE = 20480KB , FILEGROWTH = 1024KB )
GO

-- CreaTables.SQL
-- Date : 13.01.2021
-- Author : ENR_ISC_SGI


USE Tournois_eSport
GO

-- Tables de la DB 
CREATE TABLE Teams (
	id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	Name varchar(40) UNIQUE NOT NULL,
	Player_id int NOT NULL,
	Organization_id int NOT NULL,
	Level_id int NOT NULL
);


CREATE TABLE Coachs (
	id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	FirstName varchar(50) NOT NULL,
	LastName varchar(50) NOT NULL,
	Email varchar(100) UNIQUE NOT NULL
);

CREATE TABLE Train (
	id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	Team_id int NOT NULL,
	Coach_id int NOT NULL
);

CREATE TABLE Players (
	id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	FirstName varchar(50) NOT NULL,
	LastName varchar(50) NOT NULL,
	Age tinyint NOT NULL,
	Email varchar(100) UNIQUE NOT NULL
);

CREATE TABLE Tournaments (
	id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	Name varchar(40) UNIQUE NOT NULL,
	StartDate date NOT NULL,
	EndDate date,
	Reward varchar(20),
	Country varchar(20),
	City varchar(30),
	Address varchar(50),
	Team_id int NOT NULL,
	Level_id int NOT NULL,
	Platform_id int NOT NULL,
	Game_id int NOT NULL,
	Match_id int NOT NULL
);

CREATE TABLE Levels (
	id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	Name varchar(15) UNIQUE NOT NULL
);

CREATE TABLE Organizations (
	id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	Name varchar(40) UNIQUE NOT NULL
);

CREATE TABLE Sponsors (
  	id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
  	Name varchar(70) UNIQUE NOT NULL
 );

 CREATE TABLE Sponsor (
  	id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	StartDate date NOT NULL,
	EndDate date NOT NULL,
  	Organization_id int NOT NULL,
	Sponsor_id int NOT NULL
 );

 CREATE TABLE Organize (
  	id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
  	Sponsor_id int NOT NULL,
	Tournament_id int NOT NULL
 );

CREATE TABLE Platforms (
	id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	Name varchar(20) UNIQUE NOT NULL
);

CREATE TABLE Games (
	id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	Name varchar(40) UNIQUE NOT NULL,
	Mode varchar(15) NOT NULL
);

CREATE TABLE Matches (
	id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	Name varchar(40) UNIQUE NOT NULL,
	Date date NOT NULL,
	Team_id int NOT NULL
);

CREATE TABLE Broadcasts (
	id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	Name varchar(40) UNIQUE NOT NULL,
);

CREATE TABLE Broadcast (
	id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	Match_id int NOT NULL,
	Broadcast_id int NOT NULL
);

CREATE TABLE Commentators (
	id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	FirstName varchar(50) NOT NULL,
	LastName varchar(50) NOT NULL,
	Age tinyint NOT NULL,
	Email varchar(100) UNIQUE NOT NULL,
	Match_id int NOT NULL
);



GO

-- Contraintes référentielles

ALTER TABLE Teams WITH CHECK ADD  CONSTRAINT FK_Team_Player FOREIGN KEY(Player_id)
REFERENCES Players(id)

ALTER TABLE Train WITH CHECK ADD  CONSTRAINT FK_TeamCoach_Team FOREIGN KEY(Team_id)
REFERENCES Teams(id)

ALTER TABLE Train WITH CHECK ADD  CONSTRAINT FK_TeamCoach_Coach FOREIGN KEY(Coach_id)
REFERENCES Coachs(id)

ALTER TABLE Teams WITH CHECK ADD  CONSTRAINT FK_Team_Organization FOREIGN KEY(Organization_id)
REFERENCES Organizations(id)

ALTER TABLE Teams WITH CHECK ADD  CONSTRAINT FK_Team_Level FOREIGN KEY(Level_id)
REFERENCES Levels(id)

ALTER TABLE Sponsor WITH CHECK ADD  CONSTRAINT FK_OrganizationSponsor_Organization FOREIGN KEY(Organization_id)
REFERENCES Organizations(id)

ALTER TABLE Sponsor WITH CHECK ADD  CONSTRAINT FK_OrganizationSponsor_Sponsor FOREIGN KEY(Sponsor_id)
REFERENCES Sponsors(id)

ALTER TABLE Organize WITH CHECK ADD  CONSTRAINT FK_SponsorTournament_Sponsor FOREIGN KEY(Sponsor_id)
REFERENCES Sponsors(id)

ALTER TABLE Organize WITH CHECK ADD  CONSTRAINT FK_SponsorTournament_Tournament FOREIGN KEY(Tournament_id)
REFERENCES Tournaments(id)

ALTER TABLE Tournaments WITH CHECK ADD  CONSTRAINT FK_Tournament_Team FOREIGN KEY(Team_id)
REFERENCES Teams(id)

ALTER TABLE Tournaments WITH CHECK ADD  CONSTRAINT FK_Tournament_Level FOREIGN KEY(Level_id)
REFERENCES Levels(id)

ALTER TABLE Tournaments WITH CHECK ADD  CONSTRAINT FK_Tournament_Platform FOREIGN KEY(Platform_id)
REFERENCES Platforms(id)

ALTER TABLE Tournaments WITH CHECK ADD  CONSTRAINT FK_Tournament_Game FOREIGN KEY(Game_id)
REFERENCES Games(id)

ALTER TABLE Tournaments WITH CHECK ADD  CONSTRAINT FK_Tournament_Match FOREIGN KEY(Match_id)
REFERENCES Matches(id)

ALTER TABLE Matches WITH CHECK ADD  CONSTRAINT FK_Match_Team FOREIGN KEY(Team_id)
REFERENCES Teams(id)

ALTER TABLE Commentators WITH CHECK ADD  CONSTRAINT FK_Commentator_Match FOREIGN KEY(Match_id)
REFERENCES Matches(id)

ALTER TABLE Broadcast WITH CHECK ADD  CONSTRAINT FK_MatchBroadcast_Match FOREIGN KEY(Match_id)
REFERENCES Matches(id)

ALTER TABLE Broadcast WITH CHECK ADD  CONSTRAINT FK_MatchBroadcast_Broadcast FOREIGN KEY(Broadcast_id)
REFERENCES Broadcasts(id)

ALTER TABLE Commentators
ADD CHECK (Age>=18); 

ALTER TABLE Players
ADD CHECK ((Age>=18) AND (Age<=40)); 

ALTER TABLE Tournaments WITH CHECK ADD  CONSTRAINT FK_Tournament_Match_id FOREIGN KEY (Match_id)
REFERENCES Matches(id)
ON DELETE CASCADE;

ALTER TABLE Commentators WITH CHECK ADD  CONSTRAINT FK_Commentator_Match_id FOREIGN KEY (Match_id)
REFERENCES Matches(id)
ON DELETE CASCADE


GO