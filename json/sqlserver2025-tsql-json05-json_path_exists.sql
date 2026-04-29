/*

    TSQL: JSON_PATH_EXISTS
    Tomasz Libera | MVP Data Platform
    libera@kursysql.pl

    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL

    Funkcja JSON_PATH_EXISTS
    sprawdza, czy wskazana ścieżka SQL/JSON istnieje w dokumencie JSON

    Składnia:
    JSON_PATH_EXISTS ( value_expression , sql_json_path )

    Uwaga:
    - funkcja jest dostępna od SQL Server 2022
    - zwraca 1, 0 albo NULL
    - nie zgłasza błędów
    - dobrze nadaje się do filtrowania dokumentów JSON
    - nie wyciąga wartości, tylko sprawdza istnienie ścieżki

    Dokumentacja:
    https://learn.microsoft.com/en-us/sql/t-sql/functions/json-path-exists-transact-sql?view=sql-server-ver17

    1. Zacznijmy od prostego przykładu
    2. JSON_PATH_EXISTS a obiekty, tablice i elementy tablic
    3. JSON_PATH_EXISTS z tabeli
    4. Praktyczne użycie JSON_PATH_EXISTS
    5. Array wildcard and range support | SQL Server 2025



*/

USE AdventureWorks2025
GO



/*
    -------------------------------------------------------------------
    1. Zacznijmy od prostego przykładu
    - JSON_PATH_EXISTS zwraca 1, 0 albo NULL
    - sprawdzamy, czy dana ścieżka istnieje w JSON
    -------------------------------------------------------------------
*/

DECLARE @SampleJSON nvarchar(max) = N'
{
  "OrderID": 43672,
  "Status": 5,
  "Customer": {
      "CustomerID": 11000,
      "Region": "EU"
  },
  "Items": [
    {
      "ProductID": 709,
      "Name": "Mountain Bike Socks, M",
      "OrderQty": 6
    },
    {
      "ProductID": 776,
      "Name": "Mountain-100 Black, 42",
      "OrderQty": 2
    }
  ]
}';

SELECT @SampleJSON;

SELECT
    JSON_PATH_EXISTS(@SampleJSON, '$.OrderID')         AS HasOrderID,
    JSON_PATH_EXISTS(@SampleJSON, '$.Customer')        AS HasCustomer,
    JSON_PATH_EXISTS(@SampleJSON, '$.Customer.Region') AS HasRegion,
    JSON_PATH_EXISTS(@SampleJSON, '$.Items')           AS HasItems,
    JSON_PATH_EXISTS(@SampleJSON, '$.DoesNotExist')    AS HasMissingPath;
GO


/*
    -------------------------------------------------------------------
    2. JSON_PATH_EXISTS a obiekty, tablice i elementy tablic
    - można sprawdzać istnienie obiektu, tablicy albo konkretnego elementu
    -------------------------------------------------------------------
*/

DECLARE @SampleJSON nvarchar(max) = N'
{
  "OrderID": 43672,
  "Items": [
    {
      "ProductID": 709,
      "Name": "Mountain Bike Socks, M"
    },
    {
      "ProductID": 776,
      "Name": "Mountain-100 Black, 42"
    }
  ]
}';

SELECT
    JSON_PATH_EXISTS(@SampleJSON, '$.Items')              AS HasItemsArray,
    JSON_PATH_EXISTS(@SampleJSON, '$.Items[0]')           AS HasFirstItem,
    JSON_PATH_EXISTS(@SampleJSON, '$.Items[1]')           AS HasSecondItem,
    JSON_PATH_EXISTS(@SampleJSON, '$.Items[2]')           AS HasThirdItem,
    JSON_PATH_EXISTS(@SampleJSON, '$.Items[0].Name')      AS HasFirstItemName,
    JSON_PATH_EXISTS(@SampleJSON, '$.Items[1].ProductID') AS HasSecondItemProductID;
GO


/*
    -------------------------------------------------------------------
    3. JSON_PATH_EXISTS z tabeli
    - szybki test, czy dokument ma oczekiwane właściwości
    - filtrowanie dokumentów po obecności ścieżki
    -------------------------------------------------------------------
*/

DECLARE @SampleJSON nvarchar(max) =
(
    SELECT OrderDoc
    FROM DemoJson.OrderDocs_Text
    WHERE OrderID = 43672
);

SELECT @SampleJSON;

SELECT
    JSON_PATH_EXISTS(@SampleJSON, '$.OrderID')   AS HasOrderID,
    JSON_PATH_EXISTS(@SampleJSON, '$.OrderDate') AS HasOrderDate,
    JSON_PATH_EXISTS(@SampleJSON, '$.Items')     AS HasItems,
    JSON_PATH_EXISTS(@SampleJSON, '$.Items[0]')  AS HasFirstItem;
