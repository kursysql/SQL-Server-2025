/*
    Warsztaty JSON: 04. Modyfikowanie dokumentów JSON - JSON_MODIFY - rozwiązania zadań

    Tomasz Libera | MVP Data Platform
    libera@kursysql.pl

    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL

    Ten skrypt zawiera przykładowe rozwiązania zadań z pliku:

        04-A-json-modify.md
*/

USE AdventureWorks2025;
GO

/* ============================================================
   Zadanie 1. Pobierz dokument JSON do zmiennej
   ============================================================ */

DECLARE @OrderDoc nvarchar(max);

SELECT TOP (1)
    @OrderDoc = OrderDoc
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;

SELECT
    @OrderDoc AS OrderDoc;
GO


/* ============================================================
   Zadanie 2. Sprawdź wartości przed modyfikacją
   ============================================================ */

DECLARE @OrderDoc nvarchar(max);

SELECT TOP (1)
    @OrderDoc = OrderDoc
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;

SELECT
    JSON_VALUE(@OrderDoc, '$.OrderID') AS OrderID,
    JSON_VALUE(@OrderDoc, '$.Status') AS Status,
    JSON_VALUE(@OrderDoc, '$.SalesPersonID') AS SalesPersonID,
    JSON_VALUE(@OrderDoc, '$.Customer.CustomerType') AS CustomerType,
    JSON_VALUE(@OrderDoc, '$.Shipping.City') AS City,
    JSON_VALUE(@OrderDoc, '$.Shipping.CountryRegionCode') AS CountryRegionCode,
    JSON_VALUE(@OrderDoc, '$.Items[0].ProductID') AS FirstProductID,
    JSON_VALUE(@OrderDoc, '$.Items[0].OrderQty') AS FirstOrderQty;
GO


/* ============================================================
   Zadanie 3. Zmień status zamówienia
   ============================================================ */

DECLARE @OrderDoc nvarchar(max);

SELECT TOP (1)
    @OrderDoc = OrderDoc
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;

SET @OrderDoc = JSON_MODIFY(@OrderDoc, '$.Status', N'Cancelled');

SELECT
    JSON_VALUE(@OrderDoc, '$.OrderID') AS OrderID,
    JSON_VALUE(@OrderDoc, '$.Status') AS Status,
    @OrderDoc AS ModifiedOrderDoc;
GO


/* ============================================================
   Zadanie 4. Dodaj nową właściwość na głównym poziomie
   ============================================================ */

DECLARE @OrderDoc nvarchar(max);

SELECT TOP (1)
    @OrderDoc = OrderDoc
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;

SET @OrderDoc = JSON_MODIFY(@OrderDoc, '$.WorkshopSource', N'KursySQL');

SELECT
    JSON_VALUE(@OrderDoc, '$.OrderID') AS OrderID,
    JSON_VALUE(@OrderDoc, '$.WorkshopSource') AS WorkshopSource,
    @OrderDoc AS ModifiedOrderDoc;
GO


/* ============================================================
   Zadanie 5. Zmień wartość w obiekcie Customer
   ============================================================ */

DECLARE @OrderDoc nvarchar(max);

SELECT TOP (1)
    @OrderDoc = OrderDoc
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;

SELECT @OrderDoc

SET @OrderDoc = JSON_MODIFY(@OrderDoc, '$.Customer.CustomerType', N'VIP');

SELECT
    JSON_VALUE(@OrderDoc, '$.Customer.CustomerID') AS CustomerID,
    JSON_VALUE(@OrderDoc, '$.Customer.CustomerType') AS CustomerType,
    JSON_QUERY(@OrderDoc, '$.Customer') AS Customer,
    @OrderDoc AS ModifiedOrderDoc;
GO


/* ============================================================
   Zadanie 6. Dodaj właściwość do obiektu Shipping
   ============================================================ */

DECLARE @OrderDoc nvarchar(max);

SELECT TOP (1)
    @OrderDoc = OrderDoc
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;

SELECT @OrderDoc

SET @OrderDoc = JSON_MODIFY(@OrderDoc, '$.Shipping.DeliveryMethod', N'Courier');

SELECT
    JSON_QUERY(@OrderDoc, '$.Shipping') AS Shipping,
    @OrderDoc AS ModifiedOrderDoc;
GO


/* ============================================================
   Zadanie 7. Usuń właściwość SalesPersonID
   ============================================================ */

