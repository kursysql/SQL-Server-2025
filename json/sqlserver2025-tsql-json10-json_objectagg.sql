/*

    TSQL: JSON_OBJECTAGG
    Tomasz Libera | MVP Data Platform
    libera@kursysql.pl

    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL
    https://github.com/kursysql/SQL-Server-2025/

    Funkcja JSON_OBJECTAGG
    buduje obiekt JSON z agregacji danych SQL lub kolumn

    Składnia:
    JSON_OBJECTAGG ( json_key : value_expression [ NULL ON NULL | ABSENT ON NULL ] )

    Uwaga:
    - JSON_OBJECTAGG buduje obiekt JSON z wielu wierszy (z agregacji danych SQL)
    - dobrze nadaje się do agregacji danych do postaci key:value
    - można używać z GROUP BY
    - SQL Server 2025+

    1. Zacznijmy od prostego przykładu
    2. JSON_OBJECT vs JSON_OBJECTAGG — statyczne vs dynamiczne klucze
    3. JSON_OBJECTAGG + JSON_OBJECT — zagnieżdżanie obiektów JSON
    4. NULL ON NULL vs ABSENT ON NULL
    5. RETURNING json w SQL Server 2025

    Dokumentacja:
    https://learn.microsoft.com/en-us/sql/t-sql/functions/json-objectagg-transact-sql?view=sql-server-ver17

*/

USE AdventureWorks2025
GO



/*
    -------------------------------------------------------------------
    1. Zacznijmy od prostego przykładu
    - z kilku wierszy budujemy jeden obiekt JSON
    -------------------------------------------------------------------
*/

-- ! The JSON_OBJECTAGG function requires 1 argument(s)
-- w przeciwieństwie do JSON_OBJECT, JSON_OBJECTAGG wymaga podania co najmniej jednej pary klucz:wartość
SELECT JSON_OBJECTAGG();



-- zwraca obekt z jedną parą klucz:wartość
-- (to nie jest typowy sposób użycia tej funkcji)
SELECT JSON_OBJECTAGG('OrderID' : 43659);



-- funkcja JSON_OBJECTAGG jest agregatorem, 
-- więc musi być użyta w kontekście agregacji danych SQL
SELECT JSON_OBJECTAGG(k : v) AS SimpleObject
FROM (VALUES
    ('OrderID', '43659'),
    ('OrderDate', '2022-05-30T00:00:00'),
    ('Status', '5'), 
    ('OnlineOrder', 'false') 
) AS source(k, v);
GO


/*
    -------------------------------------------------------------------
    2. JSON_OBJECT vs JSON_OBJECTAGG — statyczne vs dynamiczne klucze
        - JSON_OBJECT wymaga ręcznego podania nazw kluczy
        - JSON_OBJECTAGG pozwala budować klucze dynamicznie z danych
    -------------------------------------------------------------------
*/

-- JSON_OBJECT - musisz znać klucze z góry
SELECT JSON_OBJECT(
    'OrderID': 43659, 
    'OrderDate': '2022-05-30T00:00:00', 
    'Status': 5, 
    'OnlineOrderFlag': 'false'
) AS StaticJson




-- #TempOrders
-- jeden wiersz = jedna para klucz:wartość
-- dzięki temu nazwy kluczy i ich wartości będą pochodziły bezpośrednio z danych

DROP TABLE IF EXISTS #TempOrders

CREATE TABLE #TempOrders
(
    SalesOrderID int,
    Col_Name nvarchar(100),
    Col_Value nvarchar(100)
);

INSERT INTO #TempOrders (SalesOrderID, Col_Name, Col_Value)
SELECT TOP 100 SalesOrderID, 'SalesOrderID', CONVERT(nvarchar(10), SalesOrderID, 120) 
FROM Sales.SalesOrderHeader
UNION
SELECT TOP 100 SalesOrderID, 'OrderDate', CONVERT(nvarchar(10), OrderDate, 120) 
FROM Sales.SalesOrderHeader
UNION
SELECT TOP 100 SalesOrderID, 'Status', CAST(Status AS nvarchar(100)) 
FROM Sales.SalesOrderHeader
UNION
SELECT TOP 100 SalesOrderID, 'OnlineOrderFlag', CAST(OnlineOrderFlag AS nvarchar(100)) 
FROM Sales.SalesOrderHeader

SELECT * FROM #TempOrders ORDER BY SalesOrderID



-- nazwy kluczy mogę wziąć z kolumny, 
-- więc obiekt JSON buduje się dynamicznie na podstawie danych
SELECT JSON_OBJECTAGG(Col_Name : Col_Value) AS GeneratedJson
FROM #TempOrders

