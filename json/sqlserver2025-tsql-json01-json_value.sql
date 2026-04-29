/*
	TSQL: JSON_VALUE 
	Tomasz Lbera | MVP Data Platform
	libera@kursysql.pl
	
    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL

    Funkcja JSON_VALUE 
    zwraca wartość skalarna (string, number, boolean) z dokumentu JSON


    Składnia*:
    JSON_VALUE ( expression , path [ RETURNING data_type ] )

    * RETURNING od SQL Server 2025
    
    Dokumentacja:
    https://learn.microsoft.com/en-us/sql/t-sql/functions/json-value-transact-sql?view=sql-server-ver17

    1. JSON_VALUE z pojedynczego dokumentu JSON
    2. JSON_VALUE z tabeli
    3. Filtrowanie i sortowanie po scalarach z JSON
    4. Przypisywanie wyniku JSON_VALUE do zmiennej skalarnej
    5. lax / strict
    6. Array wildcard and range support w JSON path | SQL Server 2025
    7. RETURNING | SQL Server 2025
    8. JSON_VALUE a JSON_QUERY

*/




/*
    -------------------------------------------------------------------
    1. JSON_VALUE z pojedynczego dokumentu JSON
    - zacznijmy od prostego przykładu
    - JSON_VALUE zwraca jedną wartość skalarną
    - można wejść w zagnieżdżone obiekty i w konkretny element tablicy
    -------------------------------------------------------------------
*/



DECLARE @SampleJSON nvarchar(max) = (SELECT OrderDoc FROM DemoJson.OrderDocs_Text WHERE OrderID = 43672);
SELECT @SampleJSON


-- scalar z pierwszego poziomu
SELECT JSON_VALUE(@SampleJSON, '$.OrderID') AS OrderID
GO



DECLARE @SampleJSON nvarchar(max) = (SELECT OrderDoc FROM DemoJson.OrderDocs_Text WHERE OrderID = 43672)

-- kilka elementów z pierwszego poziomu
SELECT 
    JSON_VALUE(@SampleJSON, '$.OrderID') AS OrderID,
    JSON_VALUE(@SampleJSON, '$.OrderDate') AS OrderDate,
    JSON_VALUE(@SampleJSON, '$.Status') AS Status
GO



DECLARE @SampleJSON nvarchar(max) = (SELECT OrderDoc FROM DemoJson.OrderDocs_Text WHERE OrderID = 43672)
-- próby (nieudane) zejścia do zagnieżdżonych obiektów ProductID, Name i tablicy Items
SELECT 
    JSON_VALUE(@SampleJSON, '$.OrderID') AS OrderID,
    JSON_VALUE(@SampleJSON, '$.OrderDate') AS OrderDate,
    JSON_VALUE(@SampleJSON, '$.Status') AS Status,
    JSON_VALUE(@SampleJSON, '$.Items') AS Items,
    JSON_VALUE(@SampleJSON, '$.Items.ProductID') AS ProductID,
    JSON_VALUE(@SampleJSON, '$.Items.Name') AS Name
GO


DECLARE @SampleJSON nvarchar(max) = (SELECT OrderDoc FROM DemoJson.OrderDocs_Text WHERE OrderID = 43672)
-- zejście do konkretnego elementu tablicy (pierwszego)
SELECT 
    JSON_VALUE(@SampleJSON, '$.OrderID') AS OrderID,
    JSON_VALUE(@SampleJSON, '$.OrderDate') AS OrderDate,
    JSON_VALUE(@SampleJSON, '$.Status') AS Status,
    JSON_VALUE(@SampleJSON, '$.Items[0].SalesOrderDetailID') AS SalesOrderDetailID,
    JSON_VALUE(@SampleJSON, '$.Items[0].ProductID') AS ProductID,
    JSON_VALUE(@SampleJSON, '$.Items[0].Name') AS Name,
    JSON_VALUE(@SampleJSON, '$.Items[0].UnitPrice') AS UnitPrice
GO

