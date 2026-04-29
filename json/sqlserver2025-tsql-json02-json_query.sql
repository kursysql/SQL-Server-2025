/*

	TSQL: JSON_QUERY 
	Tomasz Lbera | MVP Data Platform
	libera@kursysql.pl
	
    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL

    Funkcja JSON_QUERY 
    zwraca fragment JSON (obiekt lub tablica) z dokumentu JSON


    Składnia*:
    JSON_QUERY ( expression [ , path ] [ WITH ARRAY WRAPPER ] )

    * WITH ARRAY WRAPPER od SQL Server 2025
    
    Dokumentacja:
    https://learn.microsoft.com/en-us/sql/t-sql/functions/json-query-transact-sql?view=sql-server-ver17

    1. JSON_VALUE z pojedynczego dokumentu JSON
    2. JSON_QUERY z tabeli    
    3. lax / strict
    4. Array wildcard and range support + WITH ARRAY WRAPPER | SQL Server 2025 (Preview)
    5. JSON_QUERY + FOR JSON


*/




USE AdventureWorks2025
GO



/*
    -------------------------------------------------------------------
    1. Zacznijmy od prostego przykładu
    - JSON_QUERY zwraca obiekt albo tablicę
    - nie zwraca scalarów
    -------------------------------------------------------------------
*/



DECLARE @SampleJSON nvarchar(max) = (SELECT OrderDoc FROM DemoJson.OrderDocs_Text WHERE OrderID = 43672);
SELECT @SampleJSON

-- cały dokument
SELECT JSON_QUERY(@SampleJSON) AS SampleJson

-- obiekt
SELECT JSON_QUERY(@SampleJSON, '$.Customer') AS CustomerObject

-- nie jest obiektem, tylko scalar - w lax dostaniemy NULL, w strict błąd
SELECT JSON_QUERY(@SampleJSON, '$.Customer.CustomerID') AS CustomerObject

-- tablica
SELECT JSON_QUERY(@SampleJSON, '$.Items') AS ItemsArray

-- pojedynczy element tablicy - nadal działa, bo element jest obiektem
SELECT JSON_QUERY(@SampleJSON, '$.Items[0]') AS FirstItemObject
GO



/*
    -------------------------------------------------------------------
    2. JSON_QUERY z tabeli
    - odczyt fragmentów dokumentu JSON
    - obiekty i tablice zamiast pojedynczych scalarów
    -------------------------------------------------------------------
*/


SELECT *
FROM DemoJson.OrderDocs_Text
WHERE OrderID = 43672;
GO


-- skalary z dokumentu JSON zapisanego w kolumnie OrderDoc
-- przy użyciu JSON_QUERY dostaniemy NULL, bo ścieżka wskazuje scalar, a nie obiekt/tablicę
-- (skopiowany z przykładu JSON_VALUE)
SELECT 
    OrderID,
    JSON_QUERY(OrderDoc, '$.OrderDate') AS OrderDate,
    JSON_QUERY(OrderDoc, '$.Status') AS Status,
    JSON_QUERY(OrderDoc, '$.Items[0].SalesOrderDetailID') AS SalesOrderDetailID,
    JSON_QUERY(OrderDoc, '$.Items[0].ProductID') AS ProductID,
    JSON_QUERY(OrderDoc, '$.Items[0].Name') AS Name,
    JSON_QUERY(OrderDoc, '$.Items[0].UnitPrice') AS UnitPrice
FROM DemoJson.OrderDocs_Text
WHERE OrderID = 43672

-- skalary z dokumentu JSON zapisanego w kolumnie OrderDoc
SELECT 
    OrderID,
    JSON_QUERY(OrderDoc, '$.Customer') AS Customer,
    JSON_QUERY(OrderDoc, '$.Shipping') AS Shipping,
    JSON_QUERY(OrderDoc, '$.Totals') AS Totals,
    JSON_QUERY(OrderDoc, '$.Items') AS Items,
    JSON_QUERY(OrderDoc, '$.Items[0]') AS Items_0,
    JSON_QUERY(OrderDoc, '$.Items[1]') AS Items_1
FROM DemoJson.OrderDocs_Text
WHERE OrderID = 43672








/*
    -------------------------------------------------------------------
    3. lax / strict
    - domyślnie ścieżki działają w trybie lax
    - strict przydaje się, gdy chcę wymusić obiekt albo tablicę
    -------------------------------------------------------------------
*/



-- A/ ścieżka wskazuje scalar, a nie obiekt/tablicę
-- w lax będzie NULL, strict będzie błąd
SELECT 
    OrderID,
    JSON_QUERY(OrderDoc, 'lax $.OrderDate') AS OrderDate,
    JSON_QUERY(OrderDoc, '$.Items') AS Items
FROM DemoJson.OrderDocs_Text
WHERE OrderID = 43672

SELECT 
    OrderID,
    JSON_QUERY(OrderDoc, 'strict $.OrderDate') AS OrderDate,
    JSON_QUERY(OrderDoc, '$.Items') AS Items
FROM DemoJson.OrderDocs_Text
WHERE OrderID = 43672



