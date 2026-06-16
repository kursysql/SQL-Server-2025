/******************************************************************************
    Warsztaty SQL Server 2025 - Regex
    Część 3 - Wyodrębnianie informacji

    Plik laboratoryjny
******************************************************************************/

USE AdventureWorks2025;
GO

/******************************************************************************
Zadanie 1

Z tekstu:

'Faktura FV/2025/00123'

wyodrębnij numer faktury.

Wykorzystaj REGEXP_SUBSTR.

******************************************************************************/




GO

/******************************************************************************
Zadanie 2

Z adresów email wyodrębnij nazwę domeny.

Przykład:

adam@firma.pl -> firma.pl

Podpowiedź:
żeby usunąć znak @ użyj grupy przechwytującej i zwróć tylko jej zawartość.

SELECT
    EmailAddress,
    ... ) AS Domain
FROM Person.EmailAddress;
******************************************************************************/




GO

/******************************************************************************
Zadanie 3

Z numerów produktów wyodrębnij pierwszą cyfrę.

Podpowiedź:

SELECT
    ProductNumber,
    ...  AS FirstDigit
FROM Production.Product;
******************************************************************************/




GO

/******************************************************************************
Zadanie 4

Z tekstu:

'SQL Server 2025'

wyodrębnij numer wersji.

Podpowiedź:

SELECT ...
******************************************************************************/




GO

/******************************************************************************
Zadanie 5

Z tekstu:

'Produkt A123, B456 oraz C789'

wyświetl wszystkie identyfikatory produktów.

Wykorzystaj REGEXP_MATCHES.

Podpowiedź:

SELECT *
FROM ...
******************************************************************************/




GO

/******************************************************************************
Zadanie 6

Z adresów email wyodrębnij część znajdującą się
przed znakiem @.

Podpowiedź:

SELECT
    EmailAddress,
    ...  AS LoginPart
FROM Person.EmailAddress;
******************************************************************************/




GO

/******************************************************************************
Zadanie 7

Z tekstu:

'Kontakt: adam@firma.pl, anna@test.com'

wyświetl wszystkie adresy email.

Wykorzystaj REGEXP_MATCHES.

Podpowiedź:

SELECT *
FROM ...
******************************************************************************/




GO

/******************************************************************************
Zadanie 8

Z numerów produktów wyodrębnij pierwszą sekwencję cyfr.

Podpowiedź:

SELECT
    ProductNumber,
    ...
FROM Production.Product;
******************************************************************************/




GO

/******************************************************************************
Zadanie 9

Z tekstu:

'Błąd ERR-100, ERR-200, ERR-300'

wyświetl wszystkie kody błędów (bez przecinków i spacji i napisy "Błąd")

Wykorzystaj REGEXP_MATCHES.

Podpowiedź:

SELECT *
FROM ...
******************************************************************************/




GO

/******************************************************************************
Zadanie 10

Z tekstu:

'Plik backup_20250615.zip'

wyodrębnij datę.

Podpowiedź:

SELECT ...
******************************************************************************/




GO