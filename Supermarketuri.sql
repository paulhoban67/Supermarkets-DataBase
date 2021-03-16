CREATE DATABASE [Supermarketuri]

USE [Supermarketuri]

-- Create Table Locatii
CREATE TABLE Locatii
(	
	Numar INT IDENTITY PRIMARY KEY,
	Denumire VARCHAR(100) NOT NULL,
	Tara VARCHAR(100),
	Oras VARCHAR(100),
	Adresa VARCHAR(100) NOT NULL,
	Telefon VARCHAR(100)
);

-- Create Table Producatori
CREATE TABLE Producatori
(
	Nr INT IDENTITY PRIMARY KEY,
	Denumire VARCHAR(100) NOT NULL,
	Tara VARCHAR(100),
	Oras VARCHAR(100),
	Adresa VARCHAR(100) NOT NULL,
	Telefon VARCHAR(100)
);

-- Create Table Departamente
CREATE TABLE Departamente
(
	Nr INT IDENTITY PRIMARY KEY,
	Nume VARCHAR(100) NOT NULL,
	Locatie INT FOREIGN KEY REFERENCES Locatii(Numar),
	Telefon VARCHAR(10)
);

-- Create Table Produse
CREATE TABLE Produse
(
	Nr INT PRIMARY KEY IDENTITY,
	Denumire VARCHAR(100) NOT NULL,
	Producator INT FOREIGN KEY REFERENCES Producatori(Nr),
	Departament INT FOREIGN KEY REFERENCES Departamente(Nr),
	[Nr Lot] INT,
	Cantitate INT,
	[Pret/Lot] MONEY
);

-- Create Table Angajati
CREATE TABLE Angajati
(
	Id INT IDENTITY PRIMARY KEY,
	Nume VARCHAR(100),
	Prenume VARCHAR(100),
	CNP VARCHAR(100) NOT NULL,
	Functie VARCHAR(100),
	Departament INT FOREIGN KEY REFERENCES Departamente(Nr),
	Telefon VARCHAR(100)
);

--Insert Locatii
INSERT INTO Locatii VALUES ('ManasturShop', 'Romania', 'Cluj-Napoca', 'Strada Mehedinti, nr34', '0425774836');
INSERT INTO Locatii VALUES ('MaramuresShop', 'Romania', 'Baia-Mare', 'Bulevardul Bucuresti, nr11', '0426884596');
INSERT INTO Locatii VALUES ('MilitariShop', 'Romania', 'Bucuresti', 'Aleea Privighetorii, nr3', '0635987426');

--Insert Producatori
INSERT INTO Producatori VALUES ('SC.Cartofi.SRL', 'Romania', 'Ciurila', 'Strada Ciurilei, nr2', '0236559874');
INSERT INTO Producatori VALUES ('SC.Ferma-Zootehnica.SRL', 'Romania', 'Baia-Mare', 'Bulevardul Bucuresti, nr4', '0236548965');
INSERT INTO Producatori VALUES ('SC.Serele-Domnesti.SRL', 'Romania', 'Cluj-Napoca', 'Starda Baneasa', '0256986587');

--Insert Departamente
INSERT INTO Departamente VALUES ('Legume & Fructe', 1, '0325669845');
INSERT INTO Departamente VALUES ('Electrocasnice & IT', 2, '0123654789');
INSERT INTO Departamente VALUES ('Carmangerie', 3, '0769875632');

--Insert Produse
INSERT INTO Produse VALUES ('Cartofi', 1, 1, 234, 1000, 2);
INSERT INTO Produse VALUES ('Rosii', 3, 1, 200, 2000, 3);
INSERT INTO Produse VALUES ('Carne de manzat', 2, 3, 565, 200, NULL);

--Insert Angajati
INSERT INTO Angajati VALUES ('Hoban', 'Paul-Adelin', '533369854625', 'Director Departament', 2, '0756998425');
INSERT INTO Angajati VALUES ('Pop', 'Andrei', '5666325965895', 'Macelar', 3, '0236558965');
INSERT INTO Angajati VALUES ('Doczi', 'Daniel-Mihai', '5000369856235', 'Director Departament', 1, '0756989458');

--Update Angajati
UPDATE Angajati SET CNP='50000000000' WHERE Nume='Pop' AND Prenume='Andrei';

--Delete Produse
DELETE FROM Produse WHERE Cantitate<500 AND [Pret/Lot] IS NULL;

-- Union Departamente & Angajati
SELECT Nr,Nume FROM Departamente UNION SELECT Id,Nume FROM Angajati --

