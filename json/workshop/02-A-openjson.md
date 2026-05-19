<a href="https://www.kursysql.pl"><img src="https://www.kursysql.pl/wp-content/uploads/2022/03/Frame-3.png" title="KursySQL.pl" alt="KursySQL.pl"></a>

# 02. Zamiana JSON na wiersze - OPENJSON

## Spis treści

- [Cel tej części](#cel-tej-części)
- [Pliki używane w tej części](#pliki-używane-w-tej-części)
- [Wprowadzenie](#wprowadzenie)
- [OPENJSON](#openjson)
- [OPENJSON z domyślnym schematem](#openjson-z-domyślnym-schematem)
- [OPENJSON z klauzulą WITH](#openjson-z-klauzulą-with)
- [CROSS APPLY](#cross-apply)
- [OPENJSON vs JSON_VALUE i JSON_QUERY](#openjson-vs-json_value-i-json_query)
- [Demo](#demo)
- [Zadania do wykonania](#zadania-do-wykonania)
- [Pytania kontrolne](#pytania-kontrolne)
- [Co dalej?](#co-dalej)

---

## Cel tej części

W poprzedniej części odczytywaliśmy pojedyncze wartości, obiekty i tablice JSON za pomocą:

- `JSON_VALUE`,
- `JSON_QUERY`.

Problem pojawia się wtedy, gdy w dokumencie JSON mamy tablicę i chcemy potraktować jej elementy jak klasyczne wiersze SQL.

W tej części użyjemy funkcji:

- `OPENJSON`.

Po wykonaniu tej części powinieneś umieć:

- rozbić tablicę JSON na wiersze,
- sprawdzić wynik `OPENJSON` z domyślnym schematem,
- użyć `OPENJSON` z klauzulą `WITH`,
- zmapować właściwości JSON na kolumny SQL,
- nadać kolumnom odpowiednie typy danych,
- użyć `CROSS APPLY` do przetwarzania tablic JSON zapisanych w wielu wierszach tabeli,
- filtrować i agregować dane pochodzące z tablic JSON.

---

## Pliki używane w tej części

Skrypt demonstracyjny z repozytorium:

- [`sqlserver2025-tsql-json03-openjson.sql`](../sqlserver2025-tsql-json03-openjson.sql)

Skrypt lab do samodzielnego wykonania:

- [`02-B-openjson-lab.sql`](02-B-openjson-lab.sql)

Rozwiązania zadań:

- [`02-C-openjson-labsolution.sql`](02-C-openjson-labsolution.sql)

Wymagany setup:

- [`sqlserver2025-tsql-json00-SETUP.sql`](../sqlserver2025-tsql-json00-SETUP.sql)

---

## Wprowadzenie

W dokumencie zamówienia mamy tablicę `Items`.

W uproszczeniu wygląda ona tak:

```json
{
  "OrderID": 43672,
  "OrderDate": "2011-05-31",
  "Status": "Shipped",
  "Items": [
    {
      "ProductID": 776,
      "ProductNumber": "BK-M82B-42",
      "Name": "Mountain-100 Black, 42",
      "OrderQty": 1,
      "UnitPrice": 2024.99,
      "LineTotal": 2024.99
    },
    {
      "ProductID": 777,
      "ProductNumber": "BK-M82B-44",
      "Name": "Mountain-100 Black, 44",
      "OrderQty": 1,
      "UnitPrice": 2024.99,
      "LineTotal": 2024.99
    }
  ]
}
```

W części `01` mogliśmy odczytać pierwszy element tablicy tak:

```sql
JSON_VALUE(OrderDoc, '$.Items[0].ProductID')
```

albo drugi element tak:

```sql
JSON_VALUE(OrderDoc, '$.Items[1].ProductID')
```

To działa, ale tylko wtedy, gdy znamy konkretną pozycję w tablicy.

Jeżeli chcemy odczytać wszystkie pozycje zamówienia, potrzebujemy innego podejścia.

Do tego służy:

```sql
OPENJSON
```

---

## OPENJSON

`OPENJSON` zamienia obiekt lub tablicę JSON na zestaw wierszy.

Najprostszy przykład:

```sql
DECLARE @json nvarchar(max) = N'["SQL Server", "JSON", "OPENJSON"]';

SELECT *
FROM OPENJSON(@json);
```

Wynik zawiera trzy kolumny:
- **key** - nazwa właściwości albo indeks elementu tablicy
- **value** - wartość elementu
- **type** - typ elementu JSON


| key | value       | type |
|---|-------------|------|
| 0 | SQL Server  | 1    |
| 1 | JSON        | 1    |
| 2 | OPENJSON    | 1    |

Typy danych (`type`) są reprezentowane przez liczby:
	OPENJSON zwraca 3 kolumny, a w type:

    0 - NULL
	1 - String
	2 - Number
	3 - Boolean
	4 - Array
	5 - Object


---

## OPENJSON z domyślnym schematem

Jeżeli użyjemy `OPENJSON` bez klauzuli `WITH`, SQL Server zwróci domyślne kolumny:

```text
key
value
type
```

Przykład dla tablicy `Items`:

```sql
DECLARE @SampleJSON nvarchar(max) = (SELECT OrderDoc FROM DemoJson.OrderDocs_Text WHERE OrderID = 43672);

SELECT * FROM OPENJSON(@SampleJSON, '$.Items')
GO
```

| key |	value | type
|---|---|---|
|0|{"SalesOrderDetailID":126,"ProductID":709,"ProductNumber":"SO-B909-M","Name":"Mountain Bike Socks, M","OrderQty":6,"UnitPrice":5.7000,"LineTotal":34.200000}|5|
|1|{"SalesOrderDetailID":127,"ProductID":776,"ProductNumber":"BK-M82B-42","Name":"Mountain-100 Black, 42","OrderQty":2,"UnitPrice":2024.9940,"LineTotal":4049.988000}|5|
|2|{"SalesOrderDetailID":128,"ProductID":774,"ProductNumber":"BK-M82S-48","Name":"Mountain-100 Silver, 48","OrderQty":1,"UnitPrice":2039.9940,"LineTotal":2039.994000}|5|


To jest dobre do szybkiego podejrzenia struktury JSON.

Nie jest to jednak najwygodniejszy format do dalszej analizy, bo każdy element tablicy jest nadal fragmentem JSON zapisanym w kolumnie `value`.

---

## OPENJSON z klauzulą WITH

W praktyce często używamy `OPENJSON` z klauzulą `WITH`.

Dzięki temu możemy powiedzieć SQL Serverowi:

- jakie kolumny chcemy dostać,
- z jakich ścieżek JSON mają pochodzić,
- jakie typy danych mają mieć wynikowe kolumny.

Przykład:

```sql
DECLARE @SampleJSON nvarchar(max) = (SELECT OrderDoc FROM DemoJson.OrderDocs_Text WHERE OrderID = 43672);

SELECT *
FROM OPENJSON(@SampleJSON, '$.Items')
WITH
(
    SalesOrderDetailID INT,
    ProductID INT,
    Name NVARCHAR(100), 
    OrderQty INT,
    UnitPrice MONEY
)
GO
```

Wynik jest już klasyczną tabelą:


|SalesOrderDetailID|ProductID|Name|OrderQty|UnitPrice|
|---|---|---|---|---|
|126|709|Mountain Bike Socks, M|6|5,70|
|127|776|Mountain-100 Black, 42|2|2024,994|
|128|774|Mountain-100 Silver, 48|1|2039,994|


Od tego momentu możemy używać normalnych mechanizmów SQL:

- `WHERE`,
- `ORDER BY`,
- `GROUP BY`,
- agregacji,
- joinów,
- konwersji typów,
- obliczeń.

---

## CROSS APPLY

`OPENJSON` często łączymy z tabelą za pomocą `CROSS APPLY`.

Dlaczego?

Ponieważ w tabeli `DemoJson.OrderDocs_Text` każdy wiersz zawiera osobny dokument JSON.

```text
jeden wiersz tabeli = jedno zamówienie
jedna tablica Items = wiele pozycji zamówienia
```

`CROSS APPLY` pozwala uruchomić `OPENJSON` osobno dla każdego wiersza tabeli.

Przykład:

```sql
SELECT Items.*
FROM DemoJson.OrderDocs_Text
CROSS APPLY OPENJSON(OrderDoc, '$.Items')
WITH 
(
    SalesOrderDetailID INT,
    ProductID INT,
    Name NVARCHAR(100), 
    OrderQty INT,
    UnitPrice MONEY
) AS Items
WHERE OrderID = 43672;
```

W efekcie z jednego dokumentu JSON możemy uzyskać wiele wierszy wyniku.

|SalesOrderDetailID|ProductID|Name|OrderQty|UnitPrice|
|---|---|---|---|---|
|126|709|Mountain Bike Socks, M|6|5,70|
|127|776|Mountain-100 Black, 42|2|2024,994|
|128|774|Mountain-100 Silver, 48|1|2039,994|

---

## OPENJSON vs JSON_VALUE i JSON_QUERY

Każda z tych funkcji odpowiada na trochę inne pytanie.

| Potrzeba | Funkcja |
|---|---|
| Odczytać jedną wartość | `JSON_VALUE` |
| Odczytać obiekt lub tablicę jako JSON | `JSON_QUERY` |
| Zamienić obiekt lub tablicę JSON na wiersze | `OPENJSON` |

Przykład:

```sql
JSON_VALUE(OrderDoc, '$.Items[0].ProductID')
```

odczytuje `ProductID` pierwszego elementu tablicy.

```sql
JSON_QUERY(OrderDoc, '$.Items')
```

odczytuje całą tablicę `Items` jako JSON.

```sql
OPENJSON(OrderDoc, '$.Items')
```

rozbija tablicę `Items` na wiersze.

---

## Demo

Skrypt demonstracyjny z repozytorium:

- [`sqlserver2025-tsql-json03-openjson.sql`](../sqlserver2025-tsql-json03-openjson.sql)

---

## Zadania do wykonania

### Zadanie 1. Podejrzyj dokument z tablicą Items

Wyświetl pierwsze 10 dokumentów z tabeli:

```text
DemoJson.OrderDocs_Text
```

Pokaż kolumny:

```text
OrderID
OrderDoc
```

Posortuj wynik po `OrderID`.



---

### Zadanie 2. Odczytaj tablicę Items jako JSON

Dla pierwszych 10 zamówień odczytaj tablicę:

```text
Items
```

Użyj funkcji:

```sql
JSON_QUERY
```

Pokaż kolumny:

```text
OrderID
Items
```


---

### Zadanie 3. Użyj OPENJSON na prostej tablicy

Utwórz zmienną z prostą tablicą JSON:

```json
["SQL Server", "JSON", "OPENJSON"]
```

Następnie użyj `OPENJSON`, aby zamienić tę tablicę na wiersze.


---

### Zadanie 4. Sprawdź domyślne kolumny OPENJSON

Dla poprzedniego przykładu sprawdź, jakie wartości pojawiają się w kolumnach:

```text
key
value
type
```

### Pytanie kontrolne

Co oznacza kolumna `key` w przypadku tablicy JSON?

---

### Zadanie 5. Użyj OPENJSON na prostym obiekcie

Utwórz zmienną z prostym obiektem JSON:

```json
{
  "ProductID": 776,
  "Name": "Mountain-100 Black, 42",
  "OrderQty": 1
}
```

Następnie użyj `OPENJSON`, aby zobaczyć wynik domyślny.


---

### Zadanie 6. Rozbij tablicę Items dla jednego zamówienia

Wybierz jedno zamówienie z tabeli:

```text
DemoJson.OrderDocs_Text
```

i użyj `OPENJSON`, aby rozbić jego tablicę:

```text
Items
```

na wiersze.

Na tym etapie użyj domyślnego schematu `OPENJSON`, czyli kolumn:

```text
key
value
type
```

---

### Zadanie 7. Zmapuj pozycje zamówienia na kolumny

Dla wybranego zamówienia użyj `OPENJSON` z klauzulą `WITH`.

Odczytaj kolumny:

```text
ProductID
ProductNumber
Name
OrderQty
UnitPrice
LineTotal
```

Dobierz odpowiednie typy danych.

---

### Zadanie 8. Dodaj OrderID z tabeli

Zmodyfikuj poprzednie zapytanie tak, aby w wyniku pojawił się również `OrderID` z tabeli:

```text
DemoJson.OrderDocs_Text
```

Wynik powinien zawierać:

```text
OrderID
ProductID
ProductNumber
Name
OrderQty
UnitPrice
LineTotal
```

---

### Zadanie 9. Rozbij Items dla wielu zamówień

Użyj `CROSS APPLY`, aby rozbić tablicę `Items` dla wielu zamówień.

Pokaż pierwsze 100 wierszy wyniku.

Wynik powinien zawierać:

```text
OrderID
ProductID
Name
OrderQty
UnitPrice
LineTotal
```

---

### Zadanie 10. Przefiltruj po ProductID

Znajdź pozycje zamówień, dla których:

```text
ProductID = 776
```

Jeżeli taki produkt nie występuje w Twoich danych, użyj innej wartości znalezionej w poprzednich wynikach.

---

### Zadanie 11. Przefiltruj po ilości

Znajdź pozycje zamówień, dla których:

```text
OrderQty > 1
```

Wynik powinien zawierać:

```text
OrderID
ProductID
Name
OrderQty
UnitPrice
LineTotal
```


---

### Zadanie 12. Przelicz wartość pozycji

Dla pozycji zamówień oblicz wartość:

```text
OrderQty * UnitPrice
```

Porównaj ją z wartością:

```text
LineTotal
```

Wynik powinien zawierać:

```text
OrderID
ProductID
Name
OrderQty
UnitPrice
CalculatedLineTotal
LineTotal
```

---

### Zadanie 13. Policz liczbę pozycji w zamówieniu

Dla każdego zamówienia policz liczbę elementów w tablicy:

```text
Items
```

Wynik powinien zawierać:

```text
OrderID
ItemsCount
```

---

### Zadanie 14. Policz wartość pozycji w zamówieniu

Dla każdego zamówienia policz sumę wartości pozycji z tablicy `Items`.

Wynik powinien zawierać:

```text
OrderID
ItemsTotal
```


---

### Zadanie 15. Połącz dane z JSON_VALUE i OPENJSON

Przygotuj zapytanie, które zwróci informacje o zamówieniach i ich pozycjach.

Z poziomu dokumentu zamówienia odczytaj:

```text
OrderDate
Status
Customer.CustomerID
```

Z tablicy `Items` odczytaj:

```text
ProductID
Name
OrderQty
UnitPrice
LineTotal
```

Wynik powinien zawierać:

```text
OrderID
OrderDate
Status
CustomerID
ProductID
Name
OrderQty
UnitPrice
LineTotal
```

---



## Pytania kontrolne

1. Do czego służy `OPENJSON`?
2. Jakie trzy kolumny zwraca `OPENJSON` bez klauzuli `WITH`?
3. Co oznacza kolumna `key` dla tablicy JSON?
4. Po co używamy klauzuli `WITH` w `OPENJSON`?
5. Dlaczego warto nadawać typy danych kolumnom w klauzuli `WITH`?
6. Do czego służy `CROSS APPLY` w połączeniu z `OPENJSON`?
7. Czym różni się `JSON_QUERY(OrderDoc, '$.Items')` od `OPENJSON(OrderDoc, '$.Items')`?
8. Dlaczego odczyt `Items[0]`, `Items[1]` itd. nie jest dobrym rozwiązaniem dla raportowania?
9. Jak policzyć liczbę elementów tablicy JSON?
10. Jak połączyć dane z głównego dokumentu JSON z elementami tablicy?

---

## Co dalej?

W tej części zamienialiśmy tablice JSON na klasyczne wiersze SQL.

To pozwala używać znanych mechanizmów relacyjnych:

- filtrowania,
- sortowania,
- agregacji,
- obliczeń,
- raportowania.

W kolejnym rozdziale przejdziemy do funkcji, które pomagają sprawdzać poprawność i zawartość dokumentów JSON:

- `ISJSON`,
- `JSON_PATH_EXISTS`,
- `JSON_CONTAINS`.