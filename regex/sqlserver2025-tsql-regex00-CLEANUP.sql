
/*
	TSQL: JSON Demo setup
	Tomasz Lbera | MVP Data Platform
	libera@kursysql.pl
    
    Ten skrypt usuwa polskie dane z AdventureWorks2025:
    - Osoby z Polski
    - Adresy z polskimi kodami pocztowymi
    - Polskie województwa
    - Kraj: Polska (PL)

    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL

*/



USE AdventureWorks2025;
GO

PRINT '=== Usuwanie polskich danych z AdventureWorks2025 ===';
GO

-- ============================================
-- 1. Usunięcie polskich osób i ich powiązań
-- ============================================
PRINT '1. Usuwanie polskich osób...';

-- Znajdź BusinessEntityID dla osób z Polski
DECLARE @PolishPersonIDs TABLE (BusinessEntityID INT);

INSERT INTO @PolishPersonIDs
SELECT DISTINCT p.BusinessEntityID
FROM Person.Person p
INNER JOIN Person.BusinessEntityAddress bea ON p.BusinessEntityID = bea.BusinessEntityID
INNER JOIN Person.Address a ON bea.AddressID = a.AddressID
INNER JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
WHERE sp.CountryRegionCode = 'PL';

-- Usuń EmailAddress
DELETE FROM Person.EmailAddress
WHERE BusinessEntityID IN (SELECT BusinessEntityID FROM @PolishPersonIDs);

-- Usuń BusinessEntityAddress
DELETE FROM Person.BusinessEntityAddress
WHERE BusinessEntityID IN (SELECT BusinessEntityID FROM @PolishPersonIDs);

-- Usuń Person
DELETE FROM Person.Person
WHERE BusinessEntityID IN (SELECT BusinessEntityID FROM @PolishPersonIDs);

-- Usuń BusinessEntity
DELETE FROM Person.BusinessEntity
WHERE BusinessEntityID IN (SELECT BusinessEntityID FROM @PolishPersonIDs);

PRINT '- Polskie osoby i ich powiązania usunięte';
GO

-- ============================================
-- 2. Usunięcie polskich adresów
-- ============================================
PRINT '2. Usuwanie polskich adresów...';

DELETE FROM Person.Address
WHERE StateProvinceID IN (
    SELECT StateProvinceID 
    FROM Person.StateProvince 
    WHERE CountryRegionCode = 'PL'
);

PRINT '- Polskie adresy usunięte';
GO

-- ============================================
-- 3. Usunięcie polskich województw
-- ============================================
PRINT '3. Usuwanie polskich województw...';

DELETE FROM Person.StateProvince
WHERE CountryRegionCode = 'PL';

PRINT '- Polskie województwa usunięte';
GO



-- ============================================
-- 5. Weryfikacja usunięcia
-- ============================================
PRINT '5. Weryfikacja usunięcia...';
PRINT '';

-- Sprawdź czy zostały jakieś polskie dane
DECLARE @RemainingCount INT = 0;

SELECT @RemainingCount = COUNT(*)
FROM Person.StateProvince
WHERE CountryRegionCode = 'PL';

IF @RemainingCount = 0
    PRINT '- Wszystkie polskie dane zostały usunięte';
ELSE
    PRINT '!!! UWAGA: Znaleziono ' + CAST(@RemainingCount AS VARCHAR(10)) + ' pozostałych polskich rekordów!';

GO


DROP SCHEMA DemoRegex
GO




PRINT '';
PRINT '=== Cleanup zakończony! ===';
GO


