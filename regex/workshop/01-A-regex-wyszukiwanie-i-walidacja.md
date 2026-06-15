<a href="https://www.kursysql.pl"><img src="https://www.kursysql.pl/wp-content/uploads/2022/03/Frame-3.png" title="KursySQL.pl" alt="KursySQL.pl"></a>

# Regex - wyszukiwanie i walidacja danych

## Spis treści

- [Wprowadzenie](#wprowadzenie)
- [REGEXP_LIKE](#regexp_like)
- [REGEXP_INSTR](#regexp_instr)
- [REGEXP_COUNT](#regexp_count)
- [Podstawowa składnia regex](#podstawowa-składnia-regex)
- [Porównanie z klasycznymi funkcjami T-SQL](#porównanie-z-klasycznymi-funkcjami-t-sql)
- [Demonstracje](#demonstracje)
- [Pytania kontrolne](#pytania-kontrolne)
- [Zadania](#zadania)


## Wprowadzenie

Wyrażenia regularne (Regular Expressions, Regex) umożliwiają wyszukiwanie, walidację oraz analizę danych tekstowych przy użyciu specjalnej składni opisującej wzorce.

Do czasu pojawienia się SQL Server 2025 podobne zadania realizowano najczęściej za pomocą funkcji:

* LIKE
* PATINDEX
* CHARINDEX

lub własnych funkcji T-SQL.

SQL Server 2025 wprowadza natywne wsparcie dla wyrażeń regularnych, dzięki czemu możliwe jest tworzenie bardziej elastycznych i czytelnych zapytań służących do wyszukiwania oraz walidacji danych.

W tej części warsztatów poznasz funkcje:

* REGEXP_LIKE
* REGEXP_INSTR
* REGEXP_COUNT

## REGEXP_LIKE

Funkcja sprawdza, czy wskazany tekst spełnia określony wzorzec.

Składnia:

```sql
REGEXP_LIKE ( expression , pattern [ , flags ] )
```

Przykład:

```sql
SELECT REGEXP_LIKE('CUST-12345', '^CUST-\d{5}$');
```

Typowe zastosowania:

* walidacja adresów email,
* walidacja numerów telefonów,
* walidacja kodów pocztowych,
* sprawdzanie formatów identyfikatorów.

## REGEXP_INSTR

Funkcja zwraca pozycję pierwszego dopasowania wzorca.

Składnia:

```sql
REGEXP_INSTR ( expression , pattern [ , start ] [ , occurrence ] [ , flags ] )
```

Przykład:

```sql
SELECT REGEXP_INSTR('ABC123XYZ', '\d');
```

Typowe zastosowania:

* wyszukiwanie pozycji separatorów,
* odnajdywanie fragmentów danych,
* analiza logów i komunikatów.

## REGEXP_COUNT

Funkcja zwraca liczbę dopasowań wzorca.

Składnia:

```sql
REGEXP_COUNT ( expression , pattern [ , start ] [ , flags ] )
```

Przykład:

```sql
SELECT REGEXP_COUNT('A1B2C3', '\d');
```

Typowe zastosowania:

* liczenie cyfr,
* liczenie separatorów,
* analiza zawartości tekstu.

## Podstawowa składnia regex

| Element | Znaczenie                  |
| ------- | -------------------------- |
| ^       | początek tekstu            |
| $       | koniec tekstu              |
| .       | dowolny znak               |
| \d      | cyfra                      |
| \D      | znak niebędący cyfrą       |
| \w      | znak alfanumeryczny        |
| \s      | biały znak                 |
| +       | jedno lub więcej wystąpień |
| *       | zero lub więcej wystąpień  |
| ?       | wystąpienie opcjonalne     |
| {n}     | dokładnie n wystąpień      |
| {n,m}   | od n do m wystąpień        |
| [ABC]   | jeden z podanych znaków    |
| [^ABC]  | dowolny znak poza podanymi |

## Porównanie z klasycznymi funkcjami T-SQL

| Zadanie                          | Tradycyjne rozwiązanie | Regex        |
| -------------------------------- | ---------------------- | ------------ |
| Sprawdzenie zgodności ze wzorcem | LIKE                   | REGEXP_LIKE  |
| Wyszukanie pozycji tekstu        | CHARINDEX              | REGEXP_INSTR |
| Wyszukiwanie wzorców             | PATINDEX               | REGEXP_LIKE  |
| Liczenie wystąpień               | własna logika          | REGEXP_COUNT |

Nie oznacza to jednak, że regex powinien zastąpić wszystkie klasyczne funkcje tekstowe.

Przykładowo:

```sql
WHERE Email LIKE '%@gmail.com'
```

jest prostsze i bardziej czytelne niż:

```sql
WHERE REGEXP_LIKE(Email, '@gmail\.com$')
```

Regex warto stosować przede wszystkim wtedy, gdy:

* wzorzec jest złożony,
* wymagamy walidacji formatu danych,
* klasyczne funkcje prowadzą do rozbudowanych warunków.

## Demonstracje

Demonstracje omawiane w tej części znajdują się w plikach:

- [REGEXP_LIKE](../sqlserver2025-tsql-regex01-regexp_like.sql)
- [REGEXP_INSTR](../sqlserver2025-tsql-regex04-regexp_instr.sql)
- [REGEXP_COUNT](../sqlserver2025-tsql-regex05-regexp_count.sql)

## Pytania kontrolne

### 1. Która funkcja służy do sprawdzania zgodności tekstu ze wzorcem?

* [x] REGEXP_LIKE
* [ ] REGEXP_REPLACE
* [ ] REGEXP_SUBSTR

### 2. Który symbol oznacza początek tekstu?

* [x] ^
* [ ] $
* [ ] *

### 3. Która funkcja jest najbliższym odpowiednikiem CHARINDEX?

* [ ] REGEXP_LIKE
* [x] REGEXP_INSTR
* [ ] REGEXP_COUNT

### 4. Która funkcja zwraca liczbę dopasowań wzorca?

* [ ] REGEXP_INSTR
* [ ] REGEXP_LIKE
* [x] REGEXP_COUNT

## Zadania

- [Plik laboratoryjny](01-B-regex-wyszukiwanie-i-walidacja-lab.sql)
- [Przykładowe rozwiązania](01-C-regex-wyszukiwanie-i-walidacja-labsolution.sql)