-- Inner Join Produse & Departamente & Producator
SELECT DISTINCT P.Denumire, D.Nume, PR.Denumire FROM Produse P
	INNER JOIN Departamente D ON P.Departament=D.Nr
	INNER JOIN Producatori PR ON P.Producator=PR.Nr

-- Outer Join Angajati & Departamente
SELECT DISTINCT A.Nume, D.Nume FROM Angajati A 
	FULL OUTER JOIN Departamente D ON A.Departament=D.Nr

-- Group by Functie (count Functie) from Angajati
SELECT Functie,COUNT(Functie) AS [Numar Angajati] FROM Angajati GROUP BY Functie;

-- Group by Cantitate (sum Cantitate<1500) from Produse
SELECT Denumire,SUM(Cantitate) AS Cantitate FROM Produse GROUP BY Denumire HAVING SUM(Cantitate)<1500;

-- Group by Pret/Lot (avg Pret/Lot<10 and Cantitate>0) from Produse
SELECT Denumire,AVG([Pret/Lot]) AS [Pret mediu] FROM Produse WHERE [Pret/Lot]<10 AND Cantitate>0  GROUP BY Denumire;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Show all tables
SELECT* FROM Angajati
SELECT* FROM Producatori
SELECT* FROM Departamente
SELECT* FROM Produse
SELECT* FROM Locatii



--functie ce returneaza numarul departamentului daca este introdus denumirea acestuia
--CREATE FUNCTION denumireDepartament(@denumire VARCHAR(100))
--RETURNS INT AS
--BEGIN
--DECLARE @numar INT=0;
--SELECT @numar=Nr FROM Departamente WHERE Nume=@denumire
--RETURN @numar;
--END;
--
--PRINT dbo.denumireDepartament('Carmangerie');

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Function returneaza numarul de angajati de la departamentul introdus
CREATE FUNCTION nrAngajatiPerDepartament(@numar INT) -- FUNCTIE CE NUMARA CATI ANGAJATI SUNT LA DEPARTAMENTUL INTRODUS
RETURNS INT AS
BEGIN
DECLARE @numarAngajati INT=0;
SELECT @numarAngajati=COUNT(*) FROM Angajati WHERE Departament=@numar
RETURN @numarAngajati;
END;

PRINT dbo.nrAngajatiPerDepartament(1);

-- Procedure to add Angajati
GO
CREATE PROCEDURE addAngajati -- ADAUGA ANGAJATI DOAR DACA NU SUNT MAI MULTI DE 5 LA ACEL DEPARTAMENT
	@Nume VARCHAR(100),
	@Prenume VARCHAR(100),
	@CNP VARCHAR(100),
	@Functie VARCHAR(100),
	@Departament INT,
	@Telefon VARCHAR(100)
AS
BEGIN
IF(dbo.nrAngajatiPerDepartament(@Departament)>5)
	RAISERROR('nU SE POATE',11,1)
ELSE
	INSERT INTO Angajati(Nume,Prenume,CNP,Functie,Departament,Telefon) VALUES(@Nume,@Prenume,@CNP,@Functie,@Departament,@Telefon)
END

EXEC addAngajati 'Popescu', 'Viorel', '56663256985', 'Sofer', 2, '0365002584'
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE FUNCTION nrOrasProducatori(@oras VARCHAR(100)) -- FUNCTIE CE NUMARA CATI PRODUCATORI AVEM IN ORASUL INTRODUS
RETURNS INT AS
BEGIN
DECLARE @numar INT=0;
SELECT @numar=COUNT(*) FROM Producatori WHERE Oras=@oras
RETURN @numar;
END;

PRINT dbo.nrOrasProducatori('Cluj-Napoca');

--Procedure to add Producatori
GO
CREATE PROCEDURE addProducatori -- ADAUGA PRODUCATORI DOAR DACA IN ACEL ORAS NU EXISTA MAI MULTI DE 5
	@Denumire VARCHAR(100),
	@Tara VARCHAR(100),
	@Oras VARCHAR(100),
	@Adresa VARCHAR(100),
	@Telefon VARCHAR(100)
AS
BEGIN
IF(dbo.nrOrasProducatori(@Oras)>5)
	RAISERROR('NU SE POATE',11,1)
ELSE
	INSERT INTO Producatori(Denumire,Tara,Oras,Adresa,Telefon) VALUES(@Denumire,@Tara,@Oras,@Adresa,@Telefon)
END

EXEC addProducatori 'RomSilva','Romania','Baia-Mare','Bulevardul 1 decembrie 23/43','0856478345'

----------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE FUNCTION nrDepartamenteLocatie(@numar INT) -- FUNCTIE CE NUMARA CATE DEPARTAMENTE SUNT LA O LOCATIE
RETURNS INT AS
BEGIN
DECLARE @numardep INT=0;
SELECT @numardep=COUNT(*) FROM Departamente WHERE Locatie=@numar
RETURN @numardep;
END;

