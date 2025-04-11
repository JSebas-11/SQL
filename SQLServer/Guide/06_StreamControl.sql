--Condicionales y su estructura basica
DECLARE @doctors INT;
	--Obtener cantidad de doctores registrados y de acuerdo a ello mostrar mensaje
SELECT @doctors = COUNT(*) FROM Doctor; 

IF @doctors = 0
	BEGIN
		PRINT 'There is not doctors'
	END
ELSE IF @doctors = 1
	BEGIN
		PRINT 'There is ' + CAST(@doctors AS VARCHAR) + ' doctor'
	END
ELSE 
	BEGIN 
		PRINT 'There are ' + CAST(@doctors AS VARCHAR) + ' doctors'
	END;

--CASE
DECLARE @numValue INT = 111;
DECLARE @color VARCHAR(64);
set @color = (CASE 
				WHEN @numValue BETWEEN 0 AND 50 THEN 'Red'
				WHEN @numValue BETWEEN 51 AND 100 THEN 'Green'
				WHEN @numValue BETWEEN 101 AND 150 THEN 'Blue'
				ELSE 'Nothing'
			END)
PRINT @color;

--Keyword EXISTS
DECLARE @id INT = 8;

	--Si existe un registro con ese id, mostramos su info
IF EXISTS(SELECT * FROM Patient WHERE id = @id)
	BEGIN
		PRINT 'Patient found';
		SELECT * FROM Patient WHERE id = @id;
	END
ELSE 
	BEGIN
		PRINT 'Patient with id (' + CAST(@id AS VARCHAR) + ') doesnt exist';
	END

--Bucle WHILE
DECLARE @i INT = 1;
DECLARE @patNum INT = 0;
SELECT @patNum = COUNT(*) FROM Patient; 
DECLARE @name VARCHAR(64);
DECLARE @year INT = 0;
	
	--Mostrar nombre completo y año de nacimiento de cada paciente 
	--	salir del bucle si el año es igual a 1988 sin mostrar info patient
	--	no imprimir info patient si el año es 2000
WHILE (@i < @patNum)
	BEGIN
		PRINT 'Iteration ' + CAST(@i AS VARCHAR);
		SELECT @name = CONCAT_WS(' ', patName, patLastName) FROM Patient WHERE id = @i; 
		SELECT @year = YEAR(birthDate) FROM Patient WHERE id = @i;
		SET @i = @i+1; 
		IF @year = 1988 BREAK;
		ELSE IF @year = 2000 CONTINUE;
		PRINT @name + ' - ' + CAST(@year AS VARCHAR);
	END

--TRY CATCH <- Capturar excepciones como en cualquier lenguaje de programacion
	
	--Lanzara un error ya que no se permiten nombre de ciudades repetidos
INSERT INTO City 
VALUES ('Medellin', 'Antioquia', DEFAULT);
	
	--Atraparemos error e informaremos al usuario sin detener el flujo del programa
BEGIN TRY
	INSERT INTO City 
	VALUES ('Medellin', 'Antioquia', DEFAULT);
END TRY
BEGIN CATCH
	PRINT 'Duplicated names are not allowed in (cityName) column';
END CATCH