/*
    Warsztaty JSON: 01. Odczyt danych z JSON - JSON_VALUE i JSON_QUERY - rozwiązania zadań

    Tomasz Libera | MVP Data Platform
    libera@kursysql.pl

    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL

    Ten skrypt zawiera przykładowe rozwiązania zadań z pliku:

        01-A-json-value-json-query.md
*/

USE AdventureWorks2025;
GO

/* ============================================================
   Zadanie 1. Wyświetl przykładowe dokumenty
   ============================================================ */

SELECT TOP (10)
    OrderID,
    OrderDoc
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;
GO


/* ============================================================
   Zadanie 2. Odczytaj podstawowe wartości z dokumentu JSON
   ============================================================ */

SELECT TOP (10)
    JSON_VALUE(OrderDoc, '$.OrderID') AS OrderID,
    JSON_VALUE(OrderDoc, '$.OrderDate') AS OrderDate,
    JSON_VALUE(OrderDoc, '$.Status') AS Status,
    JSON_VALUE(OrderDoc, '$.OnlineOrder') AS OnlineOrder,
    JSON_VALUE(OrderDoc, '$.SalesPersonID') AS SalesPersonID
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;
GO


/* ============================================================
   Zadanie 3. Nadaj aliasy kolumnom
   ============================================================ */

SELECT TOP (10)
    OrderID AS TableOrderID,
    JSON_VALUE(OrderDoc, '$.OrderID') AS JsonOrderID,
    JSON_VALUE(OrderDoc, '$.OrderDate') AS OrderDate,
    JSON_VALUE(OrderDoc, '$.Status') AS Status,
    JSON_VALUE(OrderDoc, '$.OnlineOrder') AS OnlineOrder,
    JSON_VALUE(OrderDoc, '$.SalesPersonID') AS SalesPersonID
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;
GO


/* ============================================================
   Zadanie 4. Porównaj wartości z tabeli i z JSON
   ============================================================ */

SELECT
    OrderID AS TableOrderID,
    JSON_VALUE(OrderDoc, '$.OrderID') AS JsonOrderID
FROM DemoJson.OrderDocs_Text
WHERE OrderID <> TRY_CONVERT(int, JSON_VALUE(OrderDoc, '$.OrderID'));
GO


/* ============================================================
   Zadanie 5. Odczytaj dane klienta
   ============================================================ */

SELECT TOP (10)
    OrderID,
    JSON_VALUE(OrderDoc, '$.Customer.CustomerID') AS CustomerID,
    JSON_VALUE(OrderDoc, '$.Customer.AccountNumber') AS AccountNumber,
    JSON_VALUE(OrderDoc, '$.Customer.CustomerType') AS CustomerType
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;
GO


/* ============================================================
   Zadanie 6. Odczytaj dane wysyłkowe
   ============================================================ */

SELECT TOP (10)
    OrderID,
    JSON_VALUE(OrderDoc, '$.Shipping.City') AS City,
    JSON_VALUE(OrderDoc, '$.Shipping.CountryRegionCode') AS CountryRegionCode
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;
GO


/* ============================================================
   Zadanie 7. Odczytaj obiekt Customer jako JSON
   ============================================================ */

SELECT TOP (10)
    OrderID,
    JSON_QUERY(OrderDoc, '$.Customer') AS Customer
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;
GO


/* ============================================================
   Zadanie 8. Odczytaj obiekt Totals jako JSON
   ============================================================ */

SELECT TOP (10)
    OrderID,
    JSON_QUERY(OrderDoc, '$.Totals') AS Totals
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;
GO


/* ============================================================
   Zadanie 9. Odczytaj tablicę Items jako JSON
   ============================================================ */

SELECT TOP (10)
    OrderID,
    JSON_QUERY(OrderDoc, '$.Items') AS Items
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;
GO


/* ============================================================
   Zadanie 10. Celowa pomyłka: JSON_VALUE na tablicy
   ============================================================ */

SELECT TOP (10)
    OrderID,
    JSON_VALUE(OrderDoc, '$.Items') AS Items_By_JSON_VALUE,
    JSON_QUERY(OrderDoc, '$.Items') AS Items_By_JSON_QUERY
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;
GO

/*
    Komentarz:
    Items jest tablicą JSON.
    JSON_VALUE służy do odczytu wartości skalarnych, więc w trybie lax
    dla tablicy zwróci NULL.
*/


/* ============================================================
   Zadanie 11. Celowa pomyłka: JSON_VALUE na obiekcie
   ============================================================ */

SELECT TOP (10)
    OrderID,
    JSON_VALUE(OrderDoc, '$.Customer') AS Customer_By_JSON_VALUE,
    JSON_QUERY(OrderDoc, '$.Customer') AS Customer_By_JSON_QUERY
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;
GO

/*
    Komentarz:
    Customer jest obiektem JSON.
    JSON_VALUE służy do odczytu wartości skalarnych, więc w trybie lax
    dla obiektu zwróci NULL.
*/


