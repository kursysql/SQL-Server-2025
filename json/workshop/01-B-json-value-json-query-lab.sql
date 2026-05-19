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