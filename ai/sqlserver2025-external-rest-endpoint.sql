/*
	TSQL: sys.sp_invoke_external_rest_endpoint 
	Tomasz Libera | MVP Data Platform
	libera@kursysql.pl
	
    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL

    Funkcja sys.sp_invoke_external_rest_endpoint 
    umożliwia wywoływanie zewnętrznych punktów końcowych REST z poziomu T-SQL


    Składnia*:
    sys.sp_invoke_external_rest_endpoint @url NVARCHAR(MAX), @method NVARCHAR(10), @headers NVARCHAR(MAX), @body NVARCHAR(MAX)

    Dokumentacja:
    https://learn.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-invoke-external-rest-endpoint-transact-sql

    

*/



-- Wymaga włączenia w konfiguracji
SELECT * FROM sys.configurations WHERE name = 'external rest endpoint enabled';


EXEC sp_configure 'external rest endpoint enabled', 1;

RECONFIGURE WITH OVERRIDE;
GO

USE AdventureWorks2025
GO


-- W bazie danych musi istnieć Database Master Key


IF NOT EXISTS (
    SELECT 1 FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##'
    )

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Pa$$w0rd2025!';
GO



-- API key zapiszemy w db scoped credential, aby nie przechowywać go w jawnej postaci w kodzie T-SQL


DROP DATABASE SCOPED CREDENTIAL [https://api.openai.com]
GO

CREATE DATABASE SCOPED CREDENTIAL [https://api.openai.com]
WITH IDENTITY = 'HTTPEndpointHeaders',
SECRET = '{"Authorization":"Bearer XXXXXXXX"}';
GO



DECLARE @response NVARCHAR(MAX);

EXECUTE sys.sp_invoke_external_rest_endpoint 
    @url = N'https://api.openai.com/v1/chat/completions', 
    @method = 'POST', 
    @headers = '{"Content-Type":"application/json"}', 
    @payload = N'{
        "model": "gpt-4o-mini", 
        "messages": [{"role": "user", "content": "What is the capital of France? Answer in one word."}],
        "max_tokens": 50}', 
    @credential = [https://api.openai.com], 
    @response = @response OUTPUT;

SELECT @response AS OpenAI_Response;


SELECT JSON_VALUE(@response, '$.result.choices[0].message.content') AS LLM_Response;

