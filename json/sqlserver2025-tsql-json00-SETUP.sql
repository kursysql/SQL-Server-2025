/*

	TSQL: JSON Demo setup
	Tomasz Lbera | MVP Data Platform
	libera@kursysql.pl
	
    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL


*/


USE AdventureWorks2025
GO

/* 0. Cleanup */
DROP TABLE IF EXISTS DemoJson.OrderDocs_Json_Indexed
DROP TABLE IF EXISTS DemoJson.OrderDocs_Json
DROP TABLE IF EXISTS DemoJson.OrderDocs_Text

IF EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'DemoJson')
BEGIN
    DROP SCHEMA DemoJson;
END
GO





CREATE SCHEMA DemoJson
GO

/* 1. Tabele */
CREATE TABLE DemoJson.OrderDocs_Text
(
    OrderID int NOT NULL CONSTRAINT PK_OrderDocs_Text PRIMARY KEY,
    OrderDoc nvarchar(max) NOT NULL
);
GO

CREATE TABLE DemoJson.OrderDocs_Json
(
    OrderID int NOT NULL CONSTRAINT PK_OrderDocs_Json PRIMARY KEY,
    OrderDoc json NOT NULL
);
GO


CREATE TABLE DemoJson.OrderDocs_Json_Indexed
(
    OrderID int NOT NULL CONSTRAINT PK_OrderDocs_Json_Indexed PRIMARY KEY,
    OrderDoc json NOT NULL
);
GO




/* 2. Jeden dokument dla zamówienie (z wieloma pozycjami (Items) */
WITH OrderSource AS
(
    SELECT TOP (5000)
        h.SalesOrderID,
        h.OrderDate,
        h.Status,
        h.OnlineOrderFlag,
        h.SalesPersonID,
        h.CustomerID,
        c.AccountNumber,
        h.ShipMethodID,
        a.City,
        a.PostalCode,
        sp.CountryRegionCode,
        h.SubTotal,
        h.TaxAmt,
        h.Freight,
        h.TotalDue
    FROM Sales.SalesOrderHeader AS h
    INNER JOIN Sales.Customer AS c
        ON c.CustomerID = h.CustomerID
    LEFT JOIN Person.Address AS a
        ON a.AddressID = h.ShipToAddressID
    LEFT JOIN Person.StateProvince AS sp
        ON sp.StateProvinceID = a.StateProvinceID
    ORDER BY h.SalesOrderID
)
INSERT INTO DemoJson.OrderDocs_Text (OrderID, OrderDoc)
SELECT
    s.SalesOrderID,
    (
        SELECT
            s.SalesOrderID AS OrderID,
            s.OrderDate,
            s.Status,
            s.OnlineOrderFlag AS OnlineOrder,
            s.SalesPersonID,

            JSON_QUERY(
                (
                    SELECT
                        s.CustomerID,
                        s.AccountNumber,
                        CASE
                            WHEN s.AccountNumber LIKE 'AW%' THEN 'Store'
                            ELSE 'Unknown'
                        END AS CustomerType
                    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                )
            ) AS Customer,

            JSON_QUERY(
                (
                    SELECT
                        s.ShipMethodID,
                        s.City,
                        s.PostalCode,
                        s.CountryRegionCode
                    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                )
            ) AS Shipping,

            JSON_QUERY(
                (
                    SELECT
                        s.SubTotal,
                        s.TaxAmt,
                        s.Freight,
                        s.TotalDue
                    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                )
            ) AS Totals,

            JSON_QUERY(
                (
                    SELECT
                        d.SalesOrderDetailID,
                        d.ProductID,
                        p.ProductNumber,
                        p.Name,
                        d.OrderQty,
                        d.UnitPrice,
                        d.LineTotal
                    FROM Sales.SalesOrderDetail AS d
                    INNER JOIN Production.Product AS p
                        ON p.ProductID = d.ProductID
                    WHERE d.SalesOrderID = s.SalesOrderID
                    FOR JSON PATH
                )
            ) AS Items,

            JSON_QUERY(
                CASE
                    WHEN s.OnlineOrderFlag = 1 AND s.TotalDue >= 10000
                        THEN '["online","high-value","priority"]'
                    WHEN s.OnlineOrderFlag = 1
                        THEN '["online","standard"]'
                    WHEN s.CountryRegionCode = 'US'
                        THEN '["offline","domestic"]'
                    ELSE '["offline","export"]'
                END
            ) AS Tags

        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) AS OrderDoc
FROM OrderSource AS s;
GO





/* 3. Załaduj te same dane do tabeli z JSON i JSON z indeksem */
INSERT INTO DemoJson.OrderDocs_Json (OrderID, OrderDoc)
SELECT
    OrderID,
    CAST(OrderDoc AS json)
FROM DemoJson.OrderDocs_Text;
GO


INSERT INTO DemoJson.OrderDocs_Json_Indexed (OrderID, OrderDoc)
SELECT
    OrderID,
    CAST(OrderDoc AS json)
FROM DemoJson.OrderDocs_Text;
GO



SELECT TOP 1 * FROM DemoJson.OrderDocs_Text
