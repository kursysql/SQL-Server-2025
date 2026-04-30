/*

	TSQL: REGEX: Setup polskich danych
	Tomasz Lbera | MVP Data Platform
	libera@kursysql.pl
	
    Ten skrypt dodaje polskie dane do AdventureWorks2025:
    - Kraj: Polska (PL)
    - Województwa: Małopolskie, Mazowieckie, Śląskie
    - Przykładowe adresy z polskimi kodami pocztowymi
    - Przykładowe osoby z Polski
    - Poprawne i niepoprawne adresy e-mail do testów REGEXP_LIKE

    Skrypt do skasowania przykładowych danych: sqlserver2025-tsql-regex00-CLEANUP.sql


    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL


*/


USE AdventureWorks2025
GO

SET NOCOUNT ON
GO


CREATE SCHEMA DemoRegex
GO


PRINT '=== Dodawanie polskich danych do AdventureWorks2025 ===';
GO



-- ============================================
-- 1. Dodanie polskich województw (StateProvince)
-- ============================================
PRINT '1. Dodawanie polskich województw...';

-- Pobierz następny StateProvinceID
DECLARE @TerritoryID INT = 1; -- Domyślne Territory

-- Małopolskie
IF NOT EXISTS (SELECT 1 FROM Person.StateProvince WHERE StateProvinceCode = 'MA' AND CountryRegionCode = 'PL')
BEGIN
    INSERT INTO Person.StateProvince (StateProvinceCode, CountryRegionCode, IsOnlyStateProvinceFlag, Name, TerritoryID)
    VALUES ('MA', 'PL', 0, N'Małopolskie', @TerritoryID);
    PRINT '- Małopolskie dodane';
END

-- Mazowieckie
IF NOT EXISTS (SELECT 1 FROM Person.StateProvince WHERE StateProvinceCode = 'MZ' AND CountryRegionCode = 'PL')
BEGIN
    INSERT INTO Person.StateProvince (StateProvinceCode, CountryRegionCode, IsOnlyStateProvinceFlag, Name, TerritoryID)
    VALUES ('MZ', 'PL', 0, N'Mazowieckie', @TerritoryID);
    PRINT '- Mazowieckie dodane';
END

-- Śląskie
IF NOT EXISTS (SELECT 1 FROM Person.StateProvince WHERE StateProvinceCode = 'SL' AND CountryRegionCode = 'PL')
BEGIN
    INSERT INTO Person.StateProvince (StateProvinceCode, CountryRegionCode, IsOnlyStateProvinceFlag, Name, TerritoryID)
    VALUES ('SL', 'PL', 0, N'Śląskie', @TerritoryID);
    PRINT '- Śląskie dodane';
END
GO

-- ============================================
-- 2. Dodanie przykładowych adresów z polskimi kodami pocztowymi
-- ============================================
PRINT '2. Dodawanie przykładowych polskich adresów...';

DECLARE @MalopolskieID INT = (SELECT StateProvinceID FROM Person.StateProvince WHERE StateProvinceCode = 'MA' AND CountryRegionCode = 'PL');
DECLARE @MazowieckieID INT = (SELECT StateProvinceID FROM Person.StateProvince WHERE StateProvinceCode = 'MZ' AND CountryRegionCode = 'PL');
DECLARE @SlaskieID INT = (SELECT StateProvinceID FROM Person.StateProvince WHERE StateProvinceCode = 'SL' AND CountryRegionCode = 'PL');

-- Kraków (poprawne kody)
INSERT INTO Person.Address (AddressLine1, City, StateProvinceID, PostalCode)
VALUES 
    (N'ul. Floriańska 12', N'Kraków', @MalopolskieID, '31-019'),
    (N'ul. Grodzka 45', N'Kraków', @MalopolskieID, '31-001'),
    (N'os. Teatralne 5', N'Kraków', @MalopolskieID, '31-946');

-- Warszawa (poprawne kody)
INSERT INTO Person.Address (AddressLine1, City, StateProvinceID, PostalCode)
VALUES 
    (N'ul. Marszałkowska 123', N'Warszawa', @MazowieckieID, '00-001'),
    (N'Al. Jerozolimskie 56', N'Warszawa', @MazowieckieID, '00-024'),
    (N'ul. Nowy Świat 78', N'Warszawa', @MazowieckieID, '00-029');