DECLARE @OrderDoc nvarchar(max);

SELECT TOP (1)
    @OrderDoc = OrderDoc
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;

SELECT @OrderDoc

SET @OrderDoc = JSON_MODIFY(@OrderDoc, '$.SalesPersonID', NULL);

SELECT
    JSON_VALUE(@OrderDoc, '$.SalesPersonID') AS SalesPersonID,
    @OrderDoc AS ModifiedOrderDoc;
GO


/* ============================================================
   Zadanie 8. Zmień ilość w pierwszej pozycji zamówienia
   ============================================================ */

DECLARE @OrderDoc nvarchar(max);

SELECT TOP (1)
    @OrderDoc = OrderDoc
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;

SELECT @OrderDoc

SET @OrderDoc = JSON_MODIFY(@OrderDoc, '$.Items[0].OrderQty', 2);

SELECT
    JSON_VALUE(@OrderDoc, '$.Items[0].ProductID') AS ProductID,
    JSON_VALUE(@OrderDoc, '$.Items[0].Name') AS Name,
    JSON_VALUE(@OrderDoc, '$.Items[0].OrderQty') AS OrderQty,
    JSON_QUERY(@OrderDoc, '$.Items[0]') AS FirstItem,
    @OrderDoc AS ModifiedOrderDoc;
GO


/* ============================================================
   Zadanie 9. Zmień cenę w pierwszej pozycji zamówienia
   ============================================================ */

DECLARE @OrderDoc nvarchar(max);

SELECT TOP (1)
    @OrderDoc = OrderDoc
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;

SELECT @OrderDoc

SET @OrderDoc = JSON_MODIFY(@OrderDoc, '$.Items[0].UnitPrice', 1999.99);

SELECT
    JSON_VALUE(@OrderDoc, '$.Items[0].UnitPrice') AS UnitPrice,
    JSON_VALUE(@OrderDoc, '$.Items[0].LineTotal') AS LineTotal,
    JSON_QUERY(@OrderDoc, '$.Items[0]') AS FirstItem,
    @OrderDoc AS ModifiedOrderDoc;
GO

/*
    Komentarz:
    Zmiana UnitPrice nie przelicza automatycznie LineTotal.
    JSON_MODIFY wykonuje punktową zmianę wskazanej ścieżki.
*/


/* ============================================================
   Zadanie 10. Dodaj nową właściwość Audit jako obiekt JSON
   ============================================================ */

DECLARE @OrderDoc nvarchar(max);

SELECT TOP (1)
    @OrderDoc = OrderDoc
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;

SELECT @OrderDoc

SET @OrderDoc = JSON_MODIFY(
    @OrderDoc,
    '$.Audit',
    JSON_QUERY(N'{
      "ModifiedBy": "Workshop",
      "Reason": "JSON_MODIFY demo"
    }')
);

SELECT
    JSON_QUERY(@OrderDoc, '$.Audit') AS Audit,
    @OrderDoc AS ModifiedOrderDoc;
GO


/* ============================================================
   Zadanie 11. Dodaj nowy element do tablicy Items
   ============================================================ */

SELECT JSON_QUERY(N'{
      "ProductID": 999,
      "Name": "Workshop Product",
      "OrderQty": 1,
      "UnitPrice": 100.00,
      "LineTotal": 100.00
    }')

DECLARE @OrderDoc nvarchar(max);

SELECT TOP (1)
    @OrderDoc = OrderDoc
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;

SET @OrderDoc = JSON_MODIFY(
    @OrderDoc,
    'append $.Items',
    JSON_QUERY(N'{
      "ProductID": 999,
      "Name": "Workshop Product",
      "OrderQty": 1,
      "UnitPrice": 100.00,
      "LineTotal": 100.00
    }')
);



SELECT
    JSON_QUERY(@OrderDoc, '$.Items') AS Items,
    @OrderDoc AS ModifiedOrderDoc;
GO








/* ============================================================
   Koniec części 04

   W tej części rozwiązania dotyczyły:
   - JSON_MODIFY,
   - zmiany wartości w dokumencie JSON,
   - dodawania właściwości,
   - usuwania właściwości,
   - modyfikowania obiektów zagnieżdżonych,
   - modyfikowania tablic,
   - dodawania obiektów JSON przez JSON_QUERY,

   W kolejnej części przechodzimy do generowania JSON.
   ============================================================ */