/******************************************************************************
    Warsztaty SQL Server 2025 - Regex
    Część 2 - Czyszczenie i transformacja danych

    Przykładowe rozwiązania
******************************************************************************/

USE AdventureWorks2025;
GO

/******************************************************************************
Zadanie 1
******************************************************************************/

SELECT
    PhoneNumber,
    REGEXP_REPLACE(PhoneNumber, '\D','') AS CleanPhone
FROM Person.PersonPhone;
GO

/******************************************************************************
Zadanie 2
******************************************************************************/

SELECT
    EmailAddress,
    REGEXP_REPLACE(EmailAddress, '\s', '') AS CleanEmail
FROM DemoRegex.EmailAddress
WHERE CHARINDEX(' ', EmailAddress) > 0;
GO

/******************************************************************************
Zadanie 3
******************************************************************************/

SELECT
    ProductNumber,
    REGEXP_REPLACE(ProductNumber, '\d', 'X') AS ProductNumberMasked
FROM Production.Product;
GO

/******************************************************************************
Zadanie 4
******************************************************************************/

SELECT
    ProductNumber,
    REGEXP_REPLACE(ProductNumber, '[^A-Za-z0-9]', '') AS CleanProductNumber
FROM Production.Product;
GO

/******************************************************************************
Zadanie 5
******************************************************************************/

SELECT
    REGEXP_REPLACE('SQL     Server      2025', '\s+', ' ') AS Result;
GO

/******************************************************************************
Zadanie 6
******************************************************************************/

SELECT
    PhoneNumber,
    REGEXP_REPLACE(PhoneNumber, '^\+48', '') AS PhoneWithoutPrefix
FROM DemoRegex.PersonPhone
WHERE PhoneNumber LIKE '%+48%'
GO

/******************************************************************************
Zadanie 7
******************************************************************************/

SELECT
    ProductNumber,
    REGEXP_REPLACE(ProductNumber, '[A-Za-z]', '*') AS ProductNumberMasked
FROM Production.Product;
GO

/******************************************************************************
Zadanie 8
******************************************************************************/

SELECT
    REGEXP_REPLACE(
        'SQL Server 2025! #Regex @Microsoft', '[^A-Za-z0-9 ]', '') AS CleanText;
GO
