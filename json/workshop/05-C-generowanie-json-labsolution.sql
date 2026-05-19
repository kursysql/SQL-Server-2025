/*
    Warsztaty JSON: 05. Generowanie JSON z danych relacyjnych - rozwiązania zadań

    Tomasz Libera | MVP Data Platform
    libera@kursysql.pl

    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL

    Ten skrypt zawiera przykładowe rozwiązania zadań z pliku:

        05-A-generowanie-json.md
*/

USE AdventureWorks2025;
GO



/* ============================================================
   Zadanie 1. Utwórz prosty obiekt JSON
   ============================================================ */

SELECT JSON_OBJECT(
    'ProductID': 776,
    'Name': N'Mountain-100 Black, 42',
    'OrderQty': 1,
    'UnitPrice': 2024.99
) AS ProductJson;
GO


/* ============================================================
   Zadanie 2. Utwórz prostą tablicę JSON
   ============================================================ */

SELECT JSON_ARRAY(N'SQL Server', N'JSON', N'T-SQL') AS JsonArray;
GO


/* ============================================================
   Zadanie 3. Utwórz tablicę mieszaną
   ============================================================ */

SELECT JSON_ARRAY(776, N'Mountain-100 Black, 42', 1, 2024.99) AS ProductArray;
GO


/* ============================================================
   Zadanie 4. Wygeneruj obiekty JSON dla kilku zamówień
   ============================================================ */

SELECT * FROM Sales.SalesOrderHeader

SELECT TOP (10)
    SalesOrderID,
    JSON_OBJECT(
        'OrderID': SalesOrderID,
        'OrderDate': OrderDate,
        'Status': Status,
        'CustomerID': CustomerID,
        'TotalDue': TotalDue
    ) AS OrderJson
FROM Sales.SalesOrderHeader
ORDER BY
    SalesOrderID;
GO

-- alternatywnie, na podstawie tabeli z dokumentami JSON w formacie tekstowym
SELECT TOP (10)
    OrderID,
    JSON_OBJECT(
        'OrderID': OrderID,
        'OrderDate': JSON_VALUE(OrderDoc, '$.OrderDate'),
        'Status': JSON_VALUE(OrderDoc, '$.Status'),
        'CustomerID': JSON_VALUE(OrderDoc, '$.Customer.CustomerID'),
        'TotalDue': TRY_CONVERT(decimal(19, 4), JSON_VALUE(OrderDoc, '$.Totals.TotalDue'))
    ) AS OrderJson
FROM DemoJson.OrderDocs_Text
ORDER BY
    OrderID;
GO



/* ============================================================
   Zadanie 5. Wygeneruj obiekt Customer
   ============================================================ */

SELECT * FROM Sales.Customer

SELECT TOP (10)
    CustomerID,
    JSON_OBJECT(
        'CustomerID': CustomerID,
        'StoreID': StoreID,
        'TerritoryID': TerritoryID,
        'AccountNumber': AccountNumber        
    ) AS CustomerJson
FROM Sales.Customer
ORDER BY CustomerID
GO



/* ============================================================
   Zadanie 6. Wygeneruj obiekt z obiektem zagnieżdżonym
   ============================================================ */

SELECT *
FROM Sales.SalesOrderHeader AS h
JOIN Sales.Customer AS c ON h.CustomerID = c.CustomerID

SELECT TOP (10)
    SalesOrderID,
    JSON_OBJECT(
        'OrderID': h.SalesOrderID,
        'OrderDate': h.OrderDate,
        'Status': h.Status,
        'Customer': JSON_OBJECT(
            'CustomerID': c.CustomerID,
            'StoreID': c.StoreID,
            'TerritoryID': c.TerritoryID,
            'AccountNumber': c.AccountNumber    
        )
    ) AS OrderJson
FROM Sales.SalesOrderHeader AS h
JOIN Sales.Customer AS c ON h.CustomerID = c.CustomerID
ORDER BY SalesOrderID
GO


/* ============================================================
   Zadanie 7. Porównaj JSON_OBJECT z NULL ON NULL
   ============================================================ */

SELECT JSON_OBJECT(
    'ProductID': 776,
    'Name': N'Mountain-100 Black, 42',
    'Color': NULL
) AS ProductJson_DefaultNullHandling;
GO


/* ============================================================
   Zadanie 8. Porównaj JSON_OBJECT z ABSENT ON NULL
   ============================================================ */

SELECT JSON_OBJECT(
    'ProductID': 776,
    'Name': N'Mountain-100 Black, 42',
    'Color': NULL
    ABSENT ON NULL
) AS ProductJson_AbsentOnNull;
GO


/* ============================================================
   Zadanie 9. Porównaj JSON_ARRAY z wartościami NULL
   ============================================================ */

SELECT
    JSON_ARRAY(N'SQL Server', NULL, N'JSON') AS JsonArray_DefaultNullHandling,
    JSON_ARRAY(N'SQL Server', NULL, N'JSON' NULL ON NULL) AS JsonArray_NullOnNull;
GO


/* ============================================================
   Zadanie 10. Użyj JSON_ARRAYAGG dla nazw produktów
   ============================================================ */

SELECT
    JSON_ARRAYAGG(Name) AS ProductNames
FROM
(
    VALUES
        (776, N'Mountain-100 Black, 42'),
        (777, N'Mountain-100 Black, 44'),
        (778, N'Mountain-100 Black, 48')
) AS p(ProductID, Name);
GO


