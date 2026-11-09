/*

	LIVE: SQL Server 2025 : AI-ready i najciekawsze nowości
	Demo 2: JSON

	Tomasz Libera | MVP Data Platform
	libera@kursysql.pl
	
    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL

*/



USE SQLDayDemo;
GO


SELECT TOP (20)
    d.DocId,
    d.SourceSessionId,
    d.SessionDoc,
    JSON_VALUE(d.SessionDoc, '$.title') AS SessionTitle,
    JSON_QUERY(d.SessionDoc, '$.tags') AS Tags    
FROM dbo.SessionDocs_Json AS d
WHERE d.CopyNo = 1
ORDER BY d.SourceSessionId;
GO


-- SQL Server 2025: natywny JSON i prostszy predykat JSON_CONTAINS
-- Znajdz unikalne sesje oznaczone tagiem SQL2025.
-- Tablica tags -> wymagany wildcard [*].
SELECT
    d.SourceSessionId AS SessionId,
    d.SessionDoc,
    JSON_VALUE(d.SessionDoc, '$.title') AS SessionTitle
FROM dbo.SessionDocs_Json AS d
WHERE d.CopyNo = 1
  AND JSON_CONTAINS(d.SessionDoc, N'SQL2025', '$.tags[*]') = 1
ORDER BY d.SourceSessionId;
GO

