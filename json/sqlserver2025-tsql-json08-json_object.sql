/*

    TSQL: JSON_OBJECT
    Tomasz Libera | MVP Data Platform
    libera@kursysql.pl

    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL
    https://github.com/kursysql/SQL-Server-2025/

    Funkcja JSON_OBJECT
    buduje obiekt JSON z par klucz:wartość

    Składnia:
    JSON_OBJECT ( [ json_key_value [ , ...n ] ] [ json_null_clause ] [ RETURNING json ] )

    Uwaga:
    - JSON_OBJECT tworzy tekst obiektu JSON z par klucz:wartość
    - domyślnie zwraca nvarchar(max)
    - opcja RETURNING json zwraca wynik jako typ json
    - można zagnieżdżać JSON_OBJECT i JSON_ARRAY
    - można kontrolować obsługę wartości NULL:
      NULL ON NULL / ABSENT ON NULL

    1. Prosty obiekt JSON
    2. NULL ON NULL vs ABSENT ON NULL
    3. Zmienne i wyrażenia SQL
    4. Obiekt JSON z danych z tabeli
    5. Zagnieżdżanie JSON_OBJECT i JSON_ARRAY
    6. RETURNING json w SQL Server 2025

    Dokumentacja:
    https://learn.microsoft.com/en-us/sql/t-sql/functions/json-object-transact-sql?view=sql-server-ver17

*/

USE AdventureWorks2025
GO


/*
    -------------------------------------------------------------------
    1. Prosty obiekt JSON
    - JSON_OBJECT tworzy obiekt JSON
    - można podać zero, jedną albo wiele par klucz:wartość
    -------------------------------------------------------------------
*/

SELECT JSON_OBJECT() AS EmptyObject;
GO

SELECT JSON_OBJECT('name':'value', 'type':1) AS SimpleObject;
GO

SELECT JSON_OBJECT(
  'OrderID':43659,
  'OrderDate':'2022-05-30T00:00:00',
  'Status':5,
  'OnlineOrder':CAST(0 AS bit), -- jawna konwersja do boolean
  'SalesPersonID':279
) AS OrderDoc;
GO

-- zwraca nvarchar(max) (domyślnie)
SELECT JSON_OBJECT(
  'OrderID':43659,
  'OrderDate':'2022-05-30T00:00:00',
  'Status':5,
  'OnlineOrder':CAST(0 AS bit), -- jawna konwersja do boolean
  'SalesPersonID':279
) AS OrderDoc
INTO DemoJson.JsonObjectExample
GO

DROP TABLE IF EXISTS DemoJson.JsonObjectExample



/*
    -------------------------------------------------------------------
    2. NULL ON NULL vs ABSENT ON NULL
    - można zdecydować, co zrobić z wartościami NULL
    - NULL ON NULL = klucz zostaje z wartością null
    - ABSENT ON NULL = klucz jest pomijany
    -------------------------------------------------------------------
*/


SELECT JSON_OBJECT(
  'OrderID':43659,
  'OrderDate':'2022-05-30T00:00:00',
  'Status':NULL,
  'OnlineOrder':CAST(0 AS bit),
  'SalesPersonID':NULL 
) AS OrderDoc_Null;
GO


-- NULL ON NULL (domyślnie)
SELECT JSON_OBJECT(
  'OrderID':43659,
  'OrderDate':'2022-05-30T00:00:00',
  'Status':NULL,
  'OnlineOrder':CAST(0 AS bit),
  'SalesPersonID':NULL 
  NULL ON NULL
) AS OrderDoc_NullOnNull;
GO


-- ABSENT ON NULL
SELECT JSON_OBJECT(
  'OrderID':43659,
  'OrderDate':'2022-05-30T00:00:00',
  'Status':NULL,
  'OnlineOrder':CAST(0 AS bit),
  'SalesPersonID':NULL 
  ABSENT ON NULL
) AS OrderDoc_AbsentOnNull;
GO



