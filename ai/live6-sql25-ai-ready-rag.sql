/*

	LIVE SQL AI-READY SQL SERVER 2025
	Demo 6 RAG

	Tomasz Libera | MVP Data Platform
	libera@kursysql.pl
	
    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL

*/






USE SqlDayDemo;
GO

/*
    Łączymy wszystko w jeden proces RAG.

    1. pytanie użytkownika
    2. embedding pytania
    3. semantic / vector search
    4. pobranie najbardziej trafnych danych
    5. zbudowanie kontekstu
    6. przekazanie pytania + kontekstu do LLM
    7. wygenerowanie odpowiedzi


    Implementacja procesu została przygotowana wcześniej.
    Teraz interesuje nas efekt końcowy.
*/


EXEC dbo.usp_AskSqlDay
    @Question =
    N'W których sesjach SQLDay powinienem wziąć udział,
      jeśli chcę nauczyć się o tuningu wydajności SQL Server?
      Podaj tytuły sesji i wyjaśnij dlaczego.';
GO




/*
    Co musieliśmy przygotować, żeby zadziałało?
*/


-- 1. Lokalny model LLM
--    Ollama + llama3.2


-- 2. Model embeddingowy
--    Ollama + all-minilm / bge-m3


-- 3. Połączenie SQL Server z modelem
--
--    CREATE EXTERNAL MODEL ...


-- 4. Reprezentacja wektorowa danych
--
--    VECTOR(...)
--    AI_GENERATE_EMBEDDINGS(...)


-- 5. Przygotowanie dokumentu do wyszukiwania
--
--    Title
--    Description
--    Track
--    Level
--    Language
--    Speakers
--    Tags


-- 6. Materializacja i aktualizacja embeddingów


-- 7. Wyszukiwanie
--
--    VECTOR_DISTANCE(...)
--    CREATE VECTOR INDEX ...
--    VECTOR_SEARCH(...)


-- 8. RAG
--
--    pytanie
--       ↓
--    embedding
--       ↓
--    vector search
--       ↓
--    kontekst
--       ↓
--    prompt
--       ↓
--    LLM
--       ↓
--    odpowiedź