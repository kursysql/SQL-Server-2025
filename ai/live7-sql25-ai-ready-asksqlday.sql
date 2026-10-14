USE SqlDayDemo;
GO

/*
    AI-ready SQL Server 2025 - LIVE
    --------------------------------
    dbo.AskSQLDay

    Cel:
      Połączyć w jeden proces wszystkie elementy pokazywane podczas LIVE:

        pytanie użytkownika
              ↓
        embedding pytania
              ↓
        wyszukiwanie semantyczne w SQL Server
              ↓
        TOP N najbardziej trafnych sesji
              ↓
        kontekst dla LLM
              ↓
        odpowiedź modelu llama3.2

    Założenia:
      - baza: SqlDayDemo
      - dbo.SessionDetails
      - dbo.SessionEmbedding
            SessionId
            EmbeddingSource
            Embedding VECTOR(384)
      - dbo.vw_SessionSearchDocument
            SessionId
            Title
            SearchDocument
      - model embeddingowy zarejestrowany w SQL Server:
            ollama_all_minilm
      - lokalna Ollama:
            https://localhost:11435
      - model LLM:
            llama3.2

    Uwaga:
      To jest pełna implementacja używana przez skrypt LIVE nr 6.
      Podczas LIVE nie analizujemy jej linia po linii - interesuje nas
      przede wszystkim przepływ RAG i efekt końcowy.
*/

CREATE OR ALTER PROCEDURE dbo.usp_AskSQLDay
    @Question nvarchar(max),
    @TopN     int = 5,
    @Timeout  int = 230
