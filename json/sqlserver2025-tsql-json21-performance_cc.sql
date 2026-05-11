/*

    TSQL: JSON_VALUE wydajność - computed columns i indeksy
    Tomasz Libera | MVP Data Platform
    libera@kursysql.pl

    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL
    https://github.com/kursysql/SQL-Server-2025/


*/


USE AdventureWorks2025
GO



SELECT *FROM DemoJson.OrderDocs_Text


SET STATISTICS IO ON





DROP INDEX IF EXISTS IX_OrderDocs_Text_City1 ON DemoJson.OrderDocs_Text;
DROP INDEX IF EXISTS IX_OrderDocs_Text_CustomerID1 ON DemoJson.OrderDocs_Text;
DROP INDEX IF EXISTS IX_OrderDocs_Text_CustomerID2 ON DemoJson.OrderDocs_Text;
GO

ALTER TABLE DemoJson.OrderDocs_Text DROP COLUMN City1
GO
ALTER TABLE DemoJson.OrderDocs_Text DROP COLUMN CustomerID1
GO
ALTER TABLE DemoJson.OrderDocs_Text DROP COLUMN CustomerID2
GO





DROP INDEX IF EXISTS IX_OrderDocs_Json_City1 ON DemoJson.OrderDocs_Text;
DROP INDEX IF EXISTS IX_OrderDocs_Json_CustomerID2 ON DemoJson.OrderDocs_Text;
GO

ALTER TABLE DemoJson.OrderDocs_Json DROP COLUMN City1
GO
ALTER TABLE DemoJson.OrderDocs_Json DROP COLUMN CustomerID2
GO



-- porównanie rozmiaru tabel - varchar(max) vs json

-- data: 13 400 KB
EXEC sp_spaceused 'DemoJson.OrderDocs_Text'

-- data: 7 680 KB
EXEC sp_spaceused 'DemoJson.OrderDocs_Json'






/*
    
    1. JSON_VALUE i kolumna tekstowa City
    - json zapisany w typie danych nvarchar(4000)

*/


-- test przed indeksami
-- 5 000 rows
SELECT * FROM DemoJson.OrderDocs_Text


-- 5 rows
-- logical reads 1111
-- Clustered Index Scan
SELECT * FROM DemoJson.OrderDocs_Text
WHERE JSON_VALUE(OrderDoc, '$.Shipping.City') = 'Denver'
GO




-- dodanie computed column City1
ALTER TABLE DemoJson.OrderDocs_Text 
ADD City1 AS JSON_VALUE(OrderDoc, '$.Shipping.City')
GO

-- dodanie indeksu
CREATE INDEX IX_OrderDocs_Text_City1 
ON DemoJson.OrderDocs_Text (City1);
GO




-- test po dodaniu computed column i indeksu
-- 5 rows
-- logical reads 18
-- Index Seek (20%) + Key Lookup (80%)
SELECT * FROM DemoJson.OrderDocs_Text
WHERE City1 = 'Denver'
GO

-- magia computed columns i indeksów
-- mimo że w zapytaniu nie ma bezpośrednio City1, 
-- to i tak jest ono używane, bo optymalizator jest sprytny
SELECT * FROM DemoJson.OrderDocs_Text
WHERE JSON_VALUE(OrderDoc, '$.Shipping.City') = 'Denver'
GO






/*
    
    2. JSON_VALUE i kolumna tekstowa City
    - json zapisany w typie danych JSON (native JSON data type)

*/



-- test przed indeksami
SELECT * FROM DemoJson.OrderDocs_Json


-- 5 rows
-- logical reads 965
-- Clustered Index Scan
SELECT * FROM DemoJson.OrderDocs_Json
WHERE JSON_VALUE(OrderDoc, '$.Shipping.City') = 'Denver'
GO




-- dodanie computed column City1
ALTER TABLE DemoJson.OrderDocs_Json
ADD City1 AS JSON_VALUE(OrderDoc, '$.Shipping.City')
GO

-- dodanie indeksu
CREATE INDEX IX_OrderDocs_Json_City1 
ON DemoJson.OrderDocs_Json (City1);
GO




-- test po dodaniu computed column i indeksu
-- logical reads: 18
-- Index Seek (20%) + Key Lookup (80%)
SELECT * FROM DemoJson.OrderDocs_Json
WHERE City1 = 'Denver'
GO

-- magia computed columns i indeksów
-- mimo że w zapytaniu nie ma bezpośrednio City1, 
-- to i tak jest ono używane, bo optymalizator jest sprytny
SELECT * FROM DemoJson.OrderDocs_Json
WHERE JSON_VALUE(OrderDoc, '$.Shipping.City') = 'Denver'
GO





/*
    
    3. JSON_VALUE i kolumna CutomerID (int)
    - json zapisany w typie danych nvarchar(4000)

*/


-- test przed indeksami
SELECT * FROM DemoJson.OrderDocs_Text

-- read: 1111
-- Clustered Index Scan
SELECT * FROM DemoJson.OrderDocs_Text
WHERE JSON_VALUE(OrderDoc, '$.Customer.CustomerID') = 29842
GO





-- dodanie computed column CustomerID1
ALTER TABLE DemoJson.OrderDocs_Text 
ADD CustomerID1 AS JSON_VALUE(OrderDoc, '$.Customer.CustomerID')
GO

-- dodanie indeksu
CREATE INDEX IX_OrderDocs_Text_CustomerID1 
ON DemoJson.OrderDocs_Text (CustomerID1);
GO



