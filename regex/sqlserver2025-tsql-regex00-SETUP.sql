/*

	TSQL: REGEX: Setup polskich danych
	Tomasz Lbera | MVP Data Platform
	libera@kursysql.pl
	
    Ten skrypt tworzy kopie wybranych tabel AdventureWorks2025 w schemacie DemoRegex
    i dodaje polskie dane tylko do tych kopii:
    - Kraj: Polska (PL)
    - Województwa: Małopolskie, Mazowieckie, Śląskie
    - Przykładowe adresy z polskimi kodami pocztowymi
    - Przykładowe osoby z Polski
    - Poprawne i niepoprawne adresy e-mail do testów REGEXP_LIKE

    Skrypt do skasowania tabel DemoRegex: sqlserver2025-tsql-regex00-CLEANUP.sql


    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL


*/




USE AdventureWorks2025
GO

SET NOCOUNT ON
GO


IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'DemoRegex')
BEGIN
    EXEC('CREATE SCHEMA DemoRegex');
END
GO

PRINT '=== Tworzenie kopii tabel w schemacie DemoRegex ===';
GO

DROP TABLE IF EXISTS DemoRegex.EmailAddress;
DROP TABLE IF EXISTS DemoRegex.BusinessEntityAddress;
DROP TABLE IF EXISTS DemoRegex.Person;
DROP TABLE IF EXISTS DemoRegex.BusinessEntity;
DROP TABLE IF EXISTS DemoRegex.Address;
DROP TABLE IF EXISTS DemoRegex.StateProvince;
GO

SELECT *
INTO DemoRegex.StateProvince
FROM Person.StateProvince;
GO

SELECT *
INTO DemoRegex.Address
FROM Person.Address;
GO

SELECT *
INTO DemoRegex.BusinessEntity
FROM Person.BusinessEntity;
GO

SELECT *
INTO DemoRegex.Person
FROM Person.Person;
GO

SELECT *
INTO DemoRegex.BusinessEntityAddress
FROM Person.BusinessEntityAddress;
GO

SELECT *
INTO DemoRegex.EmailAddress
FROM Person.EmailAddress;
GO

SELECT *
INTO DemoRegex.PersonPhone
FROM Person.PersonPhone;
GO


PRINT '- Kopie tabel utworzone: DemoRegex.StateProvince, DemoRegex.Address, DemoRegex.BusinessEntity, DemoRegex.Person, DemoRegex.BusinessEntityAddress, DemoRegex.EmailAddress, DemoRegex.PersonPhone';
GO


PRINT '=== Dodawanie polskich danych do kopii tabel w DemoRegex ===';
GO



-- ============================================
-- 1. Dodanie polskich województw (StateProvince)
-- ============================================
PRINT '1. Dodawanie polskich województw...';

-- Pobierz następny StateProvinceID
DECLARE @TerritoryID INT = 1; -- Domyślne Territory

-- Małopolskie
IF NOT EXISTS (SELECT 1 FROM DemoRegex.StateProvince WHERE StateProvinceCode = 'MA' AND CountryRegionCode = 'PL')
BEGIN
    INSERT INTO DemoRegex.StateProvince (StateProvinceCode, CountryRegionCode, IsOnlyStateProvinceFlag, Name, TerritoryID, rowguid, ModifiedDate)
    VALUES ('MA', 'PL', 0, N'Małopolskie', @TerritoryID, NEWID(), GETDATE());
    PRINT '- Małopolskie dodane';
END

-- Mazowieckie
IF NOT EXISTS (SELECT 1 FROM DemoRegex.StateProvince WHERE StateProvinceCode = 'MZ' AND CountryRegionCode = 'PL')
BEGIN
    INSERT INTO DemoRegex.StateProvince (StateProvinceCode, CountryRegionCode, IsOnlyStateProvinceFlag, Name, TerritoryID, rowguid, ModifiedDate)
    VALUES ('MZ', 'PL', 0, N'Mazowieckie', @TerritoryID, NEWID(), GETDATE());
    PRINT '- Mazowieckie dodane';
END