/* ============================================================
   Zadanie 12. Odczytaj pierwszy element tablicy Items
   ============================================================ */

SELECT TOP (10)
    OrderID,
    JSON_VALUE(OrderDoc, '$.Items[0].ProductID') AS FirstProductID,
    JSON_VALUE(OrderDoc, '$.Items[0].Name') AS FirstProductName,
    JSON_VALUE(OrderDoc, '$.Items[0].OrderQty') AS FirstOrderQty,
    JSON_VALUE(OrderDoc, '$.Items[0].UnitPrice') AS FirstUnitPrice,
    JSON_VALUE(OrderDoc, '$.Items[0].LineTotal') AS FirstLineTotal
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;
GO


/* ============================================================
   Zadanie 13. Odczytaj drugi element tablicy Items
   ============================================================ */

SELECT TOP (10)
    OrderID,
    JSON_VALUE(OrderDoc, '$.Items[1].ProductID') AS SecondProductID,
    JSON_VALUE(OrderDoc, '$.Items[1].Name') AS SecondProductName,
    JSON_VALUE(OrderDoc, '$.Items[1].OrderQty') AS SecondOrderQty,
    JSON_VALUE(OrderDoc, '$.Items[1].UnitPrice') AS SecondUnitPrice,
    JSON_VALUE(OrderDoc, '$.Items[1].LineTotal') AS SecondLineTotal
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;
GO

/*
    Komentarz:
    Jeżeli zamówienie nie ma drugiej pozycji w tablicy Items,
    w trybie lax otrzymamy NULL.
*/


/* ============================================================
   Zadanie 14. Filtrowanie po wartości z JSON
   ============================================================ */


-- Wariant z konkretną wartością.
-- Jeżeli w danych nie ma statusu 5, podmień wartość
-- na jedną z wartości zwróconych przez poprzednie zapytanie.

SELECT TOP (10)
    OrderID,
    JSON_VALUE(OrderDoc, '$.OrderDate') AS OrderDate,
    JSON_VALUE(OrderDoc, '$.Status') AS Status
FROM DemoJson.OrderDocs_Text
WHERE JSON_VALUE(OrderDoc, '$.Status') = '5'
ORDER BY OrderID;
GO


/* ============================================================
   Zadanie 15. Filtrowanie po wartości liczbowej z JSON
   ============================================================ */

SELECT TOP (10)
    OrderID,
    JSON_VALUE(OrderDoc, '$.Totals.TotalDue') AS TotalDue_AsText,
    TRY_CONVERT(decimal(19, 4), JSON_VALUE(OrderDoc, '$.Totals.TotalDue')) AS TotalDue_AsNumber
FROM DemoJson.OrderDocs_Text
WHERE TRY_CONVERT(decimal(19, 4), JSON_VALUE(OrderDoc, '$.Totals.TotalDue')) > 1000
ORDER BY TRY_CONVERT(decimal(19, 4), JSON_VALUE(OrderDoc, '$.Totals.TotalDue')) DESC;
GO


/* ============================================================
   Zadanie 16. Sortowanie po dacie zapisanej w JSON
   ============================================================ */

SELECT TOP (10)
    OrderID,
    JSON_VALUE(OrderDoc, '$.OrderDate') AS OrderDate_AsText,
    TRY_CONVERT(date, JSON_VALUE(OrderDoc, '$.OrderDate')) AS OrderDate_AsDate
FROM DemoJson.OrderDocs_Text
ORDER BY TRY_CONVERT(date, JSON_VALUE(OrderDoc, '$.OrderDate')) DESC;
GO


/* ============================================================
   Zadanie 17. Sortowanie po kwocie zapisanej w JSON
   ============================================================ */

SELECT TOP (10)
    OrderID,
    JSON_VALUE(OrderDoc, '$.Totals.TotalDue') AS TotalDue_AsText,
    TRY_CONVERT(decimal(19, 4), JSON_VALUE(OrderDoc, '$.Totals.TotalDue')) AS TotalDue_AsNumber
FROM DemoJson.OrderDocs_Text
ORDER BY TRY_CONVERT(decimal(19, 4), JSON_VALUE(OrderDoc, '$.Totals.TotalDue')) DESC;
GO


/* ============================================================
   Zadanie 18. Porównaj tryb lax i strict
   ============================================================ */

-- Tryb domyślny, czyli lax.
-- Jeżeli właściwość nie istnieje, otrzymamy NULL.

SELECT TOP (10)
    OrderID,
    JSON_VALUE(OrderDoc, '$.DoesNotExist') AS DoesNotExist_Lax
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;
GO

-- Tryb strict.
-- Poniższe zapytanie powinno zakończyć się błędem,
-- ponieważ właściwość DoesNotExist nie istnieje.

-- !!!
 SELECT TOP (10)
     OrderID,
     JSON_VALUE(OrderDoc, 'strict $.DoesNotExist') AS DoesNotExist_Strict
 FROM DemoJson.OrderDocs_Text
 ORDER BY OrderID;
 GO

