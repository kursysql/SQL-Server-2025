/*

	TSQL: REGEXP_INSTR w SQL Server 2025 - znajdź pozycję wzorca
	Tomasz Lbera | MVP Data Platform
	libera@kursysql.pl
	
    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL
    https://github.com/kursysql/SQL-Server-2025/

    Funkcja REGEXP_INSTR
    zwraca pozycję pierwszego znaku fragmentu tekstu pasującego do wzorca wyrażenia regularnego


    Składnia:
    REGEXP_INSTR ( expression , 
        pattern_expression [ , start [ , occurrence [ , return_option [ , flags [ , group ] ] ] ] ]

        expression – ciąg znaków, w którym będzie wyszukiwany wzorzec
        pattern_expression – wyrażenie regularne, które będzie wyszukiwane w ciągu znaków expression
        start – opcjonalny argument określający pozycję początkową wyszukiwania. Domyślnie jest to 1, co oznacza, że wyszukiwanie rozpoczyna się od pierwszego znaku ciągu expression.
        occurrence – opcjonalny argument określający, która wystąpienie wzorca ma być zwrócone. Domyślnie jest to 1, co oznacza, że zostanie zwrócona pozycja pierwszego wystąpienia wzorca.
        return_option – opcjonalny argument określający, czy ma być zwrócona pozycja pierwszego znaku dopasowania (domyślnie 0) czy pozycja pierwszego znaku następującego po dopasowaniu (1).
        flags – opcjonalny argument określający dodatkowe opcje wyszukiwania, takie jak ignorowanie wielkości liter (i), dopasowanie wielowierszowe (m) lub dopasowanie pojedynczego wiersza (s).
        group – opcjonalny argument określający, która grupa przechwytywania ma być używana do zwracania pozycji. Domyślnie jest to 0, co oznacza, że będzie używana cała dopasowana sekwencja.

    Dokumentacja:
    https://learn.microsoft.com/pl-pl/sql/t-sql/functions/regexp-instr-transact-sql?view=sql-server-ver17
    
    Agenda:
    1. REGEXP_INSTR - pozycja pierwszego dopasowania
    2. start - pozycja początkowa wyszukiwania
    3. occurrence - która wystąpienie wzorca ma być zwrócone
    4. return_option - pozycja pierwszego znaku dopasowania vs. pozycja pierwszego znaku następującego po dopasowaniu
    5. flags - dodatkowe opcje wyszukiwania
    6. group - pozycja początku lub końca grupy przechwytywania
    7. Dane z DemoRegex: adresy e-mail i pozycje domeny
 

    

*/


-- ============================================
-- 1. REGEXP_INSTR - pozycja pierwszego dopasowania
-- ============================================

DECLARE @SourceText varchar(50) = 'ABC-123-DEF-456';

SELECT
    @SourceText AS SourceText,

    -- \d+ - dopasowuje jedną lub więcej cyfr
    REGEXP_INSTR(@SourceText, '\d+') AS FirstNumberPosition,

    -- - - dopasowuje znak myślnika
    REGEXP_INSTR(@SourceText, '-') AS FirstHyphenPosition,

    -- D - dopasowuje literę D
    REGEXP_INSTR(@SourceText, 'D') AS FirstDPosition,

    -- [a-zA-Z] - dopasowuje pierwszą literę (niezależnie od wielkości)
    REGEXP_INSTR(@SourceText, '[a-zA-Z]') AS FirstLetterPosition

GO


-- ============================================
-- 2. start - pozycja początkowa wyszukiwania
-- ============================================


DECLARE @SourceText varchar(50) = 'ABC-123-DEF-456';

SELECT
    @SourceText AS SourceText,

    REGEXP_INSTR(@SourceText, '\d+') AS FromBeginning,

    REGEXP_INSTR(@SourceText, '\d+', 9) AS FromPosition9;
GO



-- ============================================
-- 3. occurrence - która wystąpienie wzorca ma być zwrócone
-- ============================================

DECLARE @SourceText varchar(50) = 'ABC-123-DEF-456';

