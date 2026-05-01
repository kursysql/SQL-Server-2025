/*

    TSQL: JSON_ARRAY
    Tomasz Libera | MVP Data Platform
    libera@kursysql.pl

    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL
    https://github.com/kursysql/SQL-Server-2025/

    Funkcja JSON_ARRAY
    buduje tablicę JSON z wartości SQL

    Składnia:
    JSON_ARRAY ( [ value_expression [ , ...n ] ] [ NULL ON NULL | ABSENT ON NULL ] [ RETURNING json ] )

    Uwaga:
    - JSON_ARRAY tworzy tekst tablicy JSON z zera lub większej liczby wyrażeń
    - domyślnie zwraca nvarchar(max)
    - opcja RETURNING json zwraca wynik jako typ json
    - można zagnieżdżać JSON_ARRAY i JSON_OBJECT
    - można kontrolować obsługę wartości NULL:
      NULL ON NULL / ABSENT ON NULL

    1. Prosta tablica JSON
    2. NULL ON NULL vs ABSENT ON NULL
    3. Zmienne i wyrażenia SQL
    4. Tablica JSON z danych z tabeli
    5. Zagnieżdżanie JSON_ARRAY i JSON_OBJECT
    6. RETURNING json w SQL Server 2025


    Dokumentacja:
    https://learn.microsoft.com/en-us/sql/t-sql/functions/json-array-transact-sql?view=sql-server-ver17

*/

USE AdventureWorks2025
GO


/*
    -------------------------------------------------------------------
    1. Prosta tablica JSON
    - JSON_ARRAY tworzy tablicę JSON
    - można podać zero, jedną albo wiele wartości
    -------------------------------------------------------------------
*/

SELECT JSON_ARRAY() AS EmptyArray;
GO

SELECT JSON_ARRAY(1, 2, 3) AS SimpleArray;
GO

SELECT JSON_ARRAY('sql', 'json', 'sqlserver') AS StringArray;
GO


/*
    -------------------------------------------------------------------
    2. NULL ON NULL vs ABSENT ON NULL
    - można zdecydować, co zrobić z wartościami NULL
    - NULL ON NULL = element null zostaje w tablicy
    - ABSENT ON NULL = element jest pomijany
    -------------------------------------------------------------------
*/

SELECT JSON_ARRAY('a', 1, NULL, 2) AS Default_Array;


SELECT JSON_ARRAY('a', 1, NULL, 2 NULL ON NULL) AS NullOnNull_Array;


SELECT JSON_ARRAY('a', 1, NULL, 2 ABSENT ON NULL) AS AbsentOnNull_Array;
GO


-- pomijanie wartości opcjonalnych
SELECT TOP (5)
    t.OrderID,
    JSON_ARRAY(
        t.OrderID,
        JSON_VALUE(t.OrderDoc, '$.PromoCode') ABSENT ON NULL
    ) AS ArrayWithoutMissingPromo,
    JSON_ARRAY(
        t.OrderID,
        JSON_VALUE(t.OrderDoc, '$.PromoCode') NULL ON NULL
    ) AS ArrayWithNullPromo,
    JSON_ARRAY(
        t.OrderID,
        JSON_VALUE(t.OrderDoc, '$.PromoCode')
    ) AS ArrayWithNullPromo
FROM DemoJson.OrderDocs_Text AS t
ORDER BY t.OrderID;
GO




/*
    -------------------------------------------------------------------
    3. Zmienne i wyrażenia SQL
    - wartości mogą pochodzić ze zmiennych albo wyrażeń SQL
    -------------------------------------------------------------------
*/

DECLARE @tag1 nvarchar(20) = N'json';
DECLARE @tag2 nvarchar(20) = N'sqlserver';

SELECT JSON_ARRAY(
    USER_NAME(),
    @@SPID,
    @tag1,
    @tag2,
    YEAR(GETDATE()),
    @@SERVERNAME
) AS ArrayFromExpressions;
GO


/*
    -------------------------------------------------------------------
    4. Tablica JSON z danych z tabeli
    - budowanie lekkiej tablicy JSON na podstawie kolumn
    -------------------------------------------------------------------
*/

SELECT TOP (5)
    OrderID,
    JSON_ARRAY(
        OrderID,
        JSON_VALUE(OrderDoc, '$.OrderDate'),
        JSON_VALUE(OrderDoc, '$.Status')
    ) AS OrderSummaryArray
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;
GO


/*
    -------------------------------------------------------------------
    5. Zagnieżdżanie JSON_ARRAY i JSON_OBJECT
    - można łączyć JSON_ARRAY z JSON_OBJECT i innymi tablicami
    -------------------------------------------------------------------
*/

SELECT JSON_ARRAY(
    'name',
    JSON_OBJECT('type_id':1, 'type_name':'a'),
    JSON_ARRAY(1, 2, 3)
) AS MixedNestedArray;
GO

SELECT JSON_ARRAY(
    JSON_OBJECT('ProductID':709, 'Name':'Mountain Bike Socks, M', 'Qty':6),
    JSON_OBJECT('ProductID':776, 'Name':'Mountain-100 Black, 42', 'Qty':2)
) AS ItemsArray;
GO


