/*

	LIVE: SQL Server 2025 : AI-ready i najciekawsze nowości
	Demo 0: Setup środowiska demonstracyjnego

	Tomasz Libera | MVP Data Platform
	libera@kursysql.pl
	
    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL

*/


USE SQLDayDemo;
GO




SELECT
    @@VERSION AS SqlServerVersion,
    DB_NAME() AS DemoDatabase,
    d.compatibility_level,
    OBJECT_ID(N'dbo.SessionJson') AS SessionJsonObject,
    OBJECT_ID(N'dbo.SessionDetails') AS SessionDetailsObject,
    OBJECT_ID(N'dbo.SessionSearchVector') AS SessionSearchVectorObject
FROM sys.databases AS d
-- WHERE d.name = DB_NAME();
GO

SELECT name, value, value_for_secondary
FROM sys.database_scoped_configurations
WHERE name = N'PREVIEW_FEATURES';
GO


-- ALTER DATABASE SQLDayDemo SET COMPATIBILITY_LEVEL = 170;
-- ALTER DATABASE SCOPED CONFIGURATION SET PREVIEW_FEATURES = ON;

EXEC sp_configure 'external rest endpoint enabled', 1;
RECONFIGURE WITH OVERRIDE;

