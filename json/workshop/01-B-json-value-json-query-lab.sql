/*
    Warsztaty JSON: 01. Odczyt danych z JSON - JSON_VALUE i JSON_QUERY - lab

    Tomasz Libera | MVP Data Platform
    libera@kursysql.pl

    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL

    Ten skrypt zawiera zadania do samodzielnego wykonania.

    Opis części i pełna treść zadań:

        01-A-json-value-json-query.md

    Przykładowe rozwiązania:

        01-C-json-value-json-query-labsolution.sql
*/

USE AdventureWorks2025;
GO

/* ============================================================
   Zadanie 1. Wyświetl przykładowe dokumenty

   Wyświetl pierwsze 10 rekordów z tabeli:
      DemoJson.OrderDocs_Text

   Pokaż kolumny:
      OrderID
      OrderDoc

   Posortuj wynik po OrderID.
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 2. Odczytaj podstawowe wartości z dokumentu JSON

   Z tabeli DemoJson.OrderDocs_Text odczytaj z kolumny OrderDoc:
      OrderID
      OrderDate
      Status
      OnlineOrder
      SalesPersonID

   Użyj funkcji JSON_VALUE.
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 3. Nadaj aliasy kolumnom

   Zmodyfikuj poprzednie zapytanie tak, aby wynik zawierał:
      TableOrderID
      JsonOrderID
      OrderDate
      Status
      OnlineOrder
      SalesPersonID

   TableOrderID pochodzi z kolumny tabeli.
   JsonOrderID pochodzi z dokumentu JSON.
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 4. Porównaj wartości z tabeli i z JSON

   Sprawdź, czy wartość OrderID z kolumny tabeli jest taka sama
   jak wartość OrderID zapisana w dokumencie JSON.

   Wyświetl tylko te rekordy, dla których wartości są różne.
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 5. Odczytaj dane klienta

   Z dokumentu JSON odczytaj:
      Customer.CustomerID
      Customer.AccountNumber
      Customer.CustomerType

   Użyj funkcji JSON_VALUE.
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 6. Odczytaj dane wysyłkowe

   Z dokumentu JSON odczytaj informacje z obiektu Shipping,
   np.:
      Shipping.City
      Shipping.CountryRegionCode
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 7. Odczytaj obiekt Customer jako JSON

   Odczytaj cały obiekt:
      Customer

   Użyj funkcji JSON_QUERY.
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 8. Odczytaj obiekt Totals jako JSON

   Odczytaj cały obiekt:
      Totals

   Użyj funkcji JSON_QUERY.
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 9. Odczytaj tablicę Items jako JSON

   Odczytaj tablicę:
      Items

   Użyj funkcji JSON_QUERY.
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 10. Celowa pomyłka: JSON_VALUE na tablicy

   Spróbuj odczytać tablicę Items za pomocą JSON_VALUE.

   Porównaj wynik z JSON_QUERY.
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 11. Celowa pomyłka: JSON_VALUE na obiekcie

   Spróbuj odczytać obiekt Customer za pomocą JSON_VALUE.

   Porównaj wynik z JSON_QUERY.
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 12. Odczytaj pierwszy element tablicy Items

   Odczytaj dane pierwszej pozycji zamówienia:
      Items[0].ProductID
      Items[0].Name
      Items[0].OrderQty
      Items[0].UnitPrice
      Items[0].LineTotal

   Użyj funkcji JSON_VALUE.
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 13. Odczytaj drugi element tablicy Items

   Odczytaj dane drugiej pozycji zamówienia:
      Items[1].ProductID
      Items[1].Name
      Items[1].OrderQty
      Items[1].UnitPrice
      Items[1].LineTotal

   Sprawdź, co się stanie, jeżeli zamówienie nie ma drugiej pozycji.
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 14. Filtrowanie po wartości z JSON

   Wyświetl zamówienia, dla których:
      Status = Shipped

   Jeżeli taka wartość nie występuje w Twoich danych,
   użyj innej wartości statusu.

   Użyj JSON_VALUE w klauzuli WHERE.
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 15. Filtrowanie po wartości liczbowej z JSON

   Wyświetl zamówienia, dla których:
      Totals.TotalDue > 1000

   Pamiętaj, że wartość odczytana przez JSON_VALUE
   wymaga konwersji na typ liczbowy.
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 16. Sortowanie po dacie zapisanej w JSON

   Wyświetl zamówienia i posortuj je malejąco po wartości:
      OrderDate

   Wartość odczytaj z dokumentu JSON.
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 17. Sortowanie po kwocie zapisanej w JSON

   Wyświetl zamówienia i posortuj je malejąco po wartości:
      Totals.TotalDue

   Pamiętaj o konwersji na typ liczbowy.
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 18. Porównaj tryb lax i strict

   Spróbuj odczytać nieistniejącą właściwość:
      DoesNotExist

   Najpierw w trybie domyślnym, czyli lax,
   a potem w trybie strict.

   Przykładowe ścieżki:
      '$.DoesNotExist'
      'strict $.DoesNotExist'
   ============================================================ */

-- tu wstaw Twój kod

GO