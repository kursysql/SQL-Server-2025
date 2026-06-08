/*

	TSQL: REGEXP_REPLACE w SQL Server 2025 - 1 funkcja, która zastępuje pół T-SQL
	Tomasz Lbera | MVP Data Platform
	libera@kursysql.pl
	
    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL
    https://github.com/kursysql/SQL-Server-2025/

    Funkcja REGEXP_REPLACE
    zastępuje fragmenty tekstu pasujące do wzorca wyrażenia regularnego

    Składnia:
    REGEXP_REPLACE ( input_string, pattern, replacement_string [, start_position [, occurrence [, match_parameter ] ] ] )

    Dokumentacja:
    https://learn.microsoft.com/pl-pl/sql/t-sql/functions/regexp-replace-transact-sql?view=sql-server-ver17
    
    Agenda:

    1. Usuwanie znaków niebędących cyframi (telefon)
    2. Normalizacja numeru telefonu (format PL)
    3. Tradycyjny REPLACE vs REGEXP_REPLACE
    4. Porównanie wydajności
    5. start_position
    6. occurrence
    7. match_parameter / flags

    

*/



-- ============================================
-- 1. Usuwanie znaków niebędących cyframi (telefon)
-- \D = wszystko co NIE jest cyfrą
-- ============================================

SELECT TOP 20 
    PhoneNumber, 
    REGEXP_REPLACE(PhoneNumber, '\D', '') AS DigitsOnly 
FROM DemoRegex.PersonPhone 
ORDER BY PhoneNumber; 
GO 



-- ============================================
-- 2. Normalizacja numeru telefonu (format PL)
-- regex: \D = wszystko co NIE jest cyfrą
-- ============================================

SELECT 
    PhoneNumber, 
    -- krok 0: usuwamy wszystko poza cyframi
    REGEXP_REPLACE(PhoneNumber, '\D', '') AS DigitsOnly, 

    -- krok 2: usunięcie prefiksu 48 (jeżeli występuje)
    REGEXP_REPLACE( 
        REGEXP_REPLACE(PhoneNumber, '\D', ''),
        '^48', '' 
    ) AS PhoneWithoutCountryCode_2,

    -- krok 3: formatowanie numeru
    -- - string_replacement: może zawierać odwołania do grup przechwytujących z patternu (np. \1, \2, ...)
    --   123456789 -> 123-456-789
    REGEXP_REPLACE(
        REGEXP_REPLACE(
            REGEXP_REPLACE(PhoneNumber, '\D', ''),
            '^48', ''
        ),
        '^(\d{3})(\d{3})(\d{3})$',
        '\1-\2-\3'
    ) AS FormattedPhone_3,

    -- krok 4: dodanie standardowego prefiksu kraju
    '+48 ' +
    REGEXP_REPLACE(
        REGEXP_REPLACE(
            REGEXP_REPLACE(PhoneNumber, '\D', ''),
            '^48',
            ''
        ),
        '^(\d{3})(\d{3})(\d{3})$',
        '\1-\2-\3'
    ) AS StandardizedPhone


FROM DemoRegex.PersonPhone AS pp
INNER JOIN DemoRegex.BusinessEntityAddress be ON pp.BusinessEntityID = be.BusinessEntityID
INNER JOIN DemoRegex.Address a ON be.AddressID = a.AddressID
INNER JOIN DemoRegex.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
WHERE sp.CountryRegionCode = 'PL'
ORDER BY PhoneNumber; 
GO




SELECT 
    PhoneNumber, 

    -- sprawdzamy czy polski format jest spełniony (9 cyfr lub 11 cyfr z prefiksem 48)
    -- - w innym przypadku usuwamy wszystko poza cyframi, ale nie usuwamy prefiksu 48 (jeżeli występuje)
    CASE
        WHEN REGEXP_LIKE(REGEXP_REPLACE(PhoneNumber, '\D', ''), '^48\d{9}$')
            THEN REGEXP_REPLACE(REGEXP_REPLACE(PhoneNumber, '\D', ''), '^48', '')
        WHEN REGEXP_LIKE(REGEXP_REPLACE(PhoneNumber, '\D', ''), '^\d{9}$')
            THEN REGEXP_REPLACE(PhoneNumber, '\D', '')
        ELSE REGEXP_REPLACE(PhoneNumber, '\D', '')
    END AS PhonePL_WithoutCountryCode,

    CASE
        WHEN REGEXP_LIKE(REGEXP_REPLACE(PhoneNumber, '\D', ''), '^48\d{9}$')
            THEN 'PL'
        WHEN REGEXP_LIKE(REGEXP_REPLACE(PhoneNumber, '\D', ''), '^\d{9}$')
            THEN 'PL bez prefiksu'
        ELSE '-- nieznany format'
    END AS PhonePL_WithoutCountryCode_TEST
 
FROM DemoRegex.PersonPhone AS pp
INNER JOIN DemoRegex.BusinessEntityAddress be ON pp.BusinessEntityID = be.BusinessEntityID
INNER JOIN DemoRegex.Address a ON be.AddressID = a.AddressID
INNER JOIN DemoRegex.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
WHERE sp.CountryRegionCode = 'PL'
ORDER BY PhoneNumber; 
GO


-- ============================================
-- 3. Tradycyjny REPLACE vs REGEXP_REPLACE
-- ============================================


-- A/ Usuwanie separatorów z numeru telefonu

SELECT
    PhoneNumber,

    -- klasycznie: trzeba znać wszystkie znaki do usunięcia
    -- REPLACE składnia: REPLACE(string, old_substring, new_substring)
    REPLACE(
        REPLACE(
            REPLACE(
                REPLACE(
                    REPLACE(PhoneNumber, ' ', ''),
                    '-', ''
                ),
                '(',
                ''
            ),
            ')',
            ''
        ),
        '+',
        ''
    ) AS TraditionalReplace,

    -- regex: usuwamy wszystko, co nie jest cyfrą
    REGEXP_REPLACE(PhoneNumber, '\D', '') AS RegexReplace

