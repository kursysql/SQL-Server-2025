/*

    TSQL: JSON_VALUE wydajność - indeksy JSON
    - Wersja SQL Server 2025

    Tomasz Libera | MVP Data Platform
    libera@kursysql.pl

    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL
    https://github.com/kursysql/SQL-Server-2025/


*/

USE AdventureWorks2025
GO

SET STATISTICS IO ON


SELECT * FROM DemoJson.OrderDocs_Json_Indexed

/*

{
  "OrderID": 43659,
  "OrderDate": "2022-05-30T00:00:00",
  "Status": 5,
  "OnlineOrder": false,
  "SalesPersonID": 279,
  "Customer": {
    "CustomerID": 29825,
  },
  "Shipping": {
    "City": "Austell",
  },
  "Items": [
    {
      "SalesOrderDetailID": 1,
      "ProductID": 776,
      "ProductNumber": "BK-M82B-42",
      "Name": "Mountain-100 Black, 42",
      "OrderQty": 1,
      "UnitPrice": 2024.9940,
      "LineTotal": 2024.994000
    },
    {
      "SalesOrderDetailID": 2,
      "ProductID": 777,
      "ProductNumber": "BK-M82B-44",
      "Name": "Mountain-100 Black, 44",
      "OrderQty": 3,
      "UnitPrice": 2024.9940,
      "LineTotal": 6074.982000
    },

*/




/*
    
    1. Utworzenie indeksu JSON na kolumnie OrderDoc (cały dokument) 

*/



DROP INDEX IF EXISTS IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed


-- reserved: 7 880 KB	
-- data: 7 680 KB
-- index size: 40 KB
EXEC sp_spaceused 'DemoJson.OrderDocs_Json_Indexed'





DROP INDEX IF EXISTS IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed


CREATE JSON INDEX IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed (OrderDoc)
GO

-- reserved: 40 624 KB	(4x....)
-- data: 7 680 KB
-- index size: 31 928 KB
EXEC sp_spaceused 'DemoJson.OrderDocs_Json_Indexed'


CREATE JSON INDEX IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed (OrderDoc)
FOR('$')




/*
    
    2. JSON_VALUE i właściwość na pierwszym poziomie

*/




-- ? Clustered Index Scan
SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_VALUE(OrderDoc, '$.SalesPersonID') = 287




/* QUIZ 3

    - Dlaczego nie użył indeksu?
    a/ bo to Preview
    b/ bo wymaga Enterprise Edition
    c/ bo JSON_VALUE zwraca nvarchar, a SalesPersonID w JSON jest int

*/



-- Microsoft SQL Server 2025 (RTM-CU4) (KB5081495) 
-- - 17.0.4035.5 (X64)   Mar 29 2026 15:22:28
SELECT @@VERSION


--> test w Azure SQL Database


-- Wymuszenie indeksu
-- JSON Index Seek + Clustered Index Scan
SELECT * FROM DemoJson.OrderDocs_Json_Indexed WITH (INDEX(IXJ_OrderDocs_Json_Indexed_OrderDoc))
WHERE JSON_VALUE(OrderDoc, '$.SalesPersonID') = 287

-- odczyt tylko klucza indeksu klastrowego - cały czas Clustered Index Scan
SELECT OrderID FROM DemoJson.OrderDocs_Json_Indexed WITH (INDEX(IXJ_OrderDocs_Json_Indexed_OrderDoc))
WHERE JSON_VALUE(OrderDoc, '$.SalesPersonID') = 287






-- ? Clustered Index Scan
SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_VALUE(OrderDoc, '$.OrderDate') = '2022-05-30T00:00:00'



SELECT *
FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_VALUE(OrderDoc, '$.Shipping.City') = 'Denver';



/*
    
    3. Indeks JSON ze ścieżką do właściwości

*/

DROP INDEX IF EXISTS IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed
GO

CREATE JSON INDEX IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed (OrderDoc)
FOR
(
    '$.SalesPersonID'
)



-- reserved: 8 944 KB	
-- data: 7 680 KB
-- index size: 320 KB
EXEC sp_spaceused 'DemoJson.OrderDocs_Json_Indexed'




-- sprawdzanie struktury indeksu JSON
SELECT * FROM sys.json_indexes
SELECT * FROM sys.json_index_paths

SELECT ji.object_id, ji.index_id, ji.name, ji.type_desc, ji.optimize_for_array_search, jip.path
FROM sys.json_indexes AS ji
LEFT JOIN sys.json_index_paths AS jip ON ji.index_id = jip.index_id


-- JSON Index Seek !!!
SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_VALUE(OrderDoc, '$.SalesPersonID') = 287



-- Clustered Index Scan - brak indeksu na tej ścieżce
SELECT *
FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_VALUE(OrderDoc, '$.Shipping.City') = 'Denver';



DROP INDEX IF EXISTS IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed
GO

CREATE JSON INDEX IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed (OrderDoc)
FOR
(
    '$.Shipping.City'
)


-- reserved: 9 200 KB	
-- data: 7 680 KB
-- index size: 824 KB
EXEC sp_spaceused 'DemoJson.OrderDocs_Json_Indexed'





-- Clustered Index Scan ??
SELECT *
FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_VALUE(OrderDoc, '$.Shipping.City') = 'Denver';






/*
    
    4. Indeks JSON z kilkoma ścieżkami 

*/

DROP INDEX IF EXISTS IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed
GO

CREATE JSON INDEX IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed (OrderDoc)
FOR
(
    '$.SalesPersonID',
    '$.Shipping.City'
)


-- sprawdzanie struktury indeksu JSON
SELECT * FROM sys.json_indexes
SELECT * FROM sys.json_index_paths

SELECT ji.object_id, ji.index_id, ji.name, ji.type_desc, ji.optimize_for_array_search, jip.path
FROM sys.json_indexes AS ji
LEFT JOIN sys.json_index_paths AS jip ON ji.index_id = jip.index_id




-- reserved: 9 264 KB	
-- data: 7 680 KB
-- index size: 976 KB
EXEC sp_spaceused 'DemoJson.OrderDocs_Json_Indexed'





-- Clustered Index Scan ?? 
SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_VALUE(OrderDoc, '$.SalesPersonID') = 287

-- JSON Index Sekk + Clustered Index Seek
SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_CONTAINS(OrderDoc, 287, '$.SalesPersonID') = 1



-- Clustered Index Scan ??
SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_VALUE(OrderDoc, '$.Shipping.City') = 'Denver';

-- JSON Index Seek + Clustered Index Seek
SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_CONTAINS(OrderDoc, 'Denver', '$.Shipping.City') = 1;





/*

    5. Tablice JSON 
    optymalizacja dla wyszukiwania w tablicach 
    (OPTIMIZE_FOR_ARRAY_SEARCH = ON)

*/

SELECT ProductID, count(*)
FROM Sales.SalesOrderDetail 
GROUP BY ProductID



-- przykładowa składanie indeksu JSON - na wielu ścieżkach jednocześnie
CREATE JSON INDEX IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed (OrderDoc)
FOR
(
    '$.Customer.CustomerID',
    '$.Status',
    '$.Totals.TotalDue',
    '$.Tags[*]'
)
WITH (OPTIMIZE_FOR_ARRAY_SEARCH = ON);
GO
