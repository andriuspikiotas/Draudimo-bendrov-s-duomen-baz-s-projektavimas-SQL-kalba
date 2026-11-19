DROP VIEW IF EXISTS Klientu_info;
DROP VIEW IF EXISTS Apie_zalas;
DROP TABLE IF EXISTS Zala CASCADE;
DROP TABLE IF EXISTS DraudimoPolisas CASCADE;
DROP TABLE IF EXISTS Draudikas CASCADE;
DROP TABLE IF EXISTS Klientas CASCADE;
DROP INDEX IF EXISTS Ind_Asm_kod;
DROP INDEX IF EXISTS Ind_vard;


CREATE TABLE Klientas(
	Kliento_id SERIAL PRIMARY KEY, 
	Asmens_kodas VARCHAR(50) NOT NULL,
	Tel_Nr VARCHAR(50) NOT NULL
		CHECK (Tel_Nr LIKE '+370%'),
	Vardas VARCHAR(50) NOT NULL,
	Pavarde VARCHAR(50) NOT NULL);
	

CREATE TABLE Draudikas(
	Draudiko_id SERIAL PRIMARY KEY,
	Pavadinimas VARCHAR(50) NOT NULL,
	El_pastas VARCHAR(50),
	Miestas VARCHAR(50) NOT NULL,
	Tel_Nr VARCHAR(50) );
	
	
CREATE TABLE DraudimoPolisas (
	Poliso_Nr SERIAL PRIMARY KEY,
	Tipas VARCHAR(50) DEFAULT 'Transporto'
		CHECK (Tipas IN ('Transporto','Gyvybes','Sveikatos','Civilinis','Kelioniu','Turto')),
	Kaina REAl NOT NULL,
	Suma INT NOT NULL
		CHECK (Suma BETWEEN 0 AND 100000),
	Pradzia DATE NOT NULL,
	Pabaiga DATE NOT NULL,
	Draudiko_id INT REFERENCES Draudikas(Draudiko_id),
	Kliento_id INT REFERENCES Klientas(Kliento_id) );


CREATE TABLE Zala (
	Zala_id SERIAL PRIMARY KEY,
	Statusas VARCHAR(50) DEFAULT 'Pateikta'
		CHECK (Statusas IN ('Pateikta','Nagrinejama','Patvirtinta','Ismoketa','Atmesta')),
	Data DATE,
	Dydis INT NOT NULL
		CHECK (Dydis<=100000),
	Kliento_id INT REFERENCES Klientas(Kliento_id),
	Poliso_Nr INT REFERENCES DraudimoPolisas(Poliso_Nr));
	


INSERT INTO Klientas (Asmens_kodas, Tel_Nr, Vardas, Pavarde) VALUES
('38901011234', '+37061234567', 'Jonas', 'Jonaitis'),
('49002021234', '+37062345678', 'Petras', 'Petraitis'),
('38503031234', '+37063456789', 'Ona', 'Onaitė'),
('49604041234', '+37064567890', 'Tomas', 'Tomaitis'),
('38705051234', '+37065678901', 'Rasa', 'Rasaitė'),
('49806061234', '+37066789012', 'Lukas', 'Lukauskas'),
('38907071234', '+37067890123', 'Ieva', 'Ievaitė'),
('49008081234', '+37068901234', 'Matas', 'Mataitis'),
('39109091234', '+37069012345', 'Greta', 'Gretaitė'),
('49210101234', '+37060123456', 'Vilius', 'Viliauskas');


INSERT INTO Draudikas (Pavadinimas, El_pastas, Miestas, Tel_Nr) VALUES
('Lietuvos Draudimas', 'info@ld.lt', 'Vilnius', '+37052345678'),
('ERGO', 'info@ergo.lt', 'Kaunas', '+37052456789'),
('Compensa', 'info@compensa.lt', 'Vilnius', '+37052567890'),
('BTA', 'info@bta.lt', 'Klaipėda', '+37052678901'),
('Gjensidige', 'info@gjensidige.lt', 'Vilnius', '+37052789012');


