/*

	TSQL: REGEXP_SUBSTR w SQL Server 2025 - wyciąganie danych z tekstu
	Tomasz Lbera | MVP Data Platform
	libera@kursysql.pl
	
    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL
    https://github.com/kursysql/SQL-Server-2025/

    Funkcja REGEXP_SUBSTR
    zwraca fragment tekstu pasujący do wzorca wyrażenia regularnego

    Składnia:
    REGEXP_SUBSTR ( expression , pattern [ , start [ , occurrence [ , flags [ , group ] ] ] ] )
     expression - tekst, z którego chcemy wyciągnąć dane
     pattern - wzorzec wyrażenia regularnego
     start - opcjonalnie, pozycja początkowa wyszukiwania (domyślnie 1)
     occurrence - opcjonalnie, która wystąpienie wzorca zwrócić (domyślnie 1)
     flags - opcjonalnie, dodatkowe parametry dopasowania (np. 'c' dla case-sensitive)
     group - opcjonalnie, numer grupy do zwrócenia (domyślnie 0, czyli całe dopasowanie)


    Dokumentacja:
    https://learn.microsoft.com/pl-pl/sql/t-sql/functions/regexp-substr-transact-sql?view=sql-server-ver17
    
    Agenda:
    1. REGEXT_SUBSTR VS SUBSTRING
    2. Wyciąganie domeny z adresu email
    3. Wyciąganie nazwy użytkownika z adresu email
    4. group - grupy przechwytujące (capturing groups)
    5. start - wyszukiwanie od określonej pozycji
    6. occurrence - które dopasowanie zwrócić
    7. flags - case-sensitive / case-insensitive
    8. Dane z DemoRegex: użytkownik i domena emaila
    9. Dane z DemoRegex: numer kierunkowy kraju z telefonu

*/


-- ============================================
-- 1. REGEXT_SUBSTR VS SUBSTRING
-- ============================================

-- A/ pierwsze porównanie

DECLARE @AdresEmail varchar(50) = 'kontakt@kursysql.pl'

-- SUBSTRING składnia: SUBSTRING(expression, start, length)
SELECT
    SUBSTRING(@AdresEmail, 2, 3) AS SubstringClassic,
    REGEXP_SUBSTR(@AdresEmail, '[a-z]+') AS FirstWord;
GO


-- ============================================
-- 2. Wyciąganie domeny z adresu email
-- ============================================

DECLARE @AdresEmail varchar(50) = 'kontakt@kursysql.pl'

SELECT SUBSTRING(
	@AdresEmail, 
	CHARINDEX('@', @AdresEmail)+1, 
	CHARINDEX('@', REVERSE(@AdresEmail))
    ) AS Domain_Substring,

    -- @(.+)$ = znak @, potem grupa z domeną do końca tekstu
    -- group = 1 oznacza: zwróć tylko zawartość pierwszej grupy
    REGEXP_SUBSTR(@AdresEmail, '@(.+)$', 1, 1, 'i', 1) AS Domain_Regex
GO



-- ============================================
-- 3. Wyciąganie nazwy użytkownika z adresu email
-- ============================================

DECLARE @AdresEmail varchar(50) = 'kontakt@kursysql.pl'

SELECT
    LEFT(
        @AdresEmail,
        CHARINDEX('@', @AdresEmail) - 1
    ) AS User_Traditional,

    -- ^([^@]+)@ = od początku tekstu (^) dopasuj grupę złożoną z dowolnych znaków oprócz @ ([^@]+), 
    -- a potem znak @
    -- group = 1 oznacza: zwróć tylko zawartość pierwszej grupy, czyli nazwę użytkownika bez @
    REGEXP_SUBSTR(@AdresEmail, '^([^@]+)@', 1, 1, 'c', 1) AS User_Regex;
GO


-- ============================================
-- 4. group - grupy przechwytujące (capturing groups)
-- ============================================

DECLARE @Phone varchar(20) = '+48 501 234 567';

SELECT -- przykład z jedną grupą
    @Phone AS PhoneNumber,

    -- całe dopasowanie
    REGEXP_SUBSTR(@Phone, '\+(\d{2})', 1, 1, 'c', 0) AS WholeMatch,

    -- pierwsza grupa
    -- (\d{2}) - grupa nr 1 zawierająca dwie cyfry
    REGEXP_SUBSTR(@Phone, '\+(\d{2})', 1, 1, 'c', 1) AS Group1;
GO


DECLARE @Phone varchar(20) = '+48 501 234 567';

SELECT -- przykład z dwoma grupami
    @Phone AS PhoneNumber,
    REGEXP_SUBSTR(@Phone, '\+(\d{2}) (\d{3})', 1, 1, 'c', 0) AS WholeMatch,

    REGEXP_SUBSTR(@Phone, '\+(\d{2}) (\d{3})', 1, 1, 'c', 1) AS CountryCode,

    REGEXP_SUBSTR(@Phone, '\+(\d{2}) (\d{3})', 1, 1, 'c', 2) AS FirstDigits;
