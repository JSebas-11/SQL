--Memory Temporal Table: Existen solo en la ejecucion de la consulta
DECLARE @table TABLE(id INT IDENTITY(1, 1)); -- Fields
--Aplicar cualquier operacion con la tabla

--Physic Temporal Table: Existen mientras servidor SQL este activo
CREATE TABLE #tempTable (id INT IDENTITY(1, 1), namee SHORT_TXT); --fields
DROP TABLE #tempTable;
--Aplicar cualquier operacion con la tabla

--Crear store procedure que apartir de tabla temporal con turnos de todos los 
--pacientes, filtre los turnos por id del paciente
CREATE PROC S_PatientAppts (@idPatient INT) AS
	BEGIN 
		DECLARE @patienAppts TABLE(idPat INT, dni BIGINT, aptId INT, aptDate DATE, aptStatus INT);

		INSERT INTO @patienAppts  --Inserccion a partir de un Select
			SELECT pat.id, pat.dni, apt.aptId, apt.aptDate, apt.aptStatus
			FROM Apt_PatRelation aptPatRel
			INNER JOIN Patient pat ON pat.id = aptPatRel.idPatient
			INNER JOIN Appointment apt ON apt.aptId = aptPatRel.idAppointment;
		
		SELECT * FROM @patienAppts 
		WHERE idPat = @idPatient;
	END;
GO

EXEC S_PatientAppts 1;
EXEC S_PatientAppts 7;
EXEC S_PatientAppts 99;

--VIEWS: 'Tabla' predefinida a partir de una consulta que sera almacenada para ser usada en cualquier momento
CREATE VIEW View_PatientsAppts AS (
	SELECT pat.id, dbo.FULLNAME(pat.patName, pat.patLastName) AS patName, apt.aptId, apt.aptDate, apt.aptStatus
	FROM Apt_PatRelation patAptRel
	INNER JOIN Patient pat ON pat.id = patAptRel.idPatient
	INNER JOIN Appointment apt ON apt.aptId = patAptRel.idAppointment)

SELECT * FROM dbo.View_PatientsAppts;

CREATE VIEW View_DoctorSpeciality AS (
	SELECT doc.idDoct, dbo.FULLNAME(doc.doctName, doc.doctLastName) AS doctName, spe.specDescription
	FROM Doctor doc
	INNER JOIN Speciality spe ON spe.idSpec = doc.idSpeciality)

SELECT * FROM dbo.View_DoctorSpeciality;