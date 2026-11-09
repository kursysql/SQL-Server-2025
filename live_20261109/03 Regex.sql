/*

	LIVE: SQL Server 2025 : AI-ready i najciekawsze nowości
	Demo 3: REGEX

	Tomasz Libera | MVP Data Platform
	libera@kursysql.pl
	
    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL

*/


DECLARE @Adresy nvarchar(300) =
    N'Kontakt: Jan Kowalski, e-mail: jan.kowalski@firma.pl, kod: 30-020';

SELECT
    @Adresy AS RawText,
    REGEXP_SUBSTR(@Adresy, N'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}') AS Email,
    REGEXP_SUBSTR(@Adresy, N'[0-9]{2}-[0-9]{3}') AS PostalCode,
    REGEXP_REPLACE(@Adresy, N'[0-9]{2}-[0-9]{3}', N'[KOD USUNIETY]') AS AnonymizedText;
GO


DROP TABLE IF EXISTS #Contacts;

CREATE TABLE #Contacts (Email nvarchar(100));
INSERT INTO #Contacts VALUES
(N'jan@firma.pl'), (N'anna.nowak@example.com'), (N'niepoprawny-adres'), (N'brak@kropki');

SELECT Email
FROM #Contacts
WHERE REGEXP_LIKE(Email, N'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
GO

SELECT Email
FROM #Contacts
WHERE NOT REGEXP_LIKE(Email, N'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
GO

SELECT Email, 
       CASE 
           WHEN REGEXP_LIKE(Email, N'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN 'Valid'
           ELSE 'Invalid'
       END AS EmailStatus
FROM #Contacts
WHERE REGEXP_LIKE(Email, N'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
GO
