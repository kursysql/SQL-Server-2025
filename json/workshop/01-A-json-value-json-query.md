<a href="https://www.kursysql.pl"><img src="https://www.kursysql.pl/wp-content/uploads/2022/03/Frame-3.png" title="KursySQL.pl" alt="KursySQL.pl"></a>

# 01. Odczyt danych z JSON - JSON_VALUE i JSON_QUERY

## Spis treści

- [Cel tej części](#cel-tej-części)
- [Pliki używane w tej części](#pliki-używane-w-tej-części)
- [Wprowadzenie](#wprowadzenie)
- [JSON_VALUE](#json_value)
- [JSON_QUERY](#json_query)
- [JSON_VALUE vs JSON_QUERY](#json_value-vs-json_query)
- [Ścieżki JSON](#ścieżki-json)
- [Tryb lax i strict](#tryb-lax-i-strict)
- [Demo](#demo)
- [Zadania do wykonania](#zadania-do-wykonania)
- [Pytania kontrolne](#pytania-kontrolne)
- [Co dalej?](#co-dalej)

---

## Cel tej części

W tej części zaczniemy odczytywać dane z dokumentów JSON zapisanych w tabelach SQL Server.

Poznasz dwie podstawowe funkcje:

- `JSON_VALUE`
- `JSON_QUERY`

Po wykonaniu tej części powinieneś umieć:

- odczytać pojedynczą wartość z dokumentu JSON,
- odczytać obiekt JSON,
- odczytać tablicę JSON,
- odczytać dane z obiektów zagnieżdżonych,
- odczytać wybrane elementy tablicy JSON,
- zrozumieć różnicę między `JSON_VALUE` i `JSON_QUERY`,
- filtrować dane na podstawie wartości zapisanych w JSON,
- sortować dane na podstawie wartości zapisanych w JSON,
- zauważyć różnice między trybem `lax` i `strict`.

---

## Pliki używane w tej części

Skrypty demonstracyjne z repozytorium:

- [`sqlserver2025-tsql-json01-json_value.sql`](../sqlserver2025-tsql-json01-json_value.sql)
- [`sqlserver2025-tsql-json02-json_query.sql`](../sqlserver2025-tsql-json02-json_query.sql)

Skrypt demo do tej części warsztatu:

- [`01-B-json-value-json-query-demo.sql`](01-B-json-value-json-query-demo.sql)

Rozwiązania zadań:

- [`01-C-json-value-json-query-labsolution.sql`](01-C-json-value-json-query-labsolution.sql)

Wymagany setup:

- [`sqlserver2025-tsql-json00-SETUP.sql`](../sqlserver2025-tsql-json00-SETUP.sql)

---

## Wprowadzenie

W poprzedniej części przygotowaliśmy środowisko i sprawdziliśmy tabele warsztatowe.

W tej części zaczynamy pracę z zawartością dokumentów JSON.

Przykładowy dokument reprezentuje zamówienie. W środku znajdują się między innymi:


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
    },
    {
      "ProductID": 777,
      "Name": "Mountain-100 Black, 44",
      "OrderQty": 1,
      "UnitPrice": 2024.99,
      "LineTotal": 2024.99
    }
  ]
}
```

Te elementy mają różny charakter/ typy danych:

```text
wartość skalarna  - OrderID, OrderDate, Status, SalesPersonID
obiekt JSON       - Customer, Shipping, Totals
tablica JSON      - Items
```

Dlatego do ich odczytu używamy różnych funkcji.

---

## JSON_VALUE

Funkcja `JSON_VALUE` służy do odczytu pojedynczej wartości z dokumentu JSON.

Dla powyższego dokumentu `JSON_VALUE` pozwala odczytać na przykład takie wartości:

```sql
JSON_VALUE(OrderDoc, '$.OrderID')
JSON_VALUE(OrderDoc, '$.OrderDate')
JSON_VALUE(OrderDoc, '$.Status')
JSON_VALUE(OrderDoc, '$.Customer.CustomerID')
JSON_VALUE(OrderDoc, '$.Shipping.City')
JSON_VALUE(OrderDoc, '$.Totals.TotalDue')
JSON_VALUE(OrderDoc, '$.Items[0].ProductID')
```

Przykład:

```sql
SELECT TOP (10)
    OrderID,
    JSON_VALUE(OrderDoc, '$.OrderDate') AS OrderDate,
    JSON_VALUE(OrderDoc, '$.Status') AS Status
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;
GO
```

`JSON_VALUE` zwraca pojedynczą wartość, na przykład tekst, liczbę, datę albo wartość logiczną.

W praktyce wynik funkcji często trzeba przekonwertować na odpowiedni typ danych, szczególnie przy filtrowaniu i sortowaniu po liczbach albo datach.

Przykład:

```sql
SELECT TOP (10)
    OrderID,
    JSON_VALUE(OrderDoc, '$.Totals.TotalDue') AS TotalDue_AsText,
    TRY_CONVERT(decimal(19, 4), JSON_VALUE(OrderDoc, '$.Totals.TotalDue')) AS TotalDue_AsNumber
FROM DemoJson.OrderDocs_Text
ORDER BY TotalDue_AsNumber DESC;
GO
```

---

## JSON_QUERY

Dla tego samego dokumentu `JSON_QUERY` pozwala odczytać większy fragment JSON, na przykład cały obiekt albo całą tablicę:

```sql
JSON_QUERY(OrderDoc, '$.Customer')
JSON_QUERY(OrderDoc, '$.Shipping')
JSON_QUERY(OrderDoc, '$.Totals')
JSON_QUERY(OrderDoc, '$.Items')
```

Tutaj wynikiem nie jest pojedyncza wartość, ale poprawny fragment dokumentu JSON.

Przykład:

```sql
SELECT TOP (10)
    OrderID,
    JSON_QUERY(OrderDoc, '$.Customer') AS Customer,
    JSON_QUERY(OrderDoc, '$.Items') AS Items
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;
GO
```

`JSON_QUERY` nie zwraca pojedynczej wartości.  
Zwraca poprawny fragment JSON.

---

## JSON_VALUE vs JSON_QUERY

Najważniejsza różnica:

| Potrzeba | Funkcja |
|---|---|
| Odczytać pojedynczą wartość | `JSON_VALUE` |
| Odczytać obiekt JSON | `JSON_QUERY` |
| Odczytać tablicę JSON | `JSON_QUERY` |

Przykład celowej pomyłki:

```sql
SELECT TOP (10)
    OrderID,
    JSON_VALUE(OrderDoc, '$.Customer') AS Customer_By_JSON_VALUE,
    JSON_QUERY(OrderDoc, '$.Customer') AS Customer_By_JSON_QUERY
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;
GO
```

Obiekt `Customer` nie jest wartością skalarną, dlatego `JSON_VALUE` nie jest właściwą funkcją do jego odczytu.

Podobnie z tablicą `Items`:

```sql
SELECT TOP (10)
    OrderID,
    JSON_VALUE(OrderDoc, '$.Items') AS Items_By_JSON_VALUE,
    JSON_QUERY(OrderDoc, '$.Items') AS Items_By_JSON_QUERY
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;
GO
```

Tablica `Items` również nie jest wartością skalarną, więc do jej odczytu jako fragmentu JSON używamy `JSON_QUERY`.

---

## Ścieżki JSON

Do wskazywania elementów w dokumencie JSON używamy ścieżek.

Przykłady:

```text
$.OrderDate
$.Status
$.Customer.CustomerID
$.Shipping.City
$.Totals.TotalDue
$.Items
$.Items[0].ProductID
$.Items[0].Name
```

Znaczenie poszczególnych elementów:

| Element ścieżki | Znaczenie |
|---|---|
| `$` | cały dokument JSON |
| `$.OrderDate` | właściwość `OrderDate` na głównym poziomie |
| `$.Customer.CustomerID` | właściwość `CustomerID` wewnątrz obiektu `Customer` |
| `$.Items` | tablica `Items` |
| `$.Items[0]` | pierwszy element tablicy `Items` |
| `$.Items[0].ProductID` | właściwość `ProductID` pierwszego elementu tablicy |

Przykład:

```sql
SELECT TOP (10)
    OrderID,
    JSON_VALUE(OrderDoc, '$.Customer.CustomerID') AS CustomerID,
    JSON_VALUE(OrderDoc, '$.Items[0].ProductID') AS FirstProductID
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;
GO
```

---

## Tryb lax i strict

Ścieżki JSON mogą działać w dwóch trybach:

| Tryb | Zachowanie |
|---|---|
| `lax` | tryb domyślny; jeśli ścieżka nie istnieje, funkcja zwykle zwraca `NULL` |
| `strict` | jeśli ścieżka nie istnieje albo wskazuje niepoprawny typ elementu, zapytanie może zakończyć się błędem |

Przykład trybu domyślnego:

```sql
SELECT TOP (10)
    OrderID,
    JSON_VALUE(OrderDoc, '$.DoesNotExist') AS DoesNotExist_Lax
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;
GO
```

Przykład trybu `strict`:

```sql
SELECT TOP (10)
    OrderID,
    JSON_VALUE(OrderDoc, 'strict $.DoesNotExist') AS DoesNotExist_Strict
FROM DemoJson.OrderDocs_Text
ORDER BY OrderID;
GO
```

W materiałach ćwiczeniowych warto uruchomić wersję `strict` świadomie, ponieważ może zakończyć się błędem. To jest oczekiwane zachowanie.

---

## Demo 



Kod uruchamiany podczas demo znajduje się w pliku:

- [`sqlserver2025-tsql-json01-json_value.sql`](../sqlserver2025-tsql-json01-json_value.sql)
- [`sqlserver2025-tsql-json02-json_query.sql`](../sqlserver2025-tsql-json02-json_query.sql)




## Zadania do wykonania

### Zadanie 1. Wyświetl przykładowe dokumenty

Wyświetl pierwsze 10 rekordów z tabeli:

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

### Zadanie 2. Odczytaj podstawowe wartości z dokumentu JSON

Z tabeli:

```text
DemoJson.OrderDocs_Text
```

odczytaj z kolumny `OrderDoc` następujące wartości:

```text
OrderID
OrderDate
Status
OnlineOrder
SalesPersonID
```

Użyj funkcji `JSON_VALUE`.


---

### Zadanie 3. Nadaj aliasy kolumnom

Zmodyfikuj poprzednie zapytanie tak, aby wynik zawierał kolumny:

```text
TableOrderID
JsonOrderID
OrderDate
Status
OnlineOrder
SalesPersonID
```

Gdzie:

- `TableOrderID` pochodzi z kolumny tabeli,
- `JsonOrderID` pochodzi z dokumentu JSON.


---

### Zadanie 4. Porównaj wartości z tabeli i z JSON

Sprawdź, czy wartość `OrderID` z kolumny tabeli jest taka sama jak wartość `OrderID` zapisana w dokumencie JSON.

Wyświetl tylko te rekordy, dla których wartości są różne.
Nnie powinno zwrócić żadnych rekordów, ponieważ `OrderID` w tabeli i w JSON powinny być takie same.


---

### Zadanie 5. Odczytaj dane klienta

Z dokumentu JSON odczytaj dane klienta:

```text
Customer.CustomerID
Customer.AccountNumber
Customer.CustomerType
```

Użyj funkcji `JSON_VALUE`.

---

### Zadanie 6. Odczytaj dane wysyłkowe

Z dokumentu JSON odczytaj informacje z obiektu:

```text
Shipping
```

Spróbuj odczytać przykładowe pola, na przykład:

```text
Shipping.City
Shipping.CountryRegionCode
```

W razie potrzeby najpierw podejrzyj cały dokument JSON i sprawdź dostępne właściwości.

---

### Zadanie 7. Odczytaj obiekt Customer jako JSON

Odczytaj cały obiekt:

```text
Customer
```

Użyj funkcji `JSON_QUERY`.

---

### Zadanie 8. Odczytaj obiekt Totals jako JSON

Odczytaj cały obiekt:

```text
Totals
```

Użyj funkcji `JSON_QUERY`.

---

### Zadanie 9. Odczytaj tablicę Items jako JSON

Odczytaj tablicę:

```text
Items
```

Użyj funkcji `JSON_QUERY`.

---

### Zadanie 10. Celowa pomyłka: JSON_VALUE na tablicy

Spróbuj odczytać tablicę:

```text
Items
```

za pomocą funkcji `JSON_VALUE`.

Porównaj wynik z `JSON_QUERY`.


---

### Zadanie 11. Celowa pomyłka: JSON_VALUE na obiekcie

Spróbuj odczytać obiekt:

```text
Customer
```

za pomocą funkcji `JSON_VALUE`.

Porównaj wynik z `JSON_QUERY`.

---

### Zadanie 12. Odczytaj pierwszy element tablicy Items

Odczytaj dane pierwszej pozycji zamówienia:

```text
Items[0].ProductID
Items[0].Name
Items[0].OrderQty
Items[0].UnitPrice
Items[0].LineTotal
```

Użyj funkcji `JSON_VALUE`.

---

### Zadanie 13. Odczytaj drugi element tablicy Items

Odczytaj dane drugiej pozycji zamówienia:

```text
Items[1].ProductID
Items[1].Name
Items[1].OrderQty
Items[1].UnitPrice
Items[1].LineTotal
```

Co się stanie, jeżeli zamówienie nie ma drugiej pozycji?

---

### Zadanie 14. Filtrowanie po wartości z JSON

Wyświetl zamówienia, dla których:

```text
Status = 5
```

albo inna wartość statusu występująca w Twoich danych.

Użyj funkcji `JSON_VALUE` w klauzuli `WHERE`.

---

### Zadanie 15. Filtrowanie po wartości liczbowej z JSON

Wyświetl zamówienia, dla których wartość:

```text
Totals.TotalDue
```

jest większa od wybranej kwoty, na przykład:

```text
1000
```

Pamiętaj, że wartość odczytana przez `JSON_VALUE` wymaga konwersji na typ liczbowy.

---

### Zadanie 16. Sortowanie po dacie zapisanej w JSON

Wyświetl zamówienia i posortuj je malejąco po wartości:

```text
OrderDate
```

odczytanej z dokumentu JSON.


---

### Zadanie 17. Sortowanie po kwocie zapisanej w JSON

Wyświetl zamówienia i posortuj je malejąco po wartości:

```text
Totals.TotalDue
```

Pamiętaj o konwersji na typ liczbowy.


---

### Zadanie 18. Porównaj tryb lax i strict

Spróbuj odczytać nieistniejącą właściwość:

```text
DoesNotExist
```

najpierw w trybie domyślnym, czyli `lax`, a potem w trybie `strict`.

Przykładowe ścieżki:

```sql
'$.DoesNotExist'
'strict $.DoesNotExist'
```

Jaka jest różnica w zachowaniu zapytania?



## Pytania kontrolne

1. Do czego służy `JSON_VALUE`?
2. Do czego służy `JSON_QUERY`?
3. Dlaczego `JSON_VALUE` nie nadaje się do odczytu obiektu JSON?
4. Dlaczego `JSON_VALUE` nie nadaje się do odczytu tablicy JSON?
5. Jak odczytać pierwszy element tablicy JSON?
6. Czym różni się tryb `lax` od `strict`?
7. Dlaczego przy filtrowaniu i sortowaniu po liczbach warto wykonać konwersję typu?
8. Czy funkcje `JSON_VALUE` i `JSON_QUERY` działają zarówno na `nvarchar(max)`, jak i na typie `json`?
9. Czy ścieżki JSON są wrażliwe na wielkość liter?
10. Dlaczego odczytanie `Items[0]` nie rozwiązuje problemu odczytu wszystkich pozycji zamówienia?

---

## Co dalej?

W tej części odczytywaliśmy pojedyncze wartości, obiekty i całe tablice JSON.

Problem pojawia się wtedy, gdy chcemy odczytać wszystkie elementy tablicy jako osobne wiersze.

Na przykład tablica:

```text
Items
```

zawiera pozycje zamówienia.

W kolejnym rozdziale użyjemy:

```sql
OPENJSON
```

żeby zamienić tablicę JSON na klasyczne wiersze i kolumny SQL.