DECLARE @SampleJSON nvarchar(max) = (SELECT OrderDoc FROM DemoJson.OrderDocs_Text WHERE OrderID = 43672)
-- zejście do DRUGIEGO elementu tablicy
SELECT 
    JSON_VALUE(@SampleJSON, '$.OrderID') AS OrderID,
    JSON_VALUE(@SampleJSON, '$.OrderDate') AS OrderDate,
    JSON_VALUE(@SampleJSON, '$.Status') AS Status,
    JSON_VALUE(@SampleJSON, '$.Items[1].SalesOrderDetailID') AS SalesOrderDetailID,
    JSON_VALUE(@SampleJSON, '$.Items[1].ProductID') AS ProductID,
    JSON_VALUE(@SampleJSON, '$.Items[1].Name') AS Name,
    JSON_VALUE(@SampleJSON, '$.Items[1].UnitPrice') AS UnitPrice




/*
    -------------------------------------------------------------------
    2. JSON_VALUE z tabeli
    - odczyt pojedynczych wartości z dokumentu JSON
    - bez rozbijania tablicy na wiersze
    -------------------------------------------------------------------
*/

SELECT *
FROM DemoJson.OrderDocs_Text
WHERE OrderID = 43672;
GO


-- skalary z dokumentu JSON zapisanego w kolumnie OrderDoc
SELECT 
    OrderID,
    JSON_VALUE(OrderDoc, '$.OrderDate') AS OrderDate,
    JSON_VALUE(OrderDoc, '$.Status') AS Status,
    JSON_VALUE(OrderDoc, '$.Items[0].SalesOrderDetailID') AS SalesOrderDetailID,
    JSON_VALUE(OrderDoc, '$.Items[0].ProductID') AS ProductID,
    JSON_VALUE(OrderDoc, '$.Items[0].Name') AS Name,
    JSON_VALUE(OrderDoc, '$.Items[0].UnitPrice') AS UnitPrice
FROM DemoJson.OrderDocs_Text
WHERE OrderID = 43672


-- skalary z całej tabeli (nie tylko dla jednego OrderID)
SELECT TOP 100 
    OrderID,
    JSON_VALUE(OrderDoc, '$.OrderDate') AS OrderDate,
    JSON_VALUE(OrderDoc, '$.Status') AS Status,
    JSON_VALUE(OrderDoc, '$.Items[0].SalesOrderDetailID') AS SalesOrderDetailID,
    JSON_VALUE(OrderDoc, '$.Items[0].ProductID') AS ProductID,
    JSON_VALUE(OrderDoc, '$.Items[0].Name') AS Name,
    JSON_VALUE(OrderDoc, '$.Items[0].UnitPrice') AS UnitPrice
FROM DemoJson.OrderDocs_Text




/*
    -------------------------------------------------------------------
    3. Filtrowanie i sortowanie po scalarach z JSON
    -------------------------------------------------------------------
*/


-- filtrowanie po scalarze z dokumentu JSON
SELECT
    OrderID,
    JSON_VALUE(OrderDoc, '$.OrderDate') AS OrderDate,
    JSON_VALUE(OrderDoc, '$.Status') AS Status,
    JSON_VALUE(OrderDoc, '$.OrderDate') AS OrderDate,
    JSON_VALUE(OrderDoc, '$.Items[0].SalesOrderDetailID') AS SalesOrderDetailID,
    JSON_VALUE(OrderDoc, '$.Items[0].ProductID') AS ProductID,
    JSON_VALUE(OrderDoc, '$.Items[0].Name') AS Name,
    JSON_VALUE(OrderDoc, '$.Items[0].UnitPrice') AS UnitPrice
FROM DemoJson.OrderDocs_Text
WHERE JSON_VALUE(OrderDoc, '$.OrderDate') = '2022-05-30T00:00:00'
ORDER BY OrderID;
GO



-- sortowanie po wartości scalar z JSON
SELECT 
    OrderID,
    JSON_VALUE(OrderDoc, '$.OrderDate') AS OrderDate,
    JSON_VALUE(OrderDoc, '$.Status') AS Status,
    JSON_VALUE(OrderDoc, '$.OrderDate') AS OrderDate