-- Śląskie
IF NOT EXISTS (SELECT 1 FROM DemoRegex.StateProvince WHERE StateProvinceCode = 'SL' AND CountryRegionCode = 'PL')
BEGIN
    INSERT INTO DemoRegex.StateProvince (StateProvinceCode, CountryRegionCode, IsOnlyStateProvinceFlag, Name, TerritoryID, rowguid, ModifiedDate)
    VALUES ('SL', 'PL', 0, N'Śląskie', @TerritoryID, NEWID(), GETDATE());
    PRINT '- Śląskie dodane';
END
GO

-- ============================================
-- 2. Dodanie przykładowych adresów z polskimi kodami pocztowymi
-- ============================================
PRINT '2. Dodawanie przykładowych polskich adresów...';

DECLARE @MalopolskieID INT = (SELECT StateProvinceID FROM DemoRegex.StateProvince WHERE StateProvinceCode = 'MA' AND CountryRegionCode = 'PL');
DECLARE @MazowieckieID INT = (SELECT StateProvinceID FROM DemoRegex.StateProvince WHERE StateProvinceCode = 'MZ' AND CountryRegionCode = 'PL');
DECLARE @SlaskieID INT = (SELECT StateProvinceID FROM DemoRegex.StateProvince WHERE StateProvinceCode = 'SL' AND CountryRegionCode = 'PL');

-- Kraków (poprawne kody)
INSERT INTO DemoRegex.Address (AddressLine1, City, StateProvinceID, PostalCode, rowguid, ModifiedDate)
VALUES 
    (N'ul. Floriańska 12', N'Kraków', @MalopolskieID, '31-019', NEWID(), GETDATE()),
    (N'ul. Grodzka 45', N'Kraków', @MalopolskieID, '31-001', NEWID(), GETDATE()),
    (N'os. Teatralne 5', N'Kraków', @MalopolskieID, '31-946', NEWID(), GETDATE());

-- Warszawa (poprawne kody)
INSERT INTO DemoRegex.Address (AddressLine1, City, StateProvinceID, PostalCode, rowguid, ModifiedDate)
VALUES 
    (N'ul. Marszałkowska 123', N'Warszawa', @MazowieckieID, '00-001', NEWID(), GETDATE()),
    (N'Al. Jerozolimskie 56', N'Warszawa', @MazowieckieID, '00-024', NEWID(), GETDATE()),
    (N'ul. Nowy Świat 78', N'Warszawa', @MazowieckieID, '00-029', NEWID(), GETDATE());

-- Katowice (poprawne kody)
INSERT INTO DemoRegex.Address (AddressLine1, City, StateProvinceID, PostalCode, rowguid, ModifiedDate)
VALUES 
    (N'ul. 3 Maja 15', N'Katowice', @SlaskieID, '40-096', NEWID(), GETDATE()),
    (N'ul. Dworcowa 34', N'Katowice', @SlaskieID, '40-012', NEWID(), GETDATE());

-- Niepoprawne kody (dla testów walidacji)
INSERT INTO DemoRegex.Address (AddressLine1, City, StateProvinceID, PostalCode, rowguid, ModifiedDate)
VALUES 
    (N'ul. Testowa 1', N'Kraków', @MalopolskieID, '31019', NEWID(), GETDATE()),     -- Brak myślnika
    (N'ul. Testowa 2', N'Warszawa', @MazowieckieID, '123-45', NEWID(), GETDATE()),  -- Zły format
    (N'ul. Testowa 3', N'Katowice', @SlaskieID, '1-234', NEWID(), GETDATE());       -- Za mało cyfr

PRINT '- 11 polskich adresów dodanych do DemoRegex.Address (8 poprawnych + 3 niepoprawne do testów)';
GO

-- ============================================
-- 3. Dodanie przykładowych osób z Polski
-- ============================================
PRINT '3. Dodawanie przykładowych osób z Polski...';

DECLARE @AddressID INT;
DECLARE @AddressTypeID INT = 2; -- Home
DECLARE @BusinessEntityID INT;

-- Osoba 1: Jan Kowalski
INSERT INTO DemoRegex.BusinessEntity (rowguid, ModifiedDate)
VALUES (NEWID(), GETDATE());

SET @BusinessEntityID = SCOPE_IDENTITY();

INSERT INTO DemoRegex.Person (BusinessEntityID, PersonType, NameStyle, FirstName, LastName, EmailPromotion, rowguid, ModifiedDate)
VALUES (@BusinessEntityID, 'IN', 0, N'Jan', N'Kowalski', 0, NEWID(), GETDATE());

