/*

	TSQL: REGEXP_LIKE w SQL Server 2025 — koniec z LIKE?
	Tomasz Lbera | MVP Data Platform
	libera@kursysql.pl
	
    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL

    Funkcja REGEXP_LIKE
    sprawdza, czy tekst pasuje do wzorca wyrażenia regularnego

    Składnia:
    REGEXP_LIKE ( expression, pattern [, match_parameter] )
    
    zwraca BIT (1/0)
    
    Agenda:
    1. LIKE vs REGEXP_LIKE - podstawy
    2. Składnia regex - podstawowe elementy (start, koniec, cyfry, powtórzenia)
    3. REGEXP_LIKE zwraca BIT - ważna pułapka
    4. Walidacja emaili i kodów pocztowych


    Dokumentacja:
    https://learn.microsoft.com/en-us/sql/t-sql/functions/regexp-like-transact-sql?view=sql-server-ver17

    

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
FROM Person.Person AS p
INNER JOIN Person.EmailAddress AS e ON p.BusinessEntityID = e.BusinessEntityID
WHERE EmailAddress LIKE '%@adventure-works.com'
ORDER BY LastName;
GO

-- REGEXP_LIKE: Wyrażenia regularne, pełna kontrola
SELECT
    FirstName,
    LastName,
    EmailAddress
FROM Person.Person AS p
INNER JOIN Person.EmailAddress AS e ON p.BusinessEntityID = e.BusinessEntityID
WHERE REGEXP_LIKE(EmailAddress, '@adventure-works\.com$')
ORDER BY LastName;
GO

-- Ctrl+M
-- wydajnościowo REGEXP_LIKE jest w tym konkretnym przypadku szybszy:
-- REGEXP_LIKE jest ~5x szybszy (17% vs 83%)
-- Kotwica $ w regex jest efektywniejsza niż LIKE '%...'
-- RE2 ma lepsze optymalizacje dla tego typu wzorców
-- ale to zależy od wzorca i danych, więc zawsze testuj na swoim środowisku!


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

-- Przykład: kod pocztowy 5 cyfr
SELECT TOP 5 AddressLine1, City, PostalCode
FROM Person.Address
WHERE REGEXP_LIKE(PostalCode, '^\d{5}$')
ORDER BY PostalCode;
GO

-- Przykład: 12345 lub 12345-6789 (opcjonalne rozszerzenie)
SELECT TOP 5 AddressLine1, City, PostalCode
FROM Person.Address
WHERE REGEXP_LIKE(PostalCode, '^\d{5}(-\d{4})?$')
ORDER BY PostalCode;
GO


-- Przykład: wyszukanie tylko polskich kodów pocztowych (format 30-198)
SELECT 
    AddressLine1,
    City,
    PostalCode,
    CountryRegionCode
FROM Person.Address a
INNER JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
WHERE REGEXP_LIKE(PostalCode, '^\d{2}-\d{3}$')  -- Format: 30-198
ORDER BY PostalCode;
GO





-- Flagi regex: case-insensitive, multiline
-- 'i' = case-insensitive
-- 'c' = case-sensitive (domyślnie)
-- 'm' = multi-line mode
-- 's' = let . match \n

-- Case-sensitive (domyślnie)
SELECT COUNT(*) AS ProductCount
FROM Production.Product
WHERE REGEXP_LIKE(Name, 'black');
GO

-- Case-insensitive
SELECT COUNT(*) AS ProductCount
FROM Production.Product
WHERE REGEXP_LIKE(Name, 'black', 'i');
GO

-- ============================================
-- 3. REGEXP_LIKE zwraca BIT - ważna pułapka

-- REGEX_LIKE zwraca TRUE/FALSE, więc można go użyć bezpośrednio w SELECT lub WHERE
-- to warunek/ predykat logiczny, a nie typowa funkcja zwracająca wartość

-- najlepiej opakować go w CASE lub IIF, żeby zwracał 1/0 lub 'Valid'/'Invalid'
-- ale nie w ten sposób, bo REGEXP_LIKE zwraca BIT, a nie można go porównywać do 1/0 bezpośrednio w CASE
-- ============================================

-- !!! REGEXP_LIKE zwraca TRUE/ FALSE, więc nie można użyć bezpośrednio
SELECT PostalCode, REGEXP_LIKE(PostalCode, '^\d{2}-\d{3}$') AS IsValidPL
FROM Person.Address a
INNER JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
WHERE CountryRegionCode = 'PL';
GO

-- BŁĄD: Nie można porównywać REGEXP_LIKE = 1 w CASE
-- Incorrect syntax near '='.
SELECT PostalCode,
    CASE WHEN REGEXP_LIKE(PostalCode, '^\d{2}-\d{3}$') = 1 THEN 1 ELSE 0 END
FROM Person.Address a
INNER JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
WHERE sp.CountryRegionCode = 'PL';



-- POPRAWNIE: CASE bez porównania
SELECT PostalCode,
    CASE WHEN REGEXP_LIKE(PostalCode, '^\d{2}-\d{3}$') THEN 1 ELSE 0 END AS IsValidPL
FROM Person.Address a
INNER JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
WHERE sp.CountryRegionCode = 'PL';
GO

-- POPRAWNIE2: IIF (najkrócej)
SELECT PostalCode,
    IIF(REGEXP_LIKE(PostalCode, '^\d{2}-\d{3}$'), 1, 0) AS IsValidPL
FROM Person.Address a
INNER JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
WHERE sp.CountryRegionCode = 'PL';
GO




-- ============================================
-- 4. Walidacja emaili i kodów pocztowych
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
FROM Person.EmailAddress
ORDER BY EmailAddress;

SELECT 
    IIF(REGEXP_LIKE(EmailAddress, @email_pattern), 1, 0) AS IsValidEmail,
    count(*)
FROM Person.EmailAddress
GROUP BY IIF(REGEXP_LIKE(EmailAddress, @email_pattern), 1, 0)
GO


DECLARE @email_pattern nvarchar(200) = '^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

-- Sprawdzenie poprawnych emaili
SELECT 
    EmailAddress,
    IIF(REGEXP_LIKE(EmailAddress, @email_pattern), 1, 0) AS IsValidEmail
FROM Person.EmailAddress
WHERE REGEXP_LIKE(EmailAddress, @email_pattern) 
ORDER BY EmailAddress;
GO



-- Znalezienie potencjalnie niepoprawnych emaili
-- (adresy ze znakami not-ASCII, bez domeny (PL)
DECLARE @email_pattern nvarchar(200) = '^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

SELECT 
    EmailAddress,
    IIF(REGEXP_LIKE(EmailAddress, @email_pattern), 1, 0) AS IsValidEmail
FROM Person.EmailAddress
WHERE NOT REGEXP_LIKE(EmailAddress, @email_pattern) -- NOT
ORDER BY EmailAddress;
GO




-- Walidacja numerów telefonów
-- Format: (123) 456-7890 lub 123-456-7890
SELECT TOP 10
    PhoneNumber,
    PhoneNumberTypeID,
    CASE 
        WHEN REGEXP_LIKE(PhoneNumber, '^\(\d{3}\) \d{3}-\d{4}$') THEN 'Format: (123) 456-7890'
        WHEN REGEXP_LIKE(PhoneNumber, '^\d{3}-\d{3}-\d{4}$') THEN 'Format: 123-456-7890'
        ELSE 'Inny format'
    END AS PhoneFormat
FROM Person.PersonPhone
ORDER BY PhoneNumber;
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


-- Porównanie: LIKE vs REGEXP_LIKE dla różnych wzorców
SELECT 
    ProductNumber,
    CASE 
        WHEN ProductNumber LIKE 'BK-%' THEN 'LIKE: Bike'
        ELSE 'LIKE: Other'
    END AS LIKE_Result,
    CASE 
        WHEN REGEXP_LIKE(ProductNumber, '^BK-[A-Z]\d+') THEN 'REGEX: Bike (strict)'
        ELSE 'REGEX: Other'
    END AS REGEX_Result
FROM Production.Product
WHERE ProductNumber LIKE 'BK-%'
ORDER BY ProductNumber;
GO




SELECT DISTINCT CountryRegionCode
FROM Person.Address a
INNER JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID



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
FROM Person.Address a
INNER JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
--WHERE sp.CountryRegionCode IN ('US', 'CA', 'FR', 'PL')
--WHERE sp.CountryRegionCode = 'FR'
WHERE sp.CountryRegionCode = 'PL'
ORDER BY sp.CountryRegionCode, a.PostalCode;
GO




