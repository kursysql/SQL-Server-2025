/*

    SQL Server 2025: Indeksy JSON

    Tomasz Libera | MVP Data Platform
    libera@kursysql.pl

    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL
    https://github.com/kursysql/SQL-Server-2025/


*/

USE AdventureWorks2025
GO

SET STATISTICS IO ON


/*    
    1. Twozenie indeksu JSON
*/






/*    
    1. Twozenie indeksu JSON
*/




/*    
    X. Struktura wewnętrzna indkesu
*/


SELECT * FROM DemoJson.OrderDocs_Json_Indexed



SELECT  s.session_id
FROM    sys.tcp_endpoints AS E
        INNER JOIN sys.dm_exec_sessions AS S ON E.endpoint_id = S.endpoint_id
WHERE   E.name = 'Dedicated Admin Connection';



DROP INDEX IF EXISTS IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed

CREATE JSON INDEX IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed (OrderDoc)
FOR
(
    '$.SalesPersonID'
)


SELECT * FROM sys.objects WHERE type = 'IT' ORDER BY create_date DESC

SELECT * FROM sys.json_index_1232723444_1216000





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


SELECT * FROM sys.json_index_1232723444_1216000

