/*
    Warsztaty JSON: 02. Zamiana JSON na wiersze - OPENJSON - lab

    Tomasz Libera | MVP Data Platform
    libera@kursysql.pl

    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL

    Ten skrypt zawiera zadania do samodzielnego wykonania.

    Opis części i pełna treść zadań:

        02-A-openjson.md

    Przykładowe rozwiązania:

        02-C-openjson-labsolution.sql
*/

USE AdventureWorks2025;
GO

/* ============================================================
   Zadanie 1. Podejrzyj dokument z tablicą Items

   Wyświetl pierwsze 10 dokumentów z tabeli:

      DemoJson.OrderDocs_Text

   Pokaż kolumny:

      OrderID
      OrderDoc

   Posortuj wynik po OrderID.
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 2. Odczytaj tablicę Items jako JSON

   Dla pierwszych 10 zamówień odczytaj tablicę:

      Items

   Użyj funkcji:

      JSON_QUERY

   Pokaż kolumny:

      OrderID
      Items
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 3. Użyj OPENJSON na prostej tablicy

   Utwórz zmienną z prostą tablicą JSON:

      ["SQL Server", "JSON", "OPENJSON"]

   Następnie użyj OPENJSON, aby zamienić tę tablicę na wiersze.
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 4. Sprawdź domyślne kolumny OPENJSON

   Dla poprzedniego przykładu sprawdź, jakie wartości pojawiają się
   w kolumnach:

      key
      value
      type

   Pytanie kontrolne:
   Co oznacza kolumna key w przypadku tablicy JSON?
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 5. Użyj OPENJSON na prostym obiekcie

   Utwórz zmienną z prostym obiektem JSON:

      {
        "ProductID": 776,
        "Name": "Mountain-100 Black, 42",
        "OrderQty": 1
      }

   Następnie użyj OPENJSON, aby zobaczyć wynik domyślny.
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 6. Rozbij tablicę Items dla jednego zamówienia

   Wybierz jedno zamówienie z tabeli:

      DemoJson.OrderDocs_Text

   i użyj OPENJSON, aby rozbić jego tablicę:

      Items

   na wiersze.

   Na tym etapie użyj domyślnego schematu OPENJSON, czyli kolumn:

      key
      value
      type
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 7. Zmapuj pozycje zamówienia na kolumny

   Dla wybranego zamówienia użyj OPENJSON z klauzulą WITH.

   Odczytaj kolumny:

      ProductID
      ProductNumber
      Name
      OrderQty
      UnitPrice
      LineTotal

   Dobierz odpowiednie typy danych.
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 8. Dodaj OrderID z tabeli

   Zmodyfikuj poprzednie zapytanie tak, aby w wyniku pojawił się
   również OrderID z tabeli:

      DemoJson.OrderDocs_Text

   Wynik powinien zawierać:

      OrderID
      ProductID
      ProductNumber
      Name
      OrderQty
      UnitPrice
      LineTotal
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 9. Rozbij Items dla wielu zamówień

   Użyj CROSS APPLY, aby rozbić tablicę Items dla wielu zamówień.

   Pokaż pierwsze 100 wierszy wyniku.

   Wynik powinien zawierać:

      OrderID
      ProductID
      Name
      OrderQty
      UnitPrice
      LineTotal
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 10. Przefiltruj po ProductID

   Znajdź pozycje zamówień, dla których:

      ProductID = 776

   Jeżeli taki produkt nie występuje w Twoich danych, użyj innej
   wartości znalezionej w poprzednich wynikach.
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 11. Przefiltruj po ilości

   Znajdź pozycje zamówień, dla których:

      OrderQty > 1

   Wynik powinien zawierać:

      OrderID
      ProductID
      Name
      OrderQty
      UnitPrice
      LineTotal
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 12. Przelicz wartość pozycji

   Dla pozycji zamówień oblicz wartość:

      OrderQty * UnitPrice

   Porównaj ją z wartością:

      LineTotal

   Wynik powinien zawierać:

      OrderID
      ProductID
      Name
      OrderQty
      UnitPrice
      CalculatedLineTotal
      LineTotal
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 13. Policz liczbę pozycji w zamówieniu

   Dla każdego zamówienia policz liczbę elementów w tablicy:

      Items

   Wynik powinien zawierać:

      OrderID
      ItemsCount
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 14. Policz wartość pozycji w zamówieniu

   Dla każdego zamówienia policz sumę wartości pozycji z tablicy Items.

   Wynik powinien zawierać:

      OrderID
      ItemsTotal
   ============================================================ */

-- tu wstaw Twój kod

GO


/* ============================================================
   Zadanie 15. Połącz dane z JSON_VALUE i OPENJSON

   Przygotuj zapytanie, które zwróci informacje o zamówieniach
   i ich pozycjach.

   Z poziomu dokumentu zamówienia odczytaj:

      OrderDate
      Status
      Customer.CustomerID

   Z tablicy Items odczytaj:

      ProductID
      Name
      OrderQty
      UnitPrice
      LineTotal

   Wynik powinien zawierać:

      OrderID
      OrderDate
      Status
      CustomerID
      ProductID
      Name
      OrderQty
      UnitPrice
      LineTotal
   ============================================================ */

-- tu wstaw Twój kod

GO