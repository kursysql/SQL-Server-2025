/*

    SQL Server 2025: Indeksy JSON - użycie w zapytaniach
    - wersja SQL Server 2025

    Tomasz Libera | MVP Data Platform
    libera@kursysql.pl

    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL
    https://github.com/kursysql/SQL-Server-2025/

    1. Indeks z pojedynczą ścieżką JSON $.SalesPersonID
    2. Indeks z obiektem Shipping
    3. Indeks z pojedynczą ścieżką do obiektu JSON - np. Shipping.City
    4. Weźmy inną ścieżkę - OrderDate - i zobaczmy, czy indeks JSON będzie użyty dla JSON_VALUE
    5. Dwie ścieżki w indeksie JSON - SalesPersonID i Shipping.City
    6. Przeszukiwanie tablicy


*/

USE AdventureWorks2025
GO

SET STATISTICS IO ON


SELECT * FROM DemoJson.OrderDocs_Json_Indexed


/*
    
    1. Index z pojedynczą ścieżką JSON $.SalesPersonID
    - JSON_VALUE
    - JSON_CONTAINS
    - JSON_PATH_EXISTS
    - porównanie z computed columns

*/


 

DROP INDEX IF EXISTS IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed


CREATE JSON INDEX IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed (OrderDoc)
FOR
(
    '$.SalesPersonID'
)




-- JSON Index Seek + Clustered Index Seek
-- OrderDocs_Json_Indexed reads: 19 | json_index_: 11
SELECT * 
FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_VALUE(OrderDoc, '$.SalesPersonID') = 287

-- caly czas pozostaje Clustered Index Seek
-- OrderDocs_Json_Indexed reads: 19 | json_index_: 11
SELECT OrderID
FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_VALUE(OrderDoc, '$.SalesPersonID') = 287



-- OrderDocs_Json_Indexed reads: 15 | json_index_452196661_1216000: 3
SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_CONTAINS(OrderDoc, 287, '$.SalesPersonID') = 1




-- Clustered Index Scan
-- OrderDocs_Json reads: 965 
SELECT * FROM DemoJson.OrderDocs_Json -- Json
WHERE JSON_VALUE(OrderDoc, '$.SalesPersonID') = 287

-- Clustered Index Scan
-- OrderDocs_Text reads: 1111
SELECT * FROM DemoJson.OrderDocs_Text -- Text
WHERE JSON_VALUE(OrderDoc, '$.SalesPersonID') = 287




/*
    porównanie z kolumną tekstową i computed column
*/



-- dodanie computed column SalesPersonID i indeksu
ALTER TABLE DemoJson.OrderDocs_Text ADD SalesPersonID AS JSON_VALUE(OrderDoc, '$.SalesPersonID')
GO
CREATE INDEX IX_OrderDocs_Text_SalesPersonID ON DemoJson.OrderDocs_Text (SalesPersonID);
GO


-- Index Seek + Key Lookup
-- OrderDocs_Text reads: 19
SELECT * FROM DemoJson.OrderDocs_Text
WHERE JSON_VALUE(OrderDoc, '$.SalesPersonID') = '287'

SELECT OrderID FROM DemoJson.OrderDocs_Text
WHERE JSON_VALUE(OrderDoc, '$.SalesPersonID') = '287'





DROP INDEX IX_OrderDocs_Text_SalesPersonID ON DemoJson.OrderDocs_Text
GO

ALTER TABLE DemoJson.OrderDocs_Text DROP COLUMN SalesPersonID 
GO







/*
    
    2. Indeks z obiektem Shipping


*/


DROP INDEX IF EXISTS IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed


CREATE JSON INDEX IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed (OrderDoc)
FOR
(
    '$.Shipping'
)
GO





-- ?????
SELECT *
FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_VALUE(OrderDoc, '$.Shipping.City') = 'Denver';






/* QUIZ 3

    - Dlaczego nie użył indeksu?
    a/ bo to Preview
    b/ bo wymaga Enterprise Edition
    c/ bo indeksy nie obsługują obiektów JSON, tylko wartości skalarne

*/




SELECT ji.object_id, ji.index_id, ji.name, ji.type_desc, ji.optimize_for_array_search, jip.path
FROM sys.json_indexes AS ji
LEFT JOIN sys.json_index_paths AS jip ON ji.index_id = jip.index_id



SELECT * FROM sys.objects WHERE type = 'IT' ORDER BY create_date DESC

SELECT * FROM sys.json_index_452196661_1216000


SELECT od.*
FROM DemoJson.OrderDocs_Json_Indexed AS od
JOIN sys.json_index_452196661_1216000 AS ji ON ji.posting_1 = od.OrderID
WHERE ji.sql_value = 'Denver'



-- tak działa 
SELECT *
FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_CONTAINS(OrderDoc, 'Denver', '$.Shipping.City') = 1;





-- Microsoft SQL Server 2025 (RTM-CU4) (KB5081495) 
-- - 17.0.4035.5 (X64)   Mar 29 2026 15:22:28
SELECT @@VERSION

--> json25-perf-json_azureSQL.sql (test na Azure SQL)




SELECT * FROM DemoJson.OrderDocs_Json_Indexed 
WHERE JSON_VALUE(OrderDoc, '$.SalesPersonID') = 287



-- ?????
SELECT *
FROM DemoJson.OrderDocs_Json_Indexed WITH (INDEX(IXJ_OrderDocs_Json_Indexed_OrderDoc))
WHERE JSON_VALUE(OrderDoc, '$.Shipping.City') = 'Denver';