FROM DemoRegex.PersonPhone
ORDER BY PhoneNumber;
GO




-- B/ Usuwanie separatorów z numeru telefonu

SELECT TOP 20
    EmailAddress,
    -- klasycznie: wszystko po znaku @
    -- SUBSTRING składnia: SUBSTRING(string, start, length)
    SUBSTRING(EmailAddress, CHARINDEX('@', EmailAddress) + 1, LEN(EmailAddress)) AS Domain_Traditional,

    -- regex: usuń wszystko od początku do znaku @
    --     ^      -- od początku tekstu
    --     .*     -- dowolne znaki
    --     @      -- aż do znaku @
    REGEXP_REPLACE(EmailAddress, '^.*@','') AS Domain_Regex 

FROM DemoRegex.EmailAddress
WHERE REGEXP_LIKE(EmailAddress, '^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
ORDER BY EmailAddress;
GO



SELECT TOP 20
    EmailAddress,
    -- klasycznie: wszystko przed znakiem @
    SUBSTRING(EmailAddress, 1, CHARINDEX('@', EmailAddress) - 1) AS UserName_Traditional,

    -- regex: usuń znak @ i wszystko po nim
    --      @      -- od znaku @
    --      .*     -- dowolne znaki
    --      $      -- do końca tekstu
    REGEXP_REPLACE(EmailAddress, '@.*$', '') AS UserName_Regex

FROM DemoRegex.EmailAddress
WHERE REGEXP_LIKE(EmailAddress, '^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
ORDER BY EmailAddress;
GO





-- ============================================
-- 4. Porównanie wydajności
-- ============================================

SELECT TOP (1000000)
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS Id,
    '(+48) 501-234-567' AS Phone
INTO #BigData
FROM sys.all_objects a
CROSS JOIN sys.all_objects b;

SET STATISTICS TIME ON;

-- CPU time = 765 ms,  elapsed time = 4919 ms.
SELECT REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Phone,' ',''),'-',''),'(',''),')',''),'+','')
FROM #BigData;

-- CPU time = 4031 ms,  elapsed time = 5889 ms.
SELECT REGEXP_REPLACE(Phone, '\D', '')
FROM #BigData;


SET STATISTICS TIME OFF;


-- REGEXP_REPLACE nie zastępuje REPLACE pod kątem wydajności.
-- REGEXP_REPLACE zastępuje skomplikowaną logikę tekstową pod kątem czytelności i elastyczności.






-- ============================================
-- 5. start_position
--    Zamiana dopiero od wskazanej pozycji
-- regex: \d = dowolna cyfra
-- ============================================

DECLARE @SourceText varchar(50) = 'ABC-123-DEF-456';

SELECT
    @SourceText AS SourceText,
    REGEXP_REPLACE(@SourceText, '\d', 'X') AS ReplaceFromBeginning,
    REGEXP_REPLACE(@SourceText, '\d', 'X', 9) AS ReplaceFromPosition9;
GO

-- start = 9 oznacza: zacznij szukać dopasowań od 9. znaku


-- ============================================
-- 6. occurrence
--    Zamiana tylko konkretnego wystąpienia
-- ============================================

DECLARE @SourceText varchar(50) = 'ABC-123-DEF-456';

SELECT
    @SourceText AS SourceText,
    REGEXP_REPLACE(@SourceText, '\d', 'X', 1) AS Replace_AllDigit,
    REGEXP_REPLACE(@SourceText, '\d', 'X', 1, 0) AS Replace_AllDigit,
    REGEXP_REPLACE(@SourceText, '\d', 'X', 1, 1) AS Replace_FirstDigit,
    REGEXP_REPLACE(@SourceText, '\d', 'X', 1, 2) AS Replace_SecondDigit,
    REGEXP_REPLACE(@SourceText, '\d', 'X', 1, 3) AS Replace_ThirdDigit,
    REGEXP_REPLACE(@SourceText, '\d', 'X', 1, 4) AS Replace_FourthDigit;
GO






-- ============================================
-- 7. match_parameter / flags
--  i - bez uwzględniania wielkości liter (wartość domyślna false)
--  c - uwzględnianie wielkości liter
--  m - multiline, ^ i $ działają dla każdej linii
-- ============================================

-- A/ Zamiana case-sensitive vs case-insensitive

DECLARE @SourceText varchar(50) = 'ABC-123-abc-456';

SELECT
    @SourceText AS SourceText,

    -- c = case-sensitive
    -- zamienione zostanie tylko małe abc
    REGEXP_REPLACE(@SourceText, 'abc', 'XXX', 1, 0, 'c') AS Case_Sensitive,

    -- i = case-insensitive
    -- zamienione zostanie ABC i abc
    REGEXP_REPLACE(@SourceText, 'abc', 'XXX', 1, 0, 'i') AS Case_Insensitive
GO


-- B/ tryb wielowierszowy (multiline)
-- match_parameter = m - ^ i $ działają dla każdej linii

DECLARE @SourceText varchar(50) = N'ERROR pierwszy
INFO drugi
ERROR trzeci';

SELECT
    @SourceText AS SourceText,

    -- bez m: ^ dotyczy początku całego tekstu
    REGEXP_REPLACE(@SourceText, '^ERROR', 'WARN', 1, 0, 'c') AS Without_Multiline,

    -- z m: ^ dotyczy początku każdej linii
    REGEXP_REPLACE(@SourceText, '^ERROR', 'WARN', 1, 0, 'm') AS With_Multiline;
GO


