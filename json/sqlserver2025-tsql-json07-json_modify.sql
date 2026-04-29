/*

    TSQL: JSON_MODIFY
    Tomasz Libera | MVP Data Platform
    libera@kursysql.pl

    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL
    https://github.com/kursysql/SQL-Server-2025/

    Funkcja JSON_MODIFY
    aktualizuje wartość właściwości w dokumencie JSON
    i zwraca zaktualizowany tekst JSON

    Składnia:
    JSON_MODIFY ( expression , path , newValue )

    Uwaga:
    - JSON_MODIFY aktualizuje JSON i zwraca nowy tekst JSON
    - można zaktualizować istniejącą właściwość
    - można dodać nową właściwość
    - można usunąć właściwość
    - domyślnie path działa w trybie lax
      - w lax ustawienie NULL zwykle usuwa właściwość, 
      - strict wymaga, żeby wskazana właściwość istniała
    - do tablic można użyć append

    1. Zacznijmy od prostego przykładu
    2. Dodawanie nowej właściwości
    3. Usuwanie właściwości
    4. Zmiana danych w zagnieżdżonym obiekcie
    5. Zmiana elementu tablicy
    6. Dodawanie elementu do tablicy (append)
    7. Wiele zmian w jednym dokumencie
    8. Praca z JSON-em z tabeli
    9. lax vs strict


    Dokumentacja:
    https://learn.microsoft.com/en-us/sql/t-sql/functions/json-modify-transact-sql?view=sql-server-ver17

*/

USE AdventureWorks2025
GO


/*
    -------------------------------------------------------------------
    1. Zacznijmy od prostego przykładu
    - aktualizacja istniejącej właściwości
    -------------------------------------------------------------------
*/

DECLARE @SampleJSON nvarchar(max) = N'
{
  "OrderID": 43672,
  "Status": 5,
  "OnlineOrder": false
}';

SELECT @SampleJSON AS OriginalJson;

SELECT JSON_MODIFY(@SampleJSON, '$.Status', 6) AS UpdatedStatus;
GO

---- strict - taki sam wynik
--SELECT JSON_MODIFY(@SampleJSON, 'strict $.Status', 6) AS UpdatedStatus;
--GO

-- więcej o strict w filmie: JSON_VALUE w SQL Server jak wyciągać wartości z JSON (9:28)
-- https://www.youtube.com/watch?v=7nzS6j9n-Ts&t=568s

/*
    -------------------------------------------------------------------
    2. Dodawanie nowej właściwości
    - jeśli właściwość nie istnieje, można ją dodać
    - domyślnie path działa w trybie lax
    -------------------------------------------------------------------
*/

DECLARE @SampleJSON nvarchar(max) = N'
{
  "OrderID": 43672,
  "Status": 5
}';

SELECT @SampleJSON AS OriginalJson;

SELECT JSON_MODIFY(@SampleJSON, '$.PromoCode', 'SQLDAY2026') AS AddedPromoCode;
GO

---- strict - spowoduje błąd, bo PromoCode nie istnieje
--SELECT JSON_MODIFY(@SampleJSON, 'strict $.PromoCode', 'SQLDAY2026') AS AddedPromoCode;
--GO



/*
    -------------------------------------------------------------------
    3. Usuwanie właściwości
    - w trybie lax ustawienie NULL usuwa właściwość
    -------------------------------------------------------------------
*/

DECLARE @SampleJSON nvarchar(max) = N'
{
  "OrderID": 43672,
  "Status": 5,
  "PromoCode": "SQLDAY2026"
}';

SELECT @SampleJSON AS OriginalJson;

SELECT JSON_MODIFY(@SampleJSON, '$.PromoCode', NULL) AS PromoCodeRemoved;

--- strict + NULL ustawia wartość null, ale nie usuwa właściwości
SELECT JSON_MODIFY(@SampleJSON, 'strict $.PromoCode', NULL) AS PromoCodeRemoved;
GO



/*
    -------------------------------------------------------------------
    4. JSON_MODIFY i zagnieżdżone obiekty
    - można aktualizować pola w obiektach zagnieżdżonych
    -------------------------------------------------------------------
*/

DECLARE @SampleJSON nvarchar(max) = N'
{
  "OrderID": 43672,
  "Customer": {
      "CustomerID": 11000,
      "Region": "EU"
  }
}';

SELECT @SampleJSON AS OriginalJson;

SELECT JSON_MODIFY(@SampleJSON, '$.Customer.Region', 'US') AS UpdatedRegion;
GO