/*
    -------------------------------------------------------------------
    3. Zmienne i wyrażenia SQL
    - klucze i wartości mogą pochodzić ze zmiennych albo wyrażeń SQL
    -------------------------------------------------------------------
*/

DECLARE @id_key   nvarchar(20) = N'id';
DECLARE @id_value nvarchar(50) = CONVERT(nvarchar(50), NEWID());

SELECT JSON_OBJECT(
    'user_name':USER_NAME(),
    @id_key:@id_value,
    'spid':@@SPID,
    'current date':GETDATE()
) AS ObjectFromExpressions;
GO


/*
    -------------------------------------------------------------------
    4. Obiekt JSON z danych z tabeli
    - budowanie prostego obiektu JSON na podstawie kolumn
    -------------------------------------------------------------------
*/

SELECT TOP 5
    SalesOrderID,
    OrderDate,
    Status,
    OnlineOrderFlag,
    JSON_OBJECT(
       'OrderID':SalesOrderID,
       'OrderDate':OrderDate,
       'Status':Status,
       'OnlineOrder':OnlineOrderFlag
    ) AS OrderHeaderJson
FROM Sales.SalesOrderHeader
ORDER BY SalesOrderID;
GO

-- porównanie
SELECT TOP (5)
    OrderID,
    OrderDoc
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;
GO




/*
    -------------------------------------------------------------------
    5. Zagnieżdżanie JSON_OBJECT i JSON_ARRAY
    - można budować bardziej złożone struktury JSON
    - JSON_ARRAY i JSON_OBJECT można ze sobą łączyć
    -------------------------------------------------------------------
*/



-- porównanie - customer
SELECT TOP (5)
    OrderID,
    OrderDoc
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;
GO


SELECT TOP 5
    SalesOrderID,
    JSON_OBJECT(
       'OrderID':SalesOrderID,
       'OrderDate':OrderDate,
       'Status':Status,
       'OnlineOrder':OnlineOrderFlag,
       'SalesPersonID':SalesPersonID,
       'CustomerID':CustomerID,
       'AccountNumber':AccountNumber
    ) AS OrderHeaderJson
FROM Sales.SalesOrderHeader
ORDER BY SalesOrderID;
GO



-- zagnieżdżony obiekt Customer
SELECT TOP 5
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
       )
    ) AS OrderHeaderJson
FROM Sales.SalesOrderHeader
ORDER BY SalesOrderID;
GO

-- tablica Items (więcej o JSON_ARRAY w kolejnym demo)
SELECT TOP 5
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

-- porównanie - customer
SELECT TOP (5)
    OrderID,
    OrderDoc
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;
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



SELECT TOP 5
    SalesOrderID,
    JSON_OBJECT(
       'OrderID':SalesOrderID,
       'OrderDate':OrderDate,
       'Status':Status,
       'OnlineOrder':OnlineOrderFlag,
       'SalesPersonID':SalesPersonID,
       'CustomerID':CustomerID,
       'AccountNumber':AccountNumber
    ) AS OrderHeaderJson
INTO DemoJson.JsonObjectExample1
FROM Sales.SalesOrderHeader
ORDER BY SalesOrderID;
GO


SELECT TOP 5
    SalesOrderID,
    JSON_OBJECT(
       'OrderID':SalesOrderID,
       'OrderDate':OrderDate,
       'Status':Status,
       'OnlineOrder':OnlineOrderFlag,
       'SalesPersonID':SalesPersonID,
       'CustomerID':CustomerID,
       'AccountNumber':AccountNumber
       RETURNING json
    ) AS OrderHeaderJson
INTO DemoJson.JsonObjectExample2
FROM Sales.SalesOrderHeader
ORDER BY SalesOrderID;
GO

DROP TABLE IF EXISTS DemoJson.JsonObjectExample1;
DROP TABLE IF EXISTS DemoJson.JsonObjectExample2;



