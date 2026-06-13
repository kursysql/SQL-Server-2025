/*

	TSQL: REGEXP_LIKE w SQL Server 2025 — koniec z LIKE?
	Tomasz Lbera | MVP Data Platform
	libera@kursysql.pl
	
    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL
    https://github.com/kursysql/SQL-Server-2025/

    Funkcja REGEXP_LIKE
    sprawdza, czy tekst pasuje do wzorca wyrażenia regularnego

    Składnia:
    REGEXP_LIKE ( expression, pattern [, match_parameter] )
    
    zwraca True/False
    
    Dokumentacja:
    https://learn.microsoft.com/en-us/sql/t-sql/functions/regexp-like-transact-sql?view=sql-server-ver17

    Agenda:
    1. LIKE vs REGEXP_LIKE - podstawy
    2. Składnia regex - podstawowe elementy (start, koniec, cyfry, powtórzenia)
    4. REGEXP_LIKE zwraca BIT - ważna pułapka
    5. Walidacja adresów e-mail
    6. Walidacja numerów telefonów
    7. Walidacja kodów pocztowych

*/


USE AdventureWorks2025;
GO

-- ============================================
-- 1. LIKE vs REGEXP_LIKE — podstawy
-- ============================================


-- LIKE: Prosta składnia, ograniczone możliwości
SELECT 
    FirstName,
    LastName,
    EmailAddress
FROM DemoRegex.Person AS p
INNER JOIN DemoRegex.EmailAddress AS e ON p.BusinessEntityID = e.BusinessEntityID
WHERE EmailAddress LIKE '%@adventure-works.com'
ORDER BY LastName;
GO

-- REGEXP_LIKE: Wyrażenia regularne, pełna kontrola
SELECT
    FirstName,
    LastName,
    EmailAddress
FROM DemoRegex.Person AS p
INNER JOIN DemoRegex.EmailAddress AS e ON p.BusinessEntityID = e.BusinessEntityID
WHERE REGEXP_LIKE(EmailAddress, '@adventure-works\.com$')
ORDER BY LastName;
GO







-- Walidacja ProductNumber
-- LIKE: Produkty zaczynające się na 'BK-' (rowery)
SELECT ProductID, Name, ProductNumber
FROM Production.Product
WHERE ProductNumber LIKE 'BK-%'
ORDER BY ProductNumber;
GO

-- REGEXP_LIKE: Produkty z kodem BK-[litera][cyfry][litera]-[cyfry]
-- Przykład: BK-R93R-62
SELECT ProductID, Name, ProductNumber
FROM Production.Product
WHERE REGEXP_LIKE(ProductNumber, '^BK-[A-Z]\d+[A-Z]?-\d+$')
ORDER BY ProductNumber;
GO




-- ============================================
-- 2. Składnia regex — ^, $, \d, ., +, {}
-- ============================================

-- ^ = początek stringa
-- $ = koniec stringa
-- \d = cyfra (digit)
-- . = dowolny znak (w regex trzeba escapować \.)
-- + = jeden lub więcej
-- {n} = dokładnie n razy
-- {n,m} = od n do m razy
-- () = grupa znaków/ podwyrażenie
-- ? = element opcjonalny (0 lub 1 wystąpienie)

-- * = 0 lub więcej wystąpień
-- ? = 0 lub 1 wystąpienie (opcjonalne)
-- | = alternatywa (lub)
-- [] = klasa znaków, np. [A-Z]
-- [^] = negacja klasy znaków, np. [^0-9]

-- Przykład: kod pocztowy 5 cyfr
SELECT AddressLine1, City, PostalCode
FROM DemoRegex.Address
WHERE REGEXP_LIKE(PostalCode, '^\d{5}$')
GO

-- Przykład: 12345 lub 12345-6789 (opcjonalne rozszerzenie)
SELECT AddressLine1, City, PostalCode
FROM DemoRegex.Address
WHERE REGEXP_LIKE(PostalCode, '^\d{5}(-\d{4})?$')
GO


SELECT AddressLine1, City, PostalCode
FROM DemoRegex.Address
WHERE REGEXP_LIKE(PostalCode, '^\d{5}(-\d{4})?$')
EXCEPT
SELECT AddressLine1, City, PostalCode
FROM DemoRegex.Address
WHERE REGEXP_LIKE(PostalCode, '^\d{5}$')





-- Przykład: wyszukanie tylko polskich kodów pocztowych (format 30-198)
SELECT 
    AddressLine1,
    City,
    PostalCode,
    CountryRegionCode
FROM DemoRegex.Address a
INNER JOIN DemoRegex.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
WHERE REGEXP_LIKE(PostalCode, '^\d{2}-\d{3}$')  -- Format: 30-198
ORDER BY PostalCode;
GO



