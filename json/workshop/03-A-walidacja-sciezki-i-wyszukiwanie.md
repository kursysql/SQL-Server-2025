<a href="https://www.kursysql.pl"><img src="https://www.kursysql.pl/wp-content/uploads/2022/03/Frame-3.png" title="KursySQL.pl" alt="KursySQL.pl"></a>

# 03. Walidacja, ścieżki i wyszukiwanie w JSON

## Spis treści

- [Cel tej części](#cel-tej-części)
- [Pliki używane w tej części](#pliki-używane-w-tej-części)
- [Wprowadzenie](#wprowadzenie)
- [ISJSON](#isjson)
- [JSON_PATH_EXISTS](#json_path_exists)
- [JSON_CONTAINS](#json_contains)
- [JSON_PATH_EXISTS vs JSON_CONTAINS](#json_path_exists-vs-json_contains)
- [Demo](#demo)
- [Zadania do wykonania](#zadania-do-wykonania)
- [Pytania kontrolne](#pytania-kontrolne)
- [Co dalej?](#co-dalej)

---

## Cel tej części

W poprzednich częściach odczytywaliśmy dane z dokumentów JSON oraz rozbijaliśmy tablice JSON na wiersze.

W tej części skupimy się na sprawdzaniu dokumentów JSON:

- czy tekst jest poprawnym JSON,
- czy w dokumencie istnieje dana ścieżka,
- czy dokument zawiera konkretną wartość.

Poznasz trzy funkcje:

- `ISJSON`,
- `JSON_PATH_EXISTS`,
- `JSON_CONTAINS`.

Po wykonaniu tej części powinieneś umieć:

- sprawdzić, czy tekst zawiera poprawny JSON,
- sprawdzić, czy JSON jest obiektem, tablicą albo wartością,
- sprawdzić, czy w dokumencie istnieje określona ścieżka,
- użyć wildcarda `[*]` dla tablic JSON,
- sprawdzić, czy dokument zawiera konkretną wartość,
- odróżnić sprawdzanie istnienia ścieżki od sprawdzania zawartości.

---

## Pliki używane w tej części

Skrypty demonstracyjne z repozytorium:

- [`sqlserver2025-tsql-json04-isjson.sql`](../sqlserver2025-tsql-json04-isjson.sql)
- [`sqlserver2025-tsql-json05-json_path_exists.sql`](../sqlserver2025-tsql-json05-json_path_exists.sql)
- [`sqlserver2025-tsql-json06-json_contains.sql`](../sqlserver2025-tsql-json06-json_contains.sql)

Rozwiązania zadań:

- [`03-B-walidacja-sciezki-i-wyszukiwanie-labsolution.sql`](03-B-walidacja-sciezki-i-wyszukiwanie-labsolution.sql)

Wymagany setup:

- [`sqlserver2025-tsql-json00-SETUP.sql`](../sqlserver2025-tsql-json00-SETUP.sql)

---

## Wprowadzenie

Do tej pory zakładaliśmy, że dokument JSON ma oczekiwaną strukturę.

W praktyce często trzeba najpierw odpowiedzieć na pytania:

```text
Czy to w ogóle jest poprawny JSON?
Czy dokument ma sekcję Customer?
Czy dokument ma tablicę Items?
Czy w tablicy Items występuje ProductID = 776?
Czy dokument zawiera zamówienie wysłane do konkretnego kraju?
```

Do takich przypadków służą funkcje z tej części.

---

## ISJSON

`ISJSON` sprawdza, czy tekst zawiera poprawny JSON.

Przykład:

```sql
SELECT ISJSON(N'{"ProductID": 776, "Name": "Mountain-100 Black, 42"}') AS IsValidJson;
```

Wynik:

```text
1
```

Przykład błędnego JSON:

```sql
SELECT ISJSON(N'{ProductID: 776}') AS IsValidJson;
```

Wynik:

```text
0
```

Funkcja może też sprawdzać konkretny typ JSON:

```sql
ISJSON(expression, VALUE)
ISJSON(expression, ARRAY)
ISJSON(expression, OBJECT)
ISJSON(expression, SCALAR)
```

Przykłady:

```sql
SELECT ISJSON(N'{"ProductID": 776}', OBJECT) AS IsJsonObject;
SELECT ISJSON(N'[1, 2, 3]', ARRAY) AS IsJsonArray;
SELECT ISJSON(N'"SQL Server"', SCALAR) AS IsJsonScalar;
```

---

## JSON_PATH_EXISTS

`JSON_PATH_EXISTS` sprawdza, czy dana ścieżka istnieje w dokumencie JSON.

Przykład:

```sql
SELECT TOP (10)
    OrderID,
    JSON_PATH_EXISTS(OrderDoc, '$.Customer') AS HasCustomer,
    JSON_PATH_EXISTS(OrderDoc, '$.Items') AS HasItems
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;
```

Funkcja zwraca:

```text
1     ścieżka istnieje
0     ścieżka nie istnieje
NULL  wejściowy dokument albo argument jest NULL
```

`JSON_PATH_EXISTS` nie odczytuje wartości.  
Odpowiada tylko na pytanie: czy taka ścieżka istnieje?

Przykład z tablicą:

```sql
SELECT TOP (10)
    OrderID,
    JSON_PATH_EXISTS(OrderDoc, '$.Items[*].ProductID') AS HasAnyProductID
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;
```

Wildcard `[*]` oznacza: sprawdź wszystkie elementy tablicy.



|OrderID|HasAnyProductID|
|---|---|
|43659|1|
|43660|1|
|43661|1|
|43662|1|
|43663|1|
|43664|1|
|43665|1|
|43666|1|
|43667|1|
|43668|1|

---

## JSON_CONTAINS

`JSON_CONTAINS` sprawdza, czy dokument JSON zawiera konkretną wartość we wskazanej ścieżce.

Przykład:

```sql
SELECT TOP (5)
    OrderID,
    JSON_VALUE(OrderDoc, '$.Shipping.CountryRegionCode') AS CountryRegionCode
FROM DemoJson.OrderDocs_Json
WHERE JSON_CONTAINS(OrderDoc, N'US', '$.Shipping.CountryRegionCode') = 1
ORDER BY OrderID;
```

|OrderID|CountryRegionCode|
|---|---|
|43659|US|
|43660|US|
|43663|US|
|43664|US|
|43665|US|


Przykład z tablicą `Items`:

```sql
SELECT TOP (5)
    OrderID
FROM DemoJson.OrderDocs_Json
WHERE JSON_CONTAINS(OrderDoc, 776, '$.Items[*].ProductID') = 1
ORDER BY OrderID;
```

|OrderID|
|---|
|43659|
|43661|
|43665|
|43670|
|43672|

W tym przypadku sprawdzamy, czy w dowolnym elemencie tablicy `Items` istnieje:

```text
ProductID = 776
```

Ważne:

```text
$.Items.ProductID      -- niepoprawne dla tablicy
$.Items[*].ProductID   -- sprawdza ProductID w każdym elemencie tablicy
```

---

## JSON_PATH_EXISTS vs JSON_CONTAINS

Te funkcje odpowiadają na różne pytania.

| Pytanie | Funkcja |
|---|---|
| Czy istnieje ścieżka `$.Customer`? | `JSON_PATH_EXISTS` |
| Czy istnieje ścieżka `$.Items[*].ProductID`? | `JSON_PATH_EXISTS` |
| Czy `Shipping.CountryRegionCode` ma wartość `US`? | `JSON_CONTAINS` |
| Czy w tablicy `Items` jest produkt `776`? | `JSON_CONTAINS` |

Przykład:

```sql
SELECT TOP (5)
    OrderID,
    JSON_PATH_EXISTS(OrderDoc, '$.Shipping.CountryRegionCode') AS HasCountryRegionCode,
    JSON_CONTAINS(OrderDoc, N'US', '$.Shipping.CountryRegionCode') AS ContainsUS
FROM DemoJson.OrderDocs_Json
ORDER BY OrderID;
```

Pierwsza kolumna mówi, czy pole istnieje.  
Druga kolumna mówi, czy pole zawiera konkretną wartość.


|OrderID|HasCountryRegionCode|ContainsUS|
|---|---|---|
|43659|1|1|
|43660|1|1|
|43661|1|0|
|43662|1|0|
|43663|1|1|

---

## Demo

Do części demonstracyjnej używamy skryptów z repozytorium:

- [`sqlserver2025-tsql-json04-isjson.sql`](../sqlserver2025-tsql-json04-isjson.sql)
- [`sqlserver2025-tsql-json05-json_path_exists.sql`](../sqlserver2025-tsql-json05-json_path_exists.sql)
- [`sqlserver2025-tsql-json06-json_contains.sql`](../sqlserver2025-tsql-json06-json_contains.sql)


---

## Zadania do wykonania

### Zadanie 1. Sprawdź poprawność dokumentów JSON

Sprawdź, czy dokumenty w tabeli:

```text
DemoJson.OrderDocs_Text
```

są poprawnym JSON.

Użyj funkcji:

```sql
ISJSON
```

Wynik powinien pokazać liczbę dokumentów poprawnych i niepoprawnych.


---

### Zadanie 2. Znajdź niepoprawne dokumenty JSON

Wyświetl dokumenty z tabeli:

```text
DemoJson.OrderDocs_Text
```

dla których `ISJSON` nie zwraca `1`.

---

### Zadanie 3. Sprawdź ISJSON dla przykładowych wartości

Utwórz zapytanie, które sprawdzi `ISJSON` dla poniższych wartości:

```json
{"ProductID": 776}
[1, 2, 3]
"SQL Server"
123
true
{ProductID: 776}
```

Pokaż wynik w kolumnach:

```text
JsonText
IsJson
```

---

### Zadanie 4. Sprawdź typ JSON przez ISJSON

Dla przykładowych wartości z poprzedniego zadania sprawdź:

```sql
ISJSON(JsonText, VALUE)
ISJSON(JsonText, OBJECT)
ISJSON(JsonText, ARRAY)
ISJSON(JsonText, SCALAR)
```

---

### Zadanie 5. Sprawdź podstawowe ścieżki w dokumencie

Dla pierwszych 10 zamówień sprawdź, czy istnieją ścieżki:

```text
$.OrderID
$.Customer
$.Shipping
$.Totals
$.Items
```

Użyj funkcji:

```sql
JSON_PATH_EXISTS
```

---

### Zadanie 6. Sprawdź ścieżki zagnieżdżone

Dla pierwszych 10 zamówień sprawdź, czy istnieją ścieżki:

```text
$.Customer.CustomerID
$.Customer.AccountNumber
$.Shipping.City
$.Shipping.CountryRegionCode
$.Totals.TotalDue
```

```sql
-- Twoje rozwiązanie
```

---

### Zadanie 7. Sprawdź nieistniejącą ścieżkę

Sprawdź, co zwraca `JSON_PATH_EXISTS` dla ścieżki:

```text
$.DoesNotExist
```

---

### Zadanie 8. Sprawdź ścieżkę w tablicy Items

Dla pierwszych 10 zamówień sprawdź, czy w tablicy `Items` występuje właściwość:

```text
ProductID
```

Użyj ścieżki:

```text
$.Items[*].ProductID
```

---

### Zadanie 9. Znajdź zamówienia, które mają tablicę Items

Wyświetl zamówienia, dla których istnieje ścieżka:

```text
$.Items
```

Wynik powinien zawierać:

```text
OrderID
Items
```

---

### Zadanie 10. Znajdź zamówienia z krajem wysyłki

Znajdź zamówienia, dla których istnieje ścieżka:

```text
$.Shipping.CountryRegionCode
```

Wynik powinien zawierać:

```text
OrderID
CountryRegionCode
```

---

### Zadanie 11. Sprawdź JSON_CONTAINS dla wartości tekstowej

Znajdź zamówienia, dla których:

```text
Shipping.CountryRegionCode = US
```

Użyj funkcji:

```sql
JSON_CONTAINS
```

Wynik powinien zawierać:

```text
OrderID
CountryRegionCode
```


---

### Zadanie 12. Sprawdź JSON_CONTAINS dla wartości liczbowej

Znajdź zamówienia, dla których w dokumencie JSON występuje:

```text
SalesPersonID = 279
```

Jeżeli taka wartość nie występuje w Twoich danych, najpierw znajdź przykładową wartość `SalesPersonID` i użyj jej w filtrze.


---

### Zadanie 13. Znajdź zamówienia zawierające wybrany produkt

Znajdź zamówienia, w których tablica `Items` zawiera:

```text
ProductID = 776
```

Użyj funkcji:

```sql
JSON_CONTAINS
```

oraz ścieżki z wildcardem:

```text
$.Items[*].ProductID
```

```sql
-- Twoje rozwiązanie
```

---

### Zadanie 14. Porównaj JSON_PATH_EXISTS i JSON_CONTAINS

Dla pierwszych 20 zamówień pokaż:

```text
OrderID
CountryRegionCode
HasCountryRegionCode
ContainsUS
```

Gdzie:

```text
HasCountryRegionCode = JSON_PATH_EXISTS dla $.Shipping.CountryRegionCode
ContainsUS           = JSON_CONTAINS dla wartości US w $.Shipping.CountryRegionCode
```

---

### Zadanie 15. Sprawdź ProductID przez JSON_PATH_EXISTS i JSON_CONTAINS

Dla pierwszych 20 zamówień pokaż:

```text
OrderID
HasAnyProductID
ContainsProduct776
```

Gdzie:

```text
HasAnyProductID     = czy istnieje $.Items[*].ProductID
ContainsProduct776  = czy w $.Items[*].ProductID występuje 776
```

---

### Zadanie 16. Znajdź zamówienia bez wybranej ścieżki

Znajdź zamówienia, dla których nie istnieje ścieżka:

```text
$.SalesPersonID
```

albo jej wartość jest pusta.


---


## Pytania kontrolne

1. Do czego służy `ISJSON`?
2. Co zwraca `ISJSON`, gdy tekst nie jest poprawnym JSON?
3. Do czego służy drugi argument funkcji `ISJSON`?
4. Do czego służy `JSON_PATH_EXISTS`?
5. Czy `JSON_PATH_EXISTS` odczytuje wartość ze ścieżki?
6. Do czego służy `JSON_CONTAINS`?
7. Czym różni się `JSON_PATH_EXISTS` od `JSON_CONTAINS`?
8. Po co używamy wildcarda `[*]` przy tablicach JSON?
9. Jak sprawdzić, czy w tablicy `Items` istnieje dowolny `ProductID`?
10. Jak sprawdzić, czy w tablicy `Items` występuje konkretny `ProductID`?

---

## Co dalej?

W tej części sprawdzaliśmy poprawność, strukturę i zawartość dokumentów JSON.

W kolejnym rozdziale przejdziemy do modyfikowania dokumentów JSON przy użyciu:

- `JSON_MODIFY`.