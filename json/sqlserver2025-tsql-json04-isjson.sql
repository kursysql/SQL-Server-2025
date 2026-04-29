/*

	TSQL: ISJSON 
	Tomasz Lbera | MVP Data Platform
	libera@kursysql.pl
	
    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL

    Funkcja ISJSON
    sprawdza czy tekst zawiera poprawny JSON

    Składnia:
    ISJSON ( expression [, json_type_constraint] )
    
    Dokumentacja:
    https://learn.microsoft.com/pl-pl/sql/t-sql/functions/isjson-transact-sql?view=sql-server-ver17


    1. Zacznijmy od prostego przykładu
    2. ISJSON i json_type_constraint
    3. ISJSON z tabeli
    4. Praktyczne użycie ISJSON
    5. Ograniczenie: ISJSON nie sprawdza semantyki dokumentu
    

*/


USE AdventureWorks2025
GO





/*
    -------------------------------------------------------------------
    1. Zacznijmy od prostego przykładu
    - ISJSON zwraca 1, 0 albo NULL
    - bez drugiego argumentu sprawdzamy, czy wejście jest poprawnym
      obiektem JSON albo tablicą JSON
    -------------------------------------------------------------------
*/

DECLARE @JsonObject nvarchar(max) = N'{"OrderID": 43672, "Status": 5}'
DECLARE @JsonArray  nvarchar(max) = N'[1,2,3]'
DECLARE @NotJson    nvarchar(max) = N'OrderID=43672'
DECLARE @NullValue  nvarchar(max) = NULL

SELECT 
    ISJSON(@JsonObject) AS JsonObject,
    ISJSON(@JsonArray)  AS JsonArray,
    ISJSON(@NotJson)    AS NotJson,
    ISJSON(@NullValue)  AS NullValue
GO






/*
    -------------------------------------------------------------------
    2. ISJSON i json_type_constraint
    - sprawdzenie poprawności JSON
    - sprawdzenie, czy JSON jest obiektem, tablicą, wartością albo scalarem
    - VALUE i SCALAR to subtelna, ale ważna różnica
       - VALUE dowolna poprawna wartość JSON
       - SCALAR tylko liczba albo string JSON
    -------------------------------------------------------------------
*/

DECLARE @SampleJSON nvarchar(max) = 
(
    SELECT OrderDoc
    FROM DemoJson.OrderDocs_Text
    WHERE OrderID = 43672
)

SELECT @SampleJSON

-- realny dokument z tabeli
-- to jest poprawny JSON i jednocześnie obiekt JSON
SELECT 
    ISJSON(@SampleJSON)         AS IsValidJson_Default,
    ISJSON(@SampleJSON, OBJECT) AS IsValidJson_Object,
    ISJSON(@SampleJSON, ARRAY)  AS IsValidJson_Array,
    ISJSON(@SampleJSON, VALUE)  AS IsValidJson_Value,
    ISJSON(@SampleJSON, SCALAR) AS IsValidJson_Scalar
GO


-- porównanie VALUE i SCALAR
-- VALUE = dowolna poprawna wartość JSON
-- SCALAR = tylko string albo number
SELECT
    ISJSON(N'{"a":1}', VALUE)   AS Object_AsValue,
    ISJSON(N'[1,2,3]', VALUE)   AS Array_AsValue,
    ISJSON(N'"hello"', VALUE)   AS String_AsValue,
    ISJSON(N'123.45', VALUE)    AS Number_AsValue,
    ISJSON(N'true', VALUE)      AS True_AsValue,
    ISJSON(N'null', VALUE)      AS Null_AsValue

SELECT
    ISJSON(N'{"a":1}', SCALAR)  AS Object_AsScalar,
    ISJSON(N'[1,2,3]', SCALAR)  AS Array_AsScalar,
    ISJSON(N'"hello"', SCALAR)  AS String_AsScalar,
    ISJSON(N'123.45', SCALAR)   AS Number_AsScalar,
    ISJSON(N'true', SCALAR)     AS True_AsScalar,
    ISJSON(N'null', SCALAR)     AS Null_AsScalar
GO


