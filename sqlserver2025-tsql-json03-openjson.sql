/*

	TSQL: OPENJSON 
	Tomasz Lbera | MVP Data Platform
	libera@kursysql.pl
	
    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL

    Funkcja OPENJSON
    zwraca wiersze z dokumentu JSON, rozbijając tablice JSON na wiersze 
    i mapując pola z dokumentu JSON na kolumny w wyniku


    Składnia:
    OPENJSON( jsonExpression [ , path ] )  [ <with_clause> ]
    <with_clause> ::= WITH ( { colName type [ column_path ] [ AS JSON ] } [ ,...n ] )
    
    Dokumentacja:
    https://learn.microsoft.com/en-us/sql/t-sql/functions/openjson-transact-sql?view=sql-server-ver17

    1. Zacznijmy od prostego przykładu
    2. OPENJSON z tabelą
    3. OPENJSON + CROSS APPLY 
    4. Praktyczne użycie OPENJSON
    5. lax / strict
    6. Alternatywa: PIVOT (niezalecana)

*/



/*
    -------------------------------------------------------------------
    1. Zacznijmy od prostego przykładu
    - kolumny które zwraca OPENJSON to: key, value, type
    - użycie ścieżki (path) do wejścia w konkretną część dokumentu JSON
    -------------------------------------------------------------------
*/

DECLARE @SampleJSON nvarchar(max) = N'
{
  "OrderID": 43659,
  "OrderDate": "2022-05-30T00:00:00",
  "Status": 5,
  "OnlineOrder": false
}
'

SELECT @SampleJSON  

SELECT * FROM OPENJSON(@SampleJSON)

/*
	OPENJSON zwraca 3 kolumny, a w type:

    0 - NULL
	1 - String
	2 - Number
	3 - Boolean
	4 - Array
	5 - Object

*/






-- wybierzmy zamówienia z 3 pozycjami do dalszych testów...
SELECT SalesOrderID, count(*) FROM Sales.SalesOrderDetail 
GROUP BY SalesOrderID
HAVING count(*)= 3
GO


-- OrderDocs_Text.OrderDoc to jest kolumna typu nvarchar(max), która zawiera dokument JSON jako tekst.
DECLARE @SampleJSON nvarchar(max) = (SELECT OrderDoc FROM DemoJson.OrderDocs_Text WHERE OrderID = 43672);
SELECT @SampleJSON

SELECT *
FROM OPENJSON(@SampleJSON)
GO

-- OrderDocs_Json.OrderDoc to jest kolumna typu json, która zawiera dokument JSON w natywnym formacie JSON.
--Msg 257, Level 16, State 3, Line 97
--Implicit conversion from data type json to nvarchar(max) is not allowed. Use the CONVERT function to run this query.
DECLARE @SampleJSON nvarchar(max) = (SELECT OrderDoc FROM DemoJson.OrderDocs_Json WHERE OrderID = 43672);
SELECT @SampleJSON

SELECT *
FROM OPENJSON(@SampleJSON)
GO


DECLARE @SampleJSON nvarchar(max) = (SELECT OrderDoc FROM DemoJson.OrderDocs_Text WHERE OrderID = 43672);
SELECT @SampleJSON

-- path
-- wejście w konkretną ścieżkę Items dla każdego elementu tablicy, 
-- czyli dla każdego produktu w zamówieniu
SELECT *
FROM OPENJSON(@SampleJSON, '$.Items')
GO





/*
    -------------------------------------------------------------------
    2. OPENJSON
    - odczyt wielu wierszy z tabeli
    - with - mapowanie pól z dokumentu JSON na kolumny w wyniku
    -------------------------------------------------------------------
*/




-- nasz testowy przypadek
SELECT *
FROM DemoJson.OrderDocs_Text
WHERE OrderID = 43672

/*
  "Items": [
    {
      "SalesOrderDetailID": 126,
      "ProductID": 709,
      "ProductNumber": "SO-B909-M",
      "Name": "Mountain Bike Socks, M",
      "OrderQty": 6,
      "UnitPrice": 5.7000,
      "LineTotal": 34.200000
    },
    {
      "SalesOrderDetailID": 127,
      "ProductID": 776,
      "ProductNumber": "BK-M82B-42",
      "Name": "Mountain-100 Black, 42",
      "OrderQty": 2,
      "UnitPrice": 2024.9940,
      "LineTotal": 4049.988000
    },
    {
      "SalesOrderDetailID": 128,
      "ProductID": 774,
      "ProductNumber": "BK-M82S-48",
      "Name": "Mountain-100 Silver, 48",
      "OrderQty": 1,
      "UnitPrice": 2039.9940,
      "LineTotal": 2039.994000
    }
  ],
*/




