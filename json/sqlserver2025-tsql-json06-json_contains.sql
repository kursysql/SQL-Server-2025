/*

    TSQL: JSON_CONTAINS
    Tomasz Libera | MVP Data Platform
    libera@kursysql.pl

    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL

    Funkcja JSON_CONTAINS
    sprawdza, czy wskazana wartość występuje w ścieżce dokumentu JSON


    Składnia:
    JSON_CONTAINS ( target_expression , search_value_expression [ , path_expression ] [ , search_mode ] )

    Uwaga:
    - funkcja jest dostępna w SQL Server 2025 (preview)
    - zwraca 1, 0 albo NULL
    - dobrze nadaje się do filtrowania dokumentów JSON po konkretnej wartości
    - jeśli ścieżka wskazuje na tablicę, trzeba użyć wildcarda [*]
    - domyślnie path działa w trybie lax

    1. Zacznijmy od prostego przykładu
    2. JSON_CONTAINS i tablice
    3. JSON_CONTAINS z tabeli
    4. JSON_CONTAINS i search_mode
    5. JSON_CONTAINS i nested arrays
    6. JSON_CONTAINS a NULL i brak ścieżki



    Dokumentacja:
    https://learn.microsoft.com/en-us/sql/t-sql/functions/json-contains-transact-sql?view=sql-server-ver17

*/

USE AdventureWorks2025
GO



/*
    -------------------------------------------------------------------
    1. Zacznijmy od prostego przykładu
    - JSON_CONTAINS zwraca 1, 0 albo NULL
    - sprawdzamy, czy konkretna wartość istnieje pod wskazaną ścieżką
    -------------------------------------------------------------------
*/

DECLARE @SampleJSON JSON = '{
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
    },
    {
      "ProductID": 774,
      "Name": "Mountain-100 Silver, 48",
      "OrderQty": 1
    }
  ]
}';

SELECT @SampleJSON;

SELECT
    JSON_CONTAINS(@SampleJSON, 43672, '$.OrderID')          AS HasOrderID_43672,
    JSON_CONTAINS(@SampleJSON, 5, '$.Status')              AS HasStatus_5,
    JSON_CONTAINS(@SampleJSON, 'EU', '$.Customer.Region')  AS HasRegion_EU,
    JSON_CONTAINS(@SampleJSON, 'US', '$.Customer.Region')  AS HasRegion_US,
    JSON_CONTAINS(@SampleJSON, 776, '$.Items[0].ProductID')  AS HasProduct776_1st,
    JSON_CONTAINS(@SampleJSON, 776, '$.Items[1].ProductID')  AS HasProduct776_2nd
GO


/*
    -------------------------------------------------------------------
    2. JSON_CONTAINS i tablice
    - jeśli ścieżka wskazuje na tablicę, używamy wildcarda [*]
    - można szukać wartości w elementach tablicy
    -------------------------------------------------------------------
*/

DECLARE @SampleJSON JSON = '{
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
      "OrderQty": 1
    }
  ]
}'

SELECT
    JSON_CONTAINS(@SampleJSON, 776, '$.Items[*].ProductID')                    AS HasProduct776,
    JSON_CONTAINS(@SampleJSON, 999, '$.Items[*].ProductID')                    AS HasProduct999,
    JSON_CONTAINS(@SampleJSON, 'Mountain-100 Black, 42', '$.Items[*].Name')    AS HasBlackBike,
    JSON_CONTAINS(@SampleJSON, 'Road Helmet', '$.Items[*].Name')               AS HasRoadHelmet
GO





/*
    -------------------------------------------------------------------
    3. JSON_CONTAINS z tabeli
    - filtrowanie dokumentów po obecności konkretnej wartości
    - bardzo naturalny wzorzec użycia
    -------------------------------------------------------------------
*/

SELECT 
    OrderID,
    JSON_CONTAINS(CAST(OrderDoc AS JSON), 776, '$.Items[*].ProductID') AS HasProduct776
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;
GO


-- tylko dokumenty, które zawierają produkt 776
SELECT 
    OrderID,
    OrderDoc
FROM DemoJson.OrderDocs_Text
WHERE JSON_CONTAINS(CAST(OrderDoc AS JSON), 776, '$.Items[*].ProductID') = 1
ORDER BY OrderID;
GO


-- tylko dokumenty, które zawierają nazwę produktu Mountain-100 Black, 42
SELECT 
    OrderID
FROM DemoJson.OrderDocs_Text
WHERE JSON_CONTAINS(CAST(OrderDoc AS JSON), 'Mountain-100 Black, 42', '$.Items[*].Name') = 1
ORDER BY OrderID;
GO



/*
    -------------------------------------------------------------------
    4. JSON_CONTAINS i search_mode
    - search_mode działa dla stringów
    - 0 = porównanie equality
    - 1 = semantyka LIKE
    -------------------------------------------------------------------
*/

DECLARE @SampleJSON JSON = '{
  "Items": [
    { "Name": "Mountain Bike Socks, M" },
    { "Name": "Mountain-100 Black, 42" },
    { "Name": "Mountain-100 Silver, 48" }
  ]
}';

SELECT
    JSON_CONTAINS(@SampleJSON, 'Mountain-100 Black, 42', '$.Items[*].Name', 0) AS ExactMatch,
    JSON_CONTAINS(@SampleJSON, 'Mountain%', '$.Items[*].Name', 1)               AS LikeMatch_Mountain,
    JSON_CONTAINS(@SampleJSON, 'Road%', '$.Items[*].Name', 1)                   AS LikeMatch_Road;
GO


/*
    -------------------------------------------------------------------
    5. JSON_CONTAINS i nested arrays
    - można szukać wartości w bardziej zagnieżdżonych strukturach
    -------------------------------------------------------------------
*/

DECLARE @SampleJSON JSON = '{
  "Items": [
    {
      "ProductID": 709,
      "Tags": ["bike", "socks"]
    },
    {
      "ProductID": 776,
      "Tags": ["mountain", "black"]
    }
  ]
}';

SELECT
    JSON_CONTAINS(@SampleJSON, 'bike', '$.Items[*].Tags[*]')     AS HasTag_Bike,
    JSON_CONTAINS(@SampleJSON, 'black', '$.Items[*].Tags[*]')    AS HasTag_Black,
    JSON_CONTAINS(@SampleJSON, 'helmet', '$.Items[*].Tags[*]')   AS HasTag_Helmet;
GO


/*
    -------------------------------------------------------------------
    6. JSON_CONTAINS a NULL i brak ścieżki
    - funkcja zwraca NULL, gdy argument jest NULL
    - zwraca też NULL, gdy wskazana ścieżka nie zostanie znaleziona
    -------------------------------------------------------------------
*/

DECLARE @SampleJSON JSON = '{
  "OrderID": 43672,
  "Customer": {
      "Region": "EU"
  }
}';

SELECT
    JSON_CONTAINS(@SampleJSON, 'EU', '$.Customer.Region')   AS ExistingPath,
    JSON_CONTAINS(@SampleJSON, 'EU', '$.Customer.Country')  AS MissingPath,
    JSON_CONTAINS(@SampleJSON, 'US', '$.Customer.Region')  AS MissingValue,
    JSON_CONTAINS(NULL, 'EU', '$.Customer.Region')          AS NullInput;
GO