SELECT
    @SourceText AS SourceText,

    REGEXP_INSTR(@SourceText, '\d+', 1, 1) AS FirstNumber,

    REGEXP_INSTR(@SourceText, '\d+', 1, 2) AS SecondNumber;
GO


-- ============================================
-- 4. return_option - pozycja pierwszego znaku dopasowania 
--  vs. pozycja pierwszego znaku następującego po dopasowaniu
-- ============================================

DECLARE @SourceText varchar(50) = 'ABC-123-DEF-456';

SELECT
    @SourceText AS SourceText,

    -- początek dopasowania (domyślnie)
    REGEXP_INSTR(@SourceText, '\d+', 1, 1, 0) AS StartPosition,

    -- znak po końcu dopasowania
    REGEXP_INSTR(@SourceText, '\d+', 1, 1, 1) AS EndPositionPlus1;
GO


DECLARE @SourceText varchar(50) = 'ABC-123-DEF-456';
SELECT
    @SourceText AS SourceText,
    --! tylko 0/1 są poprawnymi wartościami dla return_option
    REGEXP_INSTR(@SourceText, '\d+', 1, 1, 3) AS StartPosition
GO


-- ============================================
-- 5. flags - dodatkowe opcje wyszukiwania
-- ============================================

DECLARE @SourceText varchar(50) = 'ABC-123-abc-456';

SELECT
    @SourceText AS SourceText,

    -- c = case-sensitive
    REGEXP_INSTR(@SourceText, 'abc', 1, 1, 0, 'c') AS CaseSensitive1,
    REGEXP_INSTR(@SourceText, '[a-z]', 1, 1, 0, 'c') AS CaseSensitive2,

    -- i = case-insensitive
    REGEXP_INSTR(@SourceText, 'abc', 1, 1, 0, 'i') AS CaseInsensitive1,
    REGEXP_INSTR(@SourceText, '[a-z]', 1, 1, 0, 'i') AS CaseInsensitive2;
GO



-- ============================================
-- 6. group - pozycja początku lub końca grupy przechwytywania
-- ============================================

DECLARE @Phone varchar(20) = '+48 501 234 567';

SELECT
    @Phone AS PhoneNumber,

    -- całe dopasowanie: +48 501
    REGEXP_SUBSTR(@Phone, '\+(\d{2}) (\d{3})', 1, 1, 'c', 0) AS WholeMatch_SUBSTR,
    REGEXP_INSTR(@Phone, '\+(\d{2}) (\d{3})', 1, 1, 0, 'c', 0) AS WholeMatch_INSTR,

    -- grupa 1: 48
    REGEXP_SUBSTR(@Phone, '\+(\d{2}) (\d{3})', 1, 1, 'c', 1) AS Group1_SUBSTR,
    REGEXP_INSTR(@Phone, '\+(\d{2}) (\d{3})', 1, 1, 0, 'c', 1) AS Group1_INSTR,           
        
    -- grupa 2: 501
    REGEXP_SUBSTR(@Phone, '\+(\d{2}) (\d{3})', 1, 1, 'c', 2) AS Group2_SUBSTR,
    REGEXP_INSTR(@Phone, '\+(\d{2}) (\d{3})', 1, 1, 0, 'c', 2) AS Group2_INSTR;
        
GO




-- ============================================
-- 7. Dane z DemoRegex: adresy e-mail i pozycja znaku @
--  regexp_instr ma sens jeśli szukamy wzorca, a nie pojedynczego znaku. 
--  Dla pojedynczego znaku lepiej użyć charindex, który jest szybszy.
-- ============================================


SELECT 
    EmailAddress,
    CHARINDEX('@', EmailAddress) AS AtPosition_charindex,
    REGEXP_INSTR(EmailAddress, '@') AS AtPosition

FROM DemoRegex.EmailAddress AS ea
INNER JOIN DemoRegex.BusinessEntityAddress AS be ON ea.BusinessEntityID = be.BusinessEntityID
INNER JOIN DemoRegex.Address AS a ON be.AddressID = a.AddressID
INNER JOIN DemoRegex.StateProvince AS sp ON a.StateProvinceID = sp.StateProvinceID
WHERE sp.CountryRegionCode = 'PL';
GO


