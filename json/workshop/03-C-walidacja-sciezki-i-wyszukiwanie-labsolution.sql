/*
    Warsztaty JSON: 03. Walidacja, ścieżki i wyszukiwanie w JSON - rozwiązania zadań

    Tomasz Libera | MVP Data Platform
    libera@kursysql.pl

    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL

    Ten skrypt zawiera przykładowe rozwiązania zadań z pliku:

        03-A-walidacja-sciezki-i-wyszukiwanie.md
*/

USE AdventureWorks2025;
GO




/* ============================================================
   Zadanie 1. Sprawdź poprawność dokumentów JSON
   ============================================================ */

SELECT
    ISJSON(OrderDoc) AS IsValidJson,
    COUNT(*) AS RowsCount
FROM DemoJson.OrderDocs_Text
GROUP BY
    ISJSON(OrderDoc)
ORDER BY
    IsValidJson DESC;
GO


/* ============================================================
   Zadanie 2. Znajdź niepoprawne dokumenty JSON
   ============================================================ */

SELECT
    OrderID,
    OrderDoc
FROM DemoJson.OrderDocs_Text
WHERE ISJSON(OrderDoc) <> 1
   OR ISJSON(OrderDoc) IS NULL
ORDER BY
    OrderID;
GO


/* ============================================================
   Zadanie 3. Sprawdź ISJSON dla przykładowych wartości
   ============================================================ */



SELECT ISJSON('{"ProductID": 776}') AS [{"ProductID": 776}]
SELECT ISJSON('[1, 2, 3]')  AS [[1, 2, 3]]]
SELECT ISJSON('"SQL Server"') AS ["SQL Server"]
SELECT ISJSON('123') AS [123]
SELECT ISJSON('true') AS [true]
SELECT ISJSON('{ProductID: 776}') AS [{ProductID: 776}]




/* ============================================================
   Zadanie 4. Sprawdź typ JSON przez ISJSON
   ============================================================ */

WITH Samples AS
(
    SELECT N'{"ProductID": 776}' AS JsonText
    UNION ALL SELECT N'[1, 2, 3]'
    UNION ALL SELECT N'"SQL Server"'
    UNION ALL SELECT N'123'
    UNION ALL SELECT N'true'
    UNION ALL SELECT N'{ProductID: 776}'
)
SELECT
    JsonText,
    ISJSON(JsonText) AS IsJson_Default,
    ISJSON(JsonText, VALUE) AS IsJson_Value,
    ISJSON(JsonText, OBJECT) AS IsJson_Object,
    ISJSON(JsonText, ARRAY) AS IsJson_Array,
    ISJSON(JsonText, SCALAR) AS IsJson_Scalar
FROM Samples;
GO




/* ============================================================
   Zadanie 5. Sprawdź podstawowe ścieżki w dokumencie
   ============================================================ */

SELECT TOP (10)
    OrderID,
    JSON_PATH_EXISTS(OrderDoc, '$.OrderID') AS HasOrderID,
    JSON_PATH_EXISTS(OrderDoc, '$.Customer') AS HasCustomer,
    JSON_PATH_EXISTS(OrderDoc, '$.Shipping') AS HasShipping,
    JSON_PATH_EXISTS(OrderDoc, '$.Totals') AS HasTotals,
    JSON_PATH_EXISTS(OrderDoc, '$.Items') AS HasItems
FROM DemoJson.OrderDocs_Text
ORDER BY
    OrderID;
GO


/* ============================================================
   Zadanie 6. Sprawdź ścieżki zagnieżdżone
   ============================================================ */

SELECT TOP (10)
    OrderID,
    JSON_PATH_EXISTS(OrderDoc, '$.Customer.CustomerID') AS HasCustomerID,
    JSON_PATH_EXISTS(OrderDoc, '$.Customer.AccountNumber') AS HasAccountNumber,
    JSON_PATH_EXISTS(OrderDoc, '$.Shipping.City') AS HasShippingCity,
    JSON_PATH_EXISTS(OrderDoc, '$.Shipping.CountryRegionCode') AS HasCountryRegionCode,
    JSON_PATH_EXISTS(OrderDoc, '$.Totals.TotalDue') AS HasTotalDue
FROM DemoJson.OrderDocs_Text
ORDER BY
    OrderID;
GO


/* ============================================================
   Zadanie 7. Sprawdź nieistniejącą ścieżkę
   ============================================================ */

SELECT TOP (10)
    OrderID,
    JSON_PATH_EXISTS(OrderDoc, '$.DoesNotExist') AS HasDoesNotExist
FROM DemoJson.OrderDocs_Text
ORDER BY
    OrderID;
GO


/* ============================================================
   Zadanie 8. Sprawdź ścieżkę w tablicy Items
   ============================================================ */

SELECT TOP (10)
    OrderID,
    JSON_PATH_EXISTS(OrderDoc, '$.Items[*].ProductID') AS HasAnyProductID
FROM DemoJson.OrderDocs_Text
ORDER BY
    OrderID;
GO


/* ============================================================
   Zadanie 9. Znajdź zamówienia, które mają tablicę Items
   ============================================================ */

SELECT TOP (10)
    OrderID,
    JSON_QUERY(OrderDoc, '$.Items') AS Items
FROM DemoJson.OrderDocs_Text
WHERE JSON_PATH_EXISTS(OrderDoc, '$.Items') = 1
ORDER BY
    OrderID;
