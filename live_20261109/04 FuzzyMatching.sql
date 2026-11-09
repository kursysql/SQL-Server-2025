/*

	LIVE: SQL Server 2025 : AI-ready i najciekawsze nowości
	Demo 4: FUZZY MATCHING

	Tomasz Libera | MVP Data Platform
	libera@kursysql.pl
	
    http://www.kursysql.pl
    http://www.youtube.com/c/KursySQL

*/



-- ============================================================================
-- 4. FUZZY MATCHING: MIASTA Z IMPORTU
-- ============================================================================

DROP TABLE IF EXISTS #Incoming;
DROP TABLE IF EXISTS #Cities;

CREATE TABLE #Incoming (InputCity nvarchar(100));
CREATE TABLE #Cities (City nvarchar(100));
INSERT INTO #Incoming VALUES
(N'Karków'), (N'Warzsawa'), (N'Gdnask'), (N'Worclaw'), (N'Poznań');
INSERT INTO #Cities VALUES
(N'Kraków'), (N'Warszawa'), (N'Gdańsk'), (N'Wrocław'), (N'Poznań'), (N'Katowice');

SELECT * FROM #Incoming;
SELECT * FROM #Cities



-- EDIT_DISTANCE: im mniejsza wartość, tym bardziej podobne napisy, 0 = identyczne
-- *_SIMILARITY: 0 = brak podobieństwa/ 100 = identyczne napisy
-- Jaro-Winkler szczególnie premiuje zgodność początku napisu.
SELECT
    inp.InputCity,
    c.City AS City,
    EDIT_DISTANCE(inp.InputCity, c.City) AS Edit_Distance_Score,
    EDIT_DISTANCE_SIMILARITY(inp.InputCity, c.City) AS Edit_Dostance_Similarity_Score,
    JARO_WINKLER_SIMILARITY(inp.InputCity, c.City) AS JaroWinkler_Similarity_Score
FROM #Incoming AS inp
CROSS APPLY #Cities  c
--WHERE EDIT_DISTANCE_SIMILARITY(inp.InputCity, c.City) > 60
ORDER BY inp.InputCity;
GO

