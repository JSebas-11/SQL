--PRACTICA STORE PROCEDURES:
--Crear Store Procedura para insertar paciente verificando integridad de parametros y posibles cambios City	
CREATE PROC I_newPatient 
	(@dni BIGINT, @name SHORT_TXT, @lastName SHORT_TXT, @birthdate DATE, @cityName SHORT_TXT, @district SHORT_TXT, 
	@email SHORT_TXT, @phone BIGINT = NULL, @address SHORT_TXT = NULL, @reason OBSERVATION = NULL, @country SHORT_TXT = 'COL') AS
	BEGIN 
		DECLARE @cityCode INT;
		SELECT @cityCode = code FROM City WHERE cityName = @cityName;

		IF (@cityCode IS NULL) 
			BEGIN
				INSERT INTO City VALUES (@cityName, @district, @country);
				SELECT @cityCode = code FROM City WHERE cityName = @cityName;
			END
		BEGIN TRY
			INSERT INTO Patient (dni, patName, patLastName, birthDate, patAddress, cityCode, phone, email, reason)
			VALUES (@dni, @name, @lastName, @birthdate, @address, @cityCode, @phone, @email, @reason)
		END TRY
		BEGIN CATCH
			IF (ERROR_NUMBER() = 2627) PRINT 'No permiten duplicados en DNI, phone o email'
			ELSE PRINT 'Ha ocurrido un error: ' + ERROR_MESSAGE();
		END CATCH 
	END;
GO

--Lanzara mensaje debido a que datos unicos ya existen
EXEC I_newPatient 1055848701, 'Jose', 'Melaso', '19950421', 'Medellin', 'Antioquia', 'jose.mela@example.com', 3148679231, 'Calle 11 #47-21', 'Revision sonda anal.';
--Creara paciente e insertara nueva ciudad en tabla City
EXEC I_newPatient 1039547562, 'Davide', 'Lazaro', '20000827', 'Pacoa', 'Amazonas', 'lazaro.dav@example.com', 3158681238, 'Carrera 12 #11-21';
--Creara paciente, y tomara code de la ciudad pero no la insertara ya que ya esta registrada
EXEC I_newPatient 1054789632, 'Josefa', 'Saldar', '19750101', 'Armenia', 'Quindio', 'jj.mela@example.com', 3228689231, 'Av. Colochos #99-69', 'Sapo.';

--Crear store procedure para insertar medico verificando integridad de parametros y posibles cambios Speciality
CREATE PROC I_newDoctor
	(@name SHORT_TXT, @lastName SHORT_TXT, @speciality SHORT_TXT) AS
	BEGIN 
		DECLARE @specCode INT;
		SELECT @specCode = idSpec FROM Speciality WHERE specDescription = @speciality;

		IF (@specCode IS NULL) 
			BEGIN
				INSERT INTO Speciality VALUES (@speciality);
				SELECT @specCode = idSpec FROM Speciality WHERE specDescription = @speciality;
			END
		BEGIN TRY
			INSERT INTO Doctor VALUES (@name, @lastName, @specCode);
		END TRY
		BEGIN CATCH  
			PRINT 'Ha ocurrido un error: ' + ERROR_MESSAGE();
		END CATCH 
	END;
GO

--Creara doctor e insertara nueva especialidad en tabla Speciality
EXEC I_newDoctor 'Esteban', 'Dido', 'Vaganciologia';
--Creara doctor, y tomara code de la especialidad pero no la insertara ya que ya esta registrada
EXEC I_newDoctor 'Daniela', 'Breva', 'Cardiologia';

--Crear store procedure para insertar turno y gestionarse en demas tablas relacionadas
CREATE VIEW View_DocApt AS (
	SELECT apt.aptId, apt.aptDate, aptPat.idDoctor, CONCAT_WS(' ', dc.doctName, dc.doctLastName) AS docName
	FROM Apt_PatRelation aptPat
	INNER JOIN Appointment apt ON aptPat.idAppointment = apt.aptId
	INNER JOIN Doctor dc ON dc.idDoct = aptPat.idDoctor);

