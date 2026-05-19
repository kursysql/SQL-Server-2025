/*
    Warsztaty JSON: 05. Generowanie JSON z danych relacyjnych - lab

    Tomasz Libera | MVP Data Platform
    libera@kursysql.pl

    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL

    Ten skrypt zawiera zadania do samodzielnego wykonania.

    Opis części i pełna treść zadań:

        05-A-generowanie-json.md

    Przykładowe rozwiązania:

        05-C-generowanie-json-labsolution.sql
*/

USE AdventureWorks2025;
GO

/* ============================================================
   Zadanie 1. Utwórz prosty obiekt JSON

   Utwórz obiekt JSON opisujący produkt:

      ProductID = 776
      Name = Mountain-100 Black, 42
      OrderQty = 1
      UnitPrice = 2024.99

   Użyj funkcji:

      JSON_OBJECT

   Oczekiwany wynik:

      {
        "ProductID": 776,
        "Name": "Mountain-100 Black, 42",
        "OrderQty": 1,
        "UnitPrice": 2024.99
      }
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 2. Utwórz prostą tablicę JSON

   Utwórz tablicę JSON zawierającą wartości:

      SQL Server
      JSON
      T-SQL

   Użyj funkcji:

      JSON_ARRAY

   Oczekiwany wynik:

      [
        "SQL Server",
        "JSON",
        "T-SQL"
      ]
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 3. Utwórz tablicę mieszaną

   Utwórz tablicę JSON zawierającą:

      ProductID
      Name
      OrderQty
      UnitPrice

   Dane mogą być wpisane na sztywno.

   Oczekiwany wynik:

      [
        776,
        "Mountain-100 Black, 42",
        1,
        2024.99
      ]
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 4. Wygeneruj obiekty JSON dla kilku zamówień

   Na podstawie tabeli:

      Sales.SalesOrderHeader

   wygeneruj dla pierwszych 10 zamówień obiekt JSON zawierający:

      OrderID na podstawie kolumny SalesOrderID
      OrderDate
      Status
      CustomerID
      TotalDue

   Użyj:

      JSON_OBJECT
      JSON_VALUE

   Przykładowy kształt OrderJson:

      {
        "OrderID": 43659,
        "OrderDate": "2022-05-30T00:00:00",
        "Status": 5,
        "CustomerID": 29825,
        "TotalDue": 23153.2339
      }
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 5. Wygeneruj obiekt Customer

   Dla pierwszych 10 zamówień wygeneruj obiekt JSON:

      Sales.Customer

   zawierający:

      CustomerID
      StoreID
      TerritoryID
      AccountNumber

   Przykładowy kształt wyniku:

      {
        "CustomerID": 1,
        "StoreID": 934,
        "TerritoryID": 1,
        "AccountNumber": "AW00000001"
      }
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 6. Wygeneruj obiekt z obiektem zagnieżdżonym

   Dla pierwszych 10 zamówień wygeneruj obiekt JSON zawierający:

      Sales.SalesOrderHeader
      Sales.Customer

      SalesOrderID
      OrderDate
      Status
      Customer.CustomerID
      Customer.StoreID
      Customer.TerritoryID
      Customer.AccountNumber

   Customer powinien być zagnieżdżonym obiektem JSON.

   Przykładowy kształt wyniku:

      {
        "OrderID": 43659,
        "OrderDate": "2022-05-30T00:00:00",
        "Status": 5,
        "Customer": {
          "CustomerID": 29825,
          "StoreID": 1046,
          "TerritoryID": 5,
          "AccountNumber": "AW00029825"
        }
      }
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 7. Porównaj JSON_OBJECT z NULL ON NULL

   Utwórz obiekt JSON z polami:

      ProductID = 776
      Name = Mountain-100 Black, 42
      Color = NULL

   Sprawdź domyślne zachowanie wartości NULL.

   Oczekiwany wynik:

      {
        "ProductID": 776,
        "Name": "Mountain-100 Black, 42",
        "Color": null
      }
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 8. Porównaj JSON_OBJECT z ABSENT ON NULL

   Utwórz taki sam obiekt jak w poprzednim zadaniu,
   ale użyj:

      ABSENT ON NULL

   Sprawdź, czy właściwość Color pojawia się w wyniku.

   Oczekiwany wynik:

      {
        "ProductID": 776,
        "Name": "Mountain-100 Black, 42"
      }
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 9. Porównaj JSON_ARRAY z wartościami NULL

   Utwórz tablicę JSON zawierającą:

      SQL Server
      NULL
      JSON

   Najpierw użyj zachowania domyślnego, a potem:

      NULL ON NULL

   Porównaj wyniki.
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 10. Użyj JSON_ARRAYAGG dla nazw produktów

   Na podstawie przykładowych danych z VALUES utwórz tablicę nazw produktów.

   Dane:

      VALUES
          (776, N'Mountain-100 Black, 42'),
          (777, N'Mountain-100 Black, 44'),
          (778, N'Mountain-100 Black, 48')

   Użyj:

      JSON_ARRAYAGG

   Oczekiwany wynik:

      [
        "Mountain-100 Black, 42",
        "Mountain-100 Black, 44",
        "Mountain-100 Black, 48"
      ]
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 11. Użyj ORDER BY w JSON_ARRAYAGG

   Zmodyfikuj poprzednie zadanie tak, aby elementy tablicy
   były posortowane po Name malejąco:

      [
        "Mountain-100 Black, 48",
        "Mountain-100 Black, 44",
        "Mountain-100 Black, 42"
      ]
   ============================================================ */

-- tu wstaw Twój kod

GO