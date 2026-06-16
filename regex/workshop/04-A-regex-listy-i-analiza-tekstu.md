<a href="https://www.kursysql.pl"><img src="https://www.kursysql.pl/wp-content/uploads/2022/03/Frame-3.png" title="KursySQL.pl" alt="KursySQL.pl"></a>

# Regex - listy i analiza tekstu

## Spis treści

* [Wprowadzenie](#wprowadzenie)
* [Cele tej części](#cele-tej-części)
* [REGEXP_SPLIT_TO_TABLE](#regexp_split_to_table)
* [Podstawowa składnia regex](#podstawowa-składnia-regex)
* [Typowe scenariusze zastosowania](#typowe-scenariusze-zastosowania)
* [Porównanie z klasycznymi funkcjami T-SQL](#porównanie-z-klasycznymi-funkcjami-t-sql)
* [Demonstracje](#demonstracje)
* [Powiązane filmy](#powiązane-filmy)
* [Pytania kontrolne](#pytania-kontrolne)
* [Zadania](#zadania)

## Wprowadzenie

W praktycznych rozwiązaniach często spotykamy dane przechowywane w postaci list wartości zapisanych w jednym polu tekstowym.

Przykłady:

* tagi przypisane do artykułu,
* lista adresów email,
* lista identyfikatorów produktów,
* dane importowane z plików CSV,
* logi aplikacyjne.

Do SQL Server 2025 podobne scenariusze realizowano najczęściej przy użyciu:

* STRING_SPLIT,
* XML,
* OPENJSON,
* własnych funkcji tabelarycznych.

SQL Server 2025 wprowadza funkcję REGEXP_SPLIT_TO_TABLE, która pozwala rozbijać tekst przy użyciu wzorców regex zamiast pojedynczych separatorów.

W tej części wykorzystamy również funkcje poznane wcześniej podczas warsztatów.

## Cele tej części

Po ukończeniu tej części będziesz potrafił:

* rozbijać tekst na wiele wierszy,
* wykorzystywać wzorce regex jako separatory,
* analizować dane półstrukturalne,
* przekształcać dane tekstowe do postaci relacyjnej,
* łączyć wiele funkcji regex w jednym rozwiązaniu.

## REGEXP_SPLIT_TO_TABLE

Funkcja rozbija tekst na wiele wierszy przy użyciu wzorca regex jako separatora.

Składnia:

```sql
REGEXP_SPLIT_TO_TABLE ( expression , pattern [ , flags ] )
```

Przykład:

```sql
SELECT *
FROM REGEXP_SPLIT_TO_TABLE(
    'SQL,Azure,Fabric,Power BI',
    ','
);
```

Typowe zastosowania:

* tagi,
* listy adresów email,
* dane CSV,
* analiza logów.

## Podstawowa składnia regex

Najczęściej wykorzystywane elementy podczas podziału tekstu:

| Element | Znaczenie                 |
| ------- | ------------------------- |
| ,       | przecinek                 |
| ;       | średnik                   |
| |       | znak pionowej kreski      |
| \s+     | jedna lub więcej spacji   |
| [,;]    | przecinek lub średnik     |
| [,\s;]+ | wiele różnych separatorów |

Przykład:

```text
SQL, Azure; Fabric | Power BI
```

może zostać rozdzielony za pomocą jednego wzorca regex.

## Typowe scenariusze zastosowania

### Tagi

Przekształcenie:

```text
SQL,Fabric,Azure,Power BI
```

na:

```text
SQL
Fabric
Azure
Power BI
```

### Listy adresów email

Rozbijanie danych importowanych z systemów zewnętrznych.

### Dane CSV

Przetwarzanie danych tekstowych przed załadowaniem do tabel.

### Logi aplikacyjne

Analiza komunikatów zawierających wiele identyfikatorów lub kodów.

### Analiza tekstu

Połączenie:

* REGEXP_SPLIT_TO_TABLE
* REGEXP_SUBSTR
* REGEXP_REPLACE
* REGEXP_COUNT

w jednym procesie przetwarzania danych.

## Porównanie z klasycznymi funkcjami T-SQL

| Zadanie           | Tradycyjne rozwiązanie | Regex                 |
| ----------------- | ---------------------- | --------------------- |
| Podział tekstu    | STRING_SPLIT           | REGEXP_SPLIT_TO_TABLE |
| Dane CSV          | STRING_SPLIT           | REGEXP_SPLIT_TO_TABLE |
| Wiele separatorów | własna logika          | REGEXP_SPLIT_TO_TABLE |
| Analiza tekstu    | wiele funkcji          | funkcje regex         |

Przykładowo:

```sql
SELECT value
FROM STRING_SPLIT(
    'SQL,Fabric,Azure',
    ','
);
```

działa wyłącznie dla jednego separatora.

Natomiast:

```sql
SELECT *
FROM REGEXP_SPLIT_TO_TABLE(
    'SQL, Fabric; Azure | Power BI',
    '[,;|]'
);
```

umożliwia wykorzystanie wielu separatorów jednocześnie.

## Demonstracje

Demonstracje omawiane w tej części znajdują się w plikach:

* [REGEXP_SPLIT_TO_TABLE](../sqlserver2025-tsql-regex07-regexp_split_to_table.sql)
* [REGEXP_COUNT](../sqlserver2025-tsql-regex05-regexp_count.sql)

## Powiązane filmy

* REGEXP_SPLIT_TO_TABLE w SQL Server 2025 — split tekstu regexem

## Pytania kontrolne

### 1. Która funkcja służy do rozbijania tekstu na wiele wierszy?

* [x] REGEXP_SPLIT_TO_TABLE
* [ ] REGEXP_SUBSTR
* [ ] REGEXP_COUNT

### 2. Która funkcja jest najbliższym odpowiednikiem REGEXP_SPLIT_TO_TABLE?

* [ ] REGEXP_MATCHES
* [x] STRING_SPLIT
* [ ] CHARINDEX

### 3. Jaką przewagę daje REGEXP_SPLIT_TO_TABLE?

* [ ] Tworzy indeksy
* [x] Umożliwia używanie wzorców regex jako separatorów
* [ ] Zawsze działa szybciej

### 4. W jakich scenariuszach funkcja jest szczególnie przydatna?

* [ ] Tworzenie tabel
* [x] Analiza list wartości i danych półstrukturalnych
* [ ] Zarządzanie uprawnieniami

## Zadania

### Ćwiczenia praktyczne

* [04-B-regex-listy-i-analiza-tekstu-lab.sql](04-B-regex-listy-i-analiza-tekstu-lab.sql)

### Rozwiązania

* [04-C-regex-listy-i-analiza-tekstu-labsolution.sql](04-C-regex-listy-i-analiza-tekstu-labsolution.sql)