-- Katowice (poprawne kody)
INSERT INTO Person.Address (AddressLine1, City, StateProvinceID, PostalCode)
VALUES 
    (N'ul. 3 Maja 15', N'Katowice', @SlaskieID, '40-096'),
    (N'ul. Dworcowa 34', N'Katowice', @SlaskieID, '40-012');

-- Niepoprawne kody (dla testów walidacji)
INSERT INTO Person.Address (AddressLine1, City, StateProvinceID, PostalCode)
VALUES 
    (N'ul. Testowa 1', N'Kraków', @MalopolskieID, '31019'),     -- Brak myślnika
    (N'ul. Testowa 2', N'Warszawa', @MazowieckieID, '123-45'),  -- Zły format
    (N'ul. Testowa 3', N'Katowice', @SlaskieID, '1-234');       -- Za mało cyfr

PRINT '- 11 polskich adresów dodanych (8 poprawnych + 3 niepoprawne do testów)';
GO

-- ============================================
-- 3. Dodanie przykładowych osób z Polski
-- ============================================
PRINT '3. Dodawanie przykładowych osób z Polski...';

DECLARE @AddressID INT;
DECLARE @AddressTypeID INT = 2; -- Home
DECLARE @BusinessEntityID INT;

-- Osoba 1: Jan Kowalski
INSERT INTO Person.BusinessEntity (rowguid, ModifiedDate)
VALUES (NEWID(), GETDATE());

SET @BusinessEntityID = SCOPE_IDENTITY();

INSERT INTO Person.Person (BusinessEntityID, PersonType, NameStyle, FirstName, LastName, EmailPromotion)
VALUES (@BusinessEntityID, 'IN', 0, N'Jan', N'Kowalski', 0);

-- Adres dla Jana
SET @AddressID = (SELECT TOP 1 AddressID FROM Person.Address WHERE City = N'Kraków' AND PostalCode = '31-019');
INSERT INTO Person.BusinessEntityAddress (BusinessEntityID, AddressID, AddressTypeID)
VALUES (@BusinessEntityID, @AddressID, @AddressTypeID);

-- Email dla Jana
INSERT INTO Person.EmailAddress (BusinessEntityID, EmailAddress)
VALUES (@BusinessEntityID, 'jan.kowalski@adventure-works.com');

PRINT '- Jan Kowalski (Kraków)';

-- Osoba 2: Anna Nowak
INSERT INTO Person.BusinessEntity (rowguid, ModifiedDate)
VALUES (NEWID(), GETDATE());

SET @BusinessEntityID = SCOPE_IDENTITY();

INSERT INTO Person.Person (BusinessEntityID, PersonType, NameStyle, FirstName, LastName, EmailPromotion)
VALUES (@BusinessEntityID, 'IN', 0, N'Anna', N'Nowak', 0);

SET @AddressID = (SELECT TOP 1 AddressID FROM Person.Address WHERE City = N'Warszawa' AND PostalCode = '00-001');
INSERT INTO Person.BusinessEntityAddress (BusinessEntityID, AddressID, AddressTypeID)
VALUES (@BusinessEntityID, @AddressID, @AddressTypeID);

INSERT INTO Person.EmailAddress (BusinessEntityID, EmailAddress)
VALUES (@BusinessEntityID, 'anna.nowak@adventure-works.com');

PRINT '- Anna Nowak (Warszawa)';

-- Osoba 3: Piotr Wiśniewski
INSERT INTO Person.BusinessEntity (rowguid, ModifiedDate)
VALUES (NEWID(), GETDATE());

SET @BusinessEntityID = SCOPE_IDENTITY();

INSERT INTO Person.Person (BusinessEntityID, PersonType, NameStyle, FirstName, LastName, EmailPromotion)
VALUES (@BusinessEntityID, 'IN', 0, N'Piotr', N'Wiśniewski', 0);

SET @AddressID = (SELECT TOP 1 AddressID FROM Person.Address WHERE City = N'Katowice' AND PostalCode = '40-096');
INSERT INTO Person.BusinessEntityAddress (BusinessEntityID, AddressID, AddressTypeID)
VALUES (@BusinessEntityID, @AddressID, @AddressTypeID);

INSERT INTO Person.EmailAddress (BusinessEntityID, EmailAddress)
VALUES (@BusinessEntityID, 'piotr.wisniewski@adventure-works.com');