/*
    -------------------------------------------------------------------
    5. JSON_MODIFY i elementy tablicy
    - można aktualizować konkretny element tablicy po indeksie
    - indeksy są zero-based
    -------------------------------------------------------------------
*/

DECLARE @SampleJSON nvarchar(max) = N'
{
  "Items": [
    {
      "ProductID": 709,
      "Name": "Mountain Bike Socks, M",
      "OrderQty": 6
    },
    {
      "ProductID": 776,
      "Name": "Mountain-100 Black, 42",
      "OrderQty": 2
    }
  ]
}';

SELECT @SampleJSON AS OriginalJson;

SELECT JSON_MODIFY(@SampleJSON, '$.Items[0].OrderQty', 10) AS UpdatedFirstItemQty;
GO


/*
    -------------------------------------------------------------------
    6. JSON_MODIFY i append
    - append pozwala dodać nowy element do tablicy
    -------------------------------------------------------------------
*/

DECLARE @SampleJSON nvarchar(max) = N'
{
  "Tags": ["json", "sqlserver"]
}';

SELECT @SampleJSON AS OriginalJson;

-- bez append: nadpisze całą tablicę
SELECT JSON_MODIFY(@SampleJSON, '$.Tags', 'sqlday') AS AppendedTag;

-- z append: doda nowy element do tablicy
SELECT JSON_MODIFY(@SampleJSON, 'append $.Tags', 'sqlday') AS AppendedTag;
GO


/*
    -------------------------------------------------------------------
    7. JSON_MODIFY i wiele zmian
    - każda funkcja robi jedną zmianę
    - dla wielu zmian można zagnieżdżać wywołania
    -------------------------------------------------------------------
*/

DECLARE @SampleJSON nvarchar(max) = N'
{
  "OrderID": 43672,
  "Status": 5,
  "Customer": {
      "Region": "EU"
  }
}';

SELECT @SampleJSON AS OriginalJson;

SELECT JSON_MODIFY(
           JSON_MODIFY(@SampleJSON, '$.Status', 6),
           '$.Customer.Region', 'US'
       ) AS MultipleChanges
GO




/*
    -------------------------------------------------------------------
    8. JSON_MODIFY na tabeli
    - tworzymy zmodyfikowaną wersję dokumentu w wyniku SELECT
    -------------------------------------------------------------------
*/

SELECT TOP (10)
    t.OrderID,
    JSON_MODIFY(t.OrderDoc, '$.Status', 10) AS ModifiedOrderDoc
FROM DemoJson.OrderDocs_Text AS t
ORDER BY t.OrderID;
GO


/*
    -------------------------------------------------------------------
    9. lax / strict
    - domyślnie obowiązuje lax
    - strict wymaga, żeby właściwość istniała
    - lax + NULL zwykle usuwa właściwość
    - strict + NULL ustawia wartość null
    https://learn.microsoft.com/en-us/sql/t-sql/functions/json-modify-transact-sql?view=sql-server-ver17#remarks
    -------------------------------------------------------------------
*/

DECLARE @SampleJSON nvarchar(max) = N'
{
  "OrderID": 43672,
  "Customer": {
      "Region": "EU"
  }
}';

SELECT @SampleJSON AS OriginalJson;

-- domyślnie lax: brakująca właściwość może zostać dodana
SELECT JSON_MODIFY(@SampleJSON, 'lax $.Customer.Country', 'PL') AS CountryAdded_Lax;
GO

-- strict: brakująca właściwość spowoduje błąd
DECLARE @SampleJSON nvarchar(max) = N'
{
  "OrderID": 43672,
  "Customer": {
      "Region": "EU"
  }
}';

SELECT JSON_MODIFY(@SampleJSON, 'strict $.Customer.Country', 'PL') AS CountryAdded_Strict;
GO


--- lax + NULL zwykle usuwa właściwość
--- strict + NULL ustawia wartość null
DECLARE @SampleJSON nvarchar(max) = N'
{
  "OrderID": 43672,
  "PromoCode": "SQLDAY2026"
}';

SELECT @SampleJSON AS OriginalJson;

SELECT JSON_MODIFY(@SampleJSON, 'lax $.PromoCode', NULL) AS PromoCodeRemoved_Lax;
GO

DECLARE @SampleJSON nvarchar(max) = N'
{
  "OrderID": 43672,
  "PromoCode": "SQLDAY2026"
}';

SELECT @SampleJSON AS OriginalJson;

SELECT JSON_MODIFY(@SampleJSON, 'strict $.PromoCode', NULL) AS PromoCodeSetToNull_Strict;
GO