FROM DemoJson.OrderDocs_Text
ORDER BY JSON_VALUE(OrderDoc, '$.OrderDate');
GO





/*
    -------------------------------------------------------------------
    4. Przypisywanie wyniku JSON_VALUE do zmiennej skalarnej
    -------------------------------------------------------------------
*/


DECLARE @ProductName nvarchar(50)

SELECT @ProductName = JSON_VALUE(OrderDoc, '$.Items[0].Name')  
FROM DemoJson.OrderDocs_Text
WHERE OrderID = 43672

SELECT @ProductName

GO





/*
    -------------------------------------------------------------------
    5. lax / strict
    - domyślnie ścieżki działają w trybie lax
    - strict przydaje się, gdy:
      - chcesz wykryć błędy (walidacja)
      - chcesz wymusić obecność właściwości
      - chcesz obsłużyć błąd TRY_CATCH
    -------------------------------------------------------------------
*/

-- brakująca ścieżka - lax zwraca NULL (zachowanie domyślne)
SELECT 
    OrderID,
    JSON_VALUE(OrderDoc, '$.OrderDate') AS OrderDate,
    JSON_VALUE(OrderDoc, '$.Status') AS Status,
    JSON_VALUE(OrderDoc, 'lax $.Items[0].SalesOrderDetail_ID') AS SalesOrderDetailID
FROM DemoJson.OrderDocs_Text
WHERE OrderID = 43672



-- brakująca ścieżka - strict rzuca błąd
SELECT 
    OrderID,
    JSON_VALUE(OrderDoc, '$.OrderDate') AS OrderDate,
    JSON_VALUE(OrderDoc, '$.Status') AS Status,
    JSON_VALUE(OrderDoc, 'strict $.Items[0].SalesOrderDetail_ID') AS SalesOrderDetailID
FROM DemoJson.OrderDocs_Text
WHERE OrderID = 43672




-- nieistniejący element listy - strict rzuca błąd
SELECT 
    OrderID,
    JSON_VALUE(OrderDoc, '$.OrderDate') AS OrderDate,
    JSON_VALUE(OrderDoc, '$.Status') AS Status,
    JSON_VALUE(OrderDoc, 'lax $.Items[99].SalesOrderDetailID') AS SalesOrderDetailID
FROM DemoJson.OrderDocs_Text
WHERE OrderID = 43672


SELECT 
    OrderID,
    JSON_VALUE(OrderDoc, '$.OrderDate') AS OrderDate,
    JSON_VALUE(OrderDoc, '$.Status') AS Status,
    JSON_VALUE(OrderDoc, 'strict $.Items[99].SalesOrderDetailID') AS SalesOrderDetailID
FROM DemoJson.OrderDocs_Text
WHERE OrderID = 43672





-- ścieżka wskazuje tablicę, a nie scalar
-- w lax będzie NULL, strict będzie błąd
SELECT 
    OrderID,
    JSON_VALUE(OrderDoc, '$.OrderDate') AS OrderDate,
    JSON_VALUE(OrderDoc, '$.Status') AS Status,
    JSON_VALUE(OrderDoc, 'lax $.Items') AS Items
FROM DemoJson.OrderDocs_Text
WHERE OrderID = 43672

SELECT 
    OrderID,
    JSON_VALUE(OrderDoc, '$.OrderDate') AS OrderDate,
    JSON_VALUE(OrderDoc, '$.Status') AS Status,
    JSON_VALUE(OrderDoc, 'strict $.Items') AS Items
FROM DemoJson.OrderDocs_Text
WHERE OrderID = 43672




/*
    -------------------------------------------------------------------
    6. Array wildcard and range support w JSON path | SQL Server 2025 (Preview)  
    - działa dla wejścia typu json
    - w JSON_VALUE ma sens tylko wtedy, gdy kończymy na jednym scalarze
    -------------------------------------------------------------------
*/


DECLARE @SampleJSON JSON = (SELECT OrderDoc FROM DemoJson.OrderDocs_Text WHERE OrderID = 43672);
SELECT @SampleJSON