/* ============================================================
   Zadanie 11. Użyj ORDER BY w JSON_ARRAYAGG
   ============================================================ */

SELECT
    JSON_ARRAYAGG(Name ORDER BY Name DESC) AS ProductNames
FROM
(
    VALUES
        (778, N'Mountain-100 Black, 48'),
        (776, N'Mountain-100 Black, 42'),
        (777, N'Mountain-100 Black, 44')
) AS p(ProductID, Name);
GO




/* ============================================================
   Koniec części 05

   W tej części rozwiązania dotyczyły:
   - JSON_OBJECT,
   - JSON_ARRAY,
   - JSON_OBJECTAGG,
   - JSON_ARRAYAGG,
   - NULL ON NULL,
   - ABSENT ON NULL,

   W kolejnej części przechodzimy do:
   - typu json,
   - computed columns,
   - indeksów JSON,
   - wydajności.
   ============================================================ */


/* ============================================================
   Odpowiedzi na pytania kontrolne
   ============================================================

   1. Do czego służy JSON_OBJECT?

      JSON_OBJECT służy do tworzenia obiektu JSON z par klucz/wartość.

      Przykład:

          SELECT JSON_OBJECT(
              'ProductID': 776,
              'Name': N'Mountain-100 Black, 42'
          ) AS ProductJson;

      Wynikiem jest obiekt JSON.


   2. Do czego służy JSON_ARRAY?

      JSON_ARRAY służy do tworzenia tablicy JSON z podanych wartości.

      Przykład:

          SELECT JSON_ARRAY(N'SQL Server', N'JSON', N'T-SQL') AS JsonArray;

      Wynikiem jest tablica JSON.


   3. Czym różni się JSON_ARRAY od JSON_ARRAYAGG?

      JSON_ARRAY tworzy tablicę z wartości podanych w jednym wywołaniu.

      Przykład:

          JSON_ARRAY(N'SQL Server', N'JSON', N'T-SQL')

      JSON_ARRAYAGG jest funkcją agregującą i tworzy tablicę z wartości
      pochodzących z wielu wierszy.

      Przykład:

          SELECT JSON_ARRAYAGG(Name)
          FROM Production.Product;


   4. Czym różni się JSON_OBJECT od JSON_OBJECTAGG?

      JSON_OBJECT tworzy pojedynczy obiekt JSON z podanych par klucz/wartość.

      Przykład:

          JSON_OBJECT('ProductID': 776, 'Name': N'Bike')

      JSON_OBJECTAGG jest funkcją agregującą i tworzy obiekt JSON
      na podstawie wielu wierszy, gdzie jedna kolumna może być kluczem,
      a druga wartością.

      Przykład:

          JSON_OBJECTAGG(ProductID: Name)


   5. Do czego służy JSON_OBJECTAGG?

      JSON_OBJECTAGG służy do tworzenia obiektu JSON z wielu wierszy.

      Najczęstszy scenariusz to przygotowanie mapy / słownika.

      Przykład:

          ProductID -> Name

      czyli wynik w stylu:

          {
            "776": "Mountain-100 Black, 42",
            "777": "Mountain-100 Black, 44"
          }


   6. Jak wymusić kolejność elementów w JSON_ARRAYAGG?

      W JSON_ARRAYAGG można użyć ORDER BY wewnątrz agregacji.

      Przykład:

          JSON_ARRAYAGG(Name ORDER BY Name DESC)

      Dzięki temu kolejność elementów w wynikowej tablicy JSON jest
      kontrolowana przez zapytanie.


   7. Jaka jest różnica między NULL ON NULL i ABSENT ON NULL?

      NULL ON NULL oznacza, że wartości NULL zostaną zapisane w JSON
      jako jawne null.

      Przykład:

          {"Color": null}

      ABSENT ON NULL oznacza, że właściwość albo element z wartością NULL
      zostanie pominięty w wyniku.

      Przykład:

          zamiast {"Color": null}
          otrzymamy obiekt bez właściwości Color.


   8. Jakie jest domyślne zachowanie NULL dla JSON_OBJECT?

      Dla JSON_OBJECT domyślne zachowanie to NULL ON NULL.

      Czyli właściwość z wartością NULL pojawi się w wyniku jako JSON-owe null.

      Przykład:

          JSON_OBJECT('ProductID': 776, 'Color': NULL)

      zwróci obiekt zawierający:

          "Color": null


   9. Jakie jest domyślne zachowanie NULL dla JSON_ARRAY?

      Dla JSON_ARRAY domyślne zachowanie to ABSENT ON NULL.

      Czyli wartość NULL jest domyślnie pomijana w tablicy.

      Przykład:

          JSON_ARRAY(N'SQL Server', NULL, N'JSON')

      domyślnie zwróci tablicę bez elementu NULL.

      Jeżeli chcemy zachować null w tablicy, można użyć:

          JSON_ARRAY(N'SQL Server', NULL, N'JSON' NULL ON NULL)


   10. Do czego służy RETURNING json?

      RETURNING json pozwala zwrócić wynik funkcji generującej JSON
      jako natywny typ json, a nie jako zwykły tekst.

      Przykład:

          JSON_OBJECT(
              'ProductID': 776,
              'Name': N'Mountain-100 Black, 42'
              RETURNING json
          )

      Jest to szczególnie istotne w scenariuszach związanych z typem json,
      dalszym przetwarzaniem dokumentów oraz indeksowaniem JSON.
*/