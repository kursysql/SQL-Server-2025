/*

    SQL Server 2025: Indeksy JSON

    Tomasz Libera | MVP Data Platform
    libera@kursysql.pl

    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL
    https://github.com/kursysql/SQL-Server-2025/

    1. Tworzenie indeksu JSON
    2. Co nie jest obsługiwane

*/

USE AdventureWorks2025
GO

SET STATISTICS IO ON


/*    
    1. Tworzenie indeksu JSON

*/


DROP INDEX IF EXISTS IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed


SELECT * FROM sys.indexes 
WHERE object_id =  OBJECT_ID('DemoJson.OrderDocs_Json_Indexed')

-- rozmiar tabeli bez indeksu JSON
-- reserved: 7 880 KB | data: 7 680 KB | index size: 40 KB 
EXEC sp_spaceused 'DemoJson.OrderDocs_Json_Indexed'




DROP INDEX IF EXISTS IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed
GO

-- indeks na wszystkich węzłach
CREATE JSON INDEX IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed (OrderDoc)
GO

CREATE JSON INDEX IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed (OrderDoc)
FOR ('$')
GO


-- indeks JSON na liście
SELECT * FROM sys.indexes 
WHERE object_id =  OBJECT_ID('DemoJson.OrderDocs_Json_Indexed')


-- sprawdzanie struktury indeksu JSON
SELECT * FROM sys.json_indexes
SELECT * FROM sys.json_index_paths

SELECT ji.object_id, ji.index_id, ji.name, ji.type_desc, ji.optimize_for_array_search, jip.path
FROM sys.json_indexes AS ji
LEFT JOIN sys.json_index_paths AS jip ON ji.index_id = jip.index_id




-- rozmiar tabeli bez indeksu JSON
-- reserved: 40 832 KB | data: 7 680 KB | index size: 31 920 KB 
EXEC sp_spaceused 'DemoJson.OrderDocs_Json_Indexed'




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
GO

-- indeks zawierający ścieżki 
CREATE JSON INDEX IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed (OrderDoc)
FOR 
(
    '$.SalesPersonID'
)
GO



SELECT ji.object_id, ji.index_id, ji.name, ji.type_desc, ji.optimize_for_array_search, jip.path
FROM sys.json_indexes AS ji
LEFT JOIN sys.json_index_paths AS jip ON ji.index_id = jip.index_id



-- rozmiar tabeli bez indeksu JSON
-- reserved: 9 088 KB | data: 7 680 KB | index size: 352 KB 
EXEC sp_spaceused 'DemoJson.OrderDocs_Json_Indexed'





/*    
    2. Co nie jest obsługiwane
    a/ więcej niż jeden indeks na tej samej kolumnie JSON
    b/ ścieżki nie mogą na siebie nachodzić
    c/ ONLINE nieobsługiwane 

*/



-- a/ więcej niż jeden indeks na tej samej kolumnie JSON
DROP INDEX IF EXISTS IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed
GO

-- indeks #1
CREATE JSON INDEX IXJ_OrderDocs_Json_Indexed_OrderDoc1
ON DemoJson.OrderDocs_Json_Indexed (OrderDoc)
FOR 
(
    '$.SalesPersonID'
)
GO


-- indeks #2
-- Msg 13681, Level 16, State 1, Line 151
-- A JSON index 'IXJ_OrderDocs_Json_Indexed_OrderDoc1' already exists on column 'OrderDoc' 
-- on table 'OrderDocs_Json_Indexed', and multiple JSON indexes per column are not allowed.
CREATE JSON INDEX IXJ_OrderDocs_Json_Indexed_OrderDoc2
ON DemoJson.OrderDocs_Json_Indexed (OrderDoc)
FOR 
(
    '$.Customer.CustomerID'
)
GO



DROP INDEX IF EXISTS IXJ_OrderDocs_Json_Indexed_OrderDoc1
ON DemoJson.OrderDocs_Json_Indexed
GO


-- zamiast tego jeden indeks z kilkoma ścieżkami 

CREATE JSON INDEX IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed (OrderDoc)
FOR 
(
    '$.SalesPersonID',
    '$.Customer.CustomerID'
)
GO


SELECT ji.object_id, ji.index_id, ji.name, ji.type_desc, ji.optimize_for_array_search, jip.path
FROM sys.json_indexes AS ji
LEFT JOIN sys.json_index_paths AS jip ON ji.index_id = jip.index_id



DROP INDEX IF EXISTS IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed
GO


-- b/ ścieżki nie mogą na siebie nachodzić

-- Msg 13683, Level 16, State 1, Line 196
-- Invalid JSON paths in JSON index.
CREATE JSON INDEX IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed (OrderDoc)
FOR 
(
    '$.Customer',
    '$.Customer.CustomerID'
)
GO



-- c/ ONLINE nieobsługiwane 


-- Msg 153, Level 15, State 35, Line 220
-- Invalid usage of the option ONLINE in the CREATE JSON INDEX statement.
CREATE JSON INDEX IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed (OrderDoc)
FOR 
(
    '$.Customer.CustomerID'
)
WITH (ONLINE = ON)



