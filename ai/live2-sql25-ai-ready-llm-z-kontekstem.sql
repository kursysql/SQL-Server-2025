/*

	LIVE SQL AI-READY SQL SERVER 2025
	Demo 2: Najprostszy pomysł: wrzućmy dane do prompta

	Tomasz Libera | MVP Data Platform
	libera@kursysql.pl
	
    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL

*/


USE SqlDayDemo;
GO

/*
    Najprostsze rozwiązanie:
    przekażmy modelowi nasze dane razem z pytaniem.

    Pobieramy tylko niewielki fragment katalogu sesji.
*/

SELECT TOP (10)
    SessionId,
    Title,
    SearchDocument
FROM dbo.vw_SessionSearchDocument
ORDER BY SessionId;
GO

DECLARE @context nvarchar(max);


/*
    Łączymy kilka dokumentów w jeden tekst.

    UWAGA:
    robimy to celowo w bardzo prosty sposób.
    Za chwilę zobaczymy, dlaczego takie podejście nie skaluje się.
*/
SELECT @context =
    STRING_AGG(
        CONVERT(nvarchar(max), SearchDocument),
        NCHAR(13) + NCHAR(10) +
        N'------------------------' +
        NCHAR(13) + NCHAR(10)
    )
FROM
(
    SELECT TOP (10)
        SearchDocument
    FROM dbo.vw_SessionSearchDocument
    ORDER BY SessionId
) AS s;


DECLARE @question nvarchar(max) =
N'Które z poniższych sesji są najbardziej interesujące
dla osoby zajmującej się wydajnością SQL Server?';


DECLARE @prompt nvarchar(max) =
CONCAT(
N'Odpowiedz wyłącznie na podstawie poniższego kontekstu.

KONTEKST:
',
@context,
N'

PYTANIE:
',
@question
);


/*
    Ten sam model LLM co wcześniej.

    Różnica jest jedna:
    tym razem przekazujemy mu NASZE dane.
*/
DECLARE @payload nvarchar(max) =
    JSON_OBJECT(
        'model': 'llama3.2',
        'prompt': @prompt,
        'stream': CAST(0 AS bit)
    );

DECLARE @response nvarchar(max);
DECLARE @answer nvarchar(max);
DECLARE @retval int;

EXEC @retval = sys.sp_invoke_external_rest_endpoint
    @url = N'https://localhost:11435/api/generate',
    @method = 'POST',
    @payload = @payload,
    @timeout = 190,
    @response = @response OUTPUT;


SELECT @answer = Answer
FROM OPENJSON(@response, '$.result')
WITH
(
    Answer nvarchar(max) '$.response'
);

SELECT @answer AS OdpowiedzLLM;
GO


-- to może po prostu wrzucimy do prompta wszystkie dane? ...[szydera OFF]


SELECT
    COUNT(*) AS LiczbaDokumentow,
    SUM(LEN(SearchDocument)) AS LiczbaZnakow
FROM dbo.vw_SessionSearchDocument;