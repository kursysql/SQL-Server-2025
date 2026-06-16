/******************************************************************************
    Warsztaty SQL Server 2025 - Regex
    Część 2 - Czyszczenie i transformacja danych

    Plik laboratoryjny
******************************************************************************/

USE AdventureWorks2025;
GO

/******************************************************************************
Zadanie 1

Usuń wszystkie znaki niebędące cyframi z numerów telefonów.

Wykorzystaj REGEXP_REPLACE.

Podpowiedź:

SELECT
    PhoneNumber,
    ...  AS CleanPhone
FROM Person.PersonPhone;
******************************************************************************/




GO

/******************************************************************************
Zadanie 2

Usuń wszystkie spacje z adresów email.

Wykorzystaj REGEXP_REPLACE.

Podpowiedź:

SELECT
    EmailAddress,
    ...  AS CleanEmail
FROM DemoRegex.EmailAddress
WHERE CHARINDEX(' ', EmailAddress) > 0;
GO

******************************************************************************/




GO

/******************************************************************************
Zadanie 3

Zastąp wszystkie cyfry w numerach produktów znakiem X.

Przykład:

HL-U509-R -> HL-UXXX-R

Podpowiedź:

SELECT
    ProductNumber,
    ... AS ProductNumberMasked
FROM Production.Product;
******************************************************************************/




GO

/******************************************************************************
Zadanie 4

Usuń wszystkie znaki poza literami i cyframi
z numerów produktów.

Podpowiedź:

SELECT
    ProductNumber,
    ...  AS CleanProductNumber
FROM Production.Product;
******************************************************************************/




GO

/******************************************************************************
Zadanie 5

Zamień wiele kolejnych spacji na pojedynczą spację.

Przetestuj na własnym przykładzie tekstowym.

Podpowiedź:

SELECT ...
******************************************************************************/




GO

/******************************************************************************
Zadanie 6

Usuń prefiks +48 z numerów telefonów.

Podpowiedź:

SELECT
    PhoneNumber,
    ...  AS PhoneWithoutPrefix
FROM DemoRegex.PersonPhone
WHERE PhoneNumber LIKE '%+48%'
GO

******************************************************************************/




GO

/******************************************************************************
Zadanie 7

Zamień wszystkie litery w numerach produktów
na znak *.

Podpowiedź:

SELECT
    ProductNumber,
    ...  AS ProductNumberMasked
FROM Production.Product;
******************************************************************************/




GO

/******************************************************************************
Zadanie 8

Usuń wszystkie znaki specjalne z przykładowego tekstu:

SQL Server 2025! #Regex @Microsoft

Podpowiedź:

SELECT ...
******************************************************************************/




GO