PRINT dbo.nrDepartamenteLocatie(2);


--Procedure to add Departamente
GO
CREATE PROCEDURE addDepartamente -- ADAUGA DEPARTAMENTE DOAR DACA LA ACEA LOCATIE NU EXISTA MAI MULT DE 5 DEPARTAMENTE
	@Nume VARCHAR(100),
	@Locatie INT,
	@Telefon VARCHAR(100)
AS
BEGIN
IF (dbo.nrDepartamenteLocatie(@Locatie)>5)
	RAISERROR('NU SE POATE',11,1)
ELSE
	INSERT INTO Departamente(Nume,Locatie,Telefon) VALUES(@Nume,@Locatie,@Telefon)
END

EXEC addDepartamente 'Depozit', 3, '0256985985'
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE FUNCTION nrProduseDepartament(@numar INT) -- FUNCTIE CE NUMARA CATE PRODUSE SUNT LA UN DEPARTAMENT INTRODUS
RETURNS INT AS
BEGIN
DECLARE @numarprod INT=0;
SELECT @numarprod=COUNT(*) FROM Produse WHERE Departament=@numar
RETURN @numarprod;
END;

PRINT dbo.nrProduseDepartament(1);


--Procedure to add Produse
GO
CREATE PROCEDURE addProduse -- ADAUGA PRODUSE DOAR DACA NU SE DEPASESTE LIMITA DE PRODUSE DE LA DEPARTAMENT, LIMITA=5
	@Denumire VARCHAR(100),
	@Producatori INT,
	@Departament INT,
	@Nr_Lot INT,
	@Cantitate INT,
	@Pret_Lot INT
AS
BEGIN
IF(dbo.nrProduseDepartament(@Departament)>5)
	RAISERROR('NU SE POATE',11,1)
ELSE
	INSERT INTO Produse(Denumire,Producator,Departament,[Nr Lot],Cantitate,[Pret/Lot]) VALUES(@Denumire,@Producatori,@Departament,@Nr_Lot,@Cantitate,@Pret_Lot)
END

EXEC addProduse 'Mancare',2,2,234,345,12
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE FUNCTION nrLocatiiOras(@oras VARCHAR(100)) -- FUNCTIE CE NUMARA CATE LOCATII SUNT INTR-UN ORAS
RETURNS INT AS
BEGIN
DECLARE @numarloc INT=0;
SELECT @numarloc=COUNT(*) FROM Locatii WHERE Oras=@oras
RETURN @numarloc;
END;

PRINT dbo.nrLocatiiOras('Cluj-Napoca');


--Procedure to add Locatii
GO
CREATE PROCEDURE addLocatii -- ADAUGA LOCATII DOAR DACA NU S-A DEPASIT NUMARUL DE LOCATII DIN ORAS(5)
	@Denumire VARCHAR(100),
	@Tara VARCHAR(100),
	@Oras VARCHAR(100),
	@Adresa VARCHAR(100),
	@Telefon VARCHAR(100)
AS
BEGIN
IF (dbo.nrLocatiiOras(@Oras)>5)
	RAISERROR('NU SE POATE',11,1)
ELSE
	INSERT INTO Locatii(Denumire,Tara,Oras,Adresa,Telefon) VALUES(@Denumire,@Tara,@Oras,@Adresa,@Telefon)
END

EXEC addLocatii 'Shop&Go','Romania','Baia-Mare','Bulevardul Bucuresti 34/54','0236589658'
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VIEW
GO
CREATE VIEW vwProduseDepartamente AS
SELECT P.Denumire, D.Nume FROM Produse P
INNER JOIN Departamente D ON P.Departament=D.Nr

SELECT* FROM vwProduseDepartamente

-- TRIGGER
GO
CREATE TRIGGER Introdu_angajati 
ON Angajati
FOR INSERT AS BEGIN SET NOCOUNT ON
PRINT 'DATETIME: '+CONVERT(VARCHAR,GETDATE(),0)+' TYPE INSERT'+' TABLE ANGAJATI'
END

INSERT INTO Angajati VALUES ('Popescu','Ion','5000363256985','sofer','2','0756984523')

-- TRIGGER
GO
CREATE TRIGGER Sterge_angajati 
ON Angajati
FOR DELETE AS BEGIN SET NOCOUNT ON;
PRINT 'DATETIME: '+CONVERT(VARCHAR,GETDATE(),0)+' TYPE DELETE'+' TABLE ANGAJATI'
END

DELETE FROM Angajati WHERE Nume='Popescu' AND Prenume='Ion'