PRINT '- Piotr Wiśniewski (Katowice)';


-- Osoby 4-10: celowo niepoprawne adresy e-mail do testów REGEXP_LIKE
-- Uwaga: to nie są „realne” dane biznesowe, tylko przypadki testowe do walidacji wzorca.

-- Osoba 4: Ewa Zielińska - brak znaku @
INSERT INTO Person.BusinessEntity (rowguid, ModifiedDate)
VALUES (NEWID(), GETDATE());

SET @BusinessEntityID = SCOPE_IDENTITY();

INSERT INTO Person.Person (BusinessEntityID, PersonType, NameStyle, FirstName, LastName, EmailPromotion)
VALUES (@BusinessEntityID, 'IN', 0, N'Ewa', N'Zielińska', 0);

SET @AddressID = (SELECT TOP 1 AddressID FROM Person.Address WHERE City = N'Kraków' AND PostalCode = '31-001');
INSERT INTO Person.BusinessEntityAddress (BusinessEntityID, AddressID, AddressTypeID)
VALUES (@BusinessEntityID, @AddressID, @AddressTypeID);

INSERT INTO Person.EmailAddress (BusinessEntityID, EmailAddress)
VALUES (@BusinessEntityID, 'ewa.zielinska.adventure-works.com');

PRINT '- Ewa Zielińska (niepoprawny email: brak @)';

-- Osoba 5: Tomasz Wójcik - brak domeny po @
INSERT INTO Person.BusinessEntity (rowguid, ModifiedDate)
VALUES (NEWID(), GETDATE());

SET @BusinessEntityID = SCOPE_IDENTITY();

INSERT INTO Person.Person (BusinessEntityID, PersonType, NameStyle, FirstName, LastName, EmailPromotion)
VALUES (@BusinessEntityID, 'IN', 0, N'Tomasz', N'Wójcik', 0);

SET @AddressID = (SELECT TOP 1 AddressID FROM Person.Address WHERE City = N'Warszawa' AND PostalCode = '00-024');
INSERT INTO Person.BusinessEntityAddress (BusinessEntityID, AddressID, AddressTypeID)
VALUES (@BusinessEntityID, @AddressID, @AddressTypeID);

INSERT INTO Person.EmailAddress (BusinessEntityID, EmailAddress)
VALUES (@BusinessEntityID, 'tomasz.wojcik@');

PRINT '- Tomasz Wójcik (niepoprawny email: brak domeny)';

-- Osoba 6: Katarzyna Kamińska - brak kropki i TLD w domenie
INSERT INTO Person.BusinessEntity (rowguid, ModifiedDate)
VALUES (NEWID(), GETDATE());

SET @BusinessEntityID = SCOPE_IDENTITY();

INSERT INTO Person.Person (BusinessEntityID, PersonType, NameStyle, FirstName, LastName, EmailPromotion)
VALUES (@BusinessEntityID, 'IN', 0, N'Katarzyna', N'Kamińska', 0);

SET @AddressID = (SELECT TOP 1 AddressID FROM Person.Address WHERE City = N'Katowice' AND PostalCode = '40-012');
INSERT INTO Person.BusinessEntityAddress (BusinessEntityID, AddressID, AddressTypeID)
VALUES (@BusinessEntityID, @AddressID, @AddressTypeID);

INSERT INTO Person.EmailAddress (BusinessEntityID, EmailAddress)
VALUES (@BusinessEntityID, 'katarzyna.kaminska@adventure-works');

PRINT '- Katarzyna Kamińska (niepoprawny email: brak TLD)';

-- Osoba 7: Michał Lewandowski - dwie małpy
INSERT INTO Person.BusinessEntity (rowguid, ModifiedDate)
VALUES (NEWID(), GETDATE());

SET @BusinessEntityID = SCOPE_IDENTITY();

INSERT INTO Person.Person (BusinessEntityID, PersonType, NameStyle, FirstName, LastName, EmailPromotion)
VALUES (@BusinessEntityID, 'IN', 0, N'Michał', N'Lewandowski', 0);

SET @AddressID = (SELECT TOP 1 AddressID FROM Person.Address WHERE City = N'Warszawa' AND PostalCode = '00-029');
INSERT INTO Person.BusinessEntityAddress (BusinessEntityID, AddressID, AddressTypeID)
VALUES (@BusinessEntityID, @AddressID, @AddressTypeID);

