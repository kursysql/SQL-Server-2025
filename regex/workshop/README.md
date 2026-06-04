<a href="https://www.kursysql.pl"><img src="https://www.kursysql.pl/wp-content/uploads/2022/03/Frame-3.png" title="KursySQL.pl" alt="KursySQL.pl"></a>

# Warsztaty REGEX w SQL Server 2025
**Regex w SQL Server 2025 – praktyczne zastosowanie wyrażeń regularnych w T-SQL**

[https://www.kursysql.pl/regex-w-sql-server-2025/](https://www.kursysql.pl/regex-w-sql-server-2025/)





## Wprowadzenie

SQL Server 2025 wprowadza długo oczekiwane wsparcie dla wyrażeń regularnych (Regular Expressions). Dzięki nowym funkcjom możemy w prosty sposób wyszukiwać, walidować, przekształcać oraz analizować dane tekstowe bez konieczności tworzenia rozbudowanych funkcji T-SQL lub korzystania z zewnętrznych narzędzi.

## Cel warsztatów

Podczas warsztatów uczestnicy poznają wszystkie nowe funkcje regex dostępne w SQL Server 2025 oraz zobaczą ich praktyczne zastosowanie na rzeczywistych przykładach związanych z jakością danych, importami, integracją systemów oraz analizą tekstu.

## Forma warsztatów

Warsztaty mają formę intensywnego laboratorium. Każdy temat omawiany jest na krótkim wprowadzeniu, a następnie prezentowany w działających demonstracjach oraz ćwiczeniach wykonywanych samodzielnie przez uczestników.

Warsztat jest oparty na przykładach demonstracyjnych z katalogu:

- [`regex`](../)

oraz na zadaniach znajdujących się w tym folderze.


## Zakres warsztatów
- REGEXP_LIKE – wyszukiwanie i walidacja danych
- REGEXP_REPLACE – czyszczenie i transformacja tekstu
- REGEXP_SUBSTR – wyodrębnianie informacji z tekstu
- REGEXP_INSTR – wyszukiwanie pozycji wzorca
- REGEXP_COUNT – analiza wystąpień wzorców
- REGEXP_MATCHES – zwracanie wielu dopasowań
- REGEXP_SPLIT_TO_TABLE – rozbijanie tekstu na wiersze
- Walidacja danych z wykorzystaniem regex
- Wydajność i dobre praktyki stosowania wyrażeń regularnych


Po zakończeniu warsztatów uczestnicy będą potrafili samodzielnie wykorzystywać wyrażenia regularne w SQL Server 2025 oraz świadomie dobierać je do konkretnych problemów biznesowych i technicznych.

---

## Wymagania

Do wykonania ćwiczeń potrzebujesz:

- SQL Server 2025,
- SQL Server Management Studio,
- bazy [`AdventureWorks2025`](https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver17&tabs=ssms),
- skryptu setup:

  [`sqlserver2025-tsql-regex00-SETUP.sql`](../sqlserver2025-tsql-regex00-SETUP.sql)


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
01-A-wyszukiwanie-i-walidacja.md
01-B-wyszukiwanie-i-walidacja-lab.sql
01-C-wyszukiwanie-i-walidacja-labsolution.sql
```

Do demonstracji prowadzącego wykorzystywane są główne skrypty SQL z katalogu `json`, np.:

```text
sqlserver2025-tsql-regex02-regexp_like.sql
sqlserver2025-tsql-regex04-regexp_instr.sql
sqlserver2025-tsql-regex05-regexp_count.sql
```


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