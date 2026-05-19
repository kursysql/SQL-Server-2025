<a href="https://www.kursysql.pl"><img src="https://www.kursysql.pl/wp-content/uploads/2022/03/Frame-3.png" title="KursySQL.pl" alt="KursySQL.pl"></a>

# 00. JSON w SQL Server 2025 - wprowadzenie i przygotowanie

## Spis treści

- [Cel tej części](#cel-tej-części)
- [Format warsztatu](#format-warsztatu)
- [Konwencja nazw plików](#konwencja-nazw-plików)
- [Co będziemy robić?](#co-będziemy-robić)
- [Mapa funkcji omawianych w warsztacie](#mapa-funkcji-omawianych-w-warsztacie)
- [Po co JSON w SQL Server?](#po-co-json-w-sql-server)
- [Przygotowanie środowiska](#przygotowanie-środowiska)
- [Wymagania](#wymagania)
- [Zadanie 1. Przygotowanie danych](#zadanie-1-przygotowanie-danych)
- [Zadanie 2. Porównanie rozmiaru tabel](#zadanie-2-porównanie-rozmiaru-tabel)
- [Pytania kontrolne](#pytania-kontrolne)
- [Co dalej?](#co-dalej)

---

## Cel tej części

W tej części przygotujemy środowisko do warsztatu i zobaczymy, na jakich danych będziemy pracować.

To nie jest jeszcze właściwe demo funkcji JSON.  
Celem jest zrozumienie:

- po co używać JSON w SQL Server,
- jaki model danych wykorzystujemy w warsztacie,
- czym różni się przechowywanie JSON jako `nvarchar(max)` od typu `json`,
- jakie tabele zostaną utworzone w schemacie `DemoJson`,
- jak sprawdzić, czy środowisko jest gotowe do dalszych ćwiczeń.

---

## Format warsztatu

Każdy moduł składa się z części demonstracyjnej i zadań.

Materiały są przygotowane tak, żeby można było:

- przejść przez wybrane przykłady razem z prowadzącym,
- uruchamiać kod SQL z osobnego pliku demo,
- wykonać zadania samodzielnie,
- porównać swoje rozwiązania z plikiem z przykładowymi odpowiedziami.

Materiały w repozytorium zawierają więcej przykładów niż zdążymy omówić na żywo.  
Dzięki temu po warsztacie można wrócić do pominiętych fragmentów.

---

## Konwencja nazw plików

Każdy rozdział warsztatu składa się z dwóch plików w folderze `workshop`:

| Plik | Znaczenie |
|---|---|
| `XX-A-*.md` | główny materiał warsztatowy: opis, linki do demo i zadania |
| `XX-C-*-labsolution.sql` | przykładowe rozwiązania zadań |

Przykład:

```text
01-A-json-value-json-query.md
01-B-json-value-json-query-labsolution.sql
```

Dzięki takiej konwencji pliki układają się alfabetycznie w kolejności pracy:

```text
A - materiał do przeczytania i zadania
B - rozwiązania zadań
```

---

## Co będziemy robić?

Podczas warsztatu przejdziemy przez cztery obszary:

1. Odczyt danych z dokumentów JSON
2. Zamiana JSON na postać relacyjną
3. Generowanie JSON z danych relacyjnych
4. Wydajność i indeksowanie JSON w SQL Server 2025

---

## Mapa funkcji omawianych w warsztacie

W warsztacie pojawią się wszystkie funkcje JSON pokazane w skryptach demonstracyjnych z repozytorium.

Nie wszystkie funkcje będą omawiane z taką samą szczegółowością podczas części live.  
Najwięcej czasu poświęcimy na `JSON_VALUE`, `JSON_QUERY`, `OPENJSON` oraz indeksowanie JSON. Pozostałe funkcje pojawią się w formie krótszych demonstracji, zadań lub materiałów do samodzielnego przejrzenia po warsztacie.

| Rozdział | Funkcje / mechanizmy | Skrypty SQL | Poziom szczegółowości |
|---|---|---|---|
| 00 | setup środowiska, tabele demo, `nvarchar(max)` vs `json` | [`json00-SETUP`](../sqlserver2025-tsql-json00-SETUP.sql), [`json00-SETUP OrderDocs_Json_Indexed`](../sqlserver2025-tsql-json00-SETUP_script_OrderDocs_Json_Indexed.sql) | techniczne przygotowanie |
| 01 | `JSON_VALUE`, `JSON_QUERY`, ścieżki JSON, `lax`, `strict` | [`json01-json_value`](../sqlserver2025-tsql-json01-json_value.sql), [`json02-json_query`](../sqlserver2025-tsql-json02-json_query.sql) | dokładnie |
| 02 | `OPENJSON`, `WITH`, `CROSS APPLY` | [`json03-openjson`](../sqlserver2025-tsql-json03-openjson.sql) | dokładnie |
| 03 | `ISJSON`, `JSON_PATH_EXISTS`, `JSON_CONTAINS` | [`json04-isjson`](../sqlserver2025-tsql-json04-isjson.sql), [`json05-json_path_exists`](../sqlserver2025-tsql-json05-json_path_exists.sql), [`json06-json_contains`](../sqlserver2025-tsql-json06-json_contains.sql) | średnio / przeglądowo |
| 04 | `JSON_MODIFY` | [`json07-json_modify`](../sqlserver2025-tsql-json07-json_modify.sql) | średnio |
| 05 | `JSON_OBJECT`, `JSON_ARRAY`, `JSON_OBJECTAGG`, `JSON_ARRAYAGG` | [`json08-json_object`](../sqlserver2025-tsql-json08-json_object.sql), [`json09-json_array`](../sqlserver2025-tsql-json09-json_array.sql), [`json10-json_objectagg`](../sqlserver2025-tsql-json10-json_objectagg.sql), [`json11-json_arrayagg`](../sqlserver2025-tsql-json11-json_arrayagg.sql) | średnio |
| 06 | typ `json`, computed columns, `CREATE JSON INDEX`, metadane indeksów JSON, performance | [`json21-perf_cc`](../sqlserver2025-tsql-json21-perf_cc.sql), [`json22-json_index`](../sqlserver2025-tsql-json22-json_index.sql), [`json23-json_index_internal`](../sqlserver2025-tsql-json23-json_index_internal.sql), [`json24-perf-json_sql25cu4`](../sqlserver2025-tsql-json24-perf-json_sql25cu4.sql), [`json25-perf-json_azureSQL`](../sqlserver2025-tsql-json25-perf-json_azureSQL.sql) | przeglądowo + demo |

---

## Po co JSON w SQL Server?

JSON przydaje się wtedy, gdy dane:

- pochodzą z aplikacji, API, komunikatów lub logów,
- mają strukturę dokumentową,
- zawierają obiekty zagnieżdżone i tablice,
- nie zawsze mają identyczny zestaw właściwości,
- są częściowo relacyjne, a częściowo półstrukturalne.

Przykłady:

- zamówienie z listą pozycji,
- konfiguracja klienta,
- zdarzenie aplikacyjne,
- odpowiedź z API,
- dane telemetryczne,
- dokument z metadanymi.

W SQL Server nie chodzi o to, żeby zastąpić model relacyjny dokumentowym.  
Chodzi raczej o to, żeby umieć połączyć oba podejścia.

---

## Przygotowanie środowiska

W tej części sprawdzimy, czy środowisko działa poprawnie i czy dane do warsztatu zostały przygotowane.

Po wykonaniu ćwiczeń powinieneś umieć:

- sprawdzić, czy istnieje schemat `DemoJson`,
- sprawdzić, czy istnieją tabele warsztatowe,
- wyświetlić przykładowy dokument,
- sprawdzić rozmiar tabel.

---

## Wymagania

Do wykonania ćwiczeń potrzebujesz:

- SQL Server 2025,
- bazy `AdventureWorks2025`,
- skryptu setup:

  [`sqlserver2025-tsql-json00-SETUP.sql`](../sqlserver2025-tsql-json00-SETUP.sql)

Opcjonalnie, do części związanej z indeksami i wydajnością:

  [`sqlserver2025-tsql-json00-SETUP_script_OrderDocs_Json_Indexed.sql`](../sqlserver2025-tsql-json00-SETUP_script_OrderDocs_Json_Indexed.sql)

---

## Zadanie 1. Przygotowanie danych

1. Sklonuj lokalnie repozytorium z materiałami do warsztatu:

   https://github.com/kursysql/SQL-Server-2025

2. Uruchom SSMS.

3. W razie potrzeby pobierz i przygotuj bazę [`AdventureWorks2025`](https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver17&tabs=ssms).

4. Uruchom skrypt setup:

   [`sqlserver2025-tsql-json00-SETUP.sql`](../sqlserver2025-tsql-json00-SETUP.sql)

5. Sprawdź, czy istnieją tabele:

   - `DemoJson.OrderDocs_Text`
   - `DemoJson.OrderDocs_Json`
   - `DemoJson.OrderDocs_Json_Indexed`

6. Wyświetl pierwsze 10 rekordów z każdej z powyższych tabel i zapoznaj się z ich zawartością.

---

## Zadanie 2. Porównanie rozmiaru tabel

Porównaj rozmiar tabel za pomocą poniższych poleceń:

```sql
EXEC sp_spaceused 'DemoJson.OrderDocs_Text';
GO

EXEC sp_spaceused 'DemoJson.OrderDocs_Json';
GO

EXEC sp_spaceused 'DemoJson.OrderDocs_Json_Indexed';
GO
```

---

## Pytania kontrolne

1. Jaki schemat został utworzony na potrzeby warsztatu?
2. Jakie trzy główne tabele będą używane w ćwiczeniach?
3. Która tabela przechowuje dokument JSON jako `nvarchar(max)`?
4. Która tabela przechowuje dokument JSON jako typ `json`?
5. Która tabela będzie używana później do testów indeksów i wydajności?
6. Czy rozmiar tabel `OrderDocs_Text` i `OrderDocs_Json` jest taki sam?
7. Dlaczego warto sprawdzić rozmiar tabel już na początku?
8. Które funkcje JSON będą omawiane najdokładniej podczas warsztatu?
9. Które funkcje są zaplanowane jako krótszy przegląd?

---

## Co dalej?

W kolejnym rozdziale zaczniemy odczytywać dane z dokumentów JSON.

Pierwsze funkcje, których użyjemy, to:

- `JSON_VALUE`
- `JSON_QUERY`