-- Adres dla Jana
SET @AddressID = (SELECT TOP 1 AddressID FROM DemoRegex.Address WHERE City = N'Kraków' AND PostalCode = '31-019');
INSERT INTO DemoRegex.BusinessEntityAddress (BusinessEntityID, AddressID, AddressTypeID, rowguid, ModifiedDate)
VALUES (@BusinessEntityID, @AddressID, @AddressTypeID, NEWID(), GETDATE());

-- Email dla Jana
INSERT INTO DemoRegex.EmailAddress (BusinessEntityID, EmailAddress, rowguid, ModifiedDate)
VALUES (@BusinessEntityID, 'jan.kowalski@adventure-works.com', NEWID(), GETDATE());

-- Telefon dla Jana
INSERT INTO DemoRegex.PersonPhone (BusinessEntityID, PhoneNumber, PhoneNumberTypeID, ModifiedDate)
VALUES (@BusinessEntityID, '501234567', 1, GETDATE());

PRINT '- Jan Kowalski (Kraków)';

-- Osoba 2: Anna Nowak
INSERT INTO DemoRegex.BusinessEntity (rowguid, ModifiedDate)
VALUES (NEWID(), GETDATE());

SET @BusinessEntityID = SCOPE_IDENTITY();

INSERT INTO DemoRegex.Person (BusinessEntityID, PersonType, NameStyle, FirstName, LastName, EmailPromotion, rowguid, ModifiedDate)
VALUES (@BusinessEntityID, 'IN', 0, N'Anna', N'Nowak', 0, NEWID(), GETDATE());

SET @AddressID = (SELECT TOP 1 AddressID FROM DemoRegex.Address WHERE City = N'Warszawa' AND PostalCode = '00-001');
INSERT INTO DemoRegex.BusinessEntityAddress (BusinessEntityID, AddressID, AddressTypeID, rowguid, ModifiedDate)
VALUES (@BusinessEntityID, @AddressID, @AddressTypeID, NEWID(), GETDATE());

INSERT INTO DemoRegex.EmailAddress (BusinessEntityID, EmailAddress, rowguid, ModifiedDate)
VALUES (@BusinessEntityID, 'anna.nowak@adventure-works.com', NEWID(), GETDATE());

INSERT INTO DemoRegex.PersonPhone(BusinessEntityID, PhoneNumber, PhoneNumberTypeID, ModifiedDate)
VALUES(@BusinessEntityID, '501 234 567', 1, GETDATE());


PRINT '- Anna Nowak (Warszawa)';

-- Osoba 3: Piotr Wiśniewski
INSERT INTO DemoRegex.BusinessEntity (rowguid, ModifiedDate)
VALUES (NEWID(), GETDATE());

SET @BusinessEntityID = SCOPE_IDENTITY();

INSERT INTO DemoRegex.Person (BusinessEntityID, PersonType, NameStyle, FirstName, LastName, EmailPromotion, rowguid, ModifiedDate)
VALUES (@BusinessEntityID, 'IN', 0, N'Piotr', N'Wiśniewski', 0, NEWID(), GETDATE());

SET @AddressID = (SELECT TOP 1 AddressID FROM DemoRegex.Address WHERE City = N'Katowice' AND PostalCode = '40-096');
INSERT INTO DemoRegex.BusinessEntityAddress (BusinessEntityID, AddressID, AddressTypeID, rowguid, ModifiedDate)
VALUES (@BusinessEntityID, @AddressID, @AddressTypeID, NEWID(), GETDATE());

INSERT INTO DemoRegex.EmailAddress (BusinessEntityID, EmailAddress, rowguid, ModifiedDate)
VALUES (@BusinessEntityID, 'piotr.wisniewski@adventure-works.com', NEWID(), GETDATE());

INSERT INTO DemoRegex.PersonPhone (BusinessEntityID, PhoneNumber, PhoneNumberTypeID, ModifiedDate)
VALUES (@BusinessEntityID, '501-234-567', 1, GETDATE());    

PRINT '- Piotr Wiśniewski (Katowice)';


-- Osoby 4-10: celowo niepoprawne adresy e-mail do testów REGEXP_LIKE
-- Uwaga: to nie są „realne” dane biznesowe, tylko przypadki testowe do walidacji wzorca.