-- na podstawie tego dokumentu JSON chciałbym wyciągnąć wszystkie produkty, 
-- które są w zamówieniu 43672
-- Items to jest TABLICA OBIEKTÓW, więc muszę użyć OPENJSON, żeby rozbić ją na wiersze.

DECLARE @SampleJSON nvarchar(max) = (SELECT OrderDoc FROM DemoJson.OrderDocs_Text WHERE OrderID = 43672);
SELECT @SampleJSON
SELECT * FROM OPENJSON(@SampleJSON, '$.Items')
GO


-- with - mapowanie pól z dokumentu JSON na kolumny w wyniku

-- dopasowanie nazw kolumn do ścieżek w JSON
DECLARE @SampleJSON nvarchar(max) = (SELECT OrderDoc FROM DemoJson.OrderDocs_Text WHERE OrderID = 43672);

SELECT *
FROM OPENJSON(@SampleJSON, '$.Items')
WITH
(
    SalesOrderDetailID INT,
    ProductID INT,
    Name NVARCHAR(100), 
    OrderQty INT,
    UnitPrice MONEY
)
GO


-- dopasowanie nazw kolumn do ścieżek w JSON (bardziej precyzyjne)
DECLARE @SampleJSON nvarchar(max) = (SELECT OrderDoc FROM DemoJson.OrderDocs_Text WHERE OrderID = 43672);

SELECT *
FROM OPENJSON(@SampleJSON, '$.Items')
WITH
(
    SalesOrderDetailID int           '$.SalesOrderDetailID',
    ProductID          int           '$.ProductID',
    Name               nvarchar(200) '$.Name',
    OrderQty           int           '$.OrderQty',
    UnitPrice          money         '$.UnitPrice'
)
GO


-- uwaga - case sensitive
DECLARE @SampleJSON nvarchar(max) = (SELECT OrderDoc FROM DemoJson.OrderDocs_Text WHERE OrderID = 43672);

SELECT *
FROM OPENJSON(@SampleJSON, '$.Items')
WITH
(
    salesOrderDetailid INT,
    ProductID INT,
    Name NVARCHAR(100), 
    OrderQty INT,
    UnitPrice MONEY
)
GO


-- dzięki takiemu mapowaniu możemy zmianiać nazwy kolumn
DECLARE @SampleJSON nvarchar(max) = (SELECT OrderDoc FROM DemoJson.OrderDocs_Text WHERE OrderID = 43672);

SELECT *
FROM OPENJSON(@SampleJSON, '$.Items')
WITH
(
    salesOrdID      int           '$.SalesOrderDetailID',
    productID       int           '$.ProductID',
    prodname        nvarchar(200) '$.Name',
    orderqty        int           '$.OrderQty',
    unitprice       money         '$.UnitPrice'
)
GO







/*
    -------------------------------------------------------------------
    3. OPENJSON + CROSS APPLY 
    - a teraz połączmy to z tabelą, żeby mieć dostęp do OrderID i innych pól z dokumentu JSON
    - OPENJSON musi być połączony z tabelą przez CROSS APPLY lub OUTER APPLY,
      bo dla każdego wiersza z tabeli chcemy rozbić tablicę Items na wiersze
    - CROSS APPLY zwraca tylko wiersze z dopasowaniem, a OUTER APPLY zostawi też te, 
      gdzie tablica/podścieżka nic nie zwróci.
    - numerowanie elementów tablicy - można wejść w konkretny element tablicy przez ścieżkę $.Items[0], $.Items[1] itd.
    -------------------------------------------------------------------
*/


SELECT *
FROM DemoJson.OrderDocs_Text
CROSS APPLY OPENJSON(OrderDoc, '$.Items') AS Items
WHERE OrderID IN (43672)
ORDER BY OrderID;

-- tylko kolumny z OPENJSON
SELECT Items.*
FROM DemoJson.OrderDocs_Text
CROSS APPLY OPENJSON(OrderDoc, '$.Items') AS Items
WHERE OrderID IN (43672)
ORDER BY OrderID;



-- Cała tablica (wszystkie 3 produkty)
SELECT Items.*
FROM DemoJson.OrderDocs_Text
CROSS APPLY OPENJSON(OrderDoc, '$.Items')
WITH 
(
    SalesOrderDetailID INT,
    ProductID INT,
    Name NVARCHAR(100), 
    OrderQty INT,
    UnitPrice MONEY
) AS Items
WHERE OrderID = 43672;