INSERT INTO DraudimoPolisas (Tipas, Kaina, Suma, Pradzia, Pabaiga, Draudiko_id, Kliento_id) VALUES
('Transporto',  45.00, 15000, '2024-01-01', '2025-01-01', 1, 1),
('Sveikatos',   30.00, 10000, '2024-02-01', '2025-02-01', 2, 2),
('Gyvybes',     60.00, 50000, '2024-01-15', '2025-01-15', 3, 3),
('Turto',       55.00, 80000, '2024-03-01', '2025-03-01', 4, 4),
('Kelioniu',    20.00,  5000, '2024-04-01', '2024-10-01', 5, 5),
('Civilinis',   35.00, 20000, '2024-01-01', '2025-01-01', 1, 6),
('Transporto',  50.00, 18000, '2024-05-01', '2025-05-01', 2, 7),
('Sveikatos',   25.00,  8000, '2024-06-01', '2025-06-01', 3, 8),
('Turto',       70.00, 95000, '2024-02-15', '2025-02-15', 4, 9),
('Kelioniu',    15.00,  3000, '2024-07-01', '2024-12-01', 5, 10);


INSERT INTO Zala (Statusas, Data, Dydis, Kliento_id, Poliso_Nr) VALUES
('Ismoketa',    '2024-03-15', 5000,  1,  3),
('Nagrinejama', '2024-04-20', 3000,  2,  5),
('Atmesta',     '2024-02-10', 1000,  3,  7),
('Patvirtinta', '2024-05-05', 8000,  4,  1),
('Pateikta',    '2024-06-01', 2000,  5,  9),
('Ismoketa',    '2024-03-20', 6000,  6,  2),
('Nagrinejama', '2024-07-15', 4000,  7,  4),
('Pateikta',    '2024-08-01', 1500,  8,  6),
('Patvirtinta', '2024-04-10', 9000,  9,  8),
('Atmesta',     '2024-05-25', 500,  10, 10);



CREATE VIEW Apie_zalas AS
	SELECT zala.statusas, SUM(dydis) AS Bendra_zala, SUM(Kaina) AS Bendra_Kaina
	FROM zala 
		LEFT JOIN klientas ON zala.kliento_id=klientas.kliento_id
		LEFT JOIN DraudimoPolisas on zala.Poliso_Nr=DraudimoPolisas.Poliso_Nr
	GROUP BY zala.statusas;


CREATE VIEW Klientu_info AS
	WITH sk AS
		(SELECT Vardas, Pavarde, Kaina,AVG(Kaina) OVER() AS Vidurkis
		 FROM Klientas
		 	LEFT JOIN DraudimoPolisas ON Klientas.Kliento_Id=DraudimoPolisas.Kliento_Id)
	SELECT Vardas, Pavarde
	FROM sk
	WHERE Kaina>Vidurkis;	

CREATE UNIQUE INDEX Ind_Asm_kod ON Klientas(Asmens_kodas);
CREATE INDEX Ind_Vard ON KLientas(Vardas);


-- 1) Surasti visus draudimo polisus pagal draudimo tipa
SELECT Poliso_Nr
FROM DraudimoPolisas
WHERE Tipas='Transporto';

-- 2) Surasti visu klientu asmens kodus pagal zalos statusa ir dydi
SELECT Asmens_kodas
FROM Zala 
	JOIN Klientas ON Zala.Kliento_id=Klientas.Kliento_id
WHERE Statusas='Ismoketa' AND Dydis>1000;

-- 3) Surasti zalas, kurios iyvko siais metais
SELECT Zala_id
FROM Zala
WHERE EXTRACT(YEAR FROM Data)=EXTRACT(YEAR FROM CURRENT_DATE);

-- 4) Ivesti nauja zala
INSERT INTO Zala (Statusas, Data, Dydis, Kliento_id, Poliso_Nr) VALUES
('Pateikta','2026-05-14',40000,3,5);

-- 5) Uzregistruoti nauja klienta
INSERT INTO Klientas (Asmens_kodas, Tel_Nr, Vardas, Pavarde) VALUES
('49210101255','+37052344891','Simas','Simaitis');

-- 6) Sukurti nauja polisa
INSERT INTO DraudimoPolisas (Tipas, Kaina, Suma, Pradzia, Pabaiga, Draudiko_id, Kliento_id) VALUES
('Gyvybes','40',15000,'2024-03-20','2030-04-30',3,6);

-- 7) Atnaujinti zalos statusa
UPDATE Zala
SET Statusas='Patvirtinta'
WHERE Zala_id=8;

-- 8) Atnaujinti draudiko telefono numeri
UPDATE Draudikas
SET Tel_Nr='+37052345858'
WHERE Draudiko_id=4;

-- 9) Atnaujinti draudiko miesta
UPDATE Draudikas
SET Miestas='Kaunas'
WHERE Draudiko_id=4;

-- 10) Istrinti zalas pagal statusa
DELETE FROM Zala
WHERE Statusas='Atmesta';




