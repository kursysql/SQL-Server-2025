/*

    SQL Server 2025: Indeksy JSON - struktura wewnętrzna

    Tomasz Libera | MVP Data Platform
    libera@kursysql.pl

    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL
    https://github.com/kursysql/SQL-Server-2025/

    Uruchomić w tybie DAC (Dedicated Admin Connection) - w Management Studio: ADMIN:locahost

    1. Index z pojedynczą ścieżką JSON $.SalesPersonID
    2. Indeks klastrowy oparty na kilku kolumnach
    3. Dwie ścieżki JSON w indeksie
    4. Obiekt JSON w indeksie
    5. Tablica w indeksie JSON
    6. Optymalizacja dla wyszukiwania w tablicach (OPTIMIZE_FOR_ARRAY_SEARCH = ON)
    7. Cały JSON w indeksie
    8. Nieistniejące ścieżki JSON w indeksie

*/


-- test czy jest DAC
SELECT  s.session_id
FROM    sys.tcp_endpoints AS E
        INNER JOIN sys.dm_exec_sessions AS S ON E.endpoint_id = S.endpoint_id
WHERE   E.name = 'Dedicated Admin Connection';


USE AdventureWorks2025


/*    
    1. Index z pojedynczą ścieżką JSON $.SalesPersonID
*/


SELECT * FROM DemoJson.OrderDocs_Json_Indexed


DROP INDEX IF EXISTS IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed


CREATE JSON INDEX IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed (OrderDoc)
FOR
(
    '$.SalesPersonID'
)
WITH (DROP_EXISTING = ON)




SELECT ji.object_id, ji.index_id, ji.name, ji.type_desc, ji.optimize_for_array_search, jip.path
FROM sys.json_indexes AS ji
LEFT JOIN sys.json_index_paths AS jip ON ji.index_id = jip.index_id AND ji.object_id = jip.object_id






SELECT * FROM sys.objects WHERE type = 'IT' ORDER BY create_date DESC

-- sys.json_index_{object_id}_{index_id},
SELECT * FROM sys.json_index_452196661_1216000


-- pokaż wiersze z SalesPersonID = 274
-- wersja A
SELECT * FROM sys.json_index_452196661_1216000
WHERE sql_value = 274


SELECT od.*
FROM DemoJson.OrderDocs_Json_Indexed AS od
JOIN sys.json_index_452196661_1216000 AS ji ON ji.posting_1 = od.OrderID
WHERE ji.sql_value = 274



SET STATISTICS IO ON

-- wersja B
SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_VALUE(OrderDoc, '$.SalesPersonID') = '274'

SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_CONTAINS(OrderDoc, 274, '$.SalesPersonID') = 1


/*    
    2. Indeks klastrowy oparty na kilku kolumnach
*/

DROP TABLE IF EXISTS DemoJson.OrderDocs_Json_Indexed_Multiple
GO

CREATE TABLE DemoJson.OrderDocs_Json_Indexed_Multiple
(
    ID INT IDENTITY,
    OrderID INT,
    OrderDoc JSON,
    PRIMARY KEY CLUSTERED (ID, OrderID)
)

INSERT INTO DemoJson.OrderDocs_Json_Indexed_Multiple (OrderID, OrderDoc)
SELECT OrderID, OrderDoc FROM DemoJson.OrderDocs_Json_Indexed


SELECT * FROM DemoJson.OrderDocs_Json_Indexed_Multiple


CREATE JSON INDEX IXJ_OrderDocs_Json_Indexed_Multiple
ON DemoJson.OrderDocs_Json_Indexed_Multiple (OrderDoc)
FOR
(
    '$.SalesPersonID'
)


SELECT ji.object_id, ji.index_id, ji.name, ji.type_desc, ji.optimize_for_array_search, jip.path
FROM sys.json_indexes AS ji
LEFT JOIN sys.json_index_paths AS jip ON ji.index_id = jip.index_id AND ji.object_id = jip.object_id



