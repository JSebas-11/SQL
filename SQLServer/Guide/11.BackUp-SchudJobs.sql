--BACKUP -> Crear un respaldo de DB
--	full -> Todo / diferential -> Agrega cambios realizados a full backup previo

BACKUP DATABASE MedicalCenter
TO DISK = 'path + .bak/.trn'
WITH COMPRESSION --/ NO_COMPRESSION / DIFERENTIAL 
, NAME = 'newName'

RESTORE DATABASE MedicalCenter
FROM DISK = 'path'
WITH REPLACE --/ NORECOVERY / RECOVERY

--SCHEDULED JOBS -> Tarea que se programa para ejecutarse automáticamente a 
--	una hora y fecha específicas (o repetidamente) a través del 
--	SQL Server Agent (administrador tareas programadas).

--Componentes:
--	Steps -> Acciones que realiza el Job 
--	Schedules -> Cuándo y con qué frecuencia se ejecuta
--	Alerts -> Notificaciones o condiciones que activan el Job
--	Notifications -> Qué hacer al finalizar (enviar correo, escribir en log, etc.)

EXEC SP_ADD_JOB @job_name = 'Job'; --Inicializar JOB

EXEC SP_ADD_JOBSTEP --Agregar accion
	@job_name = 'Job',
	@step_name = 'step1',
	@subsystem = 'TSQL',
	@command = '{StoredProcedure, backup, etc}',
	@database_name = 'MedicalCenter';

EXEC SP_ADD_SCHEDULE
    @schedule_name = 'everyDay1AM',
    @freq_type = 8, -- 1 -> Solo 1 vez / 4 -> Diario / 8 -> Semanal / 16 -> Mensual / 32 -> Mensual relativo
    @freq_interval = 9, -- 1 -> Domingo / 2 -> Lunes / 4 -> Martes / 8 -> Miercoles / 16 -> Jueves / 32 -> Viernes / 64 -> Sabado
	@active_start_time = 020000;
    --@freq_subday_type -> Si se ejecuta varias veces al día
	--@freq_subday_interval	-> Intervalo de minutos/segundos
	--@active_start_date -> Fecha en que empieza a estar activo
	--@active_start_time -> Hora en que se ejecuta (en formato HHMMSS)
	--@active_end_date -> Fecha en que deja de estar activo (opcional)
	--@active_end_time -> Hora en que deja de ejecutarse (opcional)

EXEC SP_ATTACH_SCHEDULE --Vincular schedule con job
    @job_name = 'Job',
    @schedule_name = 'everyDay1AM';

EXEC SP_ADD_JOBSERVER
    @job_name = 'Job';

--CREAR JOB QUE ELIMINE TURNOS VENCIDOS (Fecha actual - 1 mes)
CREATE PROC D_ExpiredApts
	AS
	BEGIN 
		DELETE Appointment WHERE DATEDIFF(WEEK, aptDate, GETDATE()) > 4
	END;
GO

EXEC msdb.dbo.SP_ADD_JOB @job_name = 'CancelExpiredApts';

EXEC msdb.dbo.SP_ADD_JOBSTEP 
	@job_name = 'CancelExpiredApts',
	@step_name = 'process',
	@subsystem = 'TSQL',
	@command = 'EXEC D_ExpiredApts',
	@database_name = 'MedicalCenter';

EXEC msdb.dbo.SP_ADD_SCHEDULE
    @schedule_name = 'once',
    @freq_type = 1,
	@active_start_time = 125000

EXEC msdb.dbo.SP_ATTACH_SCHEDULE
    @job_name = 'CancelExpiredApts',
    @schedule_name = 'once';

EXEC msdb.dbo.SP_ADD_JOBSERVER
    @job_name = 'CancelExpiredApts';

SELECT name, enabled 
FROM msdb.dbo.sysjobs
WHERE name = 'CancelExpiredApts';

EXEC msdb.dbo.SP_DELETE_JOB 
    @job_name = 'CancelExpiredApts';

SELECT * FROM Appointment;