INSERT INTO City 
VALUES ('Bogota', 'Bogota D.C.', DEFAULT),
	('Medellin', 'Antioquia', DEFAULT),
	('Cali', 'Valle del Cauca', DEFAULT),
	('Barranquilla', 'Atlantico', DEFAULT),
	('Cartagena', 'Bolivar', DEFAULT),
	('Cucuta', 'Norte de Santander', DEFAULT),
	('Bucaramanga', 'Santander', DEFAULT),
	('Pereira', 'Risaralda', DEFAULT),
	('Santa Marta', 'Magdalena', DEFAULT),
	('Ibague', 'Tolima', DEFAULT),
	('Manizales', 'Caldas', DEFAULT),
	('Pasto', 'Narinho', DEFAULT),
	('Neiva', 'Huila', DEFAULT),
	('Villavicencio', 'Meta', DEFAULT),
	('Armenia', 'Quindio', DEFAULT),
	('Valledupar', 'Cesar', DEFAULT),
	('Monteria', 'Cordoba', DEFAULT),
	('Sincelejo', 'Sucre', DEFAULT),
	('Popayan', 'Cauca', DEFAULT),
	('Riohacha', 'La Guajira', DEFAULT);
SELECT * FROM City;

INSERT INTO Patient
VALUES (1055848701, 'Jose', 'Melaso', '1995-04-21', 'Calle 11 #47-21', 2, 3148679231, 'jose.mela@example.com', 'Revision sonda anal.'),
	(1001234567, 'Carlos', 'Gomez', '1985-03-12', 'Cra 45 #12-34', 2, 3001234567, 'carlos.gomez@example.com', 'Paciente con alergia a la penicilina.'),
	(1002345678, 'Ana', 'Martinez', '1990-07-22', 'Calle 56 #23-45', 1, 3102345678, 'ana.martinez@example.com', 'Requiere control de presion arterial.'),
	(1003456789, 'Luis', 'Fernandez', '1978-11-05', 'Av. Principal #78-90', 3, 3203456789, 'luis.fernandez@example.com', 'Historial de diabetes tipo 2.'),
	(1004567890, 'Maria', 'Lopez', '2000-02-15', 'Carrera 10 #8-20', 4, 3014567890, 'maria.lopez@example.com', 'Paciente embarazada, tercer trimestre.'),
	(1005678901, 'Javier', 'Rodriguez', '1995-06-30', 'Calle 45 #67-89', 5, 3125678901, 'javier.rodriguez@example.com', 'Revision postoperatoria de rodilla.'),
	(1006789012, 'Laura', 'Hernandez', '1983-09-18', 'Carrera 12 #34-56', 7, 3146789012, 'laura.hernandez@example.com', 'Asma controlada, requiere seguimiento.'),
	(1007890123, 'Fernando', 'Garcia', '1972-12-01', 'Calle 23 #45-67', 8, 3157890123, 'fernando.garcia@example.com', 'Examenes de rutina programados.'),
	(1008901234, 'Paula', 'Ramirez', '1988-05-09', 'Av. Libertador #90-12', 9, 3168901234, 'paula.ramirez@example.com', 'Historial de migrañas frecuentes.'),
	(1009012345, 'Andres', 'Castro', '1993-08-25', 'Calle 67 #89-12', 10, 3179012345, 'andres.castro@example.com', 'Control de colesterol alto.'),
	(1010123456, 'Diana', 'Mejia', '2002-01-10', 'Carrera 14 #23-45', 11, 3180123456, 'diana.mejia@example.com', 'Paciente con escoliosis leve.');

--Lanzara error debido a la restriccion FK con un cityId no registrado en tabla City
INSERT INTO Patient VALUES (1010145456, 'David', 'Sonlos', '2005-01-25', 'Carrera 18 #27-55', 999, 3210123456, 'david.sonlos@example.com', 'Paciente con diarrea cronicamente leve.');

--Al borrar una ciudad de tabla City, los pacientes con ese cityCode se actualizaran a NULL Debido al ON DELETE SET NULL
INSERT INTO Patient VALUES (1010145456, 'Mosquera', 'Mosquera', '1998-09-13', 'Carrera 13 #13-13', 20, 3111123759, 'mosquera.black@example.com', 'Paciente con tono oscuro.');
DELETE City WHERE code = 20;

