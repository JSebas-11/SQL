--LOGINS -> Credencial de acceso a instancia del servidor
--USERS -> Permite a un login acceder a una DB específica, login debe estar vinculado a un usuario para ejecutar acciones.

--SQL LOGIN
CREATE LOGIN Login1 WITH PASSWORD = 'Password';
--Windows Login
CREATE LOGIN [DOMAIN\usuario] FROM WINDOWS;
--User para ese login
USE db;
GO
CREATE USER User1 FOR LOGIN Login1;

--ROLES:
--Server Roles -> Afectan a todo el servidor
--	sysadmin -> Acceso total (administrador).
--	serveradmin -> Configura opciones de servidor.
--  securityadmin -> Gestiona logins y permisos de servidor.
--  dbcreator -> Puede crear, alterar y restaurar bases de datos.
--  bulkadmin -> Puede ejecutar operaciones BULK INSERT.
ALTER SERVER ROLE sysadmin ADD MEMBER User1;
ALTER SERVER ROLE sysadmin DROP MEMBER User1;

--DB Roles -> Afecta una db especifica
ALTER ROLE db_datareader ADD MEMBER User1; --Lectura
ALTER ROLE db_datawriter ADD MEMBER User1; --Escritura
ALTER ROLE db_denydatareader DROP MEMBER User1; --No lectura
ALTER ROLE db_denydatawriter DROP MEMBER User1; --No escritura
ALTER ROLE db_ddladmin DROP MEMBER User1; --Crear/modificar objetos
ALTER ROLE db_owner ADD MEMBER User1; --Permisos totales

--User Defined Roles
CREATE ROLE MyRol AUTHORIZATION dbo -- <- Gestor rol;
--SELECT -> Otorgar lectura / INSERT -> inserccion / UPDATE -> actualizacion / DELETE -> eliminacion <- en x tabla
GRANT UPDATE, ALTER ON table1 TO MyRol;
--Permitir ejecutar procedimiento
GRANT EXECUTE ON sp_Stored TO MyRol;

--SELECT -> Negar lectura / INSERT -> inserccion / UPDATE -> actualizacion / DELETE -> eliminacion <- en x tabla
DENY UPDATE, ALTER ON table1 TO MyRol;

ALTER ROLE MyRol ADD MEMBER User1;

--Eliminar 
DROP USER User1;
DROP LOGIN Login1;
--Ver users y logins
SELECT * FROM sys.server_principals WHERE type_desc = 'SQL_LOGIN';
SELECT * FROM sys.database_principals WHERE type_desc = 'SQL_USER';

--SCHEMAS --> Namespace que agrupa objetos de la DB (dbo es default y tiene acceso a todo)
CREATE SCHEMA sch1 AUTHORIZATION dbo;
--Asignar usuario al esquema
ALTER USER UserSch1 WITH DEFAULT_SCHEMA = sch1;
--Crear usuario con esquema
CREATE USER UserSch2 FOR LOGIN Login1 WITH DEFAULT_SCHEMA = sch1;
--Asignar tablas a esquema
ALTER SCHEMA sch1 TRANSFER table2;

--SQL SERVER PROFILER <- Especie de debug para monitorear procesos (tools -> SqlSeverProfiler)