CREATE PROC I_newAppointment
	(@patDni BIGINT, @doctName SHORT_TXT, @aptDate DATE, @observation OBSERVATION = NULL) AS
	BEGIN 

		DECLARE @idPat INT;
		SELECT @idPat = id FROM Patient WHERE dni = @patDni;
		DECLARE @idDoc INT;
		SELECT @idDoc = idDoct FROM Doctor WHERE CONCAT_WS(' ', doctName, doctLastName) = @doctName;

		IF (@idPat IS NULL)
			BEGIN
				PRINT 'No existe un paciente registrado con ese DNI';
				RETURN;
			END

		IF (@idDoc IS NULL)
			BEGIN
				PRINT 'No existe un doctor registrado con ese nombre (' + @doctName + ')';
				RETURN;
			END

		DECLARE @hourDiff INT;
		SELECT @hourDiff = hourDiff FROM 
			(SELECT DATEDIFF(HOUR, @aptDate, aptDate) AS hourDiff
			FROM View_DocApt WHERE docName = @doctName) sub
		WHERE hourDiff BETWEEN 0 AND 2;

		IF (@hourDiff IS NOT NULL)
			BEGIN
				PRINT 'No hay turno disponible a esa hora con doctor (' + @doctName + ')';
				RETURN;
			END

		IF (@aptDate <= CURRENT_TIMESTAMP) 
			BEGIN
				PRINT 'Fecha/Hora debe ser mayor a este momento';
				RETURN;
			END

		BEGIN
			BEGIN TRY
				INSERT INTO Appointment VALUES (@aptDate, 2, @observation);
				--SCOPE_IDENTITY() -> Devuelve ultimo valor id (aptId)
				INSERT INTO Apt_PatRelation VALUES (SCOPE_IDENTITY(), @idPat, @idDoc);
			END TRY
			BEGIN CATCH  
				PRINT 'Ha ocurrido un error: ' + ERROR_MESSAGE();
			END CATCH 
		END
	END;
GO

--Creara el appointment e insertara la informacion en la tabla relacionada
EXEC I_newAppointment 1005678901, 'Juan Perez', '20250425 12:59';
--Lanzara mensaje ya que la hora no esta disponible
EXEC I_newAppointment 1002345678, 'Juan Perez', '20250425 13:59';
--Lanzara mensaje ya que no hay paciente con ese dni
EXEC I_newAppointment 1584588, 'Maria Gonzalez', '20250925 13:59';
--Lanzara mensaje ya que no existe un doctor con ese nombre
EXEC I_newAppointment 1005678901, 'Mamma mohnda', '20250829 05:59';

--Crear store procedure para obtener turnos de un paciente mostrando doctor
CREATE PROC S_Appointments (@patDni BIGINT) AS
	BEGIN 
		DECLARE @idPat INT;
		SELECT @idPat = id FROM Patient WHERE dni = @patDni;
		IF (@idPat IS NOT NULL)
			BEGIN
				SELECT pat.dni, CONCAT_WS(' ', doc.doctName, doc.doctLastName) AS docName, apt.aptDate, apt.aptStatus, apt.aptObservation
				FROM Apt_PatRelation rel
				INNER JOIN Patient pat ON pat.id = rel.idPatient AND pat.id = @idPat
				INNER JOIN Doctor doc ON doc.idDoct = rel.idDoctor
				INNER JOIN Appointment apt ON apt.aptId = rel.idAppointment
			END
	END;
GO

EXEC S_Appointments 1005678901;
EXEC S_Appointments 1002345678;
EXEC S_Appointments 1007890123;

--Crear store procedure para actualizar estado de un turno a partir del nombre del mismo
CREATE PROC U_Appointments (@idApt INT, @statusName SHORT_TXT) AS
	BEGIN 
		DECLARE @idStatus INT;
		SET @statusName = CONCAT(UPPER(LEFT(@statusName, 1)), LOWER(RIGHT(@statusName, LEN(@statusName)-1)));
		SELECT @idStatus = statusId FROM AptStatus WHERE statusDescrip = @statusName;
		IF (@idStatus IS NOT NULL)
			BEGIN
				UPDATE Appointment SET aptStatus = @idStatus WHERE aptId = @idApt; 
			END
	END;
GO

EXEC U_Appointments 2, 'postergado';
EXEC U_Appointments 8, 'CANCELADO';
EXEC U_Appointments 11, 'Rechazado';

--Crear store procedure para eliminar turno (mostrar si si se elimino, no borrar cuando afecte mas 1 registro)
CREATE PROC D_Appointment (@idApt INT) AS
	BEGIN 
		DECLARE @deletedRows INT;
		BEGIN TRAN
			DELETE Appointment WHERE aptId = @idApt; 
			SET @deletedRows = @@ROWCOUNT; 

			IF (@deletedRows = 0)
				BEGIN
					PRINT 'No han habido cambios';
					ROLLBACK TRAN;
				END
			ELSE IF (@deletedRows = 1)
				BEGIN
					PRINT 'Columna eliminada (' + CAST(@idApt AS VARCHAR) + ')';
					COMMIT TRAN;
				END
			ELSE
				BEGIN
					PRINT 'Operacion cancelada';
					ROLLBACK TRAN;
				END
	END;
GO

EXEC D_Appointment 9;
EXEC D_Appointment 155;