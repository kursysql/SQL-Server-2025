/******************************************************************************
    Warsztaty SQL Server 2025 - Regex
    Część 4 - Listy i analiza tekstu

    Plik laboratoryjny
******************************************************************************/

USE AdventureWorks2025;
GO

/******************************************************************************
Zadanie 1

Rozbij poniższą listę technologii na osobne wiersze:

'SQL,Fabric,Azure,Power BI'

Wykorzystaj REGEXP_SPLIT_TO_TABLE.

Podpowiedź:

SELECT *
FROM ...
******************************************************************************/




GO

/******************************************************************************
Zadanie 2

Rozbij poniższą listę wykorzystując wiele separatorów:

'SQL;Fabric,Azure|Power BI'

Separatorami są:

- przecinek
- średnik
- znak |

Podpowiedź:

SELECT *
FROM ...
******************************************************************************/




GO

/******************************************************************************
Zadanie 3

Policz ile technologii znajduje się w poniższej liście:

'SQL,Fabric,Azure,Power BI'

Wykorzystaj REGEXP_COUNT.

Podpowiedź:

SELECT ...
******************************************************************************/




GO

/******************************************************************************
Zadanie 4

Rozbij poniższy tekst na osobne adresy email:

'adam@firma.pl;anna@test.com;jan@contoso.com'

Podpowiedź:

SELECT *
FROM ...
******************************************************************************/




GO

/******************************************************************************
Zadanie 5

Rozbij listę numerów produktów:

'HL-U509-R,LL-R230,FR-R92B'

na osobne wiersze.

Podpowiedź:

SELECT *
FROM ...
******************************************************************************/




GO

/******************************************************************************
Zadanie 6

Rozbij tekst:

'ERR-100,ERR-200,ERR-300'

na osobne wiersze.

Podpowiedź:

SELECT *
FROM ...
******************************************************************************/




GO

/******************************************************************************
Zadanie 7

Dla każdego elementu listy:

'ERR-100,ERR-200,ERR-300'

wyodrębnij część liczbową.

Wykorzystaj:

- REGEXP_SPLIT_TO_TABLE
- REGEXP_SUBSTR

Podpowiedź:

SELECT ...
******************************************************************************/




GO

/******************************************************************************
Zadanie 8

Rozbij tekst:

'SQL, Fabric, Azure, Power BI'

na wiersze i usuń zbędne spacje.

Wykorzystaj:

- REGEXP_SPLIT_TO_TABLE
- REGEXP_REPLACE

Podpowiedź:

SELECT ...
******************************************************************************/




GO

/******************************************************************************
Zadanie 9

Policz liczbę adresów email w tekście:

'adam@firma.pl;anna@test.com;jan@contoso.com'

Wykorzystaj REGEXP_COUNT.

Podpowiedź:

SELECT ...
******************************************************************************/




GO

/******************************************************************************
Zadanie 10

Scenariusz końcowy.

Dla tekstu:

'ERR-100; ERR-200; ERR-300'

1. Rozbij tekst na osobne rekordy.
2. Usuń zbędne spacje.
3. Wyodrębnij część liczbową.

Wykorzystaj poznane funkcje regex.

Podpowiedź:

SELECT ...
******************************************************************************/




GO