/*
    Warsztaty JSON: 02. Zamiana JSON na wiersze - OPENJSON - rozwiązania zadań

    Tomasz Libera | MVP Data Platform
    libera@kursysql.pl

    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL

    Ten skrypt zawiera przykładowe rozwiązania zadań z pliku:

        02-A-openjson.md
*/

USE AdventureWorks2025;
GO

/* ============================================================
   Zadanie 1. Podejrzyj dokument z tablicą Items
   ============================================================ */

SELECT TOP (10)
    OrderID,
    OrderDoc
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;
GO


/* ============================================================
   Zadanie 2. Odczytaj tablicę Items jako JSON
   ============================================================ */

SELECT TOP (10)
    OrderID,
    JSON_QUERY(OrderDoc, '$.Items') AS Items
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;
GO


/* ============================================================
   Zadanie 3. Użyj OPENJSON na prostej tablicy
   ============================================================ */

DECLARE @json nvarchar(max) = N'["SQL Server", "JSON", "OPENJSON"]';

SELECT
    j.[key],
    j.[value],
    j.[type]
FROM OPENJSON(@json) AS j;
GO


/* ============================================================
   Zadanie 4. Sprawdź domyślne kolumny OPENJSON
   ============================================================ */

DECLARE @json nvarchar(max) = N'["SQL Server", "JSON", "OPENJSON"]';

SELECT
    j.[key],
    j.[value],
    j.[type]
FROM OPENJSON(@json) AS j;
GO

/*
    Komentarz:
    W przypadku tablicy JSON kolumna key oznacza indeks elementu tablicy.
    Indeksowanie zaczyna się od 0.
*/


/* ============================================================
   Zadanie 5. Użyj OPENJSON na prostym obiekcie
   ============================================================ */

DECLARE @json nvarchar(max) = N'
{
  "ProductID": 776,
  "Name": "Mountain-100 Black, 42",
  "OrderQty": 1
}';

SELECT
    j.[key],
    j.[value],
    j.[type]
FROM OPENJSON(@json) AS j;
GO


/* ============================================================
   Zadanie 6. Rozbij tablicę Items dla jednego zamówienia
   ============================================================ */

WITH FirstOrder AS
(
    SELECT TOP (1)
        OrderID,
        OrderDoc
    FROM DemoJson.OrderDocs_Text
    WHERE JSON_QUERY(OrderDoc, '$.Items') IS NOT NULL
    ORDER BY OrderID
)
SELECT
    f.OrderID,
    j.[key],
    j.[value],
    j.[type]
FROM FirstOrder AS f
CROSS APPLY OPENJSON(f.OrderDoc, '$.Items') AS j
ORDER BY
    f.OrderID,
    TRY_CONVERT(int, j.[key]);
GO

-- alternatywnie:
SELECT
    odt.OrderID,
    j.[key],
    j.[value],
    j.[type]
FROM DemoJson.OrderDocs_Text AS odt
CROSS APPLY OPENJSON(odt.OrderDoc, '$.Items') AS j
WHERE odt.OrderID = 43659
ORDER BY
    odt.OrderID,
    TRY_CONVERT(int, j.[key]);
GO



/* ============================================================
   Zadanie 7. Zmapuj pozycje zamówienia na kolumny
   ============================================================ */


SELECT
    i.ProductID,
    i.ProductNumber,
    i.Name,
    i.OrderQty,
    i.UnitPrice,
    i.LineTotal
FROM DemoJson.OrderDocs_Text AS odt
CROSS APPLY OPENJSON(odt.OrderDoc, '$.Items')
WITH
(
    ProductID int '$.ProductID',
    ProductNumber nvarchar(50) '$.ProductNumber',
    Name nvarchar(200) '$.Name',
    OrderQty int '$.OrderQty',
    UnitPrice decimal(19, 4) '$.UnitPrice',
    LineTotal decimal(19, 4) '$.LineTotal'
) AS i
WHERE odt.OrderID = 43659
ORDER BY
    i.ProductID;
GO


/* ============================================================
   Zadanie 8. Dodaj OrderID z tabeli
   ============================================================ */

SELECT
    odt.OrderID,
    i.ProductID,
    i.ProductNumber,
    i.Name,
    i.OrderQty,
    i.UnitPrice,
    i.LineTotal
FROM DemoJson.OrderDocs_Text AS odt
CROSS APPLY OPENJSON(odt.OrderDoc, '$.Items')
WITH
(
    ProductID int '$.ProductID',
    ProductNumber nvarchar(50) '$.ProductNumber',
    Name nvarchar(200) '$.Name',
    OrderQty int '$.OrderQty',
    UnitPrice decimal(19, 4) '$.UnitPrice',
    LineTotal decimal(19, 4) '$.LineTotal'
) AS i
WHERE odt.OrderID = 43659
ORDER BY
    i.ProductID;
GO




/* ============================================================
   Zadanie 9. Rozbij Items dla wielu zamówień
   ============================================================ */

SELECT TOP (100)
    t.OrderID,
    i.ProductID,
    i.Name,
    i.OrderQty,
    i.UnitPrice,
    i.LineTotal
