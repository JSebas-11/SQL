--STORED PROCEDURES -> Bloque en el que podemos encapsular instrucciones para ser llamada en cualquier momento,
--	puede recibir parametros, retornar o no valores, ejecutar consultas SELECT, INSERT, UPDATE y DELETE y manejar transacciones

--DROP PROC S_Patient;
--Procedure para obtener info paciente por su dni
CREATE PROC S_Patient (@dni BIGINT) AS 
BEGIN
	SELECT * FROM Patient WHERE dni = @dni
END;
GO --Delimitador de instrucciones

EXEC S_Patient 1005678901;

--DROP PROCEDURE S_ownedMoney;
--Procedure que a partir de un dni retorne el dinero que debe ese paciente
CREATE PROC S_ownedMoney
	(@dni BIGINT, @money MONEY OUTPUT) AS
BEGIN
	--AsignaR variable money al retorno que haya cumplido con todas las condiciones
	SELECT @money = payInf.amount FROM Patient AS pat
		--Relacionar las tablas Patient y Pay_AptRelation por medio del ID del paciente  
		INNER JOIN Pay_AptRelation AS payApt ON pat.id = payApt.idPatient
		--Relacionar las tablas Pay_AptRelation y payInf (y a su vez patient ya que esta se relaciono payApt)
		--	por medio del ID del pago
		INNER JOIN (SELECT pay.idPay, pay.amount, pays.payDescrip FROM Payment AS pay
					INNER JOIN PayStatus AS pays ON pay.payStatus = pays.paymentId) AS payInf
		--payInf es tabla intermediaria para relacionar el pago y su estado
			ON payInf.idPay = payApt.idPayment
	--Filtramos los resultados para obtener pacientes que no haya pagado y el que cumpla con el mismo dni
	WHERE payInf.payDescrip != 'Completado' AND pat.dni = @dni;
END;
GO

--VARIABLES
--Declaracion e inicializacion (init opcional, sera NULL)
DECLARE @owedMoney MONEY = 0;
--Definir
-- SET @owedMoney = 0

IF @owedMoney IS NULL 
	SET @owedMoney = 0;

--Paciente con este id tiene ya ha pagado (debe devolver 0)
DECLARE @dniToEvaluate BIGINT = 1005678901;
EXEC S_ownedMoney @dniToEvaluate, @owedMoney OUTPUT
PRINT 'Patient (' + CAST(@dniToEvaluate AS VARCHAR) + '): ' + CAST(@owedMoney AS VARCHAR);

--Paciente con este id no registra appointments (debe devolver 0)
SET @dniToEvaluate = 1009012345;
EXEC S_ownedMoney @dniToEvaluate, @owedMoney OUTPUT
PRINT 'Patient (' + CAST(@dniToEvaluate AS VARCHAR) + '): ' + CAST(@owedMoney AS VARCHAR);

--Paciente con este id no ha pagao (debe devolver el valor de deuda)
SET @dniToEvaluate = 1008901234;
EXEC S_ownedMoney @dniToEvaluate, @owedMoney OUTPUT
PRINT 'Patient (' + CAST(@dniToEvaluate AS VARCHAR) + '): ' + CAST(@owedMoney AS VARCHAR);