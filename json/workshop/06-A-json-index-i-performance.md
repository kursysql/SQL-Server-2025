<a href="https://www.kursysql.pl"><img src="https://www.kursysql.pl/wp-content/uploads/2022/03/Frame-3.png" title="KursySQL.pl" alt="KursySQL.pl"></a>

# 06. Typ json, indeksy i wydajność

## Spis treści

- [Cel tej części](#cel-tej-części)
- [Pliki używane w tej części](#pliki-używane-w-tej-części)
- [Wprowadzenie](#wprowadzenie)
- [nvarchar(max) vs json](#nvarcharmax-vs-json)
- [Computed columns](#computed-columns)
- [CREATE JSON INDEX](#create-json-index)
- [Metadane indeksów JSON](#metadane-indeksów-json)
- [Zapytania, które mogą skorzystać z indeksu JSON](#zapytania-które-mogą-skorzystać-z-indeksu-json)
- [Demo](#demo)
- [Co dalej?](#co-dalej)

---

## Cel tej części

W poprzednich częściach poznaliśmy funkcje JSON od strony składni i praktycznego użycia.

W tej części skupimy się na wydajności i indeksowaniu.

Porównamy dwa podejścia:

- klasyczne podejście: JSON w `nvarchar(max)` + computed columns + zwykłe indeksy,
- nowe podejście SQL Server 2025: natywny typ `json` + `CREATE JSON INDEX`.

Po wykonaniu tej części powinieneś umieć:

- sprawdzić typ kolumny przechowującej dokument JSON,
- zrozumieć różnicę między `nvarchar(max)` i typem `json`,
- przygotować computed columns na podstawie `JSON_VALUE`,
- utworzyć zwykłe indeksy na computed columns,
- utworzyć indeks JSON przez `CREATE JSON INDEX`,
- sprawdzić metadane indeksów JSON,
- uruchomić zapytania używające `JSON_VALUE`, `JSON_PATH_EXISTS` i `JSON_CONTAINS`,
- porównać podstawowe statystyki IO / TIME,
- rozumieć, że nie każdy scenariusz automatycznie przyspieszy tylko dlatego, że używamy JSON.

---

## Pliki używane w tej części

Skrypty demonstracyjne z repozytorium:

- [`sqlserver2025-tsql-json21-perf_cc.sql`](../sqlserver2025-tsql-json21-perf_cc.sql)
- [`sqlserver2025-tsql-json22-json_index.sql`](../sqlserver2025-tsql-json22-json_index.sql)
- [`sqlserver2025-tsql-json23-json_index_internal.sql`](../sqlserver2025-tsql-json23-json_index_internal.sql)
- [`sqlserver2025-tsql-json24-perf-json_sql25cu4.sql`](../sqlserver2025-tsql-json24-perf-json_sql25cu4.sql)
- [`sqlserver2025-tsql-json25-perf-json_azureSQL.sql`](../sqlserver2025-tsql-json25-perf-json_azureSQL.sql)

Wymagany setup:

- [`sqlserver2025-tsql-json00-SETUP.sql`](../sqlserver2025-tsql-json00-SETUP.sql)

Opcjonalnie, jeżeli chcesz odtworzyć dane do części indeksowej:

- [`sqlserver2025-tsql-json00-SETUP_script_OrderDocs_Json_Indexed.sql`](../sqlserver2025-tsql-json00-SETUP_script_OrderDocs_Json_Indexed.sql)

---

## Wprowadzenie

JSON w SQL Server można traktować na kilka sposobów.

Najprostsze podejście:

```text
kolumna nvarchar(max) + funkcje JSON
```

Przykład:

```sql
JSON_VALUE(OrderDoc, '$.Customer.CustomerID')
```


---

## nvarchar(max) vs json

W warsztacie używamy tabel:

```text
DemoJson.OrderDocs_Text
DemoJson.OrderDocs_Json
DemoJson.OrderDocs_Json_Indexed
```

Ich rola:

| Tabela | Zastosowanie |
|---|---|
| `DemoJson.OrderDocs_Text` | klasyczne podejście: dokument JSON w `nvarchar(max)` |
| `DemoJson.OrderDocs_Json` | dokument JSON w natywnym typie `json` |
| `DemoJson.OrderDocs_Json_Indexed` | tabela przygotowana do testów indeksów JSON |

Na poziomie podstawowych funkcji składnia może wyglądać podobnie:

```sql
JSON_VALUE(OrderDoc, '$.OrderDate')
JSON_QUERY(OrderDoc, '$.Items')
```

Różnice są istotniejsze przy:

- walidacji danych przy zapisie,
- sposobie przechowywania dokumentu,
- możliwości użycia `RETURNING`,
- indeksowaniu JSON,
- wydajności wybranych zapytań.

---

## Computed columns

Klasyczne podejście do optymalizacji zapytań po JSON polega na utworzeniu computed column, która wyciąga wartość z dokumentu JSON.

Przykład:

```sql
ALTER TABLE DemoJson.OrderDocs_Text 
ADD City1 AS JSON_VALUE(OrderDoc, '$.Shipping.City')
```

Następnie na takiej kolumnie można utworzyć zwykły indeks:

```sql
CREATE INDEX IX_OrderDocs_Text_City1 
ON DemoJson.OrderDocs_Text (City1)
```

To podejście jest szczególnie przydatne, gdy:

- mamy kilka często używanych ścieżek JSON,
- filtrujemy po konkretnych wartościach,
- sortujemy po wartościach z JSON,
- chcemy mieć kontrolę nad typem danych i strukturą indeksów.

---

## CREATE JSON INDEX

SQL Server 2025 wprowadza nowy mechanizm:

```sql
CREATE JSON INDEX
```

Przykład:

```sql
CREATE JSON INDEX IXJ_OrderDocs_Json_Indexed_OrderDoc
ON DemoJson.OrderDocs_Json_Indexed (OrderDoc)
FOR 
(
    '$.SalesPersonID',
    '$.Customer.CustomerID',
    '$.Items'
)
WITH (OPTIMIZE_FOR_ARRAY_SEARCH = ON)
```

Taki indeks jest tworzony na kolumnie typu `json`.

Możemy wskazać konkretne ścieżki, które chcemy indeksować.  
Możemy też użyć wariantu indeksującego dokument szerzej, ale w warsztacie lepiej pracować na konkretnych ścieżkach, bo łatwiej zrozumieć efekt.

Ważne ograniczenia i uwagi:

- tabela musi mieć klastrowany klucz główny,
- na jednej kolumnie `json` można utworzyć jeden indeks JSON,
- ścieżki w definicji indeksu nie mogą się nakładać,
- zmiana zestawu ścieżek wymaga odtworzenia indeksu,

---

## Metadane indeksów JSON

Po utworzeniu indeksu JSON możemy sprawdzić jego metadane.

Przydatne widoki systemowe:

```sql
sys.indexes
sys.json_indexes
sys.json_index_paths
```

Przykład:

```sql
SELECT
    OBJECT_SCHEMA_NAME(ji.object_id) AS SchemaName,
    OBJECT_NAME(ji.object_id) AS TableName,
    i.name AS IndexName,
    ji.*
FROM sys.json_indexes AS ji
INNER JOIN sys.indexes AS i
    ON i.object_id = ji.object_id
   AND i.index_id = ji.index_id;
```

Ścieżki indeksu można sprawdzić przez:

```sql
SELECT
    OBJECT_SCHEMA_NAME(jip.object_id) AS SchemaName,
    OBJECT_NAME(jip.object_id) AS TableName,
    i.name AS IndexName,
    jip.*
FROM sys.json_index_paths AS jip
INNER JOIN sys.indexes AS i
    ON i.object_id = jip.object_id
   AND i.index_id = jip.index_id;
```

---

## Zapytania, które mogą skorzystać z indeksu JSON

Indeks JSON może pomagać przy zapytaniach opartych o funkcje JSON, na przykład:

```sql
JSON_VALUE
JSON_PATH_EXISTS
JSON_CONTAINS
```

Przykłady:

```sql
WHERE JSON_VALUE(OrderDoc, '$.Customer.CustomerID' RETURNING int) = 29825
```

```sql
WHERE JSON_PATH_EXISTS(OrderDoc, '$.Items[*].ProductID') = 1
```

```sql
WHERE JSON_CONTAINS(OrderDoc, 776, '$.Items[*].ProductID') = 1
```

W praktyce zawsze warto sprawdzić:

- plan wykonania,
- `SET STATISTICS IO ON`,
- `SET STATISTICS TIME ON`,
- rozmiar indeksów,
- selektywność warunku,
- liczbę danych,
- to, czy zapytanie rzeczywiście pasuje do indeksowanych ścieżek.

---

## Demo

Do części demonstracyjnej używamy skryptów z repozytorium:

- [`sqlserver2025-tsql-json21-perf_cc.sql`](../sqlserver2025-tsql-json21-perf_cc.sql)
- [`sqlserver2025-tsql-json22-json_index.sql`](../sqlserver2025-tsql-json22-json_index.sql)
- [`sqlserver2025-tsql-json23-json_index_internal.sql`](../sqlserver2025-tsql-json23-json_index_internal.sql)
- [`sqlserver2025-tsql-json24-perf-json_sql25cu4.sql`](../sqlserver2025-tsql-json24-perf-json_sql25cu4.sql)
- [`sqlserver2025-tsql-json25-perf-json_azureSQL.sql`](../sqlserver2025-tsql-json25-perf-json_azureSQL.sql)

---

## Co dalej?

To koniec podstawowej ścieżki warsztatowej.

Po przejściu wszystkich części znasz już najważniejsze obszary pracy z JSON w SQL Server 2025:

- odczyt wartości, obiektów i tablic,
- zamianę JSON na wiersze,
- walidację i sprawdzanie zawartości dokumentów,
- modyfikowanie dokumentów,
- generowanie JSON,
- podstawy indeksowania i optymalizacji zapytań po JSON.

Dalsze samodzielne kroki:

- przejrzyj pełne skrypty demonstracyjne w repozytorium,
- porównaj plany wykonania dla różnych zapytań,
- sprawdź zachowanie na większej liczbie danych,
- przetestuj, które podejście lepiej pasuje do Twojego scenariusza: computed columns, model relacyjny czy indeks JSON.