-- B/ ścieżka wskazuje nieistniejący element
-- w lax będzie NULL, strict będzie błąd
SELECT 
    OrderID,
    JSON_QUERY(OrderDoc, '$.Customer') AS Customer,
    JSON_QUERY(OrderDoc, 'lax $.Item') AS Items, -- !!!!
    JSON_QUERY(OrderDoc, '$.Items[0]') AS Items_0,
    JSON_QUERY(OrderDoc, '$.Items[1]') AS Items_1
FROM DemoJson.OrderDocs_Text
WHERE OrderID = 43672

SELECT 
    OrderID,
    JSON_QUERY(OrderDoc, '$.Customer') AS Customer,
    JSON_QUERY(OrderDoc, 'strict $.Item') AS Items, 
    JSON_QUERY(OrderDoc, '$.Items[0]') AS Items_0,
    JSON_QUERY(OrderDoc, '$.Items[1]') AS Items_1
FROM DemoJson.OrderDocs_Text
WHERE OrderID = 43672



-- C/ ścieżka wskazuje element tablicy, który nie istnieje
-- w lax będzie NULL, strict będzie błąd
SELECT 
    OrderID,
    JSON_QUERY(OrderDoc, '$.Customer') AS Customer,
    JSON_QUERY(OrderDoc, '$.Items') AS Items,
    JSON_QUERY(OrderDoc, '$.Items[0]') AS Items_0,
    JSON_QUERY(OrderDoc, 'lax $.Items[99]') AS Items_99
FROM DemoJson.OrderDocs_Text
WHERE OrderID = 43672

SELECT 
    OrderID,
    JSON_QUERY(OrderDoc, '$.Customer') AS Customer,
    JSON_QUERY(OrderDoc, '$.Items') AS Items,
    JSON_QUERY(OrderDoc, '$.Items[0]') AS Items_0,
    JSON_QUERY(OrderDoc, 'strict $.Items[99]') AS Items_99
FROM DemoJson.OrderDocs_Text
WHERE OrderID = 43672




/*
    -------------------------------------------------------------------
    4. Array wildcard and range support + WITH ARRAY WRAPPER | SQL Server 2025 (Preview)
    - działa dla wejścia typu json
    - przy wildcard / range / list używamy WITH ARRAY WRAPPER
    -------------------------------------------------------------------
*/



SELECT *
FROM DemoJson.OrderDocs_JSON
WHERE OrderID = 43672


-- JSON_VALUE: odwołanie do ostatniego elementu tablicy za pomocą wildcard
-- na wejściu musi być typ JSON
SELECT 
    JSON_VALUE(OrderDoc, '$.Items[last].Name')
FROM DemoJson.OrderDocs_JSON
WHERE OrderID = 43672

-- JSON_VALUE: odwołanie do pierwszego elementu tablicy za pomocą wildcard
SELECT 
    JSON_VALUE(OrderDoc, '$.Items[0].Name')
FROM DemoJson.OrderDocs_JSON
WHERE OrderID = 43672

-- JSON_QUERY: opakowuje scalar w tablicę JSON
-- "tekst" -> ["tekst"]
SELECT 
    JSON_QUERY(OrderDoc, '$.Items[0].Name' WITH ARRAY WRAPPER) AS Name_Range
FROM DemoJson.OrderDocs_JSON
WHERE OrderID = 43672

-- tu nie ma potrzeby stosowania WITH ARRAY WRAPPER, bo zwracamy tablicę, a nie scalar
-- nie musi nic "opakowywać"
SELECT 
    JSON_QUERY(OrderDoc, '$.Items') AS Name_Range
FROM DemoJson.OrderDocs_JSON
WHERE OrderID = 43672


-- JSON_QUERY: odwołanie do zakresu elementów tablicy
SELECT 
    JSON_QUERY(OrderDoc, '$.Items[0 to 1].Name' WITH ARRAY WRAPPER) AS Name_Range
FROM DemoJson.OrderDocs_JSON
WHERE OrderID = 43672

SELECT 
    JSON_QUERY(OrderDoc, '$.Items[0 to 2].Name' WITH ARRAY WRAPPER) AS Name_Range
FROM DemoJson.OrderDocs_JSON
WHERE OrderID = 43672

-- wszystkie elementy tablicy za pomocą wildcard
SELECT 
    JSON_QUERY(OrderDoc, '$.Items[*].Name' WITH ARRAY WRAPPER) AS Name_Range
FROM DemoJson.OrderDocs_JSON
WHERE OrderID = 43672





/*
    -------------------------------------------------------------------
    5. JSON_QUERY + FOR JSON
    - przydaje się, gdy składamy JSON w wyniku i nie chcemy escape'owania
    -------------------------------------------------------------------
*/


SELECT *
FROM Sales.SalesOrderHeader
WHERE SalesOrderID = 43672

SELECT *
FROM Sales.SalesOrderHeader
WHERE SalesOrderID = 43672
FOR JSON PATH



SELECT TOP (3)
    OrderID,
    OrderDoc
FROM DemoJson.OrderDocs_Text
FOR JSON PATH
GO


SELECT TOP (3)
    OrderID,
    JSON_QUERY(OrderDoc, '$.Items') AS Items
FROM DemoJson.OrderDocs_Text
FOR JSON PATH
GO


