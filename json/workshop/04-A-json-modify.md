<a href="https://www.kursysql.pl"><img src="https://www.kursysql.pl/wp-content/uploads/2022/03/Frame-3.png" title="KursySQL.pl" alt="KursySQL.pl"></a>

# 04. Modyfikowanie dokumentów JSON - JSON_MODIFY

## Spis treści

- [Cel tej części](#cel-tej-części)
- [Pliki używane w tej części](#pliki-używane-w-tej-części)
- [Wprowadzenie](#wprowadzenie)
- [JSON_MODIFY](#json_modify)
- [Zmiana istniejącej wartości](#zmiana-istniejącej-wartości)
- [Dodawanie nowej właściwości](#dodawanie-nowej-właściwości)
- [Usuwanie właściwości](#usuwanie-właściwości)
- [Modyfikowanie tablicy](#modyfikowanie-tablicy)
- [Wstawianie obiektu JSON](#wstawianie-obiektu-json)
- [Kilka zmian w jednym dokumencie](#kilka-zmian-w-jednym-dokumencie)
- [Demo](#demo)
- [Zadania do wykonania](#zadania-do-wykonania)
- [Pytania kontrolne](#pytania-kontrolne)
- [Co dalej?](#co-dalej)

---

## Cel tej części

W poprzednich częściach odczytywaliśmy dane z dokumentów JSON, rozbijaliśmy tablice JSON na wiersze oraz sprawdzaliśmy poprawność i zawartość dokumentów.

W tej części przejdziemy do modyfikowania dokumentów JSON.

Poznasz funkcję:

- `JSON_MODIFY`

Po wykonaniu tej części powinieneś umieć:

- zmienić wartość istniejącej właściwości w dokumencie JSON,
- dodać nową właściwość,
- usunąć właściwość,
- zmodyfikować wartość w obiekcie zagnieżdżonym,
- zmodyfikować element tablicy,
- dodać nowy element do tablicy,
- wstawić obiekt JSON bez zamiany go na zwykły tekst,
- wykonać kilka zmian w jednym dokumencie.

---

## Pliki używane w tej części

Skrypt demonstracyjny z repozytorium:

- [`sqlserver2025-tsql-json07-json_modify.sql`](../sqlserver2025-tsql-json07-json_modify.sql)

Skrypt lab do samodzielnego wykonania:

- [`04-B-json-modify-lab.sql`](04-B-json-modify-lab.sql)

Rozwiązania zadań:

- [`04-C-json-modify-labsolution.sql`](04-C-json-modify-labsolution.sql)

Wymagany setup:

- [`sqlserver2025-tsql-json00-SETUP.sql`](../sqlserver2025-tsql-json00-SETUP.sql)

---

## Wprowadzenie

Do tej pory dokument JSON traktowaliśmy głównie jako źródło danych.

Przykładowo:

```sql
JSON_VALUE(OrderDoc, '$.Status')
JSON_QUERY(OrderDoc, '$.Items')
OPENJSON(OrderDoc, '$.Items')
```

pozwalały nam odczytywać dane, ale nie zmieniały dokumentu.

Jeżeli chcemy punktowo zmienić dokument JSON, używamy:

```sql
JSON_MODIFY
```

Przykładowy dokument może wyglądać tak:

```json
{
  "OrderID": 43672,
  "OrderDate": "2011-05-31",
  "Status": "Shipped",
  "OnlineOrder": true,
  "SalesPersonID": 279,
  "Customer": {
    "CustomerID": 29825,
    "AccountNumber": "10-4020-000676",
    "CustomerType": "Individual"
  },
  "Shipping": {
    "City": "Burbank",
    "CountryRegionCode": "US"
  },
  "Totals": {
    "SubTotal": 3578.27,
    "TaxAmt": 286.26,
    "Freight": 89.46,
    "TotalDue": 3953.99
  },
  "Items": [
    {
      "ProductID": 776,
      "Name": "Mountain-100 Black, 42",
      "OrderQty": 1,
      "UnitPrice": 2024.99,
      "LineTotal": 2024.99
    }
  ]
}
```

---

## JSON_MODIFY

Podstawowa składnia:

```sql
JSON_MODIFY(expression, path, newValue)
```

Gdzie:

| Element | Znaczenie |
|---|---|
| `expression` | dokument JSON |
| `path` | ścieżka do modyfikowanego elementu |
| `newValue` | nowa wartość |

Przykład:

```sql
SELECT JSON_MODIFY(@OrderDoc, '$.Status', N'Cancelled');
```

Ważna rzecz: `JSON_MODIFY` zwraca zmodyfikowany dokument JSON.  
Nie zmienia automatycznie wartości zmiennej ani kolumny, dopóki nie przypiszemy wyniku.

Przykład ze zmienną:

```sql
SET @OrderDoc = JSON_MODIFY(@OrderDoc, '$.Status', N'Cancelled');
```

Przykład z tabelą:

```sql
UPDATE DemoJson.OrderDocs_Text
SET OrderDoc = JSON_MODIFY(OrderDoc, '$.Status', N'Cancelled')
WHERE OrderID = 43672;
```

W ćwiczeniach będziemy pracować głównie na zmiennych lub kopii danych, żeby nie modyfikować przypadkowo danych bazowych.

---

## Zmiana istniejącej wartości

Najprostszy przypadek to zmiana wartości istniejącej właściwości.

```sql
SET @OrderDoc = JSON_MODIFY(@OrderDoc, '$.Status', N'Cancelled');
```

Możemy też zmieniać wartości zagnieżdżone:

```sql
SET @OrderDoc = JSON_MODIFY(@OrderDoc, '$.Customer.CustomerType', N'VIP');
```

Albo wartości w tablicach:

```sql
SET @OrderDoc = JSON_MODIFY(@OrderDoc, '$.Items[0].OrderQty', 2);
```

---

## Dodawanie nowej właściwości

Jeżeli ścieżka nie istnieje, `JSON_MODIFY` może dodać nową właściwość.

Przykład:

```sql
SET @OrderDoc = JSON_MODIFY(@OrderDoc, '$.WorkshopSource', N'KursySQL');
```

Możemy też dodać właściwość do istniejącego obiektu:

```sql
SET @OrderDoc = JSON_MODIFY(@OrderDoc, '$.Shipping.DeliveryMethod', N'Courier');
```

Ważne: jeżeli próbujemy dodać właściwość do obiektu, którego nie ma, trzeba najpierw utworzyć ten obiekt albo wstawić cały fragment JSON.

---

## Usuwanie właściwości

W trybie domyślnym, czyli `lax`, ustawienie wartości na `NULL` usuwa właściwość z dokumentu.

Przykład:

```sql
SET @OrderDoc = JSON_MODIFY(@OrderDoc, '$.SalesPersonID', NULL);
```
w trybie :
-  **lax** usuwa właściwość
-  **strict** wstawia NULL

```sql
-- Usunięcie właściwości w trybie lax
SET @OrderDoc = JSON_MODIFY(@OrderDoc, 'lax $.SalesPersonID', NULL);
```

```sql
-- Ustawienie NULL w trybie strict
SET @OrderDoc = JSON_MODIFY(@OrderDoc, 'strict $.SalesPersonID', NULL);
```

---

## Modyfikowanie tablicy

Możemy zmienić konkretny element tablicy:

```sql
SET @OrderDoc = JSON_MODIFY(@OrderDoc, '$.Items[0].OrderQty', 2);
```

Możemy też dodać nowy element do tablicy za pomocą `append`:

```sql
SET @OrderDoc = JSON_MODIFY(
    @OrderDoc,
    'append $.Items',
    JSON_QUERY(N'{
      "ProductID": 999,
      "Name": "Workshop Product",
      "OrderQty": 1,
      "UnitPrice": 100.00,
      "LineTotal": 100.00
    }')
);
```

---

## Wstawianie obiektu JSON

Jeżeli jako nową wartość przekazujemy tekst wyglądający jak JSON, SQL Server może potraktować go jak zwykły tekst.

Dlatego przy wstawianiu obiektów lub tablic JSON warto użyć:

```sql
JSON_QUERY
```

Przykład:

```sql
SET @OrderDoc = JSON_MODIFY(
    @OrderDoc,
    '$.Audit',
    JSON_QUERY(N'{
      "ModifiedBy": "Workshop",
      "Reason": "Demo"
    }')
);
```

Dzięki temu `Audit` zostanie dodany jako obiekt JSON, a nie jako tekst zawierający znaki `{` i `}`.

---

## Kilka zmian w jednym dokumencie

`JSON_MODIFY` modyfikuje jedną ścieżkę na raz.

Jeżeli chcemy wykonać kilka zmian, możemy wywołać `JSON_MODIFY` kilka razy:

```sql
SET @OrderDoc = JSON_MODIFY(@OrderDoc, '$.Status', N'Cancelled');
SET @OrderDoc = JSON_MODIFY(@OrderDoc, '$.WorkshopSource', N'KursySQL');
SET @OrderDoc = JSON_MODIFY(@OrderDoc, '$.Customer.CustomerType', N'VIP');
```

Albo zagnieździć wywołania:

```sql
SET @OrderDoc =
    JSON_MODIFY(
        JSON_MODIFY(
            JSON_MODIFY(@OrderDoc, '$.Status', N'Cancelled'),
            '$.WorkshopSource',
            N'KursySQL'
        ),
        '$.Customer.CustomerType',
        N'VIP'
    );
```

W praktyce dla czytelności często wygodniej używać kilku osobnych instrukcji `SET`.

---

## Demo

Do części demonstracyjnej używamy skryptu z repozytorium:

- [`sqlserver2025-tsql-json07-json_modify.sql`](../sqlserver2025-tsql-json07-json_modify.sql)

Skrypt zawiera więcej przykładów niż prawdopodobnie zdążymy omówić podczas warsztatu.  
Podczas demo można uruchomić tylko wybrane fragmenty.

---

## Zadania do wykonania

### Zadanie 1. Pobierz dokument JSON do zmiennej

Pobierz jeden dokument z tabeli:

```text
DemoJson.OrderDocs_Text
```

do zmiennej:

```sql
@OrderDoc
```

Następnie wyświetl dokument.



---

### Zadanie 2. Sprawdź wartości przed modyfikacją

Dla dokumentu zapisanego w zmiennej `@OrderDoc` odczytaj:

```text
OrderID
Status
SalesPersonID
Customer.CustomerType
Shipping.City
Shipping.CountryRegionCode
Items[0].ProductID
Items[0].OrderQty
```

Użyj funkcji:

```sql
JSON_VALUE
```


---

### Zadanie 3. Zmień status zamówienia

Zmień wartość:

```text
Status
```

na:

```text
Cancelled
```

Użyj funkcji:

```sql
JSON_MODIFY
```

Następnie sprawdź nową wartość przez `JSON_VALUE`.



---

### Zadanie 4. Dodaj nową właściwość na głównym poziomie

Dodaj do dokumentu nową właściwość:

```text
WorkshopSource = KursySQL
```

Następnie odczytaj ją za pomocą `JSON_VALUE`.


---

### Zadanie 5. Zmień wartość w obiekcie Customer

Zmień wartość:

```text
Customer.CustomerType
```

na:

```text
VIP
```

Następnie odczytaj:

```text
Customer.CustomerID
Customer.CustomerType
```


---

### Zadanie 6. Dodaj właściwość do obiektu Shipping

Dodaj do obiektu:

```text
Shipping
```

nową właściwość:

```text
DeliveryMethod = Courier
```

Następnie odczytaj cały obiekt `Shipping` przez `JSON_QUERY`.



---

### Zadanie 7. Usuń właściwość SalesPersonID

Usuń z dokumentu właściwość:

```text
SalesPersonID
```

Wykorzystaj `JSON_MODIFY` i wartość `NULL`.

Następnie sprawdź, czy `SalesPersonID` nadal istnieje.


---

### Zadanie 8. Zmień ilość w pierwszej pozycji zamówienia

Zmień wartość:

```text
Items[0].OrderQty
```

na:

```text
2
```

Następnie odczytaj:

```text
Items[0].ProductID
Items[0].Name
Items[0].OrderQty
```


---

### Zadanie 9. Zmień cenę w pierwszej pozycji zamówienia

Zmień wartość:

```text
Items[0].UnitPrice
```

na:

```text
1999.99
```

Następnie odczytaj:

```text
Items[0].UnitPrice
Items[0].LineTotal
```

### Pytanie kontrolne

Czy zmiana `UnitPrice` automatycznie przeliczyła `LineTotal`?


---

### Zadanie 10. Dodaj nową właściwość Audit jako obiekt JSON

Dodaj do dokumentu nową właściwość:

```text
Audit
```

jako obiekt JSON:

```json
{
  "ModifiedBy": "Workshop",
  "Reason": "JSON_MODIFY demo"
}
```

Użyj `JSON_QUERY`, aby obiekt został dodany jako JSON, a nie jako zwykły tekst.


---

### Zadanie 11. Dodaj nowy element do tablicy Items

Dodaj do tablicy:

```text
Items
```

nową pozycję:

```json
{
  "ProductID": 999,
  "Name": "Workshop Product",
  "OrderQty": 1,
  "UnitPrice": 100.00,
  "LineTotal": 100.00
}
```

Użyj:

```sql
append
JSON_QUERY
```

Następnie odczytaj całą tablicę `Items`.

---


## Pytania kontrolne

1. Do czego służy `JSON_MODIFY`?
2. Czy `JSON_MODIFY` zmienia dokument automatycznie, czy zwraca nowy dokument?
3. Jak zmienić wartość istniejącej właściwości?
4. Jak dodać nową właściwość?
5. Jak usunąć właściwość w trybie `lax`?
6. Dlaczego przy dodawaniu obiektu JSON warto użyć `JSON_QUERY`?
7. Do czego służy `append` w ścieżce `JSON_MODIFY`?
8. Czy zmiana `Items[0].UnitPrice` automatycznie przelicza `Items[0].LineTotal`?

---

## Co dalej?

W tej części modyfikowaliśmy istniejące dokumenty JSON.

W kolejnym rozdziale przejdziemy do generowania JSON z danych relacyjnych przy użyciu funkcji:

- `JSON_OBJECT`,
- `JSON_ARRAY`,
- `JSON_OBJECTAGG`,
- `JSON_ARRAYAGG`.