GO


/* ============================================================
   Zadanie 10. Znajdź zamówienia z krajem wysyłki
   ============================================================ */

SELECT TOP (20)
    OrderID,
    JSON_VALUE(OrderDoc, '$.Shipping.CountryRegionCode') AS CountryRegionCode
FROM DemoJson.OrderDocs_Text
WHERE JSON_PATH_EXISTS(OrderDoc, '$.Shipping.CountryRegionCode') = 1
ORDER BY
    OrderID;
GO


/* ============================================================
   Zadanie 11. Sprawdź JSON_CONTAINS dla wartości tekstowej

   Uwaga:
   JSON_CONTAINS jest funkcją SQL Server 2025.
   Dla tekstu podajemy wartość jako typ znakowy SQL, np. N'US'.
   ============================================================ */

SELECT TOP (20)
    OrderID,
    JSON_VALUE(OrderDoc, '$.Shipping.CountryRegionCode') AS CountryRegionCode
FROM DemoJson.OrderDocs_Json
WHERE JSON_CONTAINS(OrderDoc, N'US', '$.Shipping.CountryRegionCode') = 1
ORDER BY
    OrderID;
GO


/* ============================================================
   Zadanie 12. Sprawdź JSON_CONTAINS dla wartości liczbowej
   ============================================================ */

-- Najpierw można sprawdzić przykładowe wartości SalesPersonID.

SELECT TOP (10)
    JSON_VALUE(OrderDoc, '$.SalesPersonID') AS SalesPersonID,
    COUNT(*) AS RowsCount
FROM DemoJson.OrderDocs_Json
WHERE JSON_VALUE(OrderDoc, '$.SalesPersonID') IS NOT NULL
GROUP BY
    JSON_VALUE(OrderDoc, '$.SalesPersonID')
ORDER BY
    RowsCount DESC;
GO

-- Wariant z przykładową wartością.

SELECT TOP (20)
    OrderID,
    JSON_VALUE(OrderDoc, '$.SalesPersonID') AS SalesPersonID
FROM DemoJson.OrderDocs_Json
WHERE JSON_CONTAINS(OrderDoc, 279, '$.SalesPersonID') = 1
ORDER BY
    OrderID;
GO


/* ============================================================
   Zadanie 13. Znajdź zamówienia zawierające wybrany produkt

   Przy tablicy używamy wildcarda [*].
   ============================================================ */

SELECT TOP (20)
    OrderID
FROM DemoJson.OrderDocs_Json
WHERE JSON_CONTAINS(OrderDoc, 776, '$.Items[*].ProductID') = 1
ORDER BY
    OrderID;
GO


/* ============================================================
   Zadanie 14. Porównaj JSON_PATH_EXISTS i JSON_CONTAINS
   ============================================================ */

SELECT TOP (20)
    OrderID,
    JSON_VALUE(OrderDoc, '$.Shipping.CountryRegionCode') AS CountryRegionCode,
    JSON_PATH_EXISTS(OrderDoc, '$.Shipping.CountryRegionCode') AS HasCountryRegionCode,
    JSON_CONTAINS(OrderDoc, N'US', '$.Shipping.CountryRegionCode') AS ContainsUS
FROM DemoJson.OrderDocs_Json
ORDER BY
    OrderID;
GO


/* ============================================================
   Zadanie 15. Sprawdź ProductID przez JSON_PATH_EXISTS i JSON_CONTAINS
   ============================================================ */

SELECT TOP (20)
    OrderID,
    JSON_PATH_EXISTS(OrderDoc, '$.Items[*].ProductID') AS HasAnyProductID,
    JSON_CONTAINS(OrderDoc, 776, '$.Items[*].ProductID') AS ContainsProduct776
FROM DemoJson.OrderDocs_Json
ORDER BY
    OrderID;
GO


/* ============================================================
   Zadanie 16. Znajdź zamówienia bez wybranej ścieżki
   ============================================================ */

SELECT 
    OrderID,
    OrderDoc,
    JSON_VALUE(OrderDoc, '$.SalesPersonID') AS SalesPersonID,
    JSON_PATH_EXISTS(OrderDoc, '$.SalesPersonID') AS HasSalesPersonID
FROM DemoJson.OrderDocs_Text
WHERE JSON_PATH_EXISTS(OrderDoc, '$.SalesPersonID') = 0
   OR JSON_VALUE(OrderDoc, '$.SalesPersonID') IS NULL
ORDER BY
    OrderID;
GO

-- dla których ścieżka istnieje...
SELECT 
    OrderID,
    OrderDoc,
    JSON_VALUE(OrderDoc, '$.SalesPersonID') AS SalesPersonID,
    JSON_PATH_EXISTS(OrderDoc, '$.SalesPersonID') AS HasSalesPersonID
FROM DemoJson.OrderDocs_Text
WHERE JSON_PATH_EXISTS(OrderDoc, '$.SalesPersonID') = 1  
ORDER BY
    OrderID;
GO





/* ============================================================
   Koniec części 03

   W tej części rozwiązania dotyczyły:
   - ISJSON,
   - JSON_PATH_EXISTS,
   - JSON_CONTAINS,
   - sprawdzania poprawności dokumentów JSON,
   - sprawdzania istnienia ścieżek,
   - wyszukiwania wartości w dokumentach JSON.

   W kolejnej części przechodzimy do:
   - JSON_MODIFY.
   ============================================================ */