-- Osoba 4: Ewa Zielińska - brak znaku @
INSERT INTO DemoRegex.BusinessEntity (rowguid, ModifiedDate)
VALUES (NEWID(), GETDATE());

SET @BusinessEntityID = SCOPE_IDENTITY();

INSERT INTO DemoRegex.Person (BusinessEntityID, PersonType, NameStyle, FirstName, LastName, EmailPromotion, rowguid, ModifiedDate)
VALUES (@BusinessEntityID, 'IN', 0, N'Ewa', N'Zielińska', 0, NEWID(), GETDATE());

SET @AddressID = (SELECT TOP 1 AddressID FROM DemoRegex.Address WHERE City = N'Kraków' AND PostalCode = '31-001');
INSERT INTO DemoRegex.BusinessEntityAddress (BusinessEntityID, AddressID, AddressTypeID, rowguid, ModifiedDate)
VALUES (@BusinessEntityID, @AddressID, @AddressTypeID, NEWID(), GETDATE());

INSERT INTO DemoRegex.EmailAddress (BusinessEntityID, EmailAddress, rowguid, ModifiedDate)
VALUES (@BusinessEntityID, 'ewa.zielinska.adventure-works.com', NEWID(), GETDATE());

-- błędny numer (za krótki)
INSERT INTO DemoRegex.PersonPhone (BusinessEntityID, PhoneNumber, PhoneNumberTypeID, ModifiedDate)
VALUES (@BusinessEntityID, '50123456', 1, GETDATE());



PRINT '- Ewa Zielińska (niepoprawny email: brak @)';

-- Osoba 5: Tomasz Wójcik - brak domeny po @
INSERT INTO DemoRegex.BusinessEntity (rowguid, ModifiedDate)
VALUES (NEWID(), GETDATE());

SET @BusinessEntityID = SCOPE_IDENTITY();

INSERT INTO DemoRegex.Person (BusinessEntityID, PersonType, NameStyle, FirstName, LastName, EmailPromotion, rowguid, ModifiedDate)
VALUES (@BusinessEntityID, 'IN', 0, N'Tomasz', N'Wójcik', 0, NEWID(), GETDATE());

SET @AddressID = (SELECT TOP 1 AddressID FROM DemoRegex.Address WHERE City = N'Warszawa' AND PostalCode = '00-024');
INSERT INTO DemoRegex.BusinessEntityAddress (BusinessEntityID, AddressID, AddressTypeID, rowguid, ModifiedDate)
VALUES (@BusinessEntityID, @AddressID, @AddressTypeID, NEWID(), GETDATE());

INSERT INTO DemoRegex.EmailAddress (BusinessEntityID, EmailAddress, rowguid, ModifiedDate)
VALUES (@BusinessEntityID, 'tomasz.wojcik@', NEWID(), GETDATE());

-- za długi
INSERT INTO DemoRegex.PersonPhone (BusinessEntityID, PhoneNumber, PhoneNumberTypeID, ModifiedDate)
VALUES (@BusinessEntityID, '5012345678', 1, GETDATE());

PRINT '- Tomasz Wójcik (niepoprawny email: brak domeny)';

-- Osoba 6: Katarzyna Kamińska - brak kropki i TLD w domenie
INSERT INTO DemoRegex.BusinessEntity (rowguid, ModifiedDate)
VALUES (NEWID(), GETDATE());

SET @BusinessEntityID = SCOPE_IDENTITY();

INSERT INTO DemoRegex.Person (BusinessEntityID, PersonType, NameStyle, FirstName, LastName, EmailPromotion, rowguid, ModifiedDate)
VALUES (@BusinessEntityID, 'IN', 0, N'Katarzyna', N'Kamińska', 0, NEWID(), GETDATE());

SET @AddressID = (SELECT TOP 1 AddressID FROM DemoRegex.Address WHERE City = N'Katowice' AND PostalCode = '40-012');
INSERT INTO DemoRegex.BusinessEntityAddress (BusinessEntityID, AddressID, AddressTypeID, rowguid, ModifiedDate)
VALUES (@BusinessEntityID, @AddressID, @AddressTypeID, NEWID(), GETDATE());

INSERT INTO DemoRegex.EmailAddress (BusinessEntityID, EmailAddress, rowguid, ModifiedDate)
VALUES (@BusinessEntityID, 'katarzyna.kaminska@adventure-works', NEWID(), GETDATE());

