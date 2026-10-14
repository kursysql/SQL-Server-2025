/*

	LIVE SQL AI-READY SQL SERVER 2025
	Demo 5: VECTOR i semantic search

	Tomasz Libera | MVP Data Platform
	libera@kursysql.pl
	
    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL

*/



USE SqlDayDemo;
GO


SELECT * FROM dbo.vw_SessionSearchDocument


/*
    Klasyczne wyszukiwanie tekstowe.   

*/

SELECT *
FROM dbo.vw_SessionSearchDocument
WHERE Title LIKE N'%performance tuning%';
GO


SELECT *
FROM dbo.vw_SessionSearchDocument
WHERE SearchDocument LIKE N'%performance tuning%';
GO


SELECT SessionId, Title
FROM dbo.vw_SessionSearchDocument
WHERE SearchDocument LIKE N'%why my query is slow%';
GO


/*
    Teraz nie szukamy słów.

    Zamieniamy całe pytanie użytkownika na embedding
    i porównujemy je z embeddingami dokumentów.
*/

DECLARE @question nvarchar(max) = N'SQL Server performance tuning';
DECLARE @query_embedding vector(384) = AI_GENERATE_EMBEDDINGS(@question USE MODEL ollama_all_minilm);
SELECT @question, @query_embedding

SELECT TOP (10)
    s.SessionId,
    s.Title,
    VECTOR_DISTANCE('cosine', e.Embedding, @query_embedding) AS Distance
FROM dbo.SessionEmbedding AS e
JOIN dbo.SessionDetails AS s
    ON s.SessionId = e.SessionId
WHERE e.EmbeddingSource = 'SEARCH_DOCUMENT'
ORDER BY Distance;
GO


DECLARE @question nvarchar(max) = N'why my query is slow';
DECLARE @query_embedding vector(384) = AI_GENERATE_EMBEDDINGS(@question USE MODEL ollama_all_minilm);
SELECT @question, @query_embedding

SELECT TOP (10)
    s.SessionId,
    s.Title,
    VECTOR_DISTANCE('cosine', e.Embedding, @query_embedding) AS Distance
FROM dbo.SessionEmbedding AS e
JOIN dbo.SessionDetails AS s
    ON s.SessionId = e.SessionId
WHERE e.EmbeddingSource = 'SEARCH_DOCUMENT'
ORDER BY Distance;
GO



/*
    Ten sam problem możemy rozwiązać przy użyciu
    indeksu wektorowego i VECTOR_SEARCH.

*/

DECLARE @question nvarchar(max) = N'why my query is slow';
DECLARE @query_embedding vector(384) = AI_GENERATE_EMBEDDINGS(@question USE MODEL ollama_all_minilm);
SELECT @question, @query_embedding

SELECT 
    s.SessionId,
    s.Title,
    r.distance
FROM VECTOR_SEARCH
(
    TABLE = dbo.SessionSearchVector AS e,
    COLUMN = Embedding,
    SIMILAR_TO = @query_embedding,
    METRIC = 'cosine',
    TOP_N = 10
) AS r
JOIN dbo.SessionDetails AS s
    ON s.SessionId = e.SessionId
ORDER BY r.distance;