-- Tylko pierwszy element [0]
SELECT Items.*
FROM DemoJson.OrderDocs_Text
CROSS APPLY OPENJSON(OrderDoc, '$.Items[0]')
WITH 
(
    SalesOrderDetailID INT,
    ProductID INT,
    Name NVARCHAR(100), 
    OrderQty INT,
    UnitPrice MONEY
) AS Items
WHERE OrderID = 43672;


-- Tylko drugi element [1]
SELECT Items.*
FROM DemoJson.OrderDocs_Text
CROSS APPLY OPENJSON(OrderDoc, '$.Items[1]')
WITH 
(
    SalesOrderDetailID INT,
    ProductID INT,
    Name NVARCHAR(100), 
    OrderQty INT,
    UnitPrice MONEY
) AS Items
WHERE OrderID = 43672;






-- Tylko drugi element [1]
-- więcej niż jeden produkt, bo mamy dwa dokumenty JSON (43672 i 43679) 
-- z co najmniej dwoma produktami w tablicy Items
SELECT Items.*
FROM DemoJson.OrderDocs_Text
CROSS APPLY OPENJSON(OrderDoc, '$.Items[1]')
WITH 
(
    SalesOrderDetailID INT,
    ProductID INT,
    Name NVARCHAR(100), 
    OrderQty INT,
    UnitPrice MONEY
) AS Items
WHERE OrderID IN (43672, 43679)






-- Tylko pierwszy element [0]
-- wszystkie zamówienia
SELECT Items.*
FROM DemoJson.OrderDocs_Text
CROSS APPLY OPENJSON(OrderDoc, '$.Items[0]')
WITH 
(
    SalesOrderDetailID INT,
    ProductID INT,
    Name NVARCHAR(100), 
    OrderQty INT,
    UnitPrice MONEY
) AS Items






/*
    -------------------------------------------------------------------
    4. Praktyczne użycie OPENJSON
    - filtrowanie, projekcja i agregacja na wielu dokumentach
    - czyli moment, w którym JSON zaczyna pracować jak normalne dane relacyjne
    -------------------------------------------------------------------
*/




-- Filtrowanie zamówień po zawartości tablicy Items
-- - znajdź wszystkie zamówienia, które zawierają produkt 776
SELECT DISTINCT
    t.OrderID
FROM DemoJson.OrderDocs_Text AS t
CROSS APPLY OPENJSON(t.OrderDoc, '$.Items')
WITH
(
    ProductID int '$.ProductID'   
) AS i
WHERE i.ProductID = 776
ORDER BY t.OrderID;




-- JOIN JSON-a z tabelą relacyjną
-- po rozbiciu Items mogę normalnie połączyć dane z tabelą produktów
SELECT TOP (20)
    t.OrderID,
    i.ProductID,
    p.Name           AS CurrentProductName,
    p.Color,
    i.OrderQty,
    i.UnitPrice,
    i.LineTotal
FROM DemoJson.OrderDocs_Text AS t
CROSS APPLY OPENJSON(t.OrderDoc, '$.Items')
WITH
(
    ProductID int '$.ProductID',
    OrderQty  int '$.OrderQty',
    UnitPrice money '$.UnitPrice',
    LineTotal money '$.LineTotal'
) AS i
INNER JOIN Production.Product AS p
    ON p.ProductID = i.ProductID
ORDER BY t.OrderID, i.ProductID;



-- Agregacja per zamówienie
-- ile pozycji i jaka wartość JSON-owych linii przypada na zamówienie

SELECT
    t.OrderID,
    COUNT(*) AS ItemsCount,
    SUM(i.OrderQty) AS TotalQty,
    SUM(i.LineTotal) AS TotalValue
FROM DemoJson.OrderDocs_Text AS t
CROSS APPLY OPENJSON(t.OrderDoc, '$.Items')
WITH
(
    OrderQty  int '$.OrderQty',
    LineTotal money '$.LineTotal'
) AS i
GROUP BY t.OrderID
ORDER BY TotalValue DESC





-- CROSS APPLY vs OUTER APPLY
-- - OUTER APPLY zostawia zamówienie nawet wtedy, gdy Items nie zwróci wierszy
-- - w naszych danych nie ma zamówienia bez pozycji

SELECT
    t.OrderID,
    i.ProductID,
    i.OrderQty
FROM DemoJson.OrderDocs_Text AS t
OUTER APPLY OPENJSON(t.OrderDoc, '$.Items')
WITH
(
    ProductID int '$.ProductID',
    OrderQty  int '$.OrderQty'
) AS i
ORDER BY t.OrderID;