-- ważna różnica:
-- bez drugiego argumentu ISJSON domyślnie sprawdza tylko obiekt albo tablicę
SELECT
    ISJSON(N'"tekst"')         AS Default_String,
    ISJSON(N'123.45')          AS Default_Number,
    ISJSON(N'true')            AS Default_True,
    ISJSON(N'null')            AS Default_Null,

    ISJSON(N'"tekst"', VALUE)  AS Value_String,
    ISJSON(N'"tekst"', SCALAR) AS Scalar_String
GO


/*
    -------------------------------------------------------------------
    3. ISJSON z tabeli
    - walidacja dokumentów zapisanych w kolumnie
    - naturalny wzorzec: filtruję tylko poprawne JSON-y
    -------------------------------------------------------------------
*/

SELECT TOP (20)
    OrderID,
    ISJSON(OrderDoc) AS IsValidJson
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID
GO


-- tylko poprawne dokumenty JSON
SELECT TOP (20)
    OrderID,
    OrderDoc
FROM DemoJson.OrderDocs_Text
WHERE ISJSON(OrderDoc) = 1
ORDER BY OrderID
GO

SELECT ISJSON(OrderDoc), count(*)
FROM DemoJson.OrderDocs_Text
GROUP BY ISJSON(OrderDoc)
GO


/*
    -------------------------------------------------------------------
    4. Praktyczne użycie ISJSON
    - walidacja przed JSON_VALUE / JSON_QUERY / OPENJSON
    - szczególnie przydaje się, gdy dane przychodzą z zewnątrz
    -------------------------------------------------------------------
*/

-- 4A. Najpierw walidacja, potem odczyt wartości
SELECT TOP (20)
    OrderID,
    JSON_VALUE(OrderDoc, '$.OrderDate') AS OrderDate,
    JSON_VALUE(OrderDoc, '$.Status')    AS Status
FROM DemoJson.OrderDocs_Text
WHERE ISJSON(OrderDoc) = 1
ORDER BY OrderID;
GO


-- 4B. Najpierw walidacja, potem odczyt fragmentu JSON
SELECT TOP (20)
    OrderID,
    JSON_QUERY(OrderDoc, '$.Items') AS Items
FROM DemoJson.OrderDocs_Text
WHERE ISJSON(OrderDoc) = 1
ORDER BY OrderID;
GO


-- 4C. Najpierw walidacja, potem rozbicie tablicy na wiersze
SELECT TOP (20)
    t.OrderID,
    i.ProductID,
    i.Name,
    i.OrderQty
FROM DemoJson.OrderDocs_Text AS t
CROSS APPLY OPENJSON(t.OrderDoc, '$.Items')
WITH
(
    ProductID int           '$.ProductID',
    Name      nvarchar(200) '$.Name',
    OrderQty  int           '$.OrderQty'
) AS i
WHERE ISJSON(t.OrderDoc) = 1
ORDER BY t.OrderID;
GO


/*
    -------------------------------------------------------------------
    5. Ograniczenie: ISJSON nie sprawdza semantyki dokumentu
    - JSON może być składniowo poprawny,
      ale nadal nie mieć oczekiwanych właściwości
    -------------------------------------------------------------------
*/

-- ISJSON sprawdza poprawność składni JSON,
-- ale nie sprawdza, czy dokument ma wymagane pola,
-- właściwe typy danych i oczekiwany sens biznesowy.

DECLARE @JsonMissingFields nvarchar(max) = N'{"SomethingElse":123}'
DECLARE @JsonDuplicateKeys nvarchar(max) = N'{"OrderID":1,"OrderID":2}'
DECLARE @JsonWrongType     nvarchar(max) = N'{"OrderID":"ABC"}'

SELECT
    ISJSON(@JsonMissingFields) AS MissingFields_IsJson,
    JSON_VALUE(@JsonMissingFields, '$.OrderID') AS MissingFields_OrderID


SELECT
    ISJSON(@JsonDuplicateKeys) AS DuplicateKeys_IsJson


SELECT
    ISJSON(@JsonWrongType) AS WrongType_IsJson,
    TRY_CAST(JSON_VALUE(@JsonWrongType, '$.OrderID') AS int) AS WrongType_OrderID_AsInt
GO