FROM DemoJson.OrderDocs_Text AS t
CROSS APPLY OPENJSON(t.OrderDoc, '$.Items')
WITH
(
    ProductID int '$.ProductID',
    Name nvarchar(200) '$.Name',
    OrderQty int '$.OrderQty',
    UnitPrice decimal(19, 4) '$.UnitPrice',
    LineTotal decimal(19, 4) '$.LineTotal'
) AS i
ORDER BY
    t.OrderID,
    i.ProductID;
GO


/* ============================================================
   Zadanie 10. Przefiltruj po ProductID
   ============================================================ */

SELECT TOP (100)
    t.OrderID,
    i.ProductID,
    i.Name,
    i.OrderQty,
    i.UnitPrice,
    i.LineTotal
FROM DemoJson.OrderDocs_Text AS t
CROSS APPLY OPENJSON(t.OrderDoc, '$.Items')
WITH
(
    ProductID int '$.ProductID',
    Name nvarchar(200) '$.Name',
    OrderQty int '$.OrderQty',
    UnitPrice decimal(19, 4) '$.UnitPrice',
    LineTotal decimal(19, 4) '$.LineTotal'
) AS i
WHERE i.ProductID = 776
ORDER BY
    t.OrderID,
    i.ProductID;
GO


/* ============================================================
   Zadanie 11. Przefiltruj po ilości
   ============================================================ */

SELECT TOP (100)
    t.OrderID,
    i.ProductID,
    i.Name,
    i.OrderQty,
    i.UnitPrice,
    i.LineTotal
FROM DemoJson.OrderDocs_Text AS t
CROSS APPLY OPENJSON(t.OrderDoc, '$.Items')
WITH
(
    ProductID int '$.ProductID',
    Name nvarchar(200) '$.Name',
    OrderQty int '$.OrderQty',
    UnitPrice decimal(19, 4) '$.UnitPrice',
    LineTotal decimal(19, 4) '$.LineTotal'
) AS i
WHERE i.OrderQty > 1
ORDER BY
    t.OrderID,
    i.ProductID;
GO


/* ============================================================
   Zadanie 12. Przelicz wartość pozycji
   ============================================================ */

SELECT TOP (100)
    t.OrderID,
    i.ProductID,
    i.Name,
    i.OrderQty,
    i.UnitPrice,
    i.OrderQty * i.UnitPrice AS CalculatedLineTotal,
    i.LineTotal
FROM DemoJson.OrderDocs_Text AS t
CROSS APPLY OPENJSON(t.OrderDoc, '$.Items')
WITH
(
    ProductID int '$.ProductID',
    Name nvarchar(200) '$.Name',
    OrderQty int '$.OrderQty',
    UnitPrice decimal(19, 4) '$.UnitPrice',
    LineTotal decimal(19, 4) '$.LineTotal'
) AS i
ORDER BY
    t.OrderID,
    i.ProductID;
GO


/* ============================================================
   Zadanie 13. Policz liczbę pozycji w zamówieniu
   ============================================================ */

SELECT
    t.OrderID,
    COUNT(*) AS ItemsCount
FROM DemoJson.OrderDocs_Text AS t
CROSS APPLY OPENJSON(t.OrderDoc, '$.Items')
WITH
(
    ProductID int '$.ProductID'
) AS i
GROUP BY
    t.OrderID
ORDER BY
    t.OrderID;
GO


/* ============================================================
   Zadanie 14. Policz wartość pozycji w zamówieniu
   ============================================================ */

SELECT
    t.OrderID,
    SUM(i.LineTotal) AS ItemsTotal
FROM DemoJson.OrderDocs_Text AS t
CROSS APPLY OPENJSON(t.OrderDoc, '$.Items')
WITH
(
    LineTotal decimal(19, 4) '$.LineTotal'
) AS i
GROUP BY
    t.OrderID
ORDER BY
    t.OrderID;
GO


/* ============================================================
   Zadanie 15. Połącz dane z JSON_VALUE i OPENJSON
   ============================================================ */

SELECT TOP (100)
    t.OrderID,
    JSON_VALUE(t.OrderDoc, '$.OrderDate') AS OrderDate,
    JSON_VALUE(t.OrderDoc, '$.Status') AS Status,
    JSON_VALUE(t.OrderDoc, '$.Customer.CustomerID') AS CustomerID,
    i.ProductID,
    i.Name,
    i.OrderQty,
    i.UnitPrice,
    i.LineTotal
FROM DemoJson.OrderDocs_Text AS t
CROSS APPLY OPENJSON(t.OrderDoc, '$.Items')
WITH
(
    ProductID int '$.ProductID',
    Name nvarchar(200) '$.Name',
    OrderQty int '$.OrderQty',
    UnitPrice decimal(19, 4) '$.UnitPrice',
    LineTotal decimal(19, 4) '$.LineTotal'
) AS i
ORDER BY
    t.OrderID,
    i.ProductID;
GO


/* ============================================================
   Koniec części 02

   W tej części rozwiązania dotyczyły:
   - OPENJSON,
   - domyślnego schematu OPENJSON,
   - OPENJSON z klauzulą WITH,
   - CROSS APPLY,
   - filtrowania danych z tablic JSON,
   - agregowania danych z tablic JSON,
   - łączenia JSON_VALUE i OPENJSON.

   W kolejnej części przechodzimy do:
   - ISJSON,
   - JSON_PATH_EXISTS,
   - JSON_CONTAINS.
   ============================================================ */