-- ?
SELECT * FROM DemoJson.OrderDocs_Text
WHERE JSON_VALUE(OrderDoc, '$.Customer.CustomerID') = 29842
GO



/* QUIZ 1

    - Dlaczego nie użył indeksu?
    a/ bo to Preview
    b/ bo wymaga Enterprise Edition
    c/ bo JSON_VALUE zwraca nvarchar, a CustomerID w JSON jest int

*/


-- test2 po dodaniu indeksów 

-- rows: 4
-- reads: 14
-- Index Seek (32%) + Key Lookup (68%)
SELECT * FROM DemoJson.OrderDocs_Text
WHERE JSON_VALUE(OrderDoc, '$.Customer.CustomerID') = '29842'
GO




-- zadbajmy o typ danych tworząc computed column
ALTER TABLE DemoJson.OrderDocs_Text 
ADD CustomerID2 AS TRY_CONVERT(int, JSON_VALUE(OrderDoc, '$.Customer.CustomerID'))
GO
CREATE INDEX IX_OrderDocs_Text_CustomerID2 
ON DemoJson.OrderDocs_Text (CustomerID2);
GO


SELECT * FROM DemoJson.OrderDocs_Text



-- porównanie zwracanych typów danych
EXEC sp_describe_first_result_set @tsql = N'SELECT * FROM DemoJson.OrderDocs_Text';




-- rows: 4
-- reads: 14
-- Index Seek (30%) + Key Lookup (70%)
SELECT * FROM DemoJson.OrderDocs_Text WHERE CustomerID2 = 29842


-- uwaga! odczytując musimy teraz zadbać o typ danych w wyniku JSON_VALUE...
SELECT * FROM DemoJson.OrderDocs_Text
WHERE JSON_VALUE(OrderDoc, '$.Customer.CustomerID') = 29842
GO

-- na przykład tak:
SELECT * FROM DemoJson.OrderDocs_Text
WHERE TRY_CONVERT(int, JSON_VALUE(OrderDoc, '$.Customer.CustomerID')) = 29842
GO


-- ! RETURNING działa tylko z typem JSON
SELECT * FROM DemoJson.OrderDocs_Text
WHERE JSON_VALUE(OrderDoc, '$.Customer.CustomerID' RETURNING int) = 29842
GO









/*
    
    JSON_VALUE i kolumna CutomerID (int)
    - json zapisany w typie danych JSON (native JSON data type)
    - test RETURNING

*/




-- test przed indeksami
SELECT * FROM DemoJson.OrderDocs_Json

-- reads: 965
-- Clustered Index Scan
SELECT * FROM DemoJson.OrderDocs_Json
WHERE JSON_VALUE(OrderDoc, '$.Customer.CustomerID') = 29842
GO





-- dodanie computed column CustomerID1
ALTER TABLE DemoJson.OrderDocs_Json
ADD CustomerID1 AS TRY_CONVERT(int, JSON_VALUE(OrderDoc, '$.Customer.CustomerID'))
GO

-- dodanie indeksu
CREATE INDEX IX_OrderDocs_Json_CustomerID1
ON DemoJson.OrderDocs_Json (CustomerID1);
GO



-- to już wiemy, że nie zadziała
SELECT * FROM DemoJson.OrderDocs_Json
WHERE JSON_VALUE(OrderDoc, '$.Customer.CustomerID') = 29842
GO

-- zgodnie z oczekiwaniami
SELECT * FROM DemoJson.OrderDocs_Json
WHERE TRY_CONVERT(int, JSON_VALUE(OrderDoc, '$.Customer.CustomerID')) = 29842
GO

-- w SQL Server 2025 poza typem JSON dostajemy RETURNING - więc może?
SELECT * FROM DemoJson.OrderDocs_Json
WHERE JSON_VALUE(OrderDoc, '$.Customer.CustomerID' RETURNING int) = 29842
GO


/* QUIZ 2

    - Dlaczego nie użył indeksu?
    a/ bo w compted column ma zapisane inne wyrażenie (TRY_CONVERT), a nie RETURNING    
    b/ bo wymaga Enterprise Edition
    c/ bo to Preview

*/





-- dodanie computed column CustomerID2
ALTER TABLE DemoJson.OrderDocs_Json
ADD CustomerID2 AS JSON_VALUE(OrderDoc, '$.Customer.CustomerID' RETURNING int)
GO

-- dodanie indeksu
CREATE INDEX IX_OrderDocs_Json_CustomerID2
ON DemoJson.OrderDocs_Json (CustomerID2);
GO

-- w SQL Server 2025 poza typem JSON dostajemy RETURNING - więc może?
SELECT * FROM DemoJson.OrderDocs_Json
WHERE JSON_VALUE(OrderDoc, '$.Customer.CustomerID' RETURNING int) = 29842
GO




-- porównajmy przy okazji wydajność obu zapytań:
-- - tego z JSON_VALUE bez RETURNING i tego z TRY_CONVERT
-- nvarchar VS json

SELECT * FROM DemoJson.OrderDocs_Text
WHERE TRY_CONVERT(int, JSON_VALUE(OrderDoc, '$.Customer.CustomerID')) = 29842

SELECT * FROM DemoJson.OrderDocs_Json
WHERE TRY_CONVERT(int, JSON_VALUE(OrderDoc, '$.Customer.CustomerID')) = 29842


