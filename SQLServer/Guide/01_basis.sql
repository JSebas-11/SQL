--DATABASES: 
--	Tablas se compone de: Campos(Columnas) y Registros (Filas)
--	Valores NULL: Representam la ausencia de un valor en un campo (son distintos a whiteValues)
--	Primary Key: Identifica de manera unica a un registro en la tabla
--		Caracteristicas: Valor unico, NOT NULL, varios campos pueden ser PK (Clave compuesta)
--	Foreing Key: Es una referencia entre tablas en la que una FK es la PK de la otra tabla
--		Caracteristicas: Mismo tipo dato de campo relacionado, puede ser NULL, una tabla puede tener varias FK

--NORMALIZACION (Las primeras 3 mas comunes):
--	1st NF: Cada campo debe tener un valor unico para cada registro (No listas o estructura datos)
--	2nd NF: Cada campo debe depender completamente de la PK
--	3rd NF: Cada campo no debe depender de otro campo que no sea PK

--DATA TYPES:
--	Numéricos:
--		Enteros: TINYINT (1 byte), SMALLINT (2 bytes), INT (4 bytes), BIGINT (8 bytes)
--		Decimales: DECIMAL (p,s), NUMERIC(p,s) ? Precisión definida por el usuario (p: total de dígitos, s: decimales)
--		Flotante: FLOAT (8 bytes), REAL (4 bytes)
--		Moneda: MONEY  (8 bytes), SMALLMONEY (4 bytes)
--	Caracteres y cadenas:
--		Longitud fija: CHAR(n) ? n caracteres de longitud fija (1 a 8,000), NCHAR(n) ? n caracteres Unicode (2 bytes por carácter)
--		Longitud variable: VARCHAR(n) ? n caracteres, usa solo espacio necesario (1 a 8,000), NVARCHAR(n) ? n caracteres Unicode
--	Fechas-horas:
--		DATE ? Solo fecha (año 0001-9999)
--		DATETIME ? Fecha y hora precisión de 3.33 milisegundos
--		SMALLDATETIME ? Fecha y hora con precisión de 1 minuto
--		TIME(n) ? Solo hora (precisión de hasta 7 decimales)
--	Binarios:
--		BINARY(n) ? Almacena datos binarios de longitud fija
--		VARBINARY(n) ? Almacena datos binarios de longitud variable
--		VARBINARY(max) ? Hasta 2^31-1 bytes (2 GB)
--	Especiales:
--		BIT ? Puede almacenar 0, 1 o NULL (usa 1 bit)
--		GEOMETRY ? Datos geometricos como puntos, líneas y poligonos
--		GEOGRAPHY ? Coordenadas geograficas (latitud/longitud)
--		HIERARCHYID ? Representa estructuras jerarquicas (como grafos o arboles)

--ARITHMETIC OPERATORS: +  -  /  *  %

--COMPARISON OPERATORS: >  >=  <  <=  =  <> <- Distinto 

--LOGIC OPERATORS:
--	AND / OR / NOT / BETWEEN / IN (dataSet)
--	LIKE '' Comodines: % <- Cualquier cantidad de cualquier char
--					   _ <- Cualquier char
--					   [] <- Conjunto caracteres permitidos / [^] <- Conjunto caracteres NO permitidos / [-] <- Rangos

--Archivo MDF (Master Data File): El archivo MDF es el principal archivo de datos de una base de datos en SQL Server, ya
--	que contiene las tablas, índices, procedimientos almacenados y otros objetos de la base de datos.
--Archivo LDF (Log Data File): El archivo LDF es el archivo de registro de transacciones de una base de datos en SQL Server.
--	Registra todas las transacciones y cambios realizados en la base de datos, lo que permite la recuperación y la
--	restauración de la misma en caso de fallos o pérdida de datos.

--USER DATA TYPES: (Util para evitar confusiones cuando varios usuarios manipulan la tabla)
--	CREATE TYPE name FROM type null/not null

--FK CONSTRAINS:
--ON DELETE -> Definir comportamiento al borrar un registro en tabla padre
--		CASCADE -> Borrar automaticamente / SET NULL / SET DEFAULT / RESTRICT -> Impide eliminar / NO ACTION -> Lanza error
--ON UPDATE -> Definir comportamiento al actualizar un registro en tabla padre
--		CASCADE -> Actualiza automaticamente / SET NULL / SET DEFAULT / RESTRICT -> Impide actualizar / NO ACTION -> Lanza error

--JOINS:
--	INNER --> Registros que cumplen condicion en campo comun
--		SELECT fields FROM table1 INNER JOIN table2 ON table1.field = table2.field

--	LEFT/RIGHT --> Todos registros tabla LEFT/RIGHT si no coincide en tabla2 NULL
--		SELECT fields FROM table1 LEFT/RIGHT JOIN table2 ON table1.field = table2.field

--	FULL OUTER --> Todos registros tabla1 y 2 si no coincide NULL
--		SELECT fields FROM table1 FULL OUTER JOIN table2 ON table1.field = table2.field

--	CROSS --> Combina registros de tabla1 con tabla2 (producto cartesiano)
--		SELECT fields FROM table1 CROSS JOIN table2 ON table1.field = table2.field

--UNIONS: Unir consultas (deben tener misma cantidad de campos y tipo)
--	UNION ALL -> Todos los registros incluyendo repetidos
--		query1 UNION ALL query2
--	UNION -> Todos los registros unificando repetidos
--		query1 UNION query2

--SP PROCESS:
--Obtener informacion de objetos (tablas, vistas, procesos, etc...) en la database
SP_HELP Patient;
--Contenido de funciones, procesos, etc...
SP_HELPTEXT I_newPatient;

--TRANSACTIONS: Evaluar porcion de codigo para confirmar o revertir cambios
--BEGIN TRAN --> 'Congela' la tabla afectada hasta ejecutar un commit o rollback
--	UPDATE, DELETE, ETC
--IF () COMMIT TRAN / ROLLBACK TRAN 
--SAVE TRAN name --> Crear punto de guardado en la transaccion
--ROLLBACK TRAN name --> Hacer rollback parcial hasta cierto punto dentro de la tran

--@@TRANCOUNT -> Obtener numero transacciones activas
--@@ROWCOUNT -> Obtener cantidad registros modificados en consulta previa
--@@ERROR -> Obtener cantidad errores, si los hubo
--SCOPE_IDENTITY() -> ID ultimo registro modificado