GO


-- w regex_replace też można korzystać z grup przechwytujących, odwołując się do nich jako \1, \2 itd.

DECLARE @Phone varchar(20) = '+48 501 234 567';

SELECT
    @Phone AS PhoneNumber,

    -- całe dopasowanie
    REGEXP_REPLACE(@Phone, '\+(\d{2}) (\d{3})', '*\1*-*\2*') AS BothGroups,

    REGEXP_REPLACE(@Phone, '\+(\d{2}) (\d{3})', '*\1*') AS OnlyGroup1,

    REGEXP_REPLACE(@Phone, '\+(\d{2}) (\d{3})', '\1*\2*') AS OnlyGroup2

GO


-- ============================================
-- 5. start - wyszukiwanie od określonej pozycji
-- ============================================

DECLARE @SourceText varchar(50) = 'ABC-123-DEF-456';

SELECT
    @SourceText AS SourceText,
    -- \d+ = dopasuj ciąg cyfr, 
    -- domyślnie start = 1, więc znajdzie pierwszą liczbę
    REGEXP_SUBSTR(@SourceText, '\d+') AS FirstNumber,

    -- start = 9, więc znajdzie drugą liczbę (456)
    REGEXP_SUBSTR(@SourceText, '\d+', 9) AS NumberFromPosition9;
GO


-- ============================================
-- 6. occurrence - które dopasowanie zwrócić
-- ============================================

DECLARE @SourceText varchar(50) = 'ABC-123-DEF-456';

SELECT
    @SourceText AS SourceText,
    -- domyślnie occurrence = 1, więc znajdzie pierwszą liczbę (123)
    REGEXP_SUBSTR(@SourceText, '\d+', 1, 1) AS FirstNumber,

    -- occurrence = 2, więc znajdzie drugą liczbę (456)
    REGEXP_SUBSTR(@SourceText, '\d+', 1, 2) AS SecondNumber;
GO



-- ============================================
-- 7. flags - case-sensitive / case-insensitive
-- ============================================

DECLARE @SourceText varchar(50) = 'ABC-123-abc-456';

SELECT
    @SourceText AS SourceText,
    -- bez flag, więc domyślnie case-sensitive, znajdzie pierwsze dopasowanie 'ABC'
    REGEXP_SUBSTR(@SourceText, 'abc', 1, 1, 'c') AS CaseSensitive,

    -- flaga 'i' oznacza case-insensitive, więc znajdzie pierwsze dopasowanie 'abc' (niezależnie od wielkości liter)
    REGEXP_SUBSTR(@SourceText, 'abc', 1, 1, 'i') AS CaseInsensitive;
GO


-- ============================================
-- 8. Dane z DemoRegex: użytkownik i domena emaila
-- ============================================


SELECT 
    EmailAddress,
    IIF(REGEXP_LIKE(EmailAddress,'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'), 'Valid', 'Invalid') AS EmailValidity,

    -- ^([^@]+)@ = od początku tekstu (^) dopasuj grupę złożoną z dowolnych znaków oprócz @ ([^@]+),
    REGEXP_SUBSTR(EmailAddress, '^([^@]+)@', 1, 1, 'c', 1) AS EmailUser,

    -- @(.+)$ = znak @, potem grupa z domeną do końca tekstu
    REGEXP_SUBSTR(EmailAddress, '@(.+)$', 1, 1, 'c', 1) AS EmailDomain

FROM DemoRegex.EmailAddress AS ea
INNER JOIN DemoRegex.BusinessEntityAddress AS be ON ea.BusinessEntityID = be.BusinessEntityID
INNER JOIN DemoRegex.Address AS a ON be.AddressID = a.AddressID
INNER JOIN DemoRegex.StateProvince AS sp ON a.StateProvinceID = sp.StateProvinceID
WHERE sp.CountryRegionCode = 'PL';
GO




-- ============================================
-- 9. Dane z DemoRegex: numer kierunkowy kraju z telefonu
-- ============================================

SELECT
    PhoneNumber,

    -- \+\d{1,3} = znak +, potem 1-3 cyfry (numer kierunkowy kraju)
    REGEXP_SUBSTR(PhoneNumber, '\+\d{1,3}') AS CountryCode

FROM DemoRegex.PersonPhone AS pp
INNER JOIN DemoRegex.BusinessEntityAddress be ON pp.BusinessEntityID = be.BusinessEntityID
INNER JOIN DemoRegex.Address a ON be.AddressID = a.AddressID
INNER JOIN DemoRegex.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
WHERE sp.CountryRegionCode = 'PL'
ORDER BY PhoneNumber; 
GO

