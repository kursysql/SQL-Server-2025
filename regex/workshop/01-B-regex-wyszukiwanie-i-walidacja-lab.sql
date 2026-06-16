/******************************************************************************
    Warsztaty SQL Server 2025 - Regex
    Część 1 - Wyszukiwanie i walidacja danych

    Plik laboratoryjny
******************************************************************************/

USE AdventureWorks2025;
GO

/******************************************************************************
Zadanie 1

Znajdź wszystkie adresy email w domenie adventure-works.com.

Wykorzystaj funkcję REGEXP_LIKE.

Podpowiedź:

SELECT
    EmailAddress
FROM Person.EmailAddress
WHERE ...
******************************************************************************/




GO

/******************************************************************************
Zadanie 2

Znajdź wszystkie adresy email rozpoczynające się
od liter a, b lub c.

Wykorzystaj REGEXP_LIKE.

Podpowiedź:

SELECT
    EmailAddress
FROM Person.EmailAddress
WHERE ...
******************************************************************************/




GO

/******************************************************************************
Zadanie 3

Znajdź wszystkie produkty, których numer produktu
kończy się cyfrą.

Wykorzystaj REGEXP_LIKE.

Podpowiedź:

SELECT
    ProductNumber
FROM Production.Product
WHERE ...
******************************************************************************/




GO

/******************************************************************************
Zadanie 4

Znajdź wszystkie produkty, których numer produktu
zawiera dokładnie 3 cyfry.

Wykorzystaj REGEXP_COUNT.

Podpowiedź:

SELECT
    ProductNumber
FROM Production.Product
WHERE ...
******************************************************************************/




GO

/******************************************************************************
Zadanie 5

Wyświetl wszystkie adresy email oraz pozycję znaku @.

Wykorzystaj REGEXP_INSTR.

Podpowiedź:

SELECT
    EmailAddress,
    ... AS AtPosition
FROM Person.EmailAddress;
******************************************************************************/




GO

/******************************************************************************
Zadanie 6

Znajdź adresy email zawierające więcej niż jedną cyfrę.

Wykorzystaj REGEXP_COUNT.

Podpowiedź:

SELECT
    EmailAddress
FROM Person.EmailAddress
WHERE ...
******************************************************************************/




GO

/******************************************************************************
Zadanie 7

Znajdź produkty, których numer produktu rozpoczyna się
od dwóch (wielkich) liter, 
po których występuje dowolny tekst i przynajmniej jedna cyfra.

Wykorzystaj REGEXP_LIKE.

Podpowiedź:

SELECT
    ProductNumber
FROM Production.Product
WHERE ...
******************************************************************************/




GO

/******************************************************************************
Zadanie 8

Dla każdego adresu email zwróć:

- adres email
- pozycję pierwszej cyfry

Jeżeli adres nie zawiera cyfr, REGEXP_INSTR zwróci 0.

Wykorzystaj REGEXP_INSTR.

Podpowiedź:

SELECT
    EmailAddress,
    ... AS FirstDigitPosition
FROM Person.EmailAddress;
******************************************************************************/




GO

/******************************************************************************
Zadanie 9

Znajdź wszystkie produkty, których numer produktu
nie zawiera cyfr.

Wykorzystaj REGEXP_LIKE.

Podpowiedź:

SELECT
    ProductNumber
FROM Production.Product
WHERE ...
******************************************************************************/




GO

/******************************************************************************
Zadanie 10

Znajdź wszystkie adresy email, które:

- zawierają znak @
- kończą się domeną .com

Wykorzystaj REGEXP_LIKE.

Podpowiedź:

SELECT
    EmailAddress
FROM Person.EmailAddress
WHERE ...
******************************************************************************/




GO