INSERT INTO Person.EmailAddress (BusinessEntityID, EmailAddress)
VALUES (@BusinessEntityID, 'michal.lewandowski@@adventure-works.com');

PRINT '- Michał Lewandowski (niepoprawny email: dwie małpy)';

-- Osoba 8: Agnieszka Dąbrowska - spacja w adresie
INSERT INTO Person.BusinessEntity (rowguid, ModifiedDate)
VALUES (NEWID(), GETDATE());

SET @BusinessEntityID = SCOPE_IDENTITY();

INSERT INTO Person.Person (BusinessEntityID, PersonType, NameStyle, FirstName, LastName, EmailPromotion)
VALUES (@BusinessEntityID, 'IN', 0, N'Agnieszka', N'Dąbrowska', 0);

SET @AddressID = (SELECT TOP 1 AddressID FROM Person.Address WHERE City = N'Kraków' AND PostalCode = '31-946');
INSERT INTO Person.BusinessEntityAddress (BusinessEntityID, AddressID, AddressTypeID)
VALUES (@BusinessEntityID, @AddressID, @AddressTypeID);

INSERT INTO Person.EmailAddress (BusinessEntityID, EmailAddress)
VALUES (@BusinessEntityID, 'agnieszka dabrowska@adventure-works.com');

PRINT '- Agnieszka Dąbrowska (niepoprawny email: spacja)';

-- Osoba 9: Paweł Kaczmarek - niedozwolony znak w części lokalnej
INSERT INTO Person.BusinessEntity (rowguid, ModifiedDate)
VALUES (NEWID(), GETDATE());

SET @BusinessEntityID = SCOPE_IDENTITY();

INSERT INTO Person.Person (BusinessEntityID, PersonType, NameStyle, FirstName, LastName, EmailPromotion)
VALUES (@BusinessEntityID, 'IN', 0, N'Paweł', N'Kaczmarek', 0);

SET @AddressID = (SELECT TOP 1 AddressID FROM Person.Address WHERE City = N'Katowice' AND PostalCode = '40-096');
INSERT INTO Person.BusinessEntityAddress (BusinessEntityID, AddressID, AddressTypeID)
VALUES (@BusinessEntityID, @AddressID, @AddressTypeID);

INSERT INTO Person.EmailAddress (BusinessEntityID, EmailAddress)
VALUES (@BusinessEntityID, 'pawel.kaczmarek!@adventure-works.com');

PRINT '- Paweł Kaczmarek (niepoprawny email: znak !)';

-- Osoba 10: Magdalena Król - zbyt krótkie rozszerzenie domenowe
INSERT INTO Person.BusinessEntity (rowguid, ModifiedDate)
VALUES (NEWID(), GETDATE());

SET @BusinessEntityID = SCOPE_IDENTITY();

INSERT INTO Person.Person (BusinessEntityID, PersonType, NameStyle, FirstName, LastName, EmailPromotion)
VALUES (@BusinessEntityID, 'IN', 0, N'Magdalena', N'Król', 0);

SET @AddressID = (SELECT TOP 1 AddressID FROM Person.Address WHERE City = N'Warszawa' AND PostalCode = '00-001');
INSERT INTO Person.BusinessEntityAddress (BusinessEntityID, AddressID, AddressTypeID)
VALUES (@BusinessEntityID, @AddressID, @AddressTypeID);

INSERT INTO Person.EmailAddress (BusinessEntityID, EmailAddress)
VALUES (@BusinessEntityID, 'magdalena.krol@test.c');

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
FROM Person.Address a
INNER JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
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
FROM Person.Person p
INNER JOIN Person.BusinessEntityAddress bea ON p.BusinessEntityID = bea.BusinessEntityID
INNER JOIN Person.Address a ON bea.AddressID = a.AddressID
INNER JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
LEFT JOIN Person.EmailAddress e ON p.BusinessEntityID = e.BusinessEntityID
WHERE sp.CountryRegionCode = 'PL'
ORDER BY p.LastName, p.FirstName;
GO

PRINT '';
PRINT '=== Setup zakończony! ===';
PRINT 'Możesz teraz uruchomić przykłady REGEXP_LIKE z polskimi danymi i niepoprawnymi emailami.';
GO


SELECT * FROM Person.Person ORDER BY BusinessEntityID DESC
SELECT *FROM Person.Address ORDER BY AddressID DESC