/*
    -------------------------------------------------------------------
    5. lax / strict
    - lax/strict - w drugim argumencie OPENJSON
    - lax/strict - WITH dla brakującej właściwości
    -------------------------------------------------------------------
*/


-- lax/strict - pusty zbiór

-- lax
DECLARE @SampleJSON nvarchar(max) = (SELECT OrderDoc FROM DemoJson.OrderDocs_Text WHERE OrderID = 43672)
SELECT * FROM OPENJSON(@SampleJSON, 'lax $.Itemy') -- zamiast Items...
GO


-- strict
DECLARE @SampleJSON nvarchar(max) = (SELECT OrderDoc FROM DemoJson.OrderDocs_Text WHERE OrderID = 43672)
SELECT * FROM OPENJSON(@SampleJSON, 'strict $.Itemy') -- zamiast Items...
GO


-- domyślnie lax
DECLARE @SampleJSON nvarchar(max) = (SELECT OrderDoc FROM DemoJson.OrderDocs_Text WHERE OrderID = 43672)
SELECT * FROM OPENJSON(@SampleJSON, '$.Itemy') -- zamiast Items...
GO







-- lax/strict - WITH dla brakującej właściwości
DECLARE @SampleJSON nvarchar(max) = (SELECT OrderDoc FROM DemoJson.OrderDocs_Text WHERE OrderID = 43672);

SELECT *
FROM OPENJSON(@SampleJSON, '$.Items')
WITH
(
    SalesOrderDetailID int           '$.SalesOrderDetailID',
    ProductID          int           '$.ProductID',
    Name               nvarchar(200) '$.Name',
    OrderQty           int           '$.OrderQty',
    UnitPrice          money         '$.UnitPrice'
)
GO

-- domyślnie lax - brakująca właściwość zwróci NULL
DECLARE @SampleJSON nvarchar(max) = (SELECT OrderDoc FROM DemoJson.OrderDocs_Text WHERE OrderID = 43672);

SELECT *
FROM OPENJSON(@SampleJSON, '$.Items')
WITH
(
    SalesOrderDetailID int           '$.SalesOrderDetailID',
    ProductID          int           '$.ProductID',
    Name               nvarchar(200) '$.Name',
    OrderQty           int           '$.OrderQty',
    UnitPrice          money         '$.CenaJednostkowa'
)
GO

-- lax
DECLARE @SampleJSON nvarchar(max) = (SELECT OrderDoc FROM DemoJson.OrderDocs_Text WHERE OrderID = 43672);

SELECT *
FROM OPENJSON(@SampleJSON, '$.Items')
WITH
(
    SalesOrderDetailID int           '$.SalesOrderDetailID',
    ProductID          int           '$.ProductID',
    Name               nvarchar(200) '$.Name',
    OrderQty           int           '$.OrderQty',
    UnitPrice          money         'lax $.CenaJednostkowa'
)
GO

-- strict
DECLARE @SampleJSON nvarchar(max) = (SELECT OrderDoc FROM DemoJson.OrderDocs_Text WHERE OrderID = 43672);

--Msg 13608, Level 16, State 6, Line 522
--Property cannot be found on the specified JSON path.
SELECT *
FROM OPENJSON(@SampleJSON, '$.Items')
WITH
(
    SalesOrderDetailID int           '$.SalesOrderDetailID',
    ProductID          int           '$.ProductID',
    Name               nvarchar(200) '$.Name',
    OrderQty           int           '$.OrderQty',
    UnitPrice          money         'strict $.CenaJednostkowa'
)
GO








/*
    -------------------------------------------------------------------
    6. Alternatywa: PIVOT (niezalecana)
    - skomplikowane, niewydajne, trudne do utrzymania
    wady: słaba czytelność, dodatkowe przekształcenia, manualna konwersja typów, długi kod
    (nie do tego służy PIVOT)
    -------------------------------------------------------------------
*/

SELECT 
    OrderID,
    CAST([SalesOrderDetailID] AS INT) AS SalesOrderDetailID,
    CAST([ProductID] AS INT) AS ProductID,
    [Name],
    CAST([OrderQty] AS INT) AS OrderQty,
    CAST([UnitPrice] AS MONEY) AS UnitPrice
FROM (
    SELECT OrderID, [key], [value]
    FROM DemoJson.OrderDocs_Text
    CROSS APPLY OPENJSON(OrderDoc, '$.Items[0]')
) AS SourceTable
PIVOT (
    MAX([value]) 
    FOR [key] IN ([SalesOrderDetailID], [ProductID], [Name], [OrderQty], [UnitPrice])
) AS PivotTable





