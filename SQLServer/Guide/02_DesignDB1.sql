--Creacion de base datos verificando que no exista
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'MedicalCenter')
    CREATE DATABASE MedicalCenter;
GO

USE MedicalCenter;
GO

--Crear tipo de dato general (Especie de variable)
IF NOT EXISTS (SELECT * FROM sys.types WHERE name = 'GENERAL_ID' AND is_user_defined = 1)
BEGIN
    CREATE TYPE GENERAL_ID FROM INT;
END;
IF NOT EXISTS (SELECT * FROM sys.types WHERE name = 'OBSERVATION' AND is_user_defined = 1)
BEGIN
    CREATE TYPE OBSERVATION FROM VARCHAR(512);
END;
IF NOT EXISTS (SELECT * FROM sys.types WHERE name = 'SHORT_TXT' AND is_user_defined = 1)
BEGIN
    CREATE TYPE SHORT_TXT FROM VARCHAR(64);
END;
GO

--Creacion de tablas verificando que no existan
IF OBJECT_ID('dbo.City', 'U') IS NULL
BEGIN
	CREATE TABLE City(
		code INT PRIMARY KEY IDENTITY(1, 1),
		cityName SHORT_TXT NOT NULL UNIQUE,
		district SHORT_TXT NOT NULL,
		country CHAR(3) NOT NULL DEFAULT 'COL'
	)
END;

IF OBJECT_ID('dbo.Patient', 'U') IS NULL
BEGIN
	CREATE TABLE Patient(
		id INT PRIMARY KEY IDENTITY(1, 1), --IDENTITY(start, step) Equivale a un AUTOINCREMENT
		dni BIGINT UNIQUE,
		patName SHORT_TXT NOT NULL,
		patLastName SHORT_TXT NOT NULL,
		birthDate DATE NOT NULL,
		patAddress SHORT_TXT NULL,
		cityCode INT,
		phone BIGINT UNIQUE,
		email SHORT_TXT UNIQUE NOT NULL,
		reason OBSERVATION NULL,
		CONSTRAINT FK_Patient_City FOREIGN KEY (cityCode) REFERENCES City(code) ON DELETE SET NULL
	)
END;

IF OBJECT_ID('dbo.History', 'U') IS NULL
BEGIN
	CREATE TABLE History(
		idHist INT PRIMARY KEY IDENTITY(1, 1),
		observation OBSERVATION NULL,
		dateHist DATE NOT NULL
	)
END;

IF OBJECT_ID('dbo.Speciality', 'U') IS NULL
BEGIN
	CREATE TABLE Speciality(
		idSpec INT PRIMARY KEY IDENTITY(1, 1),
		specDescription OBSERVATION NOT NULL
	)
END;

IF OBJECT_ID('dbo.Doctor', 'U') IS NULL
BEGIN
	CREATE TABLE Doctor(
		idDoct INT PRIMARY KEY IDENTITY(1, 1),
		doctName SHORT_TXT NOT NULL,
		doctLastName SHORT_TXT NOT NULL,
		idSpeciality GENERAL_ID NULL,
		CONSTRAINT FK_Doctor_Speciality FOREIGN KEY (idSpeciality) REFERENCES Speciality(idSpec) ON DELETE SET NULL
	)
END;

IF OBJECT_ID('dbo.Pat_HistRelation', 'U') IS NULL
BEGIN
	CREATE TABLE Pat_HistRelation(
		idHistory GENERAL_ID NOT NULL,
		idPatient GENERAL_ID NOT NULL,
		idDoctor GENERAL_ID NOT NULL,
		PRIMARY KEY (idHistory, idPatient, idDoctor), --PRIMARY KEY COMPUESTA
		CONSTRAINT FK_Pat_HistRelation_History FOREIGN KEY (idHistory) REFERENCES History(idHist) ON DELETE CASCADE,
		CONSTRAINT FK_Pat_HistRelation_Patient FOREIGN KEY (idPatient) REFERENCES Patient(id) ON DELETE CASCADE,
		CONSTRAINT FK_Pat_HistRelation_Doctor FOREIGN KEY (idDoctor) REFERENCES Doctor(idDoct) ON DELETE CASCADE
	)
END;

IF OBJECT_ID('dbo.AptStatus', 'U') IS NULL
BEGIN
	CREATE TABLE AptStatus(
		statusId SMALLINT PRIMARY KEY IDENTITY(1, 1),
		statusDescrip SHORT_TXT NOT NULL UNIQUE
	)
END;

IF OBJECT_ID('dbo.Appointment', 'U') IS NULL
BEGIN
	CREATE TABLE Appointment(
		aptId INT PRIMARY KEY IDENTITY(1, 1),
		aptDate DATETIME NOT NULL,
		aptStatus SMALLINT,
		aptObservation OBSERVATION NULL,
		CONSTRAINT FK_Appointment_AptStatus FOREIGN KEY (aptStatus) REFERENCES AptStatus(statusId) ON DELETE SET NULL
	)
END;

IF OBJECT_ID('dbo.Apt_PatRelation', 'U') IS NULL
BEGIN
	CREATE TABLE Apt_PatRelation(
		idAppointment GENERAL_ID NOT NULL,
		idPatient GENERAL_ID NOT NULL,
		idDoctor GENERAL_ID NOT NULL,
		PRIMARY KEY (idAppointment, idPatient, idDoctor),
		CONSTRAINT FK_Apt_PatRelation_Apt FOREIGN KEY (idAppointment) REFERENCES Appointment(aptId) ON DELETE CASCADE,
		CONSTRAINT FK_Apt_PatRelation_Patient FOREIGN KEY (idPatient) REFERENCES Patient(id) ON DELETE CASCADE,
		CONSTRAINT FK_Apt_PatRelation_Doctor FOREIGN KEY (idDoctor) REFERENCES Doctor(idDoct) ON DELETE CASCADE
	)
END;

IF OBJECT_ID('dbo.PayStatus', 'U') IS NULL
BEGIN
	CREATE TABLE PayStatus(
		paymentId SMALLINT PRIMARY KEY IDENTITY(1, 1),
		payDescrip SHORT_TXT NOT NULL UNIQUE
	)
END;

IF OBJECT_ID('dbo.Payment', 'U') IS NULL
BEGIN
	CREATE TABLE Payment(
		idPay INT PRIMARY KEY IDENTITY(1, 1),
		payType SHORT_TXT NOT NULL,
		payDate DATETIME NOT NULL,
		amount MONEY NOT NULL,
		payStatus SMALLINT NULL,
		observation OBSERVATION NULL
		CONSTRAINT FK_Payment_PayStatus FOREIGN KEY (payStatus) REFERENCES PayStatus(paymentId) ON DELETE SET NULL
	)
END;

IF OBJECT_ID('dbo.Pay_AptRelation', 'U') IS NULL
BEGIN
	CREATE TABLE Pay_AptRelation(
		idPayment GENERAL_ID NOT NULL,
		idAppointment GENERAL_ID NOT NULL,
		idPatient GENERAL_ID NOT NULL,
		PRIMARY KEY (idPayment, idAppointment, idPatient),
		CONSTRAINT FK_Pay_AptRelation_Pay FOREIGN KEY (idPayment) REFERENCES Payment(idPay) ON DELETE CASCADE,
		CONSTRAINT FK_Pay_AptRelation_Apt FOREIGN KEY (idAppointment) REFERENCES Appointment(aptId) ON DELETE CASCADE,
		CONSTRAINT FK_Pay_AptRelation_Pat FOREIGN KEY (idPatient) REFERENCES Patient(id) ON DELETE CASCADE
	)
END;