-- ============================================
-- 3. Flagi regex: case-insensitive, multiline
-- ============================================
-- 'i' = case-insensitive
-- 'c' = case-sensitive (domyślnie)
-- 'm' = multi-line mode
-- 's' = let . match \n

-- Case-sensitive (domyślnie)
SELECT *
FROM Production.Product
WHERE REGEXP_LIKE(Name, 'black')
--WHERE REGEXP_LIKE(Name, 'black', 's')
GO

-- Case-insensitive
SELECT *
FROM Production.Product
WHERE REGEXP_LIKE(Name, 'black', 'i');
GO


-- ============================================
-- 4. REGEXP_LIKE zwraca BIT 

-- REGEX_LIKE zwraca TRUE/FALSE, więc można go użyć bezpośrednio w SELECT lub WHERE
-- to warunek/ predykat logiczny, a nie typowa funkcja zwracająca wartość

-- najlepiej opakować go w CASE lub IIF, żeby zwracał 1/0 lub 'Valid'/'Invalid'
-- ale nie w ten sposób, bo REGEXP_LIKE zwraca BIT, a nie można go porównywać do 1/0 bezpośrednio w CASE
-- ============================================

-- !!! REGEXP_LIKE zwraca TRUE/ FALSE, więc nie można użyć bezpośrednio
SELECT PostalCode, REGEXP_LIKE(PostalCode, '^\d{2}-\d{3}$') AS IsValidPL
FROM DemoRegex.Address a
INNER JOIN DemoRegex.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
WHERE CountryRegionCode = 'PL';
GO

-- BŁĄD: Nie można porównywać REGEXP_LIKE = 1 w CASE
-- Incorrect syntax near '='.
SELECT PostalCode,
    CASE WHEN REGEXP_LIKE(PostalCode, '^\d{2}-\d{3}$') = 1 THEN 1 ELSE 0 END
FROM DemoRegex.Address a
INNER JOIN DemoRegex.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
WHERE sp.CountryRegionCode = 'PL';



-- POPRAWNIE: CASE bez porównania
SELECT PostalCode,
    CASE WHEN REGEXP_LIKE(PostalCode, '^\d{2}-\d{3}$') THEN 1 ELSE 0 END AS IsValidPL
FROM DemoRegex.Address a
INNER JOIN DemoRegex.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
WHERE sp.CountryRegionCode = 'PL';
GO



-- POPRAWNIE2: IIF (najkrócej)
SELECT PostalCode,
    IIF(REGEXP_LIKE(PostalCode, '^\d{2}-\d{3}$'), 1, 0) AS IsValidPL,
    a.City,
    sp.CountryRegionCode
FROM DemoRegex.Address a
INNER JOIN DemoRegex.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
WHERE sp.CountryRegionCode = 'PL';
GO




-- ============================================
-- 5. Walidacja adresów e-mail
-- ============================================

-- Walidacja emaili: coś@coś.coś
-- [a-zA-Z0-9._%-] = dozwolone znaki w nazwie użytkownika
-- + = jeden lub więcej
-- @ = znak małpy
-- [a-zA-Z0-9.-] = dozwolone znaki w domenie
-- \. = kropka (escaped)
-- [a-zA-Z]{2,} = rozszerzenie domenowe min 2 znaki

-- ^ = początek stringa
-- $ = koniec stringa


DECLARE @email_pattern nvarchar(200) = '^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

-- Sprawdzenie które maile są poprawne (1) a które nie (0)
SELECT 
    EmailAddress,
    IIF(REGEXP_LIKE(EmailAddress, @email_pattern), 1, 0) AS IsValidEmail
FROM DemoRegex.EmailAddress
ORDER BY EmailAddress;

SELECT 
    IIF(REGEXP_LIKE(EmailAddress, @email_pattern), 1, 0) AS IsValidEmail,
    count(*)
FROM DemoRegex.EmailAddress
GROUP BY IIF(REGEXP_LIKE(EmailAddress, @email_pattern), 1, 0)
GO


DECLARE @email_pattern nvarchar(200) = '^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

-- Sprawdzenie które maile są poprawne (1) a które nie (0)
SELECT 
    EmailAddress,
    IIF(REGEXP_LIKE(EmailAddress, @email_pattern), 1, 0) AS IsValidEmail
FROM DemoRegex.Emails
GO


DECLARE @email_pattern nvarchar(200) = '^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

-- Sprawdzenie poprawnych emaili
SELECT 
    EmailAddress,
    IIF(REGEXP_LIKE(EmailAddress, @email_pattern), 1, 0) AS IsValidEmail
