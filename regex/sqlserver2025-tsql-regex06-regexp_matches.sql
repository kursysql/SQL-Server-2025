/*

	TSQL: REGEXP_MATCHES w SQL Server 2025 — wiele dopasowań z tekstu
	Tomasz Lbera | MVP Data Platform
	libera@kursysql.pl
	
    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL
    https://github.com/kursysql/SQL-Server-2025/

    Funkcja REGEXP_MATCHES
    funkcja tabelaryczna
    zwraca wszystkie fragmenty tekstu pasujące do wzorca wyrażenia regularnego


    REGEXP_SUBSTR  = daj mi jedno dopasowanie
    REGEXP_MATCHES = daj mi wszystkie dopasowania jako wiersze

    Składnia:
    REGEXP_MATCHES(string_expression, pattern_expression [ , flags ])

    - string_expression: tekst, w którym szukamy dopasowań
    - pattern_expression: wyrażenie regularne, które definiuje wzorzec dopasowania
    - flags: opcjonalne parametry modyfikujące działanie funkcji (np. 'i' dla ignorowania wielkości liter)

    zwraca tabelę z kolumną 'match' zawierającą dopasowane fragmenty tekstu
    - match_id - numer dopasowania (1 dla pierwszego, 2 dla drugiego itd.)
    - start_pos - pozycja początkowa dopasowania w string_expression
    - end_pos - pozycja końcowa dopasowania w string_expression
    - match_value - dopasowany fragment tekstu
    - substring_match - dopasowanie do grupy w wyrażeniu regularnym (jeśli użyto grupowania)

    Dokumentacja:
    https://learn.microsoft.com/en-us/sql/t-sql/functions/regexp-matches-transact-sql?view=sql-server-ver17

    
    Agenda:

    1. REGEXP_MATCHES - podstawy - zlicz liczby w tekście
    2. Zlicz adresy e-mail w tekście
    3. Zlicz numery telefonów
    4. Wszystkie liczby występujące w adresie
    5. Wszystkie domeny w adresach e-mail
    

*/


-- ============================================
-- 1. REGEXP_MATCHES - podstawy - zlicz liczby w tekście
-- ============================================

DECLARE @SourceText varchar(50) = 'ABC-123-DEF-456';

SELECT *
-- \d+ - dopasowuje ciąg jednej lub więcej cyfr
FROM REGEXP_MATCHES(@SourceText, '\d+');
GO




-- ============================================
-- 2. Zlicz adresy e-mail w tekście
-- ============================================

DECLARE @SourceText varchar(50) = 'jan@test.pl; anna@firma.pl; admin@wp.pl';

SELECT *
FROM REGEXP_MATCHES(@SourceText, '[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}');
GO




-- ============================================
-- 3. Zlicz numery telefonów 
-- ============================================

DECLARE @SourceText varchar(200) = 'Telefony: +48 501 234 567, +49 123 456 789, 501-222-333';

SELECT *
FROM REGEXP_MATCHES(@SourceText, '\+?\d[\d -]{7,}');
GO


-- ============================================
-- 4. Wszystkie liczby występujące w adresie
-- ============================================

SELECT TOP 20
    a.AddressLine1,
    m.match_value
    --,m.*
FROM DemoRegex.Address a
JOIN DemoRegex.StateProvince AS sp ON a.StateProvinceID = sp.StateProvinceID
CROSS APPLY REGEXP_MATCHES(a.AddressLine1, '\d+') m
WHERE sp.CountryRegionCode = 'PL'
GO




-- ============================================
-- 5. Wszystkie domeny w adresach e-mail
-- ============================================

SELECT
    ea.EmailAddress,
    m.match_value
FROM DemoRegex.Emails ea
CROSS APPLY REGEXP_MATCHES(ea.EmailAddress, '(\.[A-Za-z]{2,})+$') m;
GO