/*
    
    3. Indeks z pojedynczą ścieżką do obiektu JSON - np. Shipping.City


*/


DROP INDEX IF EXISTS IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed


CREATE JSON INDEX IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed (OrderDoc)
FOR
(
    '$.Shipping.City'
)
GO



-- ???
-- OrderDocs_Json_Indexed reads: 965
SELECT *
FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_VALUE(OrderDoc, '$.Shipping.City') = 'Denver';


-- Index Scan x 2
-- json_index_ reads: 50 | OrderDocs_Json_Indexed reads: 710
SELECT *
FROM DemoJson.OrderDocs_Json_Indexed WITH (INDEX(IXJ_OrderDocs_Json_Indexed_OrderDoc))
WHERE JSON_VALUE(OrderDoc, '$.Shipping.City') = 'Denver';


-- JSON Index Seek + Clustered Index Seek
-- json_index_ reads: 3 | OrderDocs_Json_Indexed reads: 15
SELECT *
FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_CONTAINS(OrderDoc, 'Denver', '$.Shipping.City') = 1;




--> json25-perf-json_azureSQL.sql (test na Azure SQL)




/*
    porównanie z kolumną tekstową i computed column
*/

-- dodanie computed column Shipping_City i indeksu
ALTER TABLE DemoJson.OrderDocs_Text ADD Shipping_City AS JSON_VALUE(OrderDoc, '$.Shipping.City')
GO

CREATE INDEX IX_OrderDocs_Text_Shipping_City ON DemoJson.OrderDocs_Text (Shipping_City);
GO


-- Index Seek + Key Lookup
-- OrderDocs_Text reads: 18
SELECT * 
FROM DemoJson.OrderDocs_Text
WHERE JSON_VALUE(OrderDoc, '$.Shipping.City') = 'Denver';



DROP INDEX IX_OrderDocs_Text_Shipping_City ON DemoJson.OrderDocs_Text
GO

ALTER TABLE DemoJson.OrderDocs_Text DROP COLUMN Shipping_City 
GO














/*
    
    4. Weźmy inną ścieżkę - OrderDate - i zobaczmy, czy indeks JSON będzie użyty dla JSON_VALUE


*/



DROP INDEX IF EXISTS IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed


CREATE JSON INDEX IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed (OrderDoc)
FOR
(
    '$.OrderDate'
)





-- Clustered Index Scan 
SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_VALUE(OrderDoc, '$.OrderDate') = '2022-08-19T00:00:00'


-- JSON Index Seek + Clustered Index Seek
SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_CONTAINS(OrderDoc, '2022-08-19T00:00:00', '$.OrderDate') = 1







--> json25-perf-json_azureSQL.sql (test na Azure SQL)








/*
    
    5. Dwie ścieżki w indeksie JSON - SalesPersonID i Shipping.City


*/




DROP INDEX IF EXISTS IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed


CREATE JSON INDEX IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed (OrderDoc)
FOR
(
    '$.SalesPersonID',
    '$.Shipping.City'
)




-- Clustered Index Scan
SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_VALUE(OrderDoc, '$.SalesPersonID') = 287

-- JSON Index Seek + Clustered Index Seek
SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_CONTAINS(OrderDoc, 287, '$.SalesPersonID') = 1





-- Clustered Index Scan
SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_VALUE(OrderDoc, '$.Shipping.City') = 'Denver'

-- JSON Index Seek + Clustered Index Seek
SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_CONTAINS(OrderDoc, 'Denver', '$.Shipping.City') = 1





-- JSON Index Seek x 2 + Clustered Index Seek
SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_VALUE(OrderDoc, '$.SalesPersonID') = 276 AND JSON_VALUE(OrderDoc, '$.Shipping.City') = 'Denver'

-- JSON Index Seek x 2 + Clustered Index Seek
SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_CONTAINS(OrderDoc, 276, '$.SalesPersonID') = 1 AND JSON_CONTAINS(OrderDoc, 'Denver', '$.Shipping.City') = 1






--> json25-perf-json_azureSQL.sql (test na Azure SQL)







/*
    
    6. Optymalizacja dla wyszukiwania w tablicach 
     - tutaj trudno o optymalizację przez computed column

*/



DROP INDEX IF EXISTS IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed


CREATE JSON INDEX IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed (OrderDoc)
FOR
(
    '$.Items'
)



-- SQL25: Clustered Index Scan
SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_VALUE(OrderDoc, '$.Items[9].ProductID') = 744

-- JSON Index Seek + Clustered Index Seek
-- OrderDocs_Json_Indexed reads: 39 | json_index_ reads: 182
SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_CONTAINS(OrderDoc, 744, '$.Items[*].ProductID') = 1




-- JSON Index Seek x 2 + Clustered Index Scan
SELECT OrderID, OrderDoc
FROM DemoJson.OrderDocs_Json_Indexed
CROSS APPLY OPENJSON(OrderDoc, '$.Items')
WITH (
    ProductID INT '$.ProductID',
    OrderQty INT '$.OrderQty'
) AS Item
WHERE Item.ProductID = 744 AND Item.OrderQty = 2;





DROP INDEX IF EXISTS IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed
GO

CREATE JSON INDEX IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed (OrderDoc)
FOR
(
    '$.Items'
)
WITH (OPTIMIZE_FOR_ARRAY_SEARCH = ON)
GO




-- JSON Index Seek + Clustered Index Seek
-- OrderDocs_Json_Indexed reads: 39 | json_index_ reads: 4
SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_CONTAINS(OrderDoc, 744, '$.Items[*].ProductID') = 1














