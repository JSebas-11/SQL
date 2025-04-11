--Clausulas DML SQL (Data Manipulation Language)

--TOP (n) -> Retorna n cantidad de registros
--Retornar los primeros 3 registros de pacientes
SELECT TOP(3) * FROM Patient;

--ORDER BY field ASC/DESC -> Ordenar por campo especifico
--Retornar los regitros ordenados por fecha nacimiento de manera ascendente
SELECT * FROM Patient
ORDER BY birthDate ASC;
--Retornar los regitros ordenados por nombre y apellido de manera descendente
SELECT * FROM Patient
ORDER BY patName DESC, patLastName DESC;

--TOP + ORDER BY
--Retornar los 3 pacientes mas jovenes
SELECT TOP(3) * FROM Patient
ORDER BY birthDate DESC;

--SELECT DISTINCT field -> Solo retorna 1 dato en campos repetidos  
--Retornar las ciudades presentes en Patient sin repetir
SELECT DISTINCT pat.cityCode, ci.cityName FROM Patient AS pat
INNER JOIN City AS ci ON pat.cityCode = ci.code;

--GROUP BY field HAVING condition -> Agrupar de acuerdo a una funcion de agregado
--HAVING -> Aplica la condicion sobre los datos despues de ser agrupados
--Agrupar los pacientes por sus años de nacimientos y retornar la cantidad
SELECT years, COUNT(id) AS Amount
FROM (SELECT *, YEAR(birthDate) AS years FROM Patient) AS Patient2
GROUP BY years;

--WHERE field BETWEEN since AND to -> Incluir rangos (Incluye extremos)
--Retornar pacientes nacido en rangos de fecha especificos
SELECT * FROM Patient
WHERE birthDate BETWEEN '1995' AND '2015'
ORDER BY birthDate ASC;

--Retornar todas las ciudades y la cantidad de pacientes de alli ordenadas descendentemente
SELECT ci.CityName, sub.Amount
FROM City AS ci
LEFT JOIN (SELECT cityCode, COUNT(cityCode) Amount FROM Patient
				GROUP BY cityCode) AS sub
	ON ci.code = sub.cityCode
ORDER BY 2 DESC;