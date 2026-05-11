/*

    TSQL: JSON_VALUE wydajność - indeksy JSON
    - Wersja AzureSQL Database

    Tomasz Libera | MVP Data Platform
    libera@kursysql.pl

    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL
    https://github.com/kursysql/SQL-Server-2025/


*/



SET STATISTICS IO ON


SELECT * FROM DemoJson.OrderDocs_Json_Indexed



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

CREATE JSON INDEX IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed (OrderDoc)
FOR('$')

-- reserved: 39 576 KB	(4x....)
-- data: 7 680 KB
-- index size: 31 752 KB
EXEC sp_spaceused 'DemoJson.OrderDocs_Json_Indexed'



/*
    
    2. JSON_VALUE i właściwość na pierwszym poziomie

*/




-- JSON Index Seek
SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_VALUE(OrderDoc, '$.SalesPersonID') = 287



-- JSON Index Seek
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



-- reserved: 8  152 KB
-- data: 7 680 KB
-- index size: 116 KB
EXEC sp_spaceused 'DemoJson.OrderDocs_Json_Indexed'





-- JSON Index Seek
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




-- JSON Index Scan
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
WITH (OPTIMIZE_FOR_ARRAY_SEARCH = ON)


---- reserved: 8 720 KB	
---- data: 7 680 KB
---- index size: 856 KB
--EXEC sp_spaceused 'DemoJson.OrderDocs_Json_Indexed'





-- JSON Index Seek + Clustered Index Scan ?? 
SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_VALUE(OrderDoc, '$.SalesPersonID') = 287

-- JSON Index Seek + Clustered Index Scan ?? 
SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_VALUE(OrderDoc, '$.Shipping.City') = 'Denver';


DROP INDEX IF EXISTS IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed
GO

CREATE JSON INDEX IXJ_OrderDocs_Json_Indexed_OrderDoc1
ON DemoJson.OrderDocs_Json_Indexed (OrderDoc)
FOR
(
    '$.SalesPersonID'
)
GO

CREATE JSON INDEX IXJ_OrderDocs_Json_Indexed_OrderDoc2
ON DemoJson.OrderDocs_Json_Indexed (OrderDoc)
FOR
(
    '$.Shipping.City'
)
GO

--> TODO





DROP INDEX IF EXISTS IXJ_OrderDocs_Json_Indexed_OrderDoc1
ON DemoJson.OrderDocs_Json_Indexed
GO

DROP INDEX IF EXISTS IXJ_OrderDocs_Json_Indexed_OrderDoc2
ON DemoJson.OrderDocs_Json_Indexed
GO


/*

    5. Tablice JSON 
    optymalizacja dla wyszukiwania w tablicach 
    (OPTIMIZE_FOR_ARRAY_SEARCH = ON)

*/

SELECT * FROM DemoJson.OrderDocs_Json_Indexed

/*
        '$.Items[9]'
*/

DROP INDEX IF EXISTS IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed
GO

CREATE JSON INDEX IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed (OrderDoc)
FOR
(
    '$.Items[9]'
)

-- reserved: 8 600 KB	
-- data: 7 680 KB
-- index size: 704 KB
EXEC sp_spaceused 'DemoJson.OrderDocs_Json_Indexed'


-- JSON Index Seek + Clustered Index Seek
-- OrderDocs_Json_Indexed reads: 8, json_index_ reads: 8
SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_VALUE(OrderDoc, '$.Items[9].ProductID') = 744

-- Clustered Index Scan
-- -- OrderDocs_Json_Indexed reads: 965
SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_CONTAINS(OrderDoc, 744, '$.Items[*].ProductID') = 1



/*
        '$.Items'
*/


DROP INDEX IF EXISTS IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed
GO

CREATE JSON INDEX IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed (OrderDoc)
FOR
(
    '$.Items'
)

-- reserved: 29 848 KB	
-- data: 7 680 KB
-- index size: 21 952 KB
EXEC sp_spaceused 'DemoJson.OrderDocs_Json_Indexed'



-- JSON Index Seek + Clustered Index Scan ??
-- OrderDocs_Json_Indexed reads: 965, json_index_ reads: 9 
SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_VALUE(OrderDoc, '$.Items[9].ProductID') = 744

-- JSON Index Seek + Clustered Index Seek
-- -- OrderDocs_Json_Indexed reads: 45, json_index_ reads: 182
SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_CONTAINS(OrderDoc, 744, '$.Items[*].ProductID') = 1

/*
        '$.Items' + OPTIMIZE_FOR_ARRAY_SEARCH = ON
*/

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

-- reserved: 40 736 KB	
-- data: 7 680 KB
-- index size: 32 760 KB
EXEC sp_spaceused 'DemoJson.OrderDocs_Json_Indexed'






-- JSON Index Seek + Clustered Index Scan ??
-- OrderDocs_Json_Indexed reads: 965, json_index_ reads: 9 
SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_VALUE(OrderDoc, '$.Items[9].ProductID') = 744

-- JSON Index Seek + Clustered Index Seek
-- -- OrderDocs_Json_Indexed reads: 39, json_index_ reads: 4
SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_CONTAINS(OrderDoc, 744, '$.Items[*].ProductID') = 1