INSERT INTO DemoRegex.PersonPhone (BusinessEntityID, PhoneNumber, PhoneNumberTypeID, ModifiedDate)
VALUES(    @BusinessEntityID,    '+48 501 234 567',    1,    GETDATE());


PRINT '- Katarzyna Kamińska (niepoprawny email: brak TLD)';

-- Osoba 7: Michał Lewandowski - dwie małpy
INSERT INTO DemoRegex.BusinessEntity (rowguid, ModifiedDate)
VALUES (NEWID(), GETDATE());

SET @BusinessEntityID = SCOPE_IDENTITY();

INSERT INTO DemoRegex.Person (BusinessEntityID, PersonType, NameStyle, FirstName, LastName, EmailPromotion, rowguid, ModifiedDate)
VALUES (@BusinessEntityID, 'IN', 0, N'Michał', N'Lewandowski', 0, NEWID(), GETDATE());

SET @AddressID = (SELECT TOP 1 AddressID FROM DemoRegex.Address WHERE City = N'Warszawa' AND PostalCode = '00-029');
INSERT INTO DemoRegex.BusinessEntityAddress (BusinessEntityID, AddressID, AddressTypeID, rowguid, ModifiedDate)
VALUES (@BusinessEntityID, @AddressID, @AddressTypeID, NEWID(), GETDATE());

INSERT INTO DemoRegex.EmailAddress (BusinessEntityID, EmailAddress, rowguid, ModifiedDate)
VALUES (@BusinessEntityID, 'michal.lewandowski@@adventure-works.com', NEWID(), GETDATE());

INSERT INTO DemoRegex.PersonPhone(BusinessEntityID, PhoneNumber, PhoneNumberTypeID, ModifiedDate)
VALUES(    @BusinessEntityID,    '+48-600-123-456',    1,    GETDATE());


PRINT '- Michał Lewandowski (niepoprawny email: dwie małpy)';

-- Osoba 8: Agnieszka Dąbrowska - spacja w adresie
INSERT INTO DemoRegex.BusinessEntity (rowguid, ModifiedDate)
VALUES (NEWID(), GETDATE());

SET @BusinessEntityID = SCOPE_IDENTITY();

INSERT INTO DemoRegex.Person (BusinessEntityID, PersonType, NameStyle, FirstName, LastName, EmailPromotion, rowguid, ModifiedDate)
VALUES (@BusinessEntityID, 'IN', 0, N'Agnieszka', N'Dąbrowska', 0, NEWID(), GETDATE());

SET @AddressID = (SELECT TOP 1 AddressID FROM DemoRegex.Address WHERE City = N'Kraków' AND PostalCode = '31-946');
INSERT INTO DemoRegex.BusinessEntityAddress (BusinessEntityID, AddressID, AddressTypeID, rowguid, ModifiedDate)
VALUES (@BusinessEntityID, @AddressID, @AddressTypeID, NEWID(), GETDATE());

INSERT INTO DemoRegex.EmailAddress (BusinessEntityID, EmailAddress, rowguid, ModifiedDate)
VALUES (@BusinessEntityID, 'agnieszka dabrowska@adventure-works.com', NEWID(), GETDATE());

PRINT '- Agnieszka Dąbrowska (niepoprawny email: spacja)';

-- Osoba 9: Paweł Kaczmarek - niedozwolony znak w części lokalnej
INSERT INTO DemoRegex.BusinessEntity (rowguid, ModifiedDate)
VALUES (NEWID(), GETDATE());

SET @BusinessEntityID = SCOPE_IDENTITY();

INSERT INTO DemoRegex.Person (BusinessEntityID, PersonType, NameStyle, FirstName, LastName, EmailPromotion, rowguid, ModifiedDate)
VALUES (@BusinessEntityID, 'IN', 0, N'Paweł', N'Kaczmarek', 0, NEWID(), GETDATE());

SET @AddressID = (SELECT TOP 1 AddressID FROM DemoRegex.Address WHERE City = N'Katowice' AND PostalCode = '40-096');
INSERT INTO DemoRegex.BusinessEntityAddress (BusinessEntityID, AddressID, AddressTypeID, rowguid, ModifiedDate)
VALUES (@BusinessEntityID, @AddressID, @AddressTypeID, NEWID(), GETDATE());