SELECT -- klasyczne odwołanie do konkretnego elementu tablicy
    JSON_VALUE(@SampleJSON, '$.Items[0].Name') AS Name_0,
    JSON_VALUE(@SampleJSON, '$.Items[1].Name') AS Name_1,
    JSON_VALUE(@SampleJSON, '$.Items[2].Name') AS Name_2

-- odwołanie do ostatniego elementu tablicy za pomocą wildcard
SELECT JSON_VALUE(@SampleJSON, '$.Items[last].Name') AS Name_Last

-- odwołanie do wszystkich elementów tablicy za pomocą wildcard - zwróci NULL, 
-- bo JSON_VALUE zwraca tylko jeden scalar
SELECT JSON_VALUE(@SampleJSON, '$.Items[*].Name') AS Name_All

-- odwołanie do zakresu elementów tablicy - zwróci NULL, 
-- bo JSON_VALUE zwraca tylko jeden scalar
SELECT JSON_VALUE(@SampleJSON, '$.Items[0 to 1].Name') AS Name_Range



-- Uwaga:
-- wildcard i range w ścieżce JSON są dużo bardziej naturalne dla JSON_QUERY,
-- bo JSON_QUERY zwraca obiekt albo tablicę.
-- JSON_VALUE zwraca scalar, więc przy wielu trafieniach kończy się to NULL-em albo błędem.




/*
    -------------------------------------------------------------------
    7. RETURNING | SQL Server 2025
    - JSON_VALUE zwraca string (nvarchar(4000), ale można użyć RETURNING, by zwrócić inny typ danych
    - obsługiwane typy danych: date, time, datetime2, datetimeoffset, decimal/ numeric, money, smallmoney    
    - jeśli potrzebujesz więcej niż 4000 znaków, musisz użyć:
        - OPENJSON 
        - lub RETURNING i wskazać typ nvarchar(max)
    -------------------------------------------------------------------
*/

-- błąd bo RETURNING w JSON_VALUE działa TYLKO 
-- z natywnym typem danych JSON wprowadzonym w SQL Server 2025, nie z NVARCHAR(MAX)
SELECT 
    OrderID,
    JSON_VALUE(OrderDoc, '$.OrderDate') AS OrderDate_DefaultString,
    JSON_VALUE(OrderDoc, '$.OrderDate' RETURNING date) AS OrderDate_Datetime
FROM DemoJson.OrderDocs_Text
WHERE OrderID = 43672


SELECT 
    OrderID,
    JSON_VALUE(OrderDoc, '$.OrderDate') AS OrderDate_DefaultString,
    JSON_VALUE(OrderDoc, '$.OrderDate' RETURNING date) AS OrderDate_Datetime
FROM DemoJson.OrderDocs_Json
WHERE OrderID = 43672


-- błąd bo datetime nie jest obsługiwany 
SELECT 
    OrderID,
    JSON_VALUE(OrderDoc, '$.OrderDate') AS OrderDate_DefaultString,
    JSON_VALUE(OrderDoc, '$.OrderDate' RETURNING datetime) AS OrderDate_Datetime
FROM DemoJson.OrderDocs_Json
WHERE OrderID = 43672





/*
    -------------------------------------------------------------------
    8. JSON_VALUE a JSON_QUERY
    - JSON_VALUE działa tylko dla scalarów
    - gdy ścieżka wskazuje tablicę lub obiekt, trzeba użyć JSON_QUERY
    -------------------------------------------------------------------
*/


SELECT 
    OrderID,
    JSON_VALUE(OrderDoc, '$.OrderDate') AS OrderDate,
    JSON_VALUE(OrderDoc, '$.Status') AS Status,
    -- NULL, bo Items to tablica, a JSON_VALUE zwraca tylko scalary
    JSON_VALUE(OrderDoc, '$.Items') AS Items_JSON_VALUE, 
    -- JSON_QUERY zwróci tablicę, bo Items to tablica
    JSON_QUERY(OrderDoc, '$.Items') AS Items_JSON_QUERY
FROM DemoJson.OrderDocs_Text
WHERE OrderID = 43672