FROM DemoRegex.EmailAddress
WHERE REGEXP_LIKE(EmailAddress, @email_pattern) 
ORDER BY EmailAddress;
GO



-- Znalezienie potencjalnie niepoprawnych emaili
-- (adresy ze znakami not-ASCII, bez domeny (PL)
DECLARE @email_pattern nvarchar(200) = '^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';


SELECT 
    EmailAddress,
    IIF(REGEXP_LIKE(EmailAddress, @email_pattern), 1, 0) AS IsValidEmail
FROM DemoRegex.EmailAddress
WHERE NOT REGEXP_LIKE(EmailAddress, @email_pattern) -- NOT
ORDER BY EmailAddress;
GO





-- ============================================
-- 6. Walidacja numerów telefonów
-- ============================================

-- Walidacja numerów telefonów
-- Format: (123) 456-7890 lub 123-456-7890
SELECT 
    PhoneNumber,
    PhoneNumberTypeID,
    CASE 
        WHEN REGEXP_LIKE(PhoneNumber, '^1 \(\d{2}\) \d{3} \d{3}-\d{4}$') THEN 'Format: 1 (11) 123 456-789'
        WHEN REGEXP_LIKE(PhoneNumber, '^\(\d{3}\) \d{3}-\d{4}$') THEN 'Format: (123) 456-7890'
        WHEN REGEXP_LIKE(PhoneNumber, '^\d{3}-\d{3}-\d{4}$') THEN 'Format: 123-456-7890'
        ELSE 'Inny format'
    END AS PhoneFormat
FROM Person.PersonPhone
ORDER BY PhoneNumber;
GO


-- Polskie numery telefonów komórkowych
/*
    ^
    (
        \+48      -- prefiks kraju
        [ -]?     -- opcjonalna spacja lub myślnik
    )?
    \d{3}        -- pierwsze 3 cyfry
    [ -]?        -- opcjonalny separator
    \d{3}        -- kolejne 3 cyfry
    [ -]?        -- opcjonalny separator
    \d{3}        -- ostatnie 3 cyfry
    $

*/

SELECT
    PhoneNumber,
    IIF(
        REGEXP_LIKE(
            PhoneNumber,
            '^(\+48[ -]?)?\d{3}[ -]?\d{3}[ -]?\d{3}$'
        ),
        'Poprawny',
        'Niepoprawny'
    ) AS ValidationResult
FROM DemoRegex.PersonPhone AS pp
INNER JOIN DemoRegex.BusinessEntityAddress be ON pp.BusinessEntityID = be.BusinessEntityID
INNER JOIN DemoRegex.Address a ON be.AddressID = a.AddressID
INNER JOIN DemoRegex.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
WHERE sp.CountryRegionCode = 'PL';
GO






-- ============================================
-- 7. Walidacja kodów pocztowych
-- ============================================

SELECT DISTINCT CountryRegionCode
FROM DemoRegex.Address a
INNER JOIN DemoRegex.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID



-- Walidacja kodów pocztowych (różne kraje)
SELECT 
    sp.CountryRegionCode,
    a.PostalCode,
    CASE 
        -- US: 12345 lub 12345-6789
        WHEN sp.CountryRegionCode = 'US' AND REGEXP_LIKE(a.PostalCode, '^\d{5}(-\d{4})?$') THEN 'Valid US ZIP'
        -- CA: A1A 1A1 lub A1A1A1 (litera-cyfra-litera [spacja] cyfra-litera-cyfra)
        WHEN sp.CountryRegionCode = 'CA' AND REGEXP_LIKE(a.PostalCode, '^[A-Z]\d[A-Z] ?\d[A-Z]\d$', 'i') THEN 'Valid CA Postal'
        -- FR: XXXXX (5 cyfr)
        WHEN sp.CountryRegionCode = 'FR' AND REGEXP_LIKE(a.PostalCode, '^\d{5}$') THEN 'Valid FR Postal'
        -- PL: XX-XXX (2 cyfry, myślnik, 3 cyfry)
        WHEN sp.CountryRegionCode = 'PL' AND REGEXP_LIKE(a.PostalCode, '^\d{2}-\d{3}$') THEN 'Valid PL Postal'
        ELSE 'Check Format'
    END AS ValidationResult
FROM DemoRegex.Address a
INNER JOIN DemoRegex.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
--WHERE sp.CountryRegionCode IN ('US', 'CA', 'FR', 'PL')
--WHERE sp.CountryRegionCode = 'FR'
--WHERE sp.CountryRegionCode = 'PL'
ORDER BY sp.CountryRegionCode, a.PostalCode;
GO

