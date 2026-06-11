
/*
    TSQL: REGEX: Cleanup danych demo
	Tomasz Lbera | MVP Data Platform
	libera@kursysql.pl
    
    Ten skrypt usuwa tabele demo utworzone przez:
    sqlserver2025-tsql-regex00-SETUP.sql

    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL

*/



USE AdventureWorks2025;
GO

SET NOCOUNT ON;
GO

PRINT '=== Usuwanie tabel demo ze schematu DemoRegex ===';
GO

DROP TABLE IF EXISTS DemoRegex.EmailAddress;
DROP TABLE IF EXISTS DemoRegex.BusinessEntityAddress;
DROP TABLE IF EXISTS DemoRegex.Person;
DROP TABLE IF EXISTS DemoRegex.BusinessEntity;
DROP TABLE IF EXISTS DemoRegex.Address;
DROP TABLE IF EXISTS DemoRegex.StateProvince;
DROP TABLE IF EXISTS DemoRegex.PersonPhone;
GO

IF EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'DemoRegex')
   AND NOT EXISTS (
        SELECT 1
        FROM sys.objects
        WHERE schema_id = SCHEMA_ID('DemoRegex')
   )
BEGIN
    DROP SCHEMA DemoRegex;
    PRINT '- Schemat DemoRegex usunięty';
END
ELSE IF EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'DemoRegex')
BEGIN
    PRINT '- Schemat DemoRegex nie został usunięty, bo zawiera jeszcze inne obiekty';
END
ELSE
BEGIN
    PRINT '- Schemat DemoRegex nie istnieje';
END
GO


DROP TABLE IF EXISTS #Emails;
GO


PRINT '';
PRINT '=== Cleanup zakończony! ===';
GO



