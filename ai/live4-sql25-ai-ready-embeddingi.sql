/*

	LIVE SQL AI-READY SQL SERVER 2025
	Demo 4: Embedding

	Tomasz Libera | MVP Data Platform
	libera@kursysql.pl
	
    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL

*/


USE SqlDayDemo;
GO

/*
    DEMO 3
    Co robi model embeddingowy?

    Model embeddingowy nie generuje odpowiedzi.
    Zamienia tekst na jego reprezentację liczbową - wektor.

    Teksty podobne znaczeniowo powinny mieć podobne wektory.
*/

DECLARE @text1 nvarchar(max) = N'riding a mountain bike on forest trails';
DECLARE @text2 nvarchar(max) = N'cycling off-road through woods and hills';
DECLARE @text3 nvarchar(max) = N'preparing pasta with tomato sauce';

DECLARE @v1 vector(384) = AI_GENERATE_EMBEDDINGS(@text1 USE MODEL ollama_all_minilm);
DECLARE @v2 vector(384) = AI_GENERATE_EMBEDDINGS(@text2 USE MODEL ollama_all_minilm);
DECLARE @v3 vector(384) = AI_GENERATE_EMBEDDINGS(@text3 USE MODEL ollama_all_minilm);

-- !!!!
-- Msg 5335, Level 16, State 1, Line 37
-- The data type vector cannot be used as an operand to the UNION, [...]is not comparable.
--SELECT @v1 AS _v1, @text1
--UNION 
--SELECT @v2 AS _v2, @text2
--UNION 
--SELECT @v3 AS _v3, @text3


/*
    Dla modelu wektor jest matematyczną reprezentacją znaczenia tekstu.
*/

SELECT @v1 AS _v1, @text1
UNION ALL
SELECT @v2 AS _v2, @text2
UNION ALL
SELECT @v3 AS _v3, @text3





/*
    Porównajmy odległość pomiędzy wektorami.

    Im MNIEJSZA wartość cosine distance,
    tym większe podobieństwo znaczeniowe.
*/
SELECT
    VECTOR_DISTANCE('cosine', @v1, @v2) AS PodobneZnaczenie,
    VECTOR_DISTANCE('cosine', @v1, @v3) AS InneZnaczenie;
GO