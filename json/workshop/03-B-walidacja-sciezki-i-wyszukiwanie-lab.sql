/*
    Warsztaty JSON: 03. Walidacja, ścieżki i wyszukiwanie w JSON - lab

    Tomasz Libera | MVP Data Platform
    libera@kursysql.pl

    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL

    Ten skrypt zawiera zadania do samodzielnego wykonania.

    Opis części i pełna treść zadań:

        03-A-walidacja-sciezki-i-wyszukiwanie.md

    Przykładowe rozwiązania:

        03-C-walidacja-sciezki-i-wyszukiwanie-labsolution.sql
*/

USE AdventureWorks2025;
GO

/* ============================================================
   Zadanie 1. Sprawdź poprawność dokumentów JSON

   Sprawdź, czy dokumenty w tabeli:

      DemoJson.OrderDocs_Text

   są poprawnym JSON.

   Użyj funkcji:

      ISJSON

   Wynik powinien pokazać liczbę dokumentów poprawnych i niepoprawnych.
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 2. Znajdź niepoprawne dokumenty JSON

   Wyświetl dokumenty z tabeli:

      DemoJson.OrderDocs_Text

   dla których ISJSON nie zwraca 1.
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 3. Sprawdź ISJSON dla przykładowych wartości

   Utwórz zapytanie, które sprawdzi ISJSON dla poniższych wartości:

      {"ProductID": 776}
      [1, 2, 3]
      "SQL Server"
      123
      true
      {ProductID: 776}

   Pokaż wynik w kolumnach:

      JsonText
      IsJson
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 4. Sprawdź typ JSON przez ISJSON

   Dla przykładowych wartości z poprzedniego zadania sprawdź:

      ISJSON(JsonText, VALUE)
      ISJSON(JsonText, OBJECT)
      ISJSON(JsonText, ARRAY)
      ISJSON(JsonText, SCALAR)
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 5. Sprawdź podstawowe ścieżki w dokumencie

   Dla pierwszych 10 zamówień sprawdź, czy istnieją ścieżki:

      $.OrderID
      $.Customer
      $.Shipping
      $.Totals
      $.Items

   Użyj funkcji:

      JSON_PATH_EXISTS
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 6. Sprawdź ścieżki zagnieżdżone

   Dla pierwszych 10 zamówień sprawdź, czy istnieją ścieżki:

      $.Customer.CustomerID
      $.Customer.AccountNumber
      $.Shipping.City
      $.Shipping.CountryRegionCode
      $.Totals.TotalDue
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 7. Sprawdź nieistniejącą ścieżkę

   Sprawdź, co zwraca JSON_PATH_EXISTS dla ścieżki:

      $.DoesNotExist
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 8. Sprawdź ścieżkę w tablicy Items

   Dla pierwszych 10 zamówień sprawdź, czy w tablicy Items
   występuje właściwość:

      ProductID

   Użyj ścieżki:

      $.Items[*].ProductID
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 9. Znajdź zamówienia, które mają tablicę Items

   Wyświetl zamówienia, dla których istnieje ścieżka:

      $.Items

   Wynik powinien zawierać:

      OrderID
      Items
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 10. Znajdź zamówienia z krajem wysyłki

   Znajdź zamówienia, dla których istnieje ścieżka:

      $.Shipping.CountryRegionCode

   Wynik powinien zawierać:

      OrderID
      CountryRegionCode
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 11. Sprawdź JSON_CONTAINS dla wartości tekstowej

   Znajdź zamówienia, dla których:

      Shipping.CountryRegionCode = US

   Użyj funkcji:

      JSON_CONTAINS

   Wynik powinien zawierać:

      OrderID
      CountryRegionCode
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 12. Sprawdź JSON_CONTAINS dla wartości liczbowej

   Znajdź zamówienia, dla których w dokumencie JSON występuje:

      SalesPersonID = 279

   Jeżeli taka wartość nie występuje w Twoich danych,
   najpierw znajdź przykładową wartość SalesPersonID
   i użyj jej w filtrze.
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 13. Znajdź zamówienia zawierające wybrany produkt

   Znajdź zamówienia, w których tablica Items zawiera:

      ProductID = 776

   Użyj funkcji:

      JSON_CONTAINS

   oraz ścieżki z wildcardem:

      $.Items[*].ProductID
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 14. Porównaj JSON_PATH_EXISTS i JSON_CONTAINS

   Dla pierwszych 20 zamówień pokaż:

      OrderID
      CountryRegionCode
      HasCountryRegionCode
      ContainsUS

   Gdzie:

      HasCountryRegionCode = JSON_PATH_EXISTS dla $.Shipping.CountryRegionCode
      ContainsUS           = JSON_CONTAINS dla wartości US w $.Shipping.CountryRegionCode
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 15. Sprawdź ProductID przez JSON_PATH_EXISTS i JSON_CONTAINS

   Dla pierwszych 20 zamówień pokaż:

      OrderID
      HasAnyProductID
      ContainsProduct776

   Gdzie:

      HasAnyProductID    = czy istnieje $.Items[*].ProductID
      ContainsProduct776 = czy w $.Items[*].ProductID występuje 776
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 16. Znajdź zamówienia bez wybranej ścieżki

   Znajdź zamówienia, dla których nie istnieje ścieżka:

      $.SalesPersonID

   albo jej wartość jest pusta.
   ============================================================ */

-- tu wstaw Twój kod

GO