/*

    SQL Server 2025: Indeksy JSON - użycie w zapytaniach
    - wersja AzureSQL Database

    Tomasz Libera | MVP Data Platform
    libera@kursysql.pl

    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL
    https://github.com/kursysql/SQL-Server-2025/

    2. Indeks z obiektem Shipping
    3. Indeks z pojedynczą ścieżką do obiektu JSON - np. Shipping.City
    4. Weźmy inną ścieżkę - OrderDate - i zobaczmy, czy indeks JSON będzie użyty dla JSON_VALUE
    5. Dwie ścieżki w indeksie JSON - SalesPersonID i Shipping.City
    6. Optymalizacja dla wyszukiwania w tablicach 


*/



SET STATISTICS IO ON





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




-- 
SELECT *
FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_VALUE(OrderDoc, '$.Shipping.City') = 'Denver';




--> json24-perf-json_sql25cu4.sql






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
-- JSON Index Seek + Clustered Index Scan
-- OrderDocs_Json_Indexed reads: 965
-- json_index_ reads: 44
SELECT *
FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_VALUE(OrderDoc, '$.Shipping.City') = 'Denver';


-- JSON Index Seek + Clustered Index Seek
-- json_index_ reads: 3 | OrderDocs_Json_Indexed reads: 15
SELECT *
FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_CONTAINS(OrderDoc, 'Denver', '$.Shipping.City') = 1;







--> json24-perf-json_sql25cu4.sql




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




-- JSON Index Seek + Clustered Index Scan 
SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_VALUE(OrderDoc, '$.OrderDate') = '2022-08-19T00:00:00'


-- JSON Index Seek + Clustered Index Seek
SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_CONTAINS(OrderDoc, '2022-08-19T00:00:00', '$.OrderDate') = 1




--> json24-perf-json_sql25cu4.sql








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




-- SQL25: Clustered Index Scan
-- JSON Index Seek + Clustered Index Scan
SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_VALUE(OrderDoc, '$.SalesPersonID') = 287

-- JSON Index Seek + Clustered Index Seek
-- (tak samo jak w SQL25)
SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_CONTAINS(OrderDoc, 287, '$.SalesPersonID') = 1






-- SQL25: Clustered Index Scan
-- JSON Index Seek + Clustered Index Scan
SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_VALUE(OrderDoc, '$.Shipping.City') = 'Denver'

-- JSON Index Seek + Clustered Index Seek
-- (tak samo jak w SQL25)
SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_CONTAINS(OrderDoc, 'Denver', '$.Shipping.City') = 1





-- JSON Index Seek x 2 + Clustered Index Seek
-- (tak samo jak w SQL25)
SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_VALUE(OrderDoc, '$.SalesPersonID') = 276 AND JSON_VALUE(OrderDoc, '$.Shipping.City') = 'Denver'

-- JSON Index Seek x 2 + Clustered Index Seek
-- (tak samo jak w SQL25)
SELECT * FROM DemoJson.OrderDocs_Json_Indexed
WHERE JSON_CONTAINS(OrderDoc, 276, '$.SalesPersonID') = 1 AND JSON_CONTAINS(OrderDoc, 'Denver', '$.Shipping.City') = 1






--> json24-perf-json_sql25cu4.sql








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