-- składanie JSON z danych z tabeli, zagnieżdżając JSON_ARRAY i JSON_VALUE
SELECT TOP (5)
    t.OrderID,
    JSON_ARRAY(
        t.OrderID,
        JSON_VALUE(t.OrderDoc, '$.OrderDate'),
        JSON_PATH_EXISTS(t.OrderDoc, '$.Items'),
        JSON_VALUE(t.OrderDoc, '$.Items[0].Name')
    ) AS OrderSummaryArray
FROM DemoJson.OrderDocs_Text AS t
ORDER BY t.OrderID;
GO

-- (przykład z demo JSON_OBJECT) 
-- tablica Items 
SELECT 
    SalesOrderID,
    JSON_OBJECT(
       'OrderID':SalesOrderID,
       'OrderDate':OrderDate,
       'Status':Status,
       'OnlineOrder':OnlineOrderFlag,
       'SalesPersonID':SalesPersonID,
       'Customer':JSON_OBJECT(
            'CustomerID':CustomerID,
            'AccountNumber':AccountNumber
       ),
       'Items':JSON_ARRAY(
            JSON_OBJECT('ProductID':1, 'UnitPrice':10.0, 'Quantity':2),
            JSON_OBJECT('ProductID':2, 'UnitPrice':20.0, 'Quantity':1)
       )
    ) AS OrderHeaderJson
FROM Sales.SalesOrderHeader
ORDER BY SalesOrderID;
GO


-- zagnieżdżanie JSON_ARRAY z podzapytaniem FOR JSON PATH 
-- - to jest bardzo praktyczne do budowania tablicy z danych z tabeli
-- 1. Podzapytanie pobiera pozycje dla każdego zamówienia
-- 2. FOR JSON PATH formatuje je jako tablicę JSON
-- 3. JSON_QUERY wstawia tę tablicę do głównego obiektu JSON
-- 4. WHERE w podzapytaniu łączy SalesOrderDetail z SalesOrderHeader po SalesOrderID

SELECT 
    h.SalesOrderID,
    JSON_OBJECT(
       'OrderID': h.SalesOrderID,
       'OrderDate': h.OrderDate,
       'Status': h.Status,
       'OnlineOrder': CAST(h.OnlineOrderFlag AS bit),
       'SalesPersonID': h.SalesPersonID,
       'Customer': JSON_OBJECT(
            'CustomerID': h.CustomerID,
            'AccountNumber': h.AccountNumber
       ),
       'Items': JSON_QUERY(
           (SELECT 
                d.ProductID,
                d.UnitPrice,
                d.OrderQty AS Quantity
            FROM Sales.SalesOrderDetail d
            WHERE d.SalesOrderID = h.SalesOrderID
            FOR JSON PATH)
       )
    ) AS OrderHeaderJson
FROM Sales.SalesOrderHeader h
ORDER BY h.SalesOrderID;
GO


-- JSON_ARRAY w podzapytaniu sie nie uda, bo nie akceptuje subquery zwracającego wiele wierszy. 
-- Przyjmuje tylko listę wartości rozdzielonych przecinkami.

-- Subquery returned more than 1 value. This is not permitted when the subquery follows =, !=, <, <= , >, >= 
SELECT 
    h.SalesOrderID,
    JSON_OBJECT(
    'Items': JSON_ARRAY(
        (SELECT JSON_OBJECT('ProductID': ProductID, 'Qty': OrderQty)
         FROM Sales.SalesOrderDetail
         WHERE SalesOrderID = h.SalesOrderID)
    ))
FROM Sales.SalesOrderHeader h
ORDER BY h.SalesOrderID;
GO




/*
    -------------------------------------------------------------------
    6. RETURNING json w SQL Server 2025
    - wynik można zwrócić jako typ json
    - to ma sens szczególnie w SQL Server 2025
    -------------------------------------------------------------------
*/


DROP TABLE IF EXISTS DemoJson.JsonObjectExample1;
DROP TABLE IF EXISTS DemoJson.JsonObjectExample2;



SELECT JSON_ARRAY(
    JSON_OBJECT('ProductID':709, 'Name':'Mountain Bike Socks, M', 'Qty':6),
    JSON_OBJECT('ProductID':776, 'Name':'Mountain-100 Black, 42', 'Qty':2)
) AS ItemsArray
INTO DemoJson.JsonObjectExample1
GO



SELECT JSON_ARRAY(
    JSON_OBJECT('ProductID':709, 'Name':'Mountain Bike Socks, M', 'Qty':6),
    JSON_OBJECT('ProductID':776, 'Name':'Mountain-100 Black, 42', 'Qty':2)
    RETURNING json
) AS ItemsArray
INTO DemoJson.JsonObjectExample2
GO


DROP TABLE IF EXISTS DemoJson.JsonObjectExample1;
DROP TABLE IF EXISTS DemoJson.JsonObjectExample2;


