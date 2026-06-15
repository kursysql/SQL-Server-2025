/*

	TSQL: REGEXP_SPLIT_TO_TABLE w SQL Server 2025 - split tekstu regexem
	Tomasz Lbera | MVP Data Platform
	libera@kursysql.pl
	
    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL
    https://github.com/kursysql/SQL-Server-2025/

    Funkcja REGEXP_SPLIT_TO_TABLE
    dzieli tekst na fragmenty zgodnie z wzorcem wyrażenia regularnego


    Składnia:
    REGEXP_SPLIT_TO_TABLE(string_expression, pattern_expression [ , flags ])
    
    Dokumentacja:
    https://learn.microsoft.com/en-us/sql/t-sql/functions/regexp-split-to-table-transact-sql?view=sql-server-ver17


    Agenda:
    1. REGEXP_SPLIT_TO_TABLE vs STRING_SPLIT
    2. Kilka separatorów jednocześnie
    3. Rozbijanie maila
    4. Rozbijanie CSV
    

*/


USE AdventureWorks2025
GO





-- ============================================
-- 1. REGEXP_SPLIT_TO_TABLE vs STRING_SPLIT
-- ============================================


-- STRING_SPLIT dzieli tekst na fragmenty zgodnie z separatorem
-- (ale nie obsługuje wyrażeń regularnych)
-- enable_ordinal opcjonalnie dodaje kolumnę ordinal do wyników, 
--   która zawiera numer porządkowy fragmentu (zaczynając od 1)
SELECT * 
FROM STRING_SPLIT('Chisel Epic Epic EVO Epic FSR Epic Hardtail Riprock', ' ')
GO

SELECT * 
FROM STRING_SPLIT('Chisel Epic Epic EVO Epic FSR Epic Hardtail Riprock', ' ', 1)
GO


SELECT * 
FROM REGEXP_SPLIT_TO_TABLE('Chisel Epic Epic EVO Epic FSR Epic Hardtail Riprock', ' ');
GO



SELECT * 
FROM STRING_SPLIT('ABC-123-DEF-456', '-', 1);
GO


SELECT * 
FROM REGEXP_SPLIT_TO_TABLE('ABC-123-DEF-456', '-');
GO


-- STRING_SPLIT rozdziela po jednym separatorze
-- REGEXP_SPLIT_TO_TABLE rozdziela po wzorcu





-- ============================================
-- 2. Kilka separatorów jednocześnie
-- ============================================



SELECT *
    -- rozdzielenie po myślniku, przecinku lub średniku 
FROM REGEXP_SPLIT_TO_TABLE('ABC-123,DEF;456', '[-,;]')
GO



SELECT *
    -- można taż użyć operatora +, aby rozdzielać po jednym lub więcej separatorów z rzędu
FROM REGEXP_SPLIT_TO_TABLE('ABC---123,,,DEF;;456', '[-,;]')
GO

SELECT *
     -- ...w ten sposób
     -- + oznacza "jeden lub więcej" wystąpień separatora, 
     --   więc ciągi separatorów są traktowane jako jeden
FROM REGEXP_SPLIT_TO_TABLE('ABC---123,,,DEF;;;456', '[-,;]+')
GO



-- ============================================
-- 3. Rozbijanie maila
-- ============================================


SELECT *
FROM REGEXP_SPLIT_TO_TABLE('jan.kowalski@kursysql.pl', '[@.]');
GO


SELECT 
    ea.EmailAddress,
    s.value
FROM DemoRegex.EmailAddress ea
CROSS APPLY REGEXP_SPLIT_TO_TABLE(ea.EmailAddress, '[@.]') s
INNER JOIN DemoRegex.BusinessEntityAddress AS be ON ea.BusinessEntityID = be.BusinessEntityID
INNER JOIN DemoRegex.Address AS a ON be.AddressID = a.AddressID
INNER JOIN DemoRegex.StateProvince AS sp ON a.StateProvinceID = sp.StateProvinceID
WHERE sp.CountryRegionCode = 'PL' 
    AND REGEXP_LIKE(EmailAddress, '^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
GO



-- ============================================
-- 4. Rozbijanie CSV
-- ============================================

DECLARE @Csv varchar(100) = 'Jan,Kowalski,Warszawa,PL';

SELECT *
FROM REGEXP_SPLIT_TO_TABLE(@Csv,',')
GO


-- rozbicie na wiersze
DECLARE @Csv varchar(200) =
'1,Jan,Kowalski,Warszawa
2,Anna,Nowak,Krakow
3,Marek,Zielinski,Gdansk';


SELECT *
-- \r?\n - rozdzielenie po znakach nowej linii (Windows: \r\n, Unix: \n)
-- ? oznacza, że \r jest opcjonalne, więc obsługuje oba formaty
FROM REGEXP_SPLIT_TO_TABLE(@Csv, '\r?\n')
GO



-- rozbicie na wiersze, a potem kolumny
DECLARE @Csv varchar(200) =
'1,Jan,Kowalski,Warszawa
2,Anna,Nowak,Krakow
3,Marek,Zielinski,Gdansk';


SELECT
    -- [^,]+ - dopasowuje ciąg znaków, który nie zawiera przecinka     
    REGEXP_SUBSTR(value, '[^,]+', 1, 1) AS Id,
    REGEXP_SUBSTR(value, '[^,]+', 1, 2) AS FirstName,
    REGEXP_SUBSTR(value, '[^,]+', 1, 3) AS LastName,
    REGEXP_SUBSTR(value, '[^,]+', 1, 4) AS City
FROM REGEXP_SPLIT_TO_TABLE(@Csv, '\r?\n');
GO





-- CSV - tekst w cudzysłowach może zawierać przecinki, 
-- więc trzeba to uwzględnić w regexie
DECLARE @Csv varchar(200) =
'1,"Jan","Kowalski","Warszawa"
2,"Anna, Maria","Nowak","Krakow"
3,"Marek","Zielinski","Gdansk"';

SELECT
    -- [^,]+ - dopasowuje ciąg znaków, który nie zawiera przecinka (czyli pojedynczą kolumnę)
    -- "([^"]*)" - dopasowuje ciąg znaków otoczony cudzysłowami
    REGEXP_SUBSTR(value, '[^,]+', 1, 1) AS Id,
    REGEXP_SUBSTR(value, '"([^"]*)"', 1, 1, 'c', 1) AS FirstName,
    REGEXP_SUBSTR(value, '"([^"]*)"', 1, 2, 'c', 1) AS LastName,
    REGEXP_SUBSTR(value, '"([^"]*)"', 1, 3, 'c', 1) AS City
FROM REGEXP_SPLIT_TO_TABLE(@Csv, '\r?\n');
GO