--Actualizar campos
UPDATE Patient SET cityCode = 1 WHERE patName = 'Paula' AND patLastName = 'Ramirez';

--Vincular tablas Patient-City con un LEFT JOIN
SELECT pat.dni, pat.patName, pat.patLastName, pat.patAddress, ci.cityName, ci.district
FROM Patient AS pat
LEFT JOIN City AS ci ON pat.cityCode = ci.code;

INSERT INTO Speciality
VALUES ('Cardiologia'),
	('Dermatologia'),
	('Gastroenterologia'),
	('Ginecologia'),
	('Neurologia'),
	('Oftalmologia'),
	('Ortopedia'),
	('Pediatria'),
	('Psiquiatria'),
	('Urologia');
SELECT * FROM Speciality;

--Restriccion de FK y borrar Speciality funcionara igual que City-Patient
INSERT INTO Doctor
VALUES ('Juan', 'Perez', 1),
	('Maria', 'Gonzalez', 2),
	('Carlos', 'Ramirez', 3),
	('Esperanza', 'Gomez', 4),
	('Luis', 'Fernandez', 5),
	('Diana', 'Martinez', 6),
	('Pedro', 'Gomez', 7),
	('Laura', 'Hernandez', 8),
	('Javier', 'Vergara', 9),
	('Sofia', 'Castro', 10);

--Vincular tablas Doctor-Speciality con un INNER JOIN
SELECT doc.doctName, doc.DoctLastName, spe.specDescription
FROM Doctor AS doc
INNER JOIN Speciality AS spe ON doc.idSpeciality = spe.idSpec;

INSERT INTO AptStatus
VALUES ('Pendiente'),
	('Realizado'),
	('Cancelado'),
	('Rechazado'),
	('Postergado'),
	('Anulado'),
	('Derivado');
SELECT * FROM AptStatus;

INSERT INTO Appointment
VALUES ('2023-03-15', 1, 'Paciente en ayunas'),
	('2022-01-25', 2, 'Paciente con vida'),
	('2025-02-21', 3, 'Integridad corporal requerida'),
	('2024-11-30', 4, 'Armas de fuego requeridas'),
	('2023-03-11', 5, 'Paciente con prueba de embarazo'),
	('2025-08-09', 6, 'Acompañamiento del FBI'),
	('2022-05-03', 7, 'Ayudas humanitarias'),
	('2024-09-19', 2, 'Paciente narcotrficante');

--Vincular tablas Appointement-Status con un INNER JOIN
SELECT apt.aptId, apt.aptDate, apt.aptObservation, stat.statusDescrip 
FROM Appointment AS apt
INNER JOIN AptStatus AS stat ON apt.aptStatus = stat.statusId;

INSERT INTO Apt_PatRelation
VALUES (2, 7, 3), --Appointment, Patient, Doctor
	(5, 1, 1),
	(3, 10, 2),
	(8, 5, 4),
	(4, 8, 6),
	(7, 3, 9),
	(6, 4, 8);

--Lanzara error ya que no existe doctor con ese id, y asi ocurrira si añadimos algun dato fuera de rango
INSERT INTO Apt_PatRelation VALUES (2, 7, 169);

INSERT INTO PayStatus
VALUES ('Completado'),
	('Pendiente'),
	('Cancelado'),
	('Rechazado');

--Lanzara error ya que no se permiten duplicados
INSERT INTO PayStatus VALUES ('Completado');

INSERT INTO Payment 
VALUES ('Efectivo', '2025-02-20 11:38:00', 88900, 1, 'Pago adelantado en entidad'), --3
	('En linea', '2024-11-30 15:20:00', 125900, 1, 'Pago a traves sucursal en linea'), --4
	('En linea', '2022-05-04 15:20:00', 69000, 4, 'Pago a traves sucursal en linea'); --7

SELECT * FROM Payment;

INSERT INTO Pay_AptRelation
VALUES (1, 3, 5), --Payment, Appointment, Patient
	(2, 4, 1),
	(3, 7, 8);
