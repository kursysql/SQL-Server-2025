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

    
    Agenda:


    Dokumentacja:

    

*/


-- ============================================
-- REGEXP_REPLACE - demo
-- ============================================

-- Dane testowe
DROP TABLE IF EXISTS #Data;
GO

CREATE TABLE #Data
(
    Id int IDENTITY(1,1),
    Phone nvarchar(50),
    Email nvarchar(200),
    CustomerCode nvarchar(50)
);

INSERT INTO #Data (Phone, Email, CustomerCode)
VALUES
('500-600-700', ' jan.kowalski@gmail.com ', 'cust-12345'),
('+48 501 222 333', 'ANNA.NOWAK@FIRMA.PL', 'CUST 98765'),
('(+48)600700800', ' test@@gmail.com ', 'cust_54321'),
('500600700', 'marek@', 'CUST-12A45'),
('501 502 503', 'ewa.zielinska@wp.pl ', 'cust-00001');

-- ============================================
-- 1. Usuwanie znaków niebędących cyframi (telefon)
-- ============================================

SELECT
    Phone,
    REGEXP_REPLACE(Phone, '\D', '') AS CleanPhone
FROM #Data;

-- \D = wszystko co NIE jest cyfrą

-- ============================================
-- 2. Normalizacja numeru telefonu (format PL)
-- ============================================

SELECT
    Phone,
    REGEXP_REPLACE(Phone, '\D', '') AS DigitsOnly,
    REGEXP_REPLACE(REGEXP_REPLACE(Phone, '\D', ''), '^48', '') AS WithoutCountryCode
FROM #Data;

-- ============================================
-- 3. Usuwanie spacji z początku i końca (TRIM regexem)
-- ============================================

SELECT
    Email,
    REGEXP_REPLACE(Email, '^\s+|\s+$', '') AS TrimmedEmail
FROM #Data;

-- ^\s+ = spacje na początku
-- \s+$ = spacje na końcu

-- ============================================
-- 4. Zamiana wielu spacji na jedną
-- ============================================

SELECT
    Phone,
    REGEXP_REPLACE(Phone, '\s+', ' ') AS NormalizedSpaces
FROM #Data;

-- ============================================
-- 5. Standaryzacja CustomerCode
-- ============================================

SELECT
    CustomerCode,
    REGEXP_REPLACE(UPPER(CustomerCode), '[^A-Z0-9]', '-') AS NormalizedCode
FROM #Data;

-- ============================================
-- 6. Usuwanie podwójnych separatorów
-- ============================================

SELECT
    CustomerCode,
    REGEXP_REPLACE(
        REGEXP_REPLACE(UPPER(CustomerCode), '[^A-Z0-9]', '-'),
        '-+',
        '-'
    ) AS CleanCode
FROM #Data;

-- ============================================
-- 7. Mini walidacja po czyszczeniu
-- ============================================

SELECT
    CustomerCode,
    REGEXP_REPLACE(
        REGEXP_REPLACE(UPPER(CustomerCode), '[^A-Z0-9]', '-'),
        '-+',
        '-'
    ) AS CleanCode,
    CASE
        WHEN REGEXP_LIKE(
            REGEXP_REPLACE(
                REGEXP_REPLACE(UPPER(CustomerCode), '[^A-Z0-9]', '-'),
                '-+',
                '-'
            ),
            '^CUST-\d{5}$'
        )
        THEN 1
        ELSE 0
    END AS IsValid
FROM #Data;

-- ============================================
-- 8. Wydajność: REPLACE vs REGEXP_REPLACE
-- ============================================

SET STATISTICS TIME, IO ON;

-- klasyczne podejście
SELECT
    REPLACE(REPLACE(REPLACE(Phone, '-', ''), ' ', ''), '(', '') AS CleanPhone
FROM #Data;

-- regex
SELECT
    REGEXP_REPLACE(Phone, '\D', '') AS CleanPhone
FROM #Data;

SET STATISTICS TIME, IO OFF;