INSERT INTO DemoRegex.EmailAddress (BusinessEntityID, EmailAddress, rowguid, ModifiedDate)
VALUES (@BusinessEntityID, 'pawel.kaczmarek!@adventure-works.com', NEWID(), GETDATE());

-- zy prefiks kraju
INSERT INTO DemoRegex.PersonPhone(BusinessEntityID, PhoneNumber, PhoneNumberTypeID, ModifiedDate)
VALUES (@BusinessEntityID, '+49 501 234 567', 1, GETDATE());

PRINT '- Paweł Kaczmarek (niepoprawny email: znak !)';

-- Osoba 10: Magdalena Król - zbyt krótkie rozszerzenie domenowe
INSERT INTO DemoRegex.BusinessEntity (rowguid, ModifiedDate)
VALUES (NEWID(), GETDATE());

SET @BusinessEntityID = SCOPE_IDENTITY();

INSERT INTO DemoRegex.Person (BusinessEntityID, PersonType, NameStyle, FirstName, LastName, EmailPromotion, rowguid, ModifiedDate)
VALUES (@BusinessEntityID, 'IN', 0, N'Magdalena', N'Król', 0, NEWID(), GETDATE());

SET @AddressID = (SELECT TOP 1 AddressID FROM DemoRegex.Address WHERE City = N'Warszawa' AND PostalCode = '00-001');
INSERT INTO DemoRegex.BusinessEntityAddress (BusinessEntityID, AddressID, AddressTypeID, rowguid, ModifiedDate)
VALUES (@BusinessEntityID, @AddressID, @AddressTypeID, NEWID(), GETDATE());

INSERT INTO DemoRegex.EmailAddress (BusinessEntityID, EmailAddress, rowguid, ModifiedDate)
VALUES (@BusinessEntityID, 'magdalena.krol@test.c', NEWID(), GETDATE());

-- niepoprawne separatory
INSERT INTO DemoRegex.PersonPhone(BusinessEntityID, PhoneNumber, PhoneNumberTypeID, ModifiedDate)
VALUES (@BusinessEntityID, '501-23-4567', 1, GETDATE());

PRINT '- Magdalena Król (niepoprawny email: TLD ma 1 znak)';
GO

-- ============================================
-- 4. Weryfikacja dodanych danych
-- ============================================
PRINT '4. Weryfikacja dodanych danych...';
PRINT '';

-- Polskie adresy
PRINT 'Polskie adresy (z walidacją kodów pocztowych):';
SELECT 
    a.AddressID,
    a.AddressLine1,
    a.City,
    a.PostalCode,
    sp.Name AS Wojewodztwo,
    CASE 
        WHEN REGEXP_LIKE(a.PostalCode, '^\d{2}-\d{3}$') THEN 'Valid'
        ELSE 'Invalid'
    END AS PostalCodeValidation
FROM DemoRegex.Address a
INNER JOIN DemoRegex.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
WHERE sp.CountryRegionCode = 'PL'
ORDER BY a.City, a.PostalCode;
GO

-- Polskie osoby
PRINT '';
PRINT 'Polskie osoby (z walidacją emaili):';
SELECT 
    p.FirstName,
    p.LastName,
    e.EmailAddress,
    CASE 
        WHEN REGEXP_LIKE(e.EmailAddress, '^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$') THEN 'Valid'
        ELSE 'Invalid'
    END AS EmailValidation,
    a.City,
    a.PostalCode
FROM DemoRegex.Person p
INNER JOIN DemoRegex.BusinessEntityAddress bea ON p.BusinessEntityID = bea.BusinessEntityID
INNER JOIN DemoRegex.Address a ON bea.AddressID = a.AddressID
INNER JOIN DemoRegex.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
LEFT JOIN DemoRegex.EmailAddress e ON p.BusinessEntityID = e.BusinessEntityID
WHERE sp.CountryRegionCode = 'PL'
ORDER BY p.LastName, p.FirstName;
GO

PRINT '';
PRINT '=== Setup zakończony! ===';
PRINT 'Możesz teraz uruchomić przykłady REGEXP_LIKE na tabelach DemoRegex z polskimi danymi i niepoprawnymi emailami.';
GO


--SELECT * FROM DemoRegex.Person ORDER BY BusinessEntityID DESC;
--SELECT * FROM DemoRegex.Address ORDER BY AddressID DESC;