<a href="https://www.kursysql.pl"><img src="https://www.kursysql.pl/wp-content/uploads/2022/03/Frame-3.png" title="KursySQL.pl" alt="KursySQL.pl"></a>

# Regex - wyodrębnianie informacji

## Spis treści

* [Wprowadzenie](#wprowadzenie)
* [Cele tej części](#cele-tej-części)
* [REGEXP_SUBSTR](#regexp_substr)
* [REGEXP_MATCHES](#regexp_matches)
* [Podstawowa składnia regex](#podstawowa-składnia-regex)
* [Typowe scenariusze zastosowania](#typowe-scenariusze-zastosowania)
* [Porównanie z klasycznymi funkcjami T-SQL](#porównanie-z-klasycznymi-funkcjami-t-sql)
* [Demonstracje](#demonstracje)
* [Powiązane filmy](#powiązane-filmy)
* [Pytania kontrolne](#pytania-kontrolne)
* [Zadania](#zadania)

## Wprowadzenie

W wielu przypadkach przechowujemy w bazie danych tekst zawierający wiele różnych informacji, ale interesuje nas jedynie jego wybrany fragment.

Przykładowo:

* numer faktury zapisany w opisie,
* domena adresu email,
* identyfikator produktu ukryty w nazwie pliku,
* numer zgłoszenia znajdujący się w logu aplikacyjnym.

Do SQL Server 2025 podobne zadania realizowano najczęściej przy użyciu:

* SUBSTRING,
* CHARINDEX,
* PATINDEX,
* PARSENAME,
* własnych funkcji T-SQL.

Nowe funkcje regex pozwalają wyodrębniać dane bez konieczności ręcznego określania pozycji początkowej i końcowej.

W tej części poznasz:

* REGEXP_SUBSTR
* REGEXP_MATCHES

## Cele tej części

Po ukończeniu tej części będziesz potrafił:

* wyciągać fragmenty tekstu zgodne z określonym wzorcem,
* pobierać wiele dopasowań z jednego ciągu znaków,
* analizować logi i dane półstrukturalne,
* upraszczać kod wykorzystujący SUBSTRING i CHARINDEX,
* wykorzystywać regex do ekstrakcji danych biznesowych.

## REGEXP_SUBSTR

Funkcja zwraca fragment tekstu zgodny z podanym wzorcem.

Składnia:

```sql
REGEXP_SUBSTR ( expression , pattern [ , start ] [ , occurrence ] [ , flags ] )
```

Przykład:

```sql
SELECT REGEXP_SUBSTR(
    'Faktura FV/2025/00123',
    'FV/[0-9]{4}/[0-9]+'
);
```

Typowe zastosowania:

* numery faktur,
* numery zamówień,
* identyfikatory produktów,
* domeny adresów email.

## REGEXP_MATCHES

Funkcja zwraca wszystkie dopasowania wzorca znalezione w tekście.

Przykład:

```sql
SELECT *
FROM REGEXP_MATCHES(
    'Produkt A123, B456 oraz C789',
    '[A-Z][0-9]{3}'
);
```

Typowe zastosowania:

* analiza logów,
* ekstrakcja wielu identyfikatorów,
* analiza tagów,
* przetwarzanie danych półstrukturalnych.

## Podstawowa składnia regex

Najczęściej wykorzystywane elementy podczas ekstrakcji danych:

| Element | Znaczenie                  |
| ------- | -------------------------- |
| \d      | cyfra                      |
| \w      | znak alfanumeryczny        |
| +       | jedno lub więcej wystąpień |
| *       | zero lub więcej wystąpień  |
| ?       | wystąpienie opcjonalne     |
| {n}     | dokładnie n wystąpień      |
| {n,m}   | od n do m wystąpień        |
| [ABC]   | jeden z podanych znaków    |
| [^ABC]  | dowolny znak poza podanymi |
| (...)   | grupa                      |

## Typowe scenariusze zastosowania

### Numery faktur

Wyodrębnianie numerów dokumentów z opisów.

Przykład:

```text
Zamówienie zrealizowano na podstawie faktury FV/2025/00123
```

### Domeny adresów email

Wyodrębnianie części domenowej adresu.

Przykład:

```text
jan.kowalski@firma.pl
```

### Analiza logów

Pobieranie identyfikatorów sesji, błędów i zgłoszeń.

### Nazwy plików

Wyodrębnianie numerów wersji lub identyfikatorów z nazw plików.

## Porównanie z klasycznymi funkcjami T-SQL

| Zadanie          | Tradycyjne rozwiązanie | Regex          |
| ---------------- | ---------------------- | -------------- |
| Fragment tekstu  | SUBSTRING              | REGEXP_SUBSTR  |
| Pozycja wzorca   | CHARINDEX              | REGEXP_INSTR   |
| Wzorzec tekstowy | PATINDEX               | REGEXP_SUBSTR  |
| Wiele dopasowań  | własna logika          | REGEXP_MATCHES |

Przykładowo:

```sql
SUBSTRING(
    Email,
    CHARINDEX('@', Email) + 1,
    LEN(Email)
)
```

może zostać zastąpione przez:

```sql
REGEXP_SUBSTR(
    Email,
    '@(.+)$'
)
```

Największą przewagą regex jest możliwość opisania wzorca zamiast ręcznego określania pozycji znaków.

## Demonstracje

Demonstracje omawiane w tej części znajdują się w plikach:

* [REGEXP_SUBSTR](../sqlserver2025-tsql-regex03-regexp_substr.sql)
* [REGEXP_MATCHES](../sqlserver2025-tsql-regex06-regexp_matches.sql)

## Powiązane filmy

* REGEXP_SUBSTR w SQL Server 2025 — wyciąganie danych z tekstu
* REGEXP_MATCHES w SQL Server 2025 — wiele dopasowań z tekstu

## Pytania kontrolne

### 1. Która funkcja służy do pobierania fragmentu tekstu zgodnego ze wzorcem?

* [x] REGEXP_SUBSTR
* [ ] REGEXP_COUNT
* [ ] REGEXP_REPLACE

### 2. Która funkcja zwraca wiele dopasowań?

* [ ] REGEXP_SUBSTR
* [x] REGEXP_MATCHES
* [ ] REGEXP_INSTR

### 3. Która klasyczna funkcja najczęściej była wykorzystywana razem z SUBSTRING?

* [x] CHARINDEX
* [ ] REPLACE
* [ ] STRING_SPLIT

### 4. Jaką przewagę daje REGEXP_SUBSTR?

* [ ] Zawsze działa szybciej
* [x] Pozwala wyszukiwać dane na podstawie wzorca
* [ ] Tworzy indeksy

## Zadania

### Ćwiczenia praktyczne

* [03-B-regex-wyodrebnianie-informacji-lab.sql](03-B-regex-wyodrebnianie-informacji-lab.sql)

### Rozwiązania

* [03-C-regex-wyodrebnianie-informacji-labsolution.sql](03-C-regex-wyodrebnianie-informacji-labsolution.sql)
