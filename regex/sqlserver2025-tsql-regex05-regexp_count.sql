/*

	TSQL: REGEXP_COUNT w SQL Server 2025 - liczenie wzorców w danych
	Tomasz Lbera | MVP Data Platform
	libera@kursysql.pl
	
    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL
    https://github.com/kursysql/SQL-Server-2025/

    Funkcja REGEXP_COUNT
    zwraca liczbę wystąpień fragmentu tekstu pasującego do wzorca wyrażenia regularnego


    Składnia:
    REGEXP_COUNT(string_expression, pattern_expression [ , start [ , flags ] ])

    Dokumentacja:
    https://learn.microsoft.com/en-us/sql/t-sql/functions/regexp-count-transact-sql?view=sql-server-ver17
    
   
    Agenda:
    1. REGEXP_COUNT - liczba dopasowań
    2. start - określenie pozycji początkowej
    3. Case sensitive
    4. Ile cyfr zawiera każdy adres email?
    5. Ile cyfr ma numer telefonu
    6. Liczenie słów w opisie produktu  

*/


-- ============================================
-- 1. REGEXP_COUNT - liczba dopasowań
-- ============================================


DECLARE @SourceText varchar(50) = 'ABC-123-DEF-456';

SELECT
    @SourceText AS SourceText,

    -- liczba cyfr w tekście
    REGEXP_COUNT(@SourceText, '\d') AS DigitsCount;
GO


DECLARE @SourceText varchar(50) = 'ABC-123-DEF-456';

SELECT
    REGEXP_COUNT(@SourceText, '\d') AS DigitsCount,
    REGEXP_COUNT(@SourceText, '\d+') AS NumbersCount;
GO





-- ============================================
-- 2. start - określenie pozycji początkowej
-- ============================================

DECLARE @SourceText varchar(50) = 'ABC-123-DEF-456';

SELECT

    
    REGEXP_COUNT(@SourceText, '\d+') AS CountFromBeginningDef,
    REGEXP_COUNT(@SourceText, '\d+', 1) AS CountFromBeginning,

    REGEXP_COUNT(@SourceText, '\d+', 9) AS CountFromPosition9;
GO



-- ============================================
-- 3. Case sensitive
-- ============================================


DECLARE @SourceText varchar(50) = 'ABC-123-abc-456';

SELECT
    -- domyślnie jest case sensitive
    REGEXP_COUNT(@SourceText, 'abc', 1) AS CaseSensitiveDef,
    REGEXP_COUNT(@SourceText, 'abc', 1, 'c') AS CaseSensitive,

    -- case insensitive
    REGEXP_COUNT(@SourceText, 'abc', 1, 'i') AS CaseInsensitive;
GO


-- ============================================
-- 4. Ile cyfr zawiera każdy adres email?
-- ============================================

SELECT TOP 20
    EmailAddress,

    REGEXP_COUNT(EmailAddress, '\d') AS DigitsInEmail

FROM DemoRegex.EmailAddress
ORDER BY EmailAddress;
GO

-- ile cyfr jest łącznie we wszystkich adresach email?
SELECT
    SUM(REGEXP_COUNT(EmailAddress, '\d')) AS DigitsInEmail
FROM DemoRegex.EmailAddress

GO




-- ============================================
-- 5. Ile cyfr ma numer telefonu
-- ============================================



SELECT
    PhoneNumber,

    REGEXP_COUNT(PhoneNumber, '\d') AS DigitsCount

FROM DemoRegex.PersonPhone
ORDER BY PhoneNumber;
GO




-- ============================================
-- 6. Liczenie słów w opisie produktu
-- ============================================

SELECT TOP 20
    Description,

    -- \w+ - dopasowuje słowa, czyli ciągi znaków alfanumerycznych
    REGEXP_COUNT(Description, '\w+' ) AS WordCount
FROM Production.ProductDescription;
GO


