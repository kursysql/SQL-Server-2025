<a href="https://www.kursysql.pl"><img src="https://www.kursysql.pl/wp-content/uploads/2022/03/Frame-3.png" title="KursySQL.pl" alt="KursySQL.pl"></a>

# Regex - czyszczenie i transformacja danych

## Spis treści

* [Wprowadzenie](#wprowadzenie)
* [Cele tej części](#cele-tej-części)
* [REGEXP_REPLACE](#regexp_replace)
* [Podstawowa składnia regex](#podstawowa-składnia-regex)
* [Typowe scenariusze zastosowania](#typowe-scenariusze-zastosowania)
* [Porównanie z klasycznymi funkcjami T-SQL](#porównanie-z-klasycznymi-funkcjami-t-sql)
* [Demonstracje](#demonstracje)
* [Powiązane filmy](#powiązane-filmy)
* [Pytania kontrolne](#pytania-kontrolne)
* [Zadania](#zadania)

## Wprowadzenie

Jednym z najczęstszych zastosowań wyrażeń regularnych jest czyszczenie i transformacja danych tekstowych.

W codziennej pracy dane pochodzące z importów plików CSV, systemów zewnętrznych lub formularzy użytkowników często wymagają dodatkowego przetworzenia przed zapisaniem w bazie danych lub dalszą analizą.

Do SQL Server 2025 podobne operacje realizowano najczęściej za pomocą:

* REPLACE,
* TRANSLATE,
* LTRIM,
* RTRIM,
* TRIM,
* własnych funkcji T-SQL.

Nowa funkcja REGEXP_REPLACE pozwala zastępować fragmenty tekstu na podstawie wzorca regex, dzięki czemu wiele złożonych transformacji można zapisać w znacznie prostszy sposób.

## Cele tej części

Po ukończeniu tej części będziesz potrafił:

* usuwać niepożądane znaki z tekstu,
* normalizować dane pochodzące z różnych źródeł,
* przygotowywać dane do walidacji,
* wykorzystywać REGEXP_REPLACE zamiast wielu zagnieżdżonych funkcji REPLACE,
* świadomie wybierać pomiędzy klasycznymi funkcjami tekstowymi a regex.

## REGEXP_REPLACE

Funkcja zastępuje fragmenty tekstu zgodne z podanym wzorcem.

Składnia:

```sql
REGEXP_REPLACE ( expression , pattern , replacement [ , start ] [ , occurrence ] [ , flags ] )
```

Przykład:

```sql
SELECT REGEXP_REPLACE('(123) 456-7890', '\D', '');
```

Wynik:

```text
1234567890
```

Typowe zastosowania:

* czyszczenie numerów telefonów,
* usuwanie znaków specjalnych,
* normalizacja identyfikatorów,
* standaryzacja danych po imporcie.

## Podstawowa składnia regex

Najczęściej wykorzystywane elementy podczas transformacji danych:

| Element | Znaczenie                     |
| ------- | ----------------------------- |
| \d      | cyfra                         |
| \D      | znak niebędący cyfrą          |
| \w      | znak alfanumeryczny           |
| \W      | znak niealfanumeryczny        |
| \s      | biały znak                    |
| \S      | znak niebędący białym znakiem |
| +       | jedno lub więcej wystąpień    |
| *       | zero lub więcej wystąpień     |
| [ABC]   | jeden z podanych znaków       |
| [^ABC]  | dowolny znak poza podanymi    |

## Typowe scenariusze zastosowania

### Normalizacja numerów telefonów

Przekształcenie:

```text
+48 501-123-456
```

na:

```text
48501123456
```

### Czyszczenie danych po imporcie

Usuwanie:

* zbędnych spacji,
* znaków specjalnych,
* separatorów.

### Standaryzacja identyfikatorów

Przekształcanie różnych formatów danych do wspólnego standardu.

### Przygotowanie danych do walidacji

Często przed walidacją danych konieczne jest ich wcześniejsze oczyszczenie.

## Porównanie z klasycznymi funkcjami T-SQL

| Zadanie                                 | Tradycyjne rozwiązanie | Regex          |
| --------------------------------------- | ---------------------- | -------------- |
| Zamiana tekstu                          | REPLACE                | REGEXP_REPLACE |
| Zamiana wielu znaków                    | TRANSLATE              | REGEXP_REPLACE |
| Usuwanie spacji                         | TRIM                   | REGEXP_REPLACE |
| Usuwanie wszystkich znaków poza cyframi | wiele REPLACE          | REGEXP_REPLACE |

Przykładowo:

```sql
REPLACE(REPLACE(REPLACE(Phone,'-',''),' ',''),'(', '')
```

może zostać zastąpione przez:

```sql
REGEXP_REPLACE(Phone,'\D','')
```

Regex nie zawsze będzie rozwiązaniem najprostszym lub najszybszym, ale często pozwala znacząco uprościć kod.

## Demonstracje

Demonstracje omawiane w tej części znajdują się w pliku:

* [REGEXP_REPLACE](../sqlserver2025-tsql-regex02-regexp_replace.sql)

## Powiązane filmy

* REGEXP_REPLACE w SQL Server 2025 — jak czyścić dane regexem

## Pytania kontrolne

### 1. Która funkcja służy do zastępowania tekstu na podstawie wzorca regex?

* [x] REGEXP_REPLACE
* [ ] REGEXP_SUBSTR
* [ ] REGEXP_COUNT

### 2. Co oznacza wzorzec \D?

* [ ] Dowolny znak
* [x] Znak niebędący cyfrą
* [ ] Cyfra

### 3. Która funkcja jest najbliższym odpowiednikiem REGEXP_REPLACE?

* [x] REPLACE
* [ ] CHARINDEX
* [ ] STRING_SPLIT

### 4. W jakim scenariuszu REGEXP_REPLACE jest szczególnie przydatny?

* [ ] Sortowanie danych
* [x] Czyszczenie i normalizacja tekstu
* [ ] Tworzenie indeksów

## Zadania

### Ćwiczenia praktyczne

* [02-B-regex-czyszczenie-i-transformacja-lab.sql](02-B-regex-czyszczenie-i-transformacja-lab.sql)

### Rozwiązania

* [02-C-regex-czyszczenie-i-transformacja-labsolution.sql](02-C-regex-czyszczenie-i-transformacja-labsolution.sql)