AS
BEGIN
    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@Question)), N'') IS NULL
        THROW 50001, N'Parametr @Question nie może być pusty.', 1;

    IF @TopN < 1
        THROW 50002, N'Parametr @TopN musi być większy od 0.', 1;

    /* ------------------------------------------------------------
       1. Zamiana pytania użytkownika na embedding
       ------------------------------------------------------------ */

    DECLARE @QueryEmbedding vector(384) = AI_GENERATE_EMBEDDINGS(@Question USE MODEL ollama_all_minilm);


    /* ------------------------------------------------------------
       2. Wyszukanie najbardziej podobnych znaczeniowo sesji

       VECTOR_DISTANCE wykonuje dokładne porównanie wektorów.
       Dla małego katalogu sesji jest to wystarczające i czytelne
       podczas demonstracji.
       ------------------------------------------------------------ */

    CREATE TABLE #Matches
    (
        Position       int            NOT NULL,
        SessionId      int            NOT NULL,
        Title          nvarchar(500)  NULL,
        SearchDocument nvarchar(max)  NULL,
        Distance       float          NULL
    );

    ;WITH Ranked AS
    (
        SELECT TOP (@TopN)
            e.SessionId,
            d.Title,
            d.SearchDocument,
            VECTOR_DISTANCE('cosine', e.Embedding, @QueryEmbedding) AS Distance
        FROM dbo.SessionEmbedding AS e
        INNER JOIN dbo.vw_SessionSearchDocument AS d
            ON d.SessionId = e.SessionId
        WHERE e.EmbeddingSource = 'SEARCH_DOCUMENT'
        ORDER BY Distance
    )
    INSERT INTO #Matches
    (
        Position,
        SessionId,
        Title,
        SearchDocument,
        Distance
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY Distance),
        SessionId,
        Title,
        SearchDocument,
        Distance
    FROM Ranked;


    /* ------------------------------------------------------------
       RESULT SET 1

       Najpierw pokazujemy, co znalazł sam SQL Server.
       Na tym etapie LLM jeszcze niczego nie wygenerował.
       ------------------------------------------------------------ */

    SELECT
        Position,
        SessionId,
        Title,
        CAST(Distance AS decimal(10, 6)) AS Distance
    FROM #Matches
    ORDER BY Position;


    /* ------------------------------------------------------------
       3. Budowa kontekstu dla modelu LLM

       Do prompta NIE trafia cała baza.
       Trafiają tylko dokumenty znalezione w poprzednim kroku.
       ------------------------------------------------------------ */

    DECLARE @Context nvarchar(max);

    SELECT @Context =
        STRING_AGG(
            CONVERT(
                nvarchar(max),
                CONCAT(
                    N'SessionId: ', SessionId, NCHAR(13) + NCHAR(10),
                    N'Tytuł: ', Title, NCHAR(13) + NCHAR(10),
                    N'Dane sesji:', NCHAR(13) + NCHAR(10),
                    SearchDocument
                )
            ),
            NCHAR(13) + NCHAR(10) +
            N'--------------------------------------------------' +
            NCHAR(13) + NCHAR(10)
        ) WITHIN GROUP (ORDER BY Position)
    FROM #Matches;


    /* ------------------------------------------------------------
       4. Prompt = instrukcja + znaleziony kontekst + pytanie
       ------------------------------------------------------------ */

    DECLARE @Prompt nvarchar(max) = CONCAT(
N'Jesteś asystentem pomagającym wybrać sesje konferencji SQLDay.

Odpowiadaj WYŁĄCZNIE na podstawie danych znajdujących się w sekcji KONTEKST.
Nie wymyślaj sesji, tytułów, prelegentów ani informacji, których nie ma w kontekście.
Jeżeli kontekst nie wystarcza do udzielenia odpowiedzi, napisz to wprost.

W odpowiedzi:
- podaj najbardziej trafne sesje,
- używaj dokładnych tytułów z kontekstu,
- krótko wyjaśnij, dlaczego każda sesja pasuje do pytania.

KONTEKST:
',
        @Context,
N'

PYTANIE UŻYTKOWNIKA:
',
        @Question
    );


    /* ------------------------------------------------------------
       5. Wywołanie lokalnego LLM w Ollama
       ------------------------------------------------------------ */

    DECLARE @Payload  nvarchar(max);
    DECLARE @Response nvarchar(max);
    DECLARE @Answer   nvarchar(max);
    DECLARE @Retval   int;

    SET @Payload = JSON_OBJECT(
        'model':  'llama3.2',
        'prompt': @Prompt,
        'stream': CAST(0 AS bit)
    );

    BEGIN TRY

        EXEC @Retval = sys.sp_invoke_external_rest_endpoint
            @url = N'https://localhost:11435/api/generate',
            @method = 'POST',
            @payload = @Payload,
            @timeout = @Timeout,
            @response = @Response OUTPUT;

        /*
            0      = otrzymaliśmy odpowiedź HTTP 2xx
            <> 0   = endpoint odpowiedział kodem błędu HTTP

            Brak możliwości wykonania połączenia, np. timeout klienta,
            powoduje wyjątek i trafia do sekcji CATCH.
        */
        IF @Retval <> 0
        BEGIN
            DECLARE @HttpError nvarchar(2048) = CONCAT(
                N'Błąd wywołania Ollama. Kod HTTP: ',
                @Retval,
                N'. Odpowiedź: ',
                LEFT(COALESCE(@Response, N'<brak>'), 1200)
            );

            THROW 50003, @HttpError, 1;
        END;

        SELECT @Answer = Answer
        FROM OPENJSON(@Response, '$.result')
        WITH
        (
            Answer nvarchar(max) '$.response'
        );

        /* --------------------------------------------------------
           RESULT SET 2

           Odpowiedź wygenerowana przez LLM na podstawie
           kontekstu wyszukanego wcześniej w SQL Server.
           -------------------------------------------------------- */

        SELECT
            @Question AS Question,
            @Answer   AS Answer;

    END TRY
    BEGIN CATCH

        DECLARE @ErrorMessage nvarchar(2048) = ERROR_MESSAGE();

        IF @ErrorMessage LIKE N'%timeout%'
           OR @ErrorMessage LIKE N'%timed out%'
        BEGIN
            SET @ErrorMessage = CONCAT(
                N'Timeout - model nie odpowiedział w wymaganym czasie. ',
                N'Aktualny @Timeout = ', @Timeout, N' s. ',
                N'Szczegóły: ', ERROR_MESSAGE()
            );
        END;

        THROW 50004, @ErrorMessage, 1;

    END CATCH;
END;
GO


/* ================================================================
   Przykład użycia
   ================================================================ */

--EXEC dbo.AskSQLDay
--    @Question = N'W których sesjach SQLDay powinienem wziąć udział,
--jeśli chcę nauczyć się o tuningu wydajności SQL Server?
--Podaj tytuły sesji i wyjaśnij dlaczego.',
--    @TopN = 5,
--    @Timeout = 230;
--GO
