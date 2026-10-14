/*

	LIVE SQL AI-READY SQL SERVER 2025
	Demo 1: AI ma wiedzę, ale nie zna moich danych

	Tomasz Libera | MVP Data Platform
	libera@kursysql.pl
	
    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL

*/

USE SqlDayDemo;
GO


/*
    DEMO 1
    AI ma wiedzę, ale nie zna moich danych
    --------------------------------------

    Korzystamy z lokalnego modelu LLM uruchomionego w Ollama.

    Model potrafi odpowiadać na pytania na podstawie swojej wiedzy,
    ale NIE MA automatycznego dostępu do danych znajdujących się
    w naszej bazie SQL Server.

    Spróbujmy zapytać go o sesje SQLDay.
*/

DECLARE @question nvarchar(max) =
N'W których sesjach SQLDay powinienem wziąć udział,
jeśli chcę nauczyć się o tuningu wydajności SQL Server?

Podaj konkretne tytuły sesji i wyjaśnij dlaczego.';


DECLARE @payload nvarchar(max);
DECLARE @response nvarchar(max);
DECLARE @answer nvarchar(max);
DECLARE @retval int;


/*
    Tworzymy żądanie dla lokalnego modelu llama3.2.

    stream = false oznacza, że chcemy otrzymać całą odpowiedź
    w jednym wyniku.
*/
SET @payload =
    JSON_OBJECT(
        'model': 'llama3.2',
        'prompt': @question,
        'stream': CAST(0 AS bit)
    );


SELECT @payload AS Payload

/*
    SQL Server 2025 może wywoływać zewnętrzne endpointy REST.

    W naszym przykładzie jest to lokalna Ollama.
*/
EXEC sp_invoke_external_rest_endpoint
    @url = N'https://localhost:11435/api/generate',
    @method = 'POST',
    @payload = @payload,
    @response = @response OUTPUT;


--EXEC sp_invoke_external_rest_endpoint
--    @url = N'https://localhost:11435/api/generate',
--    @method = 'POST',
--    @payload = @payload,
--    @timeout = 120,
--    @response = @response OUTPUT;



SELECT @answer AS AnswerRaw

/*
    Pobieramy właściwą odpowiedź modelu z odpowiedzi JSON.
*/
SELECT @answer = Answer
FROM OPENJSON(@response, '$.result')
WITH
(
    Answer nvarchar(max) '$.response'
);


SELECT @answer AS OdpowiedzLLM;
GO