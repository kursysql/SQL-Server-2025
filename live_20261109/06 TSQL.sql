/*

	LIVE: SQL Server 2025 : AI-ready i najciekawsze nowości
	Demo 5: AI

	Tomasz Libera | MVP Data Platform
	libera@kursysql.pl
	
    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL

*/




-- Nowy operator konkatenacji ANSI: ||
SELECT
    N'SQL Server ' || N'2025' AS NewOperator,
    N'SQL Server ' + N'2025' AS OldOperator,
    N'SQL Server ' || CAST(NULL AS nvarchar(10)) AS NullBehavior,
    CONCAT(N'SQL Server ', CAST(NULL AS nvarchar(10))) AS ConcatNullBehavior;
GO

-- CURRENT_DATE - data bez godziny, bez nawiasow
SELECT
    CURRENT_DATE AS TodayDate,
    CAST(GETDATE() AS date) AS PreviousApproach;
GO

-- UNISTR - zapis Unicode kodem znaku; tu rakieta :)
SELECT
    UNISTR(N'Start SQL Server 2025 \+01F680') AS UnicodeMessage;
GO

-- BASE64_ENCODE / BASE64_DECODE - przyklad dla tekstowego payloadu
DECLARE @Payload varchar(50) = 'SQL Server 2025';
DECLARE @Encoded varchar(max) = BASE64_ENCODE(CONVERT(varbinary(max), @Payload));
SELECT
    @Payload AS OriginalText,
    @Encoded AS EncodedValue,
    CONVERT(varchar(50), BASE64_DECODE(@Encoded)) AS DecodedText;
GO

-- ZMIANA: SUBSTRING - dlugosc jest teraz opcjonalna
SELECT
    SUBSTRING(N'SQL Server 2025', 5) AS FromPosition5,
    SUBSTRING(N'SQL Server 2025', 5, 20) AS EarlierSyntax;
GO

-- ZMIANA: DATEADD - argument number moze byc BIGINT.
SELECT
    DATEADD(microsecond, CAST(2147483648 AS bigint),
            CAST('2026-11-09T00:00:00' AS datetime2(7))) AS BigIntOffset;
GO
