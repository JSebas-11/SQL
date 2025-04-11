--TRIGGERS -> Conjunto de instrucciones que se ejecutan automaticamente 
--	despues (solo AFTER) de evento (INSERT, UPDATE, DELETE) en tabla o vista

--INSERTED y DELETED se comportan como tablas temporales de solo lectura.
--	INSERTED (INSERT) <- Contiene registros insertados
--	INSERTED (UPDATE) <- Contiene versiones nuevas de registros actualizados
--	DELETED (UPDATE) <- Contiene versiones anteriores de registros actualizados
--	DELETED (DELETE) <- Contiene registros eliminados

--Crear tabla que guarde info de fechas de inserccion, eliminacion 
--y actualizacion de pacientes mediante triggers
IF OBJECT_ID('dbo.PatientBackup', 'U') IS NULL
BEGIN
	CREATE TABLE PatientBackup(
		id INT PRIMARY KEY IDENTITY(1, 1),
		dni BIGINT UNIQUE,
		fullName SHORT_TXT NOT NULL,
		email SHORT_TXT UNIQUE NOT NULL,
		registeredAt DATETIME NULL,
		updatedAt DATETIME NULL,
		deletedAt DATETIME NULL
	)
END;

--INSERTION TRIGGER
CREATE TRIGGER Patient_AI 
	ON Patient AFTER INSERT AS
	BEGIN
		INSERT INTO PatientBackup (dni, fullName, email, registeredAt)
			SELECT dni, dbo.FULLNAME(patName, patLastName), email, GETDATE()
			FROM INSERTED
	END;
INSERT INTO Patient VALUES 
	(1039584145, 'Daniela', 'Rodriguez', '2003-09-25', 'Calle 26 #07-11', 5, 3128878235, 'dani.rodri@example.com', 'Bandiditis contagiosa.'),
	(1058413541, 'Manuel', 'Jalois', '2009-01-20', 'Calle 26 #07-11', 2, 3228878235, 'manuel.jaloi@example.com', NULL),
	(1055241369, 'Bruno', 'Lopez', '1994-05-01', 'Carrera 05 #14-19', 7, 3118878235, 'bruno.lol@example.com', NULL);
EXEC I_newPatient 1085412654, 'Danilo', 'Pedroza', '19710206', 'Caucasia', 'Antioquia', 'dani.pedro@example.com', 3175412364, 'Carrera 99 #69-69';

--UPDATE TRIGGER
CREATE TRIGGER Patient_AU 
	ON Patient AFTER UPDATE AS 
	BEGIN
		UPDATE PatientBackup SET updatedAt = GETDATE()
		WHERE dni = (SELECT dni FROM INSERTED)
	END;
UPDATE Patient SET reason = 'Convulsion estomacal grado 99' WHERE dni = 1055241369;
UPDATE Patient SET patAddress = 'Av. Heisenberg #01-01' WHERE dni = 1055241369;
UPDATE Patient SET reason = 'Actitudes necrofilicos' WHERE dni = 1058413541;

--DELETE TRIGGER
CREATE TRIGGER Patient_AD 
	ON Patient AFTER DELETE AS 
	BEGIN
		UPDATE PatientBackup SET deletedAt = GETDATE()
		WHERE dni = (SELECT dni FROM DELETED)
	END;
DELETE FROM Patient WHERE dni = 1085412654;
DELETE FROM Patient WHERE dni = 1055241369;

SELECT * FROM PatientBackup;