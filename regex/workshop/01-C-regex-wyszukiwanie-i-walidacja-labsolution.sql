/******************************************************************************
    Warsztaty SQL Server 2025 - Regex
    Część 1 - Wyszukiwanie i walidacja danych

    Przykładowe rozwiązania
******************************************************************************/

USE AdventureWorks2025;
GO

/******************************************************************************
Zadanie 1
******************************************************************************/

SELECT
    EmailAddress
FROM Person.EmailAddress
WHERE REGEXP_LIKE(EmailAddress, '@adventure-works\.com$');
GO

/******************************************************************************
Zadanie 2
******************************************************************************/

SELECT
    EmailAddress
FROM Person.EmailAddress
WHERE REGEXP_LIKE(EmailAddress, '^[abc]');
GO

/******************************************************************************
Zadanie 3
******************************************************************************/

SELECT
    ProductNumber
FROM Production.Product
WHERE REGEXP_LIKE(ProductNumber, '\d$');
GO

/******************************************************************************
Zadanie 4
******************************************************************************/

SELECT
    ProductNumber
FROM Production.Product
WHERE REGEXP_COUNT(ProductNumber, '\d') = 3;
GO

/******************************************************************************
Zadanie 5
******************************************************************************/

SELECT
    EmailAddress,
    REGEXP_INSTR(EmailAddress, '@') AS AtPosition
FROM Person.EmailAddress;
GO

/******************************************************************************
Zadanie 6
******************************************************************************/

SELECT
    EmailAddress, REGEXP_COUNT(EmailAddress, '\d')
FROM Person.EmailAddress
WHERE REGEXP_COUNT(EmailAddress, '\d') > 1;
GO

/******************************************************************************
Zadanie 7
******************************************************************************/

SELECT
    ProductNumber
FROM Production.Product
WHERE REGEXP_LIKE(ProductNumber, '^[A-Z]{2}.*\d');
GO

/******************************************************************************
Zadanie 8
******************************************************************************/

SELECT
    EmailAddress,
    REGEXP_INSTR(EmailAddress, '\d') AS FirstDigitPosition
FROM Person.EmailAddress;
GO

/******************************************************************************
Zadanie 9
******************************************************************************/

SELECT
    ProductNumber
FROM Production.Product
WHERE NOT REGEXP_LIKE(ProductNumber, '\d');
GO

/******************************************************************************
Zadanie 10
******************************************************************************/

SELECT
    EmailAddress
FROM Person.EmailAddress
WHERE REGEXP_LIKE(EmailAddress, '@.+\.com$');
GO
