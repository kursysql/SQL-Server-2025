/*
    Warsztaty JSON: 04. Modyfikowanie dokumentów JSON - JSON_MODIFY - lab

    Tomasz Libera | MVP Data Platform
    libera@kursysql.pl

    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL

    Ten skrypt zawiera zadania do samodzielnego wykonania.

    Opis części i pełna treść zadań:

        04-A-json-modify.md

    Przykładowe rozwiązania:

        04-C-json-modify-labsolution.sql
*/

USE AdventureWorks2025;
GO

/* ============================================================
   Zadanie 1. Pobierz dokument JSON do zmiennej

   Pobierz jeden dokument z tabeli:

      DemoJson.OrderDocs_Text

   do zmiennej:

      @OrderDoc

   Następnie wyświetl dokument.
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 2. Sprawdź wartości przed modyfikacją

   Dla dokumentu zapisanego w zmiennej @OrderDoc odczytaj:

      OrderID
      Status
      SalesPersonID
      Customer.CustomerType
      Shipping.City
      Shipping.CountryRegionCode
      Items[0].ProductID
      Items[0].OrderQty

   Użyj funkcji:

      JSON_VALUE
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 3. Zmień status zamówienia

   Zmień wartość:

      Status

   na:

      Cancelled

   Użyj funkcji:

      JSON_MODIFY

   Następnie sprawdź nową wartość przez JSON_VALUE.
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 4. Dodaj nową właściwość na głównym poziomie

   Dodaj do dokumentu nową właściwość:

      WorkshopSource = KursySQL

   Następnie odczytaj ją za pomocą JSON_VALUE.
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 5. Zmień wartość w obiekcie Customer

   Zmień wartość:

      Customer.CustomerType

   na:

      VIP

   Następnie odczytaj:

      Customer.CustomerID
      Customer.CustomerType
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 6. Dodaj właściwość do obiektu Shipping

   Dodaj do obiektu:

      Shipping

   nową właściwość:

      DeliveryMethod = Courier

   Następnie odczytaj cały obiekt Shipping przez JSON_QUERY.
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 7. Usuń właściwość SalesPersonID

   Usuń z dokumentu właściwość:

      SalesPersonID

   Wykorzystaj JSON_MODIFY i wartość NULL.

   Następnie sprawdź, czy SalesPersonID nadal istnieje.
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 8. Zmień ilość w pierwszej pozycji zamówienia

   Zmień wartość:

      Items[0].OrderQty

   na:

      2

   Następnie odczytaj:

      Items[0].ProductID
      Items[0].Name
      Items[0].OrderQty
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 9. Zmień cenę w pierwszej pozycji zamówienia

   Zmień wartość:

      Items[0].UnitPrice

   na:

      1999.99

   Następnie odczytaj:

      Items[0].UnitPrice
      Items[0].LineTotal

   Pytanie kontrolne:
   Czy zmiana UnitPrice automatycznie przeliczyła LineTotal?
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 10. Dodaj nową właściwość Audit jako obiekt JSON

   Dodaj do dokumentu nową właściwość:

      Audit

   jako obiekt JSON:

      {
        "ModifiedBy": "Workshop",
        "Reason": "JSON_MODIFY demo"
      }

   Użyj JSON_QUERY, aby obiekt został dodany jako JSON,
   a nie jako zwykły tekst.
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 11. Dodaj nowy element do tablicy Items

   Dodaj do tablicy:

      Items

   nową pozycję:

      {
        "ProductID": 999,
        "Name": "Workshop Product",
        "OrderQty": 1,
        "UnitPrice": 100.00,
        "LineTotal": 100.00
      }

   Użyj:

      append
      JSON_QUERY

   Następnie odczytaj całą tablicę Items.
   ============================================================ */

-- tu wstaw Twój kod

GO