/*

	LIVE: SQL Server 2025 : AI-ready i najciekawsze nowości
	Demo 5: AI

	Tomasz Libera | MVP Data Platform
	libera@kursysql.pl
	
    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL

*/



DECLARE @Question nvarchar(400) = N'How to speed up slow SQL queries?';

SELECT TOP (8)
    s.SessionId, s.Title
FROM dbo.SessionDetails AS s
WHERE s.Title LIKE N'%speed%'
   OR s.Title LIKE N'%performance%'
   OR s.Title LIKE N'%query%'
ORDER BY s.Title;
GO

DECLARE @Question nvarchar(400) = N'How to speed up slow SQL queries?';
DECLARE @QueryEmbedding vector(384) =
    AI_GENERATE_EMBEDDINGS(@Question USE MODEL ollama_all_minilm);

SELECT TOP (8)
    s.SessionId,
    s.Title,
    VECTOR_DISTANCE('cosine', @QueryEmbedding, sv.Embedding) AS CosineDistance
FROM dbo.SessionSearchVector AS sv
JOIN dbo.SessionDetails AS s ON s.SessionId = sv.SessionId
WHERE sv.Embedding IS NOT NULL
ORDER BY CosineDistance ASC;
GO


