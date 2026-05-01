/*

    TSQL: JSON_ARRAYAGG
    Tomasz Libera | MVP Data Platform
    libera@kursysql.pl

    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL
    https://github.com/kursysql/SQL-Server-2025/

    Funkcja JSON_ARRAYAGG
    buduje tablicę JSON z agregacji danych SQL lub kolumn

    Składnia:
    JSON_ARRAYAGG ( value_expression [ ORDER BY <column_list> ] [ NULL ON NULL | ABSENT ON NULL ] )

    Uwaga:
    - JSON_ARRAYAGG buduje tablicę JSON z wielu wierszy
    - dobrze nadaje się do agregowania list wartości
    - można używać z GROUP BY
    - można sterować kolejnością elementów przez ORDER BY
    - SQL Server 2025+

    1. Zacznijmy od prostego przykładu
    2. Tablica wartości i tablica obiektów JSON
    3. Kolejność elementów i tablica na grupę
    4. Zagnieżdżona tablica bez FOR JSON PATH
    5. NULL ON NULL vs ABSENT ON NULL
    6. RETURNING json w SQL Server 2025

    Dokumentacja:
    https://learn.microsoft.com/en-us/sql/t-sql/functions/json-arrayagg-transact-sql?view=sql-server-ver17

*/

USE AdventureWorks2025
GO


/*
    -------------------------------------------------------------------
    1. Zacznijmy od prostego przykładu
    - JSON_OBJECTAGG buduje jeden obiekt JSON z wielu wierszy
    - najczęściej używamy go do agregacji danych do postaci key:value
    -------------------------------------------------------------------
*/

-- ! The JSON_ARRAYAGG function requires 1 argument(s).
-- podobnie jak JSON_OBJECTAGG, funkcja JSON_ARRAYAGG wymaga podania argumentu, 
-- którym jest wartość do agregacji
SELECT JSON_ARRAYAGG()


-- tablica z jedną kolumną, tablica stringów
SELECT JSON_ARRAYAGG(source.v) AS SimpleArray
FROM (VALUES
    ('sql'),
    ('json'),
    ('sqlserver')
) AS source(v);
GO





/*
    -------------------------------------------------------------------
    2. Tablica wartości i tablica obiektów JSON
      - JSON_ARRAYAGG może budować nie tylko tablicę prostych wartości
      - może też agregować obiekty JSON
    -------------------------------------------------------------------
*/

-- tablica liczb
SELECT JSON_ARRAYAGG(source.v) AS NumericArray
FROM (VALUES
    (43672),
    (5),
    (3)
) AS source(v);
GO

-- tablica obiektów JSON, każdy element ma dwie właściwości
-- tablica obiektów JSON, każdy element opisuje produkt
SELECT JSON_ARRAYAGG(
           JSON_OBJECT(
               'ProductID': source.ProductID,
               'Name': source.Name
           )
       ) AS ProductsArray
FROM (VALUES
    (709, 'Mountain Bike Socks, M'),
    (776, 'Mountain-100 Black, 42'),
    (774, 'Mountain-100 Silver, 48')
) AS source(ProductID, Name);
GO


-- tablica z danych z tabeli
SELECT JSON_ARRAYAGG(h.SalesOrderID) AS OrdersArray
FROM Sales.SalesOrderHeader AS h
WHERE h.SalesOrderID BETWEEN 43659 AND 43670;
GO


/*
    -------------------------------------------------------------------
    3. Kolejność elementów i tablica na grupę
      - ORDER BY pozwala sterować kolejnością elementów w tablicy
      - GROUP BY pozwala budować osobną tablicę dla każdej grupy
    -------------------------------------------------------------------
*/

SELECT JSON_ARRAYAGG(v ORDER BY sort_id) AS OrderedArray
FROM (VALUES
    (3, 'third'),
    (1, 'first'),
    (2, 'second')
) AS source(sort_id, v);
GO

SELECT JSON_ARRAYAGG(v ORDER BY sort_id DESC) AS OrderedArray
FROM (VALUES
    (3, 'third'),
    (1, 'first'),
    (2, 'second')
) AS source(sort_id, v);
GO




SELECT JSON_ARRAYAGG(SalesOrderID ORDER BY OrderDate) AS OrdersArray
FROM Sales.SalesOrderHeader
WHERE SalesOrderID BETWEEN 43659 AND 43670;
GO


