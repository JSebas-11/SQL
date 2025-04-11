 --Built in Functions
--String Functions
DECLARE @example VARCHAR(20) = 'soy un ejemplo';
PRINT LEFT(@example, 2); --> Obtener n chars desde la izquierda
PRINT RIGHT(@example, 3); --> Obtener n chars desde la derecha
PRINT SUBSTRING(@example, 2, 5) --> Obtener chars en rango dado
PRINT LEN(@example); --> Obtener longitud de string
PRINT LOWER(@example); --> Convertir a minuscula
PRINT UPPER(@example); --> Convertir a mayuscula
PRINT REPLACE(@example, 'o', 'a');
PRINT REPLICATE(@example, 2); --> Repetir string n veces

DECLARE @example2 VARCHAR(20) = '  y soy OTRO ejemplo  ';
PRINT LTRIM(@example2); --> Eliminar espacios blanco a la izq
PRINT RTRIM(@example2); --> Eliminar espacios blanco a la der
SET @example2 = TRIM(@example2); --> Eliminar espacios blanco a la izq y der
PRINT @example2; 

PRINT CONCAT(@example, @example2); --> Concatenar campos
PRINT CONCAT_WS(' ', @example, @example2); --> Concatenar campos con separador

--Date Functions
DECLARE @now DATE = GETDATE();  
PRINT @now;
PRINT ISDATE(GETDATE());
PRINT ISDATE('2078,1,201');
PRINT GETUTCDATE();
PRINT YEAR(@now);
PRINT MONTH(@now);
PRINT DAY(@now);
PRINT DATEADD(YEAR, -2, @now); --> Agregar o quitar n dias, meses, etc a un campo Date
PRINT DATEDIFF(MONTH, @now, '20281201'); --> Diferencia entre dos Dates en dias, meses, etc
PRINT DATEPART(DW, @now); --> Obtener dia, dw(DayWeek), mes, etc

--Conversion Functions
DECLARE @money MONEY = 799.12;
PRINT CAST(@money AS INT)
PRINT CONVERT(INT, @money)

--Date Formats:
--		Existen muchos tipos de Standar Date Format (numero 3er parametro Convert)
DECLARE @date DATETIME = GETDATE();
PRINT CONVERT(VARCHAR(32), @date, 3);

--User Defined Functions: Utiliza sentencia SELECT ya que no puede modificar datos
--Tipo Escalar: Retornan un valor
CREATE FUNCTION FULLNAME(@name SHORT_TXT, @lastName SHORT_TXT)
	RETURNS SHORT_TXT AS
	BEGIN
		RETURN CONCAT_WS(' ', @name, @lastName);
	END;
GO

SELECT dbo.FULLNAME(patName, patLastName) AS patName FROM Patient;

CREATE FUNCTION GETCITY(@dni BIGINT)
	RETURNS SHORT_TXT AS
	BEGIN
		DECLARE @city SHORT_TXT;
		SELECT @city = c.CityName 
		FROM Patient p
		INNER JOIN City c ON c.code = p.cityCode
		WHERE p.dni = @dni;
		RETURN @city;
	END;
GO

SELECT dbo.FULLNAME(patName, patLastName) AS patName, dbo.GETCITY(dni) AS city FROM Patient;

CREATE FUNCTION STRINGDATE(@date DATETIME)
	RETURNS SHORT_TXT AS
	BEGIN
		DECLARE @day VARCHAR(16) = (CASE 
				WHEN DATEPART(DW, @date) = 1 THEN 'Sunday'
				WHEN DATEPART(DW, @date) = 2 THEN 'Monday'
				WHEN DATEPART(DW, @date) = 3 THEN 'Tuesday'
				WHEN DATEPART(DW, @date) = 4 THEN 'Wednesday'
				WHEN DATEPART(DW, @date) = 5 THEN 'Thursday'
				WHEN DATEPART(DW, @date) = 6 THEN 'Friday'
				WHEN DATEPART(DW, @date) = 7 THEN 'Saturday'
			END)
		DECLARE @month VARCHAR(16) = (CASE 
				WHEN MONTH(@date) = 1 THEN 'January'
				WHEN MONTH(@date) = 2 THEN 'February'
				WHEN MONTH(@date) = 3 THEN 'March'
				WHEN MONTH(@date) = 4 THEN 'April'
				WHEN MONTH(@date) = 5 THEN 'May'
				WHEN MONTH(@date) = 6 THEN 'June'
				WHEN MONTH(@date) = 7 THEN 'July'
				WHEN MONTH(@date) = 8 THEN 'August'
				WHEN MONTH(@date) = 9 THEN 'September'
				WHEN MONTH(@date) = 10 THEN 'October'
				WHEN MONTH(@date) = 11 THEN 'November'
				WHEN MONTH(@date) = 12 THEN 'December'
			END)

		RETURN @day + ' ' + CAST(DAY(@date) AS VARCHAR) + '/' + @month + + '/' + CAST(YEAR(@date) AS VARCHAR)
		END;
GO

--Tipo Tabla: Retornan conjunto de registros
CREATE FUNCTION GET_APTS_BY_STAT(@status INT)
	RETURNS TABLE AS
	RETURN(
		SELECT apt.aptId, apt.aptDate, apt.aptStatus, st.statusDescrip, apt.aptObservation 
		FROM Appointment apt
		INNER JOIN AptStatus st ON st.statusId = apt.aptStatus AND st.statusId = @status)
GO

SELECT * FROM GET_APTS_BY_STAT(1);
SELECT * FROM GET_APTS_BY_STAT(5);
SELECT * FROM GET_APTS_BY_STAT(99)