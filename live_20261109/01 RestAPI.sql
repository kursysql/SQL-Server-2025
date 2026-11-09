/*

	LIVE: SQL Server 2025 : AI-ready i najciekawsze nowości
	Demo 1: Rest API

	Tomasz Libera | MVP Data Platform
	libera@kursysql.pl
	
    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL

*/





-- ============================================================================
-- 1. REST API -> JSON: PROGNOZA DLA KRAKOWA
-- ============================================================================
DECLARE @Day date = DATEADD(DAY, 1, CAST(GETDATE() AS date))
DECLARE @DayText char(10) = CONVERT(char(10), @Day, 23)

SELECT @DayText AS Jutro

DECLARE @url nvarchar(max) =
    N'https://api.open-meteo.com/v1/forecast'
    + N'?latitude=50.0647&longitude=19.9450'
    + N'&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max'
    + N'&timezone=Europe%2FWarsaw'
    + N'&start_date=' + @DayText
    + N'&end_date=' + @DayText;
DECLARE @response nvarchar(max);



EXEC sys.sp_invoke_external_rest_endpoint
     @url = @url,
     @method = N'GET',
     @response = @response OUTPUT;

-- Surowa odpowiedz 
SELECT @response AS RestResponse;

-- JSON -> dane relacyjne
SELECT
    N'Kraków' AS City,
    TRY_CONVERT(date, JSON_VALUE(@response, '$.result.daily.time[0]')) AS ForecastDate,
    TRY_CONVERT(decimal(5,2), JSON_VALUE(@response, '$.result.daily.temperature_2m_min[0]')) AS MinC,
    TRY_CONVERT(decimal(5,2), JSON_VALUE(@response, '$.result.daily.temperature_2m_max[0]')) AS MaxC,
    TRY_CONVERT(int, JSON_VALUE(@response, '$.result.daily.precipitation_probability_max[0]')) AS RainPercent;
GO

-- uprawienia
SELECT
    USER_NAME() AS DatabaseUser,
    HAS_PERMS_BY_NAME(DB_NAME(), 'DATABASE', 'EXECUTE ANY EXTERNAL ENDPOINT')
        AS CanCallExternalEndpoint;
GO


-- CREATE ROLE RestApiUsers;
-- GRANT EXECUTE ANY EXTERNAL ENDPOINT TO RestApiUsers;
-- ALTER ROLE RestApiUsers ADD MEMBER [DemoUser];