-- dla każdej daty zamówienia budujemy tablicę z ID zamówień z tej daty
-- dzięki ORDER BY w JSON_ARRAYAGG, ID zamówień w tablicy będą posortowane rosnąco
SELECT
    OrderDate,
    JSON_ARRAYAGG(SalesOrderID ORDER BY SalesOrderID) AS OrdersArray
FROM Sales.SalesOrderHeader
GROUP BY OrderDate
ORDER BY OrderDate;
GO

-- dla każdego zamówienia budujemy tablicę z ID produktów 
SELECT
    SalesOrderID,
    JSON_ARRAYAGG(ProductID ORDER BY ProductID) AS ProductsArray
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
ORDER BY SalesOrderID;
GO


-- dla każdego zamówienia budujemy tablicę z nazwami produktów 
SELECT
    SalesOrderID,
    JSON_ARRAYAGG(Name ORDER BY Name) AS ProductsArray
FROM Sales.SalesOrderDetail
JOIN Production.Product ON Sales.SalesOrderDetail.ProductID = Production.Product.ProductID
GROUP BY SalesOrderID
ORDER BY SalesOrderID;
GO



/*
    -------------------------------------------------------------------
    4. Zagnieżdżona tablica bez FOR JSON PATH
    - JSON_ARRAY nie przyjmuje wielowierszowego podzapytania
    - JSON_ARRAYAGG pozwala zbudować tablicę Items bez FOR JSON PATH
    -------------------------------------------------------------------
*/


-- problem z demonstracji JSON_ARRAY 
-- - nie akceptuje subquery zwracającego wiele wierszy,

-- ! Subquery returned more than 1 value...
SELECT 
    h.SalesOrderID,
    JSON_OBJECT(
        'Items': JSON_ARRAY(
            (SELECT JSON_OBJECT(
                        'ProductID': d.ProductID,
                        'Qty': d.OrderQty
                    )
             FROM Sales.SalesOrderDetail AS d
             WHERE d.SalesOrderID = h.SalesOrderID)
        )
    ) AS OrderJson
FROM Sales.SalesOrderHeader AS h
WHERE h.SalesOrderID = 43659;
GO

-- zagnieżdżony JSON_ARRAYAGG w JSON_OBJECT, bez problemu agreguje wiele wierszy z podzapytania
SELECT 
    h.SalesOrderID,
    JSON_OBJECT(
        'OrderID': h.SalesOrderID,
        'Items': (
            SELECT JSON_ARRAYAGG(
                       JSON_OBJECT(
                           'ProductID': d.ProductID,
                           'Qty': d.OrderQty
                       )
                   )
            FROM Sales.SalesOrderDetail AS d
            WHERE d.SalesOrderID = h.SalesOrderID
        )
    ) AS OrderJson
FROM Sales.SalesOrderHeader AS h
WHERE SalesOrderID BETWEEN 43659 AND 43670;
GO






/*
    -------------------------------------------------------------------
    5. NULL ON NULL vs ABSENT ON NULL
      domyślnie JSON_ARRAYAGG działa z ABSENT ON NULL dla samej agregacji,
    -------------------------------------------------------------------
*/



SELECT JSON_ARRAYAGG(Color) AS ProductColors
FROM Production.Product
WHERE ProductID IN (1, 316, 317, 792);
GO


-- NULL ON NULL - element null zostaje w tablicy
SELECT JSON_ARRAYAGG(Color NULL ON NULL) AS ProductColors
FROM Production.Product
WHERE ProductID IN (1, 316, 317, 792);
GO


-- ABSENT ON NULL (domyślnie) - element z NULL jest pomijany
SELECT JSON_ARRAYAGG(Color ABSENT ON NULL) AS ProductColors
FROM Production.Product
WHERE ProductID IN (1, 316, 317, 792);
GO



/*
    -------------------------------------------------------------------
    6. RETURNING 
    - wynik można zwrócić jako typ json
    -------------------------------------------------------------------
*/



DROP TABLE IF EXISTS DemoJson.JsonObjectExample1;
DROP TABLE IF EXISTS DemoJson.JsonObjectExample2;




SELECT JSON_ARRAYAGG(Color) AS ProductColors
INTO DemoJson.JsonObjectExample1
FROM Production.Product
WHERE ProductID IN (1, 316, 317, 792);
GO



SELECT JSON_ARRAYAGG(Color RETURNING JSON) AS ProductColors
INTO DemoJson.JsonObjectExample2
FROM Production.Product
WHERE ProductID IN (1, 316, 317, 792);
GO




DROP TABLE IF EXISTS DemoJson.JsonObjectExample1;
DROP TABLE IF EXISTS DemoJson.JsonObjectExample2;