GO



SELECT 
    OrderID,
    JSON_PATH_EXISTS(OrderDoc, '$.Items') AS HasItems
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;
GO


-- tylko dokumenty, które mają ścieżkę $.Items
SELECT 
    OrderID,
    OrderDoc
FROM DemoJson.OrderDocs_Text
WHERE JSON_PATH_EXISTS(OrderDoc, '$.Items') = 1
ORDER BY OrderID;
GO


-- tylko dokumenty, które mają drugi element w tablicy Items
SELECT 
    OrderID
FROM DemoJson.OrderDocs_Text
WHERE JSON_PATH_EXISTS(OrderDoc, '$.Items[1]') = 1
ORDER BY OrderID;
GO


-- tylko dokumenty, które mają trzeci element w tablicy Items
SELECT 
    OrderID
FROM DemoJson.OrderDocs_Text
WHERE JSON_PATH_EXISTS(OrderDoc, '$.Items[2]') = 1
ORDER BY OrderID;
GO


-- tylko dokumenty, które mają trzydzieści elementów w tablicy Items
SELECT 
    OrderID,
    OrderDoc
FROM DemoJson.OrderDocs_Text
WHERE JSON_PATH_EXISTS(OrderDoc, '$.Items[29]') = 1
ORDER BY OrderID;
GO






/*
    -------------------------------------------------------------------
    4. Praktyczne użycie JSON_PATH_EXISTS
    - sprawdzanie obecności ścieżki przed dalszym odczytem
    - dobre do filtrowania dokumentów z opcjonalnymi polami
    -------------------------------------------------------------------
*/

-- 5A. Najpierw sprawdzam, czy ścieżka istnieje, potem odczytuję wartość
SELECT TOP (20)
    OrderID,
    JSON_VALUE(OrderDoc, '$.OrderDate') AS OrderDate
FROM DemoJson.OrderDocs_Text
WHERE JSON_PATH_EXISTS(OrderDoc, '$.OrderDate') = 1
ORDER BY OrderID;
GO


-- 5B. Najpierw sprawdzam, czy istnieje tablica Items, potem pobieram fragment JSON
SELECT 
    OrderID,
    JSON_QUERY(OrderDoc, '$.Items') AS Items
FROM DemoJson.OrderDocs_Text
WHERE JSON_PATH_EXISTS(OrderDoc, '$.Items') = 1
ORDER BY OrderID;
GO


-- 5C. Najpierw sprawdzam, czy istnieje ścieżka, potem rozbijam tablicę na wiersze
SELECT 
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
WHERE JSON_PATH_EXISTS(t.OrderDoc, '$.Items') = 1
ORDER BY t.OrderID;
GO


/*
    -------------------------------------------------------------------
    5. Array wildcard and range support | SQL Server 2025    
    - JSON_PATH_EXISTS zwraca 1, jeśli ścieżka zwraca niepustą sekwencję
    - wildcard / range są dostępne w SQL Server 2025 preview
    -------------------------------------------------------------------
*/

DECLARE @SampleJSON2025 JSON = '{
  "OrderID": 43672,
  "Items": [
    {
      "ProductID": 709,
      "Name": "Mountain Bike Socks, M",
      "OrderQty": 6
    },
    {
      "ProductID": 776,
      "Name": "Mountain-100 Black, 42",
      "OrderQty": 2
    },
    {
      "ProductID": 774,
      "Name": "Mountain-100 Silver, 48",
      "OrderQty": 1,
      "Color": "Silver"
    }
  ]
}';

SELECT
    JSON_PATH_EXISTS(@SampleJSON2025, '$.Items[*].Name')      AS AnyNames_Wildcard,
    JSON_PATH_EXISTS(@SampleJSON2025, '$.Items[*].Color')     AS AnyColors_Wildcard, -- !!
    JSON_PATH_EXISTS(@SampleJSON2025, '$.Items[0 to 1].Name') AS FirstTwoNames_Range,
    JSON_PATH_EXISTS(@SampleJSON2025, '$.Items[0,2].Name')    AS FirstAndThirdNames_List,
    JSON_PATH_EXISTS(@SampleJSON2025, '$.Items[0,5].Name')    AS FirstAndSixthNames_List, -- !!
    JSON_PATH_EXISTS(@SampleJSON2025, '$.Items[4,5].Name')    AS FirstAndSixthNames_List, -- !!
    JSON_PATH_EXISTS(@SampleJSON2025, '$.Items[last].Name')   AS LastName_LastToken;
GO