SELECT * FROM sys.objects WHERE type = 'IT' ORDER BY create_date DESC



SELECT * FROM sys.json_index_836198029_1216000



DROP TABLE IF EXISTS DemoJson.OrderDocs_Json_Indexed_Multiple
GO




/*    
    3. Dwie ścieżki JSON w indeksie
*/



DROP INDEX IF EXISTS IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed


CREATE JSON INDEX IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed (OrderDoc)
FOR
(
    '$.SalesPersonID',
    '$.Customer.CustomerID'
)




SELECT ji.object_id, ji.index_id, ji.name, ji.type_desc, ji.optimize_for_array_search, jip.path
FROM sys.json_indexes AS ji
LEFT JOIN sys.json_index_paths AS jip ON ji.index_id = jip.index_id AND ji.object_id = jip.object_id




SELECT * FROM sys.objects WHERE type = 'IT' ORDER BY create_date DESC


SELECT * FROM sys.json_index_452196661_1216000




/*    
    4. Obiekt JSON w indeksie
*/

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
        "AccountNumber": "AW00029825",
        "CustomerType": "Store"
      },

*/

DROP INDEX IF EXISTS IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed


CREATE JSON INDEX IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed (OrderDoc)
FOR
(
    '$.Customer'
)




SELECT * FROM sys.json_index_452196661_1216000



/*    
    5. Tablica w indeksie JSON - optymalizacja dla wyszukiwania w tablicach (OPTIMIZE_FOR_ARRAY_SEARCH = ON)
*/


DROP INDEX IF EXISTS IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed


CREATE JSON INDEX IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed (OrderDoc)
FOR
(
    '$.Items'
)

-- wybieram zamówienie z 2 pozycjami
SELECT TOP 3 SalesOrderID, count(*) FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID 
HAVING count(*) = 2

SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE OrderID = 43660

/*

      "Items": [
        {
          "SalesOrderDetailID": 13,
          "ProductID": 762,
          "ProductNumber": "BK-R50R-44",
          "Name": "Road-650 Red, 44",
          "OrderQty": 1,
          "UnitPrice": 419.4589,
          "LineTotal": 419.458900
        },
        {
          "SalesOrderDetailID": 14,
          "ProductID": 758,
          "ProductNumber": "BK-R68R-52",
          "Name": "Road-450 Red, 52",
          "OrderQty": 1,
          "UnitPrice": 874.7940,
          "LineTotal": 874.794000
        }

*/

SELECT * FROM sys.json_index_452196661_1216000
WHERE posting_1 = 43660


DROP TABLE IF EXISTS #tmp_json_index_452196661_1216000_items

SELECT * 
INTO #tmp_json_index_452196661_1216000_items
FROM sys.json_index_452196661_1216000





/*    
    6. Optymalizacja dla wyszukiwania w tablicach (OPTIMIZE_FOR_ARRAY_SEARCH = ON)
*/



DROP INDEX IF EXISTS IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed


CREATE JSON INDEX IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed (OrderDoc)
FOR
(
    '$.Items'
)
WITH (OPTIMIZE_FOR_ARRAY_SEARCH = ON)



SELECT * FROM #tmp_json_index_452196661_1216000_items

SELECT * FROM sys.json_index_452196661_1216000
WHERE posting_1 = 43660





/*    
    7. Cały JSON w indeksie
*/




DROP INDEX IF EXISTS IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed


CREATE JSON INDEX IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed (OrderDoc)


SELECT * FROM sys.json_index_452196661_1216000





/*    
    8. Nieistniejące ścieżki JSON w indeksie
*/




DROP INDEX IF EXISTS IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed
GO


CREATE JSON INDEX IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed (OrderDoc)
FOR 
(
    '$.I_miss_xml'
)
GO



SELECT * FROM sys.json_index_452196661_1216000



