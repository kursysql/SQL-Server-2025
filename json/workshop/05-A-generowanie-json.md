<a href="https://www.kursysql.pl"><img src="https://www.kursysql.pl/wp-content/uploads/2022/03/Frame-3.png" title="KursySQL.pl" alt="KursySQL.pl"></a>

# 05. Generowanie JSON z danych relacyjnych

## Spis treści

- [Cel tej części](#cel-tej-części)
- [Pliki używane w tej części](#pliki-używane-w-tej-części)
- [Wprowadzenie](#wprowadzenie)
- [JSON_OBJECT](#json_object)
- [JSON_ARRAY](#json_array)
- [JSON_ARRAYAGG](#json_arrayagg)
- [JSON_OBJECTAGG](#json_objectagg)
- [NULL ON NULL vs ABSENT ON NULL](#null-on-null-vs-absent-on-null)
- [RETURNING json](#returning-json)
- [Demo](#demo)
- [Zadania do wykonania](#zadania-do-wykonania)
- [Pytania kontrolne](#pytania-kontrolne)
- [Co dalej?](#co-dalej)

---

## Cel tej części

W poprzednich częściach pracowaliśmy głównie z istniejącymi dokumentami JSON:

- odczytywaliśmy wartości przez `JSON_VALUE`,
- odczytywaliśmy obiekty i tablice przez `JSON_QUERY`,
- rozbijaliśmy tablice na wiersze przez `OPENJSON`,
- sprawdzaliśmy strukturę i zawartość dokumentów,
- modyfikowaliśmy dokumenty przez `JSON_MODIFY`.

W tej części odwracamy kierunek.

Zamiast czytać JSON, będziemy go generować z danych relacyjnych.

Poznasz funkcje:

- `JSON_OBJECT`,
- `JSON_ARRAY`,
- `JSON_OBJECTAGG`,
- `JSON_ARRAYAGG`.

Po wykonaniu tej części powinieneś umieć:

- utworzyć prosty obiekt JSON,
- utworzyć prostą tablicę JSON,
- wygenerować obiekt JSON na podstawie kolumn SQL,
- wygenerować tablicę JSON na podstawie wielu wierszy,
- wygenerować obiekt JSON z agregacji,
- kontrolować zachowanie wartości `NULL`,
- użyć `RETURNING json`,
- przygotować prostą strukturę JSON reprezentującą zamówienie i pozycje zamówienia.

---

## Pliki używane w tej części

Skrypty demonstracyjne z repozytorium:

- [`sqlserver2025-tsql-json08-json_object.sql`](../sqlserver2025-tsql-json08-json_object.sql)
- [`sqlserver2025-tsql-json09-json_array.sql`](../sqlserver2025-tsql-json09-json_array.sql)
- [`sqlserver2025-tsql-json10-json_objectagg.sql`](../sqlserver2025-tsql-json10-json_objectagg.sql)
- [`sqlserver2025-tsql-json11-json_arrayagg.sql`](../sqlserver2025-tsql-json11-json_arrayagg.sql)

Rozwiązania zadań:

- [`05-B-generowanie-json-labsolution.sql`](05-B-generowanie-json-labsolution.sql)

Wymagany setup:

- [`sqlserver2025-tsql-json00-SETUP.sql`](../sqlserver2025-tsql-json00-SETUP.sql)

---

## Wprowadzenie

W SQL Server możemy generować JSON bez ręcznego sklejania tekstu.

Zamiast pisać coś takiego:

```sql
'{"ProductID":' + CAST(ProductID AS varchar(10)) + ',"Name":"' + Name + '"}'
```

lepiej użyć funkcji JSON.

Przykład:

```sql
JSON_OBJECT(
    'ProductID': ProductID,
    'Name': Name
)
```

To jest czytelniejsze, bezpieczniejsze i lepiej radzi sobie z typami danych oraz znakami specjalnymi.

---

## JSON_OBJECT

`JSON_OBJECT` tworzy obiekt JSON z par klucz/wartość.

Przykład:

```sql
SELECT JSON_OBJECT(
    'ProductID': 776,
    'Name': 'Mountain-100 Black, 42',
    'OrderQty': 1
) AS ProductJson;
```

Wynik:

```json
{"ProductID":776,"Name":"Mountain-100 Black, 42","OrderQty":1}
```

W praktyce wartości często pochodzą z kolumn zapytania:

```sql
SELECT TOP (10)
    JSON_OBJECT(
        'OrderID': OrderID,
        'OrderDate': JSON_VALUE(OrderDoc, '$.OrderDate'),
        'Status': JSON_VALUE(OrderDoc, '$.Status')
    ) AS OrderJson
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;
```

---

## JSON_ARRAY

`JSON_ARRAY` tworzy tablicę JSON z podanych wartości.

Przykład:

```sql
SELECT JSON_ARRAY('SQL Server', 'JSON', 'T-SQL') AS JsonArray;
```

Wynik:

```json
["SQL Server","JSON","T-SQL"]
```

Możemy też mieszać typy danych:

```sql
SELECT JSON_ARRAY(776, 'Mountain-100 Black, 42', 1, 2024.99) AS ProductArray;
```

---

## JSON_ARRAYAGG

`JSON_ARRAYAGG` **tworzy tablicę** JSON na podstawie wielu wierszy.

Przykład:

```sql
SELECT
    JSON_ARRAYAGG(Name ORDER BY ProductID) AS ProductNames
FROM
(
    VALUES
        (776, N'Mountain-100 Black, 42'),
        (777, N'Mountain-100 Black, 44'),
        (778, N'Mountain-100 Black, 48')
) AS p(ProductID, Name);
```

Wynik:
```json
[
  "Mountain-100 Black, 42",
  "Mountain-100 Black, 44",
  "Mountain-100 Black, 48"
]
```


To jest szczególnie przydatne wtedy, gdy chcemy z wielu wierszy zrobić jedną tablicę JSON.

Przykład bardziej praktyczny:

```sql
SELECT
    JSON_ARRAYAGG(
        JSON_OBJECT(
            'ProductID': ProductID,
            'Name': Name,
            'OrderQty': OrderQty
        )
        ORDER BY ProductID
    ) AS ItemsJson
FROM
(
    VALUES
        (776, N'Mountain-100 Black, 42', 1),
        (777, N'Mountain-100 Black, 44', 2),
        (778, N'Mountain-100 Black, 48', 1)
) AS i(ProductID, Name, OrderQty);
```
Wynik:
```json
[
  {
    "ProductID": 776,
    "Name": "Mountain-100 Black, 42",
    "OrderQty": 1
  },
  {
    "ProductID": 777,
    "Name": "Mountain-100 Black, 44",
    "OrderQty": 2
  },
  {
    "ProductID": 778,
    "Name": "Mountain-100 Black, 48",
    "OrderQty": 1
  }
]
```
---

## JSON_OBJECTAGG

`JSON_OBJECTAGG` **tworzy obiekt** JSON z agregacji par klucz/wartość.

Przykład:

```sql
SELECT
    JSON_OBJECTAGG(ProductID: Name) AS ProductMap
FROM
(
    VALUES
        (776, N'Mountain-100 Black, 42'),
        (777, N'Mountain-100 Black, 44'),
        (778, N'Mountain-100 Black, 48')
) AS p(ProductID, Name);
```

Wynik będzie obiektem, w którym kluczem jest `ProductID`, a wartością nazwa produktu:

```json
{
  "776": "Mountain-100 Black, 42",
  "777": "Mountain-100 Black, 44",
  "778": "Mountain-100 Black, 48"
}
```

`JSON_OBJECTAGG` jest przydatny, gdy chcemy przygotować słownik/mapę wartości.

---

## NULL ON NULL vs ABSENT ON NULL

Funkcje generujące JSON pozwalają kontrolować zachowanie wartości `NULL`.

Dla `JSON_OBJECT` domyślne zachowanie to `NULL ON NULL`.

Przykład:

```sql
SELECT JSON_OBJECT(
    'ProductID': 776,
    'Color': NULL
) AS ProductJson;
```

Wynik zawiera właściwość z wartością `null`:

```json
{"ProductID":776,"Color":null}
```

Jeżeli użyjemy `ABSENT ON NULL`, właściwość zostanie pominięta:

```sql
SELECT JSON_OBJECT(
    'ProductID': 776,
    'Color': NULL
    ABSENT ON NULL
) AS ProductJson;
```

Wynik:

```json
{"ProductID":776}
```

Dla `JSON_ARRAY` domyślne zachowanie to `ABSENT ON NULL`, czyli wartość `NULL` jest pomijana.

```sql
SELECT JSON_ARRAY('SQL Server', NULL, 'JSON') AS JsonArray;
```

Jeżeli chcemy zachować JSON-owe `null`, możemy użyć:

```sql
SELECT JSON_ARRAY('SQL Server', NULL, 'JSON' NULL ON NULL) AS JsonArray;
```

---

## RETURNING json

Domyślnie funkcje generujące JSON zwracają tekst JSON.

W SQL Server 2025 możemy użyć:

```sql
RETURNING json
```

Przykład:

```sql
SELECT JSON_OBJECT(
    'ProductID': 776,
    'Name': 'Mountain-100 Black, 42'
    RETURNING json
) AS ProductJson;
```

To pozwala zwrócić wynik jako natywny typ `json`.

Ta część będzie szczególnie ważna przy omawianiu typu `json`, indeksów i wydajności.

---

## Demo

Do części demonstracyjnej używamy skryptów z repozytorium:

- [`sqlserver2025-tsql-json08-json_object.sql`](../sqlserver2025-tsql-json08-json_object.sql)
- [`sqlserver2025-tsql-json09-json_array.sql`](../sqlserver2025-tsql-json09-json_array.sql)
- [`sqlserver2025-tsql-json10-json_objectagg.sql`](../sqlserver2025-tsql-json10-json_objectagg.sql)
- [`sqlserver2025-tsql-json11-json_arrayagg.sql`](../sqlserver2025-tsql-json11-json_arrayagg.sql)

Skrypty zawierają więcej przykładów niż prawdopodobnie zdążymy omówić podczas warsztatu.  
Podczas demo można uruchomić tylko wybrane fragmenty.

---

## Zadania do wykonania

### Zadanie 1. Utwórz prosty obiekt JSON

Utwórz obiekt JSON opisujący produkt:

```text
ProductID = 776
Name = Mountain-100 Black, 42
OrderQty = 1
UnitPrice = 2024.99
```

Użyj funkcji:

```sql
JSON_OBJECT
```

Wynik:
```json
{
  "ProductID": 776,
  "Name": "Mountain-100 Black, 42",
  "OrderQty": 1,
  "UnitPrice": 2024.99
}
```

---

### Zadanie 2. Utwórz prostą tablicę JSON

Utwórz tablicę JSON zawierającą wartości:

```text
SQL Server
JSON
T-SQL
```

Użyj funkcji:

```sql
JSON_ARRAY
```

Wynik:
```json
[
  "SQL Server",
  "JSON",
  "T-SQL"
]
```

---

### Zadanie 3. Utwórz tablicę mieszaną

Utwórz tablicę JSON zawierającą:

```text
ProductID
Name
OrderQty
UnitPrice
```

Dane mogą być wpisane na sztywno.

Wynik:
```json
[
  776,
  "Mountain-100 Black, 42",
  1,
  2024.99
]
```

---

### Zadanie 4. Wygeneruj obiekty JSON dla kilku zamówień

Na podstawie tabeli:

```text
Sales.SalesOrderHeader
```

wygeneruj dla pierwszych 10 zamówień obiekt JSON zawierający:

```text
OrderID (na podstawie kolumny SalesOrderID)
OrderDate
Status
CustomerID
TotalDue
```

Użyj:

```sql
JSON_OBJECT
JSON_VALUE
```

OrderJson:
```json
{
  "OrderID": 43659,
  "OrderDate": "2022-05-30T00:00:00",
  "Status": 5,
  "CustomerID": 29825,
  "TotalDue": 23153.2339
}
```

---

### Zadanie 5. Wygeneruj obiekt Customer

Dla pierwszych 10 zamówień wygeneruj obiekt JSON:

```text
Sales.Customer
```

zawierający:

```text
CustomerID
StoreID
TerritoryID     
AccountNumber
```

Wynik:
```json
{
  "CustomerID": 1,
  "StoreID": 934,
  "TerritoryID": 1,
  "AccountNumber": "AW00000001"
}
```

---

### Zadanie 6. Wygeneruj obiekt z obiektem zagnieżdżonym

Dla pierwszych 10 zamówień wygeneruj obiekt JSON zawierający:

```text
Sales.SalesOrderHeader
Sales.Customer
```

```text
SalesOrderID
OrderDate
Status
Customer.CustomerID
Customer.StoreID
Customer.TerritoryID
Customer.AccountNumber
```

Gdzie `Customer` powinien być zagnieżdżonym obiektem JSON:

```json
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
```

---

### Zadanie 7. Porównaj JSON_OBJECT z NULL ON NULL

Utwórz obiekt JSON z polami:

```text
ProductID = 776
Name = Mountain-100 Black, 42
Color = NULL
```

Sprawdź domyślne zachowanie wartości `NULL`.

Wynik:
```json
{
  "ProductID": 776,
  "Name": "Mountain-100 Black, 42",
  "Color": null
}
```

---

### Zadanie 8. Porównaj JSON_OBJECT z ABSENT ON NULL

Utwórz taki sam obiekt jak w poprzednim zadaniu, ale użyj:

```sql
ABSENT ON NULL
```

Sprawdź, czy właściwość `Color` pojawia się w wyniku.

Wynik:

```json
{
  "ProductID": 776,
  "Name": "Mountain-100 Black, 42"
}
```

---

### Zadanie 9. Porównaj JSON_ARRAY z wartościami NULL

Utwórz tablicę JSON zawierającą:

```text
SQL Server
NULL
JSON
```

Najpierw użyj zachowania domyślnego, a potem:

```sql
NULL ON NULL
```

Porównaj wyniki.



---

### Zadanie 10. Użyj JSON_ARRAYAGG dla nazw produktów

Na podstawie przykładowych danych z `VALUES` utwórz tablicę nazw produktów.

Dane:

```sql
VALUES
    (776, N'Mountain-100 Black, 42'),
    (777, N'Mountain-100 Black, 44'),
    (778, N'Mountain-100 Black, 48')
```

Użyj:

```sql
JSON_ARRAYAGG
```

Wynik:
```json
[
  "Mountain-100 Black, 42",
  "Mountain-100 Black, 44",
  "Mountain-100 Black, 48"
]
```

---

### Zadanie 11. Użyj ORDER BY w JSON_ARRAYAGG

Zmodyfikuj poprzednie zadanie tak, aby elementy tablicy były posortowane po `Name` malejąco:


```json
[
  "Mountain-100 Black, 48",
  "Mountain-100 Black, 44",
  "Mountain-100 Black, 42"
]
```

---


## Pytania kontrolne

1. Do czego służy `JSON_OBJECT`?
2. Do czego służy `JSON_ARRAY`?
3. Czym różni się `JSON_ARRAY` od `JSON_ARRAYAGG`?
4. Czym różni się `JSON_OBJECT` od `JSON_OBJECTAGG`?
5. Do czego służy `JSON_OBJECTAGG`?
6. Jak wymusić kolejność elementów w `JSON_ARRAYAGG`?
7. Jaka jest różnica między `NULL ON NULL` i `ABSENT ON NULL`?
8. Jakie jest domyślne zachowanie `NULL` dla `JSON_OBJECT`?
9. Jakie jest domyślne zachowanie `NULL` dla `JSON_ARRAY`?
10. Do czego służy `RETURNING json`?
---

## Co dalej?

W tej części generowaliśmy JSON z danych relacyjnych.

W kolejnym rozdziale przejdziemy do tematów wydajnościowych:

- typ `json`,
- computed columns,
- indeksy JSON,
- `CREATE JSON INDEX`,
- metadane indeksów JSON,
- porównanie wybranych podejść.