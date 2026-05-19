<a href="https://www.kursysql.pl"><img src="https://www.kursysql.pl/wp-content/uploads/2022/03/Frame-3.png" title="KursySQL.pl" alt="KursySQL.pl"></a>

# Warsztaty JSON w SQL Server 2025

Materiały do praktycznych warsztatów poświęconych pracy z JSON w SQL Server 2025.

Warsztat jest oparty na przykładach demonstracyjnych z katalogu:

- [`json`](../)

oraz na zadaniach znajdujących się w tym folderze.

## Cel warsztatu

Celem warsztatu jest praktyczne przejście przez najważniejsze mechanizmy pracy z JSON w SQL Server 2025:

- odczyt wartości, obiektów i tablic JSON,
- zamiana tablic JSON na wiersze relacyjne,
- walidacja i sprawdzanie struktury dokumentów,
- wyszukiwanie wartości w dokumentach JSON,
- modyfikowanie dokumentów JSON,
- generowanie JSON z danych relacyjnych,
- podstawy indeksowania i optymalizacji zapytań po JSON.

Materiały zawierają więcej przykładów i zadań niż zwykle da się omówić w trakcie 90-minutowego warsztatu.  
Dzięki temu można wrócić do nich po spotkaniu i przećwiczyć pominięte fragmenty samodzielnie.

---

## Wymagania

Do wykonania ćwiczeń potrzebujesz:

- SQL Server 2025,
- SQL Server Management Studio,
- bazy [`AdventureWorks2025`](https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver17&tabs=ssms),
- skryptu setup:

  [`sqlserver2025-tsql-json00-SETUP.sql`](../sqlserver2025-tsql-json00-SETUP.sql)

Opcjonalnie, do części związanej z indeksami i wydajnością:

- [`sqlserver2025-tsql-json00-SETUP_script_OrderDocs_Json_Indexed.sql`](../sqlserver2025-tsql-json00-SETUP_script_OrderDocs_Json_Indexed.sql)

---

## Konwencja nazw plików

Każda część warsztatu może składać się z trzech plików:

| Plik | Znaczenie |
|---|---|
| `XX-A-*.md` | opis części, krótkie wprowadzenie, linki do demo i lista zadań |
| `XX-B-*-lab.sql` | plik roboczy dla uczestnika, zawierający polecenia zadań i miejsca na kod |
| `XX-C-*-labsolution.sql` | przykładowe rozwiązania zadań oraz odpowiedzi na pytania kontrolne |

Przykład:

```text
01-A-json-value-json-query.md
01-B-json-value-json-query-lab.sql
01-C-json-value-json-query-labsolution.sql
```

Do demonstracji prowadzącego wykorzystywane są główne skrypty SQL z katalogu `json`, np.:

```text
sqlserver2025-tsql-json01-json_value.sql
sqlserver2025-tsql-json02-json_query.sql
sqlserver2025-tsql-json03-openjson.sql
```

---

## Części warsztatu

| Część | Temat | Materiał | Lab | Rozwiązania |
|---|---|---|---|---|
| 00 | Przygotowanie środowiska | [`00-A-przygotowanie-srodowiska.md`](00-A-przygotowanie-srodowiska.md) | | |
| 01 | `JSON_VALUE` i `JSON_QUERY` | [`01-A-json-value-json-query.md`](01-A-json-value-json-query.md) | [`01-B-json-value-json-query-lab.sql`](01-B-json-value-json-query-lab.sql) | [`01-C-json-value-json-query-labsolution.sql`](01-C-json-value-json-query-labsolution.sql) |
| 02 | `OPENJSON` | [`02-A-openjson.md`](02-A-openjson.md) | [`02-B-openjson-lab.sql`](02-B-openjson-lab.sql) | [`02-C-openjson-labsolution.sql`](02-C-openjson-labsolution.sql) |
| 03 | Walidacja, ścieżki i wyszukiwanie | [`03-A-walidacja-sciezki-i-wyszukiwanie.md`](03-A-walidacja-sciezki-i-wyszukiwanie.md) | [`03-B-walidacja-sciezki-i-wyszukiwanie-lab.sql`](03-B-walidacja-sciezki-i-wyszukiwanie-lab.sql) | [`03-C-walidacja-sciezki-i-wyszukiwanie-labsolution.sql`](03-C-walidacja-sciezki-i-wyszukiwanie-labsolution.sql) |
| 04 | `JSON_MODIFY` | [`04-A-json-modify.md`](04-A-json-modify.md) | [`04-B-json-modify-lab.sql`](04-B-json-modify-lab.sql) | [`04-C-json-modify-labsolution.sql`](04-C-json-modify-labsolution.sql) |
| 05 | Generowanie JSON | [`05-A-generowanie-json.md`](05-A-generowanie-json.md) | [`05-B-generowanie-json-lab.sql`](05-B-generowanie-json-lab.sql) | [`05-C-generowanie-json-labsolution.sql`](05-C-generowanie-json-labsolution.sql) |
| 06 | Typ `json`, indeksy i wydajność | [`06-A-json-index-i-performance.md`](06-A-json-index-i-performance.md) |  |  |

---

## Zakres funkcji

W trakcie warsztatu pojawiają się między innymi:

| Obszar | Funkcje / mechanizmy |
|---|---|
| Odczyt danych | `JSON_VALUE`, `JSON_QUERY` |
| Zamiana JSON na wiersze | `OPENJSON`, `WITH`, `CROSS APPLY` |
| Walidacja i sprawdzanie struktury | `ISJSON`, `JSON_PATH_EXISTS` |
| Wyszukiwanie zawartości | `JSON_CONTAINS` |
| Modyfikowanie dokumentów | `JSON_MODIFY` |
| Generowanie JSON | `JSON_OBJECT`, `JSON_ARRAY`, `JSON_OBJECTAGG`, `JSON_ARRAYAGG` |
| SQL Server 2025 | typ `json`, `RETURNING json`, `CREATE JSON INDEX` |
| Wydajność | computed columns, indeksy, statystyki IO/TIME, plany wykonania |

---

## Jak korzystać z materiałów

1. Uruchom setup środowiska.
2. Otwórz plik `XX-A-*.md`, żeby przeczytać opis i listę zadań.
3. Otwórz plik `XX-B-*-lab.sql` i wpisuj swoje rozwiązania pod komentarzami:

   ```sql
   -- tu wstaw Twój kod
   ```

4. Po wykonaniu zadań porównaj swoje rozwiązania z plikiem `XX-C-*-labsolution.sql`.
5. Odpowiedzi na pytania kontrolne znajdują się na końcu plików `labsolution.sql`.

---

## Autor

Tomasz Libera | MVP Data Platform  
libera@kursysql.pl

http://www.kursysql.pl  
http://www.youtube.com/c/KursySQL