/*
{
  "OnlineOrderFlag": "0",
  "OrderDate": "2022-05-30",
  "SalesOrderID": "43659",
  "Status": "5",
  "OnlineOrderFlag": "0",
  "OrderDate": "2022-05-30",
  "SalesOrderID": "43660",
  "Status": "5",
  "OnlineOrderFlag": "0",
  "OrderDate": "2022-05-30",
  "SalesOrderID": "43661",
  "Status": "5",
  ...
}
*/


-- jeśli chcemy budować osobny obiekt JSON dla każdego zamówienia,
-- grupujemy dane po SalesOrderID - klucze są nadal dynamiczne i pochodzą z danych
SELECT 
    SalesOrderID, 
    JSON_OBJECTAGG(Col_Name : Col_Value) AS GeneratedJson
FROM #TempOrders
GROUP BY SalesOrderID





/*
    -------------------------------------------------------------------
    3. JSON_OBJECTAGG + JSON_OBJECT
     - wartością w JSON_OBJECTAGG nie musi być scalar
     - może nią być także cały obiekt zbudowany przez JSON_OBJECT
    -------------------------------------------------------------------
*/

-- jeden klucz:wartość dla każdego wiersza, ale wartością jest cały obiekt JSON z danymi o zamówieniu
SELECT 
    JSON_OBJECTAGG(
        SalesOrderID:Status
    ) AS OrdersByStatus
FROM Sales.SalesOrderHeader
WHERE SalesOrderID BETWEEN 43659 AND 43670;


-- jak dodać dwa pola do wartości w JSON_OBJECTAGG?
-- The JSON_OBJECTAGG function requires 1 argument(s).
-- JSON_OBJECTAGG przyjmuje tylko jedną parę klucz:wartość, więc...
SELECT 
    JSON_OBJECTAGG(
        SalesOrderID:Status, 
        SalesOrderID:OrderDate
    ) AS OrdersByStatusAndDate
FROM Sales.SalesOrderHeader
WHERE SalesOrderID BETWEEN 43659 AND 43670;


-- zagnieżdżony JSON_OBJECT wewnątrz JSON_OBJECTAGG, 
-- aby dodać więcej danych do wartości
SELECT JSON_OBJECTAGG(
    SalesOrderID:JSON_OBJECT(
        'OrderID':SalesOrderID,
        'OrderDate':OrderDate,
        'Status':Status,
        'OnlineOrderFlag':OnlineOrderFlag
    )
) AS OrdersObject
FROM Sales.SalesOrderHeader
WHERE SalesOrderID BETWEEN 43659 AND 43670



/*
    -------------------------------------------------------------------
    4. NULL ON NULL vs ABSENT ON NULL
      domyślnie, jeśli NULL, to właściwość zostaje w obiekcie z wartością null
    -------------------------------------------------------------------
*/


SELECT 
    JSON_OBJECTAGG(
        ProductID : Color
     ) AS ProductColors
FROM Production.Product
WHERE ProductID IN (1, 316, 317, 792);
GO

-- NULL ON NULL (domyślnie) - właściwość zostaje w obiekcie z wartością null
SELECT 
    JSON_OBJECTAGG(
        ProductID : Color 
        NULL ON NULL
    ) AS ProductColors
FROM Production.Product
WHERE ProductID IN (1, 316, 317, 792);
GO

-- ABSENT ON NULL - właściwość z wartością NULL jest pomijana
SELECT 
    JSON_OBJECTAGG(
        ProductID : Color 
        ABSENT ON NULL
    ) AS ProductColors
FROM Production.Product
WHERE ProductID IN (1, 316, 317, 792);
GO





/*
    -------------------------------------------------------------------
    5. RETURNING 
    - wynik można zwrócić jako typ json
    -------------------------------------------------------------------
*/


DROP TABLE IF EXISTS DemoJson.JsonObjectExample1;
DROP TABLE IF EXISTS DemoJson.JsonObjectExample2;


SELECT 
    JSON_OBJECTAGG(
        ProductID : Color 
    ) AS ProductColors
INTO DemoJson.JsonObjectExample1
FROM Production.Product
WHERE ProductID IN (1, 316, 317, 792);
GO



SELECT 
    JSON_OBJECTAGG(
        ProductID : Color 
        RETURNING JSON
    ) AS ProductColors
INTO DemoJson.JsonObjectExample2
FROM Production.Product
WHERE ProductID IN (1, 316, 317, 792);
GO




DROP TABLE IF EXISTS DemoJson.JsonObjectExample1;
DROP TABLE IF EXISTS DemoJson.JsonObjectExample2;
