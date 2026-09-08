USE master;


ALTER DATABASE SQLDayDemo
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO



SET NOCOUNT ON;
SET XACT_ABORT ON;

IF DB_ID(N'SQLDayDemo') IS NULL CREATE DATABASE SQLDayDemo;
GO

USE SQLDayDemo;
GO

DROP TABLE IF EXISTS dbo.SessionSpeaker;
DROP TABLE IF EXISTS dbo.SpeakerEditionProfile;
DROP TABLE IF EXISTS dbo.Speaker;
DROP TABLE IF EXISTS dbo.SessionTag;
DROP TABLE IF EXISTS dbo.SessionDetails;

DROP TABLE IF EXISTS dbo.SessionEmbedding;

DROP TABLE IF EXISTS dbo.Tag;

DROP TABLE IF EXISTS dbo.SessionFormat;
DROP TABLE IF EXISTS dbo.SessionLevel;
DROP TABLE IF EXISTS dbo.Language;
DROP TABLE IF EXISTS dbo.EventEdition;
DROP TABLE IF EXISTS dbo.TopicTrack;
GO

CREATE TABLE dbo.EventEdition (
    EventEditionId smallint NOT NULL CONSTRAINT PK_EventEdition PRIMARY KEY,
    EventName nvarchar(50) NOT NULL,
    EditionYear smallint NOT NULL,
    SourceFileName nvarchar(260) NOT NULL,
    CONSTRAINT UQ_EventEdition UNIQUE (EventName, EditionYear),
    CONSTRAINT CK_EventEdition_Year CHECK (EditionYear BETWEEN 2000 AND 2100)
);

CREATE TABLE dbo.Language (
    LanguageId tinyint NOT NULL CONSTRAINT PK_Language PRIMARY KEY,
    LanguageName nvarchar(50) NOT NULL CONSTRAINT UQ_Language UNIQUE
);

CREATE TABLE dbo.SessionLevel (
    SessionLevelId tinyint NOT NULL CONSTRAINT PK_SessionLevel PRIMARY KEY,
    LevelName nvarchar(100) NOT NULL CONSTRAINT UQ_SessionLevel UNIQUE
);

CREATE TABLE dbo.SessionFormat (
    SessionFormatId tinyint NOT NULL CONSTRAINT PK_SessionFormat PRIMARY KEY,
    FormatName nvarchar(100) NOT NULL --CONSTRAINT UQ_SessionFormat UNIQUE
);

CREATE TABLE dbo.TopicTrack (
    TopicTrackId smallint NOT NULL CONSTRAINT PK_TopicTrack PRIMARY KEY,
    TrackName nvarchar(150) NOT NULL CONSTRAINT UQ_TopicTrack UNIQUE
);

CREATE TABLE dbo.Speaker (
    SpeakerId int NOT NULL CONSTRAINT PK_Speaker PRIMARY KEY,
    FirstName nvarchar(100) NOT NULL,
    LastName nvarchar(100) NOT NULL,
    DisplayName AS CONCAT(FirstName, N' ', LastName) PERSISTED
);

CREATE TABLE dbo.Tag (
    TagId smallint NOT NULL CONSTRAINT PK_Tag PRIMARY KEY,
    TagName nvarchar(150) NOT NULL CONSTRAINT UQ_Tag UNIQUE
);

CREATE TABLE dbo.SessionDetails (
    SessionId int NOT NULL CONSTRAINT PK_SessionDetails PRIMARY KEY,
    EventEditionId smallint NOT NULL,
    Title nvarchar(500) NOT NULL,
    [Description] nvarchar(max) NULL,
    SessionFormatId tinyint NULL,
    SessionLevelId tinyint NULL,
    LanguageId tinyint NULL,
    TopicTrackId smallint NULL,
    Room nvarchar(150) NULL,
    ScheduledAt datetime2(0) NULL,
    ScheduledDurationMinutes smallint NULL,
    LiveUrl nvarchar(1000) NULL,
    RecordingUrl nvarchar(1000) NULL,
    FavoritedCount int NOT NULL CONSTRAINT DF_Session_Favorited DEFAULT (0),
    CONSTRAINT FK_Session_EventEdition FOREIGN KEY (EventEditionId) REFERENCES dbo.EventEdition(EventEditionId),
    CONSTRAINT FK_Session_Format FOREIGN KEY (SessionFormatId) REFERENCES dbo.SessionFormat(SessionFormatId),
    CONSTRAINT FK_Session_Level FOREIGN KEY (SessionLevelId) REFERENCES dbo.SessionLevel(SessionLevelId),
    CONSTRAINT FK_Session_Language FOREIGN KEY (LanguageId) REFERENCES dbo.Language(LanguageId),
    CONSTRAINT FK_Session_Track FOREIGN KEY (TopicTrackId) REFERENCES dbo.TopicTrack(TopicTrackId),
    CONSTRAINT CK_Session_Duration CHECK (ScheduledDurationMinutes IS NULL OR ScheduledDurationMinutes > 0)
);

CREATE TABLE dbo.SessionSpeaker (
    SessionId int NOT NULL,
    SpeakerId int NOT NULL,
    SpeakerOrder tinyint NOT NULL,
    IsSubmissionOwner bit NOT NULL CONSTRAINT DF_SessionSpeaker_Owner DEFAULT (0),
    CONSTRAINT PK_SessionSpeaker PRIMARY KEY (SessionId, SpeakerId),
    CONSTRAINT UQ_SessionSpeaker_Order UNIQUE (SessionId, SpeakerOrder),
    CONSTRAINT FK_SessionSpeaker_SessionDetails FOREIGN KEY (SessionId) REFERENCES dbo.SessionDetails(SessionId),
    CONSTRAINT FK_SessionSpeaker_Speaker FOREIGN KEY (SpeakerId) REFERENCES dbo.Speaker(SpeakerId)
);

CREATE TABLE dbo.SessionTag (
    SessionId int NOT NULL,
    TagId smallint NOT NULL,
    CONSTRAINT PK_SessionTag PRIMARY KEY (SessionId, TagId),
    CONSTRAINT FK_SessionTag_SessionDetails FOREIGN KEY (SessionId) REFERENCES dbo.SessionDetails(SessionId),
    CONSTRAINT FK_SessionTag_Tag FOREIGN KEY (TagId) REFERENCES dbo.Tag(TagId)
);

CREATE TABLE dbo.SpeakerEditionProfile (
    SpeakerId int NOT NULL,
    EventEditionId smallint NOT NULL,
    TagLine nvarchar(500) NULL,
    Bio nvarchar(max) NULL,
    LinkedInUrl nvarchar(1000) NULL,
    XUrl nvarchar(1000) NULL,
    CompanyWebsiteUrl nvarchar(1000) NULL,
    BlogUrl nvarchar(1000) NULL,
    FacebookUrl nvarchar(1000) NULL,
    InstagramUrl nvarchar(1000) NULL,
    CONSTRAINT FK_SpeakerEditionProfile_Speaker FOREIGN KEY (SpeakerId) REFERENCES dbo.Speaker(SpeakerId),
    CONSTRAINT FK_SpeakerEditionProfile_Edition FOREIGN KEY (EventEditionId) REFERENCES dbo.EventEdition(EventEditionId)
);

CREATE INDEX IX_Session_EventEdition ON dbo.SessionDetails(EventEditionId);
CREATE INDEX IX_Session_Track ON dbo.SessionDetails(TopicTrackId);
CREATE INDEX IX_SessionSpeaker_Speaker ON dbo.SessionSpeaker(SpeakerId);
GO


USE master
GO

USE SQLDayDemo;
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRANSACTION;

INSERT INTO dbo.EventEdition (EventEditionId, EventName, EditionYear, SourceFileName) VALUES
(1, N'SQLDay', 2024, N'SQLDay 2024'),
(2, N'SQLDay', 2025, N'SQLDay 2025'),
(3, N'SQLDay', 2026, N'SQLDay 2026'),
(4, N'SQLDay Lite', 2024, N'SQLDay Lite 2024'),
(5, N'SQLDay Lite', 2025, N'SQLDay Lite 2025'),
(6, N'SQLDay Lite', 2026, N'SQLDay Lite 2026');

INSERT INTO dbo.Language (LanguageId, LanguageName) VALUES
(1, N'English'),
(2, N'Polish');

INSERT INTO dbo.SessionLevel (SessionLevelId, LevelName) VALUES
(1, N'Advanced'),
(2, N'Expert'),
(3, N'Intermediate'),
(4, N'Introductory and overview');

INSERT INTO dbo.SessionFormat (SessionFormatId, FormatName) VALUES
(1, N'20min Keynote'),
(2, N'45min Session'),
(3, N'Keynote (30 min)'),
(4, N'Pre-Con Hands-on Lab (8h)'),
(5, N'Pre-con hands-on lab (8h)'),
(6, N'Pre-con seminar (8h)'),
(7, N'SessionDetails (60 min)'),
(8, N'Workshop'),
(9, N'Workshop (8h)');

INSERT INTO dbo.TopicTrack (TopicTrackId, TrackName) VALUES
(1, N'AI-Powered Analytics'),
(2, N'AI/ML'),
(3, N'Advanced Modern Analytics'),
(4, N'Architecture'),
(5, N'Azure'),
(6, N'Data Architecture & Governance'),
(7, N'Data Vizualizations'),
(8, N'Fabric'),
(9, N'Next-Gen Data Engineering & Modern BI'),
(10, N'PowerBI'),
(11, N'SQL Admin'),
(12, N'SQL DBA/Dev'),
(13, N'SQL DBA/Dev, AI/ML'),
(14, N'SQL Dev'),
(15, N'SQL in Action'),
(16, N'Timeless Foundations');

INSERT INTO dbo.Tag (TagId, TagName) VALUES
(1, N'Administration'),
(2, N'AI'),
(3, N'AI Agents'),
(4, N'AI in Medicine'),
(5, N'Artificial Intelligence'),
(6, N'Automation'),
(7, N'AWS'),
(8, N'Azure'),
(9, N'Azure SQL Database'),
(10, N'Big Data'),
(11, N'Cloud'),
(12, N'Computer Vision'),
(13, N'Copilot'),
(14, N'Cosmos DB'),
(15, N'Cryptography'),
(16, N'Data Factory'),
(17, N'Data Governance'),
(18, N'Data lake'),
(19, N'Data Quality'),
(20, N'Data Visualisation'),
(21, N'DataAgent'),
(22, N'Databricks'),
(23, N'DataOps'),
(24, N'DAX'),
(25, N'dbt'),
(26, N'DecisionIntelligence'),
(27, N'Deployment'),
(28, N'Development'),
(29, N'Dimensional Modelling'),
(30, N'ETL'),
(31, N'Extended Events'),
(32, N'GCP'),
(33, N'GenAI'),
(34, N'Instrumentation'),
(35, N'Integration'),
(36, N'IntelligentInsights'),
(37, N'Internals'),
(38, N'IoT'),
(39, N'Kusto query language'),
(40, N'LLM'),
(41, N'Machine Learning'),
(42, N'Machine Learning Life Cycle'),
(43, N'Managing'),
(44, N'Migration'),
(45, N'Monitoring'),
(46, N'MS Fabric'),
(47, N'Non technical'),
(48, N'On Premises'),
(49, N'Open-source'),
(50, N'OracleDB'),
(51, N'Performance Tuning'),
(52, N'PostgreSQL'),
(53, N'Power BI'),
(54, N'PowerApps'),
(55, N'PowerAutomate'),
(56, N'Productivity'),
(57, N'Prompt Engineering'),
(58, N'Python'),
(59, N'Real-Time Intelligence'),
(60, N'Reporting'),
(61, N'Responsible AI'),
(62, N'REST API'),
(63, N'Security'),
(64, N'Snowflake'),
(65, N'Spark'),
(66, N'SPONSORED'),
(67, N'SQL Managed Instance'),
(68, N'SQL Server'),
(69, N'SQL2017'),
(70, N'SQL2019'),
(71, N'SQL2022'),
(72, N'SQL2025'),
(73, N'Streaming Data'),
(74, N'Synapse Analytics'),
(75, N'T-SQL');

INSERT INTO dbo.Speaker (SpeakerId, FirstName, LastName) VALUES
(1,  N'Jakub', N'Igła'),
(2, N'Dominik', N'Dębowski'),
(3, N'Maciej', N'Helt'),
(4, N'Grzegorz', N'Łyp'),
(5, N'Tomasz', N'Mazurek'),
(6, N'Piotr', N'Zieliński'),
(7, N'Grzegorz', N'Brodny'),
(8, N'Tomasz', N'Szreder'),
(9, N'Dominik', N'Szcześniak'),
(10, N'Lukasz', N'Grala'),
(11, N'Dawid', N'Kolasa'),
(12, N'Dr. Dani', N'Ljepava'),
(13, N'Remigiusz', N'Kinas'),
(14, N'Jacek', N'Nosal'),
(15, N'Karol', N'Krupa'),
(16, N'Piotr', N'Balik'),
(17, N'Mathias', N'Halkjaer'),
(18, N'Andrea', N'Martorana Tusa'),
(19, N'Daniel', N'Brański'),
(20, N'Jakub', N'Frydrych'),
(21, N'Wioleta', N'Sokołowska'),
(22, N'Marek', N'Maśko'),
(23, N'Michal', N'Tinthofer'),
(24, N'Tim', N'Spannagel'),
(25, N'Injae', N'Park'),
(26, N'Tonie', N'Huizer'),
(27, N'Artur', N'Dalak'),
(28, N'Rudi', N'Bruchez'),
(29, N'Mladen', N'Andzic'),
(30, N'Sebastian', N'Stulik'),
(31, N'Filip', N'Popović'),
(32, N'Ula', N'Cholewa'),
(33, N'Matt', N'Collins'),
(34, N'Szymon', N'Lasota'),
(35, N'Hugo', N'Kornelis'),
(36, N'Peer', N'Grønnerup'),
(37, N'Artur', N'Lachowicz'),
(38, N'Adam', N'Marczak'),
(39, N'Piotr', N'Tybulewicz'),
(40, N'Kacper', N'Glugla'),
(41, N'Damian', N'Ostrowski'),
(42, N'Magdalena', N'Kurlanc'),
(43, N'Andrzej', N'Kukuła'),
(44, N'Pragati', N'Jain'),
(45, N'Marcin', N'Szeliga'),
(46, N'Erwin', N'de Kreuk'),
(47, N'Grant', N'Fritchey'),
(48, N'Alberto', N'Ferrari'),
(49, N'Tomasz', N'Gołaszewski'),
(50, N'Lars', N'Andersen'),
(51, N'Abhi', N'Jayanty'),
(52, N'Edwin M', N'Sarmiento'),
(53, N'Wojciech', N'Bukowski'),
(54, N'Catalin', N'Gheorghiu'),
(55, N'Marcin', N'Chudeusz'),
(56, N'Matthias', N'Nohl'),
(57, N'Štěpán', N'Rešl'),
(58, N'Mariusz', N'Wiecha'),
(59, N'Andy', N'Cutler'),
(60, N'Leszek', N'Michalak'),
(61, N'Uwe', N'Ricken'),
(62, N'Grzegorz', N'Stolecki'),
(63, N'Mathias', N'Thierbach'),
(64, N'Maciej', N'Dydejczyk'),
(65, N'Hubert', N'Kobierzewski'),
(66, N'Benni', N'De Jagere'),
(67, N'Antti', N'Loukiala'),
(68, N'Dominik', N'Bender'),
(69, N'Przemysław', N'Starosta'),
(70, N'Pawel', N'Potasinski'),
(71, N'Mihail', N'Mateev'),
(72, N'Jakub', N'Świercz'),
(73, N'Maciej', N'Pilecki'),
(74, N'Natalia', N'Warszewska'),
(75, N'Beata', N'Boraca'),
(76, N'Wojciech', N'Nowak'),
(77, N'Paul', N'Andrew'),
(78, N'Olivier', N'Van Steenlandt'),
(79, N'Bartlomiej', N'Graczyk'),
(80, N'Artur', N'Huk'),
(81, N'Marek', N'Maśko'),
(82, N'Kamil', N'Nowinski'),
(83, N'Krzysztof', N'Paś'),
(84, N'Mariusz', N'Kujawski'),
(85, N'Przemysław', N'Kundzicz'),
(86, N'Brian', N'Bønk'),
(87, N'Adrian', N'Chodkowski'),
(88, N'Michał', N'Jankowski'),
(89, N'Łukasz', N'Kałużny'),
(90, N'Martyna', N'Sikorska'),
(91, N'Asaf', N'Sneh'),
(92, N'Erik', N'Darling'),
(93, N'Michał', N'Pstrąg'),
(94, N'Michał', N'Kowalczewski'),
(95, N'Adam', N'Marczak'),
(96, N'Andrew', N'Pruski'),
(97, N'Joanna', N'Borkowska'),
(98, N'Sarah', N'Kossakowska'),
(99, N'Michał', N'Sadowski'),
(100, N'Marco', N'Russo'),
(101, N'Maciej', N'Rubczyński'),
(102, N'Łukasz', N'Balcerzak'),
(103, N'Tomasz', N'Krawczyk'),
(104, N'Tomasz', N'Jacyno'),
(105, N'Torsten', N'Strauß'),
(106, N'David', N'Postlethwaite'),
(107, N'Damian', N'Widera'),
(108, N'Dieter', N'Gobeyn'),
(109, N'Damian', N'Ryśnik'),
(110, N'Tomasz', N'Libera'),
(111, N'Strahinja', N'Rodic'),
(112, N'Paweł', N'Ekk-Cierniakowski'),
(113, N'Jakub', N'Wawrzyniak'),
(114, N'Bartek', N'Wierzbicki'),
(115, N'Gethyn', N'Ellis'),
(116, N'Radosław', N'Szmit'),
(117, N'Felix', N'Mutzl'),
(118, N'Julia', N'Orłowska'),
(119, N'Ola', N'Hallengren'),
(120, N'Anonymized', N'By Request'),
(121, N'Łukasz', N'Furga'),
(122, N'Patryk', N'Miziuła'),
(123, N'Agnieszka', N'Cieplak'),
(124, N'Estera', N'Kot'),
(125, N'Frank', N'Geisler'),
(126, N'Roman', N'Czarko-Wasiutycz'),
(127, N'Maciej', N'Pilecki'),
(128, N'Tomasz', N'Kostyrka'),
(129, N'Tomasz', N'Waloszek'),
(130, N'Peter', N'Kruis'),
(131, N'Duncan', N'Boyne'),
(132, N'Mladen', N'Prajdic'),
(133, N'Chris', N'Webb'),
(134, N'Just', N'Blindbæk'),
(135, N'Krystsina', N'Kremianeuskaya'),
(136, N'Patryk', N'Rożenek'),
(137, N'Maciej', N'Kępa'),
(138, N'James', N'Serra'),
(139, N'Wojciech', N'Pratkowiecki'),
(140, N'Sasa', N'Popovic'),
(141, N'Natalia', N'Bednarek'),
(142, N'Greg', N'Strzyminski'),
(143, N'Konrad', N'Sarnecki'),
(144, N'Sander', N'Stad'),
(145, N'Przemysław', N'Sapkowski'),
(146, N'Pieter', N'Vanhove'),
(147, N'Kev', N'Chant'),
(148, N'Johan Ludvig', N'Brattås'),
(149, N'Remigiusz', N'Tunowski'),
(150, N'Kornelia', N'Kobierzewska'),
(151, N'Michał', N'Gołoś'),
(152, N'Mateusz', N'Osiak'),
(153, N'Denis', N'Reznik'),
(154, N'Sławomir', N'Malinowski'),
(155, N'Krzysztof', N'Burejza'),
(156, N'Mariusz', N'Wójcik'),
(157, N'Magnus', N'Ahlkvist'),
(158, N'Erland', N'Sommarskog'),
(159, N'Gabi', N'Münster'),
(160, N'Michał', N'Góra');

INSERT INTO dbo.SessionDetails (SessionId, EventEditionId, Title, [Description], SessionFormatId, SessionLevelId, LanguageId, TopicTrackId, Room, ScheduledAt, ScheduledDurationMinutes, LiveUrl, RecordingUrl, FavoritedCount) VALUES
(1, 1, N'Onelake with Fabric, The Data Lake-as-a-Service Platform', N'In this session, we delve deeper into OneLake, a crucial component of Microsoft Fabric that serves as a data lake-as-a-service solution. OneLake enables organizations to avoid data silos and centrally store and manage data without the need to build or maintain a data lake themselves. It functions as a data storage platform, much like OneDrive does for files.

During this session, we explore how OneLake works and why it is a true game changer. We discuss the various capabilities of OneLake, including out-of-the-box governance features such as data lineage, data protection, certification, and catalog integration. These features facilitate streamlined data management and enhanced compliance.

Furthermore, we examine the integration of OneLake with other services, such as Power BI. Discover how applying a sensitivity label to a OneLake file automatically applies to related Power BI datasets, ensuring consistent security and compliance.

Whether you''re a data engineer, data scientist, or analyst, this SessionDetails provides valuable insights into how OneLake can help centralize and manage data while leveraging the scalability, security, and advanced capabilities of Microsoft Fabric. Get ready to explore the possibilities of OneLake and understand why it is a critical component of the modern data landscape.

I look forward to welcoming you to this engaging session, and learn you how OneLake can make a difference in your organization.', 7, 4, 1, 8, N'Room B', '2024-05-14T10:50:00', 60, NULL, NULL, 0),
(2, 1, N'User Definied Functions – From SQL 2000 – SQL 2022', N'User Definied Functions (UDF) came first with SQL Server 2000. While developers welcomed the introduction of these features, they became a DAB nightmare.
This SessionDetails start with the very basics of User Definied Functions (SCALAR, MULTI-LINE, INLINE) and shows the problems of functions when they get used in queries.
Lots of improvements have been made since to speed up queries which are using UDF.
The second part of the SessionDetails treat the great improvements of execution of functions and show ways to reach new records in the execution of your queries with UDFs.', 7, 3, 1, 14, N'Room C', '2024-05-15T09:00:00', 60, NULL, NULL, 0),
(3, 1, N'What you can do to protect your SQL Server and why it matters', N'How secure is your SQL Server?

What steps do you take to ensure that your SQL Server is safe from attack?
The CIS Benchmarks, from the Centre of Internet Security (CIS), are a set of globally recognized and consensus-driven best practices to help us implement and manage our cybersecurity defences.

What that means is that there is a set of guidelines, or best practices, agreed upon by the industry that suggests the best things to do to make our SQL Servers secure.

In this session, listen to David and Gethyn discussing these best practices, see if you agree with them, and see how many you have implemented.', 7, 4, 1, 11, N'Room C', '2024-05-14T16:50:00', 60, NULL, NULL, 0),
(4, 1, N'Lessons learnt from PySpark Notebooks and extracting APIs', N'Notebooks inside Fabric are a high-speed solution for data transformation, and APIs are a great data source and are provided by many systems. So, it is great to have the ability to download and shape their data by PySpark for other Fabric purposes.

In this session, I will show my lessons learnt from Notebooks and API extractions. A SessionDetails is aimed even for beginners who have never worked with APIs or Notebooks. I will show what libraries are required and how to create a User Define Function that can be very handy for more complex transformations.', 7, 3, 1, 8, N'Room D', '2024-05-15T11:40:00', 60, NULL, NULL, 0),
(5, 1, N'ChatGPT is the best DBA sidekick', N'Have you tried using ChatGPT to ease your day-to-day database duties? ChatGPT is your AI partner that can read deadlock graphs, analyze locking, write and correct T-SQL code, interpret execution plans, find informations from the ERRORLOG, and much more. I''m going to introduce you to the assistant every DBA wishes they had - OpenAI''s language model, ChatGPT. We''re going to look at the impressive, the surprising, and even the funny hiccups when AI meets SQL Server.

Some Highlights:
Ever feel like you''re trying to decode alien language when looking at deadlock graphs? Watch as ChatGPT deciphers these for you in real-time!

AI Locking Analysis: see ChatGPT detect and analyze locking conflicts from the unfathomable blocked process report

Ask ChatGPT for any T-SQL solution for getting information or acting on the Database, like creating test data. And correct its mistakes along the way.

AI Reading Execution Plans: Watch ChatGPT unravel the mysteries of execution plans, a task that often seems like trying to understand modern art!

In this session, you will understand the potential (and limits!) of AI, specifically ChatGPT, in SQL Server administration and performance tuning, and learn to leverage ChatGPT in diagnosing and resolving common and not-so-common SQL Server issues, including those pesky deadlock graphs and locking issues.

By the way, thanks to ChatGPT for the help in writing this abstract!', 7, 4, 1, 11, N'Room D', '2024-05-14T10:50:00', 60, NULL, NULL, 0),
(6, 1, N'Modele danych w Power BI - koniec żartów i gaz do dechy!', N'Czas skończyć w kółko powtarzane opery mydlane o gwiazdach, faktach i wymiarach. Czas wyjść poza ogólnie znane historie o relacjach i filtrach. W ostatnim czasie (a nawet dawno temu) w Power BI pojawiło się sporo nowych narzędzi, funkcjonalności oraz trendów: grupy kalkulacyjne, modele kompozytowe, tabele hybrydowe, agregacje, funkcje okienkowe i kalkulacje wizualne, RLS statyczny i dynamiczny, OLS, podejście No Calculate i wiele innych. Wszystkie te rzeczy, chcesz czy nie chcesz, są składnikami modelu danych, które musisz brać pod uwagę już na wczesnych etapach projektowania.
Ten warsztat jest dla Ciebie jeśli chcesz wyjść poza fundamenty modelowania wielowymiarowego, zanurkować głęboko w to co potrafi Power BI i stworzyć modele wydajne, funkcjonalne no i (ważne) ładne.', 9, 3, 2, 10, N'Room C', '2024-05-13T08:30:00', 540, NULL, NULL, 0),
(7, 1, N'Using Lakehouse Data at scale with Power BI, featuring Direct Lake mode', N'Many companies have invested heavily in building data lakes to store large volumes of structured and unstructured data from various sources into Delta Parquet files. These Delta Parquet files can be used for a wide range of Analytics and Business Intelligence applications. Most of these organizations struggle to derive insights from their investments due to the complexity of accessing and querying the data, and how to let self-service users connect to this data in the lake using Power BI.

With the introduction of Microsoft Fabric, an all-in-one analytics solution for enterprises, we now have a better approach for this. In this session, we will explore how to use Lakehouse data at scale with Power BI, using the new Direct Lake connectivity mode. Power BI Direct Lake combines the best of both worlds from Import and DirectQuery mode, and gives us the option for great performance over data in the lake, without introducing additional latency for dataset refreshes.

We will start by discussing the benefits of the Lakehouse architecture and how it can improve data management and analytics. We will then move on to explore how to connect to Lakehouse data using Power BI by combining both of these architecture components and using each of them to their strengths.

We will also cover best practices for optimizing performance when working with large volumes of data, including using data partitioning and query optimization techniques. We will demonstrate how to use Power BI to analyze Lakehouse data in real-time and how to build reports that provide actionable insights for decision-making.

By the end of the session, attendees will have a solid understanding of how to leverage Lakehouse data at scale with Power BI and how to build powerful analytics solutions that can handle massive amounts of data. Whether you are a data analyst, data scientist, or BI professional, this SessionDetails will provide you with valuable insights into the world of Lakehouse data and Power BI, featuring the new Direct Lake connectivity mode.', 7, 1, 1, 8, N'Room A', '2024-05-14T12:10:00', 60, NULL, NULL, 0),
(8, 1, N'Data platform engineering - Insights into building a Cloud Data Platform', N'In this keynote, I will take you on a journey through the world of data platform engineering, using the example of a remarkable collaboration between Lufthansa, Microsoft, and Databricks to build a company-wide data platform on Azure that started in 2021.

Our story begins with the humble origins of the One Data Platform (ODP) team, where we started by crafting our first Terraform scripts. Fast forward to today, and we are proud to serve approximately 50 internal tenants within the Lufthansa ecosystem.

Throughout this transformative journey, we''ve grappled with managing a multitude of resources, including scaling up to thousands of vCPUs, orchestrating Databricks clusters, and handling multiple AI/ML workspaces. Additionally, we''ve been responsible for designing and the oversight of hundreds of other Azure assets.

Reference:
- https://customers.microsoft.com/en-us/story/1483045629012560205-lufthansa-azure-en
- https://pages.databricks.com/202303-EMEA-FE-Lakehouse-Day-Frankfurt.html
https://www.linkedin.com/posts/cspannbauer_our-odp-one-data-platform-is-one-of-our-activity-7097282290434621440-FvdL/
- https://investor-relations.lufthansagroup.com/fileadmin/downloads/en/more/LHG-Bericht-ueber-die-Erreichung-der-EU-Ziele-Veroeffentlichungsform-ENG.pdf', 7, 3, 1, 5, N'Room D', '2024-05-14T16:50:00', 60, NULL, NULL, 0),
(9, 1, N'Driving alerts and actions on your data', N'Your data is only valuable if you can act on it. But acting on data often requires manual monitoring of reports and dashboards, which can be time-consuming. That''s why we have created Data Activator. Data Activator is an experience in Microsoft Fabric that lets you create alerts and trigger an event like email, Teams message or Power Automate flows from your data, without writing code. In this session. In this SessionDetails you will see how Data Activator works in action', 7, 3, 1, 8, N'Room C', '2024-05-15T15:00:00', 60, NULL, NULL, 0),
(10, 1, N'Data Encryption & Integrity: Innovations in Azure SQL', N'Transparent data encryption (TDE), Always Encrypted and ledger are integral components of SQL Server and Azure SQL Database''s security arsenal, providing robust data protection, confidentiality, and integrity. Combining encryption and ledger capabilities significantly enhances data security by ensuring the protection of sensitive data at rest and mitigating the risk of data tampering or unauthorized modifications. Together, they fortify the database against various attack vectors, help you meet regulatory requirements, and instill trust across multiple parties in an increasingly data-driven landscape.', 7, 3, 1, 11, N'Room D', '2024-05-15T10:20:00', 60, NULL, NULL, 0),
(11, 1, N'Deneb and Vega-Lite: The Secret Weapon for Custom Power BI Visuals', N'Join us for an how-to SessionDetails that guides you through the journey of crafting a custom Power BI visual using the Deneb and Vega-Lite combination, starting with the essentials and progressing to creating an advanced visualization.
We will explore a variety of aspects, including data transformations, using parameters and expressions, as well as enabling interactive functionalities and custom tooltips.
Whether you''re a newcomer or an experienced Power BI developer, this meetup promises to empower you with the knowledge and skills to create impactful custom visuals.
Don''t miss this chance to unlock the full potential of Power BI data visualization!', 7, 1, 1, 10, N'Room B', '2024-05-14T15:30:00', 60, NULL, NULL, 0),
(12, 1, N'Azure Data Factory - Deployment challenges', N'ADF is an important brick in the architecture of any modern data warehousing solution and many other scenarios.
As it exists for some time now and we know its capability pretty well, the deployment of the service is still something that leaves much to be desired, specifically in a bit more complex instances.
In this session, I will show a few challenges to publishing ADF and solution for them.', 7, 3, 2, 5, N'Room A', '2024-05-15T10:20:00', 60, NULL, NULL, 0),
(13, 1, N'Advanced semantic models refresh automation in Power BI', N'Take full control over your semantic model refresh automation. Usually, in your daily planning there’s a gap between your data source data availability and the scheduled refresh on the Power BI service. This is caused by the impossibility to directly connect the semantic model refresh to a pipeline.

How to bridge that gap? How to trigger a Power BI semantic model refresh as the final step of a full ETL process? There are several ways to achieve it. It is possible to invoke the Power BI APIs in combination with tools such as Power Automate, or to run some Powerhell scripts, for example.

Furthermore, you can go deeper with the Dataset API, triggering only a specific table or even a single partition. Not the full semantic model, saving time and resources on your system.

In this heavily demo-based session, many examples of automation are showcased based on real cases of implementation in Pandora. You will see how to:

-Trigger a semantic model refresh using Power Automate
-Post a semantic model refresh using Power BI API and Power Automate
-Post a semantic model refresh from Logic App
-Trigger a semantic model refresh using Powershell
-Trigger a single table or partition refresh in your semantic model using XMLA endpoint and SSMS
-Handle advanced incremental refresh with the XMLA endpoint and the Tabular Model Scripting Language
-Trigger a single table or partition refresh in your semantic model using the enhanced dataset API
-Trigger a refresh from an Azure Data Factory / Synapse Analytics pipeline', 7, 2, 1, 10, N'Room A', '2024-05-14T14:10:00', 60, NULL, NULL, 0),
(14, 1, N'Power BI. Przekraczając kolejne granice granic na mapach.', N'Zapraszam na kolejne spotkanie z mapami w Power BI. Podczas tej sesji opowiem o walce, zwiątpieniu, porzuceniu i powrocie do odkrywania nowych możliwości. To niczym  odkrywanie nowych lądów. Teraz ten proces wygląda na fajną przygodę. Determinacja i wizja osiągnięcia celu, to cechy, które mnie nie opuściły. Dlaczego tak mało tematów poświęcanych jest mapom? Bo bywają trudne, niestabilne. A dopóki nie włączy się opcja ciekawości - "dlaczego to tak działa", a może "zadziała w ten sposób", to nadal pewne możliwości skrywana na mapach pozostają bezludnymi wyspami. Serdecznie zapraszam.', 7, 3, 2, 10, N'Room A', '2024-05-15T11:40:00', 60, NULL, NULL, 0),
(15, 1, N'Building an Azure Data Analytics Platform End-to-End', N'The resources on offer in Azure are constantly changing, which means as data professionals we need to constantly change too. Updating knowledge and learning new skills. No longer can we rely on products matured over a decade to deliver all our solution requirements. Today, data platform architectures designed in Azure with best intentions and known design patterns can go out of date within months. That said, is there now a set of core components we can utilise in the Microsoft cloud to ingest, curation and deliver insights from our data? When does ETL become ELT? When is IaaS better than PaaS? Do we need to consider scaling up or scaling out? And should we start making cost the primary factor for choosing certain technologies? In this SessionDetails we''ll explore the answers to all these questions and more from an architect’s viewpoint. Based on real world experience let’s think about just how far the breadth of our knowledge now needs to reach when starting from nothing and building a complete Microsoft Azure Data Analytics solution.', 7, 1, 1, 4, N'Auditorium', '2024-05-15T09:00:00', 60, NULL, NULL, 0),
(16, 1, N'Hacking and Hacking Mitigation For SQL Server', N'In recent years we have seen and heard about a scenarios where hackers gained access to your system, databases are encrypted and where data is stolen.
The question is not if our systems are going to be attacked, but rather when this is going to happen.

As a data professional you have the obligation to protect the data to the best of your abilitity.
You have to deal with both outsider and insider threats.
Outside attackers motivated by profit, activism, retribution, or mischief.
Insider threats may have the same motives but could be tied to workplace issues resulting in people abusing their access privileges to inflict harm.

When you have been attacked it is really important to find out what happened and how to mititgate the attack.
Mitigation, or Attack Mitigation, is the reduction in seriousness or severity of an event.
In mitigation we center around strategies to limit the impact of a threat against our data.

In this SessionDetails we will discuss:

* Teach you how you can attack your systems
* Mitigate the attack
* Log your findings', 7, 3, 1, 14, N'Room C', '2024-05-14T12:10:00', 60, NULL, NULL, 0),
(17, 1, N'Obsługa błędów w Azure Data Factory', N'To normalne, że każdy z nas robi błędy w kodzie. Natomiast ważne jest to, jak je obsługujemy i czy w ogóle jesteśmy powiadamiani w przypadku ich wystąpienia.

Podczas tej sesji omówię różne wzorce, których możemy używać w Azure Data Factory do obsługi błędów. Pokażę również sposób, dzięki któremu możemy łatwo włączyć powiadomienia o błędach przetwarzania pipeline''ów.', 7, 3, 2, 5, N'Room C', '2024-05-14T10:50:00', 60, NULL, NULL, 0),
(18, 1, N'DP-600 exam for Fabricators', N'In this SessionDetails we introduce Fabricators to the DP-600 exam. Which you need to pass to gain the Microsoft Certified: Fabric Analytics Engineer Associate certification.

It is co-presented by two MVP’s who have looked into solutions for clients from different perspectives. One from a Power BI background and one from a Data Engineering services background.

So that you get a holistic overview about the main objectives for the DP-600 exam.

During the SessionDetails we provide an overview about each of the main sections of the exam:
• Plan, implement and manage a solution for data analytics
• Prepare and serve data
• Implement and manage semantic models
• Explore and analyze data

During the SessionDetails we will show demos. Along with some tips along the way.

At the end of this training day, you will have a good overview about what is required for the DP-600 exam.', 7, 4, 1, 8, N'Room B', '2024-05-15T13:40:00', 60, NULL, NULL, 0),
(19, 1, N'Generatywna Sztuczna Inteligencja dla zabieganych', N'Zapoznaj się z możliwościami generatywnej sztucznej inteligencji (GAI) na praktycznym warsztacie dla specjalistów danych. Dowiesz się, czym są duże modele językowe (LLMs) i jak wykorzystać je do tworzenia inteligentnych aplikacji. Nauczysz się używać usług Azure OpenAI i Copilot, formułowania skutecznych promptów, pytania LLMs o Twoje własne dane za pomocą rozwiązań RAG i zasad odpowiedzialnego korzystania z GAI. Odkryjesz, że LLMs to nie tylko czatboty generujące słowa, ale potężne narzędzia, które potrafią obsługiwać różne języki, wyszukiwać informacje, analizować dane, prognozować wyniki, tworzyć i interpretować obrazy, muzykę i mowę. Nie przegap tej okazji, aby poznać technologię, która zmienia sposób, w jaki pracujemy z komputerami.

Aby wykonać ćwiczenia z pierwszej części warsztatu dotyczącej usługi Microsoft Copilot, wymaga tylko komputera z przeglądarką Edge i konta Microsoft.

Aby wziąć udział w ćwiczeniach z drugiej części warsztatu, w ramach której będziemy używać usługi Azure OpenAI, będziesz dodatkowo potrzebował Visual Studio Code z rozszerzeniami dla języka Python i Jupyter Notebook.', 9, 3, 2, 2, N'Room 351', '2024-05-13T08:30:00', 540, NULL, NULL, 0),
(20, 1, N'SQL Server 2022 Performance Enhancements', N'In this SessionDetails we are going to look at the performance enhancements in SQL Server 2022. We will cover the most important enhancements in the optimizer (intelligent query processing), storage engine, Accelerated Database Recovery, availability groups, Query Store, stack dumps and some more.

Which problems are the features solving? How are they doing it?

I will share some real-world experiences of the features, from running SQL Server 2022 on mission-critical databases.', 7, 3, 1, 11, N'Auditorium', '2024-05-14T12:10:00', 60, NULL, NULL, 0),
(21, 1, N'Microsoft Fabric Real-Time Analytics', N'In the fast-paced world of data analytics, real-time insights are the driving force behind informed decisions and competitive advantage. The long-awaited moment is here: Real-Time Analytics in Microsoft Fabric has reached general availability (GA), unveiling a wide range of transformative features and capabilities to empower data-driven professionals across diverse domains. Whether you’re an experienced business analyst, a curious citizen data scientist, or a passionate data engineer, Real-Time Analytics is your gateway to endless possibilities.', 7, 4, 1, 8, NULL, NULL, NULL, NULL, NULL, 0),
(22, 1, N'[PL] Doskonalenie Zapytań w Świecie Baz Danych', N'Zapraszamy na całodniowy warsztat "Doskonalenie Zapytań w Świecie Baz Danych",który jest praktycznym Hands-On Lab, skupiającym się na rozwijaniu umiejętności w zakresie pisywania efektywnych zapytań SQL. W trakcie warsztatu uczestnicy zdobędą głębsze zrozumienie planów zapytań, dowiedzą się, jak optymalizować kod SQL, oraz jak wykorzystać narzędzia takie jak Query Store do monitorowania i analizy wydajności zapytań.
Warsztat obejmie także omówienie różnych metod optymalizacji kodu SQL, uwzględniając zarówno aspekty czytelności, jak i wydajności. Uczestnicy dowiedzą się, jak unikać pułapek, zrozumieją istotę indeksów i poznają techniki tworzenia zapytań, które są skalowalne i efektywne.
Dodatkowo, warsztat dotknie tematu nowoczesnych narzędzi, takich jak GitHub Copilot czy ChatGPT, i omówi, w jaki sposób mogą być użyte w procesie tworzenia zapytań SQL. Będziemy rozważać zalety i ograniczenia tych narzędzi oraz przedstawimy praktyczne wskazówki dotyczące współpracy z nimi, zwracając uwagę na fakt, że choć są one potężne, to nie zawsze idealnie odzwierciedlają indywidualne potrzeby projektu.
Zapraszamy wszystkich entuzjastów baz danych i programistów do udziału w warsztacie, gdzie zyskają praktyczne umiejętności, które pozwolą im doskonalić jakość i wydajność swoich zapytań SQL.', 9, 3, 2, 14, N'Auditorium', '2024-05-13T08:30:00', 540, NULL, NULL, 0),
(23, 1, N'Azure Databricks - zero to hero', N'Współczesne rozwiązania charakteryzują się dużą skalą przez co tradycyjne rozwiązania oparte o relacyjne bazy danych przestają spełniać swoją rolę. Tutaj z pomoca przychodzą nam rozwiązania oparte o data lake, które dzięki skalowalnemu storage i rozdzieleniu go od warstwy przetwarzającej daje możliwość równoległego przetwarzania na dużą skalę. Z drugiej zaś strony chcielibyśmy móc wykorzystać tę moc ale też skorzystać z prostoty tradycyjnych hurtowni i składować dane jak tabele, odpytywać je językiem SQL czy też łatwo aktualizować. Tutaj z pomocą przychodzi nam lakehouse będący połączeniem obu podejść oraz platforma Azure Databricks umożliwiająca budowę takiego rozwiązania.

Podczas warsztatu przedstawione zostaną kluczowe elementy związane z pracą z Databricks i lakehouse w tym:
- wstęp do usługi,
- klastry, konfiguracja i ich typy,
- omówienie formatu Delta,
- Unity Catalog,
- tworzenie i operacje na obiektach,
- wydajność i utrzymanie rozwiązania,
- Delta Live Tables i Autoloader,
- Orkiestracja i monitoring,
- Databricks SQL Warehouse,
- Integracja z innymi usługami Azure oraz Power BI

Całość okraszona zostanie praktycznymi przykładami oraz całą gamą dobrych praktyk wypracowanych w projektach implementacyjnych.', 9, 3, 2, 5, N'Room D', '2024-05-13T08:30:00', 540, NULL, NULL, 0),
(24, 1, N'Microsoft Fabric - hidden gems', N'W trakcie sesji skupimy się na eksplorowaniu mniej znanych, ale wartościowych aspektów platformy Microsoft Fabric. Podczas prezentacji skierujemy uwagę na funkcje, które często pozostają w cieniu, ale mają istotne znaczenie dla efektywności i potencjału innowacyjnego tej platformy.

Poruszymy kwestie związane zarówno z wydajnością samej platformy, jak i również jej automatyzacją, skalowaniem oraz utrzymaniem. Całość zostanie wzbogacona o niezbędną dawkę wiedzy praktycznej, użytecznej przy projektowych zastosowaniach platformy.', 7, 3, 2, 8, N'Auditorium', '2024-05-15T10:20:00', 60, NULL, NULL, 0),
(25, 1, N'Generatywna sztuczna inteligencja w IT- możliwości i zagrożenia', N'Generatywna sztuczna inteligencja (GAI) to technologia, która potrafi tworzyć nowe treści na podstawie danych wejściowych. Może to być tekst, obraz, dźwięk, wideo lub kod. GAI ma wiele zastosowań w IT, od automatyzacji zadań, poprzez wspomaganie kreatywności, po generowanie rozwiązań. Jednak GAI niesie ze sobą także wiele wyzwań i ryzyk, takich jak etyka, bezpieczeństwo, ochrona danych czy prawa autorskie. Na tej sesji dowiesz się, jak korzystać z GAI w sposób odpowiedzialny i świadomy, jakie są jej zalety i ograniczenia, oraz jak radzić sobie z potencjalnymi zagrożeniami.', 7, 3, 2, 2, N'Auditorium', '2024-05-14T14:10:00', 60, NULL, NULL, 0),
(26, 1, N'(Azure) Open AI - how to work with information not with data warehouse(s)', N'(Azure) Open AI - how to work with information, not with data warehouse(s)

OpenAI changes the approach to how we are working with data. Previously, to get insights, we had to extract information from source systems, put them into formalized structures, and then - build reports.
Now, we can work with "free text" (ubiquitous in medicine) in any language humans speak and get accurate results. So - instead of building "yet another central data warehouse," we can work directly with source information.
But - this will require an entirely different approach to creating information systems. Also, some information is already in structured formats. So we need to combine two worlds. In that session, we will discuss how we could do that - using (among others!) Azure Open AI, C#, Semantic Kernel, Kernel Memory, Prompt Flow, and many database extensions (we need to save data somewhere!)', 7, 1, 2, 2, N'Auditorium', '2024-05-14T16:50:00', 60, NULL, NULL, 0),
(27, 1, N'Skok w DAX dla tych co znają SQL', N'Tabelaryczne modele danych tworzone w Power BI czy w Analysis Services mogą być bardzo dobrym źródłem danych dla wielu aplikacji wizualizujących czy raportujących - choćby dla starego, dobrego Reporting Services (czy raportów stronicowanych w samym Power BI). Wtedy DAX musi zostać zastosowany jako język zapytań aby wyciągnąć potrzebne dane. Czy jednak specjalista od przewracania kontekstów w miarach potrafi wykonać proste, klasyczne złączenia jak SQL?. W trakcie sesji zobaczymy jak pisać zapytania w DAX, które są odpowiednikami klauzul i opcji w SQL. Mnóstwo przykładów i praktyki.', 7, 3, 2, 10, N'Auditorium', '2024-05-15T13:40:00', 60, NULL, NULL, 0),
(28, 1, N'Open source LLM z poziomu Databricks', N'Databricks jest istotnym graczem na rynku rozwiązań analitycznych, zaproponował również swoje podejście do tematu dużych modeli językowych. W ramach sesji omówiony zostanie model Dolly, w pełni otwarte podejście do uczenia i rozpragowywania LLM.  Część demonstracyjna poświęcona będzie pokazaniu w jak prosty sposób z wykorzystaniem Databricks jesteśmy w stanie wytrenować swój własny model, nieograniczony licencjami. Dodatkowo, porównamy Dolly z alternatywnymi modelami, zarówno komercyjnymi GPT-4 czy Gemini, jak i innymi rozwiązaniami open source.', 7, 3, 2, 2, N'Room D', '2024-05-14T15:30:00', 60, NULL, NULL, 0),
(29, 1, N'Dude, what to do with the video cameras?', N'Problem, boss heard about chatGPT. In his head AI ca do anything now. So, I got the task to give the video camera feed to the "gpt", to count the cars in the parking.
OK, chatGPT has chat in name not video or vision, so that''s a hint... But AI and more precise Custom Vision or chatGPT (followed by Vision) is the solution to my problem.
This SessionDetails will show what we can do, relatively easily, with a live video feed. Demos end to end.', 7, 3, 1, 2, N'Room A', '2024-05-15T13:40:00', 60, NULL, NULL, 0),
(30, 1, N'Jak (nie)budować platformy danych w firmie, czyli fakty i mity oczami praktyków', N'"Platforma danych w chmurze jest  kluczowym elementem dla każdej firmy, która chce wykorzystać swój potencjał analityczny i konkurencyjny"

Czy, aby na pewno ?

Może jednak budowa platformy danych to przedsięwzięcie, które nie ma szansy na uzyskanie właściwego poziomu zwrotu z inwestycji? A może platformy danych to uniwersalne rozwiązania, które można łatwo powielać i przenosić z organizacji do organizacji, bo przecież to wyłącznie technologia i nie wymaga żadnej wiedzy biznesowej ani domenowej ?

Podczas sesji podzielimy się naszymi doświadczeniami i spostrzeżeniami z budowania platform danych w różnych domenach i branżach. Omówimy  wyzwania i pułapki, które napotkaliśmy, a także najlepsze praktyki i rozwiązania, które pozwoliły zrealizować projekt z sukcesem. Obalimy również niektóre mity i błędne przekonania na temat platform danych.

O naszych doświadczenia opowiemy  korzystając z rzeczywistych przykładów, ale także studium przypadków z projektów. Pokażemy, w jaki sposób platformy danych mogą umożliwić podejmowanie decyzji w oparciu o dane, innowacje i tworzenie wartości. Przedstawimy również kilka praktycznych wskazówek dotyczących uruchamiania, zarządzania i skalowania platform danych w firmie.

Do zobaczenia na naszej sesji!', 7, 3, 2, 4, NULL, NULL, NULL, NULL, NULL, 0),
(31, 1, N'Common Missing SQL Server Features Implemented as CLR Modules', N'Overview of many typical not implemented in SQL Server features that are easily implementable in CLR. We start from the one-liners to more complete task using global objects and multithreading.', 7, 1, 2, 14, N'Room B', '2024-05-15T11:40:00', 60, NULL, NULL, 0),
(32, 1, N'Databricks Ninja: Performance tuning', N'Azure Databricks dostarcza natywnie wysoce zoptymalizowane środowisko uruchomieniowe obsługujące różnorodne obciążenia w Lakehouse, od przetwarzania ETL na dużą skalę po interaktywne zapytania ad-hoc. Wiele z tych optymalizacji odbywa się automatycznie. Jednak co zrobić w momencie gdy automatyczne optymalizacje nie wystarczają a wyłącznie skalowanie klastrów nie spełnia oczekiwań? Przyjrzymy się temu jak możemy wpływać na działanie DBR za pomocą zaawansowanych ustawień konfiguracyjnych, jak działa cost-based optimizer (CBO), czym jest adaptive query execution (AQE) itp. Przeanalizujemy fizyczne plany zapytań, zwracając uwagę na możliwość ich optymalizacji.', 7, 2, 2, 5, N'Auditorium', '2024-05-15T11:40:00', 60, NULL, NULL, 0),
(33, 1, N'All levels of securing data in PowerBI', N'Podczas tej sesji opowiem w jaki sposób i na jakich poziomach można zabezpieczyć dostęp do danych w Power BI.', 7, 4, 2, 10, N'Room A', '2024-05-14T10:50:00', 60, NULL, NULL, 0),
(34, 1, N'Data Governance z Databricks Unity Catalog  - raport z wdrożenia', N'Databricks to aktualnie jedna z najpopularniejszych platform, która umożliwia tworzenie rozwiązań analizy danych opartych o koncepcje data lakehouse. Sama platforma składa się z wielu komponentów, a jednym z nich jest Unity Catalog - usługa, która zapewnia scentralizowaną kontrolę dostępu, auditing, data lineage i data discovery.
Wdrożenie, a szczególnie migracja istniejących rozwiązań, tak aby działały pod "parasolem" UC jest sporym wyzwaniem. Struktura, catalogs, volumes, migracja managed i external tables, migracja Delta Live Tables, zarządzanie uprawnieniami, data lineages to tylko niektóre z obszarów związane Unity Catalog.
W trakcie sesji pokaże w jak to wyglądało w praktyce.', 7, 1, 2, 5, N'Room D', '2024-05-15T13:40:00', 60, NULL, NULL, 0),
(35, 1, N'Old wine in a new bottle - Grupy obliczeniowe, Eksplorator modelu i widok DAX query w Power BI Deskt', N'Wcześniej dostępne wyłącznie w narzędziach zewnętrznych (np Tabular Editor, DAX Studio), funkcje te są teraz natywnie dostępne w Power BI Desktop - zwiększając możliwości analityczne, upraszczając nawigację po elementach modelu danych i umożliwiając testowanie zapytań DAX. Dołącz do nas, aby zobaczyć jak w praktyce zastosować te funckjonalności, które od teraz są dostępne w aplikacji Power BI.', 7, 3, 2, 10, N'Room A', '2024-05-14T16:50:00', 60, NULL, NULL, 0),
(36, 1, N'LLMs - lessons learned', N'Celem prezentacji będzie przedstawienie różnych projektów wykorzystujących duże modele językowe i wniosków płynących z ich wdrożenia. Podczas tej sesji będę chciał odpowiedzieć na następujące pytania:
Czy lepiej wykorzystać istniejący model takim jakim jest, dotrenowywać go czy próbować budować od podstaw?
Jak monitorować działanie dużych modeli językowych?
Jak zapewnić bezpieczeństwo rozwiązań opartych o LLMy?
Od czego zależą odpowiedzi na powyższe pytania w kontekście konkretnego projektu?
W podsumowaniu, na bazie wyciągniętych lekcji, postaram się również opisać kiedy warto stosować duże modele językowe a w jakich przypadkach zupełnie się one nie sprawdzą.', 7, 3, 2, 2, N'Room B', '2024-05-15T09:00:00', 60, NULL, NULL, 0),
(37, 1, N'Deciphering Data Architectures full-day workshop', N'This pre-conference workshop will begin by defining ''big data'' and clarifying various data architecture concepts to establish a solid foundation of understanding before delving into specific data architectures. Topics to be covered include relational data warehouses, data lakes, data marts, data virtualization, and the differences between ETL and ELT. James will then explore and compare the architectures of the Modern Data Warehouse, Data Fabric, Data Lakehouse, and Data Mesh in considerable detail, highlighting their advantages and disadvantages. While these concepts may seem appealing in theory, James will address potential concerns to consider before implementation. This workshop aims to demystify these complex topics, offering ample opportunity for questions. The content is derived from James''s book "Deciphering Data Architectures: Choosing Between a Modern Data Warehouse, Data Fabric, Data Lakehouse, and Data Mesh."', 9, 4, 1, NULL, N'Room A', '2024-05-13T08:30:00', 540, NULL, NULL, 0),
(38, 1, N'Deciphering Data Architectures (Modern Data Warehouse, Data Fabric, Data Lakehouse, Data Mesh)', N'Data fabric, data lakehouse, and data mesh have recently appeared as viable alternatives to the modern data warehouse. These new architectures have solid benefits, but they’re also surrounded by a lot of hyperbole and confusion. In this presentation I will give you a guided tour of each architecture to help you understand its pros and cons. I will also examine common data architecture concepts, including data warehouses and data lakes. You’ll learn what data lakehouses can help you achieve, and how to distinguish data mesh hype from reality. Best of all, you’ll be able to determine the most appropriate data architecture for your needs. And I’ll finish with discussing Microsoft’s version of the data mesh.', 7, 4, 1, 4, N'Auditorium', '2024-05-14T10:50:00', 60, NULL, NULL, 0),
(39, 1, N'Azure Data Platform as Code - can it be done it in less than a week?', N'The aim of this SessionDetails is to demonstrate how an enterprise-ready Azure Data Platform can be set up from scratch in days instead of months. I will present the most important lessons I''ve learned over the last year while working on such an automation framework. I''ll discuss failures, dead ends, drawn conclusions, and the approach we ultimately developed and successfully implemented.

During this one-hour session, I''ll address, among other topics:
- Landing Zones, Cloud Adoption & Cloud Scale Analytics Frameworks - why should the ''Data people'' also understand this stuff?
- Automation from day one & Everything as Code.
- Networking, Security, Monitoring.
- Why a bunch of accelerators work better than an out-of-the-box solution.
- Project timeline, proper analysis and collaboration with the client - the keys to success.', 7, 1, 2, 5, N'Room B', '2024-05-14T14:10:00', 60, NULL, NULL, 0),
(40, 1, N'Co SQL deweloper powinien wiedzieć o Delta Lake', N'With the increasing popularity of lakehouses and the Delta format, developers are moving away from traditional databases towards file-based formats. In this session, we''ll delve into what SQL developers need to understand about Delta Lake as they navigate this transition.

Explore the fundamentals of Delta Lake, uncovering its distinctive features and learning how SQL developers can utilize it in ETL processes. We''ll cover essential aspects like ACID compliance, schema evolution, time travel, and provide insights into what''s happening behind the scenes with files when executing basic SQL read/write statements.

Whether you''re an experienced SQL developer or just starting out, this SessionDetails offers a straightforward guide to enhance your skills in working with Delta Lake in the upcoming era of lakehouses.', 7, 1, 2, 14, N'Room C', '2024-05-15T13:40:00', 60, NULL, NULL, 0),
(41, 1, N'Co naprawdę potrafią nowe wizualizacje karty oraz fragmentora w Power BI?', N'W ciągu ostatnich kilku miesięcy Microsoft intensywnie pracował nad zwiększeniem możliwości wbudowanych wizualizacji karty oraz fragmentatora (filtra) w Power BI. W temacie działo się sporo i już być może obiły Ci się o uszy use-casy pokazujące te nowe funkcje w akcji. Ale jak zabrać się za wykorzystanie tych możliwości w codziennej pracy? Od czego zacząć i co można osiągnąć bez wyrywania sobie włosów z głowy?

Podczas tej sesji przeprowadzę Cię przez aktualne funkcjonalności nowej karty oraz fragmentatora. Demonstracje oprzemy na przykładach z życia wziętych, które wspólnie zbudujemy podczas sesji. Opowiem Ci, w których scenariuszach warto skorzystać z nowych funkcjonalności oraz dlaczego, a kiedy lepiej pozostać przy sprawdzonych i utartych metodach.

Po tej sesji:
- będziesz znał(a) aktualne możliwości nowych wizualizacji karty oraz fragmentatora.
- będziesz w stanie zidentyfikować scenariusze, w których skorzystanie z tych funkcjonalności przyniesie wymierne korzyści.
- będziesz wyposażony(a) w techniczną wiedzę potrzebną do zaimplementowania nowej wizualizacji karty i fragmentatora w swoich raportach od dosłownie następnego dnia.

Sesja skierowana jest do twórców raportów w Power BI, którzy mają podstawowe doświadczenie w pracy z narzędziem oraz mieli okazję do stworzenia kilku typów filtrów oraz kart w swoich raportach.', 7, 3, 2, 10, N'Room A', '2024-05-15T15:00:00', 60, NULL, NULL, 0),
(42, 1, N'Medalion Architecture (Bronze, Silver, Gold) decoded in practice', N'In the internet, blogs, and documentation, there are often some information about the concept of Data Lakehouse and Medalion Architecture. Unfortunately, there is frequently a lack of precise and straightforward explanation of what these layers are. The aim of this SessionDetails is to clarify what a Lakehouse is, what the layers of the Medalion architecture are, the ''rules'' that should govern each layer, the purpose and goal of each layer, and potential deviations from the rules. With this knowledge, you can avoid mistakes in designing a Lakehouse and ensure proper order in your data.', 7, 3, 1, 4, N'Room B', '2024-05-15T10:20:00', 60, NULL, NULL, 0),
(43, 1, N'Wykorzystanie Microsoft Fabric w obszarze przetwarzania i analizy danych w praktyce', N'Zapraszamy na ekskluzywny warsztat, który skupi się na praktycznym wykorzystaniu potencjału Microsoft Fabric w projektach przetwarzania i analizy danych. Podczas tego intensywnego jednodniowego wydarzenia, uczestnicy będą mieli okazję zanurzyć się w fascynującym świecie nowoczesnych technologii danych. Niezależnie czy planujesz rozwój lub rozpoczynasz budowę systemu, który łączy potęgę przetwarzania Big Data ze stabilnością hurtowni danych, a może rozważasz wzbogacenie swoich danych dzięki GenAI – ten warsztat jest dla Ciebie.

Podczas 8h intensywnej aktywności uczestnicy będą mieli niepowtarzalną okazję do pracy ramię w ramię z ekspertami w dziedzinie przetwarzania i analizy danych. Prowadzący, którzy są uznawani za liderów branży, przekażą swoją wiedzę i doświadczenie. Sesje będą obejmować teoretyczne wprowadzenie do kluczowych koncepcji, ale przede wszystkim praktyczne ćwiczenia, które umożliwią uczestnikom samodzielne skonfigurowanie i uruchomienie rozwiązania. Dzięki temu warsztatowi zdobędziesz nie tylko cenne umiejętności, ale także przekonasz się, jak Microsoft Fabric może przyspieszyć  transformację Twojej organizacji.

Cel Warsztatu:

Budowa Rozwiązania End-to-End: Uczestnicy będą pracować z ekspertami w zakresie przetwarzania danych, aby zbudować kompleksowe rozwiązanie oparte na Microsoft Fabric – od  struktury danych po wdrożenie i analizę wyników.

 - Łatwość, Elastyczność i Szybkość Działania: Warsztat skoncentruje się na wykorzystaniu łatwych w użyciu narzędzi Microsoft Fabric, ukazując elastyczność i szybkość, jaką można osiągnąć przy projektowaniu, wdrażaniu i skalowaniu rozwiązań danych.
- Charytatywny Cel Warsztatu: Ciesz się nie tylko rozwijaniem umiejętności, ale również uczestnictwem w akcji charytatywnej! Decyzję o wyborze organizacji charytatywnej, na którą zostaną przekazane środki zebrane podczas warsztatu, podejmą sami uczestnicy.
- Wymagane Umiejętności: Podstawowa wiedza z zakresu przetwarzania danych i analizy danych.

Korzyści dla Uczestników:

·       Praktyczne doświadczenie w budowie rozwiązania z wykorzystaniem Microsoft Fabric.
·       Spotkanie z wiodącymi specjalistami w dziedzinie przetwarzania i analizy danych.
·       Możliwość wsparcia celu charytatywnego poprzez udział w warsztatach.

Miejsca są ograniczone, aby zapewnić najwyższą jakość interakcji i nauki, więc nie zwlekaj z rejestracją. Dołącz do naszych prowadzących i odkryj, jak Microsoft Fabric może stać się fundamentem innowacyjnych rozwiązań w Twojej organizacji!

Zarejestruj się już dziś i bądź częścią wyjątkowego wydarzenia, które łączy naukę z pomocą na rzecz wspólnej dobrej sprawy.', 9, 3, 2, NULL, N'Room B', '2024-05-13T08:30:00', 540, NULL, NULL, 0),
(44, 1, N'Microsoft Fabric Semantic Link w zastosowaniach praktycznych', N'W trakcie sesji pokażę, w jaki sposób wykorzystać Semantic Link - czyli połączenie modelu semantycznego oraz Data Science w Microsoft Fabric. Często w modelu semantycznym użyte są kalkulacje, które należałoby wykorzystać w procesie uczenia maszynowego. Bez połączenia modelu semantycznego z notatnikami trzeba jednak taką logikę powielać, co niekorzystnie wpływa na proces wytwarzania i utrzymania kodu. Semantic Link pozwala zapobiegać tym sytuacjom.', 7, 3, 2, 10, NULL, NULL, NULL, NULL, NULL, 0),
(45, 1, N'What''s new in Power Query in Power BI, Fabric and Excel?', N'Power Query is the self-service data transformation tool in Power BI Desktop, Fabric Dataflows and Excel. In this SessionDetails you''ll find out about new user interface features, new M functions, new data sources and data destinations, and lots more new functionality that has been added in the last year.', 7, 3, 1, 8, N'Auditorium', '2024-05-14T15:30:00', 60, NULL, NULL, 0),
(46, 1, N'Microsoft Fabric CI/CD - What is there and what is coming?', N'Microsoft Fabric is the new kid in town for the full Data & Analytics stack in Azure, all in one Software as a Service offering. Combining workloads for Data Integration, Data Engineering, Data Science, Analytics and Reporting is meant to streamline and simplify managing the implementation and maintenance of your Data & Analytics projects.
But to achieve this goal, support for Dev and Data Ops is absolutely necessary. This was one of the gaps often addressed also for existing offerings like Power BI and Synapse, where support was either not there at all or insufficient.

This demo-rich SessionDetails will deliver an overview of the features Microsoft Fabric offers to support a clean and efficient CI/CD process. Which workloads and items are supported, how can best practices be achieved and which gaps can still be perceived.

We''d love to experience an interactive SessionDetails by not only sharing our point of view, but  by discussing advantages and disadvantages with you and learning about your feedback and perception.', 7, 3, 1, 8, N'Room B', '2024-05-14T16:50:00', 60, NULL, NULL, 0),
(47, 1, N'Practical Azure DevOps for Data Platform professionals', N'In this customized SessionDetails Data Platform professionals will be prepared to use Azure DevOps in the workplace. Since there is more demand for Data Platform professionals to have Azure DevOps knowledge.

Brought to you by two MVP’s who both have extensive Azure DevOps experience in the workplace. One of whom is a former Product Owner and the other known for contributing to open-source solutions

During the SessionDetails we will cover how to use all the default services within Azure DevOps in the workplace. We will also explain some jargon and answer questions along the way.

A lot of examples are based on SQL Server. However, a lot of the topics covered can also be used with other services available within the Microsoft Data Platform. For example, Azure Synapse Analytics.

Topics we will cover along the way include how to:

• Customize Azure Boards to manage your work items on a daily basis.
• Use Power BI with Azure DevOps to track work progress.
• Work with Git, including branch strategies.
• Implement CI/CD for different types of deployments.
• Perform unit tests for SQL Server databases both on-premises and in the cloud.
• Manage test plans without a single spreadsheet.
• Store artifacts within Azure DevOps.
• Make the most out of extensions.', 7, 3, 1, 14, N'Room C', '2024-05-14T14:10:00', 60, NULL, NULL, 0),
(48, 1, N'Jak użyć dbt w Microsoft Fabric', N'Z dbt spotykamy się w praktycznie wszędzie tam, gdzie należy zaprojektować transformacje danych dla rozwiązań analitycznych (ale nie tylko). Dbt pozwala zespołom szybko wdrażać kod zgodnie z najlepszymi praktykami inżynierii oprogramowania. Tyle opisu marketingowego zaczerpniętego od producenta.

W trakcie sesji pokażemy, jak skonfigurować i użyć dbt w połączeniu  z Microsoft Fabric – dla Lakehouse oraz Data Warehouse.

Nie zabraknie także przykładów pokazujących, jak dbt wspiera testy kodu oraz pracę deweloperów tworzących rozwiązania analityczne', 7, 3, 2, 5, N'Room D', '2024-05-14T12:10:00', 60, NULL, NULL, 0),
(49, 1, N'Holistyczne podejście do jakości danych', N'Temat jakości danych to nie tylko same dane ale również problemy z wiązane z jakością ich przetwarzania co wpływa na to, jak nasza hurtownia danych jest postrzegana przez użytkowników.
Na sesji przedstawię problem jakości danych z różnych punktów widzenia oraz możliwe podejścia do radzenia siebie z poszczególnymi obszarami jakości danych.', 7, 3, 2, 5, N'Room D', '2024-05-15T09:00:00', 60, NULL, NULL, 0),
(50, 1, N'Spark SQL dla deweloperów SQL Server', N'W języku T-SQL czujesz się jak ryba w wodzie, ale notatniki z kodem python, SparkSQL są dla Ciebie cały czas obce?
Ta sesja jest dla Ciebie! Przyjdź aby dowiedzieć się jak przetwarzać dane w ramkach danych i zastosować aktualne doświadczenie i umiejętności do pisania zapytań w SparkSQL.

Zdecydowana większość sesji będzie oparta o praktyczne przykłady, w pełni realizowane w ramach w Microsoft Fabric. Jeśli chcesz w trakcie sesji wykonywać przykłady samodzielnie - przyjdź na sesję z własnym komputerem, a wcześniej przygotuj bezpłatną demonstracyjną wersję Fabric. Jak to zrobić dowiesz się z poniższego filmu:
https://youtu.be/9FXwqwAcTYM', 7, 3, 2, 14, N'Room A', '2024-05-14T15:30:00', 60, NULL, NULL, 0),
(51, 1, N'Rozproszony Monolit: Wyzwania i Strategie w Dzieleniu Baz Danych dla Mikrousług', N'W obliczu dynamicznego rozwoju technologii i rosnącego znaczenia mikrousług, konieczne staje się dostosowanie tradycyjnych relacyjnych baz danych do nowoczesnych wymagań biznesowych i technologicznych. W procesie migracji architektury aplikacji z monolitycznej do mikrousług często zaniedbuje się istotną warstwę danych. Architekci skupiają się na właściwym zaprojektowaniu serwisów, podczas gdy oryginalne bazy danych pozostają niezmienione - nadal funkcjonują jako jednostkowy, wielki monolit. Efektem tego jest paradoksalne połączenie monolitu i mikrousług w postaci rozproszonego monolitu.

W trakcie tej sesji przedstawię konkretne i sprawdzone techniki dzielenia relacyjnych baz danych na mniejsze jednostki. Omówimy kluczowe aspekty związane z migracją danych, dbając o to, aby wprowadzane zmiany były transparentne dla aplikacji i nie miały negatywnego wpływu na dostępność naszego systemu. Przyjrzymy się również kwestiom związanym z utrzymaniem spójności danych oraz strategiom zapewniającym ciągłość operacyjną w trakcie procesu transformacji. Celem sesji jest dostarczenie praktycznych wskazówek, które pomogą uczestnikom skutecznie zintegrować strategie dzielenia baz danych w kontekście mikrousług w ramach ich własnych projektów.', 7, 3, 2, 4, N'Room B', '2024-05-14T12:10:00', 60, NULL, NULL, 0),
(52, 1, N'Designing and implementing sales strategies in Power BI', N'Na przykładzie wdrożenia strategii cenowych produktów pokażę zalety i wady użycia merge/append queries vs relacje aktywne/nieaktyne. Różnice w projektowaniu modeli, różnice w DAX oraz troubleshooting.', 7, 3, 2, 10, N'Room C', '2024-05-15T10:20:00', 60, NULL, NULL, 0),
(53, 1, N'Chmura to nie tylko inna serwerownia. Dobre praktyki przy przenoszeniu danych do chmury.', N'Usługi w chmurze Microsoft Azure to nie tylko inna serwerownia – poznaj metodologie, które pozwolą odnieść sukces przy migracji, modernizacji, innowacji czy relokacja aplikacji wraz z danymi do chmury. W czasie sesji pokaże, jak wykorzystać istniejące funkcjonalności platformy danych opartych o Infrastrukturę jako usługa (IaaS), a także usług opartych o Platformę jako usługę (PaaS). W jakich sytuacja wybrać IaaS, a kiedy PaaS? Czy chmura zawszę jest tańsza? To tylko kilka pytań, na które znajdziecie odpowiedź na tej sesji. Nie braknie także przykładów jak wykorzystać partycjonowanie danych, nadmiarowość, pozimowy spójności czy planowanie przywrócenia po awarii na platformie danych.', 7, 3, 2, 5, N'Room B', '2024-05-15T15:00:00', 60, NULL, NULL, 0),
(54, 1, N'Microsoft Fabric dla programistów SQL', N'Uwielbiamy SQL. Napisaliśmy obaj duuużo kodu SQL, rozwiązywaliśmy problemy w SQL, a nawet zdarzało nam się myśleć w SQL w naszych kerierach zawodowych. Teraz, dzięki Microsoft Fabric, najnowszemu challengerowi wśród platform do analizy danych, mamy wrażenie, że nasza znajomość SQL budowana przez ostatnie dwie dekady może być bardzo przydatna. Jeśli tak jak my uwielbiasz SQL, przyjdź na tę sesję, a pokażemy Ci (z całą serią demo na żywo!), jak możesz wykorzystać znajomość SQL w Microsoft Fabric oraz w jakim kierunku rozwijać kompetencje, by efektywniej pracować z danymi i analityką w Fabric.', 7, 3, 2, 8, N'Auditorium', '2024-05-15T15:00:00', 60, NULL, NULL, 0),
(55, 1, N'Prototypowanie i zbieranie wymagań raportowych', N'Identyfikacja potrzeb oraz wymagań użytkowników końcowych jest nieodłączną częścią wytwarzania produktów i kiedy ich funkcjonalności pokrywają te potrzeby to zwiększamy szanse na adopcję wraz z zadowoleniem "konsumentów". w pierwszej części sesji przejdziemy przez scenariusz identyfikacji wymagań w rozwiązaniach raportowych w formie backlogu, a w drugiej - zrealizujemy próbę stworzenia szkicu dashboardu na bazie zgromadzonych informacji. Po tej sesji dowiesz się jakie pytania zadajemy użytkownikom, jak je analizujemy oraz jak je przełożyć na wizualną warstwę naszych raportów.', 7, 4, 2, 10, N'Room A', '2024-05-15T09:00:00', 60, NULL, NULL, 0),
(56, 1, N'Analysis Services at Scale', N'Sesja skupi się na podzielieniu się doświadczeniami w pracy z dużymi modelami danych w chmurze i wyzwaniami jakie za tym stoją. Mając czasami setki GB dancyh modele tabelaryczne wymagają poszukiwania optymalizacji w każdym mozliwym zakamarku, aby nie generować niepotrzebnych kosztów. Import odpowiednich typów kolumn, optymalizacja miar i zarządzanie importem danych przekłada się na koszt całego rozwiązania, co ma coraz większe znaczenie dla użytkowników końcowych. W trakcie sesji pokażę też live demo optymalizacji miar na potrzeby raportu Power BI i jak to się wpływa na wydajność całej platfromy.', 7, 1, 2, 5, N'Room D', '2024-05-14T14:10:00', 60, NULL, NULL, 0),
(57, 1, N'Challenges in managing Azure-based Data Platform', N'Volvo has been developing and running a cloud data platform for the last few years. We want to share best practices, surprises, and traps we discovered during the design, development, and operation phases. We will touch on the elements of development, monitoring, design, and cost management. We invite you to come along and learn from our journey.', 7, 3, 1, 5, N'Room C', '2024-05-15T11:40:00', 60, NULL, NULL, 0),
(58, 1, N'Monitorowanie i optymalizacja Azure SQL - długa droga do Database Watcher', N'Database Watcher – czyli najnowsze rozwiązanie Microsoftu do monitorowania i optymalizacji Azure SQL pojawił się całkiem niedawno na rynku, choć tak naprawdę jest to już trzecie podejście do wdrożenia tej funkcjonalności.

Wprowadzenie Azure SQL przez Microsoft było sporym przełomem dla świata administratorów i developerów baz danych. Ze względu na silnik działający w chmurze, dużo elementów konserwacji i konfiguracji zostało przed nami ukrytych, oferując nam w zamian zupełnie nowe sposoby na optymalizacje wydajności bazy danych. Nie ma co się oszukiwać - baza danych PaaS, zarządzana przez Azure, nadal wymaga troski i uwagi, aby działać z wysoką wydajnością i bez niepotrzebnych kosztów. Dlatego takie rozwiązanie jak Database Watcher przydaje się nie tylko DBA ale może wspierać pracę dev/dataOpsów jak i zwykłych developerów czy analityków, np. aby kontrolować plany wykonania kwerend czy też minimalizować obciążenie logu transakcyjnego.

Poprzednicy Database Watcher, czyli: Azure SQL Analytics i SQL Insights nigdy nie wyszli z preview, więc warto przyjrzeć się jak najnowsze rozwiązanie prezentuje się w boju i jakie są jego rokowania.', 7, 3, 2, 5, N'Room C', '2024-05-14T15:30:00', 60, NULL, NULL, 0),
(59, 2, N'Wykorzystanie JSON w SQL Server: Zaawansowane funkcje i praktyczne zastosowania', N'Podczas sesji zostaną omówione najnowsze usprawnienia w obsłudze JSON w SQL Server, w tym natywny typ danych JSON wprowadzony w 2024 roku, który optymalizuje przechowywanie i przetwarzanie danych JSON. Zostaną szczegółowo zaprezentowane następujące funkcje:

Walidacja JSON za pomocą ISJSON() i JSON_PATH_EXISTS(), pozwalająca na sprawdzanie poprawności i struktury dokumentów JSON.

Ekstrakcja danych przy użyciu JSON_VALUE() i JSON_QUERY(), umożliwiająca łatwe wyciąganie wartości i fragmentów JSON.

Modyfikacja JSON z wykorzystaniem JSON_MODIFY(), pozwalająca na zmiany w strukturze dokumentu bez potrzeby jego całkowitej rekonstrukcji.

Agregacja danych JSON dzięki nowym funkcjom JSON_OBJECTAGG() i JSON_ARRAYAGG(), umożliwiająca tworzenie złożonych dokumentów JSON na podstawie danych relacyjnych.

Transformacja danych relacyjnych na JSON z użyciem operatora OPENJSON(), ułatwiająca przekształcanie danych relacyjnych w struktury JSON.

W trakcie sesji pokazane zostaną również przykłady łączenia danych relacyjnych z JSON oraz sposoby efektywnego przetwarzania zapytań na danych półstrukturalnych.', 7, 3, 2, 14, N'Auditorium', '2025-05-14T11:40:00', 60, NULL, NULL, 0),
(60, 2, N'Data API Builder: Manage your database with REST API', N'Imagine pulling data from your database with a simple REST call instead of launching SQL Management Studio. With Azure Data API Builder (DAB) you can do just that. One JSON file tells DAB which tables to expose, and in seconds it spins up both REST and GraphQL endpoints. Swagger UI and an OpenAPI spec appear automatically. The same file lets you set roles, filters, and row-level security— with no code required. 

In this SessionDetails I will show what comes “out of the box,” how to stand it up in minutes, and what can go wrong. It will be 60 minutes walk through DAB from four angles: a casual user, a hands-on developer, a cautious admin, and a data architect.', 7, 4, 1, 14, N'Room B', '2025-05-14T09:00:00', 60, NULL, NULL, 0),
(61, 2, N'How to properly handle LOB data in SQL Server', N'Larger-than-life data, often referred to as Large Object (LOB) data, such as documents, images, audio, and video, has become an integral part of modern database systems. Microsoft SQL Server offers powerful features and strategies for effectively managing LOB data. This SessionDetails will take you on a journey through the intricate world of LOB data in SQL Server, offering insights, best practices, and practical techniques to streamline your data management strategies.', 7, 1, 1, 14, N'Room C', '2025-05-13T12:10:00', 60, NULL, NULL, 0),
(62, 2, N'Going Live with dbt-core on Databricks and MS Fabric', N'During this session, we''ll dive into building a production-ready flow for dbt projects on Databricks and Microsoft Fabric. We''ll start with a brief introduction to what Analytics Engineering is, why the ELT approach is dominating platforms like Databricks, Snowflake, and MS Fabric right now, and how dbt helps us design the transformation layer.

After a quick demo, we’ll move on to the main part of the session, focusing on transitioning our locally running projects to production environments. We’ll discuss this topic using both Databricks and MS Fabric as examples, presenting several scenarios for tackling this challenge. We''ll concentrate on key stages of the process, including:

- Automated deployment using CI/CD pipelines along with testing
- Orchestration (including ADF, Fabric Pipelines, Airflow, Workflows)
- Compute resources needed for processing (Databricks Clusters, Fabric Notebooks, Docker + ACR/ACI)
- Authentication using service principals
- Automatic generation and hosting of project documentation in Azure

Note: Besides introducing dbt, we won''t go into the details of specific features during the session; our focus will be on operationalizing the processes.', 7, 1, 2, 14, N'Auditorium', '2025-05-14T15:00:00', 60, NULL, NULL, 0),
(63, 2, N'Tips & Tricks z migracji dużej organizacji do Databricks Unity Catalog', N'Każdy klient na świecie obecnie boryka sie z takimi samymi wyzwaniami pracując z platformą Databricks, czyli migracja do Unity Catalog. Na tej sesji opowiem jak taką migrację zrobiliśmy u swojego klienta, nad czym spędzilismy najwięcej czasu, na czym sie potknęliśmy, jakie narzędzia użyliśmy, co się nam sprawdziło. Czyli podsumujemy 8 miesięcy migracji w 60 minut.', 7, 1, 2, 4, N'Auditorium', '2025-05-13T16:50:00', 60, NULL, NULL, 0),
(64, 2, N'Build A Fabric Real-time Intelligence Solution in One Day', N'Real-Time Intelligence in Fabric is designed to enable organisations to bring their streaming, high-granularity, time-sensitive event data into Fabric and build various analytical, visual and action oriented data applications and experiences with it. In this session, you will learn about what Fabric Real-time Intelligence is meant for and will then build an end-to-end solution using streaming data.

This SessionDetails will get you hands-on with Real-Time Hub, Eventstream, Eventhouse, Data Activator, Real-time Dashboards, Power BI, and Copilot with combination of Microsoft MVPs and Fabric product group members to guide you along the way.

The end-to-end solution we build together will encompass:
• Discovering and cataloging your data streams using Real-Time Hub
• Connecting to streaming data from various sources around the world
• Cleaning, normalizing, preparing data for superior query time experiences
• Leveraging Copilot to discover streaming data
• Low-code/no-code experiences for data exploration
• Developing dashboards', 9, 4, 1, 8, N'Room E (351)', '2025-05-12T08:30:00', 540, NULL, NULL, 0),
(65, 2, N'Beyond the Podium: A Data Architect''s Guide to Lakehouse Architectures in Microsoft Fabric', N'Ever wondered how the Gold, Silver, and Bronze architecture of a Lakehouse truly fits into organizations of different skills and sizes? Just like in "The Wizard of Oz," where Dorothy discovers the real wizard behind the curtain, this SessionDetails uncovers the reality of Lakehouse structures across various company sizes.
Join us to explore who implements what and what organizational adjustments are necessary. Discover the challenges that, while not perfect, are currently shaped by Microsoft Fabric''s capabilities.
In this session, we provide clarity from data ingestion to layer responsibilities, ensuring data architects have a comprehensive understanding of how to navigate and refine these architectures.
By the end of this session, you will:
- Understand the practical application of Lakehouse architecture in diverse business landscapes.
- Identify organizational adjustments needed for seamless integration.
- Recognize current limitations in Microsoft Fabric and how to work within them.
Whether you''re a data architect, engineer, or manager, this SessionDetails will equip you with the insights you need to optimize your Lakehouse strategy for your organization. Get ready for a journey from conceptual maps to actual organizational implementation.', 7, 1, 1, 4, N'Room C', '2025-05-14T11:40:00', 60, NULL, NULL, 0),
(66, 2, N'Execution Plans in Depth', N'For troubleshooting slow queries, looking at the execution plan is a good starting point. But sometimes, just looking at the plan does not help. Sometimes you need to dig deeper.

In this full-day pre-con session, you will learn everything you need to be take your understanding of execution plans to the next level. For almost every operator you can encounter in an execution plan, we will look at the inner workings, and look at properties that can affect their performance. We will also look at how operators in a plan interact with and affect each other.

Aside from explaining all of the common operators, we will also touch on several operators that were introduced or modified in the newer versions of SQL Server.

In short: After this pre-con, you will be better prepared to look at execution plans, find the spot where it hurts, and then rewrite your query to get a faster execution plan.

If you have seen some execution plans but feel you need to bring your understanding to the next level, then this pre-con is for you.', 9, 1, 1, 14, N'Room A', '2025-05-12T08:30:00', 540, NULL, NULL, 0),
(67, 2, N'Approximate functions: How do they work?', N'Sometimes, a close approximation is good enough. And sometimes, a close approximation is a lot faster. Microsoft has introduced “Approximate Query Processing” (the APPROX_COUNT_DISTINCT and APPROX_PERCENTILE functions) to give you exactly that benefit when you don''t need exact answers.

But do you have a good response when you propose to use this function and your manager asks you to explain how they work first? Or is your only option to claim "black magic by smart Microsoft engineers"?

The algorithms used are not a secret. HyperLogLog and KLL Sketch. And now you most likely know exactly as much as you already knew before. And when you google for those terms ... you end up with a headache.

Time to join me for a SessionDetails where I explain the black magic in the simplest possible terms, so that you can then explain it to your manager!', 7, 2, 1, 14, N'Room A', '2025-05-14T15:00:00', 60, NULL, NULL, 0),
(68, 2, N'Auditing Azure SQL Database with Log Analytics- How, where and what', N'If you have built an Azure SQL database you will have probably seen the Auditing option in the Portal.
But what exactly does this give us ?

In this presentation we will look at Auditing in Azure SQL database.
How to correctly configure auditing.
Setting up the necessary Diagnostics
Viewing the data in Azure Analytics.
Introduction to the Kusto Query Language
Azure SQL Analytics to monitor performance  (still in Preview after 4 years)
Azure SQL Security Insights
Putting it all together with Azure Workbooks
And finally what does data watcher give us ?', 7, 4, 1, 11, N'Room D', '2025-05-14T10:20:00', 60, NULL, NULL, 0),
(69, 2, N'Answering Questions Using Extended Events', N'Sure, you can use Extended Events within SQL Server to capture query performance metrics. However, is that all you really want?

For most people, they want to know the answers to questions. Which query is using the most CPU? Why did that statement recompile? Is Query Store having problems on my database? These and many other questions can be easily answered through the use of Extended Events.

This SessionDetails explores how to use Extended Events to do more than simply capture performance metrics, although we''ll do that too. You can learn to put Extended Events to work in your own systems to answer your own questions based on the information provided here. We''ll go beyond simply capturing events and talk about how to combine them through Causality Tracking. We''ll also consume the data in ways beyond simply capturing to a file, such as through histograms.

You will better be able to put Extended Events to work helping you answer your questions.', 7, 3, 1, 11, N'Room A', '2025-05-14T09:00:00', 60, NULL, NULL, 0),
(70, 2, N'Azure Data Factory Monitoring: You’re Doing It Wrong', N'Monitoring Azure Data Factory (ADF) can be challenging, especially if you’re sticking to out-of-the-box setups or traditional monitoring tools. In this session, we''ll uncover the common pitfalls and missed opportunities in ADF monitoring and explore how to transform your approach. I’ll dive into advanced techniques like leveraging Azure Monitor, user properties, integrating with Log Analytics, integrating with custom dashboards such as Grafana dashboards, and creating custom KQL queries for deeper insights. Attendees will walk away with practical strategies to gain better visibility into pipeline performance, troubleshoot issues faster, and ensure smoother operations across complex data workflows. Stop relying on minimal metrics—it''s time to level up your ADF monitoring game!', 7, 1, 1, 5, N'Room A', '2025-05-14T11:40:00', 60, NULL, NULL, 0),
(71, 2, N'Learn how to promote and reuse key metrics from your semantic models across your organization', N'Have you ever found yourself in a situation where you saw the “same” measure in two different reports, showing conflicting values? Or a situation where you wanted to create a measure to use in your own report, but were uncertain whether that measure already existed in another model?  It’s common for organizations to have multiple semantic models with overlapping content, which can often become difficult to manage and maintain data quality in an organization when duplicative measures in so many models get created. But what if you could centrally manage measures and reuse them across multiple semantic models? In this session, we’ll explore the new Metrics Hub and show how it can enhance the discoverability and reuse of Metrics derived from measures in enterprise semantic models.', 7, 3, 1, 10, N'Room D', '2025-05-14T11:40:00', 60, NULL, NULL, 0),
(72, 2, N'Building a Fortress of Your Fabric Environment: Security Best Practices for Data Engineers', N'Microsoft Fabric is a powerful, all-in-one analytics solution for enterprises that integrates data movement, real-time analytics, data science, and business intelligence. As data engineers, securing this environment is essential to protect sensitive data while maintaining efficiency. Microsoft Fabric, as a SaaS platform, offers robust built-in security features that simplify this task.

In this session, we’ll dive into the key security features and practices you can leverage to strengthen your Fabric environment. We’ll discuss the latest available security options, including private links for inbound access to Fabric and its artifacts, Trusted Workspace, Managed VNets with outbound Private Endpoints for external resources and how users can authenticate, ensuring your data remains secure.

By the end of this session, you’ll have a comprehensive understanding of the out-of-the-box security features of Microsoft Fabric, as well as the best practices to implement for maintaining a resilient and secure data environment.

This knowledge will help your organization safeguard its data, enhance operational efficiency, and build a secure foundation for future growth.
After this SessionDetails you are ready to build your own Fortress.', 7, 1, 1, 8, N'Room C', '2025-05-14T09:00:00', 60, NULL, NULL, 0),
(73, 2, N'Spark w Microsoft Azure – Wszystko, co chcesz wiedzieć, a boisz się zapytać!', N'Apache Spark to niezastąpione narzędzie dla analityków i inżynierów danych, oferujące potężne możliwości przetwarzania dużych zbiorów danych. Microsoft Azure, wraz z rozwiązaniem Microsoft Fabric, zyskuje na popularności jako platforma chmurowa do złożonej analizy Big Data. Jak jednak w pełni wykorzystać Spark na Azure? Co wybrać: Databricks, HDInsight, Synapse Analytics, Spark na maszynach wirtualnych lub AKS, czy Spark w Microsoft Fabric?

W tej sesji, krok po kroku, omówimy, na podstawie jakich kryteriów wybrać sposób korzystania z Apache Spark na platformie Azure, aby uzyskać maksymalną wydajność, elastyczność oraz optymalne koszty. Dowiesz się, jak skonfigurować klastry, zintegrować Spark z usługami do przechowywania danych i Machine Learning oraz z jakich narzędzi korzystać, aby osiągnąć najwyższą efektywność w przetwarzaniu dużych zbiorów danych. Sesja zawiera również studium przypadku – na praktycznych przykładach pokażemy, jak dobrać najlepsze rozwiązanie do Twojego konkretnego scenariusza biznesowego.', 7, 1, 2, 5, N'Auditorium', '2025-05-14T10:20:00', 60, NULL, NULL, 0),
(74, 2, N'DAX w służbie User Experience w Power BI', N'Czy byłeś w takiej sytuacji? Zadbałeś o zebranie wymagań biznesowych, zaprojektowałeś wydajne potoki wczytywania danych do modelu w schemacie gwiazdy, napisałeś zaawansowane formuły w DAXie i przygotowałeś piękne wizualizacje. I cały ten wysiłek po to, żeby usłyszeć “meeeh” od klienta, gdyż nie był on w stanie wyraźnie zobaczyć etykietki danych na najwyższej kolumnie na wykresie kolumnowym. Albo dlatego, że klient wybrał taki produkt na filtrze, który nie jest sprzedawany w bieżąco wybranym kraju i otrzymał w wyniku tego zupełnie pustą stronę raportu.
Ja też spotkałem się z takimi sytuacjami. O ile dodanie tła do etykiet danych rozwiązało pierwszy problem, a przynajmniej tak się zdawało, to w końcu zrozumiałem, że musi istnieć lepsze rozwiązanie takiego wyzwania. Tak samo musiało istnieć lepsze rozwiązanie niż włączenie relacji dwukierunkowej, by rozwiązać drugą opisaną sytuację.
Podczas swoich przygód z Power BI spotkałem się z wieloma takimi wyzwaniami. Miały one dwa punkty wspólne: znacznie pogarszały User Experience oraz mogły zostać rozwiązane kilkoma sprytnymi linijkami DAXa. Podczas tej sesji opowiem o wybranych przypadkach tego typu oraz ich rozwiązaniach, by pomóc Ci dopiąć Twój raport Power BI na ostatni guzik.

Po tej sesji będziesz w stanie:
•_x0009_Polepszyć skalowanie wykresów i zsynchronizować ich skalę.
•_x0009_Tworzyć szyte na miarę etykiety danych na wykresach na kilka sposobów,
•_x0009_Zawężać opcje widoczne na fragmentatorze do tylko tych dostępnych w bieżącym kontekście bez potrzeby użycia relacji dwukierunkowej.', 7, 1, 2, 10, N'Room A', '2025-05-14T10:20:00', 60, NULL, NULL, 0),
(75, 2, N'How Power BI Pros actually use AI', N'AI has been around for several years, but integrating AI into Power BI development can still seem like a challenge. This SessionDetails delves into practical applications of Large Language Models (LLMs) to streamline and enhance Power BI workflows. Attendees will gain insights into:

-Bulk measure creation.
-Reusing existing components.
-No-code SVGs to enhance tables.
-DAX documentation for better maintainability.
-Making mock datasets for testing and prototyping.
-The limitations of AI usage.

This SessionDetails is tailored for Power BI professionals seeking to use AI tools to optimize their development processes and deliver more efficient, insightful reports.', 7, 3, 1, 10, N'Room B', '2025-05-14T15:00:00', 60, NULL, NULL, 0),
(76, 2, N'AI/ML na początek - Twoja mapa startowa w świecie sztucznej inteligencji', N'Sztuczna inteligencja i uczenie maszynowe to technologie, które stały się fundamentem nowoczesnego świata IT. Choć mnogość dostępnych materiałów, frameworków i gotowych rozwiązań sugeruje, że nigdy nie było łatwiej zacząć, rzeczywistość często okazuje się bardziej skomplikowana. Przytłaczająca liczba opcji potrafi utrudnić wybór odpowiedniego kierunku na starcie.

Podczas tej sesji, w formule debaty, przyjrzymy się różnym podejściom do rozpoczęcia pracy z AI/ML. Omówimy kluczowe narzędzia i zasoby, które ułatwią postawienie pierwszych kroków w tej dziedzinie. Zastanowimy się, jak odróżnić rozwiązania prowadzące do celu od tych, które mogą zmylić i spowolnić rozwój.

Na konkretnych, życiowych przykładach pokażemy najczęstsze błędy i wyzwania, z jakimi mierzą się początkujący. Podzielimy się sprawdzonymi sposobami ich unikania, aby start w AI/ML był skuteczny, inspirujący i pełen nowych możliwości.

Wyjdziesz z tej sesji z jasnym planem działania, gotowy świadomie wkroczyć w świat AI/ML – z wiedzą, narzędziami i pewnością, że obrałeś właściwy kierunek.', 7, 4, 2, 2, N'Room C', '2025-05-13T10:50:00', 60, NULL, NULL, 0),
(77, 2, N'Understand your data landscape with Observability platform', N'Dane to fundament nowoczesnych organizacji, ale ich rosnąca skala i złożoność sprawiają, że zarządzanie nimi staje się coraz trudniejsze. Jakie dane posiadamy, gdzie są przechowywane, jak są przetwarzane i czy można im zaufać – to pytania, na które wiele firm nie potrafi jednoznacznie odpowiedzieć. Bez pełnego wglądu w ekosystem danych trudno jest podejmować świadome decyzje, eliminować błędy czy spełniać regulacyjne wymagania.

W takich sytuacjach rozwiązaniem jest platforma Data Observability – narzędzie zapewniające pełną widoczność, monitorowanie i diagnozowanie problemów w całym krajobrazie danych. Dzięki temu organizacje mogą lepiej zrozumieć, jak ich dane są wykorzystywane i zarządzane, oraz zwiększyć ich jakość i niezawodność.

W tej sesji omówimy, jak zaprojektowaliśmy i wdrożyliśmy platformę Data Observability na chmurze Azure dla klienta z branży farmaceutycznej, gdzie kluczowym celem było zrozumienie, gdzie znajdują się dane, jakie procesy na nie wpływają i kto z nich korzysta. Opowiemy o wyzwaniach technologicznych, specyfice branży oraz praktycznych wskazówkach związanych z budową rozwiązania opartego na konkretnych filarach monitoringu. Sesja dostarczy inspiracji i konkretnych przykładów zastosowania, które mogą być pomocne w lepszym zarządzaniu danymi w każdej organizacji.', 7, 3, 2, 5, N'Room D', '2025-05-13T14:10:00', 60, NULL, NULL, 0),
(78, 2, N'How to talk with Tabular data  Chatbot case study from Raiffeisen Tech and RBI Group', N'While Retrieval-Augmented Generation (RAG) dominates text-based collaboration, working with structured data presents a unique set of challenges—and opportunities. This SessionDetails explores how Large Multimodal Model (LMM) Agents can be leveraged to design a chatbot capable of “talking” with tabular data.

The presentation delves into an innovative approach to interacting with structured datasets, outlining the practical steps, tools, and methodologies used. The solution bridges the gap between traditional RAG approaches and the nuanced demands of tabular data, addressing real-world challenges encountered along the way.

This case study provides actionable insights and inspiration for anyone exploring new frontiers for LMMs or seeking to enhance structured data workflows.', 7, 3, 1, 2, N'Room C', '2025-05-14T15:00:00', 60, NULL, NULL, 0),
(79, 2, N'Enterprise Databots: Projektowanie i zarządzanie inteligentnymi DataBotami w organizacji', N'Odkryj potencjał budowania i wdrażania zaawansowanych DataBotów w organizacji.
Zapraszamy na ekskluzywny warsztat poświęcony tworzeniu inteligentnych DataBotów z wykorzystaniem najnowszych technologii Microsoft i Databricks. Podczas tego intensywnego jednodniowego wydarzenia, uczestnicy będą mieli okazję poznać praktyczne aspekty implementacji chatbotów opartych na danych organizacyjnych. Warsztat prowadzony jest przez  ekspertów w dziedzinie specjalizujących się w zaawansowanych rozwiązaniach sztucznej inteligencji i uczenia maszynowego, certyfikowanych Microsoft MVP w kategoriach Data i AI.
Pod okiem prowadzących uczestnicy poznają praktyczne zastosowania najnowszych dostępnych technologii, czerpiąc z ich wieloletniego doświadczenia w tworzeniu zaawansowanych rozwiązań AI. Format warsztatów łączy zwięzłe wprowadzenie teoretyczne z rozbudowaną częścią praktyczną, gdzie każdy uczestnik samodzielnie zbuduje i wdroży działające rozwiązanie.
Cel Warsztatu: Budowa Kompleksowego DataBota: Uczestnicy będą pracować nad stworzeniem inteligentnego chatbota, który będzie potrafił odpowiadać na pytania w oparciu o różnorodne źródła danych organizacyjnych - od nieustrukturyzowanych dokumentów po dane analityczne z baz SQL. Szczególna uwaga zostanie poświęcona zrozumieniu możliwości zarządzania wdrożonym DataBotem.
Kluczowe Elementy:
•_x0009_Implementacja bezpiecznego dostępu do danych organizacyjnych
•_x0009_Integracja różnorodnych źródeł danych (dokumenty, procedury, bazy SQL)
•_x0009_Wykorzystanie najnowszych technologii AI, w tym Microsoft Fabric AI Skills i Databricks Genie
•_x0009_Zarządzanie modelami z wykorzystaniem  Azure AI Foundry i Databricks Mosaic ML
•_x0009_Praktyczne aspekty wdrożenia i zarządzania dostępem użytkowników  do Bota.
Wymagane Umiejętności: Podstawowa znajomość zagadnień związanych z przetwarzaniem danych i sztuczną inteligencją.
Korzyści dla Uczestników:
•_x0009_Praktyczne doświadczenie w tworzeniu DataBotów.
•_x0009_Poznanie najlepszych praktyk w zakresie bezpieczeństwa i zarządzania dostępem do danych udostępnionych w postaci czatów w organizacjach.
•_x0009_Rozpoznanie standardów i kluczowych zasad zarządzania modelami wykorzystywanymi w DataBotach.
•_x0009_Zrozumienie architektury nowoczesnych rozwiązań konwersacyjnych.
•_x0009_Możliwość konsultacji z ekspertami Microsoft MVP specjalizującymi się w rozwiązaniach Data i AI', 9, 1, 2, 2, N'Room C', '2025-05-12T08:30:00', 540, NULL, NULL, 0),
(80, 2, N'Analytics Engineering z dbt', N'Cel warsztatu:
Celem warsztatu jest przekazanie uczestnikom praktycznej wiedzy i umiejętności w zakresie budowy i wdrażania potoków danych za pomocą narzędzia dbt. Uczestnicy poznają miejsce dbt w procesie ELT, nauczą się konfiguracji projektów, pracy z modelami oraz testowania jakości danych. Zrozumieją także, jak wdrażać i orkiestrować rozwiązania oparte o dbt na nowoczesnych platformach danych, takich jak Databricks, Snowflake czy Microsoft Fabric.

Forma:
•_x0009_Wykład (40%), Laboratoria (60%).
•_x0009_Warsztat w formule "bring your own platform" - zdecydowana większość prezentowanego kodu będzie uniwersalna a uczestnicy podczas warsztatu będą mieli okazję zbudować rozwiązanie na Databricks, Snowflake lub MS Fabric. Kurs nie wymaga nakłądu finansowego ze strony uczestników - wystarczą wersje darmowe (Trial) każdej z platform.

Grupa docelowa:
Programiści SQL, Analitycy i Inżynierowie Danych, zainteresowani nauką budowy i wdrażania potoków danych za pomocą narzędzia dbt.

Wymagania:
•_x0009_SQL - poziom podstawowy/średniozaawansowany.
•_x0009_Pracy z interfejsem wiersza poleceń (cmd) i git - poziom podstawowy.
•_x0009_Znajomość na poziomie podstawowym przynajmniej jednej z platform - Databricks, Snowflake lub MS Fabric.
•_x0009_Laptop ze stabilnym połączeniem internetowym.
•_x0009_Aktywne konto testowe Databricks, Snowflake lub MS Fabric (wystarczą wersje bezpłatne).

Agenda:
•_x0009_Krótka historia BigData - od baz relacyjnych do nowoczesnych platform danych.
•_x0009_Czym różnią się od siebie podejścia ETL i ELT.
•_x0009_DataOps i Analytics Engineering.
•_x0009_Czym jest, a czym nie jest narzędzie dbt. Jakie jest jego miejsce w procesie ELT.
•_x0009_Konfiguracja repozytorium Git oraz projektu dbt-core dla Databricks/Snowflake/MSFabric. [hands-on]
•_x0009_Sources, Seeds, Models. [hands-on]
•_x0009_Data Tests, Data Freshness. [hands-on]
•_x0009_Omówienie podstawowych poleceń dbt run, test, build. [hands-on]
•_x0009_Jinja Templates, Macros. [hands-on]
•_x0009_Materializations, Incremental Load. [hands-on]
•_x0009_Snapshots – implementacja mechanizmów SCD1/SCD2. [hands-on]
•_x0009_Packages. [hands-on]
•_x0009_Dokumentacja oraz Lineage.  [hands-on]
•_x0009_Uprodukcyjnienie oraz orkiestracja rozwiązania - omówienie możliwości.
•_x0009_dbt Core vs. dbt Cloud.', 9, 4, 2, 14, N'Room D', '2025-05-12T08:30:00', 540, NULL, NULL, 0),
(81, 2, N'(transformacja?) Od Power BI dewelopera do Fabric inżyniera', N'Pracujesz w Power BI od kilku miesięcy lub lat, a świat tej platformy zaczyna Cię ograniczać. Być może warstwa Power Query stała się bardzo rozbudowana, a liczba wymaganych transformacji przerasta możliwości narzędzia. Może również odświeżanie danych trwa wieki, a subskrypcje Premium są zbyt kosztowne w stosunku do oferowanych funkcji. A może chcesz wykorzystać moc obliczeniową modelu semantycznego (DAX jest niezastąpiony!) do dalszych transformacji lub uczenia maszynowego.

Chcielibyśmy zaprosić Ciebie na warsztat typu hands-on, w trakcie którego sprawdzisz, że w takich przypadkach Microsoft Fabric stanowi naturalne rozwiązanie, ponieważ umożliwia realizację takich scenariuszy na kilka sposobów:

1. Dane mogą być wstępnie umieszczone w Lakehouse (jako landing zone).

2. Transformacje mogą być realizowane w Fabric ADF, Dataflows, Data Wrangler, notatnikach oraz procedurach składowanych.

3. Model semantyczny, który można odświeżać w bardziej wybiórczy sposób.

4. Semantic Link, który umożliwia dostęp do danych w notatnikach.

5. Więcej opcji powiadomień z Twoich raportów dzięki Activatorowi.

6. Poszczególne zadania można łączyć w sekwencje, zrównoleglić i wywoływać zgodnie z harmonogramem lub w odpowiedzi na zdarzenie.

Microsoft Fabric znacznie upraszcza rozwój rozwiązań analitycznych na wielu płaszczyznach. Warto zwrócić uwagę na możliwość wersjonowania kodu (projektów, komponentów platformy, wdrażania między środowiskami dev, test, prod), zredukowane do minimum czynności administracyjne oraz ciągły rozwój platformy w wielu kierunkach.

Adaptacja do nowej platformy jest łatwa, a narzędzia stały się bardziej intuicyjne z perspektywy dewelopera Power BI, który chce wykonać swoje zadanie w sposób bardziej efektywny i precyzyjny.

Na tym wielowarstwowym torcie czeka na nas także spory owoc wiśni: wejście w świat sztucznej inteligencji staje się coraz prostsze. AutoML, Copiloty – są już dostępne na platformie, więc nawet jako inżynier Fabric (a wcześniej deweloper Power BI) możesz z łatwością wykorzystać te funkcjonalności.

Podczas warsztatu przejdziemy wspólnie przez opisane wyżej scenariusze. Prosimy zabrać ze sobą laptopy, ponieważ warsztat ma charakter hands-on. Posiadacze maszyn firmowych - upewnijcie się, że możecie się podłączyć do publicznych i zabezpieczonych hasłem sieci WiFi. Każdy uczestnik otrzyma indywidualny dostęp do naszego tenanta.', 9, 3, 2, 8, N'Room F (Functional)', '2025-05-12T08:30:00', 540, NULL, NULL, 0),
(82, 2, N'GenBI czyli BI w czasach generatywnego AI', N'Tematyka generatywnego AI zdominowała świat w ostatnich dwóch latach. Od listopada 2022, czyli od momentu pojawienia się ChatGPT, liczba modeli językowych i multimodalnych sięgnęła milionów, a wielkie firmy prześcigają się w inwestycjach w generatywne AI. Zmiany związane z pojawieniem się fali generatywnego AI są nieodzowne i dotykają także obszaru Business Intelligence. W tej sesji przyjrzymy się (na demo i z krytycznym spojrzeniem) trzem rozwiązaniom text-to-SQL wykorzystującym generatywne AI do zmiany sposobu pracy użytkowników biznesowych i analityków z danymi - AI Skills w Microsoft Fabric, AI/BI Genie w Databricks i Snowflake Cortex Analyst.', 7, 3, 2, 2, NULL, NULL, NULL, NULL, NULL, 0),
(83, 2, N'Database Unit Testing for Data Professionals', N'In traditional software development, Unit Testing is pretty well known. But what about Unit Testing for database solutions?
Or more specifically, what about Unit testing for Data Warehouse solutions?

In this session, we will dive into the world of Unit Testing for databases, with a focus on Data Warehousing solutions.
Before we dive into practical examples, we need to understand the key concepts and the importance of Unit Testing.
As soon as the basics are set, we will talk about different possibilities/frameworks to implement Unit Testing.

Near the right before the halfway mark, we will dive into the tSQLt Framework specifically and we will start to get more practical.

What are we going to discover?
* How to create 1 or more Test Classes?
* How to create different Unit tests?
* What''s possible with tSQLt?
* How to automate your Unit tests?

If you are wondering how to get started with Unit Testing for Data Warehouse solutions or databases in general this SessionDetails is for you!', 7, 3, 1, 14, N'Room C', '2025-05-14T10:20:00', 60, NULL, NULL, 0),
(84, 2, N'Advanced DAX', N'If you already know and use the DAX but want to move to the next level, this workshop is for you.
Unleash the full power of evaluation context manipulation, learn about expanded tables, control the data lineage, avoid circular dependencies, and manage relationships at different granularities.
The prerequisite to attend this training is good experience writing DAX measures in Power BI or Analysis Services. You must know row context, filter context, and context transition. You are comfortable with using CALCULATE. You are not afraid to learn something new. At the minimum, watch the free Introducing DAX Video Course and make weeks of practice before attending this training.
Here are a few examples of what you can learn in this workshop:
•_x0009_Filter columns, not tables. Yes, you already know that, but you will learn many more reasons why it is a good idea.
•_x0009_Understand when to use ALLEXCEPT, and what to use instead of ALLEXCEPT all the many times when ALLEXCEPT is not a good idea.
•_x0009_Fix the circular dependency error that might appear when you create a relationship, a calculated column, or a table.
•_x0009_Control data lineage and play with it by using TREATAS.
•_x0009_Write granularity-aware measures when you use many-to-many cardinality relationships (yes, you can if you know what you are doing).', 9, 2, 1, 10, N'Auditorium', '2025-05-12T08:30:00', 540, NULL, NULL, 0),
(85, 2, N'Understanding window functions in DAX', N'Window functions (INDEX, OFFSET, WINDOW) are the latest addition to DAX; they also introduce a new concept named apply semantics. They are extremely powerful to simplify writing DAX code that needs to work on sorted tables, while also increasing performance for several calculations, like running totals, comparing one row with the previous one and so on.
In this SessionDetails we introduce window functions and apply semantics through several examples, so to obtain a good understanding of their capabilities and performance.', 7, 1, 1, 10, N'Auditorium', '2025-05-13T12:10:00', 60, NULL, NULL, 0),
(86, 2, N'AI w zasięgu SQL - inteligentne funkcje analityczne w Microsoft Fabric i Databricks', N'Nowoczesne platformy analityczne umożliwiają wykorzystanie zaawansowanych modeli AI bezpośrednio z poziomu standardowych zapytań SQL. W trakcie sesji zobaczymy, jak Microsoft Fabric i Databricks demokratyzują dostęp do sztucznej inteligencji, pozwalając analitykom na wzbogacanie danych o analizę sentymentu, klasyfikację, tłumaczenie tekstów, czy też wykonywanie bardziej sprecyzowanych zapytań - wszystko to bez konieczności pisania skomplikowanego kodu czy wdrażania własnych modeli. Przyjrzymy się praktycznym zastosowaniom wbudowanych funkcji AI w codziennych zadaniach analitycznych, od automatycznej kategoryzacji produktów po zaawansowaną analizę opinii klientów. W części demonstracyjnej pokażemy, jak łatwo wykorzystać gotowe modele językowe  jak wzbogacać dane strukturalne oraz jak łączyć tradycyjną analitykę z możliwościami sztucznej inteligencji. Omówimy również aspekty wydajnościowe i kosztowe takich rozwiązań. Sesja będzie szczególnie wartościowa dla analityków SQL i inżynierów danych, którzy chcą wykorzystać potencjał AI bez konieczności zostania ekspertami uczenia maszynowego.', 7, 3, 2, 2, N'Auditorium', '2025-05-14T09:00:00', 60, NULL, NULL, 0),
(87, 2, N'Migrate Your On-Premises SQL Server Databases to Microsoft Azure', N'Your company has made a decision to move your SQL Server databases to the cloud. But they are still unsure about which is the right way to go.

With all the day-to-day firefighting and workload that you need to handle, you have not had a chance to explore the cloud. But you need to get up-to-speed to make sure you have the confidence to get the job done.

This SessionDetails is all about migrating your on-premises SQL Server databases to Microsoft Azure. And instead of being overwhelmed with all the different features and options available to you, we will concentrate only on the ones that you will need for the migration. This covers

- primary considerations for migration
- effective strategies for database migration
- network connectivity for application connectivity and security
- post-migration operational tasks

At the end of the session, you will be able to create your own migration plan with the right strategy and approach to successfully migrate your on-premises SQL Server databases to Microsoft Azure.', 7, 3, 1, 11, N'Auditorium', '2025-05-13T10:50:00', 60, NULL, NULL, 0),
(88, 2, N'Kusto in Action: Powering Real-Time Intelligence in Fabric', N'Real-time Intelligence in Microsoft Fabric empowers data professionals and business users to seamlessly process and analyze highly granular, event-driven data. At its core lies the Kusto engine and the Kusto Query Language (KQL), delivering powerful capabilities for real-time data analysis. This SessionDetails explores how you can leverage KQL to build efficient, event-driven solutions in Fabric with real-world examples.

In this session, we will discuss:

- The role of Kusto in Real-Time Intelligence and Fabric, including its integration across the Real-Time Hub, Eventstream, Real-Time Dashboard, and Activator Fabric items.

- Key features of KQL that make it a game-changer for analysis of data in motion, including syntax, built-in functions, and operators, demonstrated through live queries on sample real-time data.

- How you can use Kusto and Real-Time Intelligence to monitor and govern your Fabric estate by cataloging workspace item, capacity utilization, and OneLake events in the Real-Time Hub.

Come along if you are a developer, data engineer, or analyst seeking practical examples and best practices for crafting KQL queries to drive real-time data analysis and actions. You will leave this SessionDetails equipped with the skills to unlock the full potential of real-time data in Fabric.', 7, 4, 1, 8, N'Room B', '2025-05-14T10:20:00', 60, NULL, NULL, 0),
(89, 2, N'Zrozum liczby zmiennoprzecinkowe w SQLServer', N'Liczby zmiennoprzecinkowe są niezwykle przydatne w świecie programowania, ale jednocześnie kryją w sobie wiele pułapek i nieoczywistych wyzwań. Podczas tej sesji odkryjesz tajniki przechowywania i manipulacji liczbami zmiennoprzecinkowymi w SQL Server. Omówimy także standard IEEE 754, który definiuje sposób ich reprezentacji, oraz różnice między różnymi typami danych zmiennoprzecinkowych w SQL Server. Przyjrzymy się także problemom związanym z precyzją, zaokrągleniami i porównaniami, które mogą zaskoczyć nawet doświadczonych programistów. Na koniec pokażemy praktyczne przykłady i najlepsze praktyki, aby zminimalizować ryzyko błędów w pracy z liczbami zmiennoprzecinkowymi.', 7, 3, 2, 14, N'Room B', '2025-05-13T10:50:00', 60, NULL, NULL, 0),
(90, 2, N'Database DevOps...CJ/CD: Continuous Journey Continuous Disaster?', N'Transforming a team that was used to a SVN-based-big-single-repo work style and little to no automation was a bumpy ride.
Join me in this SessionDetails where I share my experience in implementing Azure DevOps with Git, automated build and release pipelines and disposable personal databases.

In this SessionDetails I will tell you about my days as team lead and the challenges I faced while introducing:

DevOps:
- The formal DevOps term and process
- Working with sprints (our 4th attempt)

Git:
- Git as version control to SVN / TFVC people
- Using branches instead of only the master
- Adapting a Git branching strategy

Pipelines:
- Adapting a Build & Release Workflow
- Implementing naming conventions for: repos, branches, builds and releases
- The Introduction (and success) of pipelines
- Manual vs Pull Request Release

Dedicated Environments:
- Working with a database IDP (internal development platform)
- With versioned personal databases
- Including stashing databases when priorities change

Migrating an existing team that is stuck in its ways, critical by nature and fed up with deadlines is an interesting journey you don''t always hear about.

But in the end...it''s a lot of patience, work and yes it''s exhausting,  but completely worth it.

Take-aways
1. Insights in a real world DevOps migration  / transformation
2. Knowledge and experience sharing on the often forgotten DevOps part: the database
3. Beside all the talking: demonstration with tips you can directly make use of', 7, 4, 1, 14, N'Room C', '2025-05-13T14:10:00', 60, NULL, NULL, 0),
(91, 2, N'Microsoft Fabric Real-Time Intelligence dla inżynierów danych', N'W świecie dynamicznie zmieniających się danych kluczowym wyzwaniem staje się efektywne i automatyczne przetwarzanie informacji w czasie rzeczywistym. Podczas tej sesji pokażemy, jak na platformie Microsoft Fabric zintegrować architektury lakehouse i przetwarzania czasu rzeczywistego, wykorzystując takie funkcjonalności jak Fabric Events i Activator. Omówimy praktyczne scenariusze, w których automatyzacja procesów ładowania i przetwarzania danych pozwala na szybkie podejmowanie decyzji oraz wspiera tworzenie zaawansowanych systemów analitycznych. Dowiesz się, jak budować skalowalne rozwiązania, które przekształcają dane w wartość biznesową w czasie rzeczywistym.', 7, 3, 2, 8, N'Room A', '2025-05-13T15:30:00', 60, NULL, NULL, 0),
(92, 2, N'Szyfruj, przenoś, korzystaj -  klucz do bezpiecznego procesowania wrażliwych danych w MS SQL Server', N'Szyfrowanie danych przy użyciu klucza symetrycznego jest jednym z elementów zapewniającym bezpieczeństwo danych, zwłaszcza w scenariuszach przenoszenia informacji między różnymi środowiskami.

W tej prelekcji zaprezentujemy możliwość zaszyfrowania danych w on-premise MS SQL Server oraz odszyfrowania ich w chmurowym Azure Database, wykorzystując odpowiednio skonstruowany klucz symetryczny. Ten sam proces może być zastosowany do przenoszenia danych pomiędzy różnymi instancjami on-premise.

Uczestnicy dowiedzą się, jak zaimplementować szyfrowanie w MS SQL Server, aby umożliwić korzystanie z tych danych w formie odszyfrowanej na innych instancjach.

Przedstawimy także praktyczne podejście do zwinnego i wydajnego poruszania się po zaszyfrowanych danych, co ułatwia codzienną pracę z dużymi zbiorami danych i upraszcza integrację z innymi procesami.

Prelekcja dostarczy uczestnikom podstawy teoretycznej wiedzy na temat kluczy symetrycznych w MS SQL Server, ale głównie skupi się na praktycznym wdrożeniu szyfrowania danych za pomocą klucza symetrycznego.', 7, 3, 2, 14, N'Room B', '2025-05-13T16:50:00', 60, NULL, NULL, 0),
(93, 2, N'Becoming an Azure SQL DBA - Advancing the Role of the SQL Server DBA', N'This full-day workshop delivered by Microsoft Azure SQL product group is optimized for SQL Server DBAs that want to learn how their role evolves in Azure and what are the skills that will make them heroes of digital transformation in their organizations.

You will learn how Azure SQL automates many common tasks and offers business continuity capabilities out of the box; what are the areas with shared responsibility; what remains solely in realm of DBA and what''s the unique new value DBA can bring.

The topics include high availability, disaster recovery, backup and restore, performance tuning and troubleshooting, cost optimization, observability, security, compliance, connectivity, integration with Microsoft Fabric and other Azure services.', 9, 3, 1, 11, N'Room B', '2025-05-12T08:30:00', 540, NULL, NULL, 0),
(94, 2, N'Building scalable and automated Databricks-oriented data platform from scratch - lessons learned', N'Designing and implementing a holistic data platform is always a challenge, especially when your plan is to deliver it within a few months for a large-scale, multi-tenant organization.

Nevertheless, we decided to achieve this goal.
With fully automated deployment of the infrastructure composed of modular, reusable building blocks we provided tailored services for each tenant and environment. Moreover, we implemented an advanced framework for data processing jobs, allowing its users to define, deploy and automate new ETL pipelines or data integrations with basic configuration files. To normalize data governance in such various environments, we implemented a dedicated tool to manage and automate Unity Catalog resources. The entire solution allows users to implement tests and robust data quality checks on many stages, ensuring the crucial data transformations provide valuable and correct results.

During my presentation, I''d like to discuss how did we manage to provide such a scalable platform, the main difficulties we faced and what kind of experience we gained during this process', 7, 1, 2, 4, N'Room D', '2025-05-14T15:00:00', 60, NULL, NULL, 0),
(95, 2, N'Microsoft Fabric CICD - do''s, dont''s and hopes', N'Fabric is with us for quite some time now, but the topic of operating it under DevOps principles is still fresh. In this SessionDetails i wanted to talk about possible ways of deploying Fabric components across environments in an automated way. We will go through different scenarios and see the pros and cons of each approach, as well as challenges faced during the implementation.', 7, 3, 1, 8, N'Auditorium', '2025-05-14T13:40:00', 60, NULL, NULL, 0),
(96, 2, N'Ewolucja od Tradycyjnej Hurtowni do Modern Lakehouse w Databricks', N'Czy kiedykolwiek zastanawiałeś się, jak skutecznie przekształcić tradycyjną hurtownię danych w nowoczesny lakehouse, który sprosta wymaganiom współczesnych projektów bankowych i ubezpieczeniowych?
Zapraszam na praktyczną sesję, podczas której odkryjesz, jak platforma Azure Databricks może zrewolucjonizować zarządzanie danymi w Twojej organizacji. Prezentacja skierowana jest do specjalistów ds. danych, architektów oraz każdego, kto buduje lub modernizuje infrastrukturę danych.
Rozpoczniemy od omówienia fundamentów Databricks i stworzenia landing zone w Azure, uwzględniając kluczowe aspekty architektury i bezpieczeństwa w branżach regulowanych. Następnie przejdziemy do integracji danych, prezentując budowę ingestion framework z wykorzystaniem Delta Live Tables (DLT) lub Apache Spark — pokazując ich praktyczne zastosowania i korzyści.
Kluczowym punktem będzie architektura Medalion i modelowanie danych, które pozwolą Ci zrozumieć, jak projektować efektywne lakehouse’y przy użyciu sprawdzonych wzorców oraz Unity Catalog. Omówię także zaawansowane funkcje, takie jak maskowanie danych, zarządzanie bezpieczeństwem i data lineage, które wspierają zgodność z regulacjami.
W części praktycznej podziele się doświadczeniami z migracji hurtowni danych do Azure — dowiesz się, jak skutecznie przezwyciężyć typowe wyzwania, zaplanować migrację oraz wykorzystać narzędzia AI do automatyzacji transformacji kodu lub narzędzie takich jak Informatica Power Center lub SSIS.
Dodatkowo zaprezentuję różnorodne narzędzia dostępne w ekosystemie Databricks, takie jak dbt, DatabricksSQL i Apache Spark, które ułatwiają budowę nowoczesnych modeli danych.', 7, 3, 2, 5, N'Room B', '2025-05-13T12:10:00', 60, NULL, NULL, 0),
(97, 2, N'Mastering Microsoft Fabric Data Warehouse Performance', N'Join us for an in-depth SessionDetails on mastering Microsoft Fabric Data Warehouse performance, where we will cover everything from the fundamentals of query optimizer to advanced performance monitoring and optimization techniques. This SessionDetails will explore how query optimizer intelligently tunes your workload for optimal performance, learn the latest features and enhancements such as data clustering, query Insights and improved UI monitoring capabilities. We will provide you with the essential skillset for end-to-end performance management. Packed with demos and practical advice, this SessionDetails will include best practices for optimizing your data estate and delivering delighting performance experiences to your data warehouse users.', 7, 1, 1, 8, N'Room A', '2025-05-13T14:10:00', 60, NULL, NULL, 0),
(98, 2, N'Understanding Fabric Capacities', N'You''ve heard about Microsoft Fabric, and you''re ready to take it for a spin? Excellent, let''s get us started off in those few advertised minutes! But hold on .. you need a capacity to actually use something, and might not be completely clear on what it actually entails? You''re not alone with these questions, and it is perfectly fine to stop and think about it for a while. In fact, it''s a good thing you want to understand the single most core concept of Fabric as that will hopefully allow you to make better decisions down the road.

The introduction of Fabric Capacities sparked a lot of questions with Data Architects, Engineers, and Analysts coming from an IaaS or Paas (Infrastructure or Platform as a Service) way of working. Microsoft Fabric is presented as an all-in-one Analytics SaaS (Software as a Service) solution, with a unified measure for Compute and Storage. Great, promising to make the cost and performance predictability a lot simpler. Great! But what exactly does that mean, and what will it actually cost the company?

To understand Fabric Capacities, we need to briefly look at the architecture and what exactly those unified measures look like, including how they are similar, yet different from the existing Power BI Premium Capacities. Understanding the different types and sizes of capacities will help us make the right decisions for our Data Platform solutions in the organization.

But then, how do you manage those capacities and assess if they are in a healthy state? What are some of the options to follow the demands and needs of your business users to allocate the right resources to them? Most importantly, what options do I have to automate the majority of these tasks?

Walking out of the session, you should understand the key concept of Fabric Capacities and how they are at the core of everything you''ll do in Microsoft Fabric, be able to choose the one that is right for you, periodically assess if the choice was right, and act where needed.', 7, 3, 1, 8, N'Auditorium', '2025-05-13T15:30:00', 60, NULL, NULL, 0),
(99, 2, N'Context in DAX', N'Zrozumienie kontekstu w języku DAX jest kluczowe dla budowania zapytań i rozwiązywania problemów, ponieważ formuły mogą zwracać inne wyniki w zależności od założonych filtrów, relacji pomiędzy tabelami, miejsca w wizualizacji, w którym znajduje się komórka z wartością i kilku innych aspektów wpływających finalnie na rezultat końcowy.
Kontekst w DAX jest niezmiernie ważny do zrozumienia, aby móc budować zapytania, które zwracają dokładnie taki rezultat, którego oczekiwaliśmy, co zwłaszcza na początku nauki tego języka może sprawiać trudność, kiedy na przykład dodajemy do tabeli nową kolumnę lub filtrujemy do pojedynczego produktu, a otrzymujemy zupełnie nieoczekiwany wynik.', 7, 3, 2, 10, N'Room C', '2025-05-13T16:50:00', 60, NULL, NULL, 0),
(100, 2, N'Cena chaosu: Jak brak jakości w budowie platformy danych prowadzi do kosztownego kryzysu', N'Niska jakość rozwiązań na platformie danych to przepis na chaos, którego skutki odczuwają zarówno zespoły techniczne, jak i biznesowe. Brak testów, repozytoriów kodu i dokumentacji prowadzi do kosztownych przestojów, problemów z utrzymaniem oraz nieefektywności. Prelekcja pokaże, jak nieprzemyślane decyzje organizacyjne, techniczne I technologiczne potęgują problemy operacyjne i organizacyjne, oraz jakie kroki warto podjąć, by stworzyć stabilną i skalowalną platformę.
Poruszymy takie tematy jak:
- Omówienie podstawowych błędów: brak testów, dokumentacji, repozytorium kodu.
- Deweloperzy kontra procesy: Skutki pracy bezpośrednio na produkcji
- Chaos organizacyjny: Rola PMO i dobrych praktyk w zarządzaniu projektami
- Koszty zaniedbań: Wpływ niskiej jakości na budżet i wydajność zespołu.
- Droga do naprawy: Budowa kultury jakości na platformie danych', 7, 3, 2, 4, N'Room D', '2025-05-13T10:50:00', 60, NULL, NULL, 0),
(101, 2, N'SQL database in Microsoft Fabric head-to-head with Azure SQL', N'Azure SQL and SQL database in Microsoft Fabric are both OLTP database solutions, but they exist in different environments. In this session, we’ll dive into a head-to-head comparison of these two solutions, exploring their architecture, key features, platform capabilities, integration and ideal scenarios. We’ll break down key concepts and differences and compare them between SQL offerings in Azure and Fabric.

By the end of the session, attendees will understand the strengths and limitations of each solution, the differences in use cases, and when to choose one over the other.
Whether you’re a seasoned data professional or someone who’d like to become one, join us in this SessionDetails so we can equip you with actionable insights and help choose the right tool.', 7, 3, 1, 11, N'Room B', '2025-05-13T14:10:00', 60, NULL, NULL, 0),
(102, 2, N'Fabric Monitoring Made Simple: Built-In Tools and Custom Solutions', N'As organizations increasingly rely on Microsoft Fabric for their data needs, effective monitoring becomes essential—not just for performance optimization, but also for ensuring security, tracking adoption, and maintaining compliance.

In this session, we’ll explore the full spectrum of monitoring options in Fabric. You’ll learn how to leverage Microsoft’s built-in tools—such as the Monitoring Hub, Admin Monitoring workspace, and Workspace Monitoring—to gain valuable insights and improve operational efficiency.

We’ll also introduce the Fabric Unified Admin Monitoring (FUAM) solution—a powerful, open-source framework developed by the community and supported by Microsoft. FUAM bridges the gap between built-in tools and fully custom monitoring by offering a scalable, extendable approach to tenant-wide visibility.

Finally, we’ll demonstrate how to take things further by building your own monitoring pipelines using Fabric Data Factory and Fabric Spark, tailored to meet specific organizational requirements.

By the end of this session, you’ll have a solid understanding of what’s available out of the box, how FUAM can accelerate your admin insights, and how to develop custom solutions when you need maximum flexibility. Whether your goal is to save time, reduce costs, or strengthen your data governance, this SessionDetails will equip you with the knowledge to succeed.', 7, 3, 1, 8, N'Room D', '2025-05-13T12:10:00', 60, NULL, NULL, 0),
(103, 2, N'Snowflake & Power BI - governance challenges', N'Thousands of workspaces, reports, semantic models and more - in a large company governance is much more than just knowing who uses what and how often to properly govern their resources. I want to showcase what kind of tools (built-in and custom), frameworks and features (and AI) we are using to monitor, manage and govern environment based on Snowlake, Power BI and Fabric. Is Purview right for the job, what Fabric introduced recently and what is still needed - we will take a closer look into all those topics.', 7, 3, 2, 10, N'Room B', '2025-05-14T13:40:00', 60, NULL, NULL, 0),
(104, 2, N'Azure SQL Managed Instance Demo Party', N'Join us for a thrilling, demo-driven SessionDetails over a dozen incredible features for Azure SQL Managed Instance that will show you the latest and greatest innovations that enable Database Administrators and Developers to soar higher.

Whether you’re a DBA, Azure Administrator, Developer, Business Intelligence developer, or any other data professional, these demos will show you how to go father with the exciting features that are available to you. Some of the topics we will cover are hybrid scenarios, performance and scale, application compatibility, workload modernization, compliance, data mobility/migration & business continuity/disaster recovery - and several more - in this fast-paced demo-only session', 7, 3, 1, 5, N'Room D', '2025-05-13T16:50:00', 60, NULL, NULL, 0),
(105, 2, N'Fabric Mirroring okiem architekta', N'Współcześnie rzadko zdarza się by jakakolwiek organizacja zaczynała swoją przygodę z analityką od tzw. green field. Przeciwnie, dysponuje wieloma rozwiązaniami, których integracja często wymaga dużych nakładów pracy i czasu. Zazwyczaj oznacza to konieczność budowania czy modyfikowania istniejących potoków przetwarzania danych dla nowych zastosowań. Z pomocą przychodzi Microsoft Fabric, a konkretnie Fabric Mirroring. Jest to rozwiązanie pozwalające nam na wykorzystanie ciągłej replikacji istniejących źródeł danych, bezpośrednio do OneLake. Sesja poświęcona będzie zagadnieniom architektonicznym. Jak z perspektywy architektów rozwiązań wygląda możliwość wykorzystania Fabric Mirroring w praktyce? Jakie mamy do dyspozycji scenariusze integracji z innymi rozwiązaniami? Czy warto używać mirroringu nie tylko dla źródeł/usług danych Microsoft? Słabe i mocne strony Fabric Mirroring oczami osób pracujących z Microsoft Fabric na co dzień.', 7, 3, 2, 4, N'Room A', '2025-05-13T12:10:00', 60, NULL, NULL, 0),
(106, 2, N'What Happens When Things Go Wrong? A Guide to Business Continuity in Fabric', N'Microsoft Fabric makes developing an end-to-end analytics solution a rewarding experience, removing the hurdles of stitching together multiple cloud services to provide a holistic data platform. However, as easier as this has become we still need to be mindful of what happens when things go wrong...how do we ensure continuity of data solutions built in Fabric?

In this SessionDetails attendees will understand how disaster recovery and business continuity are handled across the various workloads within Fabric to ensure relevant processes are in-place to deal with any issues that may occur.', 7, 1, 1, 8, N'Room A', '2025-05-13T10:50:00', 60, NULL, NULL, 0),
(107, 2, N'Is it architected.. well?', N'In this session, I will overview key principles to consider when designing an effective, enterprise-grade analytics solution. Let''s go deep into the details of reliability, security, cost optimization, operational excellence, and performance efficiency. Are all of them of the same importance? How should my architecture look? How do we cover all business needs while preserving those pillars? Let us discover together the world of "Azure Well-Architected Framework" for analytical solutions.', 7, 3, 2, 4, NULL, NULL, NULL, NULL, NULL, 0),
(108, 2, N'GenAI Done Responsibly', N'Eksperci szacują, że wpływ GenAI na globalne PKB może dorównać największym gospodarkom świata. Automatyzacja, kreatywne narzędzia i innowacyjne rozwiązania w niemal każdej branży wydają się być na wyciągnięcie ręki.

Ale czy GenAI rzeczywiście zmieni nasz świat na lepsze? Czy jej rozwój nie wiąże się z ryzykiem wyzwań etycznych, dezinformacji i nierówności? Powstają pierwsze regulacje, takie jak AI Act w Unii Europejskiej, a najwięksi dostawcy GenAI wprowadzają w swoje modele mechanizmy etyczne. Czy to wystarczy, aby uznać te rozwiązania za odpowiedzialne?

Podczas sesji spróbujemy odpowiedzieć na pytanie - co oznacza odpowiedzialne projektowanie systemów informatycznych opartych o GenAI. Omówimy, jakie praktyczne narzędzia warto użyć podczas implementacji, by minimalizować ryzyko, oraz jak skutecznie monitorować funkcjonowanie takich rozwiązań', 7, 3, 2, 2, N'Room D', '2025-05-14T13:40:00', 60, NULL, NULL, 0),
(109, 2, N'Jak Copilot wspiera różne role użytkowników w Microsoft Fabric', N'W tej sesji zaprezentuję, jak Copilot w Microsoft Fabric wspiera użytkowników pełniących różne role w organizacji, od administratorów po analityków i inżynierów danych. Dzięki Copilot, każdy użytkownik otrzymuje dostosowane do jego potrzeb rekomendacje, które automatyzują codzienne zadania i optymalizują procesy. Od zarządzania dostępem i konfiguracją środowiska przez tworzenie raportów i przetwarzanie danych, po monitorowanie wydajności — Copilot ułatwia pracę na każdym etapie zarządzania i analizy danych. Ta sesja pokaże, jak Copilot zwiększa efektywność i przyspiesza realizację zadań w Microsoft Fabric, niezależnie od pełnionej roli.', 7, 3, 2, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(110, 2, N'Keynote: Composable AI and its impact on Enterprise Architecture', N'Software ate the world and AI is eating software. Recent years are an epic ride of innovation that gave life to a host of new technologies and pretty much every (software) product - whether old or new - has to have some “AI magic” label. Most of these efforts, however, aren’t sustainable as “the AI” often is a bolt-on feature. The rise of AI-centered applications requires composable building blocks and impacts the data and application layers of modern enterprise architecture. Simply because this is the forefront of AI driven economic force enterprises need to get the foundations right and empower its people now! This talk examines what’s changing, what stays the same and how AI systems unlock business value drawing from hands-on examples in supply chain and human resources.

1. Status quo: AI lives in the data layer
2. Trend: composable enterprise AI
3. Big picture: integration of AI into the economy', 3, 1, 1, 4, N'Auditorium', '2025-05-13T10:00:00', 30, NULL, NULL, 0),
(111, 2, N'Partitioning Approaches in Database Systems: Insights from Oracle, SQL Server, and PostgreSQL', N'In this session, we will delve into the world of database partitioning, exploring the different approaches used by leading database engines such as Oracle, SQL Server, and PostgreSQL. We will begin by providing an overview of database partitioning, discussing its benefits and challenges.
Next, we will take a deep dive into the partitioning approaches offered by each database system. We will examine range partitioning, hash partitioning, list partitioning, interval partitioning, and composite partitioning. We will also explore the different partitioning strategies available and discuss best practices for choosing the right strategy for your specific needs.
Finally, we will compare and contrast the partitioning approaches used by Oracle, SQL Server, and PostgreSQL. We will highlight the strengths and weaknesses of each approach and provide real-world examples to illustrate their practical applications.
Throughout the session, we will provide insights from our own experiences and share case studies to help you understand how partitioning can improve the performance and scalability of your database systems.
At the very end we will also take a look on how this advanced knowledge can still be levereged in PaaS DB engines, and what is covered for us by Cloud automatically.', 7, 3, 1, 14, N'Room C', '2025-05-14T13:40:00', 60, NULL, NULL, 0),
(112, 2, N'FinOps - Praktyczny przewodnik zarządzania kosztami usług Data w Azure Cloud', N'Na decyzję o wyborze chmury do budowy oprogramowania, wpływa między innymi brak konieczności ponoszenia na starcie dużych inwestycji w budowę własnej infrastruktury, czy też w utrzymanie zespołu specjalistów od jej wsparcia.
Jednak zignorowanie kwestii kosztów działania chmury na etapie projektowania architektury systemu oraz brak późniejszego monitorowania wydatków związanych z jej działaniem,
może doprowadzić do utraty zakładanych oszczędności.

W trakcie spotkania, opowiemy jak zaplanować przewidywalną wysokość wydatków na chmurę Azure.
Dowiecie się co doradza w tym temacie sam Microsoft w ramach Well-Architected Framework oraz jak używać Azure Pricing Calculator.
Przybliżymy takie pojęcia jak Pay-as-you-go, Rezerwacje, Saving Plans, Hybrid Benefit.

Podzielimy się praktycznymi radami wynikającymi z naszego doświadczenia w zakresie optymalizacji kosztów Azure.
Na przykładach dotyczących usług Data (m.in. Synapse Analytics, Databricks, Analysis Services).
Otrzymacie wiedzę jak budować mechanizmy ograniczające wydatki, poznacie narzędzia do monitorowania kosztów oraz alarmowania o przekroczeniu założonych progów.

Mamy nadzieję, że dzięki zaproponowanemu przez nas podejściu, rozpoczniecie transformację w kierunku wytworzenia dyscypliny w zarządzaniu kosztami oraz zmienicie nastawienie zespołu projektowego na efektywność kosztową.', 7, 3, 2, 5, N'Room C', '2025-05-13T15:30:00', 60, NULL, NULL, 0),
(113, 2, N'Implementacja data martów i udostępnianie danych w Snowflake w Żabce', N'Wdrożenie nowoczesnej architektury danych w chmurze, takiej jak Snowflake, to złożony proces. Budowa efektywnych data martów i skuteczne udostępnianie danych w organizacji o skali Żabki wymaga strategicznego podejścia i praktycznego doświadczenia. Podczas tej sesji podzielimy się doświadczeniami Żabki z tego procesu, opierając się na wdrażanym projekcie MMM (Marketing Mix Modelling). Opowiemy o motywacjach, kluczowych etapach, napotkanych wyzwaniach i wyciągniętych wnioskach. Przedstawimy architekturę docelową, wybrane narzędzia i technologie, a także strategie zarządzania danymi. Zobaczysz, jak Snowflake przyczynia się do poprawy dostępu do danych i wspiera podejmowanie decyzji marketingowych w Żabce. Ta sesja pozwoli Ci zrozumieć praktyczne aspekty transformacji danych w dużej organizacji i zainspirować się doświadczeniami z wdrażanego przez nas projektu.', 7, 3, 2, 4, N'Room D', '2025-05-13T15:30:00', 60, NULL, NULL, 0),
(114, 2, N'Power BI Gateway Logs Unlocked: Find the Clues, Fix the Issues', N'On-Premise Data Gateway often feels like the most mysterious part of Power BI. Even its name can mislead, as it''s also needed for some cloud sources!

It seems simple: create a connection, map it to your model, schedule refresh and it usually just works... But have you ever wondered what happens when you click that refresh button? How does your data travel through the Gateway, which hurdles does it need to pass and, more importantly, what traces does it leave behind?

Don''t you worry, after today''s session, Gateway will have no secrets for you!

During these 60 minutes I''ll explain how the Gateway works in plain words. Together we''ll dive into Gateway logs, discovering valuable insights, practical ways to spot issues and techniques to boost performance. No mystery - just clear, actionable knowledge!', 7, 3, 1, 10, N'Room D', '2025-05-14T09:00:00', 60, NULL, NULL, 0),
(115, 2, N'Advanced SQL Server Table and Index Partitioning', N'This presentation explores advanced SQL Server partitioning techniques that can help enhance performance, scalability and maintenance. It covers how table partitioning breaks large datasets into manageable segments, enabling partition elimination for faster query processing and efficient maintenance. You’ll learn about quick data movement through partition switching and truncation, as well as the performance boost offered by integrating partitioning into your indexing strategy. Practical examples illustrate how partitioning minimizes hotspots and improves maintenance operations, providing scalable solutions for high-scale environments.', 7, 3, 1, 11, N'Room A', '2025-05-13T16:50:00', 60, NULL, NULL, 0),
(116, 2, N'(developer) productivity, data intelligence and building an AI application', N'"Hey, we just bought this awesome AI and it solved all of our problems" - said no one ever. The field of tech is developing at a breathtaking speed - boosted by (the many promises of) AI - and we''re witnesses to a user experience that''s about to fundamentally change. Together, we dive into the shift from "general intelligence" to "data intelligence", lessons learned along the way, practical examples, crunch some data, build AI models and build a data product that helps cater insight to knowledge workers in my company when and where they need it.', 7, 3, 1, 2, N'Room B', '2025-05-13T15:30:00', 60, NULL, NULL, 0),
(117, 2, N'Fundamenty wiarygodnej analityki:Data Governance jako klucz do sukcesu organizacji opartej na danych', N'W erze, gdy dane stały się strategicznym zasobem, organizacje stawiają czoła fundamentalnemu wyzwaniu: jak zapewnić wiarygodność informacji stanowiących podstawę decyzji biznesowych?

W mojej sesji przedstawię kompleksowe podejście do zarządzania jakością danych w całym ich cyklu życia. Zaprezentuję praktyczne aspekty wdrożenia Data Governance, ze szczególnym uwzględnieniem katalogu danych jako centralnego elementu ekosystemu zarządzania.

Zamiast abstrakcyjnych koncepcji, zademonstruję praktyczną ścieżkę od identyfikacji anomalii w raporcie biznesowym, poprzez śledzenie pochodzenia danych (data lineage), aż do lokalizacji i naprawy źródła problemu. Pokażę, jak zintegrowane narzędzia Data Governance umożliwiają sprawne zarządzanie kryzysem jakościowym i budowanie organizacji rzeczywiście opartej na danych.

Moja sesja adresowana jest zarówno do osób zarządzających danymi, jak i do analityków oraz decydentów biznesowych poszukujących solidnych fundamentów dla swoich analiz.', 7, 3, 2, 4, N'Auditorium', '2025-05-13T14:10:00', 60, NULL, NULL, 0),
(118, 2, N'Azure SQL i Fabric SQL z modelami LLM, czyli co może być w nowym SQL Server 2025', N'Możliwości, jakie dają modele językowe LLM w zakresie przeszukiwania i rozumienia tekstu, otwierają nowy rozdział w sposobie wyszukiwania informacji zawartych w relacyjnych bazach danych. Podczas sesji pokażemy, jak skuteczniej realizować zapytania tekstowe z wykorzystaniem Azure SQL oraz Fabric SQL. Przyjrzymy się także, jak wykorzystać RAG i modele LLM w praktyce. Zastanowimy się również, które z tych funkcji mogą znaleźć się w SQL Server 2025.', 7, 1, 2, 4, N'Room B', '2025-05-14T11:40:00', 60, NULL, NULL, 0),
(119, 2, N'Nie tylko o AI – czego można się spodziewać po SQL Server 2025 patrząc na Azure SQL i Fabric', N'SQL Server 2025 nie został jeszcze oficjalnie wydany, ale pierwsze symptomy już widać – wystarczy przyjrzeć się nowościom w Azure SQL i Fabric. W tej sesji skupimy się na tym, jakie zmiany w zakresie wydajności, bezpieczeństwa i architektury mogą (zapewne będą) przeniesione z chmury do wersji on-prem. Pokażemy konkretne funkcje, mechanizmy i zmiany, które już teraz testowane są w usługach cloudowych i mają spore szanse trafić do SQL Servera 2025.
Bez AI, bez LLM, bez cukru, tylko czysty SQL.', 7, 3, 2, 14, N'Room A', '2025-05-14T13:40:00', 60, NULL, NULL, 0),
(120, 3, N'From Xbox to Insights: Real-Time Data in Action', N'Fasten your seatbelts—this SessionDetails is all gas, no brakes! Ready to learn how to build a Real-Time Intelligence Solution in Fabric but wondering how to create real-time data for your POC? Join me  for an adrenaline-packed, live-demo SessionDetails where I’ll turn Forza Horizon on Xbox into your data playground!

In just one hour, we’ll show you how to stream live telemetry data straight from the racetrack, transform it into powerful real-time insights with dashboards, and take immediate action with Data Activator. No prerecorded content here—just real-time solutions, real fun, and maybe a little tire smoke.

By the end, you’ll be ready to bring these concepts back to your environment—even if your boss won’t let you use an Xbox at work. Get ready to race into the future of real-time analytics!', 7, 4, 1, 9, N'Room C', '2026-05-12T12:10:00', 60, NULL, NULL, 0),
(121, 3, N'Data Protection Layers - Practical Guide', N'Data security - everyone knows it’s important, yet hardly anyone talks about it. In every project, we discuss performance, cost optimization, and data quality… but who’s actually responsible for protecting the data itself?

In this highly technical - and slightly provocative - session, two data engineers will take you on a deep dive through the different layers of data protection. From physical and network-level safeguards to encryption, masking, and row-level security, they’ll explore what should happen versus what really happens in real-world projects.

Expect mind-bending demos, a good dose of irony, and some uncomfortable truths about how fragile our data ecosystems truly are. You’ll leave with a clearer understanding of where the real risks hide - and what every data professional can do to make security a built-in part of their daily engineering work, not just an afterthought.', 7, 4, 2, 16, N'Room B', '2026-05-13T09:00:00', 60, NULL, NULL, 0),
(122, 3, N'Jak przetwarzać tylko to, co się zmieniło - wzorzec niezależny od technologii', N'W Fabricu czy Databricksach mamy dziś wbudowane mechanizmy do przetwarzania przyrostowego i często to wystarcza. Ale co, jeśli z jakiegoś powodu nie możemy ich użyć? Albo chcemy mieć podejście, które zadziała niezależnie od technologii?
_x0009_
Na tej sesji pokażę uniwersalny wzorzec wykrywania zmian, który sprawdza się w każdym środowisku - w Azure, Fabricu, Databricksach, dbt, Snowflake’u, a nawet on-prem. Dzięki niemu można pominąć dane, które już zostały przetworzone i skupić się wyłącznie na tym, co się faktycznie zmieniło.', 7, 3, 2, 16, N'Auditorium', '2026-05-12T15:30:00', 60, NULL, NULL, 0),
(123, 3, N'Automating Your Microsoft Fabric Data Platform: From Blueprint to Reality', N'Join this full-day, hands-on workshop designed to help you master automation in Microsoft Fabric. Whether you’re starting your automation journey or optimizing existing processes, this SessionDetails will equip you with practical skills to accelerate development, minimise risk, and reduce costs through low-code and pro-code automation.
You’ll learn how to automate every step of the Fabric Data Platform lifecycle, from design and setup to implementation, deployment, and documentation. Through demo-packed exercises, we’ll guide you in building a robust, scalable, and efficient data platform using automation best practices.

By the end of this workshop, you will be able to:
Automate platform setup using code and configuration scripts.
Implement a metadata-driven ingestion approach for streamlined data preparation.
Build a foundation for semantic models with automation techniques.
Integrate CI/CD pipelines using GitHub and Azure DevOps for continuous delivery.
Leverage Fabric CLI, REST APIs, and the fabric-cicd Python library to simplify workflows.

This workshop blends low-code flexibility with pro-code power, ensuring you leave with actionable tools, scripts, and knowledge to integrate automation into your Fabric Data Platform. From blueprint to reality, you’ll gain the confidence to automate processes that accelerate development and deliver consistent, cost-effective solutions.

Requirements:
Must have
– Visual Studio Code installed

Nice to Have
– Access to a Fabric environment and Fabric Capacity
– Possibility to create workspaces

Easy to have:
– Fabric Admin role

In case the „nice to have” requirements can not be met, we will provide the attendees with these requirements.', 5, 3, 1, 6, N'Room D', '2026-05-11T08:30:00', 540, NULL, NULL, 0),
(124, 3, N'Practical Databricks FinOps: Strategies for Cost Optimization in Data Lakehouse', N'This SessionDetails will explore effective strategies for optimizing costs on the Databricks platform through data-driven Financial Operations (FinOps) practices. Attendees will learn how to leverage system data to generate actionable insights, develop cost-saving recommendations tailored to specific departments, and implement proactive alerts to prevent budget overruns. Additionally, the SessionDetails will cover the integration of Generative AI to provide analysts with personalized query optimization recommendations, enhancing efficiency and reducing costs. Join me to discover practical approaches to maximizing the value of your Databricks investment while maintaining fiscal discipline.
Language will be chosen during the SessionDetails (PL/ENG).', 7, 3, 1, 6, N'Room A', '2026-05-13T15:00:00', 60, NULL, NULL, 0),
(125, 3, N'Dynamic Search Conditions - SQL 2025 Edition', N'A common requirement in database applications is that users want a function to search a set of data from a large set of possible search conditions. The challenge is to implement such searches in a way that is both maintainable and efficient in terms of performance. This SessionDetails looks at the two main techniques to implement such searches and highlights their strengths and limitations.

In this revamped version of the session, we will also look at the new feature in SQL 2025, Optional Parameter Plan Optimization and why it does not suffice to solve these problems.

This is a level 300 SessionDetails aimed at developers who have been working with T-SQL for a few years.', 7, 3, 1, 16, N'Room C', '2026-05-12T14:10:00', 60, NULL, NULL, 0),
(126, 3, N'CTE Myths—Busted!', N'Common Table Expressions (CTEs) are a staple in modern SQL development—but they’re also surrounded by persistent myths that can mislead even experienced developers. Is a CTE just a fancy temp table? Does it always hit TempDB? Is it guaranteed to improve readability and performance?

In this session, we’ll start with the fundamentals: what a CTE is, how it works, and where it fits into query design. Then we’ll dive into the most widespread misconceptions about CTEs.

You’ll see real-world examples that clarify when CTEs behave like inline views, when they don’t, and how SQL Server actually handles them under the hood.

Whether you use CTEs for recursion, modularization, or query simplification, this SessionDetails will give you the clarity to use them effectively—and the insight to avoid common traps.', 7, 3, 1, 15, N'Room C', '2026-05-12T10:50:00', 60, NULL, NULL, 0),
(127, 3, N'Enhancing Multimodal RAG with Cosmos DB Vector Search and Azure AI Image Embeddings', N'This SessionDetails explores how Cosmos DB Vector Search, combined with Azure AI-generated image embeddings, enhances multimodal retrieval-augmented generation (RAG) systems using GPT and AI Vision. It compares image embeddings generated via the Azure AI Model Inference API with the latest multimodal embeddings from Computer Vision v4.0.
The presentation highlights how these new multimodal embeddings integrate image and text data to improve cross-modal retrieval. It also examines the role of Contrastive Language-Image Pre-training (CLIP) embeddings within the Azure ecosystem and their impact on accuracy and relevance in multimodal RAG applications.
Through a comparative analysis, we demonstrate how Azure AI and Cosmos DB optimize image-centric AI workflows, unlocking new possibilities for advanced multimodal AI systems.', 7, 1, 1, 1, N'Room A', '2026-05-13T10:20:00', 60, NULL, NULL, 0),
(128, 3, N'Advanced T-SQL Triage: The Art of Fixing Terrible Code', N'You’ve seen it before: the procedure that looks like it was generated by an AI trained on Stack Overflow and despair. It’s got MERGE. It’s got RIGHT JOINs. It’s got logic so tangled you’d need a flowchart, a flashlight, and a therapist to debug it. And now… it’s your problem.

In this full-day festival of query-fixing, Erik Darling leads you through the real world mysteries of advanced T-SQL: the strange, the slow, and the occasionally cursed. You’ll tackle tangled paging logic, rescue window functions and indexed views from spools and spills, and finally learn when to keep a CTE and when to yeet it. We’ll refactor data modifications that block like linebackers, decode procedural patterns, and write dynamic SQL that’s powerful and polite.

You’ll learn when to CROSS APPLY, dig into views vs. inline TVFs, and discover why RIGHT JOIN is not simply LEFT JOIN’s syntactic twin. We’ll uncover when user-defined functions wreck your query execution plans—and how to rewrite them with flair. If you’ve ever been curious about why that query sometimes takes SO long and how to best rewrite it without just guessing, this is your playground.

Expect fast demos, big laughs, and a glorious cheat sheet to take home. Because refactoring SQL isn’t just necessary—it’s super fun when you''re in the right party.', 6, 1, 1, 16, N'Room A', '2026-05-11T08:30:00', 540, NULL, NULL, 0),
(129, 3, N'For a Few Rows More: Mastering Row Goals in SQL Server', N'In this performance tuning deep dive, Erik Darling exposes the strange and often overlooked impact of row goals on SQL Server execution plans.

Through practical demonstrations, you''ll see how these optimizer shortcuts, designed to retrieve just enough rows to satisfy a query, can silently steer execution plans in ways that drastically affect performance —sometimes for better, sometimes for worse.

You''ll walk away with immediately applicable techniques for recognizing, troubleshooting, and strategically implementing row goals in your environment. Learn how to finesse these mechanisms to your advantage, using them deliberately to push SQL Server toward faster, more efficient plans.

If you want to understand why SQL Server sometimes makes bewildering decisions, and how to take back control of your queries, saddle up — it''s time to go looking for a few rows more. These essential techniques are vital for anyone serious about advanced SQL Server performance optimization.', 7, 3, 1, 16, N'Room B', '2026-05-12T12:10:00', 60, NULL, NULL, 0),
(130, 3, N'Orchestration best practices in Microsoft Fabric', N'Join me for a SessionDetails on mastering orchestration within Microsoft Fabric. Discover best practices for scheduling and managing your data workflows. We will be talking about native schedulers for items like semantic models, dataflows, notebooks, etc, and why using only these can bring you into specific issues that can be handled more elegantly and efficiently. Explore how to effectively schedule components with multiple dependencies like pipelines and notebooks while addressing common challenges such as dependency control and parametrization. Learn why pipelines are great for managing complex workflows, offering superior control over dependencies and execution. Finally, dive into the power of Directed Acyclic Graphs (DAGs) in tools like Apache Airflow and see how they excel at orchestrating notebooks and why this is a crucial part of orchestration in the Microsoft Fabric ecosystem. Whether you’re building pipelines and notebooks or preparing complex reporting solutions with dependencies between semantic models or between Fabric items, this SessionDetails will equip you with actionable strategies to achieve efficient and scalable orchestration in Microsoft Fabric.', 7, 1, 1, 6, N'Room C', '2026-05-13T11:40:00', 60, NULL, NULL, 0),
(131, 3, N'SQL Server i wektorowa rewolucja, czyli jak LLM widzi Twoje dane', N'SQL Server 2025 otwiera nowy rozdział - obsługę baz wektorowych, kluczowego elementu napędzającego Duże Modele Językowe (LLM) i nowoczesne rozwiązania AI. Ale czym właściwie są wektory? Jak tekst, obraz czy kod staje się rzędem liczb? Co to są embeddingi i dlaczego są tak istotne w przetwarzaniu semantycznym?

W trakcie tej sesji zaprezentuję:
- jak LLM-y „rozumieją” dane,
- czym są embeddingi i jak można je tworzyć,
- jak przechowywać i przeszukiwać dane wektorowe w SQL Server 2025,
- oraz dlaczego baza wektorowa to coś więcej niż tylko nowy typ danych.

Całość osadzona będzie w praktycznych scenariuszach i demo - bez zbędnej matematyki, za to z naciskiem na zrozumienie tego, jak połączyć klasyczne podejście do danych z nowoczesnymi możliwościami AI. Jeśli chcesz dowiedzieć się, jak już dziś budować rozwiązania gotowe na jutro - ta sesja jest dla Ciebie.', 7, 3, 2, 1, N'Room A', '2026-05-12T10:50:00', 60, NULL, NULL, 0),
(132, 3, N'SQL Server Accelerated Database Recovery', N'Accelerated database recovery is not a well known feature, even though it''s been around since SQL Server 2019.
It improves database availability, especially in the presence of long-running transactions, by redesigning the database engine recovery process
and it has been improved with every new version.
In this SessionDetails we''ll look at how it works and how we can use it to our benefit.', 7, 1, 1, 16, N'Room A', '2026-05-12T16:50:00', 60, NULL, NULL, 0),
(133, 3, N'SQL Injection 2026: Atak, który wciąż powraca. Live hacking w aplikacjach webowych', N'SQL Injection podatność, którą znamy od ponad dwóch dekad, powinna dawno zniknąć z krajobrazu bezpieczeństwa. A jednak w 2026 roku wciąż należy do najczęściej wykorzystywanych wektorów ataku, a jej skutki pozostają wyjątkowo destrukcyjne. Dynamiczny rozwój technologii, generowanie kodu z użyciem AI i presja na tempo wytwarzania oprogramowania tylko pogłębiają problem.

W trakcie tej sesji przeprowadzimy serię praktycznych ataków na podatną aplikację webową, krok po kroku pokazując, jak proste błędy w logice zapytań prowadzą do wycieku danych, manipulacji informacjami biznesowymi, eskalacji uprawnień, a w skrajnych przypadkach - do pełnego przejęcia kontroli nad systemem. Wszystko w formule live hacking, oparte na realistycznych scenariuszach inspirowanych tym, co nadal spotykamy w środowiskach produkcyjnych.

Po części pokazowej omówimy także praktyczne techniki obrony, które realnie działają w 2026 roku. Od bezpiecznych konstrukcji kodu, przez ograniczanie uprawnień, po architektoniczne wzorce ograniczające szanse na udany atak.', 7, 3, 2, 16, N'Auditorium', '2026-05-13T11:40:00', 60, NULL, NULL, 0),
(134, 3, N'Optimized Locking in SQL Server 2025: Internals, Contention, and Concurrency', N'Optimized Locking in SQL Server 2025 introduces a fundamental redesign of how the storage engine synchronizes concurrent data modifications. By shifting long-lived protection from row and page resources to transaction-level ownership, the engine significantly reduces lock memory consumption, blocking chains, and deadlock susceptibility in high-throughput OLTP workloads.

A central innovation is the Lock After Qualification (LAQ) execution model. Instead of acquiring update locks during the scan phase, SQL Server evaluates row qualification optimistically using versioned visibility semantics and synchronizes only when correctness requires it. Through internal predicate-outcome heuristics, the engine can bypass certain conflicting rows without waiting while still preserving full ACID guarantees.

In this session, we will analyze the redesigned locking pipeline step-by-step:

TID Locks – how transaction ownership replaces many traditional row locks
LAQ mechanics – separating qualification from physical modification
Conflict resolution patterns – why some write-write conflicts no longer cause blocking
Correctness safeguards – commit-dependent predicate reasoning and re-qualification
Using targeted demos with sys.dm_tran_locks, sys.dm_os_waiting_tasks, execution plan analysis, and page-level inspection techniques, we correlate observable lock behavior with the underlying storage engine state. By examining page headers and row structures, we visualize transaction ownership, version pointers, and in-row versus off-row version storage in the Persistent Version Store (PVS).

We conclude by exploring practical workload implications, including index access paths, hotspot patterns, and scenarios where the engine must fall back to classic locking semantics.
Attendees will leave with a precise mental model of SQL Server 2025’s evolved locking pipeline - and actionable guidance for designing workloads that benefit from reduced contention, improved scalability, and more predictable concurrency behavior.', 7, 2, 1, 15, N'Room A', '2026-05-12T14:10:00', 60, NULL, NULL, 0),
(135, 3, N'DAX - Beyond the Basics', N'❓ Have you been using PowerBI for a while but your users are now asking for more complex measures and reports?

❓ Would you like to step beyond these simple reports and take your DAX to the next level to solve your organisation’s challenges?

❓Are you comfortable with basic DAX and CALCULATE, but:

Seeking solutions to complex business problems using DAX.

Working in industries like finance, sales, supply chain, or analytics, where advanced calculations are essential.

Your DAX is limited and you end up with solutions that don’t perform.

You solve problems by duplicating and precalculating data – which is slow to iterate on – rather than in DAX.

You are looking forward to review several DAX concepts with practical applications you can easily reuse.

You want more DAX tools in your DAX toolbox to help you excel.

Overview

This workshop will advance your DAX skills to bridge the gap between basic and advanced concepts. Through real-world scenarios, you’ll learn to write efficient expressions, solve complex business challenges, and create dynamic, impactful reports with DAX.

Here are a few examples of what you can learn in this workshop:

✅Using OR conditions between slicers in DAX.
✅Creating a slicer that filters multiple columns in Power BI.
✅ Learn how to use REMOVEFILTER / VALUES for “natural” hierarchical calculations.
✅Show updated year-to-date actuals and forecasts in the same chart.
✅When and how to use visual calculations in DAX.
✅Optimize cumulative totals using variables and windows.
✅Implement different types of ranking calculations.
✅Aggregate relative periods (like each new customer''s first 30 days of purchase) efficiently.', 6, 1, 1, 9, N'Auditorium', '2026-05-11T08:30:00', 540, NULL, NULL, 0),
(136, 3, N'Introducing DAX User-Defined Functions (UDF)', N'This SessionDetails introduces the DAX Used-Defined Functions, the new feature announced in 2025!
A user-defined function is a DAX formula with parameters that can return values or tables. Parameters can be passed by value or by expressions. In this session, you learn how to define and consume user-defined functions in your semantic model.', 7, 3, 1, 9, N'Auditorium', '2026-05-12T10:50:00', 60, NULL, NULL, 0),
(137, 3, N'Trenuj, wdrażaj, nadzoruj: techniczny przewodnik po AI w Databricks', N'Warsztat przeprowadzi uczestników przez cały cykl życia modeli uczenia maszynowego - od budowy danych, przez trening i automatyzację, aż po wykorzystanie potencjału AI w rozwiązaniach produkcyjnych. Uczestnicy poznają pełny stack MLOps oparty na środowisku Databricks oraz MLFlow, nauczą się projektować pipeline’y, przygotowywać dane, tworzyć cechy, trenować modele, wdrażać je i monitorować w realnym środowisku.

Warsztat stawia na konkret: praktyczne podejście do architektury ML, feature engineeringu, klasycznych algorytmów, sieci neuronowych i głębokich, CI/CD dla modeli, MLOps i nowoczesnych rozwiązań z obszaru AI. Uczestnicy wyjdą z niego z kompletnym obrazem, jak projektować i utrzymywać systemy ML, które działają, skalują się i nie wybuchają w produkcji.

Zakres warsztatu:
1. Architektura AI/ML - pełny obraz stacku ML, role w procesie i referencyjne architektury chmurowe.
2. Dane - praktyczne przygotowanie, czyszczenie, walidacja i budowanie pipeline’ów.
3. Feature engineering - typy cech, transformacje, feature store, monitoring i drift.
4. Algorytmy ML - przegląd najważniejszych metod i ich zastosowanie w praktyce.
5. Trenowanie modeli - metryki, tuning, podejście distributed, MLflow w akcji.
6. Sieci neuronowe i Deep Learning - podstawy sieci, frameworki, skalowanie, GPU/TPU.
7. Pipeline ML - automatyzacja, CI/CD, orkiestracja i wersjonowanie modeli.
8. MLOps - pełne utrzymanie modeli, monitorowanie, testy, rejestry modeli.

Warsztat jest kierowany do inżynierów, data scientistów i architektów pracujących lub planujących zacząć pracę z ML.

Wymagania:
- Laptop z przeglądarką internetową
- Darmowe konto Databricks Free', 5, 3, 2, 1, N'Room C', '2026-05-11T08:30:00', 540, NULL, NULL, 0),
(138, 3, N'Wykorzystanie CDC MS SQL Server do migracji typu near on-line systemu transakcyjnego', N'Sesja obejmuje opis, zasady migracji systemu transakcyjnego  (tutaj ERP) oraz napotkane problemy.

Zakres migracji to ponad 41 tys. tabel, prawie 10mld wierszy danych, skrócenie czasu niedostępności (przełączenia) systemu z 7 dni do 47 minut.

Napotkane problemy i istotne zagadnienia:

1. metodologia poboru danych z użyciem snapshota bazy danych

2. prawidłowa replikacja transakcji przy użyciu danych z mechanizmu CDC

3. obsługa kilkudziesięciu tysięcy instancji tabel CDC przez system skanujący logi oraz wykonanie i odtworzenie backupu bazy danych.', 7, 4, 2, 16, N'Room D', '2026-05-13T13:40:00', 60, NULL, NULL, 0),
(139, 3, N'Microsoft Fabric i Snowflake - lepiej razem czy lepiej... nie mówić?', N'Snowflake AI Data Cloud zajmuje czołowe miejsce wśród dostępnych na rynku platform danych. Microsoft Fabric jest wciąż nowym produktem, przyciągającym coraz większą atencję klientów każdego miesiąca. W 2024 r. firmy Microsoft i Snowflake ogłosiły rozszerzenie swojego partnerstwa w celu umożliwienia dwukierunkowej wymiany danych między Snowflake i Fabric, zapewniając bardziej wydajne i elastyczne zarządzanie danymi dla klientów korzystających z obu platform w swoich ekosystemach danych. W listopadzie 2025 r. to partnerstwo poszło nawet dalej i doczekaliśmy się m.in. obiektu Snowflake database w Fabric. Ale czy to wszystko gwarantuje dobrą integrację między obiema platformami? Przyjdź na tę sesję, aby dowiedzieć się od praktyków Snowflake i Fabric, jak najlepiej wykorzystać dostępne funkcje do integracji Fabric i Snowflake. Gwarantujemy obszerne demo i praktycznie wnioski z naszych testów i wdrożeń.', 7, 3, 2, 9, N'Room B', '2026-05-13T15:00:00', 60, NULL, NULL, 0),
(140, 3, N'Niedoceniane supermoce Databricks - Nowoczesny proces transfromacji danych', N'Databricks jest nieustannie rozwijany o nowe funkcje, które znacząco upraszczają przetwarzanie i ładowanie danych.
Podczas tej sesji pokażę, jak wykorzystać wbudowane funkcjonalnosci takie jak Auto Loader, Spark Declarative Pieplines (SDP), Structured streaming oraz Lakeflow do budowny nowoczesnego processu data ingestion.
Omówię różne scenariusze wykorzystania Auto Loadera, SDP i (nie tylko), od klasycznego batcha po micro-batch i strumieniowe ładowanie danych z użyciem Structured Streaming – również w kontekście przetwarzania zmian (CDC). Pokażę, że streaming nie musi oznaczać tylko real-time, ale może służyć do optymalizacji batchowych procesów ładowania danych.
W drugiej części sesji przejdziemy przez możliwości orkiestracji pipeline''ów danych z użyciem Databricks Workflows i Pipelines.
Na koniec pokażę, jak połączyć wszystkie te elementy w spójny, skalowalny i łatwy do utrzymania framework data ingestion — gotowy do działania w środowisku enterprise.', 7, 3, 2, 9, N'Auditorium', '2026-05-12T16:50:00', 60, NULL, NULL, 0),
(141, 3, N'Zbuduj inteligentnego agenta w jeden dzień – Copilot Studio w praktyce', N'Celem warsztatu jest tworzenie konwersacyjnych i autonomicznych agentów z wykorzystaniem Microsoft Copilot Studio. Uczestnicy spędzą około 80% czasu na ćwiczeniach praktycznych, tworząc inteligentnych agentów automatyzujących procesy biznesowe, przetwarzających dane multimodalne i generujących dynamiczne, oparte na danych odpowiedzi.

Kluczowe techniki:
•_x0009_Projektowanie i personalizacja agentów z wykorzystaniem narzędzi Microsoft Copilot Studio (flows, plugins, actions)
•_x0009_Uziemianie agentów w Dataverse dla zapewnienia poprawności odpowiedzi
•_x0009_Tworzenie multimodalnych promptów łączących tekst, grafiki i dane tabelaryczne dla zwiększenia precyzji i kontekstu odpowiedzi
•_x0009_Konfiguracja autonomicznych wyzwalaczy zdarzeń dla proaktywnego działania agentów
•_x0009_Wdrażanie zasad Responsible AI, obejmujących filtrację treści, moderację i kontrolę dostępu

Agenda:
•_x0009_Tworzenie agentów w Copilot Studio
•_x0009_Budowa systemów multi-agentowych
•_x0009_Projektowanie agentów autonomicznych
•_x0009_Personalizacja odpowiedzi agentów
•_x0009_Odpowiedzialne AI i zarządzanie treścią
•_x0009_Implementacja funkcji multimodalnych
•_x0009_Ugruntowywanie promptów własnymi danymi

Dostarczone zasoby:
•_x0009_Gotowe przykładowe przepływy agentów (flows) do samodzielnej rozbudowy
•_x0009_Szablony promptów dla scenariuszy konwersacyjnych i multimodalnych
•_x0009_Przykładowe zestawy danych oraz komplety rozwiązań do ćwiczeń

Wymagania:
•_x0009_Laptop z systemem Windows 11
•_x0009_Przeglądarka Microsoft Edge
•_x0009_Konto służbowe Microsoft 365 (konta prywatne, np. @outlook.com, nie są obsługiwane)
•_x0009_Dostęp do Microsoft Copilot Studio (możliwy w ramach bezpłatnej wersji próbnej Copilot Studio)
•_x0009_Środowisko Power Platform z aktywnym Dataverse oraz uprawnieniami administratora (dostępne w ramach bezpłatnej wersji próbnej Copilot Studio)
•_x0009_Licencja Power Automate Premium – niezbędna do korzystania z zaawansowanych konektorów i automatyzacji, w tym integracji z Dataverse (dostępna w ramach bezpłatnej wersji próbnej Copilot Studio)
•_x0009_Podstawowa znajomość środowiska Microsoft 365 (logowanie do Office, Teams itp.)
•_x0009_Podstawowa znajomość środowiska Power Platform', 5, 3, 2, 1, N'Room F (Functional)', '2026-05-11T08:30:00', 540, NULL, NULL, 0),
(142, 3, N'Fast-Track Your Lakehouse Build with a Metadata Framework', N'In today’s data-driven world, fast and efficient data platform delivery is crucial for staying ahead of the competition. Join me for a dynamic SessionDetails that demonstrates how to build a metadata-driven Lakehouse with Microsoft cloud native technologies. Using your preferred compute and storage resources, Azure Data Factory, Azure Databricks, Azure Synapse Analytics or Microsoft Fabric.

Discover how to simplify and overcome common obstacles such as fragmented data ingestion, change data capture, and orchestration scalability using proven best practices. Learn how to leverage automation, open-standards, and seamless cloud integration to accelerate time-to-insight with minimal technical debt. This SessionDetails is perfect for techies and data leaders alike, seeking to streamline their cloud data platform delivery while maintaining cost control and operational resilience. In summary, unlock the potential to build a Lakehouse in a day by using an open-source metadata driven product accelerator.', 7, 3, 1, 9, N'Room B', '2026-05-12T15:30:00', 60, NULL, NULL, 0),
(143, 3, N'Deep Dive: Architektura Systemów Autonomicznych: Microsoft AI Foundry i Wzorce Multi-Agent', N'Jak zaprojektować system, w którym jeden agent zleca zadania drugiemu, a całość nie rozsypuje się przy błędzie API? To sesja poświęcona Agent Control Plane i inżynierii orkiestracji w Microosft AI Foundry. Przeanalizujemy dylemat Code-first (Semantic Kernel/Python SDK) vs Workflow-first (Logic Apps), wchodząc w szczegóły zarządzania stanem (state management) i obsługi długotrwałych procesów asynchronicznych. Zobaczysz implementację wzorców projektowych dla systemów wieloagentowych (Multi-Agent Systems), mechanizmy "tool calling" na poziomie kodu oraz sposoby na debugowanie łańcucha decyzyjnego LLM w środowisku produkcyjnym.

Kluczowe zagadnienia:
- Hybrydowa orkiestracja: łączenie Azure Functions z deklaratywnymi przepływami.
- Zarządzanie cyklem życia agenta w Foundry (CI/CD dla AI).
-Optymalizacja latencji i kosztów w złożonych łańcuchach wywołań (Chain of Thought).', 7, 2, 2, 1, N'Room C', '2026-05-13T09:00:00', 60, NULL, NULL, 0),
(144, 3, N'Power BI meet MCP - what can we get out of it?', N'The Model Context Protocol (MCP) is one of the hottest topics in the GenAI era. It can be seen as a universal translator for AI agents – just as USB ports allow you to connect any device to a computer, MCP allows AI to connect to any tool or service in a standardized way. It''s no surprise, then, that the more advanced the platform, the more capabilities the MCP servers that work with it offer. In this presentation, you''ll learn how to use MCP as a Power BI developer. You''ll also learn what to watch out for when working with MCP servers. I guarantee plenty of demonstrations and maintaining a clear, human perspective despite the AI ​​overload on stage ;-)', 7, 3, 1, 1, N'Room D', '2026-05-12T12:10:00', 60, NULL, NULL, 0),
(145, 3, N'Intelligent Data, Smart Decisions: LLM as the New Standard in Data Management', N'Can you imagine a world where your data describes, catalogues and repairs itself? In this interactive session, we will show you how Large Language Models are transforming the daily work of data professionals.

During this SessionDetails full of live demos, you will see:

-  Automatic cataloguing – how AI creates descriptions of data resources 

- Intelligent quality control – anomaly detection and synthetic data generation

- Semantic discovery – searching for data in natural language without SQL

This is not theory – these are concrete tools that you can implement tomorrow. Get ready for a SessionDetails that will change your approach to data management and show you the future, or rather the present, of this field.', 7, 3, 2, 6, N'Room A', '2026-05-13T09:00:00', 60, NULL, NULL, 0),
(146, 3, N'The Missing Runtime: AI That Acts. Not Just Chats.', N'Most LLM-based agents today operate on prompts, not on data. They can generate insights, but they struggle to act inside real systems because they lack identity, state and deterministic execution boundaries. In data-driven environments — real-time analytics, monitoring, automation — this makes them unreliable.

This SessionDetails introduces the Decision Intelligence Runtime (DIR): a vendor-agnostic, architecture-first approach that turns an LLM into a decision engine operating on event streams, stored state, policies and deterministic validators.
DIR treats autonomy as a data problem, not a prompting technique.

To ground these concepts in reality, I will demonstrate the architecture behind AIvestor — a multi-agent ecosystem operating on live market streams. The focus is not on trading strategies, but on using financial markets as the ultimate adversarial environment: noisy, high-frequency and unforgiving. This makes them a perfect stress test for evaluating safety, state consistency and decision integrity where standard frameworks fail.

You will learn:

1. Why prompt-driven agents fail, and how DIR enables Responsibility-Oriented Agents with long-lived identity.

2. How the DIR loop works (Explain → Policy → Validate → Execute) to isolate probabilistic reasoning from deterministic action.

3. How to maintain agent state in an event-driven, data-first architecture.

4. Human-in-the-Loop 2.0: intent as input, escalation as output — not the usual “approve the LLM output” pattern.

5. How to coordinate multiple agents using an Event-Oriented Agent Mesh.

This talk is for architects and engineers working with data systems, real-time pipelines and AI-driven decision automation, who want to build AI that does things — not just talks about things.', 7, 1, 2, 1, N'Room D', '2026-05-13T15:00:00', 60, NULL, NULL, 0),
(147, 3, N'Jak budować skalowalne rozwiązania w Databricks: podróż z notebooków do pakietów', N'W świecie Data Engineeringu notebooki od lat były moim codziennym narzędziem do tworzenia procesów ETL w środowisku Azure Databricks i stanowiły świetny start do pracy. Ale w miarę jak projekty rosły zaczęły się pojawiają problemy z brakiem modularności, a testowanie stawało się wyzwaniem.
W tej prelekcji opowiem historię, dlaczego i jak z perspektywy inżyniera danych przeszłam od notebooków do pakietów w Databricks i jak zmieniło to mój sposób pracy. Zaprezentuję, jak wygląda praktyczna praca w Visual Studio Code od struktury repozytorium, przez organizację kodu modułowego, konfigurację środowiska venv do uruchamiania testów i pakietu.
To prezentacja dla każdego, kto czuje, że notebooki przestają mu wystarczać i chce zobaczyć, jak inaczej może wyglądać praca z kodem. Dostaniesz wskazówki, jak zrobić pierwsze kroki i uniknąć typowych błędów.', 7, 3, 2, 9, N'Room C', '2026-05-13T10:20:00', 60, NULL, NULL, 0),
(148, 3, N'Spark Tuning & Best Practices: From Theory to Production-Ready Performance', N'in-depth exploration of Apache Spark optimization techniques drawn from real-world production experience at Unity. This SessionDetails bridges the gap between Spark fundamentals and practical performance tuning strategies that can dramatically improve your data processing pipelines.

What You''ll Learn:

- Understanding Spark Architecture: Deep dive into executors, RDDs, and how Spark processes data across distributed clusters

- Tackling Data Skew: Learn to identify and resolve one of the most common performance bottlenecks, including:
  - Adaptive Query Execution (AQE) strategies
  - Manual salting techniques
  - Handling null keys in joins
  - Real case study: How we reduced a 6-hour job to under 3 hours

- Query Optimization Techniques:
  - Proper partition key usage and filtering strategies
  - Join optimization (Broadcast vs. Shuffle joins)
  - Shuffle partition tuning for optimal performance
  - Understanding Coalesce vs. Repartition trade-offs

- Memory Management: Configure executor and driver memory for stability and performance

- Production Case Studies: Real-world examples from Unity''s data infrastructure, including challenges faced and solutions implemented

Who Should Attend:
This SessionDetails is ideal for data engineers, data scientists, and analytics engineers who work with Spark and want to move beyond basic implementations to production-grade, optimized pipelines. Whether you''re struggling with slow jobs, OOM errors, or data skew issues, you''ll leave with actionable strategies to improve your Spark applications.

Key Takeaway:
Learn how to diagnose performance issues, understand the "why" behind Spark''s behavior, and apply proven optimization patterns that can reduce job execution time from hours to minutes.', 7, 3, 1, 15, N'Room A', '2026-05-12T15:30:00', 60, NULL, NULL, 0),
(149, 3, N'Are your semantic models ready for Copilot?', N'Most Power BI semantic models were built before Copilot existed. They still deliver value and valuable insights. Imagine that your manager tell you that you should enable Copilot for Power BI and make consumers more productive - what do you do?
Simply turning on Copilot for existing models won’t guarantee results. Why? Because Copilot relies on well-structured, optimized semantic models to deliver meaningful insights and efficiencies.
In this session, you’ll learn:
• Why preparation matters: Understand the limitations of “as-is” models and what Copilot needs to shine.
• Best practices for optimization: Practical steps to make your semantic models Copilot-ready.
• Ways to consume models with Copilot and Agents: Explore different integration scenarios and user experiences.

Whether you’re a BI professional, data modeler, or decision-maker, this SessionDetails will equip you with actionable strategies to maximize Copilot’s impact on your organization. This SessionDetails will include live demos, including optimizing models for Copilot and consuming Copilot.', 7, 1, 1, 1, N'Room D', '2026-05-12T16:50:00', 60, NULL, NULL, 0),
(150, 3, N'Design patterns in Data Engineering', N'Cześć, jestem tu dziś jako Leszek Michalak z DAMA chapter Poland.
DAMA — Data Management Association — to międzynarodowa organizacja skupiająca praktyków zarządzania danymi. Jej misją jest promowanie najlepszych praktyk w tym jak dane są zbierane, przechowywane, chronione i wykorzystywane w organizacjach.
A ja dziś mam pokrewny temat, leżący u podstaw Data Governance, mówiący o tym, że bez dobrych danych, jasnych procedur i odpowiedniego zarządzania nimi — nie będzie niczego. Żadnej analityki, żadnego AI, żadnych decyzji opartych na faktach.
Opowiem o data engineering — a konkretnie o tym, jak nie wynajdować koła na nowo.
Moja prezentacja to Design Patterns in Data Engineering — wzorce projektowe, które rozwiązują powtarzające się problemy w budowie pipeline''ów danych. Tak jak w architekturze oprogramowania mamy wzorce GoF, tak w inżynierii danych mamy sprawdzone schematy: medallion architecture, event sourcing, CDC, idempotent writes i wiele innych.
Bo dane bez struktury to tylko szum. A dobry wzorzec to różnica między pipeline''em, który działa — a takim, który działa niezawodnie.', 7, 4, 2, 6, N'Room B', '2026-05-13T11:40:00', 60, NULL, NULL, 0),
(151, 3, N'Your first SQL Database implementation in Microsoft Fabric', N'In this session, Kamil, a seasoned data engineer with over two decades of expertise in data (SQL Server, Azure SQL, and now Fabric), shares his view on the new database capabilities in Microsoft Fabric.
In this session, you will learn enough about Fabric and SQL database (not Warehouse) concepts to start building your own solutions immediately.
The SessionDetails starts with a few theoretical concepts to provide guidelines and is then filled with practical examples.
We will go through everything important when it comes to SQL Database: managing objects from UI, syncing code with Git, developing code with VSCode, using built-in Graph API for applications and also deploying to other environments.
During the session, we will think about what typical scenarios or use cases might be used together with SQL Database in Fabric.', 7, 3, 2, 15, N'Room A', '2026-05-12T12:10:00', 60, NULL, NULL, 0),
(152, 3, N'Query Performance Enhancements in SQL Server 2025', N'Query tuning has always been a challenge. There is always so much to learn and understand in order to identify where your bottlenecks may be and then know how to address them. While SQL Server 2025 may not make query performance improvement easy, it certainly does make it easier. Come to this SessionDetails to learn how various enhancements from improvements in Parameter Sensitive Plans (aka Parameter Sniffing) to Optimized Locking, all come together in SQL Server 2025 to help your queries run faster. You''ll learn which of these improvements is on by default, and which ones you may want to switch on. Along the way we''ll even talk a little Extended Events and some DMVs. You can make SQL Server run faster, and 2025 will help you along that path.', 7, 3, 1, 15, N'Room D', '2026-05-13T09:00:00', 60, NULL, NULL, 0),
(153, 3, N'Konwersacyjna analiza danych z Fabric Data Agents', N'Sesja prezentuje architekturę i możliwości Microsoft Fabric Data Agents, komponentu umożliwiającego wykonywanie zapytań analitycznych w języku naturalnym poprzez wykorzystanie dużych modeli językowych (LLM) do generowania semantycznie poprawnych zapytań SQL czy KQL.
Omówiony zostanie psposób działania agentów: interpretacja pytań użytkownika, mapowanie intencji na odpowiednie źródło danych w OneLake (lakehouse, warehouse, model semantyczny Power BI), generacja zapytań, a następnie zwrócenie ustrukturyzowanej odpowiedzi w postaci tabeli, wizualizacji lub podsumowania tekstowego.
Uczestnicy zapoznają się z mechanizmami konfiguracyjnymi agenta.
Część demonstracyjna obejmie scenariusze end‑to‑end: budowę agenta, definiowanie źródeł danych i instrukcji, oraz jego testowanie.
Na zakończenie przedstawione zostaną rekomendacje dotyczące tworzenia Fabric Data Agents.', 7, 3, 2, 1, N'Room B', '2026-05-12T14:10:00', 60, NULL, NULL, 0),
(154, 3, N'Hidden Gems of SQL Server 2025', N'SQL Server 2025 is now generally available, packed with headline-grabbing features like built-in AI capabilities, Microsoft Fabric integration, native JSON data type with advanced functions, vector database, regular expressions, and more. These features are exciting and well-covered in official releases, blogs, and announcements.
However, as with every major SQL Server version, the real treasures often lie in the smaller, lesser-known enhancements that don''t make the front-page news - yet provide significant everyday benefits for DBAs, developers, and architects.
In this session, we''ll dive deep into some of these hidden gems: subtle but powerful improvements in performance tuning, security, availability, tempdb optimizations, In-Memory data management, diagnostics, and other engine areas, which make our daily work a bit more pleasant.
What exactly are they? That''s the surprise - join me to uncover them together through demos and real-world examples! You''ll leave armed with practical, low-effort upgrades you can apply immediately to make your SQL Server instances more efficient, stable, and easier to manage.', 7, 3, 1, 15, N'Room D', '2026-05-13T11:40:00', 60, NULL, NULL, 0),
(155, 3, N'Lakehouse Federation w praktyce: Azure Databricks i Microsoft Fabric', N'W nowoczesnych architekturach enterprise Azure Databricks coraz częściej stanowi centralną platformę dla inżynierii danych, zaawansowanych transformacji, CDC, streamingu oraz trenowania modeli ML/AI. Jednocześnie organizacje potrzebują szybkiego dostępu do tych samych danych dla analityki biznesowej, decyzji operacyjnych i raportowania – bez kosztownej replikacji i ryzykownych migracji.

Podczas tej sesji zobaczymy, jak Lakehouse Federation umożliwia połączenie Databricks jako silnika „system of data engineering” z Microsoft Fabric jako warstwą konsumpcji analitycznej i Real‑Time Intelligence. Zagłębimy się w techniczne mechanizmy federacji: interoperacyjność formatów Delta Lake, ścieżkę odczytu Direct Lake przez OneLake Shortcuts, granice predicate push‑down, spójność snapshotów oraz rzeczywiste konsekwencje wydajnościowe.

Omówimy także model governance i bezpieczeństwa w środowisku multi‑engine: role Unity Catalog w egzekwowaniu polityk dostępu oraz Microsoft Purview w zakresie lineage, klasyfikacji i zgodności.', 7, 1, 2, 6, N'Auditorium', '2026-05-12T12:10:00', 60, NULL, NULL, 0),
(156, 3, N'End-to-end Monitoring for Microsoft Fabric', N'Keeping your Microsoft Fabric environment healthy requires visibility across dataflows, pipelines, real‑time ingestion, semantic models, and user activity.

In this session, we take an end‑to‑end tour of the monitoring capabilities available in Fabric today. We’ll explore how the Real‑Time Hub helps you track event streams and data activations as they happen, how Workspace Monitoring exposes detailed workload‑level insights, and how the Monitoring Hub centralizes operational signals across capacities, items, and execution history.

We’ll also look at open‑source community accelerators that extend Fabric’s monitoring story with advanced dashboards, log enrichment, and deeper operational observability.

By the end, you’ll know how to combine these tools into a unified monitoring strategy that supports proactive troubleshooting, capacity planning, and reliable enterprise‑scale Fabric operations.', 7, 3, 1, 6, N'Room B', '2026-05-12T16:50:00', 60, NULL, NULL, 0),
(157, 3, N'Tempdb w SQL Server – architektura, mechanizmy wewnętrzne, dobre praktyki i nowości', N'Tempdb jest jednym z kluczowych elementów architektury SQL Server, który jest niedocenianą bezą danych w SQLServer przez co jest jednym z najczęstszych źródeł wąskich gardeł w środowiskach produkcyjnych. Podczas sesji przeanalizujemy wewnętrzne mechanizmy działania tempdb — model alokacji stron i extentów, strukturę PFS/GAM/SGAM, sposób obsługi metadanych obiektów tymczasowych oraz architekturę Version Store wykorzystywanego w RCSI i Snapshot Isolation.
Skupimy się na scenariuszach prowadzących do PAGELATCH contention, problemach z metadanymi (w tym zmianach w nowszych wersjach SQL Server), nadmiernym obciążeniu I/O i logu tempdb oraz niekontrolowanym growth. Na przykładach produkcyjnych workloadów omówimy wzorce zapytań i operacji, które generują największy load na tempdb, w szczególności: hash spill, sort spill, worktables, operacje indeksowe oraz row versioning.
Część diagnostyczna obejmuje praktyczne wykorzystanie DMV, waits i latch analysis, korelację z planami wykonania oraz zastosowanie Extended Events do identyfikacji źródeł contention i nadmiernego zużycia przestrzeni. W drugiej części przedstawione zostaną zweryfikowane w praktyce dobre praktyki konfiguracji tempdb (liczba i rozmiar plików, autogrowth, storage layout, log behavior) oraz techniki ograniczania obciążenia poprzez modyfikację zapytań i wzorców aplikacyjnych.
Sesja przeznaczona jest dla DBA i inżynierów wydajności pracujących w środowiskach produkcyjnych; zawiera real-world troubleshooting, metody diagnostyczne i rekomendacje, które można zastosować bezpośrednio po konferencji. Sesja będzie zawierać gotowe skrypty SQL, szablony monitorowania i praktyczne case studies. Idealna dla DBA''ów i Senior SQL Server Administratorów chcących opanować krytyczną część infrastruktury SQL Server.', 7, 1, 2, 16, N'Room B', '2026-05-12T10:50:00', 60, NULL, NULL, 0),
(158, 3, N'JSON w SQL Server 2025 - wydajność silnika, indeksy i zaawansowane wzorce użycia', N'SQL Server oferuje zaawansowane mechanizmy pracy z danymi półstrukturalnymi, w których JSON przestaje być jedynie formatem wymiany, a staje się pełnoprawnym typem danych przetwarzanym bezpośrednio przez silnik bazy danych. Podczas sesji analizowane są wewnętrzne aspekty obsługi JSON - sposób przechowywania danych, mechanizmy optymalizacji dostępu oraz wpływ tych rozwiązań na plany zapytań, koszty operacji i zużycie zasobów.

Istotną część prezentacji stanowić będą dedykowane indeksy JSON, rozpatrywane z perspektywy ich implementacji, zasad wykorzystania przez optymalizator oraz wpływu na charakterystykę wydajnościową zapytań w scenariuszach filtrowania i wyszukiwania danych wewnątrz dokumentów. Przedstawione zostaje również przetwarzanie całych struktur JSON z użyciem funkcji takich jak JSON_CONTAINS, a także konsekwencje rozszerzonej zgodności ze standardem ANSI SQL dla złożonych ścieżek i operacji na tablicach.

Sesja ma charakter głęboko techniczny - obejmuje analizę execution planów, porównanie wzorców projektowych (JSON vs model relacyjny) oraz scenariusze architektoniczne, w których SQL Server pełni rolę silnika przetwarzania danych półstrukturalnych w systemach integracyjnych i event-driven, z naciskiem na świadome decyzje projektowe i ich skutki wydajnościowe.', 7, 1, 2, 15, N'Room C', '2026-05-13T15:00:00', 60, NULL, NULL, 0),
(159, 3, N'Medallion Architecture i Clickhouse - czyli klasyka zupełnie inaczej', N'ClickHouse to jedna z najszybszych analitycznych baz danych, używana przez gigantów takich jak Cloudflare, Netflix czy Tesla do przetwarzania miliardów wierszy na sekundę. Jej unikatowe mechanizmy składowania i przetwarzania danych sprawiają, że implementacja sprawdzonych wzorców, takich jak Medallion Architecture, wymaga zmiany paradygmatu. Zamiast budować klasyczne, ciężkie procesy ETL/ELT, ClickHouse promuje podejście „real-time by design”.
W trakcie sesji dowiesz się, jak zaprojektować architekturę, która jest nie tylko wydajna, ale też prostsza w utrzymaniu i tańsza niż „klasyczne” rozwiązania analityczne. Pokażę, jak w praktyce wykorzystać silniki integracyjne (Integration Engines), tabele z rodziny MergeTree oraz widoki zmaterializowane (Materialized Views) do budowy warstw danych Bronze, Silver i Gold w projektach BI.', 7, 3, 2, 6, N'Room D', '2026-05-12T10:50:00', 60, NULL, NULL, 0),
(160, 3, N'Jak budować platformy danych na Azure', N'Przez ostatnie 3 lata mialem przywilej budować nie jedna, a dwie platformy danych, co dało mi unikalny zestaw doświadczeń z tym związanych. Na ten sesji opowiem o moich doświadczeniach, o podejście jakie ja z moim zespolem stosujemy podczas budowania platform od zera, gdzie są różnice od tego opisanego w Cloud Adoption Framework, i jak się maja realia do znanego podejścia Data Landing Zones.', 7, 1, 2, 6, N'Auditorium', '2026-05-13T13:40:00', 60, NULL, NULL, 0),
(161, 3, N'Elevating Microsoft Fabric Performance to the Maximum', N'Microsoft Fabric provides powerful capabilities for analytics and data processing, but achieving optimal performance requires targeted optimization strategies. This SessionDetails explores advanced techniques to maximize the efficiency, speed, and scalability of Fabric workloads across notebooks, data pipelines, Power BI reports, and lakehouse operations.

This SessionDetails covers capacity selection and scaling best practices; query optimization in Spark and SQL endpoints; effective partitioning, caching and materialization strategies; pipeline orchestration for reduced latency; monitoring tools such as Spark UI, common performance bottlenecks and their resolution, plus real-world tuning examples to achieve peak throughput and cost efficiency.
Ideal for data engineers, architects, and administrators seeking practical guidance to elevate Microsoft Fabric environments to their highest performance levels.', 7, 1, 2, 9, N'Room D', '2026-05-12T14:10:00', 60, NULL, NULL, 0),
(162, 3, N'Zarządzanie uprawnieniami w Databricks/Azure w dużej organizacji', N'Zarządzanie uprawnieniami to zawsze gorący temat, zwłaszcza w organizacji, która ma wiele deweloperów, projektów, inicjatyw i użytkowników biznesowych.
Zazwyczaj pomysłów na zarządzanie uprawnieniami jest wiele.
Na tej sesji dowiesz się jak zarządzać uprawnieniami w Azure i Azure Databricks, jak to zostało zaimplementowane w jednej z dużych organizacji, jakie były wyzwania i wymogi regulacyjne oraz jakie metody procesowe i technologiczne zostały użyte (a jakie odrzucone) by sprostać tym wymaganiom.', 7, 3, 2, 6, N'Room D', '2026-05-12T15:30:00', 60, NULL, NULL, 0),
(163, 3, N'How to adapt as a data professional in the era of AI', N'„ The Matrix is everywhere. It is all around us. Even now, in this very room”. Remember this famous quote from the Matrix movie? Well, you could say the same about AI today. It’s everywhere around us „jumping out of the refrigerator”. It’s clear that because of AI our lives won’t be the same anymore, also as data professionals. In this keynote SessionDetails I will focus on skills every data professional should develop to stay ahead of the game and not get crazy in the era of AI.', 3, 3, 1, 16, NULL, NULL, NULL, NULL, NULL, 0),
(164, 3, N'Kto tu jest problemem: Data czy reszta IT?', N'Projekty data mają dziwną supermoc: potrafią wkurzyć backend, infrę, i security… jednocześnie. I zwykle nie chodzi o „złych ludzi”, tylko o zderzenie światów: inne definicje „done”, inne tempo, inne ryzyka i inne wyobrażenie, kto za co odpowiada. W tej sesji rozkładam na czynniki pierwsze tytułowe: Kto tu jest problemem - Data czy reszta IT?

Będzie trochę roastu, trochę „to zależy”, i sporo rzeczy, które wszyscy czują, ale rzadko mówią na głos. Pogrzebiemy w miejscach, gdzie najczęściej robi się gorąco, i sprawdzimy, co w praktyce działa, gdy chcesz dowieźć data bez wojny domowej w IT. Jeśli masz choć jedno „serio znowu to samo?” po projekcie data - wpadaj.', 7, 3, 2, 16, N'Auditorium', '2026-05-13T15:00:00', 60, NULL, NULL, 0),
(165, 3, N'From SQL Agent to Livy API: programmatic Spark orchestration in Microsoft Fabric', N'You mastered SQL Agent jobs and SSIS packages. You built reliable ETL pipelines that run for years. Now Microsoft Fabric brings Apache Spark into your data platform, and suddenly the rules feel different.

This SessionDetails bridges that gap. We will explore how Spark Job Definitions and Notebooks fit into Fabric''s architecture, then go deeper into the Livy API for programmatic job control. Think of Livy as your new sp_start_job, but for distributed compute.

You will see how to submit Spark jobs from external systems, poll for completion, capture logs, and build retry logic that matches the reliability you expect from SQL Server workloads. Live demos will show real integration patterns: triggering Spark from Azure Functions, coordinating with Data Factory, and building custom monitoring dashboards.

If you are a data professional expanding from T-SQL into Spark, this SessionDetails gives you the control layer you have been missing.', 7, 3, 1, 9, N'Room B', '2026-05-13T13:40:00', 60, NULL, NULL, 0),
(166, 3, N'Przygotowanie obrazów dla modeli multimodalnych na przykładzie projektu odczytu liczników energii', N'Coraz częściej do zadań związanych z wizją komputerową używane są multimodalne duże modele językowe. Często uważa się, że tego typu modele są w stanie przyjąć dowolne dane wejściowe, jednak podobnie jak w klasycznych modelach uczenia maszynowego, niska jakość danych wejściowych prowadzi do słabych wyników, zgodnie z zasadą "garbage in, garbage out". W tej prezentacji przedstawię wnioski z projektu odczytu liczników z fotografii, koncentrując się na kluczowych krokach przygotowujących obrazy do użycia w LLM-ach, aby uzyskać wysoką skuteczność.', 7, 3, 2, 1, N'Room A', '2026-05-13T13:40:00', 60, NULL, NULL, 0),
(167, 3, N'MERGE w Databricks: dlaczego poprawny wynik nie zawsze jest poprawny', N'MERGE INTO jest jednym z najczęściej używanych mechanizmów w Databricks i Delta Lake. Dla wielu zespołów stał się podstawą budowy warstw Silver i Gold. Problem w tym, że MERGE bardzo często nie zachowuje się tak, jak zakładają projektanci pipeline’ów.

W tej sesji pokażę:
dlaczego MERGE nie jest deterministyczny w wielu realnych scenariuszach,
jak race conditions i wielokrotne dopasowania źródła prowadzą do cichych błędów,
co dzieje się przy retry, replay i late-arriving data,
dlaczego „działa” nie oznacza „jest poprawne”.

Na konkretnych przykładach omówimy, w jakich warunkach MERGE:
łamie idempotency,
produkuje niespójne wyniki,
utrudnia odtworzenie stanu danych.

Sesja nie jest tutorialem SQL, lecz analizą poprawności przetwarzania danych w systemie rozproszonym. Jej celem jest pokazanie, kiedy MERGE ma sens, a kiedy należy zmienić wzorzec architektoniczny.', 7, 1, 2, 16, N'Room D', '2026-05-13T10:20:00', 60, NULL, NULL, 0),
(168, 3, N'Fabric Private Link - Setup, Limitations and Recommendation', N'Microsoft Fabric without public internet access is still a relatively uncommon model, yet the demand for fully private analytics platforms is rapidly growing. This SessionDetails demonstrates how Microsoft Fabric operates in a tenant-wide Private Link configuration, how it differs from the default public setup, and which limitations must be taken into account. Based on real implementation experience, it also shows how to properly analyze an existing Fabric environment and which aspects are critical to evaluate before enabling Private Link. The SessionDetails further covers Managed Virtual Network, the VNet Data Gateway as the only supported gateway option, the recommended architectural approach to Private Link implementation, and a hybrid alternative using per-workspace inbound and outbound networking.', 7, 2, 2, 9, N'Room C', '2026-05-12T15:30:00', 60, NULL, NULL, 0),
(169, 3, N'Adding PostgreSQL to your SQL Server Skill Set', N'More organizations are adding PostgreSQL to their technology stack than ever before. The challenge is that they are not immediately replacing their existing technology, which means more and more people need to understand both SQL Server and PostgreSQL. This all-day class is explicitly designed to support people who already know SQL Server as they begin their journey to add PostgreSQL to their skill set. We’ll cover the areas of overlap between the two platforms, as well as all the differences that can make learning PostgreSQL a challenge. Not only does this all-day class teach PostgreSQL, but it also explores tooling, documentation, the cloud, and other resources to help on the journey of adding PostgreSQL to an existing SQL Server skill set.', 6, 4, 1, 15, N'Room B', '2026-05-11T08:30:00', 540, NULL, NULL, 0),
(170, 3, N'Bez kodu, bez kompromisów: transformacja danych w Coalesce', N'Praktyczna sesja poświęconą możliwościom platformy Coalesce, nowoczesnego narzędzia do transformacji danych. Podczas spotkania pokażemy, jak Coalesce umożliwia zespołom bardziej efektywne budowanie, wdrażanie i zarządzanie potokami danych, jednocześnie zapewniając spójność, transparentność oraz wysoką wydajność w złożonych środowiskach danych.
 Jak wykorzystywać Coalesce w codziennej pracy? W jaki sposób wykorzystać AI do transformacji danych i wsparcia data governance? Jak zapewnić wysoką jakość i pełną kontrolę nad danymi oraz procesami transformacji w organizacji? Na te i inne pytania odpowiemy w trakcie sesji.', 7, 4, 2, 9, N'Room A', '2026-05-13T11:40:00', 60, NULL, NULL, 0),
(171, 3, N'Co gryzie Harolda Paina? Decision Intelligence z użyciem Fabric, Power Platform i GenAI', N'Harold the Pain jest użytkownikiem biznesowym, który na co dzień korzysta z przygotowywanych dla niego danych i na ich podstawie podejmuje kluczowe decyzje biznesowe.

Na bazie tej persony pokażemy, jak przejść od klasycznego raportowania do podejścia Decision Intelligence, które realnie wspiera proces podejmowania decyzji poprzez wzbogacenie istniejących procesów raportowych o automatyzację i GenAI.

W trakcie sesji zaprezentujemy również praktyczne zastosowanie integracji Microsoft Fabric z Power Platform i GenAI, pokazując, w jaki sposób takie podejście może:

skraca czas od danych do decyzji,
ograniczyć ręczne przetwarzanie danych,
poprawić jakość i spójność informacji,
łączy perspektywę danych, biznesu i procesów,
usprawnić współpracę między działami,
wspiera w podejmowaniu lepszych decyzji,
poprawia User Experiences, buduje adopcje i zaangażowanie', 7, 3, 2, 9, N'Room C', '2026-05-13T13:40:00', 60, NULL, NULL, 0),
(172, 3, N'Build Better Semantic Models Faster: AI, Automation, and the New Tabular Editor CLI', N'The way we build semantic models is changing quickly. In this session, we''ll take you on a hands-on journey from traditional manual development to AI-assisted and agentic workflows, and show you exactly how Tabular Editor 3 powers every step of that journey.

First, we''ll introduce the AI Assistant in Tabular Editor 3: an integrated, bring-your-own-model experience that helps you write DAX, generate C# scripts, create Best Practice Rules, analyze errors, and get guidance - all without leaving your development environment.

Then we go further. We''ll introduce the brand-new Tabular Editor CLI, a semantic model command-line tool built for humans but optimized for agents. Designed to run on Windows, Mac, and Linux, the CLI enables powerful automation scenarios: CI/CD pipelines, scripted bulk operations, and agentic development with coding agents such as Claude Code or GitHub Copilot. We''ll walk through practical examples showing how agents can use the CLI to read, query, and modify semantic models, doing in minutes what would otherwise take hours.

Whether you''re looking to automate repetitive tasks, integrate semantic model development into your DevOps workflows, or explore agentic development in practice, this SessionDetails provides the tools, concepts, and demos to get started.

You''ll leave with:
•_x0009_A clear mental model of AI-assisted vs. agentic development and when to use each
•_x0009_Hands-on insight into the Tabular Editor 3 AI Assistant
•_x0009_A first look at the new Tabular Editor CLI and how to use it for automation and agentic workflows', 7, 3, 1, 9, N'Auditorium', '2026-05-13T10:20:00', 60, NULL, NULL, 0),
(173, 3, N'Jak nauczyłem AI budować dashboardy - i dlaczego tyle razy się pomylił zanim się nauczył', N'Format zapisu Power BI do .pbip otworzył drogę do budowy dashboardów przy wsparciu AI, ale szybko okazuje się, że „działający kod” i „działające rozwiązanie” to dwie różne rzeczy. AI generuje poprawne fragmenty, ale może nie radzić sobie ze spójnością między modelem (np. budowanym w Tabular Editor), warstwą wizualną i mockupami przygotowanymi w innych narzędziach. Dokładanie promptów, referencji czy tzw. SKILLS nie rozwiązuje problemu – jedne błędy znikają, a inne pojawiają się. W tej sesji pokażemy, dlaczego problem nie leży w samym modelu AI, tylko w braku kontroli nad procesem wytwarzania. Przedstawimy podejście oparte na połączeniu pipeline’u, „SKILLS” oraz wielopoziomowej walidacji działającej w pętli: generate → validate → diagnose → fix, w którym dedykowany agent AI wspiera ten proces. Całość pokażemy na przykładzie budowy raportu Power BI – od wymagań do cicd na Fabric (lub tylko do uruchomienia raportu na desktopie).', 7, 3, 2, 9, N'Auditorium', '2026-05-13T09:00:00', 60, NULL, NULL, 0),
(174, 3, N'The Hidden Cost of Bad Prompts', N'A Practical Guide to Prompt Engineering for SQL, Fabric, and Power BI Professionals.

Berry Wand has a problem. Six months into her role as Chief Data Officer for a leading police force, the data culture work is paying off, leadership is bought in, governance is tightening, and her team is finally being asked the right questions. The new problem is that her team cannot answer them fast enough.

Microsoft Fabric is in. Copilot licences have been procured. Power BI is the standard. The tools are in place. And yet, when Berry watches her senior analysts work, she notices the same thing every time. They write a one-line prompt. They get back something that is almost right. They spend the next twenty minutes editing the output into something usable. By the time they are done, they could have written it from scratch faster.

Berry’s team has not been trained in prompt engineering. They have been trained in DAX, in T-SQL, in Power BI semantic modelling, in Fabric architecture. The prompting, they have been left to figure out for themselves. And the gap between what good prompting produces and what one-line prompting produces, multiplied by every analyst on her team, every working day, is the largest unrecognised productivity cost in her department.

Then she heard about a SessionDetails at SQLDay focused on prompt engineering for data professionals. Not generic “10 ChatGPT hacks” content. Not a vendor demo. A working set of frameworks, tested in real engagements, designed for the work data professionals actually do.

She arrived ready to take notes for her team.

In this session, Berry learned:

›  Why most “bad AI output” is actually a prompting problem, and how to spot it in five seconds

›  The five core prompt frameworks every data professional should know (RTF, BAB, CARE, CRIT, RISE) and when to reach for each

›  Worked examples for the work that fills the week: writing DAX, drafting technical documentation, reviewing PRs, building Power BI report descriptions, generating test data, summarising stakeholder meetings

›  Grounding: how to point Copilot at the right SharePoint folder, Fabric workspace, or document so you stop getting averaged, generic output

›  The prompt library pattern that turns one-person productivity gains into team-level capability

›  What to teach a data team first if you have one hour, one day, or one quarter to lift them out of “ad-hoc” prompting

Berry left with three things: a framework reference her analysts could open on a second monitor on Monday morning, the language to explain to her CIO why the Copilot licence cost is the smaller half of the AI investment, and a working prompt library template she could share with her team that afternoon.

This SessionDetails is for SQL Server, Fabric, and Power BI professionals who have access to Copilot or another enterprise AI tool, are getting middling results from it, and suspect there is a better way. It is not for AI specialists or prompt engineering consultants. It is for the people doing the actual data work, who need AI to make that work measurably faster without the output needing to be rewritten before it can be used.

Attendees will receive a free reference PDF covering the nine prompt frameworks discussed, plus access to the prompt library template referenced in the session.', 7, 4, 1, 6, N'Room C', '2026-05-12T16:50:00', 60, NULL, NULL, 0),
(175, 3, N'Talk-to-data zamiast tradycyjnych dashbordów', N'W dobie Generative AI i Agentic AI rola tradycyjnych dashbordów BI traci na znaczeniu. Dashboardy odpowiadają na pytania, które już znamy. AI odpowiada na pytania, których jeszcze nie zadaliśmy.

Omówimy w jaki sposób można zbudować rozwiązanie oparte na architekturze agentów SI, jaką role odgrywa model semantyczny i jak go dobrze zbudować; co oznacza „governance” w rozwiązaniu opartym na Agentach SI;  oraz jak finalnie może wyglądać nowoczesne rozwiązanie wspomagające proces podejmowania decyzji w biznesie zastępujące tradycyjne dashboardy BI.', 7, 3, 2, 1, N'Auditorium', '2026-05-12T14:10:00', 60, NULL, NULL, 0),
(176, 3, N'SMT Stories: SQL Server Tuning from the Trenches', N'Let’s talk about real-world SQL Server performance tuning challenges and the lessons learned while solving them. This SessionDetails will focus on practical customer cases, unusual performance problems, and the methods used to diagnose and resolve them.

Topics will include tracing the impact of synchronous and asynchronous statistics updates on execution plans, investigating background task issues during Columnstore index builds, monitoring and optimizing recursive triggers containing and other cases.', 7, 3, 1, 15, N'Room B', '2026-05-13T10:20:00', 60, NULL, NULL, 0),
(177, 4, N'Plany zapytań - omówienie komponentów', N'Krótkie omówienie najważniejszych komponentów planów zapytań w SQL Server. Z wykładu dowiesz się, które operatory powinny spędzać Ci sen z powiek, które lepiej wymienić na inne, a które mogą zostać Twoimi przyjaciółmi.', 2, 1, 2, 12, NULL, NULL, NULL, NULL, NULL, 0),
(178, 4, N'Microsoft Fabric REST API: Possibilities and challenges', N'The Microsoft Fabric REST API offers a powerful interface for developers to programmatically interact with Microsoft Fabric services, enabling automation, data integration, and enhanced workflows. Participants will gain insights into the core functionalities of the API, such as querying datasets, managing resources, and orchestrating complex workflows. However, the SessionDetails also addresses the challenges that come with leveraging this API, such as authentication complexities, rate limiting, and handling large datasets efficiently. Attendees will learn best practices for overcoming these challenges, ensuring secure and optimal use of the API. You can expect both, useful knowledge and practical demonstrations.', 2, 3, 2, 3, N'Marian Rejewski', '2024-10-19T15:45:00', 45, NULL, NULL, 5),
(179, 4, N'Ai powered semantic search in your Database', N'This presentation will delve into the realm of semantic search within Elasticsearch databases. Exploring the intersection of advanced search techniques and machine learning, we will discuss the power of leveraging semantic understanding to enhance search capabilities. We will navigate through practical examples using simple architecture to integrate pre-trained models with Elasticsearch and to alter the way we interact with database.', 2, 3, 2, 2, N'Mistrz Twardowski', '2024-10-19T14:45:00', 45, NULL, NULL, 3),
(180, 4, N'Monitorowanie SQL Server - narzędzia, analiza i life-hacks', N'Obserwacja działania SQL Server to jedno z ważnych zadań administratora. Serwer generuje mnóstwo danych o swoim funkcjonowaniu poprzez widoki DMV, liczniki wydajnościowe, Query Store, XE, audyty i wiele, wiele innych. Jak zebrać je wszystkie razem i nie tracić dużo czasu na analizę? W trakcie sesji zaprezentuję narzędzia oraz metody i sztuczki, których sam używam codziennie w swojej pracy.', 2, 3, 2, 12, N'Kazimierz Wielki', '2024-10-19T11:00:00', 45, NULL, NULL, 7),
(181, 4, N'SQL Server - droga do optymalnej konfiguracji i wydajności', N'Dużo już mówiliśmy o tym jak optymalizować wykonywanie ciężkiego zapytania. Zagłębialiśmy się w plany wykonania czy użycie indeksów. Teraz czas przyjrzeć się samemu serwerowi. Co powoduje, że wszystkie zapytania zaczynają szwankować?
Tematyka:
- Konfiguracja serwera - co pomaga, czego nie należy ruszać.
- Jak serwer wykorzystuje zasoby (CPU, RAM, IO). Jak je monitorować - widoki DMV, wskaźniki wydajnościowe.
- Stany oczekiwania - monitoring i możliwości reagowania.
- TempDB.
- Poznaj swój serwer, czyli jak symulować obciążenie - HammerDB, SQLQueryStress.', 8, 1, 2, 12, N'Mistrz Twardowski', '2024-10-18T09:00:00', 540, NULL, NULL, 0),
(182, 4, N'Transforming SQL Authentication: Real-World Scenarios with Azure Managed Identity', N'Discover how to enhance the security of your SQL databases by transitioning from traditional password-based authentication to a modern, passwordless approach using Azure Managed Identity. In this session, I will explore real-world scenarios that demonstrate the practical implementation of transitioning from connectionstrings to Role-Based Access Control (RBAC) with Managed Identity for Azure applications. Highlighting the benefits of eliminating passwords and simplifying access management.', 2, 1, 1, 12, N'Marian Rejewski', '2024-10-19T12:00:00', 45, NULL, NULL, 2),
(183, 4, N'Jak AI wylądował w świecie SQL, czyli poznaj Snowflake Cortex', N'W naszym wystąpieniu przedstawimy zaawansowane funkcje językowe oferowane przez Snowflake Cortex. Dowiemy się, jak korzystać z funkcji LLM (Large Language Model) do analizy tekstu, tłumaczenia, streszczania i generowania treści. Spróbujemy pozyskać informacje z biletów PKP przy użyciu AI.
Snowflake Cortex zapewnia natychmiastowy dostęp do wiodących w branży dużych modeli językowych (LLM) przeszkolonych przez badaczy z takich firm jak Mistral, Meta i Google. Oferuje także modele, które Snowflake dostosował do konkretnych zastosowań.
Ponieważ te LLM są w pełni hostowane i zarządzane przez Snowflake, korzystanie z nich nie wymaga konfiguracji. Twoje dane pozostają w Snowflake, zapewniając wydajność, skalowalność i zarządzanie, jakich oczekujesz.
Funkcje Snowflake Cortex są dostarczane jako funkcje SQL i Python.', 2, 3, 2, 2, N'Kazimierz Wielki', '2024-10-19T13:45:00', 45, NULL, NULL, 7),
(184, 4, N'Key performance metrics of MS SQL Server performance', N'SessionDetails covers most important MS SQL Server performance metrics. We are going to talk about deep meaning of each of them with examples. This will allow DBAs to understand the meaning of most typical performance problems.', 2, 1, 2, 12, N'Mistrz Twardowski', '2024-10-19T15:45:00', 45, NULL, NULL, 3),
(185, 4, N'7 things you don''t need in time series analysis', N'When you read about how to work with time series, you see many theoretical tips that sound very good. But often it turns out that they just don''t work well in practice. In this talk, I''ll summarize my several years of hands-on experience in time series-based projects to outline some such unexpected findings.', 2, 4, 1, 2, N'Mistrz Twardowski', '2024-10-19T10:00:00', 45, NULL, NULL, 1),
(186, 4, N'Microsoft Fabric dla specjalistów Power BI', N'Świat danych i analityki już nigdy nie będzie taki sam, odkąd w zeszłym roku światło dzienne ujrzał Microsoft Fabric, ujednolicona platforma danych działająca w modelu Software-as-a-Service. Fabric otwiera całe spektrum zupełnie nowych możliwości i sposobów pracy dla wszystkich osób zajmujących się analityką danych, w tym osób pracujących do tej pory w rolach związanych z Power BI. Jeśli kiedykolwiek przyszło Ci pracować z Power BI, przyjdź na naszą sesję, by dowiedzieć się, co Fabric ma Ci do zaoferowania i jak może zmienić podejście do tworzenia rozwiązań analitycznych i zarządzania nimi. Gwarantujemy liczne demonstracje technologii i dużą porcję materiałów do samodzielnego budowania Twojego warsztatu pracy z Fabric.', 2, 3, 2, 3, NULL, NULL, NULL, NULL, NULL, 0),
(187, 4, N'MLOps on Azure - war stories and lessons learned', N'Około 80% projektów z dziedziny AI/ML kończy się porażką. Statystyka ta może wydawać się zaskakująca - AI jest teraz tak popularne, blueprinty gotowych rozwiązań tak łatwo dostępne, jak trudne może być zbudowanie modelu uczenia maszynowego i wystawienie go na produkcję?

MLOps jest zestawem zasad i najlepszych praktyk mającym zapewnić powodzenie projektu AI w całym cyklu jego życia. Niezrozumienie lub niewłaściwe zastosowanie tych praktyk może sprawić, że również i nasze wdrożenie prędzej czy później utknie w martwym punkcie bez odwrotu.

W trakcie tej sesji omówię czym jest MLOps, na jakich filarach stoi i jak na tych filarach z powodzeniem opierać wdrażane rozwiązanie. Przedstawię również przykłady "z życia wzięte" jak odejście od fundamentów rzutuje na jakość całego systemu. Całość w formie historii wojennych z projektu refaktoryzacji systemu Computer Vision opartego o serwisy chmurowe Azure wdrożonego na urządzeniach brzegowych dwóch zakładów farmaceutycznych.', 2, 3, 2, 2, N'Marian Rejewski', '2024-10-19T11:00:00', 45, NULL, NULL, 3),
(188, 4, N'Don''t Bite Off More You Can Chew - Take it in Chunks', N'Any SQL programmer with some experience knows that loops are bad and that you should work with all data at once in set-based statements. However, you may have experienced situations where this strategy did not work out well and you ran into problems like out-growing the transaction log or blocking other users. You can solve this by operating on the data in chunks. Implementing chunking is not that difficult, but there are still pitfalls you can run into. In this session, I will discuss in what situations you may want to use chunking. I will give some best practices for how to implement chunking for good performance and I will highlight some things you need to keep in mind, for instance, recovering from interruptions.

This is a level 300/400 SessionDetails for persons who have been working with
T-SQL development for a few years.', 2, 1, 1, 12, N'Mistrz Twardowski', '2024-10-19T13:45:00', 45, NULL, NULL, 4),
(189, 4, N'DAX - optymalizacje na przykładach', N'Warsztat będzie poświęcony tematom związanym z miarami DAX i ich zastosowaniem w praktyce. Pokażemy na nim jak pracować z calculation groups oraz miarami zagnieżdżonymi aby uniknąć pogorszenia wydajności. Poruszymy tematy związane z vertical fusion oraz horizontal fusion, które mogą być bardzo pomocne w pracy z raportami dla odbiorców - użycie odpowiednich wizualizacji może całkowicie zmienić odbiór raportu przez użytkownika końcowego. Przejdziemy też przez przykłady pokazujące jak pracować z miarami gdy mamy tabele parametrów oraz jak uniknąć problemów w przypadku stosowania tabel agregacyjnych. Nie zabraknie modelowania - pokażemy jak sterować wymiarami które mają przechowywać wartości historyczne oraz jaki może mieć to wpływ na wydajność. Zahaczymy też o nowości - funkcje okna w zastosowaniach praktycznych, które bardzo ułatwiają development niektórych miar.', 8, 3, 2, 3, N'Diabeł Wenecki', '2024-10-18T09:00:00', 540, NULL, NULL, 0),
(190, 4, N'Databricks - Devops dla zabieganych', N'Databricks jest już z nami od lat, w tym w setkach implementacji w polskich firmach. Chcemy podzielić się naszymi doświadczeniami zarówno z wdrażania usługi Databricks w nowych projektach, jak i w optymalizacji już zastanych rozwiązań. Na tej sesji przejdziemy przez proces tworzenia i odpowiedniego zabezpieczenia Databricks Workspace na platformie Azure. Razem zastosujemy najlepsze praktyki zwiazane z automatyzacją tworzenia środowiska na Azurze (za pomocą zarówno Azure Bicepa jak i Terrraforma) oraz wszystkich niezbędnych komponentów wewnątrz workspace’u. Dokładnie omówimy, na przykładach, zabezpieczenia sieciowe środowiska, logi i monitoring oraz kontrolę dostępów. Następnie zabierzemy sie do tworzenia klastrów (zwykłych i SQL) i pokazania, jak je wykorzystywać oraz odpowiednio zabezpieczyć. Potem stworzymy pełen setup Unity Catalogu wraz z testowym ładowaniem danych do stworzonych przez nas tabel. To wszystko okrasimy pełną automatyzacją całego środowiska + procesem CI/CD przy pracy z Databricks. W trakcie będziemy także omawiać optymalizacje kosztowe rozwiązań, które razem stworzymy z przykładami z naszych poprzednich wdrożeń.', 8, 1, 2, 3, N'Zawisza Czarny', '2024-10-18T09:00:00', 540, NULL, NULL, 0),
(191, 4, N'Budowa aplikacji z agentami AI', N'Podczas warsztatu używając Pythona i usług Azure zbudujemy aplikację wykorzystującą agentów AI, czyli modeli językowych zdolnych do autonomicznego lub częściowo autonomicznego wykonywania złożonych zadań. Jako główną składową użyjemy frameworku Langchain, który zostanie przedstawiony od strony teoretycznej w pierwszej części warsztatu. Podczas niej omówię podstawowe elementy framework''u takie jak łańcuchy, agenci czy narzędzia. W drugiej części skupimy się na budowie samej aplikacji rozpoczynając od uruchomienia koniecznych usług Azure, takich jak Azure OpenAI, Azure AI Document Intelligence i Azure AI Search. Oprócz części backendowej stworzymy również prosty interfejs z wykorzystaniem biblioteki streamlit. Po stworzeniu aplikacji omówimy i przetestujemy również możliwości dotyczące jej monitorowania.', 8, 3, 2, 3, N'Marian Rejewski', '2024-10-18T09:00:00', 540, NULL, NULL, 1),
(192, 4, N'Deep Dive into Predictive Analytics using Azure Open AI GPT-4-TV and GPT-4o models with Vision', N'Azure OpenAI Service has introduced an image analysis feature that leverages large language models (LLMs) to comprehend the content of images.
GPT-4 Turbo with Vision, developed by OpenAI, is a significant multimodal model (LMM) capable of interpreting images and providing text-based answers to queries regarding those images. It combines capabilities in natural language processing and visual comprehension. The latest GPT-4o covers all GPT-4-TV features with better performance, lower price, and improved work with voice and video.
This SessionDetails covers real-life cases and demos using Azure Solutions and GPT-4 Turbo with Vision and CPT-4o for enhanced predictive analysis.', 2, 1, 1, 2, N'Kazimierz Wielki', '2024-10-19T15:45:00', 45, NULL, NULL, 2),
(193, 4, N'All you need to know about AI Act', N'The EU AI Act represents a pioneering legislative effort to govern the deployment of Artificial Intelligence across the European Union. Its primary goal is to foster innovation while ensuring ethical standards and safeguarding fundamental human rights against the potential risks posed by AI technologies.
The responsibility primarily falls on the shoulders of the providers (developers of AI systems). However, users who implement high-risk AI applications are also subject to certain responsibilities.
With the impending enforcement of this law throughout the EU, it is crucial for all to gain an understanding of its implications.
In this SessionDetails we will not only debunk AI Act but also develop an intelligent agent capable of addressing any questions related to it, presenting a unique opportunity that should not be overlooked.', 2, 3, 2, 2, N'Mistrz Twardowski', '2024-10-19T12:00:00', 45, NULL, NULL, 3),
(194, 4, N'Microsoft Fabric and GitHub - The story so far', N'Microsoft Fabric is a new service that was announced during Microsoft Build 2023. Which has caused a lot of excitement in the Microsoft Data Platform community.

This year support for GitHub as a provider for Git integration was introduced.

In this SessionDetails I give a brief overview of Microsoft Fabric is before going into details about how you can use GitHub with it at this moment in time. Including Git integration and other ways that you can connect up to the Data Warehouse experience.

During the SessionDetails I will also introduce some GitHub best practices.', 2, 3, 1, 3, N'Mistrz Twardowski', '2024-10-19T11:00:00', 45, NULL, NULL, 3),
(195, 4, N'Upgrade Databricks z hive metastore do Unity Catalog - blaski i cienie', N'Celem sesji jest podzielenie się doświadczeniami z procesu aktualizacji Databricks z hive metastore do Unity Catalog. Dodatkowo, chcemy pokazać nasze doświadczenie związane z otwarciem kodu Unity Catalog.', 2, 3, 2, 3, N'Marian Rejewski', '2024-10-19T13:45:00', 45, NULL, NULL, 2),
(196, 4, N'SQL Server w Praktyce: Jak Skutecznie Usuwać Dane z Tabeli', N'Efektywne zarządzanie danymi jest kluczowym elementem sukcesu każdej organizacji. Prezentacja "SQL Server w Praktyce: Jak Skutecznie Usuwać Dane z Tabeli" skierowana jest do administratorów baz danych, programistów oraz osób zainteresowanych zaawansowanymi technikami usuwania danych w SQL Serverze.

Podczas prezentacji omówione zostaną różnorodne metody usuwania danych, takie jak DELETE, TRUNCATE, DROP oraz operacje na partycjach. Przedstawione będą sytuacje, w których warto stosować każdą z tych metod, ich zalety i ograniczenia, a także jak wybrać najlepszą strategię w zależności od konkretnego scenariusza.

Zgłębione zostaną praktyczne aspekty usuwania danych, w tym zarządzanie dużymi zbiorami danych, minimalizacja blokad oraz optymalizacja wydajności. Przedstawione będą realne przykłady i best practices, które pozwolą na skuteczne i bezpieczne zarządzanie danymi w bazie danych.', 2, 1, 2, 12, N'Marian Rejewski', '2024-10-19T10:00:00', 45, NULL, NULL, 8),
(197, 4, N'Microsoft Fabric and Azure Databricks: tough love, or perfect symbiosis?', N'Whether you are just thinking about it or have already started designing the architecture of an analytical solution that will allow you to quickly address the business problems of your organization, you are faced with two solutions that are at the forefront of dynamic development. These are Microsoft Fabric and Azure Databricks. Is choosing one path necessary? Is there a potential for symbiosis between these two solutions? Or maybe one absorbs the other? During this session, we will look at specific examples of architectures in which both Microsoft Fabric and Azure Databricks operate, showing that the landscape of analytical solutions can be incredibly exciting. The SessionDetails is based on experiences from real projects implemented for enterprise clients.', 2, 3, 2, 3, N'Kazimierz Wielki', '2024-10-19T10:00:00', 45, NULL, NULL, 5),
(198, 4, N'Querying structured data with LLMs in a systematic way', N'In this session, we''ll explore how to link Large Language Models with relational databases. We''ll delve into case studies and discuss various tried-and-tested approaches for achieving this integration. You’ll gain insights into the benefits, challenges, and future prospects of combining LLMs with structured data. Finally, I''ll introduce dbally, an open-source library that I am actively developing at deepsense.ai. dbally is a powerful, secure, and reliable framework for querying structured data using natural language. Whether you''re a seasoned data science professional or just starting out, this talk will offer valuable insights and practical strategies to enhance your skills in working with LLMs and external structured data sources.', 2, 1, 1, 13, N'Marian Rejewski', '2024-10-19T14:45:00', 45, NULL, NULL, 3),
(199, 4, N'Azure Data Engineering i Fabric - no i co teraz?', N'Dużo się zmienia na rynku w związku z nową usługą Microsoft Fabric. Na tej sesji opowiem jak to wygląda na dzień dzisiejszy z perspektywy inżyniera danych w Azure. Porówamy sobie usługi dostępne na obu platformach i opowiem jak wygląda sytuacja na rynku u moich klientów.', 2, 3, 2, 3, N'Kazimierz Wielki', '2024-10-19T12:00:00', 45, NULL, NULL, 5),
(200, 4, N'Czy DirectLake zastąpi Import i DirectQuery?', N'Wraz z nadejściem Microsoft Fabric wprowadzenie nowego trybu przechowywania danych w Power BI na pierwszy rzut oka wygląda obiecująco. Inne zarządzanie pamięcią, szybkie odświeżanie, kompatybilność DAX z trybem Import to te lepsze cechy. Na tej sesji - oprócz porównania wydajności - zobaczymy jednak kilka przykładów (także tych nieoczywistych), kiedy trzeba rozważyć rezygnację z nowości. Jako bonus przekształcimy model z DirectLake na Import.', 2, 1, 2, 3, NULL, NULL, NULL, NULL, NULL, 0);
INSERT INTO dbo.SessionDetails (SessionId, EventEditionId, Title, [Description], SessionFormatId, SessionLevelId, LanguageId, TopicTrackId, Room, ScheduledAt, ScheduledDurationMinutes, LiveUrl, RecordingUrl, FavoritedCount) VALUES
(201, 4, N'Jak poprawić czytelność wykresów w Power BI', N'Domyślne właściwości formatowania wykresów w Power BI (lub innym narzędziu DataViz) nie ułatwiają życia czytelnikom raportów. Twoją rolą jest takie dopasowanie ich, aby wizualizacja generowała jasny przekaz dla grupy docelowej.

W tego typu sytuacji wiele osób takich jak Cole Nussbaumer Knaflic, Stephen Few czy Scott Berinato opisało już najlepsze praktyki w projektowaniu wykresów, a my postaramy się je wykorzystać w Power BI.

Ta sesja obejmie 5 scenariuszy demonstrujących jak przekonwertować trudne do odczytania wykresy na pozbawiony szumów komunikat, który przyciągnie uwagę użytkownika raportu.', 2, 1, 2, 3, N'Kazimierz Wielki', '2024-10-19T14:45:00', 45, NULL, NULL, 5),
(202, 4, N'Keynote: Tajemnice budowy polskiego modelu językowego Bielik', 'brak opisu', 1, NULL, 2, 2, N'Kazimierz Wielki', '2024-10-19T09:25:00', 20, NULL, NULL, 9),
(203, 5, N'SQL Server Worst Practices', N'My Database Journey started with Borland Paradox, via Microsoft Access to SQL Server. I wasn’t very good with Paradox. Somewhere while working with Access I think I understood the basics of data modelling for an rDBMS. I got things to work, but seriously I wasn’t very good. Moving over to SQL Server made me realise something. SQL and SQL isn’t always the same. And since I didn’t even understand best practices in MS Access, my knowledge didn’t really translate well to SQL Server.

This SessionDetails is about mistakes and misunderstandings. Most of the mistakes and misunderstandings are my own. Having misunderstood things, leading to having made mistakes, is part of the reason I now consider myself pretty good with SQL Server.

What you will get if you attend this SessionDetails is:
- Me making fun of myself and my mistakes and misunderstandings.
- Consequences. Real ones and theoretical ones.
- How I should have done instead (and how you should do to avoid making the same mistakes I did)', 2, 3, 1, 12, N'Smok Wawelski (131)', '2025-10-17T12:00:00', 45, NULL, NULL, 0),
(204, 5, N'Jak prostymi metodami poprawiać wydajność raportów Power BI', N'Czy Twoje raporty Power BI działają wolniej niż byś chciał? Czy zastanawiasz się, jak zwiększyć ich wydajność bez konieczności stosowania skomplikowanych technik? Ta sesja jest dla Ciebie!
Podczas tej krótkiej prezentacji dowiesz się dowiesz się, jak za pomocą prostych i skutecznych metod poprawić wydajność swoich raportów Power BI.
Sesja skupi się na:
- Optymalizacja zapytań DAX: Jak małe zmiany mogą się przełożyć na wydajność całego raportu i dalczego należy pamiętać o alternatywnych funkcjach wykonujących te samie obliczenia.
- Jak użycie nowych funkcji otwiera całkowicie nowe możliwości przetwarzania danych w locie dzięki którym statyczne dane nie są potrzebne.
- Zarządzanie modelami danych: Jak niewielkie zmiany mogą uprościć model danych i poprawić jego wydajność aby był bardziej wydajny.', 2, 1, 2, 7, N'Smok Wawelski (131)', '2025-10-17T10:00:00', 45, NULL, NULL, 0),
(205, 5, N'Databricks Overwatch - Dashboard, który widzi wszystko', N'Efektywne zarządzanie środowiskiem Databricks wymaga ciągłego monitoringu i analizy kluczowych metryk operacyjnych. Jeżeli zastanawiałeś się kiedyś, jak to zrobić to mamy rozwiązanie - Databricks Overwatch. Overwatch to narzędzie open-source, które zapewnia pełną widoczność tego, co dzieje się w Twoim środowisku Databricks.

W trakcie tej sesji:
- Poznasz tajniki teorii Overwatch - dowiesz się, czym dokładnie jest, jakie realne problemy rozwiązuje oraz dlaczego warto go wdrożyć.
- Krok po kroku skonfigurujesz swój własny job Overwatch - zobaczysz, jak łatwo uruchomić zbieranie kluczowych danych, od instalacji aż po integrację z platformą Databricks.
- Odkryjesz moc dashboardów i wizualizacji - poznasz przykładowe dashboardy, dzięki którym szybko zidentyfikujesz problemy, zoptymalizujesz koszty oraz zwiększysz wydajność klastrów.
- Lessons learned z produkcji - otrzymasz cenne wskazówki i doświadczenia zdobyte podczas wdrożeń Overwatch w dużych środowiskach produkcyjnych.

Po zakończeniu sesji będziesz gotowy, by samodzielnie wdrożyć oraz maksymalnie wykorzystać potencjał Databricks Overwatch w swoim środowisku.', 2, 3, 2, 3, N'Baltazar (120)', '2025-10-17T11:00:00', 45, NULL, NULL, 1),
(206, 5, N'Aplikacje RAG w Microsoft Fabric', N'W trakcie sesji stworzymy czatbota odpowiadającego na pytania użytkowników na podstawie danych przechowywanych w Lakehouse Microsoft Fabric. Użyjemy do tego biblioteki SynapseML, Azure AI Document Intelligence i Azure OpenAI Services. Przy okazji wyjaśnimy mechanizmy działania aplikacji RAG i dowiemy się, co wpływa na ryzyko zakażeń pooperacyjnych.', 2, 1, 2, 2, N'Don Pedro (128)', '2025-10-17T10:00:00', 45, NULL, NULL, 1),
(207, 5, N'Odkrywaj swoje dane w PowerBI zadając pytania w języku naturalnym', N'W świecie chatbotów i wirtualnych asystenów coraz częściej chcielibyśmy używać naszych danych zadając pytania w naszym naturalnym języku. Natywnie Power BI wspiera to swoją wbudowaną wizualizacją Q&A. Jednak pytania te są bardzo często dla silnika niezrozumiałe. Podczas tej sesji opowiem w jaki sposób przygotować nasz model do tego, żeby rozumiał o co go pytamy oraz pokażę jak go "uczyć" w oparciu o zadawane już wcześniej pytania oraz nasze doświadczenia.', 2, 4, 2, 2, N'Smok Wawelski (131)', '2025-10-17T11:00:00', 45, NULL, NULL, 0),
(208, 5, N'Introduction to Regular Expressions in SQL Server', N'Regular expressions have been used in computing environments for decades for advanced search and replace operations. In SQL Server we have had the LIKE operator forever, but anyone who has tried to make advanced pattern-matching has realised that its capabilities are quite limited. And if you want to make replace operations, you have been even more limited.

This is changing! Regular expressions are finally coming to SQL Server. Support for regular expressions is part of SQL Server 2025, currently in public preview. It is also available for public preview in Azure SQL Database.

In this SessionDetails we will learn how regular expressions work in SQL Server, starting with the very basic operations. Through the SessionDetails we will move to more advanced features, and I will show some examples of complex find-and-replace operations we can do with regular expression that previously were difficult or impossible to implement in T-SQL.

To have benefit from this session, you don’t need to have any previous knowledge or experience of regular expressions, but as the title says: this is an introduction. SQL-wise, I will assume that you have used the LIKE operator and maybe some of the other built-in string functions.', 2, 3, 1, 12, N'Baltazar (120)', '2025-10-17T10:00:00', 45, NULL, NULL, 0),
(209, 5, N'Nowa składnia zapytań SQL w BigQuery - Pipe Query Syntax', N'Tradycyjna składnia języka SQL może stać się męcząca przy dłuższych, bardziej rozbudowanych zapytaniach. Ograniczenia języka SQL powodują, że kod jest trudny do zrozumienia, utrzymania i zmian.

BigQuery wprowadza nową składnię - pipe syntax - która zupełnie zmienia sposób tworzenia zapytań SQL. Jest niezwykle prosta, a zarazem oferuje ogromne możliwości, w tym zwiększenie produktywności i klarowności kodu SQL.

Zapraszam na sesję, gdzie przedstawię ten rewolucyjny wynalazek. Zapoznamy się z jego głównymi założeniami i cechami, zobaczymy, jak wygląda struktura zapytań przypominająca przetwarzanie potokowe. Dowiesz się, jak dzięki temu można szybciej pisać zapytania, które zarówno są bardziej czytelne, jak i bardziej wydajne. Oprócz slajdów będzie sporo demonstracji na żywo, w których pokażę praktycznie wszystkie elementy pipe query syntax. Zdobyta wiedza będzie możliwa do natychmiastowego zastosowania w projektach dotyczących BigQuery.', 2, 3, 2, 12, N'Baltazar (120)', '2025-10-17T15:45:00', 45, NULL, NULL, 1),
(210, 5, N'Getting Ready for SQL Server 2025: Upgrade Strategies for Highly Available SQL Server Environments', N'If you have existing high availability and disaster recovery solutions for your SQL Server instances, proper planning and considerations have to be made when upgrading to SQL Server 2025.

In this session, we will look at high availability options in previous versions of SQL Server, including database mirroring, failover clustering, log shipping and replication. We will also learn how to upgrade to SQL Server 2025 with minimal downtime when SQL Server high availability and disaster recovery features are part of the existing configuration.

This SessionDetails will focus on:

1) The considerations for performing an in-place upgrade versus a side-by-side migration
2) How to prepare for the upgrade in order be successful
3) How to upgrade to SQL Server 2025 with existing database mirroring, failover clustering, log shipping and Availability Group configuration
4) How to reduce your downtime and level of effort associated with upgrading SQL Server', 2, 1, 1, 12, N'Don Pedro (128)', '2025-10-17T11:00:00', 45, NULL, NULL, 0),
(211, 5, N'Od Danych do AI: Inżynieria Danych i AI w praktyce', N'Warsztat ma na celu przejście przez kilka typowych projektów z pogranicza Data Engineeringu, Machine Learningu i AI, aby pokazać uczestnikom, jak w praktyce wygląda metodologia pracy z takimi rozwiązaniami – od podstaw aż po wdrożenie. Pokażemy, jak przygotować dane, zbudować pipeline ETL, wytrenować prosty model ML lub system wyszukiwania semantycznego, a na końcu jak połączyć to z ChatGPT w formie kompletnej aplikacji. Skupimy się na praktycznym podejściu do pracy nad projektami AI end-to-end, omawiając zarówno aspekty techniczne, jak i procesowe: jak planować, realizować i iteracyjnie rozwijać takie rozwiązania w realnym środowisku.

Warsztat bedzie realizowany w środowisko databricks', NULL, 4, 2, 2, N'Pampalini (137)', '2025-10-16T09:00:00', 540, NULL, NULL, 1),
(212, 5, N'Keynote: Building a Recession-proof Career in the New Era of an AI-Driven Economy', N'In a world increasingly shaped by artificial intelligence, one thing is clear: the rules of career growth are being rewritten in real time.

AI agents and automation are replacing hundreds of thousands of jobs. More and more companies are are looking for skilled workers who already know how to use AI tools.

For data professionals at all levels, from rising juniors to seasoned experts, the challenge is no longer just about keeping up. It’s about future-proofing your value in a constantly evolving global economy.

In this keynote, we will unpack what it truly means to build a recession-proof career in the age of AI. This isn’t about chasing the latest AI tools nor learning the new hype. It’s about developing the mindset, skills, and strategies that transcend economic cycles and technological disruptions.

It''s becoming an expert at what we already are.', 1, 4, 1, 3, N'Don Pedro (128)', '2025-10-17T09:25:00', 20, NULL, NULL, 3),
(213, 5, N'Fabric z perspektywy budowy platformy danych', N'Fabric  jest już z nami od kilku lat, i co raz wiecej firm zaczyna spoglądać w jego kierunku przy budowie swojej platformy danych. Chcemy podzielić się naszymi doświadczeniami zarówno z wdrażania MS Fabric w nowych projektach, jak i w optymalizacji już zastanych rozwiązań. Przejdziemy przez proces tworzenia struktury projektów, podziału ich na części oraz dobre praktyki które udało nam się do tej pory wypracować. Stworzymy pelny przeplyw danych od zrodla, przez sparkowy notebook aż po lakehouse, z którego przygotujemy raport. Po drodze przejdziemy przez „ways of working” z każdym z tych elementów, co się sprawdza, a czego lepiej unikać. Na końcu przejdziemy do pełnej automatyzacji całości naszego projektu przy deploymencie na następne środowiska i porozmawiamy o możliwych podejściach w tym temacie.', NULL, 1, 2, 3, N'Bolek i Lolek (135)', '2025-10-16T09:00:00', 540, NULL, NULL, 1),
(214, 5, N'Two Developers, One Mission: Make a Test Database That Doesn’t Suck', N'If you''ve ever been frustrated by a test database filled with nonsense, duplicates, sensitive information, or YOLO-style restored production backups, this SessionDetails is for you.
Join Peter Kruis and Tonie Huizer, two energetic data enthusiasts, on an epic (and slightly chaotic) quest to build test databases that are safe, realistic, and actually useful for development and testing. With decades of combined experience, they’ll take you on a journey through the wild world of test data, showing just how bad it can get, and how good it can be.
Through engaging role play, real-world examples, and live demos, they’ll expose the dangers of shady test environments and share smarter, safer ways to manage test data. Audience participation is encouraged; because (bad) test databases are a team sport!
You’ll leave entertained, but more importantly, you’ll leave with tools and strategies to stop your test database from being the weakest link in your development chain.
Because let’s face it: your test database shouldn’t suck.', 2, 3, 1, 12, N'Don Pedro (128)', '2025-10-17T14:45:00', 45, NULL, NULL, 0),
(215, 5, N'Generatywne AI w SQL Server 2025 w praktyce', N'Nowe możliwości SQL Server 2025 związane ze sztuczną inteligencją znacząco rozszerzają zastosowanie tej platformy w kontekście pracy z tekstem i dużymi modelami językowymi. Dzięki wersji public preview możemy już dziś sprawdzić, jak w praktyce wykorzystać nowy silnik do semantycznego wyszukiwania informacji – i przygotować się na jego pełne wdrożenie w środowiskach produkcyjnych.

Podczas warsztatu skoncentrujemy się na natywnym wsparciu dla danych wektorowych oraz integracji z modelami językowymi. Na konkretnym przykładzie – dokumentacji technicznej – przejdziemy przez cały proces: od podziału tekstu na mniejsze fragmenty (chunking), przez generowanie embeddingów (wektorów), aż ich zapis w bazie danych i tworzenie zapytań.

Embeddingi wygenerujemy zarówno z użyciem modelu text-embedding-ada-002 z katalogu Azure OpenAI, jak i przy pomocy lokalnie hostowanego modelu, co pozwoli porównać oba podejścia i zrozumieć ich zastosowania w różnych scenariuszach – także tych wymagających zgodności z polityką prywatności lub działania offline.

Warsztat przeznaczony jest dla inżynierów danych, programistów oraz architektów systemów, którzy chcą rozszerzyć swoje umiejętności o semantyczne przetwarzanie informacji i integrację AI z relacyjną bazą danych.', NULL, 1, 2, 2, N'Reksio (134)', '2025-10-16T09:00:00', 540, NULL, NULL, 0),
(216, 5, N'SQL Server 2025 - przeglad nowosci dla specjalistow danych', N'SQL Server 2025 to odpowiedź Microsoftu na rosnące potrzeby nowoczesnych środowisk danych. W trakcie prelekcji omówione zostaną najważniejsze nowości, jakie przynosi ta wersja – od usprawnień w wydajności i optymalizacji zapytań, przez rozbudowane możliwości integracji z chmurą i obsługi danych nieliniowych, po nowe funkcje związane z AI, bezpieczeństwem, zgodnością oraz automatyzacją zarządzania bazami danych. Prelekcja skierowana jest do specjalistów danych – administratorów, architektów i analityków – którzy chcą świadomie przygotować się na migrację i efektywnie wykorzystać nowe możliwości platformy.', 2, 3, 2, 12, N'Don Pedro (128)', '2025-10-17T13:45:00', 45, NULL, NULL, 0),
(217, 5, N'Azure Databricks okiem administratora/DBA', N'Bazy danych miały swojego DBA — a czy Databricks powinien mieć swojego DataBricksAdministratora?
W tej sesji opowiem, jakie — moim zdaniem — obowiązki powinni pełnić Administrator "Accountu" oraz Administrator Workspace’u. Dowiesz się, na co zwracać uwagę, jakie narzędzia mogą Ci w tym pomóc oraz jak zautomatyzować codzienne zadania.

Nie zabraknie także elementów architektonicznych — pokażę, jak odpowiednio poukładać wybrane komponenty Databricks, by zapanować nad swoim środowiskiem analizy danych.', 2, 1, 2, 12, N'Smok Wawelski (131)', '2025-10-17T14:45:00', 45, NULL, NULL, 1),
(218, 5, N'Data Flow Mastery: Unravelling MS Fabric Orchestration', N'Join a practical SessionDetails on data orchestration with Microsoft Fabric to boost your data engineering skills.
During this session, you will discover a variety of tools and techniques for Data Pipeline Orchestration that are feasible in MS Fabric, including APIs, Spark Notebooks, Azure Data Factory, Fabric Pipelines, CLI, and others. You will also learn how to implement event-driven orchestration to deliver your data to business as quickly as possible while minimizing costs. We will answer questions about which orchestration technique is best and when, what the pros and cons of using it are, how mature the technology is, and how hard it is to implement and maintain. We are going to demonstrate each technique in a live demo.
Through practical examples, this SessionDetails will help you choose the orchestration techniques appropriate for your skills and architecture.', 2, 3, 2, 3, N'Smok Wawelski (131)', '2025-10-17T15:45:00', 45, NULL, NULL, 0),
(219, 5, N'Implementing VLS (Visual-Level Security) in Power BI', N'Have you ever wondered if it’s possible to implement varying access rights by visual? You’ve surely heard of RLS and therefore you know that a single given user can have just one role at a time, so just one scope of data access per user per report will work.

But how do you tackle a use-case, when the same user should have visibility into:
- only his/her region in one visual and the whole country in another visual.
- detailed sales data for his/her region in one visual and an aggregated finance data in another visual.

There may be some thoughts on how to address this challenge already lingering through your mind: a duplicate (likely aggregated) data model, leveraging OLS (Object-Level Security), creating another page with the aggregated data and restricting access to it by conditionally displaying a page navigation menu. While all of these methods do work to a certain extent, they also feature trade-offs and limitations e.g. introducing redundancy to the model, not being the most user-friendly, intuitive or robust.

During this SessionDetails I’ll introduce you to another method of solving the said use-case: the VLS. This technique doesn’t come with any of the drawbacks mentioned before. I’ll first cover the concept behind VLS and explain how to implement it during a live demo. You will also learn a number of use-cases that can be tackled with it. Finally, I will go through a few potential pitfalls in VLS and how to work around them.

After this SessionDetails you will:
- understand the concept behind VLS.
- be able to implement VLS in a number of scenarios.
- know good and best practices when working with VLS.

It would be great if prior to attending this SessionDetails you would have a general understanding of RLS, DAX and tabular models.', 2, 1, 1, 7, N'Don Pedro (128)', '2025-10-17T15:45:00', 45, NULL, NULL, 0),
(220, 5, N'Bringing Order to the Talent Chaos: Structuring Recruitment Data with ELT Pipelines and LLMs', N'This SessionDetails walks through a real-world use case of automating recruitment reporting by using Fivetran to extract data from an Applicant Tracking System (ATS) and loading it into BigQuery for analysis. Additionally, large language models (LLMs) were leveraged to parse unstructured resume text, transforming it into structured data for better candidate insights and reporting. The talk will cover the architecture, challenges faced, and practical lessons learned from combining traditional ELT pipelines with modern AI techniques.', 2, 3, 1, 3, N'Baltazar (120)', '2025-10-17T14:45:00', 45, NULL, NULL, 1),
(221, 5, N'Clickhouse Internals - czyli co sprawia, że Clickhouse jest tak unikatowy.', N'Czy obok rozwiązań takich jak Databricks, Snowflake czy MS Fabric jest jeszcze miejsce dla innych platform analitycznych? Jeśli szukamy naprawdę wydajnego rozwiązania należy zwrócić uwagę na Clickhouse ,open-source’owa platformę , która już jest używana m.in przez Cisco, Couldflare, Netfix’a czy Teslę do przetwarzania miliardów wierszy na sekundę.
Kolumnowy format danych z wydajną kompresją, unikatowe podejście do składowania danych, wyjątkowe możliwości materialized views czy integracja z innymi rozwiązaniami, to tylko niektóre z elementów, które sprawiają, że Clickhouse jest naprawdę ciekawym rozwiązaniem.
W trakcie sesji spróbujemy oczywiście sprawdzić Clickhouse w praktyce, aby się o przekonać o jego unikalności.', 2, 3, 2, 3, N'Smok Wawelski (131)', '2025-10-17T13:45:00', 45, NULL, NULL, 1),
(222, 5, N'Agentic AI in Fabric', N'In the era of AI, the ability to quickly and easily draw insights and answers from our data, is as important than ever, and being able to ask those questions in plain human language.

In this SessionDetails we''ll uncover the possibilities of combining Microsoft Fabric with external AI tools to enable scenarios to utilize your data through agents. We''ll touch upon topics like the data modelling for AI, data agents, prompts, and touch upon advanced tools like Model Context Protocol (MCP), Agent-to-agent (A2A), and automation with N8N.

Topics:
- Data Modelling for AI
- Data Agents
- Intro to Advanced Agentic Capabilities

After attending this session, you’ll be able to leverage your data with AI agents inside and outside of Fabric, and you be up to date on the newest tool for AI-powered BI—ready to develop solutions or advice clients and colleagues on how to use AI with Power BI and Fabric.', 2, 1, 1, 2, N'Baltazar (120)', '2025-10-17T13:45:00', 45, NULL, NULL, 0),
(223, 5, N'Użycie pamięci w zapytaniach DAX', N'Bywa, że nasz ulubiony silnik Vertipaq dostaje od nas w kość (analityczną) i odmawia odpowiedzi na zapytania naszych użytkowników. Przytłoczenie go zbyt dużą ilością danych skutkuje głośnym protestem i wywieszeniem transparentu manifestującym wykorzystanie zasobów poza granice możliwości.

Na sesji poznamy przyczyny takich zjawisk, metod diagnozy i sprawdzimy czy można zminimalizować ich występowanie.', 2, 2, 2, 3, N'Don Pedro (128)', '2025-10-17T12:00:00', 45, NULL, NULL, 0),
(224, 5, N'Introduction to SQL Server callstack analysis', N'This SessionDetails introduces one of the most powerful debugging tools available to the SQL Server administrators and consultants - callstack analysis. We will look at what the callstacks are, how to gather them and how to analyze them for clues on what''s going on. I will introduce you to some powerful tools that can make your work with callstacks much easier. Then we will go over some typical scenarios where callstacks are useful, along with real-life examples.', 2, 2, 1, 12, N'Baltazar (120)', '2025-10-17T12:00:00', 45, NULL, NULL, 0),
(225, 6, N'SQL Server 2025 Optimized Locking', N'Introduced in SQL Server 2025, optimized locking improves transaction locking mechanism
to reduce lock blocking and lock memory consumption for concurrent transactions.
It''s composed of two primary components: transaction ID (TID) locking and lock after qualification (LAQ).
In this SessionDetails we''ll look into how this works and how we can use it.', 2, 3, 1, 12, N'SOPOT', '2026-09-25T11:00:00', 45, NULL, NULL, 0),
(226, 6, N'Medallion Architecture w dużej organizacji: więcej niż Bronze, Silver i Gold', N'Medallion Architecture często pokazuje się jako prosty schemat: Bronze na dane surowe, Silver na dane oczyszczone, Gold na dane gotowe dla biznesu. I jako punkt wyjścia ten podział jest bardzo przydatny. Problem zaczyna się wtedy, gdy próbujemy zastosować go w dużej organizacji, z wieloma zespołami, różnymi źródłami danych, wymaganiami bezpieczeństwa, governance i realnymi ograniczeniami produkcyjnymi.

W tej sesji chciałbym pokazać praktyczną stronę wdrażania architektury Medallion. Nie tylko to, jak powinny wyglądać warstwy danych, ale też jakie decyzje trzeba podjąć, żeby ten model faktycznie działał: kto odpowiada za dane, kiedy dane mogą przejść do kolejnej warstwy, jak definiować jakość, jak radzić sobie ze zmianami schematów, jak nie zgubić lineage i jak uniknąć sytuacji, w której lakehouse powoli zamienia się w data swamp.

Opowiem o typowych problemach, które pojawiają się po drodze: zbyt szybkim “czyszczeniu” danych w warstwie Bronze, traktowaniu Silver jako miejsca na wszystko, budowaniu Gold pod pojedyncze raporty, duplikowaniu logiki biznesowej i braku jasnego ownershipu. Pokażę też, gdzie Medallion Architecture naprawdę pomaga — szczególnie wtedy, gdy warstwy medalionowe są dobrze zdefiniowane i wspierane przez sensowne standardy techniczne oraz procesy governance.

W tle pojawi się również Databricks jako przykład platformy, na której taki model można wdrażać: Delta Lake, Unity Catalog, Azure Data Lake Gen2. Nie będzie to jednak sesja o samych narzędziach. Głównym tematem będzie to, jak podejść do architektury Medallion w praktyce, żeby była zrozumiała dla zespołów, możliwa do utrzymania i rzeczywiście przydatna dla organizacji.

Uczestnicy wyjdą z sesji z konkretnymi wskazówkami, na co uważać przy projektowaniu warstw danych, jak myśleć o odpowiedzialności i jakości, oraz jak budować platformę danych, która nie kończy się na ładnym diagramie, tylko działa w codziennej pracy.', 2, 1, 2, 3, N'GDYNIA', '2026-09-25T12:00:00', 45, NULL, NULL, 0),
(227, 6, N'Slim Models, Lower Bills: Cutting Power BI/ Fabric Capacity Costs from the Inside', N'In the SessionDetails I will cover the technical aspects of my recent projects were I significantly downsized Power BI semantic models (Biggest model: 120 GBs). This led to huge cost saving opportunity for the capacities.
I will show real- life scenarios which led to downsizing the models.
Starting point - of course talks with the business.
And plenty of technical aspects: getting rid of redundant information, DMV/ DAX.INFO() analysis, VertiPaqAnalyzer as one of the friends etc.
I can also include the Log Analytics Workspace integrations to seek for models that are not being used at all but are heavy and cost a lot.
Hard scenario - automated way of analyzing queries to identify objects that are not being used within the models.
All that based on real scenarios that I implemented for my Clients.
Good thing is that the hints can also be applicable for Clients using PRO/ PPU pricing model or AAS (Azure Analysis Services)', 2, 2, 1, 3, N'GDYNIA', '2026-09-25T14:45:00', 45, NULL, NULL, 0),
(228, 6, N'SQL Performance Pitfalls: Identification and Optimization Lab', N'This interactive workshop presents realistic examples of bad SQL programming that often lead to performance problems in practice. The aim of the SessionDetails is to show participants how to identify, analyze and optimize inefficient SQL queries/SQL code in order to achieve significant performance improvements.
The workshop focuses on five to ten concrete, poorly implemented SQL coding scenarios. For each of these scenarios, the underlying problems are explained in detail and optimization approaches are then presented. Different techniques and best practices are presented that are essential for improving query speed and system efficiency.
With the help of practical lab exercises, load tests are generated to measurably compare performance before and after optimization. This allows participants to directly understand which measures lead to a significant reduction in response times and what impact they have on the overall system load.
At the end of the session, participants will have a better understanding of the most common pitfalls in SQL programming practices and will be able to perform in-depth performance analyses and make optimizations.', 4, 3, 1, 12, N'Fahrenheit', '2026-09-24T08:30:00', 540, NULL, NULL, 0),
(229, 6, N'Mastering Statistics in Microsoft SQL Server', N'Statistics are one of the most powerful — and most misunderstood — components of the SQL Server query optimizer. They drive cardinality estimation, influence join strategies, shape memory grants, and ultimately determine whether a query runs in milliseconds or minutes. When they’re fresh and accurate, statistics make SQL Server look brilliant. When they’re stale, incomplete, or misleading, they can bring even the best‑designed systems to their knees.
This SessionDetails takes you deep into the world of SQL Server statistics: what they are, how they work, and why they matter. We’ll explore histogram structures, density vectors, cardinality estimation models, and how SQL Server uses statistics to choose execution plans. You’ll learn the difference between auto‑created and user‑created statistics, when filtered statistics shine, and how ascending keys, skewed data, and parameter sensitivity can sabotage even the most carefully indexed workloads.', 2, 3, 1, 12, N'GDAŃSK', '2026-09-25T12:00:00', 45, NULL, NULL, 0),
(230, 6, N'AI-ready SQL Server 2025: praktyczne warsztaty z vector search, JSON, regex i Fabric', N'SQL Server 2025 to nowa generacja platformy danych, która łączy klasyczny model relacyjny z funkcjami potrzebnymi w nowoczesnych aplikacjach: AI, wyszukiwaniem semantycznym, danymi półstrukturalnymi, integracją z Microsoft Fabric oraz inteligentną optymalizacją zapytań.

Podczas całodniowych warsztatów uczestnicy krok po kroku zbudują i przećwiczą scenariusz oparty na jednej spójnej bazie demo. Zaczniemy od pracy z embeddingami, typem vector i similarity search, następnie przejdziemy przez przygotowanie danych z użyciem JSON, regex i fuzzy matching, a na końcu pokażemy, jak połączyć SQL Server 2025 z Microsoft Fabric oraz jak utrzymać wydajność z pomocą Query Store i nowoczesnych mechanizmów Query Intelligence.

Warsztaty mają charakter praktyczny. Uczestnicy pracują na gotowym środowisku, wykonują ćwiczenia samodzielnie i poznają nowe funkcje SQL Server 2025 w kontekście realnych scenariuszy: wyszukiwania semantycznego, poprawy jakości danych, integracji analitycznej oraz strojenia wydajności.

Dla kogo jest to szkolenie:
- dla administratorów baz danych, developerów SQL, inżynierów danych i architektów, którzy chcą poznać praktyczne możliwości SQL Server 2025.
- dla zespołów, które chcą zrozumieć, jak połączyć klasyczny SQL Server z obszarem AI, Microsoft Fabric i nowoczesną optymalizacją wydajności.', 4, 1, 2, 12, N'Kwiatkowski', '2026-09-24T08:30:00', 540, NULL, NULL, 0),
(231, 6, N'Migracja SQL Servera na Databricks – praktyczny poradnik z wykorzystaniem GenAI', N'Praktyczna sesja pokazująca, jak skutecznie przenieść obciążenia z SQL Servera do Databricks Lakehouse z maksymalnym wykorzystaniem sztucznej inteligencji.
Omówimy:

- Strategie migracji (Analytics-First, ETL-First, Lift-and-Shift)
- Lakebridge + GenAI w automatyzacji analizy i konwersji kodu T-SQL / SSIS
- Unity Catalog, Lakehouse Federation, column masking i Row Level Security
- Najlepsze praktyki budowania medallion architecture oraz parallel run

Sesja skierowana do DBA, inżynierów danych, architektów i BI Developerów.', 2, 1, 2, 12, N'GDAŃSK', '2026-09-25T14:45:00', 45, NULL, NULL, 0),
(232, 6, N'The Future of Data Quality: Can We Let Data Fix Itself?', N'Data Quality has traditionally focused on detecting problems: finding missing values, broken pipelines, and inconsistent data. But what happens after an issue is discovered?

This SessionDetails explores the next step in data reliability: automated data correction and remediation. Can modern data platforms move beyond alerts and manual fixes toward self-healing data processes?

We will discuss where autonomous data corrections make sense, where human decisions are still essential, and how combining Data Quality, Data Observability, and automation can create more resilient data ecosystems.

Key topics:

* from data validation to automated remediation,
* safe patterns for autonomous data corrections,
* balancing automation, governance, and trust.', 2, 3, 2, 3, N'GDYNIA', '2026-09-25T13:45:00', 45, NULL, NULL, 0),
(233, 6, N'Don’t Let Your Permissions Be Hijacked!', N'You are sysadmin on a production server, and on this server, there are databases where there are users with power permissions such as the db_owner or db_ddladmin roles. They have no server-level permissions, but there may be rogues who want to perform actions beyond what their own permissions allow them to. One they can achieve this is to have you to unknowingly run code that perform these actions, using your almighty permissions – or by another word hijacking them. For instance, if you have set up a reindexing job for all databases, this is a great opportunity for permission hijacking.

Not only sysadmin can be the victim of such attacks, but a developer who has permissions to create stored procedures and triggers can attack a user who is in the db_owner role to extend his or her permission in the database.

In this SessionDetails I will discuss some of the possible attacks on this theme and what means you can take to protect yourself against them.', 2, 3, 1, 12, N'SOPOT', '2026-09-25T13:45:00', 45, NULL, NULL, 0),
(234, 6, N'The Burrito Bot: AI-Powered Search in SQL Server 2025', N'SQL Server 2025 introduces native vector support, enabling AI-powered semantic search directly inside the database engine. But what does that mean for data professionals and how does it actually work?

In this session, we’ll break down the fundamentals of vector search and show exactly how SQL Server stores, indexes, and queries embeddings to deliver semantic search capabilities.

We’ll cover: -
How the vector data type works in SQL Server
How to generate and store embeddings using an external LLM
Performing searches using vector_search() and vector_distance()
How vector indexes work under the hood

We''ll then bring it all together to build an intelligent, AI-driven application to...provide burrito restaurant recommendations in Ireland.

This SessionDetails is ideal for data professionals and developers who want a practical understanding of SQL Server’s vector capabilities, with real demos and a real use case.', 2, 3, 1, 12, N'SOPOT', '2026-09-25T15:45:00', 45, NULL, NULL, 0),
(235, 6, N'SQL Anti-Patterns That Survive Code Reviews', N'Większość zespołów robi code review. Mamy pull requesty, checklisty, doświadczonych developerów, architektów i testy automatyczne. A mimo to na produkcję nadal trafiają zapytania SQL, które zwracają poprawne wyniki, ale są kruche, trudne do utrzymania i coraz droższe wraz ze wzrostem danych.

Dlaczego? Ponieważ podczas review najczęściej zadajemy niewłaściwe pytanie: „Czy działa?”. Znacznie rzadziej zastanawiamy się, jaką kardynalność zakłada zapytanie, co stanie się po pojawieniu się wartości NULL, jak kod zachowa się przy stukrotnie większym wolumenie albo czy jego poprawność nie zależy od niewidocznych na pierwszy rzut oka właściwości schematu, typów danych i środowiska wykonania.

W tej sesji przeanalizujemy przypadki SQL, które regularnie przechodzą przez code review nie dlatego, że są dobre, ale dlatego, że sprawiają takie wrażenie. Skupimy się na sytuacjach, w których poprawność składni i wyniku przysłania istotniejsze pytania dotyczące semantyki danych, ukrytych założeń, skalowalności oraz długoterminowego utrzymania rozwiązania.

Na przykładach z codziennej pracy pokażę, jak pozornie niewinne decyzje prowadzą do błędów biznesowych, problemów wydajnościowych, awarii po zmianie schematu oraz zachowań, których nie dało się przewidzieć, analizując wyłącznie sam fragment kodu.

Nie będzie to katalog pułapek składniowych ani sesja poświęcona analizie pojedynczych execution planów. Konkretne przykłady T-SQL posłużą nam do pokazania szerszego problemu: kod może wyglądać poprawnie, choć jego zachowanie zależy od założeń dotyczących danych, metadanych, środowiska wykonania i przyszłych zmian. To sesja o tym, jak rozpoznawać te założenia podczas code review, zanim ich konsekwencje pojawią się na produkcji.', 2, 3, 2, 12, N'GDAŃSK', '2026-09-25T10:00:00', 45, NULL, NULL, 0),
(236, 6, N'Agentic AI na Databricks: agenci, narzędzia i RAG', N'Warsztat pokazuje, jak zbudować prostego agenta AI na platformie Databricks. Uczestnicy przejdą od prototypu w AI Playground, przez tool-calling i RAG, aż do scenariusza end-to-end wykorzystującego dokumenty oraz dane tabelaryczne.

Zakres warsztatu

Agentic AI i AI Playground

* agent vs chatbot i klasyczny RAG,
* podstawowe wzorce agentowe,
* szybkie prototypowanie i testowanie agenta.

Tool-calling i RAG

* projektowanie narzędzi agenta,
* wybór narzędzia i obsługa fallbacku,
* wykorzystanie dokumentów, Vector Search i kontekstu RAG.

Dane tabelaryczne, SQL i Genie

* SQL i funkcje jako narzędzia agenta,
* kontrolowany dostęp do danych,
* rola Genie w pracy z danymi biznesowymi.

Warsztat end-to-end

* budowa agenta wybierającego między RAG a danymi tabelarycznymi,
* testowanie pytań użytkownika,
* poprawa promptów, narzędzi i fallbacku.

MCP, bezpieczeństwo i rozwój rozwiązania

* podstawy Model Context Protocol,
* least privilege, governance i kontrola dostępu,
* ograniczenia środowisk testowych,
* elementy wymagane przed wdrożeniem produkcyjnym.

Efekty warsztatu

Po warsztacie uczestnicy będą potrafili:

* wyjaśnić różnice między chatbotem, RAG i Agentic AI,
* zbudować prostego agenta na Databricks,
* połączyć RAG z narzędziem do danych tabelarycznych,
* przetestować logikę wyboru narzędzi i fallbacku,
* wskazać podstawowe ryzyka dotyczące bezpieczeństwa, kosztów i governance.

Warsztat koncentruje się na praktycznym prototypie. Pełna konfiguracja produkcyjna, MCP, AI Gateway i deployment zostaną omówione jako kierunki dalszego rozwoju.', 4, 3, 2, 2, N'Schopenhauer', '2026-09-24T08:30:00', 540, NULL, NULL, 0),
(237, 6, N'Kupiłeś Fabric. I co teraz? Praktyczny warsztat dla ludzi od Power BI, SQL i Excela', N'Microsoft Fabric wygląda prosto, dopóki nie trzeba zbudować pierwszego sensownego rozwiązania. Wtedy pojawiają się pytania: Lakehouse czy Warehouse? Dataflow czy Notebook? Pipeline czy ręczne odświeżanie? Gdzie właściwie są dane? Czy Power BI dalej działa tak samo? Co z uprawnieniami, odświeżaniem, kosztami i wersjonowaniem?

Ten warsztat jest dla osób, które znają dane z perspektywy Power BI, SQL, Excela, raportowania albo prostego ETL, ale nie chcą zaczynać nauki Fabric od marketingowych diagramów i listy wszystkich usług. Zamiast omawiać Fabric zbudujemy od zera małe, kompletne rozwiązanie analityczne.

Zaczniemy od prostego scenariusza: mamy dane w plikach i tabelach, trzeba je wczytać, uporządkować, przygotować do raportowania i udostępnić w Power BI. W trakcie warsztatu utworzymy workspace, Lakehouse, tabele, prostą warstwę danych surowych i oczyszczonych, model semantyczny, raport oraz pipeline uruchamiający cały proces.

Po drodze wyjaśnimy, do czego naprawdę służą najważniejsze elementy Fabric: OneLake, Lakehouse, Warehouse, Dataflow Gen2, Notebook, Pipeline, semantic model i Power BI.', 4, 4, 2, 3, N'Heweliusz', '2026-09-24T08:30:00', 540, NULL, NULL, 0),
(238, 6, N'Migracja projektów Data & Analytics: to nie tylko zmiana connection stringa', N'Migracje projektów Data & Analytics, szczególnie Azure-to-Azure, często wyglądają z zewnątrz jak prosty lift-and-shift: zmienić connection stringi, dostosować trochę kod i uruchomić rozwiązanie na nowej platformie.

W praktyce opóźnienia i komplikacje często kryją się w miejscach, których na początku nie widać: discovery, niejasnym ownershipie, dostępie do danych, zależnościach downstream, sieciach, walidacji wyników, czy wyłączaniu starego rozwiązania.

Podczas sesji pokażę te ukryte elementy procesu migracji, wyjaśnię dlaczego potrafią zająć tak dużo czasu i podpowiem, jak uwzględnić je już na etapie planowania oraz estymacji.

Całość opiera się na prawdziwych doświadczeniach z migracji rzeczywistych projektów.', 2, 4, 2, 3, N'GDAŃSK', '2026-09-25T11:00:00', 45, NULL, NULL, 0),
(239, 6, N'MCP Servers - build your own toolkit for AI agents', N'W praktycznej pracy z agentami AI szybko pojawia się pytanie: jak mają korzystać z naszych wewnętrznych baz wiedzy i narzędzi w sposób kontrolowany, a nie oparty na przypadkowym promptowaniu? Jednym z rozwiązań tego problemu są serwery MCP.

W tej sesji pokażemy, czym jest MCP i jak wykorzystać go do budowania własnego zestawu narzędzi dla agentów AI. Przejdziemy przez praktyczny scenariusz: zbudujemy własny serwer MCP, wystawimy go, podłączymy i zintegrujemy z jednym z narzędzi developerskich, tak aby agent mógł korzystać z danych i akcji w bardziej uporządkowany sposób.

Zrobimy też mały pojedynek: agent z MCP kontra agent bez MCP. Sprawdzimy, który szybciej dochodzi do celu, który daje bardziej sensowne odpowiedzi i który rzadziej odpływa w kreatywne bajkopisarstwo.

Jeżeli chcesz zobaczyć, jak wygląda podstawowa architektura serwera MCP, jak udostępniać agentowi własne narzędzia i dane oraz w jakich przypadkach MCP realnie upraszcza pracę, a kiedy może być zbędnym dodatkiem - ta sesja jest dla Ciebie.', 2, 3, 2, 2, N'GDAŃSK', '2026-09-25T15:45:00', 45, NULL, NULL, 0),
(240, 6, N'Good Design Wins Adoption', N'The visual design theory behind reports people actually use.

I''ve watched the same thing happen on two different Power BI reports
built from identical data, for the same audience. One got opened
every Monday. One got exported to Excel and never touched Power BI
again.

The difference wasn''t the DAX. It was Gestalt grouping, pre-attentive
attributes, the 60-30-10 color rule: things most report builders have
never heard of, and all of which decide in the first four seconds
whether anyone trusts what they''re looking at.

This talk pulls apart the actual theory (Colin Ware''s pre-attentive
attributes, Tufte''s data-ink ratio, the eye-tracking research behind
why dashboards get scanned top-left to bottom-right) and turns it
into rules you can apply immediately: the 3-30-300 layout rule, why a
KPI without a target is decoration, and five things to refuse the
moment someone asks for them (yes, gauges are on the list).

It''s built for Power BI, but every principle in it works on any
screen you''re asking someone to trust. You''ll leave with a framework,
not a mood board.', 2, 1, 1, 7, N'SOPOT', '2026-09-25T10:00:00', 45, NULL, NULL, 0),
(241, 6, N'Ontologia Palantir Foundry jako brakujące ogniwo między SQL a LLM', N'Duża część dzisiejszych integracji AI z danymi to RAG oparty o wyszukiwanie wektorowe i podobieństwo semantyczne. Palantir Foundry daje alternatywę: ontologię, czyli warstwę typowanych obiektów i relacji nad danymi, która pozwala wykorzystywać kontekst strukturalny przed przekazaniem informacji do LLM podobnie jak SQL wykorzystuje schemat, relacje oraz operacje WHERE i JOIN.
Podejście zostanie zaprezentowane na dwóch przykładach przygotowanych na bazie otwartych zbiorów danych z Kaggle: analizy ryzyka chorób kardiologicznych oraz wyceny nieruchomości. Dzięki wykorzystaniu publicznych danych uczestnicy będą mogli samodzielnie odtworzyć przedstawione rozwiązania po zakończeniu sesji.
Celem sesji jest przybliżenie koncepcji Ontologii w Palantir Foundry oraz pokazanie, jak różni się ona od podejść spotykanych w większości współczesnych rozwiązań AI i Data Engineering.
Porównamy to podejście z popularnymi architekturami opartymi o RAG, wyszukiwanie wektorowe oraz klasyczne modele pracy z relacyjnymi bazami danych, wskazując podobieństwa, różnice i ograniczenia każdego z nich.
Sesja nie będzie prezentacją marketingową produktu, lecz próbą obiektywnego spojrzenia na różne podejścia do modelowania danych i budowy rozwiązań AI - zarówno koncepcje stosowane w Palantir Foundry, jak i popularne alternatywy oparte o klasyczne modele danych oraz architektury RAG.
Sesja skierowana jest do osób pracujących z danymi - Data Engineerów, analityków oraz developerów zainteresowanych wykorzystaniem LLM w połączeniu z danymi strukturalnymi.', 2, 3, 2, 2, N'GDYNIA', '2026-09-25T11:00:00', 45, NULL, NULL, 0),
(242, 6, N'Od kostki OLAP do agenta AI – dlaczego model danych znowu stał się superważny', N'Przez ostatnie lata odnieśliśmy ogromny sukces. Tworzenie raportów stało się prostsze niż kiedykolwiek wcześniej. Nowoczesne platformy analityczne pozwalają bardzo szybko importować dane i publikować atrakcyjne dla oka dashboardy. W efekcie wielu autorów raportów doszło do naturalnego wniosku:
„skoro użytkownik końcowy widzi jedynie raport, to właśnie raport jest najważniejszy”.

 A model danych? O ile liczby się zgadzają, wydaje się jedynie niewiele znaczącym szczegółem technicznym. Tymczasem starsze rozwiązania, takie jak Analysis Services Multidimensional, Essbase, Cognos czy SAP BW, zmuszały nas do znacznie większej dyscypliny. Projektowaliśmy fakty i wymiary, definiowaliśmy granulację danych, budowaliśmy hierarchie, dbaliśmy o jakość danych i precyzyjnie opisywaliśmy znaczenie miar. Nie dlatego, że lubiliśmy cierpieć, ale dlatego, że platforma nie pozwalała nam pójść na skróty.

Przez wiele lat wydawało się, że ten poziom rygoru nie jest już potrzebny. A potem pojawili się agenci AI i problemem stają się nie zaimplementowane w nich algorytmy, lecz niejednoznaczne modele danych, brak metadanych i wiele konkurujących wersji tej samej prawdy biznesowej.

Podczas sesji pokażemy, dlaczego praktyki znane z klasycznych platform BI wracają dziś w zupełnie nowej roli. Porozmawiamy o modelowaniu wymiarowym, warstwie semantycznej, metadanych, dokumentacji oraz o tym, dlaczego agent AI potrzebuje dobrze opisanego modelu danych bardziej niż wykresu słupkowego. W trakcie demonstracji na żywo zobaczymy również, jak ten sam zestaw danych zachowuje się w przypadku klasycznego raportu i w przypadku agenta AI odpowiadającego na pytania zadawane językiem naturalnym.

Bo być może nadchodzi era, w której najważniejszym konsumentem naszego modelu danych nie będzie już dashboard.

Będzie nim sztuczna inteligencja.

A ona — w przeciwieństwie do wielu użytkowników biznesowych — naprawdę czyta dokumentację. 😉', 2, 1, 2, 7, N'GDAŃSK', '2026-09-25T13:45:00', 45, NULL, NULL, 0),
(243, 6, N'Databricks & DevOps - How Declarative Automation Bundles help with CI/CD', N'Declarative Automation Bundles (DABs, previously known as Databricks Asset Bundles) bring an "infrastructure-as-code" approach to packaging and deploying notebooks, jobs, pipelines, and workflows across environments. Instead of clicking through the workspace UI or stitching together ad-hoc scripts, teams can define their entire Databricks project - code, configuration, and infrastructure - in YAML, version it alongside their source code, and deploy it consistently through a CI/CD pipeline.

In this session, we''ll explore how DevOps practices translate into the Databricks world. We''ll cover what Bundles are and how they compare to notebook-based deployments, how to structure a bundle for dev/test/prod environments, and how to wire them into a CI/CD pipeline (GitHub Actions/Azure DevOps) for automated validation and deployment. Along the way, we''ll look at common pitfalls, testing strategies, and how Bundles fit into a broader data platform governance and release process.

You''ll leave with a practical blueprint for automating Databricks deployments - reducing manual work, improving repeatability, and bringing real DevOps discipline to your data engineering workflows.', 2, 3, 2, 3, N'GDYNIA', '2026-09-25T15:45:00', 45, NULL, NULL, 0),
(244, 6, N'Lakehouse, Warehouse czy oba? Jak nie przekombinować architektury w Microsoft Fabric', N'Microsoft Fabric daje wiele możliwości zbudowania tego samego rozwiązania. Dane możemy umieścić w Lakehouse albo Warehouse, podzielić je na warstwy Bronze, Silver i Gold, rozdzielić pomiędzy kilka elementów lub trzymać w jednym miejscu. Do tego dochodzą notebooki, SQL, pipeline’y, shortcuty i modele semantyczne.

Samo uruchomienie tych komponentów jest stosunkowo proste. Trudniejsze jest zdecydowanie, których z nich rzeczywiście potrzebujemy.

Podczas sesji przejdziemy przez kilka typowych scenariuszy: rozwiązanie budowane głównie przez zespół SQL, przetwarzanie plików i danych częściowo ustrukturyzowanych oraz architekturę łączącą data engineering z raportowaniem w Power BI.

Zastanowimy się, kiedy wybrać Lakehouse, kiedy Warehouse, a kiedy połączyć oba podejścia. Porównamy również kilka sposobów zbudowania architektury medallion: jeden Lakehouse z podziałem logicznym, osobne elementy dla każdej warstwy oraz wariant, w którym Lakehouse obsługuje warstwy Bronze i Silver, a Warehouse warstwę Gold.

Porozmawiamy także o tym, kiedy warto używać shortcutów zamiast kopiowania danych oraz jaki wpływ podział rozwiązania ma na uprawnienia, wdrażanie, monitorowanie i późniejsze utrzymanie.

Celem sesji nie jest wskazanie jednej uniwersalnej architektury (bo takowej nie ma). Checemy pokazać, jakie pytania należy zadać przed rozpoczęciem budowy rozwiązania i jak uniknąć sytuacji, w której prosta potrzeba raportowa kończy się kilkunastoma elementami Fabric, których nikt nie chce później utrzymywać.', 2, 3, 2, 3, N'GDYNIA', '2026-09-25T10:00:00', 45, NULL, NULL, 0),
(245, 6, N'Cloud is the New Legacy: Why Medallion Architecture Won’t Save Your Chaos', N'Cloud migration is often presented as an opportunity to leave legacy behind. In reality, many organizations simply move existing data, processes and architectural problems to a new platform, add a few modern patterns, and call it transformation.

Medallion Architecture is a great example. Bronze, Silver and Gold layers can provide a useful structure, but they cannot fix unclear ownership, duplicated business logic, broken data pipelines, missing contracts or years of accumulated technical debt. If we migrate chaos, we can end up with a modern-looking lakehouse that is already becoming the next generation of legacy.

This SessionDetails takes a critical look at what happens when cloud migration becomes a technology exercise instead of an architecture and organizational transformation. We will explore common migration and data platform anti-patterns, why they emerge, and how to recognize them before they become expensive to maintain.

But this is not just a list of things that went wrong. We will also look at practical approaches to building data platforms that can actually evolve: domain ownership, data contracts, platform engineering, observability, pragmatic governance and knowing what not to migrate.

The goal is simple: stop moving yesterday’s problems faster and start designing platforms that will not become tomorrow’s legacy.', 2, 1, 2, 3, N'SOPOT', '2026-09-25T14:45:00', 45, NULL, NULL, 0),
(246, 6, N'Source-Aligned Data Products: From theory to demo', N'A source-aligned data product is supposed to be the building block in data mesh, yet still many stumble getting them going. Where does it live in version control? Who owns it? How does it relate to the application it draws from?
This SessionDetails connects the dots between software architecture and analytical data. We''ll make the case that a source-aligned data product inherits the bounded context of the application it extends, and explore what that means for how you structure your codebase, manage contracts, and maintain clear ownership, regardless of your specific tooling choices.
In the second half, there will be a demo that goes from requirements description all the way to a generated data contract, to data pipeline development. You''ll walk away with a practical framework for thinking about source-aligned data products and a glimpse of how generative AI can take the grunt work out of creating them.', 2, 3, 1, 12, N'SOPOT', '2026-09-25T12:00:00', 45, NULL, NULL, 0),
(247, 6, N'Why AI Adoption is about the Culture and not the Technology?', N'Enterprises invest millions in AI platforms, yet success rates remain stubbornly low. The culprit? A blind spot: culture. In this opening keynote, Marek Maśko reveals why technical excellence can’t compensate for cultural inertia, and how ignoring human factors leads to stalled pilots, shadow resistance, and “AI fatigue.”

We’ll dissect the top challenges - fear of job displacement, lack of trust in AI decisions, and leadership misalignment - and share proven strategies to overcome them. From building psychological safety to designing role-specific learning paths, you’ll learn how to transform AI from a novelty into a trusted partner in everyday work. Join us for a candid look at why most AI programs fail - and how to build the cultural foundation that makes them succeed.', 1, 4, 1, 2, N'GDAŃSK', '2026-09-25T09:25:00', 20, NULL, NULL, 0);

INSERT INTO dbo.SessionSpeaker (SessionId, SpeakerId, SpeakerOrder, IsSubmissionOwner) VALUES
(1, 46, 1, 1),
(2, 61, 1, 1),
(3, 106, 1, 1),
(3, 115, 2, 0),
(4, 57, 1, 1),
(5, 28, 1, 1),
(6, 62, 1, 1),
(7, 66, 1, 1),
(8, 64, 1, 1),
(8, 72, 2, 0),
(9, 50, 1, 1),
(10, 146, 1, 1),
(11, 135, 1, 1),
(12, 82, 1, 1),
(13, 18, 1, 1),
(14, 14, 1, 1),
(15, 77, 1, 1),
(16, 144, 1, 1),
(17, 39, 1, 1),
(18, 44, 1, 1),
(18, 147, 2, 0),
(19, 45, 1, 1),
(20, 119, 1, 1),
(21, 86, 1, 0),
(22, 156, 1, 1),
(22, 129, 2, 0),
(23, 87, 1, 1),
(24, 87, 1, 1),
(25, 45, 1, 1),
(26, 120, 1, 1),
(27, 62, 1, 1),
(28, 101, 1, 1),
(29, 54, 1, 1),
(30, 79, 1, 1),
(30, 70, 2, 0),
(31, 4, 1, 1),
(32, 113, 1, 1),
(32, 10, 2, 0),
(33, 49, 1, 1),
(34, 103, 1, 1),
(35, 102, 1, 1),
(35, 2, 2, 0),
(36, 112, 1, 1),
(37, 138, 1, 1),
(37, 77, 2, 0),
(38, 138, 1, 1),
(39, 128, 1, 1),
(40, 53, 1, 1),
(40, 87, 2, 0),
(41, 142, 1, 1),
(42, 53, 1, 1),
(43, 79, 1, 1),
(43, 70, 2, 0),
(43, 107, 3, 0),
(43, 65, 4, 0),
(43, 113, 5, 0),
(43, 10, 6, 0),
(43, 101, 7, 0),
(43, 110, 8, 0),
(43, 124, 9, 0),
(44, 107, 1, 1),
(45, 133, 1, 1),
(46, 159, 1, 1),
(46, 63, 2, 0),
(47, 147, 1, 1),
(47, 144, 2, 0),
(48, 107, 1, 1),
(48, 124, 2, 0),
(49, 126, 1, 1),
(50, 110, 1, 1),
(51, 22, 1, 1),
(52, 19, 1, 1),
(53, 99, 1, 1),
(54, 70, 1, 1),
(54, 79, 2, 0),
(55, 65, 1, 1),
(56, 27, 1, 1),
(57, 114, 1, 1),
(57, 30, 2, 0),
(58, 34, 1, 1),
(177, 69, 1, 1),
(178, 74, 1, 1),
(179, 94, 1, 1),
(180, 62, 1, 1),
(181, 62, 1, 1),
(181, 155, 2, 0),
(182, 108, 1, 1),
(183, 151, 1, 1),
(183, 70, 2, 0),
(184, 4, 1, 1),
(185, 122, 1, 1),
(186, 70, 1, 1),
(186, 79, 2, 0),
(187, 137, 1, 1),
(188, 158, 1, 1),
(189, 27, 1, 1),
(189, 6, 2, 0),
(190, 5, 1, 1),
(190, 15, 2, 0),
(191, 112, 1, 1),
(192, 71, 1, 1),
(193, 45, 1, 1),
(194, 147, 1, 1),
(195, 97, 1, 1),
(195, 75, 2, 0),
(196, 156, 1, 1),
(197, 113, 1, 1),
(198, 93, 1, 1),
(199, 95, 1, 1),
(200, 65, 1, 1),
(201, 65, 1, 1),
(201, 150, 2, 0),
(202, 13, 1, 0),
(59, 156, 1, 1),
(60, 74, 1, 1),
(61, 61, 1, 1),
(62, 128, 1, 1),
(63, 95, 1, 1),
(64, 148, 1, 1),
(64, 125, 2, 0),
(64, 136, 3, 0),
(64, 124, 4, 0),
(65, 56, 1, 1),
(65, 24, 2, 0),
(66, 35, 1, 1),
(67, 35, 1, 1),
(68, 106, 1, 1),
(69, 47, 1, 1),
(70, 108, 1, 1),
(71, 50, 1, 1),
(72, 46, 1, 1),
(73, 124, 1, 1),
(73, 79, 2, 0),
(74, 142, 1, 1),
(75, 25, 1, 1),
(76, 137, 1, 1),
(76, 45, 2, 0),
(77, 137, 1, 1),
(77, 156, 2, 0),
(78, 76, 1, 1),
(79, 101, 1, 1),
(79, 113, 2, 0),
(79, 10, 3, 0),
(80, 128, 1, 1),
(80, 116, 2, 0),
(81, 65, 1, 1),
(81, 107, 2, 0),
(82, 70, 1, 1),
(82, 79, 2, 0),
(83, 78, 1, 1),
(84, 48, 1, 1),
(85, 48, 1, 1),
(86, 101, 1, 1),
(87, 52, 1, 1),
(88, 51, 1, 1),
(89, 129, 1, 1),
(90, 26, 1, 1),
(91, 82, 1, 1),
(91, 70, 2, 0),
(92, 143, 1, 1),
(92, 83, 2, 0),
(93, 29, 1, 1),
(93, 140, 2, 0),
(93, 111, 3, 0),
(93, 12, 4, 0),
(93, 68, 5, 0),
(94, 139, 1, 1),
(95, 5, 1, 1),
(96, 84, 1, 1),
(97, 31, 1, 1),
(98, 66, 1, 1),
(99, 49, 1, 1),
(100, 53, 1, 1),
(100, 87, 2, 0),
(101, 111, 1, 1),
(101, 140, 2, 0),
(102, 134, 1, 1),
(103, 32, 1, 1),
(103, 151, 2, 0),
(104, 12, 1, 1),
(104, 140, 2, 0),
(105, 110, 1, 1),
(105, 113, 2, 0),
(106, 59, 1, 1),
(107, 113, 1, 1),
(108, 88, 1, 0),
(108, 118, 2, 1),
(109, 107, 1, 1),
(110, 117, 1, 1),
(111, 34, 1, 1),
(111, 98, 2, 0),
(112, 16, 1, 1),
(112, 37, 2, 0),
(113, 145, 1, 1),
(113, 21, 2, 0),
(114, 8, 1, 1),
(115, 73, 1, 1),
(116, 117, 1, 1),
(117, 10, 1, 1),
(118, 10, 1, 1),
(119, 155, 1, 1),
(119, 107, 2, 0),
(203, 157, 1, 1),
(204, 27, 1, 1),
(205, 137, 1, 1),
(205, 156, 2, 0),
(206, 101, 1, 0),
(206, 10, 2, 1),
(207, 49, 1, 1),
(208, 158, 1, 1),
(209, 43, 1, 1),
(210, 52, 1, 1),
(211, 155, 1, 1),
(211, 10, 2, 0),
(211, 101, 3, 0),
(211, 107, 4, 0),
(212, 52, 1, 1),
(213, 5, 1, 1),
(213, 15, 2, 0),
(214, 26, 1, 1),
(214, 130, 2, 0),
(215, 94, 1, 1),
(216, 155, 1, 1),
(216, 107, 2, 0),
(217, 53, 1, 1),
(218, 87, 1, 1),
(219, 142, 1, 1),
(220, 20, 1, 1),
(221, 103, 1, 1),
(222, 17, 1, 1),
(223, 65, 1, 1),
(223, 141, 2, 0),
(224, 127, 1, 0),
(120, 125, 1, 1),
(121, 74, 1, 1),
(121, 3, 2, 0),
(122, 39, 1, 1),
(123, 46, 1, 1),
(123, 36, 2, 0),
(124, 40, 1, 1),
(125, 158, 1, 1),
(126, 61, 1, 1),
(127, 71, 1, 1),
(128, 92, 1, 1),
(129, 92, 1, 1),
(130, 57, 1, 1),
(131, 137, 1, 1),
(132, 132, 1, 1),
(133, 156, 1, 1),
(133, 16, 2, 0),
(134, 105, 1, 1),
(135, 100, 1, 1),
(136, 100, 1, 1),
(137, 137, 1, 1),
(138, 154, 1, 1),
(138, 109, 2, 0),
(139, 70, 1, 1),
(139, 151, 2, 0),
(140, 84, 1, 1),
(141, 45, 1, 1),
(142, 77, 1, 1),
(142, 33, 2, 0),
(143, 10, 1, 1),
(144, 25, 1, 1),
(145, 79, 1, 1),
(145, 65, 2, 0),
(146, 80, 1, 1),
(147, 90, 1, 1),
(148, 91, 1, 1),
(149, 50, 1, 1),
(150, 60, 1, 0),
(151, 82, 1, 1),
(152, 47, 1, 1),
(153, 45, 1, 1),
(153, 65, 2, 0),
(154, 153, 1, 1),
(155, 113, 1, 1),
(156, 66, 1, 1),
(157, 129, 1, 1),
(157, 99, 2, 0),
(158, 110, 1, 1),
(159, 103, 1, 1),
(160, 38, 1, 1),
(161, 87, 1, 1),
(162, 53, 1, 1),
(163, 70, 1, 1),
(164, 89, 1, 1),
(165, 124, 1, 1),
(166, 112, 1, 1),
(167, 107, 1, 1),
(168, 121, 1, 1),
(169, 47, 1, 1),
(170, 160, 1, 1),
(171, 42, 1, 0),
(171, 41, 2, 0),
(172, 134, 1, 1),
(172, 36, 2, 0),
(173, 11, 1, 1),
(174, 115, 1, 1),
(175, 85, 1, 0),
(175, 104, 2, 0),
(176, 23, 1, 1),
(225, 132, 1, 1),
(226, 152, 1, 1),
(227, 9, 1, 1),
(228, 61, 1, 1),
(229, 61, 1, 1),
(230, 110, 1, 1),
(230, 99, 2, 0),
(231, 40, 1, 1),
(231, 1, 2, 0),
(232, 55, 1, 1),
(233, 158, 1, 1),
(234, 96, 1, 1),
(235, 156, 1, 1),
(236, 155, 1, 1),
(236, 58, 2, 0),
(237, 107, 1, 1),
(237, 124, 2, 0),
(238, 39, 1, 1),
(239, 137, 1, 1),
(239, 16, 2, 0),
(240, 131, 1, 1),
(241, 7, 1, 1),
(241, 149, 2, 0),
(242, 65, 1, 1),
(242, 141, 2, 0),
(243, 82, 1, 1),
(244, 107, 1, 0),
(244, 123, 2, 1),
(245, 83, 1, 1),
(246, 67, 1, 1),
(247, 81, 1, 0);

INSERT INTO dbo.SessionTag (SessionId, TagId) VALUES
(2, 9),
(2, 28),
(2, 48),
(2, 67),
(2, 75),
(3, 1),
(3, 63),
(4, 28),
(4, 35),
(5, 1),
(6, 24),
(6, 29),
(6, 53),
(7, 18),
(7, 53),
(8, 5),
(8, 6),
(8, 8),
(8, 10),
(8, 11),
(8, 16),
(8, 22),
(8, 23),
(8, 27),
(8, 35),
(10, 9),
(10, 63),
(10, 67),
(10, 69),
(10, 70),
(10, 71),
(11, 20),
(11, 53),
(11, 60),
(12, 6),
(12, 16),
(12, 27),
(13, 53),
(14, 20),
(14, 28),
(14, 53),
(15, 10),
(15, 18),
(15, 22),
(16, 1),
(16, 63),
(17, 8),
(17, 16),
(18, 1),
(18, 16),
(18, 18),
(18, 20),
(18, 22),
(18, 35),
(18, 53),
(18, 60),
(18, 65),
(19, 5),
(19, 8),
(19, 41),
(20, 71),
(22, 9),
(22, 69),
(22, 70),
(22, 71),
(22, 75),
(23, 8),
(23, 10),
(23, 18),
(23, 22),
(24, 16),
(24, 53),
(24, 65),
(25, 5),
(25, 63),
(26, 4),
(26, 5),
(26, 8),
(26, 11),
(26, 41),
(26, 60),
(27, 75),
(28, 5),
(28, 8),
(28, 22),
(28, 49),
(29, 5),
(29, 8),
(30, 8),
(30, 10),
(30, 11),
(30, 16),
(30, 18),
(30, 22),
(30, 23),
(30, 30),
(30, 41),
(30, 42),
(32, 8),
(32, 22),
(32, 51),
(34, 22),
(34, 28),
(34, 30),
(34, 43),
(34, 63),
(36, 5),
(36, 8),
(36, 11),
(36, 41),
(36, 42),
(36, 58),
(39, 6),
(39, 8),
(39, 11),
(39, 16),
(39, 22),
(39, 23),
(40, 10),
(40, 18),
(40, 22),
(40, 65),
(41, 20),
(41, 53),
(41, 60),
(42, 10),
(42, 18),
(42, 22),
(44, 53),
(46, 28),
(46, 53),
(47, 1),
(47, 6),
(47, 8),
(47, 27),
(47, 28),
(47, 48),
(47, 53),
(47, 71),
(47, 75),
(48, 6),
(48, 30),
(48, 58),
(48, 74),
(54, 10),
(54, 18),
(54, 58),
(54, 65),
(54, 75),
(56, 1),
(56, 8),
(56, 24),
(56, 53),
(57, 8),
(57, 10),
(57, 43),
(57, 45),
(58, 1),
(58, 9),
(58, 45),
(60, 9),
(60, 62),
(62, 6),
(62, 8),
(62, 22),
(62, 23),
(62, 25),
(62, 46),
(63, 22),
(64, 38),
(64, 39),
(64, 59),
(64, 73),
(66, 7),
(66, 9),
(66, 28),
(66, 32),
(66, 48),
(66, 51),
(66, 67),
(66, 70),
(66, 71),
(67, 9),
(67, 28),
(67, 37),
(67, 48),
(67, 67),
(67, 70),
(67, 71),
(67, 75),
(68, 1),
(68, 9),
(68, 39),
(68, 45),
(69, 1),
(69, 9),
(69, 31),
(69, 34),
(69, 51),
(69, 70),
(69, 71),
(70, 39),
(70, 45),
(70, 53),
(72, 1),
(72, 28),
(72, 35),
(73, 10),
(73, 11),
(73, 51),
(73, 65),
(74, 20),
(74, 24),
(74, 53),
(75, 5),
(75, 28),
(75, 53),
(76, 5),
(76, 41),
(76, 42),
(77, 8),
(77, 16),
(77, 22),
(77, 45),
(78, 2),
(78, 3),
(78, 33),
(78, 40),
(79, 5),
(79, 8),
(79, 22),
(79, 40),
(79, 42),
(80, 10),
(80, 18),
(80, 22),
(80, 23),
(80, 30),
(80, 49),
(80, 64),
(80, 75),
(82, 5),
(83, 28),
(83, 71),
(86, 5),
(88, 1),
(88, 10),
(88, 39),
(88, 45),
(88, 60),
(90, 6),
(90, 27),
(90, 28),
(90, 47),
(92, 8),
(92, 11),
(92, 15),
(92, 28),
(92, 30),
(92, 35),
(92, 44),
(92, 48),
(92, 63),
(92, 70),
(92, 75),
(93, 8),
(93, 9),
(93, 67),
(94, 8),
(94, 10),
(94, 18),
(94, 22),
(94, 30),
(94, 60),
(95, 23),
(95, 27),
(96, 8),
(96, 22),
(96, 28),
(96, 30),
(97, 51),
(97, 75),
(98, 1),
(98, 8),
(98, 43),
(101, 1),
(101, 8),
(101, 9),
(101, 11),
(101, 28),
(101, 35),
(101, 43),
(101, 44),
(101, 45),
(101, 67),
(101, 71),
(101, 75),
(102, 1),
(102, 45),
(103, 43),
(103, 45),
(103, 53),
(103, 60),
(103, 63),
(103, 64),
(104, 8),
(104, 67),
(108, 33),
(108, 61),
(111, 50),
(111, 51),
(111, 52),
(111, 68),
(113, 6),
(113, 10),
(113, 30),
(113, 35),
(113, 64),
(117, 17),
(117, 19),
(118, 2),
(118, 9),
(118, 33),
(119, 9),
(119, 28),
(119, 46),
(119, 51),
(119, 68),
(120, 46),
(120, 59),
(122, 8),
(123, 6),
(123, 30),
(123, 46),
(123, 62),
(124, 10),
(124, 11),
(124, 22),
(124, 33),
(125, 51),
(125, 68),
(125, 75),
(126, 9),
(126, 28),
(126, 67),
(126, 68),
(126, 75),
(127, 2),
(127, 5),
(127, 8),
(127, 12),
(127, 14),
(127, 33),
(130, 1),
(130, 6),
(130, 16),
(130, 46),
(130, 58),
(131, 2),
(131, 5),
(131, 33),
(131, 40),
(131, 68),
(133, 63),
(133, 68),
(134, 1),
(134, 28),
(134, 51),
(134, 72),
(135, 24),
(135, 46),
(135, 53),
(136, 24),
(136, 53),
(137, 2),
(137, 5),
(137, 22),
(137, 41),
(137, 42),
(137, 58),
(137, 65),
(138, 6),
(138, 30),
(138, 44),
(139, 46),
(139, 64),
(140, 22),
(140, 30),
(140, 65),
(141, 2),
(141, 3),
(141, 33),
(141, 61),
(143, 2),
(143, 3),
(143, 5),
(144, 2),
(144, 3),
(144, 5),
(144, 40),
(144, 46),
(145, 2),
(145, 17),
(145, 19),
(145, 22),
(145, 40),
(146, 3),
(146, 31),
(146, 40),
(146, 59),
(146, 61),
(147, 8),
(147, 22),
(147, 28),
(147, 30),
(147, 35),
(147, 58),
(147, 66),
(148, 10),
(148, 22),
(148, 65),
(149, 46),
(149, 53),
(151, 46),
(151, 68),
(152, 9),
(152, 37),
(152, 51),
(152, 68),
(153, 3),
(153, 46),
(154, 68),
(154, 72),
(155, 22),
(155, 46),
(156, 1),
(156, 45),
(156, 46),
(158, 9),
(158, 68),
(158, 72),
(158, 75),
(159, 10),
(159, 48),
(159, 49),
(159, 73),
(160, 8),
(160, 11),
(160, 22),
(161, 46),
(162, 1),
(162, 8),
(162, 17),
(162, 22),
(163, 2),
(163, 5),
(163, 28),
(163, 47),
(165, 11),
(165, 23),
(165, 35),
(165, 46),
(165, 58),
(165, 62),
(165, 65),
(166, 2),
(166, 12),
(166, 40),
(167, 22),
(168, 66),
(170, 66),
(171, 13),
(171, 21),
(171, 26),
(171, 36),
(171, 46),
(171, 53),
(171, 54),
(171, 55),
(171, 66),
(172, 6),
(172, 29),
(172, 33),
(172, 46),
(172, 53),
(172, 66),
(173, 66),
(174, 2),
(174, 13),
(174, 46),
(174, 53),
(174, 56),
(174, 57),
(175, 66),
(176, 66);

INSERT INTO dbo.SpeakerEditionProfile (SpeakerId, EventEditionId, TagLine, Bio, LinkedInUrl, XUrl, CompanyWebsiteUrl, BlogUrl, FacebookUrl, InstagramUrl) VALUES
(1, 6, N'Principal Platform Architect', N'I''m a platform architect with 20 years of experience in software and cloud engineering. For many years I''ve been designing and building data platforms across both the private and public sectors, with a particular specialisation in Azure Databricks.', NULL, NULL, NULL, NULL, NULL, NULL),
(2, 1, N'EBIS, Development Manager/BI Architect & Consultant', N'Od ponad 4 lat pracuję jako BI Consultant, a od ponad 8 lat z danymi.
Na co dzień zajmuję się wdrażaniem i utrzymywaniem systemów BI w oparciu o technologie Microsoft. Power BI, bazy danych i usługi Azure to mój chleb powszedni. Jestem stałym prelegentem na spotkaniach Polskiej Grupy Użytkowników Power BI.', N'https://www.linkedin.com/in/dominik-d%C4%99bowski-91645a115/', NULL, NULL, NULL, NULL, NULL),
(3, 3, N'Solution Architect at SII', N'Ponad 15 lat w branży IT, w tym ponad dekada pracy z platformami Business Intelligence. Specjalizuję się w rozwiązaniach opartych na Microsoft Azure oraz Power BI i Microsoft Fabric. Z pasją dzielę się wiedzą z zakresu rozwiązań danych, architektury chmurowej, integracji i bezpieczeństwa informacji. Na co dzień pomagam w projektowaniu procesów ETL, budowie skalowalnych hurtownie danych oraz interaktywne raportó w Power BI, pomagając klientom w pełni wykorzystać potencjał ekosystemu danych Azure.', N'https://www.linkedin.com/in/maciejhelt/', NULL, N'https://sii.pl/', NULL, NULL, NULL),
(4, 1, N'Product Manager at Asseco Business Solutions, optimizer, problem solver', N'Magister o specjalizacji Inteligentych Systemów Informacyjnych na Politechnice Warszawskiej. Menedżer Produktu w Asseco Business Solutions. Entuzjasta programowania niskopoziomowego. Architekt i optymalizator silnika bazodanowego MS SQL Server.', N'https://www.linkedin.com/in/grzegorzlyp/', N'https://twitter.com/GrzegorzLyp', N'https://www.assecobs.pl', NULL, N'https://www.facebook.com/profile.php?id=100001054878385', NULL),
(4, 4, N'Product Manager at Asseco Business Solutions, optimizer, problem solver', N'Magister o specjalizacji Inteligentych Systemów Informacyjnych na Politechnice Warszawskiej. Menedżer Produktu w Asseco Business Solutions. Entuzjasta programowania niskopoziomowego. Architekt i optymalizator silnika bazodanowego MS SQL Server.', NULL, NULL, NULL, NULL, NULL, NULL),
(5, 2, N'Azure Data & Devops Freelancer', N'Azure and Data professional with over 8 years of experience in both Enterprise and Startup environments. Focused on bringing Big Data tooling together with proper DevOps approach.  Delivered successful Data warehousing and Data Lake projects, with a strong focus on best cloud practices and processes.
Used to work in a fast paced and client facing roles, always bringing value through properly selected technology to deal with the underlying business problem.', NULL, NULL, NULL, NULL, NULL, NULL),
(5, 4, N'Azure Data & Devops | EthosFlow', N'Azure and Data professional with over 7 years of experience in both Enterprise and Startup environments. Focused on bringing Big Data tooling together with proper DevOps approach.  Delivered successful Data warehousing and Lakehouse projects, with a strong focus on best cloud practices and processes.
Used to work in a fast paced and client facing roles, always bringing value through properly selected technology to deal with the underlying business problem.', NULL, NULL, NULL, NULL, NULL, NULL),
(5, 5, N'Azure Data & Devops Freelancer', N'Azure and Data professional with over 5 years of experience in both Enterprise and Startup environments. Focused on bringing Big Data tooling together with proper DevOps approach.  Delivered successful Data warehousing and Data Lake projects, with a strong focus on best cloud practices and processes.
Used to work in a fast paced and client facing roles, always bringing value through properly selected technology to deal with the underlying business problem.', NULL, NULL, NULL, NULL, NULL, NULL),
(6, 4, N'Eviden PowerBI Senior Developer', N'Majored in Computer Science and Econometrics in University of Economics in Poznan.
I''ve started out as marketing analyst working mainly in Excel/VBA. It became clear to me that working with data is a way to go.
After career change in 2013, I''ve been working on various reporting projects and during that time moved from MS Excel automated reports (VBA), through Tabular Model in Excel 2010 (already working in DAX and PowerQuery) straight to PowerBI world. Since 2019 I''ve worked in PowerBI-based reporting projects for various clients from pharma, FMCG, transport, public services.', NULL, NULL, NULL, NULL, NULL, NULL),
(7, 6, N'Senior Cloud Data Engineer', N'He is passionate about optimizing data pipelines to improve performance, reduce costs, and simplify solution maintenance. He has a strong interest in columnstore indexes and delta file architectures, leveraging these techniques to deliver scalable, efficient solutions.

An experienced Data Engineering professional with a Ph.D. in Affective Computing and a Master’s in Software Engineering, bringing over 12 years of expertise in designing, building, and optimizing Business Intelligence (BI) solutions and ETL processes.  Leader of Trojmiasto Data Community local group.', NULL, NULL, NULL, NULL, NULL, NULL),
(8, 2, N'Power BI Developer and Trainer', N'I have been working with Power BI since 2016. First as a Data Analyst, where together with Power Query in Excel it saved me countless hours of repetitive tasks. And later as a Power BI Specialist / Consultant, helping companies build data platforms based on Microsoft Data stack.
Currently I am a Senior Data Analyst / Power BI Developer at Volvo Group, focusing on creating solutions to monitor a data platform built on Azure cloud. Additionally, I am delivering trainings on Power BI, Power Automate and Azure data solutions.', N'https://www.linkedin.com/in/tszreder/', NULL, NULL, NULL, NULL, NULL),
(9, 6, N'Dominik Szcześniak', N'Data profesional who loves working on end-to-end solutions. In BI area for last 8 years. Fan of Power BI and its backend possibilities. For instance to serve data.
Worked on both on premises and cloud solutions, mostly in Microsoft/ Azure environment.
Currently combining Databricks and Power BI as serving layer.
Sharing knowledge via blog: danesawszedzie.pl and Author of tech-edu podcast: "Dane Są Wszędzie".', NULL, NULL, NULL, NULL, NULL, NULL),
(10, 1, N'CEO TIDK, MVP AI&Data Platform, Mentor, Futurolog', N'Prezes firmy TIDK. Doktorant na Politechnice Poznańskiej. Posiada 25-letnie doświadczenie w analizie danych, Business Intelligence oraz zaawansowanej analityce. W swojej karierze wiele lat zajmował się prowadzeniem projektów ERP i BI. Naukowo związany z Politechniką Poznańską w obszarze eksploracji danych. Posiada większość certyfikatów w zakresie danych i analizy danych Microsoft. Certyfikowany trener Microsoft. Od 2010 roku Microsoft Most Valuable Professional w kategorii Data Platform. Od 2018 roku jeden z 50 na świecie MVP w kategorii AI. Prelegent na licznych konferencjach w kraju i na świecie. Członek zarządu Polskiego Towarzystwa Informatycznego Oddział Wielkopolska, członek Polskiego Stowarzyszenia Sztucznej Inteligencji, lider Data Community Poland. Założyciel Data Scientist as a Service.', N'https://www.linkedin.com/in/lukaszgrala/', NULL, N'http://tidk.pl', N'https://linktr.ee/lukaszgrala', N'https://www.facebook.com/lukasz.grala/', NULL),
(10, 2, N'CEO TIDK, MVP Data & AI, Mentor, Futurolog', N'Prezes firmy TIDK. Absolwent studiów doktoranckich z obszaru sztucznej inteligencji na Politechnice Poznańskiej. Posiada ponad 25-letnie doświadczenie w projektowaniu rozwiązań analitycznych, analizie danych, uczeniu maszynowym oraz zaawansowanej analityce. Od 15 lat ewangelista rozwiązań AI. Posiada większość certyfikatów w zakresie danych i analizy danych Microsoft. Certyfikowany trener Microsoft. Od 2010 roku Microsoft Most Valuable Professional w kategorii Data Platform. Od 2018 roku jeden z 50 na świecie MVP w kategorii AI. Prelegent na licznych konferencjach w kraju i na świecie. Lider Data Community w Poznaniu. Autor podcastów i webinarów: "Opór jest daremny. Nadchodzi AI!", "Analityka w biznesie","Arena architektów". Wykładowca na wyższych uczelniach, między innymi na eMBA UE w Poznaniu', N'https://www.linkedin.com/in/lukaszgrala/', NULL, N'http://tidk.pl', N'https://linktr.ee/lukaszgrala', N'https://www.facebook.com/lukasz.grala/', NULL),
(10, 3, N'CEO TIDK, MVP Data & AI, Mentor, Futurolog', N'Prezes firmy TIDK. Absolwent studiów doktoranckich z obszaru sztucznej inteligencji na Politechnice Poznańskiej. Posiada ponad 25-letnie doświadczenie w projektowaniu rozwiązań analitycznych, analizie danych, uczeniu maszynowym oraz zaawansowanej analityce. Od 15 lat ewangelista rozwiązań AI. Posiada większość certyfikatów w zakresie danych i analizy danych Microsoft. Certyfikowany trener Microsoft. Od 2010 roku Microsoft Most Valuable Professional w kategorii Data Platform. Od 2018 roku jeden z 50 na świecie MVP w kategorii AI. Prelegent na licznych konferencjach w kraju i na świecie. Lider Data Community w Poznaniu. Autor podcastów i webinarów: "Opór jest daremny. Nadchodzi AI!", "Analityka w biznesie","Arena architektów". Wykładowca na wyższych uczelniach, między innymi na eMBA UE w Poznaniu', N'https://www.linkedin.com/in/lukaszgrala/', NULL, N'http://tidk.pl', N'https://linktr.ee/lukaszgrala', N'https://www.facebook.com/lukasz.grala/', NULL),
(10, 5, N'CEO TIDK, MVP Data & AI, Mentor, Futurolog', N'Prezes firmy TIDK. Absolwent studiów doktoranckich z obszaru sztucznej inteligencji na Politechnice Poznańskiej. Posiada ponad 25-letnie doświadczenie w projektowaniu rozwiązań analitycznych, analizie danych, uczeniu maszynowym oraz zaawansowanej analityce. Od 15 lat ewangelista rozwiązań AI. Posiada większość certyfikatów w zakresie danych i analizy danych Microsoft. Certyfikowany trener Microsoft. Od 2010 roku Microsoft Most Valuable Professional w kategorii Data Platform. Od 2018 roku jeden z 50 na świecie MVP w kategorii AI. Prelegent na licznych konferencjach w kraju i na świecie. Lider Data Community w Poznaniu. Autor podcastów i webinarów: "Opór jest daremny. Nadchodzi AI!", "Analityka w biznesie","Arena architektów". Wykładowca na wyższych uczelniach, między innymi na eMBA UE w Poznaniu', NULL, NULL, NULL, NULL, NULL, NULL),
(11, 3, N'Senior BI Consultant', N'Dawid Kolasa, PhD – BI & Data Consultant w Clouds On Mars, specjalizujący się w projektowaniu rozwiązań analitycznych i AI wspierających decyzje biznesowe. Od blisko 20 lat łączy doświadczenie w obszarze Business Intelligence, analityki danych oraz zaawansowanego modelowania z praktyką biznesową zdobytą w projektach realizowanych dla producentów, retailerów i organizacji międzynarodowych.

Na co dzień pracuje z Power BI, Microsoft Fabric, Tabular Editor oraz rozwiązaniami opartymi o Machine Learning i AI, prowadząc inicjatywy związane m.in. z self-healing data, forecastingiem sprzedaży, modelami predykcyjnymi oraz architekturą nowoczesnych platform danych.

W swojej pracy szczególny nacisk kładzie na łączenie technologii z realnymi potrzebami biznesu — od zbierania wymagań, przez projektowanie modeli danych i dashboardów, aż po wdrożenie i automatyzację procesów analitycznych. Posiada również doświadczenie w prowadzeniu szkoleń oraz prezentacji dla kadry zarządczej i zespołów technicznych. Doktor nauk o zarządzaniu, absolwent Akademii Leona Koźmińskiego oraz Uniwersytetu Kardynała Stefana Wyszyńskiego.', N'https://www.linkedin.com/in/dawid-kolasa-phd-a5a327166/', NULL, N'https://cloudsonmars.com/', NULL, NULL, NULL),
(12, 2, N'Senior Product Manager at Microsoft, Managed Instance Product Group', N'Dr. Dani is a Senior Product Manager at Microsoft responsible for product development and business growth of flagship Azure SQL Managed Instance PaaS service. His areas of expertise in Azure SQL domain include hybrid environments, backup and restore, high availability, intelligence, monitoring, automatic tuning and user\human interfaces. His experience brings in more than 15+ years of product innovation worldwide starting from Silicon Valley start-ups innovating Internet technologies to enterprise innovation in the intelligent cloud space.', N'https://www.linkedin.com/in/danimir', N'https://twitter.com/danimir', N'https://azure.microsoft.com/en-us/products/azure-sql/database/', N'https://techcommunity.microsoft.com/t5/user/viewprofilepage/user-id/182256', NULL, NULL),
(13, 4, N'Head of AI @ Grupa NEUCA | AI, iRPA | 2xKaggle GM | Speakleash core team', N'As the Director of Projects and Intelligent Automation at NEUCA, the largest pharmaceutical distributor in Poland, I lead a team of experts in AI, RPA, chatbots, cognitive services, and machine learning. We deliver innovative solutions that improve the efficiency, quality, and customer satisfaction of our business processes and services.

With over 20 years of experience in managing complex and strategic programs, projects, portfolios, and project offices across various sectors, I have developed a strong track record of delivering results, driving change, and facilitating collaboration. I am also a certified coach (ICF / ACC), facilitator, and AgilePM practitioner, who supports the development and growth of individuals and teams.', NULL, NULL, NULL, NULL, NULL, NULL),
(14, 1, N'Business Intelligence Consultant', N'Pasjonat map, danych i technologii z bogatym doświadczeniem w pracy z systemami klasy BI oraz ERP, BPM i CRM. Przygodę z Excel’em zaczął od wersji 7 (to już 25 lat tej znajomości). Związany z Krakowem – od zawsze i raczej na zawsze. Urodzony z opcją analizy danych i przestrzeni topograficznej. Dzięki swojej rozległej wiedzy i doświadczeniu pomaga oszczędzać setki godziny potrzebnych, aby udanie wdrożyć zaplanowany projekt w zadanym czasie oraz budżecie. Uwielbia wymagające wdrożenia, jeśli jest tylko taka potrzeba szkoli i poszerza horyzonty – własne i klientów, uzyskując ich satysfakcję i zadowolenie. Przy okazji, duże zadowolenie sprawia mu obserwacja i rozpowszechnianie wiedzy informatycznej. Sezonowo w czasie wolnym jeździ na rowerze i na nartach, a przez cały rok grywa w piłkę nożną oraz wychowuje trójkę dzieci.', N'https://pl.linkedin.com/in/jacek-nosal-krpleu', NULL, NULL, NULL, NULL, NULL),
(15, 4, N'Azure Devops & Apps | EthosFlow', N'Karol Krupa began his career as a Java developer, honing his skills in software development and object-oriented programming. Transitioning into the realm of cloud computing, he specialized in DevOps with a focus on Microsoft technologies. John mastered Azure, implementing scalable, secure, and efficient cloud solutions. With his expertise, he has led numerous successful projects, optimizing cloud infrastructure and fostering innovation. Right now he focuses big data and enabling data transformations.', NULL, NULL, NULL, NULL, NULL, NULL),
(15, 5, N'Azure Devops & Apps | EthosFlow', N'Karol Krupa began his career as a Java developer, honing his skills in software development and object-oriented programming. Transitioning into the realm of cloud computing, he specialized in DevOps with a focus on Microsoft technologies. John mastered Azure, implementing scalable, secure, and efficient cloud solutions. With his expertise, he has led numerous successful projects, optimizing cloud infrastructure and fostering innovation. Right now he focuses big data and enabling data transformations.', NULL, NULL, NULL, NULL, NULL, NULL),
(16, 2, N'Senior Data Engineer at SoftwareOne', N'Senior Data engineer with several years of experience in Microsoft on-premise solutions. Deals with wide-ranging data processing from source files to reporting databases. Currently working on projects mainly related to Microsoft Azure and Databricks Solutions. At next He want to developing his experience towards MS Fabric solutions.

Member of the audit committee of Data Community Poland.', N'https://www.linkedin.com/in/piotrbalik/', NULL, NULL, NULL, NULL, NULL),
(16, 3, N'Senior Data Engineer at Datumo', N'Senior Data engineer with several years of experience in Microsoft on-premise solutions. Deals with wide-ranging data processing from source files to reporting databases. Currently working on projects mainly related to Microsoft Azure and Databricks Solutions. At next He want to developing his experience towards MS Fabric solutions.

Member of the audit committee of Data Community Poland.', N'https://www.linkedin.com/in/piotrbalik/', NULL, NULL, NULL, NULL, NULL),
(16, 6, N'Senior Data Engineer at Datumo', N'Senior Data engineer with several years of experience in Microsoft on-premise solutions. Deals with wide-ranging data processing from source files to reporting databases. Currently working on projects mainly related to Microsoft Azure and Databricks Solutions. At next He want to developing his experience towards MS Fabric solutions.

Member of the audit committee of Data Community Poland.', NULL, NULL, NULL, NULL, NULL, NULL),
(17, 5, N'Principal Architect, Microsoft Data Platform MVP', N'Mathias is a data enthusiast with a great passion for the synergy between data analytics and cloud data platforms.

As a Principal Architect at Fellowmind he works with building up clients'' data capabilities, implementing data platform technologies and all-in-all maximize the impact of their their data.

Being a Microsoft Data Platform MVP, he is very passionate about sharing anything with community, especially something around turning data into impact!

With a background in Product Development and Innovation, Mathias brings a unique ''Data Product'' perspective to the realm of data architecture, and is obsessed with the bigger picture. With his slightly rebellious attitude, he''s not afraid to challenge the status quo and break industry norms to find new and better solutions.', NULL, NULL, NULL, NULL, NULL, NULL),
(18, 1, N'MVP Data Platform - Product Manager, Pandora', N'Microsoft MVP Data Platform.

Works for Pandora, a jewelry brand based in Copenhagen (DK).
Product Manager for the common Content Management platform built on Sharepoint.
Co-admin of the company''s Power BI tenant with duties of governance, monitoring and auditing.
Solution Owner for the Data Analytics and Identity Access Management Azure platform.

Common speaker in events and conferences around Europe (SQL Saturdays, PASS Summit, SQL Nexus, Intelligent Cloud, SQL Konferenz, SQL Day Poland, dataMinds Connect, Power BI Summit, Power Platform Bootcamp, etc).
Speaker for DW/BI and the Italian Virtual Chapter.

Author for sqlservercentral.com, sqlshack.com, UGISS (User Group Italiano SQL Server).', N'https://www.linkedin.com/in/andrea-martorana-tusa-b247541/', N'https://twitter.com/bruco441', NULL, NULL, NULL, NULL),
(19, 1, N'BI Manager w DXC Technology.', N'BI Manager z ponad 20 letnim doświadczeniem w branży IT. Wieloletni BI/SQL Senior Consultant w technologiach MS SQL Server, Power BI, SAP BO, Microstrategy.', NULL, NULL, NULL, NULL, NULL, NULL),
(20, 5, N'Datumo, Data Engineer', N'Data engineer with 4+ years of experience across data warehousing and ML. Passionate about building scalable data solutions and applying machine learning to unlock insights from both structured and unstructured data.', NULL, NULL, NULL, NULL, NULL, NULL),
(21, 2, N'Senior Media Projects Manager Żabka Polska', N'Wioleta Sokołowska to marketerka z ponad 10-letnim doświadczeniem w obszarze mediów. Odpowiadała za wdrażanie strategii mediowych, łączących media offline i online, konsekwentnie zwiększając obecność marki Żabki w cyfrowym świecie. Obecnie, jako Senior Media Projects Manager w Żabka Polska, rozwija projekty nastawione na poprawę efektywności zakupu mediów i optymalizację wyników. Jest zwolenniczką patrzenia na marketing jak na inwestycję, a nie koszt, i każdego dnia szuka potwierdzenia tego w danych.', N'https://www.linkedin.com/in/wioleta-soko%C5%82owska-93b37980/', NULL, N'https://zabkagroup.com/pl/', NULL, NULL, NULL),
(22, 1, N'Senior Software Engineering Manager at CAE Poland', N'Na co dzień pracuje jako Menedżer międzynarodowego zespołu bazodanowego w CAE Flight Services Poland. Razem z zespołem wspiera kilkadziesiąt zespołów programistów, testerów, wdrożeniowców oraz pracowników wsparcia technicznego. Fan optymalizacji zapytań oraz zgłębiania wiedzy o SQL Server Internals. Z bazami danych a w szczególności SQL Serverem zawodowo związany od 2010 roku.', N'https://www.linkedin.com/in/marekmasko/', N'https://twitter.com/MarekMasko', NULL, NULL, NULL, NULL),
(23, 3, N'Founder of Woodler', N'Michal Tinthofer is the founder of Woodler, a company specializing in Microsoft SQL Server performance, monitoring, and optimization. With extensive experience in database architecture, troubleshooting, and enterprise-scale performance tuning, he helps organizations solve complex SQL Server challenges through data-driven analysis and deep technical expertise. He is also the driving force behind SMT, Woodler’s advanced SQL Monitoring & Tuning platform.', N'https://www.linkedin.com/in/michal-tinthofer-3b437528/', NULL, N'https://www.woodler.eu/', N'https://www.woodler.eu/blog', NULL, NULL),
(24, 2, N'Principal Consultant @ b.telligent', N'Data Enthusiast from Germany. Working as a Principal Consultant at btelligent', N'https://www.linkedin.com/in/tim-spannagel/', NULL, N'https://www.btelligent.com/', N'https://medium.com/@TimsMind', NULL, NULL),
(25, 2, N'Microsoft MVP / Power BI Consultant', N'Injae Park is a Microsoft Data Platform MVP who combines his technical expertise with a passion for teaching by sharing his insights and practical tips through his YouTube channel @PowerBIPark. Injae''s content ranges from beginner tutorials to advanced techniques, and as part of the Power BI Core Visual Representatives - he aims to bridge the MS Developer team with the Power BI community. His education in psychology and economics as well as his experience in consulting gives him a well-rounded perspective on the Power BI Developer experience, making his tutorials both engaging and accessible.', N'https://www.linkedin.com/in/injae-park/', NULL, N'https://www.youtube.com/@PowerBIPark', NULL, NULL, NULL),
(25, 3, N'Microsoft MVP / Power BI Consultant', N'Injae Park is a Microsoft Data Platform MVP who combines his technical expertise with a passion for teaching by sharing his insights and practical tips through his YouTube channel @PowerBIPark. Injae''s content ranges from beginner tutorials to advanced techniques, and as part of the Power BI Core Visual Representatives - he aims to bridge the MS Developer team with the Power BI community. His education in psychology and economics as well as his experience in consulting gives him a well-rounded perspective on the Power BI Developer experience, making his tutorials both engaging and accessible.', N'https://www.linkedin.com/in/injae-park/', NULL, N'https://www.youtube.com/@PowerBIPark', NULL, NULL, NULL),
(26, 2, N'Software, Data, DevOps Consultant at Promicro', N'My name is Tonie, with 20+ years of experience in IT I like to read, experiment, talk and write about software.
The fun I experience in my job is the combination of people and technology.
To be honest I''m not the greatest DBA, Developer or SysAdmin, but I like to follow up and combine a lot of the things those people do.

in 2021 I started to write small stories on Medium, because talking about software is one thing...
In my stories I explain Azure, SQL and other Microsoft technologies with (if possible) one central topic Whisky!', N'https://www.linkedin.com/in/toniehuizer/', N'https://twitter.com/promicroNL/', N'https://promicro.nl', N'http://log.vantonie.nl/', NULL, NULL),
(26, 5, N'Software, Data, DevOps Consultant at Promicro', N'Tonie Huizer is a Software, Data, and DevOps Consultant who believes good tech starts with understanding your people. A regular on international stages and a Microsoft Certified Azure Developer, Tonie loves helping teams simplify complex challenges; whether that’s modernizing database deployments, designing scalable systems, or just getting Dev and Ops to finally talk to each other.

Tonie is known for his clear, energetic presentation style and ability to make complex topics accessible and engaging. As a Redgate Community Ambassador, he advocates for database DevOps and contributes to open knowledge sharing through blogs, talks, and events across the globe. He also co-leads SeaQL Saturday, a community-driven event that blends education, networking, and Sammie, his Kooikerhondje mascot. (Because yes, even events are better with a dog.)

Whether he''s discussing Azure DevOps workflows, database release automation, or the cultural shifts required to implement DevOps successfully, Tonie brings real-world experience, humor, and actionable insights. His goal is to inspire professionals not just to adopt new technologies, but to transform how teams collaborate and innovate.

And when he’s not speaking about tech, he might just be speaking about whisky. Tonie is a passionate whisky enthusiast who loves sharing stories, flavors, and the occasional tasting SessionDetails with his fellow connoisseur of TasteWhisky. If you''re into DevOps, data, and a well-aged dram on the side, Tonie’s your man!', NULL, NULL, NULL, NULL, NULL, NULL),
(27, 1, N'Data Team Stream Lead SoftwareOne', N'Moja przygoda z raportowaniem i dostarczaniem danych dla użytkowników końcowych rozpoczęła się ponad 18 lat temu. Na początku pracowałem z prostymi arkuszami kalkulacyjnymi w oparciu o dane z bazy IBM DB2 ale z biegiem czasu zmieniłem swoją specjalizację na produkty firmy Microsoft i w końcu trafiłem do świata rozwiązań chmurowych. Obecnie moja praca skupia się na tabelarycznych modelach danych w Azure oraz procesach ETL opartych na DataBricks i Synapse.', N'https://www.linkedin.com/in/artur-dalak-9266345b/', NULL, NULL, NULL, NULL, NULL),
(27, 4, N'Data Team Stream Lead SoftwareOne', N'Moja przygoda z raportowaniem i dostarczaniem danych dla użytkowników końcowych rozpoczęła się ponad 18 lat temu. Na początku pracowałem z prostymi arkuszami kalkulacyjnymi w oparciu o dane z bazy IBM DB2 ale z biegiem czasu zmieniłem swoją specjalizację na produkty firmy Microsoft i w końcu trafiłem do świata rozwiązań chmurowych. Obecnie moja praca skupia się na tabelarycznych modelach danych w Azure oraz procesach ETL opartych na DataBricks i Synapse.', NULL, NULL, NULL, NULL, NULL, NULL),
(27, 5, N'Data Team Stream Lead SoftwareOne', N'Moja przygoda z raportowaniem i dostarczaniem danych dla użytkowników końcowych rozpoczęła się ponad 18 lat temu. Na początku pracowałem z prostymi arkuszami kalkulacyjnymi w oparciu o dane z bazy IBM DB2 ale z biegiem czasu zmieniłem swoją specjalizację na produkty firmy Microsoft i w końcu trafiłem do świata rozwiązań chmurowych. Obecnie moja praca skupia się na tabelarycznych modelach danych w Azure oraz procesach ETL opartych na DataBricks i Synapse.', NULL, NULL, NULL, NULL, NULL, NULL),
(28, 1, N'Speeding up your nested loops', N'French independent SQL server expert, Data Platform MVP, with 25 years experience. An old-fashioned relational database fan, open to NoSQL wanderings, but without ORM, please. More geared towards database development than administration, but needing to act as a DBA most of the time. He has authored several books, about SQL Server optimization, SQL Server security, and NoSQL. He has also authored video trainings at Pluralsight, and in French at Linkedin Learning. He is speaking at community events across Europe. He could have been a cook, a writer or a mountain guide. What does he do in the database business ?', N'https://www.linkedin.com/in/rudibruchez/', NULL, N'https://www.pachadata.com', NULL, NULL, NULL),
(29, 2, N'Principal PM Manager at Microsoft', N'Joined Microsoft as a Program Manager in Azure SQL product group in 2016, after fifteen years in business analysis and product management, mostly in the financial industry. He''s been working on Azure SQL Managed Instance since its early days in areas of business continuity and disaster recovery, data virtualization, and data mobility.', N'https://www.linkedin.com/in/mladenandzic/', NULL, N'https://www.microsoft.com', N'https://techcommunity.microsoft.com/t5/azure-sql/bg-p/AzureSQLBlog', NULL, NULL),
(30, 1, N'Manager of Platform Component Management and Cloud Monitoring Team, Data & AI Foundation, Volvo Group Digital & IT', N'Stulik Sebastian is a Manager at Volvo Polska, leading the Automation and Cloud Monitoring team at the Volvo Data unit. Over 16 years of professional experience in multiple technologies, from Data Warehouse Development to building back-end and front-end data solutions. For the last few years responsible for business intelligence solutions and data platforms, both on-prem and cloud. He is currently managing the team of DevOps and Data Engineers as well as Power BI Developers accountable for the monitoring, performance, and optimizations of the Volvo Data Cloud platform.', N'https://www.linkedin.com/in/sstulik/', NULL, N'https://www.volvo.com/', NULL, NULL, NULL),
(31, 2, N'Microsoft, Senior Product Manager', N'Filip Popović is a Senior Product Manager at Microsoft and part of the Fabric Product Group, focusing on SQL performance. Before joining Microsoft in 2019, he spent over ten years in the software and financial services industry, delivering business analytics solutions using the Microsoft technology stack.', N'https://www.linkedin.com/in/popovicfilip/', N'https://twitter.com/FilipPop_MSFT', NULL, NULL, NULL, NULL),
(32, 2, N'Head of BI', N'Obecnie pracuje jako BI Evangelist w Infinite Services. Od ponad 17-tu lat związana z pracą w IT, bazami danych i BI-em. Na co dzień zajmuje się projektami BI oraz szerzeniem wiedzy o BI zarówno wewnątrz jak i na zewnątrz firmy', N'https://www.linkedin.com/in/ulacholewa/', NULL, NULL, NULL, NULL, NULL),
(33, 3, N'Cloud Formations, Consultant', N'Matt is a Senior Analytics Consultant working on end-to-end Data Platform solutions with the Microsoft Azure tech stack. He currently works at Cloud Formations, currently focusing on Data Engineering in both product development and delivery.

Outside of working with data, he is a keen skier, runner and beer drinker.', N'https://www.linkedin.com/in/matt-collins-0b5556135/', NULL, N'https://www.cloudformations.org/', N'https://medium.com/@mc12338', NULL, NULL),
(34, 1, N'Cloud Architect @ Lingaro', N'Since the beginning of my career I’m working with data, mainly in Microsoft technologies. For the last few years I’m focusing on Azure, both in professional and private projects.
I''m MCT with few certificates in Azure (Architect, Admin, Database Administrator, Data Engineer) providing internal and external trainings/sessions.', N'https://www.linkedin.com/in/szymon-lasota/', N'https://twitter.com/Shimon893', N'https://lingarogroup.com/', N'https://azureronin.pl/', NULL, NULL),
(34, 2, N'Cloud Architect @ Lingaro', N'Cloud Architect @ Lingaro

Since the beginning of my career I’m working with data, mainly in Microsoft technologies. For the last few years I’m focusing on Azure, both in professional and private projects.
I''m MCT with few certificates in Azure (Architect, Admin, Database Administrator, Data Engineer) providing internal and external trainings/sessions.', N'https://www.linkedin.com/in/szymon-lasota/', N'https://twitter.com/Shimon893', N'https://lingarogroup.com/', N'https://azureronin.pl/', NULL, NULL),
(35, 2, N'I make SQL Server fast (.com)', N'Hugo Kornelis is an established SQL Server community expert who spends a lot of time at various conferences. He is also a blogger, technical editor of a variety of books, and Pluralsight author. He was awarded SQL Server MVP and Data Platform MVP 17 times (2006 - 2016 / 2019 - now).

When not working for the community, he is busy at his day job: freelance database developer/consultant.

Hugo has over 25 years of SQL Server experience in various roles. Starting from a strong database design background, he has spent the last ten years specializing in execution plans and query performance tuning.', N'https://www.linkedin.com/in/hugokornelis/', N'https://twitter.com/hugo_kornelis', N'https://sqlserverfast.com/', N'https://sqlserverfast.com/blog/', NULL, NULL),
(36, 3, N'Head of Engineering, Technical Architect & Community Advocate at Tabular Editor', N'Peer is a seasoned Data & BI professional with over 15 years of experience delivering enterprise-grade analytics solutions across industries. He recently joined Tabular Editor as a Technical Architect & Community Advocate, where he helps shape the future of semantic modeling while supporting the global data community.

Previously, Peer was a key member of the twoday Microsoft Fabric expert group, where he helped define best practice frameworks for Fabric implementations - ranging from metadata-driven ingestion and transformation patterns to CI/CD pipelines and scalable ways of working across environments.

Peer’s involvement with Microsoft Fabric began in 2022 as part of the early private preview of what was then known as Project Trident. This early engagement has given him deep, practical insights into the platform’s architecture and evolution, making him a trusted authority on modern data engineering with Fabric.

Driven by a passion for community, innovation, and quality, Peer regularly shares his knowledge through blogs, talks, and open-source contributions - empowering others to unlock the full potential of their data platforms.', N'https://www.linkedin.com/in/groennerup/', NULL, N'https://www.tabulareditor.com', N'https://peerinsights.emono.dk', N'https://www.facebook.com/gronnerup', N'https://www.instagram.com/peergronnerup'),
(37, 2, N'SoftwareONE, Principal Project Manager', N'Project Manager z dwudziestoletnim doświadczeniem w branży IT.
Specjalizuję się w realizacji projektów z obszaru Business Intelligence.
Wdrożyłem wiele projektów związanych z hurtowniami danych, migracją rozwiązań on-premise do chmury czy też dotyczących wizualizacji danych
Pasjonuję się zagadnieniami związanymi z danymi, takimi jak np. data quality, governance lub bezpieczeństwo.
Entuzjasta zwinnych metodyk zarządzania projektami, głównie Scrum i SAFe.', N'https://www.linkedin.com/in/arturlachowicz/', NULL, N'https://www.softwareone.com/', NULL, NULL, NULL),
(38, 3, N'Head of Azure Practice at C&F, Microsoft Azure MVP', N'Microsoft Azure MVP i Cloud Architect z ponad 14 letnim doświadczeniem w branży IT. Pasjonat technologiczny ze szczególnym ukierunkowaniem na technologie Microsoft oraz chmurę Azure na którą od ostatnich kilku lat projektuje rozwiązania. Adam wdraża rozwiązania dla dużych firm międzynarodowych specjalizując się w dziedzinie Data & Analytics. W wolnym czasie Adam prowadzi własny kanał na YouTube (Azure for Everyone) poświęcony chmurze Azure.', N'https://www.linkedin.com/in/adam-marczak/', N'https://twitter.com/MarczakIO', N'https://www.youtube.com/AdamMarczakYT', N'https://marczak.io', NULL, NULL),
(39, 1, N'C&F, Senior Solutions Architect', N'W IT od ponad 18 lat, z czego większość związana z MS SQL Serverem. Fanatyk baz relacyjnych oraz optymalizacji ich wydajności. Ostatnimi czasy coraz śmielej i chętniej patrzący w stronę Azure''a z punktu widzenia systemów BIowych. Obecnie architekt chmurowy w C&F. Prywatnie miłośnik kotów oraz gier komputerowych.', N'https://www.linkedin.com/in/piotr-tybulewicz-81a8793/', NULL, NULL, NULL, NULL, NULL),
(39, 3, N'C&F, Senior solutions architect', N'Stary piernik namiętnie gadający o danych i szeroko rozumianym data engineeringu (zwłaszcza w Azure).', N'https://www.linkedin.com/in/piotr-tybulewicz-81a8793/', NULL, NULL, NULL, NULL, NULL),
(39, 6, N'C&F, Senior solutions architect', N'I''m a Cloud Architect with 20+ years of experience in IT, specializing in Azure data platforms and data governance. I design and deliver enterprise-scale solutions across Azure and Databricks, focusing on turning business requirements into practical, production-ready architectures.

I actively share knowledge through internal trainings and my YouTube channel, where I share lessons learned from real-world data platform implementations.', NULL, NULL, NULL, NULL, NULL, NULL),
(40, 3, N'Xebia, Data Engineer', N'Data Engineer with a proven track record of harnessing the power of data to drive innovation and efficiency. With over 9 years of experience in the field, I specialize in ETL processes, cloud solutions, and data storage, with a strong foundation in programming languages such as Python and SQL.

I am passionate about using technology to make a positive impact on the world. As I continue to explore the frontiers of data engineering, I seek opportunities to collaborate with like-minded professionals and organizations that are committed to innovation and excellence.', N'https://www.linkedin.com/in/kacper-glugla-b15763153/', NULL, N'https://xebia.com/', NULL, NULL, NULL),
(40, 6, N'Xebia, Data Engineer', N'Data Engineer with a proven track record of harnessing the power of data to drive innovation and efficiency. With over 10 years of experience in the field, I specialize in ETL processes, cloud solutions, and data storage, with a strong foundation in programming languages such as Python and SQL.

I am passionate about using technology to make a positive impact on the world. As I continue to explore the frontiers of data engineering, I seek opportunities to collaborate with like-minded professionals and organizations that are committed to innovation and excellence.', NULL, NULL, NULL, NULL, NULL, NULL),
(41, 3, N'Head of Business and Decision Intelligence @ Lingaro', N'Damian is a results-driven Business Intelligence leader with over 11 years of experience in BI development, solution architecture, and delivery leadership. He has designed and delivered large-scale reporting solutions for C-level stakeholders, leading high-performing teams and managing terabyte-scale data environments. Passionate about performance optimization, data modeling, and working with billion-row datasets, he thrives on pushing Power BI to its limits—where scale, speed, and smart design truly matter. With a strong focus on AI, automation, and process efficiency, strategic vision to drive innovation and measurable business impact.', N'https://www.linkedin.com/in/damian-ostrowski-555899121/', NULL, N'https://lingarogroup.com/', NULL, NULL, NULL),
(42, 3, N'BI/AI Advisor', N'Magda is a BI/AI Advisor with over 13 years of experience in the BI field. Technology agnostic. Program Council Member for the BI track at Data Science Summit (2024, 2025). Speaker. She believes dashboards won’t disappear, but their development will require increasingly advanced skills—driven by both technological progress and growing user expectations around reporting, performance, and data consumption. Privately, an outdoor enthusiast.', NULL, NULL, NULL, NULL, NULL, NULL),
(43, 5, N'BigQuery pro', N'I work in Google Cloud with Big Data products, mostly BigQuery. I work with the biggest customers and data architectures in the world.

Before joining Google I used to work with Microsoft SQL Server for many years, especially in performance optimization field, but also migrations, upgrades, HA. I was an infra/db/BI architect and developer. I was a trainer, and done other consulting work in SQL Server and Azure.

I sometimes speak on domestic and international conferences including SQLDay, Google Build with Gemini: Developer Summit, SQLSaturday in several countries, SQLNexus, Global Azure Bootcamp and more.', NULL, NULL, NULL, NULL, NULL, NULL),
(44, 1, N'Microsoft MVP - Data Platform, Analytics Manager at Avanade', N'Pragati is a Data Platform MVP (Microsoft Most Valuable Professional).
Currently, she is working as a Manager at Avanade in UK and works towards generating and delivering data insights to various customers. She holds a Master’s degree in Data Science and Analytics from Royal Holloway University of London.
She is skilled in various tools and technologies like Microsoft Power BI, Tableau, Microsoft Excel, Azure ML Studio, Azure Databricks Pyspark and SQL.
She has been using Power BI for few years now and is recognised as a Superuser on the Microsoft Power BI Community.
Outside work she enjoys photography, loves hiking, she is a trained Indian classical singer and has a passion for painting. She even has her Instagram page dedicated to painting.

Microsoft MVP: https://mvp.microsoft.com/en-us/PublicProfile/5004163?fullName=Pragati%20Jain', N'https://www.linkedin.com/in/pragatijain1187/', N'https://twitter.com/pragati1187', N'https://datavibe.co.uk/', N'https://datavibe.co.uk/', NULL, NULL),
(45, 1, N'Freelancer Data Scientist working with and teaching SQL Server and Azure.', N'Marcin Szeliga is a Freelance Data Scientist who specializes in working with and teaching SQL Server and Azure, with over 25 years of experience in the field. Marcin has been consistently awarded the Microsoft Most Valuable Professional title since 2006 and is one of only two AI MVPs in Poland.

Marcin is an accomplished speaker at numerous European conferences, a university teacher, and an author of books and articles on the Microsoft data platform. Additionally, he serves on the program boards of the PWN publisher and the Polish Association of Artificial Intelligence in Medicine, with a commitment to advancing the field of data science and AI.

As a leader of Data Community Poland and an active member of the Polish data science communities, Marcin is passionate about building a vibrant and inclusive community of data professionals. His dedication to helping others unlock the power of data is evident in his work with clients, teaching students, and collaborating with fellow experts.', N'http://www.linkedin.com/in/marcinszeliga/', NULL, NULL, NULL, NULL, NULL),
(45, 2, N'Freelancer Data Scientist working with and teaching SQL Server and Azure.', N'Marcin Szeliga is a Freelance Data Scientist who specializes in working with and teaching SQL Server and Azure, with over 25 years of experience in the field. Marcin has been consistently awarded the Microsoft Most Valuable Professional title since 2006 and is one of only two AI MVPs in Poland.

Marcin is an accomplished speaker at numerous European conferences, a university teacher, and an author of books and articles on the Microsoft data platform. Additionally, he serves on the program boards of the PWN publisher and the Polish Association of Artificial Intelligence in Medicine, with a commitment to advancing the field of data science and AI.

As a leader of Data Community Poland and an active member of the Polish data science communities, Marcin is passionate about building a vibrant and inclusive community of data professionals. His dedication to helping others unlock the power of data is evident in his work with clients, teaching students, and collaborating with fellow experts.', N'http://www.linkedin.com/in/marcinszeliga/', NULL, NULL, NULL, NULL, NULL),
(45, 3, N'Freelancer Data Scientist working with and teaching SQL Server and Azure.', N'Marcin Szeliga is a Freelance Data Scientist who specializes in working with and teaching SQL Server and Azure, with over 25 years of experience in the field. Marcin has been consistently awarded the Microsoft Most Valuable Professional title since 2006 and is one of only two AI MVPs in Poland.

Marcin is an accomplished speaker at numerous European conferences, a university teacher, and an author of books and articles on the Microsoft data platform. Additionally, he serves on the program boards of the PWN publisher and the Polish Association of Artificial Intelligence in Medicine, with a commitment to advancing the field of data science and AI.

As a leader of Data Community Poland and an active member of the Polish data science communities, Marcin is passionate about building a vibrant and inclusive community of data professionals. His dedication to helping others unlock the power of data is evident in his work with clients, teaching students, and collaborating with fellow experts.', N'http://www.linkedin.com/in/marcinszeliga/', NULL, NULL, NULL, NULL, NULL),
(45, 4, N'Freelancer Data Scientist working with and teaching SQL Server and Azure.', N'Marcin Szeliga is a Freelance Data Scientist who specializes in working with and teaching SQL Server and Azure, with over 25 years of experience in the field. Marcin has been consistently awarded the Microsoft Most Valuable Professional title since 2006 and is one of only two AI MVPs in Poland.

Marcin is an accomplished speaker at numerous European conferences, a university teacher, and an author of books and articles on the Microsoft data platform. Additionally, he serves on the program boards of the PWN publisher and the Polish Association of Artificial Intelligence in Medicine, with a commitment to advancing the field of data science and AI.

As a leader of Data Community Poland and an active member of the Polish data science communities, Marcin is passionate about building a vibrant and inclusive community of data professionals. His dedication to helping others unlock the power of data is evident in his work with clients, teaching students, and collaborating with fellow experts.', NULL, NULL, NULL, NULL, NULL, NULL),
(46, 1, N'Data Platform MVP | Lead Data and AI |Public Speaker | InSpark | Innovate to Accelerate', N'Erwin de Kreuk is a passionate and very experienced Microsoft Solution Architect.
Working as a Principal Consultant/ Lead Data and AI for InSpark in the Netherlands. Speaking at different national and international data community events. He is been awarded as Data Platform MVP.

He is working in the world of data on the Microsoft Platform for last 14 years and the last 6 years he has shifted his focus to the Azure Platform.
Answering complex customer cases and technical issues are part of his day-to-day work. In addition to this work, he is a member of the Technology Board within InSpark and leads a team of highly experienced Data Expert in the field of Microsoft Data Platform.

He is eager in helping out customers in getting the most added value out of their complex Analytics environment with a strong focus on solutions in the Azure Cloud (Platform as a Service).
As a Technology Board member, he is always investigating the latest (vs newest) possibilities/opportunities and sharing his enthusiasm among his colleagues, the community and customers. He is one of the main Stakeholders for the InSpark Solution (Managed) Oxygen, a Modern Data platform Estate as-a-service.', N'https://www.linkedin.com/in/erwindekreuk/', N'https://twitter.com/ErwindeKreuk', N'https://erwindekreuk.com', N'https://erwindekreuk.com', NULL, NULL),
(46, 2, N'Data Platform MVP | Lead Data and AI |Public Speaker | InSpark | Innovate to Accelerate', N'Erwin de Kreuk is a passionate and highly experienced Microsoft Solution Architect. He currently serves as a Principal Consultant and Lead Data and AI at InSpark in the Netherlands. Erwin is a frequent speaker at various national and international data community events and has been recognized as a Data Platform MVP.

With 16 years of experience in the world of data on the Microsoft Platform, Erwin has spent the last 8 years focusing on the Azure Platform. His day-to-day work involves addressing complex customer cases and technical issues. Additionally, he is a member of the Technology Board at InSpark, where he leads a team of highly experienced Data Experts specializing in the Microsoft Data Platform.

Erwin is dedicated to helping customers maximize the value of their complex analytics environments, with a strong emphasis on solutions in the Azure Cloud (Platform as a Service) and Microsoft Fabric. As a Technology Board member, he continuously explores the latest opportunities and shares his enthusiasm with colleagues, the community, and customers. He is also a key stakeholder for the InSpark Solution (Managed) Oxygen, a Modern Data Platform Estate as-a-service and the Nitrogen Control Center a native solution build on top of Microsoft Fabric for easy data integration and data Processing.', N'https://www.linkedin.com/in/erwindekreuk/', N'https://twitter.com/ErwindeKreuk', N'https://erwindekreuk.com', N'https://erwindekreuk.com', NULL, NULL),
(46, 3, N'Data Platform MVP | Technology Lead Data  |Public Speaker | InSpark', N'Erwin de Kreuk is a passionate and highly experienced Technology Leader in the Data & AI domain. He currently serves as a Principal Consultant and Lead Data and AI at InSpark, winner of the Global Partner of the Year (POTY) Award for Identity and the Dutch Partner of the Year (POTY) Award for Data & AI.

Erwin is a frequent speaker at various national and international data community events and has been recognized as a Data Platform MVP.

With 16 years of experience in the world of data on the Microsoft Platform, Erwin has spent the last 8 years focusing on the Azure Platform. His day-to-day work involves addressing complex customer cases and technical issues. Additionally, he is a member of the Technology Board at InSpark, where he leads a team of highly experienced Data Experts specializing in the Microsoft Data Platform.

Erwin is dedicated to helping customers maximize the value of their complex analytics environments, with a strong emphasis on solutions in the Azure Cloud (Platform as a Service) and Microsoft Fabric. As a Technology Board member, he continuously explores the latest opportunities and shares his enthusiasm with colleagues, the community, and customers. He is also a key stakeholder for the InSpark Solution (Managed) Oxygen, a Modern Data Platform Estate as-a-service and the Nitrogen Control Center a native solution build on top of Microsoft Fabric for easy data integration and data Processing.', N'https://www.linkedin.com/in/erwindekreuk/', N'https://twitter.com/ErwindeKreuk', N'https://erwindekreuk.com', N'https://erwindekreuk.com', NULL, NULL),
(47, 2, N'Redgate Software', N'Grant Fritchey is a Data Platform MVP and AWS Community Builder with over 30 years’ experience in IT, including time spent in support and development. Grant works with multiple data platforms including SQL Server and PostgreSQL as well as multiple cloud platforms. He has also developed in VB, VB.NET, C#, and Java. Grant writes books for Apress and Simple-Talk. Grant presents at conferences and user groups, large and small, all over the world. He joined Redgate Software as a product advocate in January 2011.', N'https://www.linkedin.com/in/grant-fritchey/', N'http://twitter.com/gfritchey', N'https://red-gate.com', N'https://scarydba.com', N'https://www.facebook.com/GFritchey', N'https://www.instagram.com/gfritchey/'),
(47, 3, N'Redgate Software Product Advocate, Microsoft MVP & AWS Community Builder', N'Grant Fritchey is a Data Platform MVP and AWS Community Builder with over 30 years’ experience in IT, including time spent in support and development. Grant works with multiple data platforms including SQL Server and PostgreSQL as well as multiple cloud platforms. He has also developed in VB, VB.NET, C#, and Java. Grant writes books for Apress and Simple-Talk. Grant presents at conferences and user groups, large and small, all over the world. He joined Redgate Software as a product advocate in January 2011.', N'https://www.linkedin.com/in/grant-fritchey/', N'http://twitter.com/gfritchey', N'https://red-gate.com', N'https://scarydba.com', N'https://www.facebook.com/GFritchey', N'https://www.instagram.com/gfritchey/'),
(48, 2, N'SQLBI', N'Alberto started working with SQL Server in 2000 and immediately his interest focused on Business Intelligence. He and Marco Russo created sqlbi.com, where they publish extensive content about Business Intelligence.
Alberto published several books about Analysis Services, Power BI, and Power Pivot. He is a Microsoft MVP and he earned the SSAS Maestro title, the highest level of certification on Microsoft Analysis Services technology.
Today, Alberto''s main activities are in the delivery of DAX and data modeling workshops for Power BI and Analysis Services all around the world. Alberto offers consulting services on large and complex data warehouses to provide assessments and validation of project analysis or to perform specific problem-solving activities.
Alberto is a well-known speaker at many international conferences, like PASS Summit, Sqlbits, and Microsoft Ignite. He loves to be on stage both at large events and at smaller user groups meetings, exchanging ideas with other SQL and BI fans. When traveling for work, he likes to engage with local user groups to provide evening sessions about his favorite topics. Thus, you can easily meet Alberto by looking up local Power BI user groups during scheduled courses.
Outside of SQLBI, most of Alberto''s personal time is spent practicing video games, in the vain hope of eventually beating his son.', N'https://www.linkedin.com/in/albertoferrarisqlbi/', N'https://twitter.com/ferrarialberto', N'https://www.sqlbi.com', N'https://www.sqlbi.com', NULL, NULL),
(49, 1, N'Senior Software/System Architect @ DXC Technology', N'A Data Architect at DXC Technology fascinated with IT and programming since early school years. I chose data analysis as a specialization path and from that angle I’m used to work with the Microsoft database engines. Currently mostly in Azure.
I’ve gained experience with the engine on data warehouses and building data flows oriented at a specific business needs.', N'https://www.linkedin.com/in/tomasz-go%C5%82aszewski/', NULL, NULL, NULL, NULL, NULL),
(49, 2, N'Senior Software/System Architect @ DXC Technology', N'A Data Architect at DXC Technology fascinated with IT and programming since early school years. I chose data analysis as a specialization path and from that angle I’m used to work with the Microsoft database engines. Currently mostly in Azure.
I’ve gained experience with the engine on data warehouses and building data flows oriented at a specific business needs.', N'https://www.linkedin.com/in/tomasz-go%C5%82aszewski/', NULL, NULL, NULL, NULL, NULL),
(49, 5, N'Senior Software/System Architect @ DXC Technology', N'A Data Architect at DXC Technology fascinated with IT and programming since early school years. I chose data analysis as a specialization path and from that angle I’m used to work with the Microsoft database engines. Currently mostly in Azure.
I’ve gained experience with the engine on data warehouses and building data flows oriented at a specific business needs.', NULL, NULL, NULL, NULL, NULL, NULL),
(50, 1, N'Program Manager Fabric CAT', N'Lars is Program Manager on Fabric Customer Advisory Team at Microsoft. His passion is helping organizations getting insights out of data. He joined Microsoft in 2014 and has been working with BI solutions since 1999.', N'https://www.linkedin.com/in/mslars/', N'https://twitter.com/LarsADK', NULL, NULL, NULL, NULL),
(50, 2, N'Program Manager Fabric CAT at Microsoft', N'Lars is Program Manager on Fabric Customer Advisory Team at Microsoft. His passion is helping organizations getting insights out of data. He joined Microsoft in 2014 and has been working with BI solutions since 1999.', N'https://www.linkedin.com/in/mslars/', N'https://twitter.com/LarsADK', NULL, NULL, NULL, NULL),
(50, 3, N'Program Manager Fabric CAT at Microsoft', N'Lars is Program Manager on Fabric Customer Advisory Team at Microsoft. His passion is helping organizations getting insights out of data. He joined Microsoft in 2014 and has been working with BI solutions since 1999.', N'https://www.linkedin.com/in/mslars/', N'https://twitter.com/LarsADK', NULL, NULL, NULL, NULL),
(51, 2, N'Data Engineer at Quorum', N'I’m a Data Engineer and data analytics enthusiast specialising in the Azure data platform, Microsoft Fabric, Power BI, and SQL Server. With multiple Azure certifications, I’m passionate about developing and sharing my knowledge and eagerly take any opportunity to present and speak on topics I’ve explored and mastered.

Outside of data, I’m an avid fan of football and Formula 1, and I enjoy cooking, whisky, and making plans to travel the world.', N'https://www.linkedin.com/in/abhinav-j/', N'https://x.com/data_abhinavj', N'https://www.quorum.co.uk', NULL, NULL, NULL),
(52, 2, N'Managing Director; Microsoft Certified Master: SQL Server', N'is the Managing Director of 15C, a consulting and training company that specializes in designing, implementing and supporting SQL Server infrastructures. He is a 12-year former Microsoft Data Platform MVP and Microsoft Certified Master from Ottawa, Canada (but he’s originally from the Philippines) specializing in high availability, disaster recovery and system infrastructures running on the Microsoft server technology stack. His background in Unix has taken him to the world of DevOps and Docker to containerize SQL Server. He is very passionate about technology but has interests in music, neuroscience, social psychology, professional and organizational development, leadership and management matters when not working with databases.

Edwin lives up to his primary mission statement: "To help people and organizations grow and develop their full potential."', N'https://www.linkedin.com/in/edwinmsarmiento/', N'https://twitter.com/EdwinMSarmiento', N'https://learnsqlserverhadr.com', N'https://LearnSQLServerHADR.com/blog', NULL, N'https://www.instagram.com/learnsqlserverhadr'),
(52, 5, N'Managing Director; Microsoft Certified Master: SQL Server', N'is the Managing Director of 15C, a consulting and training company that specializes in designing, implementing and supporting SQL Server infrastructures. He is a 12-year former Microsoft Data Platform MVP and Microsoft Certified Master from Ottawa, Canada (but he’s originally from the Philippines) specializing in high availability, disaster recovery and system infrastructures running on the Microsoft server technology stack. His background in Unix has taken him to the world of DevOps and Docker to containerize SQL Server. He is very passionate about technology but has interests in music, neuroscience, social psychology, professional and organizational development, leadership and management matters when not working with databases.

Edwin lives up to his primary mission statement: "To help people and organizations grow and develop their full potential."', NULL, NULL, NULL, NULL, NULL, NULL),
(53, 1, N'Data platform architect & engineer', N'A data enthusiast and a ‘Data Craftsman.’ Engaged in the architecture (including infrastructure) of Data Platform solutions, mainly in the Azure cloud. Associated with the Data field since 2012, or perhaps earlier, as he graduated Computer Science and Econometrics studies at the University of Economics in Krakow. He started his journey from Excel, through on-premises databases, to cloud solutions, including Snowflake and Databricks. Currently, he primarily works in the Azure Databricks area, designing subsequent Lakehouses and exploring the nuances of spark during breaks between creating diagrams in Visio. Privately, a husband and father, a volleyball fan (both active and passive).', N'https://www.linkedin.com/in/wojciech-bukowski-1b829566/', N'https://twitter.com/wojjy_theOne', N'https://pl.seequality.net/', N'https://pl.seequality.net/', NULL, NULL),
(53, 2, N'Data platform architect & engineer', N'A data enthusiast and a ‘Data Craftsman.’ Engaged in the architecture (including infrastructure) of Data Platform solutions, mainly in the Azure cloud. Associated with the Data field since 2012, or perhaps earlier, as he graduated Computer Science and Econometrics studies at the University of Economics in Krakow. He started his journey from Excel, through on-premises databases, to cloud solutions, including Snowflake and Databricks. Currently, he primarily works in the Azure Databricks area, designing subsequent Lakehouses and exploring the nuances of spark during breaks between creating diagrams in Visio. Privately, a husband and father, a volleyball fan (both active and passive).', N'https://www.linkedin.com/in/wojciech-bukowski-1b829566/', N'https://twitter.com/wojjy_theOne', N'https://pl.seequality.net/', N'https://pl.seequality.net/', NULL, NULL),
(53, 3, N'SEEQUALITY. Data platform architect & engineer', N'Data advisor and co-owner at SEEQUALITY. A data enthusiast and a ‘Data Craftsman.’ Engaged in the architecture (including infrastructure) of Data Platform solutions, mainly in the Azure cloud. Associated with the Data field since 2012, or perhaps earlier, as he graduated Computer Science and Econometrics studies at the University of Economics in Krakow. He started his journey from Excel, through on-premises databases, to cloud solutions, including Snowflake and Databricks. Currently, he primarily works in the Azure Databricks area, designing subsequent Lakehouses and exploring the nuances of spark during breaks between creating diagrams in Visio. Privately, a husband and father, a volleyball fan (both active and passive).', N'https://www.linkedin.com/in/wojciech-bukowski-1b829566/', N'https://twitter.com/wojjy_theOne', N'https://pl.seequality.net/', N'https://pl.seequality.net/', NULL, NULL),
(53, 5, N'SEEQUALITY. Data platform architect & engineer', N'Data advisor and co-owner at SEEQUALITY. A data enthusiast and a ‘Data Craftsman.’ Engaged in the architecture (including infrastructure) of Data Platform solutions, mainly in the Azure cloud. Associated with the Data field since 2012, or perhaps earlier, as he graduated Computer Science and Econometrics studies at the University of Economics in Krakow. He started his journey from Excel, through on-premises databases, to cloud solutions, including Snowflake and Databricks. Currently, he primarily works in the Azure Databricks area, designing subsequent Lakehouses and exploring the nuances of spark during breaks between creating diagrams in Visio. Privately, a husband and father, a volleyball fan (both active and passive).', NULL, NULL, NULL, NULL, NULL, NULL),
(54, 1, N'Epam Systems', N'Catalin Gheorghiu is a solution architect from Timisoara Romania. The current interests are in the area of (I)IoT, industrial mobile and cloud solutions. In addition to addressing the software development and architecture, is a trainer and consultant. In his spare time is member of the technical community, contributing with articles and blogs (signed MrSmersh), presentations to several user groups/meetups (also is RONUA Timisoara user group leader), and lecturing all over Romania and abroad.
Since 2011, every year he was awarded the Microsoft MVP Award. Is also a current holder of the Intel Software Innovator Award. Is a current Microsoft Certified Trainer.', N'https://www.linkedin.com/in/catalingheorghiu/', N'https://twitter.com/MrSmersh', N'https://www.epam.com', NULL, NULL, NULL),
(55, 6, N'CEO at digna', N'Marcin Chudeusz is the Co-Founder and CEO of digna, where his role emphasizes his expertise in data management and consultancy. Before co-founding Digna, Marcin garnered significant experience as a Data Warehouse Consultant. This background equipped him with deep insights into data architecture, integration, and management strategies, essential in today''s data-driven business environments.', NULL, NULL, NULL, NULL, NULL, NULL),
(56, 2, N'b.telligent Deutschland GmbH', N'Matthias Nohl is a consultant focusing on cloud platform & data analytics in the Azure cloud environment, data warehouse architecture and performance optimization and advises customers from various industries on data analytics topics.', N'https://www.linkedin.com/in/matthiasnohl', N'https://twitter.com/mnohlimits', N'https://www.btelligent.com', NULL, NULL, NULL),
(57, 1, N'Power BI MVP | Managing partner & Lead technical consultant', N'I am a data lover, especially in the ecosystem of Microsoft tools. I primarily focus on Power BI, Azure Synapse, and Azure SQL. In general, I follow a very simple motto.

"Don´t say it cannot be done, or someone who doesn´t know it will come and do it."

I am a co-founder and a Lead Technical Consultant at DataBrothers. We are Power BI experts and consultants with a focus on data analysis, reporting, and training in Power BI. We work with our clients across the globe on developing custom solutions and training their users on all levels (from business to development).', N'https://www.linkedin.com/in/%C5%A1t%C4%9Bp%C3%A1n-re%C5%A1l-464084152/', N'https://twitter.com/tpnRel1', N'https://www.databrothers.cz/en/make-your-data-shine/', N'https://datameerkat.com/', NULL, NULL),
(57, 3, N'Data Platform MVP | Managing partner & Lead technical consultant at DataBrothers', N'I am a data lover, especially in the ecosystem of Microsoft tools. I primarily focus on Power BI, Azure Synapse, and Azure SQL. In general, I follow a very simple motto.

"Don´t say it cannot be done, or someone who doesn´t know it will come and do it."

I am a co-founder and a Lead Technical Consultant at DataBrothers. We are Power BI experts and consultants with a focus on data analysis, reporting, and training in Power BI. We work with our clients across the globe on developing custom solutions and training their users on all levels (from business to development).', N'https://www.linkedin.com/in/%C5%A1t%C4%9Bp%C3%A1n-re%C5%A1l-464084152/', N'https://twitter.com/tpnRel1', N'https://www.databrothers.cz/en/make-your-data-shine/', N'https://datameerkat.com/', NULL, NULL),
(58, 6, N'Clouds on Mars, AI & Machine Learning Center of Excellence Lead', N'With over 10 years of experience in AI, machine learning, and data science, he helps organizations transform data into measurable business value. Leveraging deep expertise in Microsoft Azure and modern AI platforms, he designs scalable, production-ready solutions and leads teams in delivering impactful, client-focused outcomes across international markets.', NULL, NULL, NULL, NULL, NULL, NULL),
(59, 2, N'Independent Business Intelligence Consultant', N'I am an Azure Data Platform professional working predominantly with Azure Synapse Analytics (SQL Pools), Data Factory, SQL Server and Power BI.  I hold an MSc in Business Intelligence and Data Mining.  I am a current Microsoft Data Platform MVP.', N'https://www.linkedin.com/in/andycutler/', NULL, N'https://www.datahaibi.com', N'https://www.serverlesssql.com', NULL, NULL),
(60, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(61, 1, N'db Berater GmbH - Managing Director', N'Uwe Ricken is working with IT systems since the 90’s. The start of experiences with Microsoft SQL Server came with the assignment for development of membership administration software for the American Chamber of Commerce in Germany. The software has been distributed to five additional European countries. The primary passion for developments with Microsoft SQL Server expanded in 2007 with his engagement as a DBA for Deutsche Bank AG in Frankfurt am Main. After 6 years of operational experiences as a DBA and over 14 years as a developer of complex database models he achieved the “Microsoft Certified Master – SQL Server 2008” certification which “was” the highest technical certification. The year 2013 finished with the first MVP award for his support to the Microsoft SQL Server community in Germany and Europe.
To provide his deep knowledge about Microsoft SQL Server to the interested community Uwe Ricken is blogging since 2010 at http://www.sqlmaster.de about his daily experiences with Microsoft SQL Server. His blog posts are in German language only to provide the German speaking SQL community inside views into the technology of Microsoft SQL Server.
Uwe Ricken is a speaker on many international conferences and events and preferred topics are “Database Internals”, “Indexing” and “Development”.', N'https://www.linkedin.com/in/uwericken/', NULL, N'https://db-berater.de', N'https://sqlmaster.de', NULL, NULL),
(61, 2, N'db Berater GmbH - Managing Director', N'Uwe Ricken is working with IT systems since the 90’s. The start of experiences with Microsoft SQL Server came with the assignment for development of membership administration software for the American Chamber of Commerce in Germany. The software has been distributed to five additional European countries. The primary passion for developments with Microsoft SQL Server expanded in 2007 with his engagement as a DBA for Deutsche Bank AG in Frankfurt am Main. After 6 years of operational experiences as a DBA and over 14 years as a developer of complex database models he achieved the “Microsoft Certified Master – SQL Server 2008” certification which “was” the highest technical certification. The year 2013 finished with the first MVP award for his support to the Microsoft SQL Server community in Germany and Europe.
To provide his deep knowledge about Microsoft SQL Server to the interested community Uwe Ricken is blogging since 2010 at http://www.sqlmaster.de about his daily experiences with Microsoft SQL Server. His blog posts are in German language only to provide the German speaking SQL community inside views into the technology of Microsoft SQL Server.
Uwe Ricken is a speaker on many international conferences and events and preferred topics are “Database Internals”, “Indexing” and “Development”.', N'https://www.linkedin.com/in/uwericken/', NULL, N'https://db-berater.de', N'https://sqlmaster.de', NULL, NULL),
(61, 3, N'db Berater GmbH - Managing Director', N'Uwe Ricken is working with IT systems since the 90’s. The start of experiences with Microsoft SQL Server came with the assignment for development of membership administration software for the American Chamber of Commerce in Germany. The software has been distributed to five additional European countries. The primary passion for developments with Microsoft SQL Server expanded in 2007 with his engagement as a DBA for Deutsche Bank AG in Frankfurt am Main. After 6 years of operational experiences as a DBA and over 14 years as a developer of complex database models he achieved the “Microsoft Certified Master – SQL Server 2008” certification which “was” the highest technical certification. The year 2013 finished with the first MVP award for his support to the Microsoft SQL Server community in Germany and Europe.
To provide his deep knowledge about Microsoft SQL Server to the interested community Uwe Ricken is blogging since 2010 at http://www.sqlmaster.de about his daily experiences with Microsoft SQL Server. His blog posts are in German language only to provide the German speaking SQL community inside views into the technology of Microsoft SQL Server.
Uwe Ricken is a speaker on many international conferences and events and preferred topics are “Database Internals”, “Indexing” and “Development”.', N'https://www.linkedin.com/in/uwericken/', NULL, N'https://db-berater.de', N'https://sqlmaster.de', NULL, NULL),
(61, 6, N'db Berater GmbH - Managing Director', N'Uwe Ricken has been working with IT systems since the early 1990s, with a deep focus on Microsoft SQL Server starting from his work on Membership Software for the American Chamber of Commerce in Germany - later rolled out across five European countries. His passion for SQL Server took off in 2007 when he joined Deutsche Bank AG as a database administrator, gaining hands-on experience in high-performance, enterprise-scale environments.

With over three decades of experience in database development and operations, Uwe earned the prestigious "Microsoft Certified Master – SQL Server 2008", the highest technical certification at the time. In 2013, he was honored with his first  "Microsoft MVP Award" for his contributions to the SQL Server community across Germany and Europe.

Since 2010, Uwe has been sharing his expertise through his blog https://sqlmaster.de, offering deep dives into SQL Server internals, performance tuning, and real-world troubleshooting.

A regular speaker at international conferences and user groups, Uwe’s sessions focus on Database Internals, Indexing Strategies and Advanced SQL Development - always with a practical, performance-driven mindset.', NULL, NULL, NULL, NULL, NULL, NULL),
(62, 1, N'TIDK', N'Swoją przygodę z informatyką rozpoczynał 30 lat temu pisząc programy w języku BASIC na domowy komputer Commodore C64. Na stałe związał się jednak ze światem baz danych relacyjnych i wielowymiarowych, przechodząc stopniowo od dBase i Clipper poprzez ulubiony SQL Server aż do big data i NoSQL.

Od lat dziewięćdziesiątych zeszłego stulecia zajmuje się fascynującym światem uczenia maszynowego i sztucznej inteligencji.  Specjalizuje się w projektowaniu i wdrażaniu aplikacji analitycznych i raportowych szczególnie w obszarach planowania, budżetowania, controllingu oraz analiz finansowych. Jako konsultant z pasją pomaga dbać o wydajność serwerów oraz krótki czas wykonywania zapytań.

Dzieli się swoją wiedzą i doświadczeniem na prowadzonych przez siebie szkoleniach i warsztatach. Aktywny prelegent na konferencjach SQL Day i innych spotkaniach branżowych. Można go często spotkać na spotkaniach Data Community Poland. W latach 2009 – 2021 nagradzany przez Microsoft tytułem Most Valuable Professional w obszarze SQL Server i Data Platform.', NULL, NULL, NULL, NULL, NULL, NULL),
(62, 4, N'TIDK', N'Swoją przygodę z informatyką rozpoczynał 30 lat temu pisząc programy w języku BASIC na domowy komputer Commodore C64. Na stałe związał się jednak ze światem baz danych relacyjnych i wielowymiarowych, przechodząc stopniowo od dBase i Clipper poprzez ulubiony SQL Server aż do big data i NoSQL.

Od lat dziewięćdziesiątych zeszłego stulecia zajmuje się fascynującym światem uczenia maszynowego i sztucznej inteligencji.  Specjalizuje się w projektowaniu i wdrażaniu aplikacji analitycznych i raportowych szczególnie w obszarach planowania, budżetowania, controllingu oraz analiz finansowych. Jako konsultant z pasją pomaga dbać o wydajność serwerów oraz krótki czas wykonywania zapytań.

Dzieli się swoją wiedzą i doświadczeniem na prowadzonych przez siebie szkoleniach i warsztatach. Aktywny prelegent na konferencjach SQL Day i innych spotkaniach branżowych. Można go często spotkać na spotkaniach Data Community Poland. W latach 2009 – 2021 nagradzany przez Microsoft tytułem Most Valuable Professional w obszarze SQL Server i Data Platform.', NULL, NULL, NULL, NULL, NULL, NULL),
(63, 1, N'Data Platform MVP, Power BI Contributor, Developer of pbi-tools', N'In 2015, after having spent over ten years as a Software Developer and Architect with Microsoft technologies, Mathias Thierbach moved into the Microsoft BI space. He soon landed on Power BI, but also realized quickly that the development and engineering tools and practices were nothing like the ones well established in software development. This is how pbi-tools started as a project, the only complete source control solution for Power BI.

During seven years of leading a data management team at YouGov, he experienced the benefits of those efforts every day. Having open sourced the project in fall of 2021, Mathias spends a lot of his free time bringing source control and DevOps practices to the wider Power BI community now.

In addition to his open source engagements, Mathias cares deeply about his role as an enterprise technology leader. Like many, once having started as a single contributor technologist, he had to pivot significantly when he moved into a manager role, responsible for building, stabilizing and growing a team of data engineers, analysts and architects. Mathias is now passionately sharing the many experiences and learnings that came out of that journey with the community.', N'https://www.linkedin.com/in/mthierba/', NULL, N'https://pbi.tools', N'https://notes.mthierba.net/', NULL, NULL),
(64, 1, N'Nordcloud, Data Solution Architect', N'Hey there! I''m a Cloud & Data Architect with a passion for simplifying complex challenges. Armed with an MBA, I bring a fresh perspective to the table. My jam includes AWS, Azure, Big Data, and machine learning.

Right now, I''m at Nordcloud, leading the charge in data platform engineering. I''ve built high-speed solutions for major banks, rocked the hybrid cloud scene for telecom giants, and more.

With a toolbox of tech skills, I''m all about the future of data and tech. Let''s chat about data platform engineering, the next big thing! 😎💻🚀', N'https://www.linkedin.com/in/maciekdydejczyk', NULL, N'https://nordcloud.com', NULL, NULL, NULL);

INSERT INTO dbo.SpeakerEditionProfile (SpeakerId, EventEditionId, TagLine, Bio, LinkedInUrl, XUrl, CompanyWebsiteUrl, BlogUrl, FacebookUrl, InstagramUrl) VALUES
(65, 1, N'Cogit, BI Practice Lead', N'Hubert works at Cogit as BI Practice Lead (since 2007). He helps customers to gather their data and convert it into valuable information using Microsoft Data Platform technologies. Hubert manages two UG''s: Data Community Poland (Warsaw Chapter) and Warsaw Power BI User Group. In his spare time, he teaches DataViz on two universities', N'https://pl.linkedin.com/in/kobierzewski', N'http://www.twitter.com/DataHubert', N'http://codec.pl/', N'https://datingwithdata.net', NULL, NULL),
(65, 2, N'Cogit, BI Practice Lead', N'Hubert works at Cogit as BI Practice Lead (since 2007). He helps customers to gather their data and convert it into valuable information using Microsoft Data Platform technologies. Hubert manages two UG''s: Data Community Poland (Warsaw Chapter) and Warsaw Power BI User Group. In his spare time, he teaches DataViz on two universities', N'https://pl.linkedin.com/in/kobierzewski', N'http://www.twitter.com/DataHubert', N'http://codec.pl/', N'https://datingwithdata.net', NULL, NULL),
(65, 3, N'Cogit, BI Practice Lead', N'Hubert works at Cogit as BI Practice Lead (since 2007). He helps customers to gather their data and convert it into valuable information using Microsoft Data Platform technologies. Hubert manages two UG''s: Data Community Poland (Warsaw Chapter) and Warsaw Power BI User Group. In his spare time, he teaches DataViz on two universities', N'https://pl.linkedin.com/in/kobierzewski', N'http://www.twitter.com/DataHubert', N'http://codec.pl/', N'https://datingwithdata.net', NULL, NULL),
(65, 4, N'Cogit, BI Practice Lead', N'Od roku 2007 Hubert pracuje w firmie Cogit jako BI Practice Lead. Na co dzień pomaga klientom gromadzić dane i przekształcać je w wartościowe informacje używając technologi spod znaku Platformy Danych Microsoft. Poza pracą Hubert udziela się w zarządzie Data Community Poland a w czasie wolnym prowadzi zajęcia z wizualizacji danych na dwóch uczelniach.', NULL, NULL, NULL, NULL, NULL, NULL),
(65, 5, N'Cogit, BI Practice Lead', N'Hubert works at Cogit as BI Practice Lead (since 2007). He helps customers to gather their data and convert it into valuable information using Microsoft Data Platform technologies. Hubert manages two UG''s: Data Community Poland (Warsaw Chapter) and Warsaw Power BI User Group. In his spare time, he teaches DataViz on two universities', NULL, NULL, NULL, NULL, NULL, NULL),
(65, 6, N'Cogit, BI Practice Lead', N'Hubert works at Cogit as BI Practice Lead (since 2007). He helps customers to gather their data and convert it into valuable information using Microsoft Data Platform technologies. Hubert manages two UG''s: Data Community Poland (Warsaw Chapter) and Warsaw Power BI User Group. In his spare time, he teaches DataViz on two universities', NULL, NULL, NULL, NULL, NULL, NULL),
(66, 1, N'No coffee? No insights!', N'Benni is a Senior Program Manager in the Fabric Customer Advisory Team (Fabric CAT) at Microsoft. Aspiring to be top notch in his field, through continuous personal development, on both technical and soft skills. He strives for maximum results in his tasks using team play, communication, thinking outside of the box, and (endless) motivation. Benni is always ready to tackle the unknown, or pick up fresh ideas to broaden his range. Building on past experiences, he continuously tries to find new, more efficient ways of obtaining results, and improving the process along the way.

Loving (almost) every day of it, he’s fascinated by the value of data, sometimes flabbergasted by the lack of awareness, and intrigued by the endless possibilities whilst discovering new ways of looking at data. He thrives on unfolding new insights for customers whilst using an open and transparent communication.

On a daily basis he turns (large amounts of) coffee into insights for customers, and references witty British comedy, lame dad jokes, and obscure facts way too often. Overly enthusiastic about anything data related, he’s trying hard to keep up with all things new and shiny.

When not working, blogging or reading, you’ll likely find him out and about being his weird self. Rumour has it that he’s also involved with a ragtag band of data enthusiasts, enjoying themselves whilst organising cool community things.
They go by the name of .. dataMinds!', N'https://www.linkedin.com/in/bennidejagere/', N'https://twitter.com/BenniDeJagere', N'https://learn.microsoft.com/en-us/fabric/get-started/microsoft-fabric-overview', N'https://bennidejagere.com/', NULL, NULL),
(66, 2, N'No coffee? No insights!', N'Benni is a Senior Program Manager in the Fabric Customer Advisory Team (Fabric CAT) at Microsoft. Aspiring to be top notch in his field, through continuous personal development, on both technical and soft skills. He strives for maximum results in his tasks using team play, communication, thinking outside of the box, and (endless) motivation. Benni is always ready to tackle the unknown, or pick up fresh ideas to broaden his range. Building on past experiences, he continuously tries to find new, more efficient ways of obtaining results, and improving the process along the way.

Loving (almost) every day of it, he’s fascinated by the value of data, sometimes flabbergasted by the lack of awareness, and intrigued by the endless possibilities whilst discovering new ways of looking at data. He thrives on unfolding new insights for customers whilst using an open and transparent communication.

On a daily basis he turns (large amounts of) coffee into insights for customers, and references witty British comedy, lame dad jokes, and obscure facts way too often. Overly enthusiastic about anything data related, he’s trying hard to keep up with all things new and shiny.

When not working, blogging or reading, you’ll likely find him out and about being his weird self. Rumour has it that he’s also involved with a ragtag band of data enthusiasts, enjoying themselves whilst organising cool community things.
They go by the name of .. dataMinds!', N'https://www.linkedin.com/in/bennidejagere/', N'https://twitter.com/BenniDeJagere', N'https://learn.microsoft.com/en-us/fabric/get-started/microsoft-fabric-overview', N'https://bennidejagere.com/', NULL, NULL),
(66, 3, N'No coffee? No insights!', N'Benni is a Principal Program Manager in the Fabric Customer Advisory Team (Fabric CAT) at Microsoft. Aspiring to be top notch in his field, through continuous personal development, on both technical and soft skills. He strives for maximum results in his tasks using team play, communication, thinking outside of the box, and (endless) motivation. Benni is always ready to tackle the unknown, or pick up fresh ideas to broaden his range. Building on past experiences, he continuously tries to find new, more efficient ways of obtaining results, and improving the process along the way.

Loving (almost) every day of it, he’s fascinated by the value of data, sometimes flabbergasted by the lack of awareness, and intrigued by the endless possibilities whilst discovering new ways of looking at data. He thrives on unfolding new insights for customers whilst using an open and transparent communication.

On a daily basis he turns (large amounts of) coffee into insights for customers, and references witty British comedy, lame dad jokes, and obscure facts way too often. Overly enthusiastic about anything data related, he’s trying hard to keep up with all things new and shiny.

When not working, blogging or reading, you’ll likely find him out and about being his weird self. Rumour has it that he’s also involved with a ragtag band of data enthusiasts, enjoying themselves whilst organising cool community things.
They go by the name of .. dataMinds!', N'https://www.linkedin.com/in/bennidejagere/', N'https://twitter.com/BenniDeJagere', N'https://learn.microsoft.com/en-us/fabric/get-started/microsoft-fabric-overview', N'https://bennidejagere.com/', NULL, NULL),
(67, 6, N'Data designer @ Solita', N'Antti Loukiala is a data architect at Solita. He''s spent the last several years deep in data mesh and data products. Antti has focused on designing them, building them, writing a research paper on the topic, and occasionally learning the hard way what doesn''t work.', NULL, NULL, NULL, NULL, NULL, NULL),
(68, 2, N'Senior Engineering Architect at Microsoft', N'Dominik is a Senior Engineering Architect working on complex migration to Azure SQL as well as solving some of the post migration challenges.
In his previous role he worked as a consultant with enterprise customers helping them to modernize and optimize their SQL landscape.  He is very passionate about SQL Server in general and mostly focuses on business continuity, performance tuning and optimization', N'https://www.linkedin.com/in/dominik-bender-772a428/', NULL, N'https://www.microsoft.com', NULL, NULL, NULL),
(69, 4, N'Grasta - właściciel, trener, wykładowca akademicki', N'Właściciel firmy informatycznej - Grasta i oraz firmy cyfryzującej procesy w firmach - DigiData, doświadczony trener programowania, optymalizacji i administrowania baz danych oraz procesów ETL, wykładowca akademicki na Collegium da Vinci w Poznaniu i na Wyższej Szkole Bankowej w Katowicach', NULL, NULL, NULL, NULL, NULL, NULL),
(70, 1, N'Sr Program Manager at Microsoft', N'Member of the Microsoft Fabric Customer Advisory Team (CAT). In his professional career Pawel has always been associated with data engineering and analytics (SQL, BI, Big Data). Founder of the Polish SQL Server Users Group (PLSSUG), today known as Data Community Poland. Regular speaker at conferences, community events and user groups. Former Microsoft Most Valuable Professional (MVP).', N'https://www.linkedin.com/in/pawelpotasinski/', N'https://twitter.com/PawelPotasinski', N'https://www.infinite-services.com', NULL, NULL, NULL),
(70, 2, N'CTO at InfiniteDATA Services', N'CTO at InfiniteDATA Services, a company specializing in developing state-of-the-art data platforms for large enterprises. In his professional career Pawel has always been associated with data engineering and analytics (SQL, BI, Big Data). Founder of the Polish SQL Server Users Group (PLSSUG), today known as Data Community Poland. Regular speaker at conferences, community events and user groups. Former Microsoft Most Valuable Professional (MVP).', N'https://www.linkedin.com/in/pawelpotasinski/', N'https://twitter.com/PawelPotasinski', N'https://www.infinite-services.com', NULL, NULL, NULL),
(70, 3, N'CTO at Infinite Services', N'CTO at Infinite Services, a company specializing in developing state-of-the-art data platforms for large enterprises. In his professional career Pawel has always been associated with data engineering and analytics (SQL, BI, Big Data). Founder of the Polish SQL Server Users Group (PLSSUG), today known as Data Community Poland. Regular speaker at conferences, community events and user groups. Former Microsoft Most Valuable Professional (MVP).', N'https://www.linkedin.com/in/pawelpotasinski/', N'https://twitter.com/PawelPotasinski', N'https://www.infinite-services.com', NULL, NULL, NULL),
(70, 4, N'CTO at InfiniteDATA Services', N'CTO at InfiniteDATA Services, a company specializing in developing state-of-the-art data platforms for large enterprises. In his professional career Pawel has always been associated with data engineering and analytics (SQL, BI, Big Data). Founder of the Polish SQL Server Users Group (PLSSUG), today known as Data Community Poland. Regular speaker at conferences, community events and user groups. Former Microsoft Most Valuable Professional (MVP).', NULL, NULL, NULL, NULL, NULL, NULL),
(71, 3, N'Senior Solution Architect at EPAM Systems, Soft Project, Owner', N'Mihail Mateev is an owner,  Solution Architect, Senior Technical Evangelist at SoftProject, responsible for .Net, IoT and cloud solutions. Mihail currently works as a Senior Solution Architect at EPAM Systems. He also worked many years  like a Technical evangelist in the Infragistics. Last years Mihail was focused on various areas related to technology Microsoft:  Visual Studio , ASP.Net, Windows client apps, MS SQL Server and Microsoft Azure.', N'https://www.linkedin.com/in/mmateev/', N'https://twitter.com/mihailmateev', N'https://www.softproject.technology', N'https://mmateev.wordpress.com/', N'https://www.facebook.com/mihail.mateev/', N'https://www.instagram.com/mmateev/'),
(71, 4, N'Senior Solution Architect at EPAM Systems, Soft Project, Owner', N'Mihail Mateev is an owner,  Solution Architect, Senior Technical Evangelist at SoftProject, responsible for .Net, IoT and cloud solutions. Mihail currently works as a Senior Solution Architect at EPAM Systems. He also worked many years  like a Technical evangelist in the Infragistics. Last years Mihail was focused on various areas related to technology Microsoft:  Visual Studio , ASP.Net, Windows client apps, MS SQL Server and Microsoft Azure.', NULL, NULL, NULL, NULL, NULL, NULL),
(72, 1, N'Azure Data Solutions Architect @ Nordcloud | Technical leader | Educator | Speaker', N'Hi! I''m a cloud architect specializing in Microsoft Azure, with over 14 years of experience in delivering professional IT solutions. Over this time, I''ve worked with major FMCG companies, telcos and airlines, building cloud-based business applications, data warehouses, BI systems and cloud data platforms. And in today''s fast-paced IT world, there''s more exciting stuff just around the corner!', NULL, NULL, NULL, NULL, NULL, NULL),
(73, 2, N'SQL Server Master at Woodler', N'Maciej Pilecki is a seasoned SQL Server expert with over 20 years of hands-on experience in database architecture, administration, and performance tuning. As Microsoft Certified Master in SQL Server and former Data Platform MVP, Maciej has led complex data projects across various industries, specializing in T-SQL programming, high availability, database optimization and scalability. Maciej is a frequent conference speaker and has contributed extensively to the SQL Server community through training, publications, and user groups.', N'https://www.linkedin.com/in/maciejpilecki', NULL, N'https://www.woodler.eu/', NULL, NULL, NULL),
(74, 2, N'Senior Software Engineer at Sii Poland', N'Senior Software Engineer with aspirations to become an Architect. Experienced developer in Java, Python, and PySpark, working with Azure/AWS clouds and proficient in various Informatica tools. Skilled in ETL, DWH, Business Activity Monitoring, Real-Time Streaming, and API development.

In the meantime, a Data Community member and data processing enthusiast. Since 2021, a member of the SQLDay Council.

In private life, a proud mother of a 3-year-old son, and caretaker of two adopted bunnies.', N'https://www.linkedin.com/in/natwarszewska/', NULL, NULL, NULL, NULL, NULL),
(74, 3, N'Senior Software Engineer at Sii', N'Senior Software Engineer with aspirations to become an Architect. Experienced developer in Java, Python, and PySpark, working with Azure/AWS clouds and proficient in various Informatica tools. Skilled in ETL, DWH, Business Activity Monitoring, Real-Time Streaming, and API development.

In the meantime, a Data Community member and data processing enthusiast. Since 2021, a member of the SQLDay Council.', N'https://www.linkedin.com/in/natwarszewska/', NULL, NULL, NULL, NULL, NULL),
(74, 4, N'Senior Software Engineer at Sii', N'Senior Software Engineer with aspirations to become an Architect. Experienced developer in Java, Python, and PySpark, working with Azure/AWS clouds and proficient in various Informatica tools. Skilled in ETL, DWH, Business Activity Monitoring, Real-Time Streaming, and API development.

In the meantime, a Data Community member and data processing enthusiast. Since 2021, a member of the SQLDay Council.

In private life, a proud mother of a 3-year-old son, and caretaker of two adopted bunnies.', NULL, NULL, NULL, NULL, NULL, NULL),
(75, 4, N'BitPeak, Senior Data Engineer', N'Senior Data Engineer w BitPeak.
Wieloletnie doświadczenie w projektowaniu i implementacji procesów przetwarzania oraz ładowania danych w trybie batchowym.
Systematycznie poszerza wiedzę z zakresu szeroko pojętej platformy danych. Szczególnie interesują ją procesy strumieniowe oraz szeroko pojęta optymalizacja przetwarzania danych.
Doświadczenie z danymi zdobyła realizując projekty dla branży finansowej, transportowej, produkcyjnej oraz motoryzacyjnej.', NULL, NULL, NULL, NULL, NULL, NULL),
(76, 2, N'Wojciech Nowak, GenAI Tech Lead at Raiffeisen Tech', N'An engineer with 8 years of experience, specialized in building Modern Data Architectures like Data Mesh or Data Fabric and making AI Agents production grade. His choice of an engineering career was inspired by the works of Stanisław Lem, whose books shaped his thinking and led him to explore the field of technology. Currently, he serves as a GenAI Tech Lead at Raiffeisen Tech, where he passionately builds innovative GenAI products. Privately, he is an enthusiast of skiing and water sports :)', N'https://www.linkedin.com/in/wojciech-nowak-6a6497120', NULL, NULL, N'https://medium.com/@4wojciechnowak', NULL, NULL),
(77, 1, N'Co-Founder & CTO of Cloud Formations | Microsoft MVP', N'Paul (AKA @mrpaulandrew) is the Founder & CTO of Cloud Formations, a specialist data consultancy based in the UK. With nearly 20 years’ experience designing and delivering Microsoft data architectures, Paul leads a passionate team of engineers, supporting businesses small and large with scalable cloud platforms. Business value delivered through data insights. Over the years, Paul has covered the breadth and depth of design patterns and industry leading concepts, including Lambda, Kappa, Delta Lake, Data Mesh and Data Fabric.

Paul is also a Microsoft Data Platform MVP, director for the Data Relay community conference, East Midlands user group leader, book author and mentor. In addition to the day job(s), Paul is a father of three, husband, foodie, runner, blood donor, geek, Lego, and Star Wars fan! Lastly, Paul confesses to enjoying a Ramstein playlist when given half a chance to do some coding for a customer project.', N'https://www.linkedin.com/in/mrpaulandrew/', N'https://twitter.com/mrpaulandrew', N'https://www.cloudformations.org', N'https://mrpaulandrew.com', NULL, NULL),
(77, 3, N'Co-Founder & CTO of Cloud Formations | Microsoft MVP', N'Paul (AKA @mrpaulandrew) is the Co-Founder & CTO of Cloud Formations, a specialist data consultancy based in the UK. With nearly 20 years’ experience designing and delivering Microsoft data architectures, Paul leads a passionate team of engineers, supporting businesses small and large with scalable cloud platforms. Business value delivered through data insights. Over the years, Paul has covered the breadth and depth of design patterns and industry leading concepts, including Lambda, Kappa, Delta Lake, Data Mesh and Data Fabric.

Paul is also a Microsoft Data Platform MVP, director for the Data Relay community conference, East Midlands user group leader, book author and mentor. In addition to the day job(s), Paul is a father of three, husband, foodie, runner, blood donor, geek, Lego, and Star Wars fan! Lastly, Paul confesses to enjoying a Ramstein playlist when given half a chance to do some coding for a customer project.', N'https://www.linkedin.com/in/mrpaulandrew/', N'https://twitter.com/mrpaulandrew', N'https://www.cloudformations.org', N'https://mrpaulandrew.com', NULL, NULL),
(78, 2, N'BI Teamlead @ X²O', N'Olivier Van Steenlandt is a Business Intelligence Professional who spent most of his early career assisting retail companies to get more value of their data using the Microsoft BI Stack (SSIS, SSAS, SSRS, Power BI).

As his first experience in the field (in Business Intelligence), Olivier worked as a Big Data Analyst using tools such as Hadoop and Spark.

In 2015 the focus changed to traditional data warehousing & reporting using SSIS, SSRS & MicroStrategy. A bit later, around June 2019, the opportunity arose to fill the position of BI Teamlead. In this function he was able to set up a hybrid BI Team (team members in Belgium and Belarus).

Early 2020, Olivier joined the dataMinds crew as a core member, assisting to organise several events.

Around April 2021, Olivier started a new position as BI Teamlead in another Retail Company to support business growth. Besides the challenge to help the BI Team grow and deliver projects on time, he started to use SSAS & Power BI.

When Olivier is not working there is a high chance that you find him on a football field, studying (BI Related), playing music (Saxophone / Piano) or cooking.', N'https://www.linkedin.com/in/oliviervansteenlandt/', N'https://twitter.com/Oli_VSteenlandt', NULL, N'https://www.data-cuisine.com', NULL, NULL),
(79, 1, N'..::  Discovering POWER of Your data ::..', N'Niemal dwie dekady doświadczenia w projektowaniu, wdrażaniu i optymalizacji rozwiązań z obszaru Business Intelligence i Data Warehouse. Przez ostatnie lata Bartek współpracuje z klientami i partnerami Microsoft transformując ich rozwiązania z obszaru danych do chmury publicznej. Jeden z głównych ewangelistów technologii takich jak Power BI, Azure Data Explorer czy Azure Synapse Analytics w Polsce i CEE. Ceniony ekspert w zakresie licencjonowania produktów Microsoft oraz Software Asset Management. Autor wielu publikacji oraz prelegent na konferencjach i warsztatach technologicznych. Posiada liczne certyfikacje m.in. Microsoft Certified Trainer, MCSE Business Intelligence & Data Platform. W latach 2013-2015 uhonorowany tytułem MVP w kategorii SQL Server | Data Platform. Propagator i zwolennik pracy zdalnej, który czas po pracy spędza z dala od maila, telefonu i świata technologii.

----

Almost two decades of experience in designing, implementing and optimizing Business Intelligence and Data Warehouse solutions. In recent years, Bartek has been cooperating with Microsoft clients and partners, transforming their solutions from the data area to the public cloud. One of the main evangelists of technologies such as Power BI, Azure Data Explorer or Azure Synapse Analytics in Poland and Central Europe and Middle East.
A valued expert in the field of Microsoft licensing and Software Asset Management. Author of many publications and speaker at conferences and technological workshops. He holds numerous certifications m.in Microsoft Certified Trainer, MCSE Business Intelligence & Data Platform. In the years 2013-2015 he was honored with the title of MVP in the category SQL Server | Data Platform. Propagator and supporter of remote work, who spends his time after work away from e-mail, telephone and the world of technology.', N'https://www.linkedin.com/in/bartlomiejgraczyk/', N'https://twitter.com/bagraczyk', N'https://www.graczyk.info.pl', N'https://www.graczyk.info.pl', NULL, NULL),
(79, 2, N'Chief Technology Architect | Head of Technology & Architecture | Data & Analytics', N'An expert with nearly twenty years of experience specializing in designing efficient, secure and scalable solutions, from data warehouses and data lakes, through stream processing systems, to advanced analytics and machine learning platforms.  As an experienced architect, focuses on creating and implementing comprehensive strategies in the area of data and analytics closely related to the organization''s business goals.

Has successfully built and developed Centers of Excellence in the area of data transformation, introducing data governance & management standards, ensuring the quality and security of solutions, as well overseeing the implementation of data architecture in leading organizations in the world. Actively tracks and evaluates new technologies, collaborates with solution providers and recommends innovative approaches to data and analytics.

Has confirmed experience by numerous industry certifications, including the title of MVP. A co-creator of educational platforms and an active participant in the data community, where as a leader and mentor supports the development of architects, engineers and data analysts, sharing expert knowledge and best practices in the field of modern data architecture.

A promoter and supporter of remote work. Consciously separates professional and private time, spending free time away from technology', N'https://www.linkedin.com/in/bartlomiejgraczyk/', N'https://twitter.com/bagraczyk', N'https://www.graczyk.info.pl', N'https://www.graczyk.info.pl', NULL, NULL),
(79, 3, N'..::  Discovering POWER of Your data ::..', N'An expert with nearly twenty years of experience specializing in designing efficient, secure and scalable solutions, from data warehouses, through stream processing systems, to advanced analytical and machine learning platforms.  As an experienced architect focuses on creating and implementing comprehensive strategies in the area of data and analytics closely related to the organization''s business goals.

Successfully built and developed Centers of Excellence in the area of data transformation, introducing data management standards, ensuring the quality and security of solutions, and overseeing the implementation of data architecture in leading organizations in the world. Actively tracks and evaluates new technologies, collaborating with solution providers and recommending innovative approaches to data and analytics.

Experience confirmed with numerous industry certifications, including the title of MVP. A co-creator of educational platforms and an active participant in the data community, where as a leader and mentor supports the development of architects, engineers and data analysts, sharing expert knowledge and best practices in the field of modern data architecture.

A promoter and supporter of remote work.Consciously separates professional and private time, spending free time away from technology', N'https://www.linkedin.com/in/bartlomiejgraczyk/', N'https://twitter.com/bagraczyk', N'https://www.graczyk.info.pl', N'https://www.graczyk.info.pl', NULL, NULL),
(79, 4, N'..::  Discovering POWER of Your data ::..', N'Almost two decades of experience in designing, implementing and optimizing Business Intelligence and Data Warehouse solutions. In recent years, Bartek has been cooperating with customers and partners, transforming their solutions from the data area to the public cloud. One of the main evangelists of technologies such as Power BI, Azure Data Explorer or Azure Synapse Analytics in Poland and Central Europe and Middle East.
A valued expert in the field of Microsoft licensing and Software Asset Management. Author of many publications and speaker at conferences and technological workshops. He holds numerous certifications m.in Microsoft Certified Trainer, MCSE Business Intelligence & Data Platform. In the years 2013-2015 he was honored with the title of MVP in the category SQL Server | Data Platform. Propagator and supporter of remote work, who spends his time after work away from e-mail, telephone and the world of technology.', NULL, NULL, NULL, NULL, NULL, NULL),
(80, 3, N'Cloud Data Architect at Future Processing', N'Systems architect and data engineer with over 20 years of experience in building end-to-end data platforms. At Future Processing, he focuses on designing robust, scalable data and ML/AI ecosystems - helping organizations move from fragile Proofs of Concept to reliable, production-grade systems.

Independently, he is developing the concept of the Decision Intelligence Runtime (DIR) - a missing architectural layer that bridges probabilistic LLMs with the deterministic nature of business processes. He is the creator of the Responsibility-Oriented Agents and Event-Oriented Agent Mesh patterns.
To validate these ideas, he runs AIvestor, a research project operating on high-frequency financial data - using markets not as an investment product, but as a uniquely adversarial environment to stress-test real-time autonomy, state management and decision integrity.', N'https://www.linkedin.com/in/arturhuk/', NULL, N'https://www.future-processing.com/', N'https://www.oreilly.com/people/artur-huk/', NULL, NULL),
(81, 6, N'Senior Software Engineering Manager at CAE Poland', N'Na co dzień pracuje jako Menedżer międzynarodowego zespołu Operations Research w CAE Flight Services Poland. Razem z zespołem wspiera kilkadziesiąt zespołów programistów, testerów, wdrożeniowców oraz pracowników wsparcia technicznego. Fan optymalizacji zapytań oraz zgłębiania wiedzy o SQL Server Internals. Z bazami danych a w szczególności SQL Serverem zawodowo związany od 2010 roku.', NULL, NULL, NULL, NULL, NULL, NULL),
(82, 1, N'Blogger, Speaker, Microsoft Data Platform MVP. Group Manager & Analytics Architect. MCSE Data Management and Analytics', N'Blogger, speaker, #sqlfamily member. Microsoft Data Platform MVP. Data passionate, Data Engineer and Architect.
Over 20 years of programming and experience with SQL Server databases (since 2000 version) he confirmed by certificates MCITP, MCP, MCTS, MCSA, MCSE Data Platform & Data management & analytics. He worked both as developer and administrator big databases designing systems from the scratch. Recently focused on Data Platform in Azure as a certified (Azure Dev-Ops Engineer Expert, Azure Developer Associate) Data Engineer and Azure Architect.
Passionate about optimization of database systems, an advocate of code transparency, open-source projects and automation, DevOps and PowerShell fan.

Since 2015 he has been living and working in the UK. Currently professionally associated with Avanade, an international consulting company.

Socially, tied with Data Community Poland (former PLSSUG) for many years, He worked a couple of years as a volunteer and now as a co-organizer and speaker of the biggest SQL Server conference in Poland (SQLDay).
Socially, tied with the Data Community Poland Association (former PLSSUG) and the SQLDay conference for many years; currently as a co-organizer of a five-day Data Relay conference in the UK, a volunteer at SQLBits and a presenter at these and many other conferences.

An originator of the "Ask SQL Family" podcast and founder of SQLPlayer blog.
Privately happy husband and father of two wonderful girls.', N'https://www.linkedin.com/in/kamilnowinski/', NULL, N'https://learn.azureplayer.net/', N'https://azureplayer.net/', N'https://www.facebook.com/theazureplayer', N'https://www.instagram.com/kamilnowgeek/'),
(82, 2, N'Blogger, Speaker, Microsoft Data Platform MVP. Group Manager & Analytics Architect. MCSE Data Management and Analytics', N'Blogger, speaker, #sqlfamily member. Microsoft Data Platform MVP. Data passionate, Data Engineer and Architect.
Over 20 years of programming and experience with SQL Server databases (since 2000 version) he confirmed by certificates MCITP, MCP, MCTS, MCSA, MCSE Data Platform & Data management & analytics. He worked both as developer and administrator big databases designing systems from the scratch. Recently focused on Data Platform in Azure as a certified (Azure Dev-Ops Engineer Expert, Azure Developer Associate) Data Engineer and Azure Architect.
Passionate about optimization of database systems, an advocate of code transparency, open-source projects and automation, DevOps and PowerShell fan.

Since 2015 he has been living and working in the UK. Currently professionally associated with Avanade, an international consulting company.

Socially, tied with Data Community Poland (former PLSSUG) for many years, He worked a couple of years as a volunteer and now as a co-organizer and speaker of the biggest SQL Server conference in Poland (SQLDay).
Socially, tied with the Data Community Poland Association (former PLSSUG) and the SQLDay conference for many years; currently as a co-organizer of a five-day Data Relay conference in the UK, a volunteer at SQLBits and a presenter at these and many other conferences.

An originator of the "Ask SQL Family" podcast and founder of SQLPlayer blog.
Privately happy husband and father of two wonderful girls.', N'https://www.linkedin.com/in/kamilnowinski/', NULL, N'https://learn.azureplayer.net/', N'https://azureplayer.net/', N'https://www.facebook.com/theazureplayer', N'https://www.instagram.com/kamilnowgeek/'),
(82, 3, N'Blogger, Speaker, Microsoft Data Platform MVP. Group Manager & Analytics Architect. MCSE Data Management and Analytics', N'Blogger, speaker, #sqlfamily member. Microsoft Data Platform MVP. Data passionate, Data Engineer and Architect.
Over 20 years of programming and experience with SQL Server databases (since 2000 version) he confirmed by certificates MCITP, MCP, MCTS, MCSA, MCSE Data Platform & Data management & analytics. He worked both as developer and administrator big databases designing systems from the scratch. Recently focused on Data Platform in Azure as a certified (Azure Dev-Ops Engineer Expert, Azure Developer Associate) Data Engineer and Azure Architect.
Passionate about optimization of database systems, an advocate of code transparency, open-source projects and automation, DevOps and PowerShell fan.

Since 2015 he has been living and working in the UK. Currently professionally associated with Avanade, an international consulting company.

Socially, tied with Data Community Poland (former PLSSUG) for many years, He worked a couple of years as a volunteer and now as a co-organizer and speaker of the biggest SQL Server conference in Poland (SQLDay).
Socially, tied with the Data Community Poland Association (former PLSSUG) and the SQLDay conference for many years; currently as a co-organizer of a five-day Data Relay conference in the UK, a volunteer at SQLBits and a presenter at these and many other conferences.

An originator of the "Ask SQL Family" podcast and founder of SQLPlayer blog.
Privately happy husband and father of two wonderful girls.', N'https://www.linkedin.com/in/kamilnowinski/', NULL, N'https://learn.azureplayer.net/', N'https://azureplayer.net/', N'https://www.facebook.com/theazureplayer', N'https://www.instagram.com/kamilnowgeek/'),
(82, 6, N'Strategic data architecture for the Microsoft & Databricks stack - deliberately, not accidentally', N'Kamil Nowinski is a Databricks Solutions Architect Champion, former Microsoft Data Platform MVP, and Azure Data Engineer & Architect focused on designing strategic, AI-ready data platforms for the modern enterprise.
With over 25 years of experience in data engineering and SQL Server technologies, Kamil specialises in building scalable Lakehouse and Lake-centric architectures across Microsoft Fabric, Azure, and Databricks. His expertise spans Data Strategy, Data Integration, governance frameworks, and platform maturity models - helping organisations move from fragmented analytics to unified, high-performance data ecosystems.
Kamil''s work centres on architecting robust foundations, including implementing Unity Catalog with classification, designing real-time and event-driven architectures, modernising legacy BI estates, and embedding DevOps practices into data platforms. He believes that successful AI and advanced analytics are not accidental - they are the result of deliberate architectural decisions, strong governance, and disciplined engineering practices.
As a consultant working with enterprises across the UK market, he partners with organisations to troubleshoot complex data challenges, prototype next-generation BI and Big Data solutions, and optimise Microsoft-centric data environments for scale, automation, and long-term sustainability.
He is the founder of AzurePlayer.net blog, creator of the "Ask SQL Family" podcast and actively publishes technical content on his YouTube channel, sharing practical insights on Data Strategy, Microsoft Fabric, Databricks, and modern cloud data engineering with the global #sqlfamily community.
Privately happy husband and father of 2 wonderful girls.', NULL, NULL, NULL, NULL, NULL, NULL),
(83, 2, N'Future Processing, Senior Cloud Data Engineer', N'A Data Engineer with expertise in designing and implementing data processing, migration strategies, and data warehouse solutions. He tackles complex projects that leverage technologies like Python, SQL Server, Snowflake, and Azure cloud.', NULL, NULL, NULL, NULL, NULL, NULL),
(83, 6, N'Future Processing, Senior Cloud Data Engineer', N'A Data Engineer with expertise in designing and implementing data processing, migration strategies, and data warehouse solutions. He tackles complex projects that leverage technologies like Python, SQL Server, Snowflake, and Azure cloud.', NULL, NULL, NULL, NULL, NULL, NULL),
(84, 2, N'Cloud Data Architect', N'Mariusz to doświadczony architekt i inżynier danych, specjalizujący się w tworzeniu platform danych dla projektów związanych z hurtowniami danych, "data lake" oraz uczeniem maszynowym. Miał okazję pracować z platformami chmurowymi, takimi jak Azure, GCP i AWS. Jego ponad 14-letnie doświadczenie obejmuje branżę finansową, ubezpieczeniową, FMCG, farmaceutyczną i telekomunikacyjną. Mariusz pracuje nad innowacyjnymi projektami dla klientów zarówno w Polsce, jak i poza jej granicami. Posiada certyfikacje z zakresu inżynierii danych zarówno od Azure, jak i GCP. Poza swoją wiedzą techniczną, Mariusz jest pasjonatem historii, książek, rysunku, inżynierii danych oraz języka Python. Chętnie dzieli się swoją wiedzą, a jego artykuły można znaleźć na platformie Medium.', N'https://www.linkedin.com/in/mariusz-kujawski-812bb1103/', NULL, NULL, N'https://medium.com/@mariusz_kujawski', NULL, NULL),
(84, 3, N'Cloud Data Architect', N'Mariusz is an experienced Architect and Data Engineer who specializes in creating Data Platforms for projects focused on Data Warehouses, Data Lakes, and Machine Learning. He''s skilled in popular cloud systems like Azure, GCP, and AWS and has over 14 years of experience in the data processing industry in Finance, FMCG, Pharma, and Telecommunication. Mariusz works on innovative projects for clients in Poland and beyond. He''s certified in data engineering from both Azure and GCP. Beyond his technical expertise, Mariusz is a big fan of history, books, drawing, data engineering, and the Python language. He enjoys sharing his knowledge, and you can find his articles on Medium.', N'https://www.linkedin.com/in/mariusz-kujawski-812bb1103/', NULL, NULL, N'https://medium.com/@mariusz_kujawski', NULL, NULL),
(85, 3, N'Lead Data Architect', N'Lead Data Architect w Bayer Consumer Health. Delivery manager i data architect. Od 15 lat specjalizuję się w projektach transformujących różne obszary łańcucha dostaw w branży FMCG (CPG), w szczególności w zarządzaniu zapasami, dostawami materiałów, transportem i optymalizacją sieci łańcucha dostaw i produkcji.', NULL, NULL, NULL, NULL, NULL, NULL),
(86, 1, N'Principal Architect, Data & Analytics', N'Brian has worked with SQL Server for more than two decades - varying projects on both size and complexity. Now he''s working to support the Data & Analytics team at Fellowmind.

Honored with MVP on Data Platform from 2023.

Currently given the honor of being Microsoft Recognized Fasttrack Solution Architect since 2022.

Brian loves data and is always trying to glue the business and tech together using his knowledge and experience.

He is always open to meet new people and help them get better at their job or task.', N'https://linkedin.com/in/brianbonk', NULL, N'https://intellishore.dk', N'Https://dcode.bi', NULL, NULL),
(87, 1, N'Data Solutions Technical Lead', N'Microsoft Data Platform MVP. Subject matter expert in the field of Data Engineering and Business Intelligence. On a daily basis, he works as a Data Solutions Technical Lead in Elitmind with the entire range of Microsoft solutions tools, both On-premise and in the Azure Cloud.

Loves to share knowledge, writes a lot on his technological blog seequality.net. Open to various discussions on the Data related topics, frequent speaker during dedicated conferences and user groups.

The main organizer and mentor of the first hackathon dedicated to the Microsoft Data Platform called SiriusCoding. In the professional field, he is interested in all technologies related to Data Processing and Storage. The holder of numerous certificates such as Microsoft Certified Solutions Expert, Azure Data Engineer, or Microsoft Certified Trainer. Personally, fun of rock music and nature, trying to be the best father and husband.', N'https://www.linkedin.com/in/adriansql/', N'https://twitter.com/adrian_sql', N'https://www.seeqlty.com/', N'https://pl.seequality.net/', NULL, NULL),
(87, 2, N'Data Architect', N'Microsoft Data Platform MVP. Subject matter expert in the field of Data Engineering and Business Intelligence. On a daily basis, he works as a Data Architect in Seequality with the entire range of Microsoft solutions tools, both On-premise and in the Azure Cloud.

Loves to share knowledge, writes a lot on his technological blog seequality.net. Open to various discussions on the Data related topics, frequent speaker during dedicated conferences and user groups.

In the professional field, he is interested in all technologies related to Data Processing and Storage. The holder of numerous certificates such as Microsoft Certified Solutions Expert, Azure Data Engineer, or Microsoft Certified Trainer. Personally, fun of rock music and nature, trying to be the best father and husband.', N'https://www.linkedin.com/in/adriansql/', N'https://twitter.com/adrian_sql', N'https://www.seeqlty.com/', N'https://pl.seequality.net/', NULL, NULL),
(87, 3, N'Data Solutions Technical Lead', N'Currently working as a Data Architect at SeeQuality, where he designs and implements enterprise-grade solutions leveraging the full spectrum of Microsoft data technologies, Azure services, Databricks, and complementary platforms.

Passionate about knowledge sharing, he actively maintains a widely followed technical blog at seequality.net and regularly contributes thought leadership to the global data community. An accomplished speaker, he is a frequent presenter at international conferences, user groups, and industry events focused on data-related topics.

His technical interests encompass the entire data lifecycle, including modern data processing, storage architectures, analytics, and cloud-native solutions. He holds numerous high-level certifications, including Microsoft Certified Solutions Expert (Data Management and Analytics), Microsoft Certified: Azure Data Engineer Associate, Microsoft Certified: Fabric Analytics Engineer Associate, and Microsoft Certified Trainer (MCT).

Outside of work, he is an enthusiastic rock music and avid nature lover, while dedicating himself to being the best possible husband and father.', N'https://www.linkedin.com/in/adriansql/', N'https://twitter.com/adrian_sql', N'https://www.seeqlty.com/', N'https://pl.seequality.net/', NULL, NULL),
(87, 5, N'Data Solutions Technical Lead', N'Microsoft Data Platform MVP. Subject matter expert in the field of Data Engineering and Business Intelligence. On a daily basis, he works as a Data Solutions Technical Lead in Elitmind with the entire range of Microsoft solutions tools, both On-premise and in the Azure Cloud.

Loves to share knowledge, writes a lot on his technological blog seequality.net. Open to various discussions on the Data related topics, frequent speaker during dedicated conferences and user groups.

The main organizer and mentor of the first hackathon dedicated to the Microsoft Data Platform called SiriusCoding. In the professional field, he is interested in all technologies related to Data Processing and Storage. The holder of numerous certificates such as Microsoft Certified Solutions Expert, Azure Data Engineer, or Microsoft Certified Trainer. Personally, fun of rock music and nature, trying to be the best father and husband.', NULL, NULL, NULL, NULL, NULL, NULL),
(88, 2, N'Innovator | Tech Evangelist | Emerging Tech Strategist | Solution Architect', N'Michał to doświadczony architekt, projektant, lider zespołu i trener, uhonorowany tytułem Microsoft MVP. Od lat tworzy aplikacje w .NET dla największych światowych firm, koncentrując się na nowoczesnych rozwiązaniach chmurowych. Jego przygoda z programowaniem rozpoczęła się w latach 90., kiedy na 8-bitowych maszynach poznawał języki: BASIC i Assembler. Obecnie skupia się na wdrażaniu innowacyjnych technologii, takich jak informatyka kwantowa, low-code i GenAI. Poza kodowaniem uwielbia podróżować, fotografować oraz dzielić się wiedzą w społeczności technologicznej oraz na swoim blogu.', N'https://www.linkedin.com/in/michalmjankowski/', N'https://twitter.com/JankowskiMichal', N'https://objectivity.co.uk', N'https://jankowskimichal.pl', NULL, N'https://www.instagram.com/jankowskimm/'),
(89, 3, N'Azure MVP, Technology Advisor & Managing Partner @ Protopia', N'Technology Advisor i Managing Partner w Protopia - butikowym consultingu, który pomaga firmom przekuwać cloud - kiedyś przede wszystkim cloud, dziś coraz częściej mocno przehajpowane AI - w realny efekt biznesowy. Zawsze bleeding edge: Azure od 2013, Docker/Kubernetes od 2014, a z LLM-ami dłubał jeszcze zanim ChatGPT i "AI-szamania" na LinkedInie zrobiły się mainstreamem. W jego CV znajdziesz też sporo projektów data oraz przekrój technologii, które w momencie wdrożenia były na topie - a potem, jak każda moda, po prostu przeminęły.

Microsoft MVP nieprzerwanie od 2012. Poza Protopią współtworzy podcast Patoarchitekci.', N'https://www.linkedin.com/in/lukaszkaluzny/', N'https://x.com/kaluzaaa', N'https://protopia.tech', N'https://patoarchitekci.io', NULL, NULL),
(90, 3, N'C&F, Azure Solution Engineer', N'Na co dzień, od 5 lat pracuję z technologią chmurową Azure, którego jestem ogromną pasjonatką. W swojej pracy łączę praktyczne doświadczenie z ciekawością i chęcią ciągłego eksperymentowania. Jako inżynier danych tworzę procesy przetwarzania danych, buduję pipeline’y i projektuję architekturę rozwiązań. Uwielbiam odkrywać nowe narzędzia i pasjonuje mnie też dzielenie się wiedzą. Wierzę, że najlepsze pomysły rodzą się wtedy, gdy rozmawiamy o tym, jak pracujemy. Po godzinach z ciekawością śledzę nowinki technologiczne i szukam inspiracji do kolejnych eksperymentów.', N'https://pl.linkedin.com/in/martyna-sikorska-czury%C5%82o-2198871a5', NULL, N'https://candf.com/', NULL, NULL, NULL),
(91, 3, N'Staff Data Engineer @Unity', N'Experienced Data Engineering Tech Lead with a diverse technical background in data infrastructure, data architecture design, and robust data pipes building. With 10+ years of experience, I bring great problem-solving skills and a can-do approach that can contribute to various projects.', N'https://www.linkedin.com/in/asaf-sneh/', NULL, N'https://unity.com/', NULL, NULL, NULL),
(92, 3, N'I will make your SQL Server faster in exchange for money.', N'Erik Darling started using SQL Server after a dispute with Excel over a vlookup.

He enjoys public arguments with the optimizer, and wine photography.', N'https://www.linkedin.com/company/darling-data', N'https://twitter.com/erikdarlingdata', N'https://erikdarling.com/', N'https://erikdarling.com/', NULL, NULL),
(93, 4, N'Machine Learning Engineer at deepsense.ai', N'Michał is a machine learning engineer at deepsense.ai. He enjoys contributing to open-source and researching about foundation models and how to make them more useful in enterprise workflows.', NULL, NULL, NULL, NULL, NULL, NULL),
(94, 4, N'Nokia, R&D Developer', N'Programmer with 8 years of experience. For the past 3 years, he has worked for Nokia on the development team of an AI-based chat bot application for telecom engineers.', NULL, NULL, NULL, NULL, NULL, NULL),
(94, 5, N'Nokia, R&D Developer', N'Programmer with 8 years of experience. For the past 3 years, he has worked for Nokia on the development team of an AI-based chat bot application for telecom engineers.', NULL, NULL, NULL, NULL, NULL, NULL),
(95, 2, N'Chief Azure Architect @ C&F', N'Microsoft Azure MVP i Cloud Architect z ponad 14 letnim doświadczeniem w branży IT. Pasjonat technologiczny ze szczególnym ukierunkowaniem na technologie Microsoft oraz chmurę Azure na którą od ostatnich kilku lat projektuje rozwiązania. Adam wdraża rozwiązania dla dużych firm międzynarodowych specjalizując się w dziedzinie Data & Analytics. W wolnym czasie Adam prowadzi własny kanał na YouTube (Azure for Everyone) poświęcony chmurze Azure.', N'https://www.linkedin.com/in/adam-marczak/', N'https://twitter.com/MarczakIO', N'https://candf.com', N'https://marczak.io', NULL, NULL),
(95, 4, N'Chief Azure Architect @ C&F', N'Microsoft Azure MVP i Cloud Architect z ponad 14 letnim doświadczeniem w branży IT. Pasjonat technologiczny ze szczególnym ukierunkowaniem na technologie Microsoft oraz chmurę Azure na którą od ostatnich kilku lat projektuje rozwiązania. Adam wdraża rozwiązania dla dużych firm międzynarodowych specjalizując się w dziedzinie Data & Analytics. W wolnym czasie Adam prowadzi własny kanał na YouTube (Azure for Everyone) poświęcony chmurze Azure.', NULL, NULL, NULL, NULL, NULL, NULL),
(96, 6, N'Principal Field Solutions Architect', N'Andrew is a Microsoft Data Platform MVP and Docker Captain who helps organise Data Ceili and EightKB.

He is interested in all things database/kubernetes/container related and shares his passion for these topics by speaking at events across the world.

Originally from Wales but now exploring Ireland.

You can find him on Bluesky @dbafromthecold.com and blogging at dbafromthecold.com', NULL, NULL, NULL, NULL, NULL, NULL),
(97, 4, N'Digital Advisor w firmie Bit Peak sp. z o.o.', N'Od 15 lat jestem entuzjastką rozwiązań klasy BI. Pracuję obecnie na stanowisku Digital Advisor w firmie Bit Peak tworząc wspólnie z klientami Platformy skrojone na miarę ich potrzeb.', NULL, NULL, NULL, NULL, NULL, NULL),
(98, 2, N'Lingaro, Data Engineer', N'An enthusiastic and energetic problem solver with the passion for programming and emerging technologies. Proven track record within the RDB domain, SQL, and PL/SQL. A certified Oracle professional with additional working knowledge of open source database solutions.', NULL, NULL, NULL, NULL, NULL, NULL),
(99, 1, N'Microsoft Technical Trainer, MCT', N'A trainer and database expert with extensive experience in supporting clients'' architectural decisions, infrastructure reviews and consulting in the field of databases and applications based on Microsoft SQL Server. The leader of the Data Community Krakow group and an active speaker at conferences related to SQL Server in Europe. On a daily basis, he works as a Microsoft Technical Trainer, training clients from around the world in the Microsoft Azure platform. In 2020-2021, selected by Microsoft as MCT Regional Lead, as well as Microsoft MVP in the Data Platform category.', N'https://www.linkedin.com/in/misadowski', N'https://twitter.com/SadowskiMichal', NULL, NULL, NULL, NULL),
(99, 3, N'Solution Architect, MCT', N'Microsoft Fabric Solutions Architect helping clients worldwide unlock value from their data. Specializes in architectural consulting, infrastructure design, and database solutions on the Microsoft platform.
Leader of the Kraków Data Community and regular speaker at SQL Server conferences across Poland and Europe. Former Microsoft MVP in the Data Platform category and former MCT Regional Lead (2020-2021).', N'https://www.linkedin.com/in/misadowski', N'https://twitter.com/SadowskiMichal', NULL, NULL, NULL, NULL),
(99, 6, N'Solution Architect, MCT', N'Microsoft Fabric Solutions Architect helping clients worldwide unlock value from their data. Specializes in architectural consulting, infrastructure design, and database solutions on the Microsoft platform.
Leader of the Kraków Data Community and regular speaker at SQL Server conferences across Poland and Europe. Former Microsoft MVP in the Data Platform category and former MCT Regional Lead (2020-2021).', NULL, NULL, NULL, NULL, NULL, NULL),
(100, 3, N'SQLBI', N'Marco is a business intelligence consultant and mentor. He wrote several books about Power BI, Analysis Service, and Power Pivot. He also regularly write articles and white papers that are available on sqlbi.com. Marco is a Microsoft MVP and an SSAS Maestro, the highest level of certification on Microsoft Analysis Services.
Today, Marco focuses his time with SQLBI customers, traveling extensively to train and consult on DAX and data modeling for Power BI and Analysis Services. Marco also teaches public classes worldwide.
Marco is a regular speaker at international conferences. He also enjoys delivering evening sessions at local user groups during his trips.', N'https://www.linkedin.com/in/sqlbi/', N'https://x.com/marcorus', N'https://www.sqlbi.com', N'https://www.sqlbi.com/blog/marco/', N'https://www.facebook.com/marco.russo.42', N'https://www.instagram.com/marcosqlbi/'),
(101, 1, N'Big Data & AI Solutions Architect w TIDK | AI, ML & Cloud Development Leader w TIDK', N'Team leader w zespole AI/ML w TIDK, gdzie w świetnym towarzystwie zajmujemy się wdrażaniem rozwiązań opartych na sztucznej inteligencji. Aktualnie jestem w trakcie doktoratu wdrożeniowego na Politechnice Poznańskiej, gdzie skupiam się na modelach prognozowania szeregów czasowych oraz detekcji anomalii. W pracy korzystam z rozwiązań chmurowych, w których kompetencje potwierdzają zdobyte przeze mnie certyfikaty zarówno z obszaru MS Azure jak i GCP.', N'https://www.linkedin.com/in/maciej-rubczy%C5%84ski-174293103/', NULL, N'http://www.tidk.pl/', N'https://www.linkedin.com/newsletters/naj-w-ai-7135957593432162304/', NULL, NULL),
(101, 2, N'Big Data & AI Solutions Architect w TIDK | AI, ML & Cloud Development Leader w TIDK', N'W TIDK odpowiedzialny za nadzór nad rozwojem i wytwarzaniem projektów w obszarze Big Data & AI jako Head of Development. Posiada ponad 5 letnie doświadczenie zawodowe w obszarze danych i AI. Swoją drogę zawodową rozpoczął na Politechnice Poznańskiej gdzie jest aktualnie w trakcie studiów doktoranckich w obszarze Sztucznej Inteligencji.

Od 2024 Microsoft MVP w kategorii Azure AI Services, jako jedna z czterech osób w Polsce. W pracy korzysta z rozwiązań chmurowych dostarczanych przez Micrsoft Azure, Databricks oraz Google Cloud, w których kompetencje potwierdzają zdobyte certyfikaty.', N'https://www.linkedin.com/in/maciej-rubczy%C5%84ski-174293103/', NULL, N'http://www.tidk.pl/', N'https://www.linkedin.com/newsletters/naj-w-ai-7135957593432162304/', NULL, NULL),
(101, 5, N'Head of Development w TIDK | Big Data & AI Solutions Architect w TIDK', N'W TIDK odpowiedzialny za nadzór nad rozwojem i wytwarzaniem projektów w obszarze Big Data & AI jako Head of Development. Swoją drogę zawodową rozpoczął na Politechnice Poznańskiej, a od 2019 roku pracuje w firmie TIDK - najpierw jako Machine Learning Engineer, obecnie Head of Development oraz architekt rozwiązań z zakresu Big Data i Sztucznej Inteligencji. Od 2024 Microsoft MVP w kategorii Azure AI Services, jako jedna z czterech osób w Polsce. W pracy korzysta z rozwiązań chmurowych dostarczanych przez Micrsoft Azure, Databricks oraz Google Cloud, w których kompetencje potwierdzają zdobyte certyfikaty.', NULL, NULL, NULL, NULL, NULL, NULL),
(102, 1, N'Objectivity, Senior BI Dev', N'Pracuję jako Senior BI developer w środowisku Microsoft. Na co dzień zajmuję się modelami tabelarycznymi Power BI wykorzystując narzędzia Tabular Editor, DAX Studio czy SQL Server Management Studio. Przygodę z danymi zacząłem w 2018 roku od Excela i SPSSa, pomału rozwijając kolejne kompetencje. W analizie danych największą satysfakcję sprawia mi wyciąganie wniosków z dużych zbiorów danych i prezentowanie ich na intuicyjnych wizualizacjach.', N'https://www.linkedin.com/in/%C5%82ukasz-balcerzak-3081b1154/', NULL, NULL, NULL, NULL, NULL),
(103, 1, N'Data Architect, Data Engineer', N'Data architect, jak i data engineer, który od wielu lat nie tylko projektuje, ale również implementuje związane z analizą dużych zbiorów danych. Pasjonat nowych technologii związanych z przechowywaniem oraz przetwarzania danych w szczególności opartych o koncepcję data lakehause''ów . Od ponad 3 lat tworzy i rozwija rozwiązanie data lakehouse zbudowane w oparciu o chmurę Azure i Databricks. Od kilku lat związany z Data Community.', N'https://www.linkedin.com/in/tomasz-krawczyk-1a531328/', NULL, NULL, NULL, NULL, NULL),
(103, 3, N'Data Architect, Data Engineer', N'Data Engineer i Data Architect z ponad 20-letnim stażem w IT, który od dekady projektuje systemy do analizy dużych zbiorów danych. Doświadczenie zdobywał, wdrażając rozwiązania oparte o Snowflake, Synapse, Fabric czy Databricks. Obecnie koncentruje się na eksplorowaniu ultra-skalowalnych silników bazodanowych takich jak ClickHouse oraz ich synergii z obszarem AI, LLM i bazami wektorowymi.
Zdobyte doświadczenie wykorzystuje do przekształcania wymagań biznesowych w efektywne architektury danych i dostarczanie kompleksowych rozwiązań BI będących odpowiedzią na potrzeby biznesu.', N'https://www.linkedin.com/in/tomasz-krawczyk-1a531328/', NULL, NULL, NULL, NULL, NULL),
(103, 5, N'Data Architect, Data Engineer', N'Data Engineer i Data Architect z ponad 20-letnim stażem w IT, od ponad 10 lat zajmuje się tworzeniem rozwiązań do analizy dużych zbiorów danych. W swojej hisotrii miałem okazję pracować z rozwiązanimi takimi jak Snowflake,Synapse, Fabric czy Databricks.Aktulanie eksploruję ciekawe, skalowalne rozwiązania open-source do przechowywania i przetwarzania danych, analizując jednocześnie co dzieje się w obaszarze AI, LLM, agentów AI i baz wektorowych.
Zdobyte doświadczenie wykorzystuje przekształcanie wymagań biznesowych w efektywne architektury danych
 i dostarczanie kompleksowych rozwiązań BI.', NULL, NULL, NULL, NULL, NULL, NULL),
(104, 3, N'Senior Data Scientist', N'Senior Data Scientist w Bayer Consumer Health. Od ponad 10 lat zajmuję się wspieraniem biznesu rozwiązaniami z obszaru uczenia maszynowanego i zautomatyzowanej analityki. Lubię porządkować dane, optymalizować procesy i tworzyć narzędzia pozwalające bizensowi zarabiać większe pieniądze.', NULL, NULL, NULL, NULL, NULL, NULL),
(105, 3, N'Torsten Strauss - MVP Data Platform and Developer Technologies', N'Torsten Strauß (MVP) is the CEO of inside-sqlserver and Principal Microsoft SQL Consultant at Sarpedon Quality Lab. He is a multi-certified Microsoft expert specializing in Azure DevOps, as well as performance optimization and development of SQL Server and Azure SQL environments.
Torsten has delivered over 320 technical sessions at national and international conferences and user groups. Since 2018, he has been recognized annually as a Microsoft Most Valuable Professional for Data Platform — and since 2025, also for Developer Technologies. He is a Microsoft Certified Trainer and was recognized as one of Sessionize’s Top Speakers for three consecutive years.', N'https://www.linkedin.com/in/torsten-strauss/', NULL, NULL, N'https://inside-sqlserver.com/', NULL, NULL),
(106, 1, N'SQL Server and Oracle DBA, Azure  and PowerBI admins', N'David Postlethwaite has been a SQL Server and Oracle DBA since 2008.
He now lives and works in Copenhagen supporting databases, Azure, NetApp, security, auditing, mentoring and whatever else his company asks him to work on.
In a previous life he was a .NET developer and way back in history a Windows and Netware administrator.', N'https://www.linkedin.com/in/davidpostlethwaite/', NULL, N'http://BankingCircle.com', NULL, NULL, NULL),
(106, 2, N'SQL Server and Oracle DBA, Azure  and PowerBI admins', N'David Postlethwaite has been a SQL Server and Oracle DBA since 2008.
He now lives and works in Copenhagen supporting databases, Azure, NetApp, security, auditing, mentoring and whatever else his company asks him to work on.
In a previous life he was a .NET developer and way back in history a Windows and Netware administrator.', N'https://www.linkedin.com/in/davidpostlethwaite/', NULL, N'http://BankingCircle.com', NULL, NULL, NULL),
(107, 1, N'Data Architect', N'Software engineer with 20+ years of professional experience in all aspects of software development.
Damian participated in a number of projects in international environments and possesses practical knowledge of procedures and tools which are necessary for successful implementation of such projects.
Now he focuses on building solutions based on Data Platform (including complex database driven systems, database administering, tuning and optimization, cloud solutions, ML).
Damian is experienced speaker and columnist. Damian is a Microsoft Data Platform MVP for over 10 years and Microsoft Certified Trainer for 15 years. He now is also an MCSE of Data Platform. Describes himself as an energetic actor.', N'https://www.linkedin.com/in/damian-widera-0b56284/', N'https://twitter.com/codingfamilynet', NULL, NULL, NULL, NULL),
(107, 2, N'Senior Data Solution Architect, MVP Data Platform', N'Software engineer with 20+ years of professional experience in all aspects of software development.
Damian participated in a number of projects in international environments and possesses practical knowledge of procedures and tools which are necessary for successful implementation of such projects.
Now he focuses on building solutions based on Data Platform (including complex database driven systems, database administering, tuning and optimization, cloud solutions, ML).
Damian is experienced speaker and columnist. Damian is a Microsoft Data Platform MVP for over 16 years and Microsoft Certified Trainer for 20 years. He now is also an MCSE of Data Platform. Describes himself as an energetic actor.', N'https://www.linkedin.com/in/damian-widera-0b56284/', N'https://twitter.com/codingfamilynet', NULL, NULL, NULL, NULL),
(107, 3, N'Data Architect', N'Software engineer with 20+ years of professional experience in all aspects of software development.
Damian participated in a number of projects in international environments and possesses practical knowledge of procedures and tools which are necessary for successful implementation of such projects.
Now he focuses on building solutions based on Data Platform (including complex database driven systems, database administering, tuning and optimization, cloud solutions, ML).
Damian is experienced speaker and columnist. Damian is a Microsoft Data Platform MVP for over 10 years and Microsoft Certified Trainer for 15 years. He now is also an MCSE of Data Platform. Describes himself as an energetic actor.', N'https://www.linkedin.com/in/damian-widera-0b56284/', N'https://twitter.com/codingfamilynet', NULL, NULL, NULL, NULL),
(107, 5, N'Data Architect', N'Software engineer with 20+ years of professional experience in all aspects of software development.
Damian participated in a number of projects in international environments and possesses practical knowledge of procedures and tools which are necessary for successful implementation of such projects.
Now he focuses on building solutions based on Data Platform (including complex database driven systems, database administering, tuning and optimization, cloud solutions, ML).
Damian is experienced speaker and columnist. Damian is a Microsoft Data Platform MVP for over 10 years and Microsoft Certified Trainer for 15 years. He now is also an MCSE of Data Platform. Describes himself as an energetic actor.', NULL, NULL, NULL, NULL, NULL, NULL),
(107, 6, N'Data Architect', N'Software engineer with 20+ years of professional experience in all aspects of software development.
Damian participated in a number of projects in international environments and possesses practical knowledge of procedures and tools which are necessary for successful implementation of such projects.
Now he focuses on building solutions based on Data Platform (including complex database driven systems, database administering, tuning and optimization, cloud solutions, ML).
Damian is experienced speaker and columnist. Damian is a Microsoft Data Platform MVP for over 10 years and Microsoft Certified Trainer for 15 years. He now is also an MCSE of Data Platform. Describes himself as an energetic actor.', NULL, NULL, NULL, NULL, NULL, NULL),
(108, 2, N'Enterprise Integration Architect & Azure Cloud Solutions Architect', N'With a deep passion for Cloud technology since 2012, I have extensive experience in IT, Architecture, and Leadership, particularly with Microsoft Azure, .NET, Dynamics, and Power Platform. From the intricate realm of IT to the strategic landscape of Architecture, my journey has been guided by a natural curiosity and a relentless drive for innovation. Transitioning from consultancy to leadership roles within the enterprise domain, I am currently immersed in crafting end-to-end architectures for large-scale organizations, fueled by a genuine passion for collaborative problem-solving and solution crafting.

I hold certifications in TOGAF, Scrum Master, and Azure Architecture, and I am skilled at creating clear, effective solutions to complex challenges in enterprise settings. I specialize in developing architectures that accommodate various integration flows and software solutions.', N'https://www.linkedin.com/in/dietergobeyn/', N'https://x.com/DieterGobeyn', N'https://hikoniq.be', N'https://azuretechinsider.com/', NULL, NULL),
(108, 4, N'Enterprise Integration Architect & Azure Cloud Solutions Architect', N'A seasoned Cloud enthusiast with 12+ years of experience in IT, Architecture and Leadership, I bring a wealth of hands-on expertise in Microsoft Azure, .NET, Dynamics and Power Platform. From the intricate realm of IT to the strategic landscape of Architecture, my journey has been guided by a natural curiosity and a relentless drive for innovation. Transitioning from consultancy to leadership roles within the enterprise domain, I am currently immersed in crafting end-to-end architectures for large-scale organizations, fueled by a genuine passion for collaborative problem-solving and solution crafting.

I hold certifications in TOGAF, Scrum Master, and Azure Architecture, and I am skilled at creating clear, effective solutions to complex challenges in enterprise settings. I specialize in developing architectures that accommodate various integration flows and software solutions.', NULL, NULL, NULL, NULL, NULL, NULL),
(109, 3, N'SoftFit, Co-owner', N'Ponad 20 lat doświadczenia w branży IT, zdobywanego na stanowiskach programisty oraz administratora systemów. Obecnie przedsiębiorca. Specjalizuje się w systemach Business Intelligence oraz rozwiązaniach backendowych wspierających rozwój firm, głównie z obszaru e-commerce i startupów.', NULL, NULL, NULL, NULL, NULL, NULL),
(110, 1, N'Data Architect TIDK, MVP Data Platform, KursySQL.pl', N'Data Architect w firmie TIDK. MVP Data Platform, MCT.
Aktywny członek Data Community Poland.
Prelegent na konferencjach dot. Platformy danych Microsoft.
Jego prezentacje i szkolenia są dostępne na kanale YouTube www.youtube.com/c/kursysql oraz w ramach serwisu www.kursysql.pl
Pasjonat kolarstwa i maratonów MTB.', N'https://www.linkedin.com/in/tomaszlibera/', NULL, N'https://www.tidk.pl', N'https://www.kursysql.pl/aktualnosci/', N'https://www.facebook.com/kursysql/', NULL),
(110, 2, N'Data Architect TIDK, MVP Data Platform, KursySQL.pl', N'Data Architect w firmie TIDK. MVP Data Platform, MCT.
Aktywny członek Data Community Poland.
Prelegent na konferencjach dot. Platformy danych Microsoft.
Jego prezentacje i szkolenia są dostępne na kanale YouTube www.youtube.com/c/kursysql oraz w ramach serwisu www.kursysql.pl
Pasjonat kolarstwa i maratonów MTB.', N'https://www.linkedin.com/in/tomaszlibera/', NULL, N'https://www.tidk.pl', N'https://www.kursysql.pl/aktualnosci/', N'https://www.facebook.com/kursysql/', NULL),
(110, 3, N'Data Architect TIDK, MVP Data Platform, KursySQL.pl', N'Data Architect w firmie TIDK. MVP Data Platform, MCT.
Aktywny członek Data Community Poland.
Prelegent na konferencjach dot. Platformy danych Microsoft.
Jego prezentacje i szkolenia są dostępne na kanale YouTube www.youtube.com/c/kursysql oraz w ramach serwisu www.kursysql.pl
Pasjonat kolarstwa i maratonów MTB.', N'https://www.linkedin.com/in/tomaszlibera/', NULL, N'https://www.tidk.pl', N'https://www.kursysql.pl/aktualnosci/', N'https://www.facebook.com/kursysql/', NULL),
(110, 6, N'Data Architect TIDK, MVP Data Platform, KursySQL.pl', N'Data Architect w firmie TIDK. MVP Data Platform, MCT.
Aktywny członek Data Community Poland.
Prelegent na konferencjach dot. Platformy danych Microsoft.
Jego prezentacje i szkolenia są dostępne na kanale YouTube www.youtube.com/c/kursysql oraz w ramach serwisu www.kursysql.pl
Pasjonat kolarstwa i maratonów MTB.', NULL, NULL, NULL, NULL, NULL, NULL),
(111, 2, N'Product Manager at Microsoft', N'Strahinja is a Product Manager at Microsoft, specializing in enhancing the backup and restore features of Azure SQL Managed Instance. Before joining the Managed Instance team, he worked on Microsoft Fabric, where he contributed to developing Synapse Data Warehouse and serverless SQL pools in Azure Synapse Analytics. Strahinja is passionate about engaging with end-users, gathering feedback, identifying pain points, and crafting solutions to address their needs. In his life before Microsoft, Strahinja worked as a gameplay programmer, developing AAA video games.', N'https://www.linkedin.com/in/strahinjarodic/', N'https://twitter.com/Strale15', NULL, N'https://www.linkedin.com/in/strahinjarodic/', NULL, NULL),
(112, 1, N'Data Science Domain Lead, SoftwareOne', N'Od prawie 10 lat zawodowo zajmuje się analityką danych jako data scientist, lider zespołu i kierownik projektu. Brał udział w wielu projektach z obszaru zaawansowanej analityki danych, takich jak monitorowanie linii produkcyjnych, analiza opinii, detekcja fraudów i prognozowanie cen. Jego główne doświadczenie i zainteresowania dotyczą branży farmaceutycznej i ochrony zdrowia, ale brał udział w projektach z różnych obszarów, takich jak finanse, handel detaliczny, energetyka i rolnictwo. Obecnie odpowiada za projektowanie i wdrażanie rozwiązań danych, głównie z zakresu uczenia maszynowego i sztucznej inteligencji. Swoją wiedzą dzieli się jako trener data science, wykładowca i prelegent na konferencjach. Współautor prac naukowych, głównie z zakresu medycyny i statystyki, publikowanych m.in. w czasopismach z listy filadelfijskiej.', N'https://pl.linkedin.com/in/pawe%C5%82-ekk-cierniakowski', NULL, NULL, NULL, NULL, NULL),
(112, 3, N'Senior Manager Artificial Intelligence and Machine Learning, SoftwareOne', N'Od prawie 10 lat zawodowo zajmuje się analityką danych jako data scientist, lider zespołu i kierownik projektu. Brał udział w wielu projektach z obszaru zaawansowanej analityki danych, takich jak monitorowanie linii produkcyjnych, analiza opinii, detekcja fraudów i prognozowanie cen. Jego główne doświadczenie i zainteresowania dotyczą branży farmaceutycznej i ochrony zdrowia, ale brał udział w projektach z różnych obszarów, takich jak finanse, handel detaliczny, energetyka i rolnictwo. Obecnie odpowiada za projektowanie i wdrażanie rozwiązań danych, głównie z zakresu uczenia maszynowego i sztucznej inteligencji. Swoją wiedzą dzieli się jako trener data science, wykładowca i prelegent na konferencjach. Współautor prac naukowych, głównie z zakresu medycyny i statystyki, publikowanych m.in. w czasopismach z listy filadelfijskiej.', N'https://pl.linkedin.com/in/pawe%C5%82-ekk-cierniakowski', NULL, NULL, NULL, NULL, NULL),
(112, 4, N'Data Science Domain Lead, SoftwareOne', N'Od prawie 10 lat zawodowo zajmuje się analityką danych jako data scientist, lider zespołu i kierownik projektu. Brał udział w wielu projektach z obszaru zaawansowanej analityki danych, takich jak monitorowanie linii produkcyjnych, analiza opinii, detekcja fraudów i prognozowanie cen. Jego główne doświadczenie i zainteresowania dotyczą branży farmaceutycznej i ochrony zdrowia, ale brał udział w projektach z różnych obszarów, takich jak finanse, handel detaliczny, energetyka i rolnictwo. Obecnie odpowiada za projektowanie i wdrażanie rozwiązań danych, głównie z zakresu uczenia maszynowego i sztucznej inteligencji. Swoją wiedzą dzieli się jako trener data science, wykładowca i prelegent na konferencjach. Współautor prac naukowych, głównie z zakresu medycyny i statystyki, publikowanych m.in. w czasopismach z listy filadelfijskiej.', NULL, NULL, NULL, NULL, NULL, NULL),
(113, 1, N'CTO TIDK, MVP Data Platform', N'Jakub Wawrzyniak - CTO @ TIDK, solutions architect, coordinates and is responsible for the quality of projects implemented in ​​AI, BI, Big Data, and advanced analytics. He specializes in designing efficient analytical solutions based on the public cloud.

His experience and knowledge in optimization are appreciated by the most prominent Polish organizations. PhD student, scientifically associated with the Department of Theory of Algorithms and Programming Systems of the Institute of Computer Science of the Poznań University of Technology. He has been working in the IT sector for over ten years. Designer and developer of solutions for public administration, programmer.

He has experience in implementing international R&D projects, including on behalf of the university, for external entities. His research interests include such issues as algorithm design, computational complexity analysis, machine learning, combinatorial optimization, and task scheduling.

Member of the Organizing Committees of the Game Industry Conference and Applied Data Science. Member of the Polish Game Research Society.', N'https://www.linkedin.com/in/jakub-piotr-wawrzyniak/', N'https://twitter.com/jwawrzyniak_', NULL, NULL, NULL, NULL),
(113, 2, N'CTO TIDK, MVP Data Platform', N'Jakub Wawrzyniak - CTO @ TIDK, solutions architect, coordinates and is responsible for the quality of projects implemented in ​​AI, BI, Big Data, and advanced analytics. He specializes in designing efficient analytical solutions based on the public cloud.

His experience and knowledge in optimization are appreciated by the most prominent Polish organizations. PhD student, scientifically associated with the Department of Theory of Algorithms and Programming Systems of the Institute of Computer Science of the Poznań University of Technology. He has been working in the IT sector for over ten years. Designer and developer of solutions for public administration, programmer.

He has experience in implementing international R&D projects, including on behalf of the university, for external entities. His research interests include such issues as algorithm design, computational complexity analysis, machine learning, combinatorial optimization, and task scheduling.

Member of the Organizing Committees of the Game Industry Conference and Applied Data Science. Member of the Polish Game Research Society.', N'https://www.linkedin.com/in/jakub-piotr-wawrzyniak/', N'https://twitter.com/jwawrzyniak_', NULL, NULL, NULL, NULL),
(113, 3, N'Cloud Solution Architect, Advisor, ex-Microsoft MVP Data Platform', N'Senior Data Solution Engineer at Microsoft, passionate about innovation in the field of data and artificial intelligence. PhD in Computer Science, former Microsoft MVP Data Platform, co-leader of the Data Community Poznań group. He helps organizations discover the full potential of the cloud by creating scalable analytics platforms based on Azure, Microsoft Fabric, and Databricks. He combines technical knowledge with a business approach to support companies in their digital transformation and building competitive advantage. Speaker at industry events, promoter of modern solutions, and ambassador for technologies that are changing the way we work with data.', N'https://www.linkedin.com/in/jakub-piotr-wawrzyniak/', N'https://twitter.com/jwawrzyniak_', NULL, NULL, NULL, NULL),
(113, 4, N'CTO TIDK, MVP Data Platform', N'Jakub Wawrzyniak - CTO @ TIDK, solutions architect, coordinates and is responsible for the quality of projects implemented in ​​AI, BI, Big Data, and advanced analytics. He specializes in designing efficient analytical solutions based on the public cloud.

His experience and knowledge in optimization are appreciated by the most prominent Polish organizations. PhD student, scientifically associated with the Department of Theory of Algorithms and Programming Systems of the Institute of Computer Science of the Poznań University of Technology. He has been working in the IT sector for over ten years. Designer and developer of solutions for public administration, programmer.

He has experience in implementing international R&D projects, including on behalf of the university, for external entities. His research interests include such issues as algorithm design, computational complexity analysis, machine learning, combinatorial optimization, and task scheduling.

Member of the Organizing Committees of the Game Industry Conference and Applied Data Science. Member of the Polish Game Research Society.', NULL, NULL, NULL, NULL, NULL, NULL),
(114, 1, N'Volvo Polska - Manager of Platform Architecture and Governance', N'Bartek Wierzbicki is a director at Volvo Polska, managing the  Platform Architecture and Governance team at the Volvo Data unit. Over 15 years of professional experience in multiple technologies, from embedded software programming to front-end data solutions. For the last few years responsible for business intelligence solutions and data platforms, both on-prem and cloud. He is currently managing the team of solution architects accountable for the architecture of the Volvo Data Cloud platform.', N'https://www.linkedin.com/in/bartlomiej-wierzbicki-a59b63172?utm_source=share&utm_campaign=share_via&utm_content=profile&utm_medium=android_app', NULL, N'https://www.volvogroup.com/en/', NULL, NULL, NULL),
(115, 1, N'SQL Server Consultant and Trainer', N'Gethyn is a Microsoft Data Platform MVP, SQL Server consultant and trainer specialising in the Microsoft Data Platform. Gethyn runs a small consultancy practice in the UK with clients across Europe and North America. The consultancy practice specialises in SQL Server upgrades, migrations to Azure, database security, architecture  of highly available data platforms and database performance. Gethyn has published two books relating to SQL Server, one on SQL Server 2014 new features, and another on the Azure IaaS offering. He is also a Microsoft Certified Trainer for a number of years and has delivered approximately 200 training courses. He maintains a data platform themed blog on his website www.gethynellis.com', N'https://www.linkedin.com/in/gethynellis/', N'https://twitter.com/gethyn_ellis', N'https://www.gethynellis.com/', N'https://www.gethynellis.com/blog', NULL, NULL),
(115, 3, N'SQL Server Consultant and Trainer', N'Gethyn is a Microsoft Data Platform MVP, SQL Server consultant and trainer specialising in the Microsoft Data Platform. Gethyn runs a small consultancy practice in the UK with clients across Europe and North America. The consultancy practice specialises in SQL Server upgrades, migrations to Azure, database security, architecture  of highly available data platforms and database performance. Gethyn has published two books relating to SQL Server, one on SQL Server 2014 new features, and another on the Azure IaaS offering. He is also a Microsoft Certified Trainer for a number of years and has delivered approximately 200 training courses. He maintains a data platform themed blog on his website www.gethynellis.com', N'https://www.linkedin.com/in/gethynellis/', N'https://twitter.com/gethyn_ellis', N'https://www.gethynellis.com/', N'https://www.gethynellis.com/blog', NULL, NULL),
(116, 2, N'Data Platform Architect, GetInData | Part of Xebia', N'Experienced Data Platform Architect with over 11 years in designing and implementing scalable data solutions.
Proficient in data transformation and advanced analytics, database management, stream processing and cloud solutions.
Big Data trainer, big data blogger and conference speaker.', N'https://www.linkedin.com/in/rszmit/', NULL, NULL, NULL, NULL, NULL);

INSERT INTO dbo.SpeakerEditionProfile (SpeakerId, EventEditionId, TagLine, Bio, LinkedInUrl, XUrl, CompanyWebsiteUrl, BlogUrl, FacebookUrl, InstagramUrl) VALUES
(117, 2, N'Data + AI + Strategy', N'When not talking about Data & AI, Felix is a proud father and explores playgrounds and skate parks in the city. He spent the last couple of years advancing data-driven and digital transformations at international manufacturing companies: hands on, both, in code and on the shopfloor.

Throughout this time he observed that the transformation into a data + ai company requires more than “just” technology. So today, Felix helps companies across Europe in building sustainable transformation programs by translating business vision into technology and vice versa as a Data & AI Strategist at Databricks.

Felix lives close by Munich in Germany.', N'https://www.linkedin.com/in/felix-mutzl', NULL, N'https://www.databricks.com', NULL, NULL, NULL),
(118, 2, N'Data & AI Manager | GenAI Lead', N'Jestem liderką w obszarze danych i sztucznej inteligencji z ponad 15-letnim doświadczeniem. Obecnie buduję zespół inżynierów GenAI, wspierając firmy w transformacji biznesowej z wykorzystaniem Generative AI. Skupiam się na praktycznym zastosowaniu rozwiązań opartych na AI, które umożliwia osiąganie realnych i wymiernych korzyści.', N'https://www.linkedin.com/in/julia-or%C5%82owska-b5787112', NULL, NULL, NULL, NULL, NULL),
(119, 1, N'Chief Data Platforms Engineer, Saxo Bank', N'Ola Hallengren is a Data Platform MVP and the creator of the "SQL Server Maintenance Solution".', N'https://www.linkedin.com/in/olahallengren/', NULL, N'https://ola.hallengren.com', NULL, NULL, NULL),
(120, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(121, 3, N'Fabric/Purview/Azure Data Solution Tech Lead', N'Experienced Data Solution Technical Lead, Trainer, and Team Leader with a proven track record in architecting, implementing, and optimizing complex data solutions on Microsoft Azure, Fabric and Purview. Specializing in the Azure and Fabric data ecosystem, I have consistently enabled organizations to derive actionable insights and build scalable, secure, and cost-effective data platforms. Adept at bridging technical and business domains, I lead cross-functional teams, deliver strategic training programs, and drive data modernization initiatives aligned with business goals.', N'https://www.linkedin.com/in/lukasz-furga/', NULL, N'https://www.elitmind.com/', NULL, NULL, NULL),
(122, 4, N'staff data scientist w deepsense.ai, współzałożyciel PyData Bydgoszcz, wykładowca na PBŚ', N'Staff data scientist with mathematical background, data science lecturer at Bydgoszcz University of Technology, PyData Bydgoszcz cofounder, passionate about the city of Bydgoszcz, traveling to not necessarily touristy places and telling mediocre jokes.', NULL, NULL, NULL, NULL, NULL, NULL),
(123, 6, N'Database Engineer', N'Od 15 lat zajmuje się platformą danych (on-premise i w chmurze) w Asseco Business Solutions S.A. Grupa lubelska Data Community Poland.', NULL, NULL, NULL, NULL, NULL, NULL),
(124, 1, N'Product Manager | Big Data Processing', N'Driving ethical innovations in Big Data, Analytics and AI as an Architect/Tech Lead with a strong management and execution muscle, and with over 10 years of experience in various roles, including research, software development, and project management, across different industries and domains.', N'https://www.linkedin.com/in/esterakot/', N'https://twitter.com/estera_kot', N'https://aka.ms/fabric-espresso', N'https://www.linkedin.com/in/esterakot/', NULL, N'https://www.instagram.com/_drkot/'),
(124, 2, N'Product Manager | Solution Architect | Big Data Analytics & AI', N'Driving ethical innovations in Big Data, Analytics and AI as an Architect/Tech Lead with a strong management and execution muscle, and with over 10 years of experience in various roles, including research, software development, and project management, across different industries and domains.', N'https://www.linkedin.com/in/esterakot/', N'https://twitter.com/estera_kot', N'https://aka.ms/fabric-espresso', N'https://www.linkedin.com/in/esterakot/', NULL, N'https://www.instagram.com/_drkot/'),
(124, 3, N'CTO @ Clouds on Mars', N'Dr. Estera Kot is the Chief Technology Officer at Clouds On Mars, where she drives the company’s innovation in Data & AI strategy and execution. A former Principal Product Manager at Microsoft, she played a key role in building performance-critical components of Azure Synapse Analytics and Microsoft Fabric, focusing on Apache Spark and high-efficiency analytical engines.

Estera is a Polish-born engineer by passion, fluent in several programming languages and recognized for her hands-on technical depth. She earned her Ph.D. in Computer Science with distinction, specializing in machine and deep learning for medical imaging. Her research has led to numerous scientific publications and a U.S. patent in big data processing.

Her career spans global tech leaders like Intel, Sony, and Procter & Gamble. She is a respected educator and mentor, having designed full-time and postgraduate AI-in-Cloud programs at the Warsaw University of Technology. Her students now work at CERN, Google, Meta, and other top-tier institutions worldwide. Estera is a guest lecturer at UCLA—one of the top public research universities in the U.S.—and Łazarski University in Warsaw.

As a speaker, she’s presented at top industry events including MLADS (Microsoft’s internal AI and data science conference in Redmond), the inaugural FabCon in Las Vegas, and several AI and cloud conferences across Europe. She also produces educational content on YouTube, making complex AI topics accessible and practical.

Estera is committed to building scalable, ethical, and real-world-driven AI solutions, with a focus on impact over hype.', N'https://www.linkedin.com/in/esterakot/', N'https://twitter.com/estera_kot', N'https://aka.ms/fabric-espresso', N'https://www.linkedin.com/in/esterakot/', NULL, N'https://www.instagram.com/_drkot/'),
(124, 6, N'CTO @ Clouds on Mars', N'Dr. Estera Kot is the Chief Technology Officer at Clouds On Mars, where she drives the company’s innovation in Data & AI strategy and execution. A former Principal Product Manager at Microsoft, she played a key role in building performance-critical components of Azure Synapse Analytics and Microsoft Fabric, focusing on Apache Spark and high-efficiency analytical engines.

Estera is a Polish-born engineer by passion, fluent in several programming languages and recognized for her hands-on technical depth. She earned her Ph.D. in Computer Science with distinction, specializing in machine and deep learning for medical imaging. Her research has led to numerous scientific publications and a U.S. patent in big data processing.

Her career spans global tech leaders like Intel, Sony, and Procter & Gamble. She is a respected educator and mentor, having designed full-time and postgraduate AI-in-Cloud programs at the Warsaw University of Technology. Her students now work at CERN, Google, Meta, and other top-tier institutions worldwide. Estera is a guest lecturer at UCLA—one of the top public research universities in the U.S.—and Łazarski University in Warsaw.

As a speaker, she’s presented at top industry events including MLADS (Microsoft’s internal AI and data science conference in Redmond), the inaugural FabCon in Las Vegas, and several AI and cloud conferences across Europe. She also produces educational content on YouTube, making complex AI topics accessible and practical.

Estera is committed to building scalable, ethical, and real-world-driven AI solutions, with a focus on impact over hype.', NULL, NULL, NULL, NULL, NULL, NULL),
(125, 2, N'GDS Business Intelligence GmbH', N'Frank Geisler is the owner and CEO of GDS Business Intelligence GmbH, a leading Microsoft Solution Provider specializing in Data and AI. He holds numerous prestigious certifications, including Data Platform MVP, MCT, Azure Solutions Architect Expert, Azure Security Engineer Associate, Azure Data Engineer Associate, and DevOps Engineer Expert. In his role, Frank excels in building robust Business Intelligence systems leveraging Microsoft technologies such as SQL Server, Azure Data Platform, Microsoft Fabric, and Power BI. He is also proficient in constructing Azure infrastructures and architectures using PowerShell and Bicep.

Frank is a prolific author, having written several bestselling books including "Power BI für Dummies," "Azure für Dummies," "Docker für Dummies," and "Pro Serverless Data Handling with Microsoft Azure." As a frequent speaker, he has delivered insightful presentations at major national and international conferences like the PASS Community Summit, SQL BITS, and SQL Server Konferenz.

In addition to his professional achievements, Frank co-founded PASS Deutschland e.V. in 2004 and has served on its board of directors for many years. He also leads the Microsoft Data Community Regional Chapter Münsterland, contributing significantly to the community''s growth and development.', N'https://www.linkedin.com/in/frank-geisler', N'https://twitter.com/FrankGeisler', N'https://gds-business-intelligence.de/', NULL, NULL, NULL),
(125, 3, N'GDS Business Intelligence GmbH', N'Frank Geisler is the owner and CEO of GDS Business Intelligence GmbH, a leading Microsoft Solution Provider specializing in Data and AI. He holds numerous prestigious certifications, including Data Platform MVP, MCT, Azure Solutions Architect Expert, Azure Security Engineer Associate, Azure Data Engineer Associate, and DevOps Engineer Expert. In his role, Frank excels in building robust Business Intelligence systems leveraging Microsoft technologies such as SQL Server, Azure Data Platform, Microsoft Fabric, and Power BI. He is also proficient in constructing Azure infrastructures and architectures using PowerShell and Bicep.

Frank is a prolific author, having written several bestselling books including "Power BI für Dummies," "Azure für Dummies," "Docker für Dummies," and "Pro Serverless Data Handling with Microsoft Azure." As a frequent speaker, he has delivered insightful presentations at major national and international conferences like the PASS Community Summit, SQL BITS, and SQL Server Konferenz.

In addition to his professional achievements, Frank co-founded PASS Deutschland e.V. in 2004 and has served on its board of directors for many years. He also leads the Microsoft Data Community Regional Chapter Münsterland, contributing significantly to the community''s growth and development.', N'https://www.linkedin.com/in/frank-geisler', N'https://twitter.com/FrankGeisler', N'https://gds-business-intelligence.de/', NULL, NULL, NULL),
(126, 1, N'dataExpert', N'Pomagam firmom kłamać... mniej.

Istnieją trzy rodzaje kłamstw: kłamstwa, okropne kłamstwa i statystyki. Z reguły, statystycznie Twoje raporty są prawidłowe. Nie zawsze jednak odzwierciedlają one dostatecznie rzeczywistość. Pomagam to zmienić.

Zajmuję się przetwarzaniem danych w każdej ilości i wydobywaniem z nich wartości biznesowej.

--
Specjalizuje się w dostrajaniu wydajności SQL Server, optymalizacji zapytań, bezpieczeństwie, obszarach Business Intelligence, w tym Big Data i ETL na platformie Microsoft BI.

Platforma danych Microsoft to moja praca i pasja. Dzięki szerokiemu doświadczeniu w różnych obszarach, to co robię najlepiej, można określić jako ogólne rozwiązywanie problemów. :)

Poza pracą pomagam organizować lokalną grupę pasjonatów w ramach stowarzyszenia Data Community Poland (dawniej PLSSUG). Współorganizuję także największą konferencję (w naszej części Europy) SQL Day.
Przez ponad 6 lat byłem zaangażowany w Data Community jako Członek Zarządu Stowarzyszenia.
Od 2022 roku pełni funkcję Członka Rady Nadzorczej Stowarzyszenia.', N'https://www.linkedin.com/in/romanczarko/', NULL, N'https://astrokyon.com', NULL, NULL, NULL),
(127, 5, N'SQL Server Master at Woodler', N'Maciej Pilecki is a seasoned SQL Server expert with over 20 years of hands-on experience in database architecture, administration, and performance tuning. As Microsoft Certified Master in SQL Server and former Data Platform MVP, Maciej has led complex data projects across various industries, specializing in T-SQL programming, high availability, database optimization and scalability. Maciej is a frequent conference speaker and has contributed extensively to the SQL Server community through training, publications, and user groups.', NULL, NULL, NULL, NULL, NULL, NULL),
(128, 1, N'Data Platform Architect, GetInData | Part of Xebia', N'For 10 years in Data projects based mostly on the Microsoft platform. In recent years eagerly escaping into topics related to Architecture and DevOps.', N'https://www.linkedin.com/in/tomasz-kostyrka/', NULL, N'https://getindata.com/', N'https://pl.seequality.net/', NULL, NULL),
(128, 2, N'Data Platform Architect, GetInData | Part of Xebia; Databricks Solution Architect Champion', N'Data Platform Architect with ten years of experience in various positions related to the Data field.

Proficient with the Microsoft technology stack - started his journey with SQL Server and the SSIS/AS/RS suite, currently primarily focused on Azure Cloud, Snowflake, and Databricks platforms. Highly enthusiastic about all kinds of automation and implementing the DevOps/DataOps practices in projects.

Privately, a husband and father of two, suffering from chronic lack of time and sleep deprivation.', N'https://www.linkedin.com/in/tomasz-kostyrka/', NULL, N'https://getindata.com/', N'https://pl.seequality.net/', NULL, NULL),
(129, 1, N'Data Architect at SoftwareOne', N'Architekt, programista, trener z wieloletnim doświadczeniem w projektowaniu i tworzeniu systemów Business Intelligence oraz procesów przetwarzania danych. Lider i współzałożyciel grupy bydgosko-toruńskiej Data Community. Na co dzień pracuje jako Data Architekt w firmie SoftwareOne odpowiadając za architekturę u jednego z głównych klientów. Pasjonat danych i technologii MS lubiący dzielić się swoją wiedzą, pasją zarówno na spotkaniach grup lokalnych jak również na konferencjach związanych z SQLServer.', N'https://www.linkedin.com/in/tomaszwaloszek/', NULL, NULL, NULL, NULL, NULL),
(129, 2, N'Data Architect at SoftwareOne', N'Architekt, programista, trener z wieloletnim doświadczeniem w projektowaniu i tworzeniu systemów Business Intelligence oraz procesów przetwarzania danych. Lider i współzałożyciel grupy bydgosko-toruńskiej Data Community. Na co dzień pracuje jako Data Architekt w firmie SoftwareOne odpowiadając za architekturę u jednego z głównych klientów. Pasjonat danych i technologii MS lubiący dzielić się swoją wiedzą, pasją zarówno na spotkaniach grup lokalnych jak również na konferencjach związanych z SQLServer.', N'https://www.linkedin.com/in/tomaszwaloszek/', NULL, NULL, NULL, NULL, NULL),
(129, 3, N'Data Architect at SoftwareOne', N'Architekt, programista, trener z wieloletnim doświadczeniem w projektowaniu i tworzeniu systemów Business Intelligence oraz procesów przetwarzania danych. Lider i współzałożyciel grupy bydgosko-toruńskiej Data Community. Na co dzień pracuje jako Data Architekt w firmie SoftwareOne odpowiadając za architekturę u jednego z głównych klientów. Pasjonat danych i technologii MS lubiący dzielić się swoją wiedzą, pasją zarówno na spotkaniach grup lokalnych jak również na konferencjach związanych z SQLServer.', N'https://www.linkedin.com/in/tomaszwaloszek/', NULL, NULL, NULL, NULL, NULL),
(130, 5, N'SQL Server Consultant', N'Peter is a SQL Consultant at Monin-IT who enjoys working across the full spectrum of SQL Server since 2010, though he likes the performance tuning the most. Since stepping into the speaker scene in 2023, he has shared his knowledge at events like SQLBits and SQL/Data Saturday. Peter’s sessions are known for being informative, demo-filled and delivered with an approachable style that is very suitable for newcomers and accidental DBA''s. Whether it’s diving into wait stats, tackling tricky query plans, or just having a laugh while learning something new; Peter is always up for making SQL a little more fun.', NULL, NULL, NULL, NULL, NULL, NULL),
(131, 6, N'The Power BI Kinda Guy', N'With a background across ERP systems including Epicor ERP, Microsoft Dynamics 365, Infor Visual, and Sage 200, Duncan brings a deep understanding of how data flows through businesses. He focuses on reporting that reflects real operational processes, not just what looks good in a dashboard.

He works across Power BI, Dataverse, Power Apps, and Power Automate, with a particular interest in report design, semantic models, governance, and building systems that scale.

Outside of client work, Duncan runs the Norfolk Power Platform User Group and is the founder of the East of England Power Platform Summit, creating spaces for people at all levels to learn, connect, and grow.

Outside of tech, he’s a dad of two, usually being outnumbered at home by kids and a dog. When he does get a bit of time, it’s spent gaming, reading, getting lost in manga, or listening to music that most people would describe as “a bit aggressive.”', NULL, NULL, NULL, NULL, NULL, NULL),
(132, 3, N'Making stuff with SQL Server, C# and Swift. Monday lover.', N'Mladen Prajdić is a Data Platform MVP from Slovenia. He''s been programming for 20 years, developing diﬀerent types of applications in .Net (C#) and SQL Server, ranging from standard line-of-business, image-processing applications to high performance and IoT applications. He''s a regular speaker at various conferences and usergroup meetings, really likes to optimize slow SQL statements, analyze performance, and find unconventional solutions to difficult SQL Server problems. In his free time, he also develops a very popular add-in for SSMS, called the SSMS Tools Pack (www.ssmstoolspack.com).', N'https://www.linkedin.com/in/mladenprajdic', N'https://twitter.com/MladenPrajdic', N'https://www.ssmstoolspack.com/', NULL, NULL, NULL),
(132, 6, N'Making stuff with SQL Server and C#. Monday lover.', N'Mladen Prajdić is a Data Platform MVP from Slovenia. He''s been programming for over 25 years, developing diﬀerent types of applications in .Net (C#) and SQL Server, ranging from standard line-of-business, image-processing applications to high performance and IoT applications. He''s a regular speaker at various conferences and usergroup meetings, really likes to optimize slow SQL statements, analyze performance, and find unconventional solutions to difficult SQL Server problems. In his free time, he also develops a very popular add-in for SSMS, called the SSMS Tools Pack (www.ssmstoolspack.com).', NULL, NULL, NULL, NULL, NULL, NULL),
(133, 1, N'Principal Program Manager, Microsoft', N'Chris Webb is a member of the Fabric Customer Advisory Team at Microsoft', N'https://www.linkedin.com/in/chriswebb6/', N'https://twitter.com/cwebb_bi', N'https://www.microsoft.com', N'https://blog.crossjoin.co.uk/', NULL, NULL),
(134, 2, N'Microsoft BI architect, trainer, speaker and MVP | twoday', N'BI architect with extensive experience in all phases of BI development on Microsoft SQL Server, Azure, Fabric and Power BI. Founder and coordinator of Microsoft Business Intelligence Professionals Denmark (MsBIP.dk) and Power BI UG Denmark (PowerBI.dk). Is a Microsoft Certified Trainer.', N'https://linkedin.com/in/blindbaek', NULL, N'https://justB.dk', N'https://justB.dk/blog/', NULL, NULL),
(134, 3, N'Microsoft BI architect, trainer, speaker and MVP', N'BI architect with extensive experience in all phases of BI development on Microsoft SQL Server, Azure, Fabric and Power BI. Founder and coordinator of Microsoft Business Intelligence Professionals Denmark (MsBIP.dk) and Power BI UG Denmark (PowerBI.dk). Is a Microsoft Certified Trainer.', N'https://linkedin.com/in/blindbaek', NULL, N'https://justB.dk', N'https://justB.dk/blog/', NULL, NULL),
(135, 1, N'EPAM Systems', N'Power BI consultant with 10+ years of experience in providing innovative BI solutions for a wide range of clients. Extensive knowledge of Power BI, including advanced reporting and data modeling.', NULL, NULL, NULL, NULL, NULL, NULL),
(136, 2, N'Business Unit Consulting Lead @ Clouds On Mars', N'Patryk currently holds the position of Business Unit Consulting Lead at Clouds On Mars, where he oversees the delivery of Business Intelligence solutions, with a primary focus on the Microsoft technology stack, for Customers across diverse industries.

Dedicated to professional growth, Patryk actively pursues opportunities for continuous learning, striving to expand his knowledge and further enhance his expertise through the attainment of relevant certifications.

He is passionate about developing robust backend ETL and data warehouse solutions and then visualizing the results through user-friendly, interactive Power BI dashboards.', N'https://www.linkedin.com/in/prozenek/', NULL, NULL, NULL, NULL, NULL),
(137, 2, N'Cloud Data Engineer & Technical Leader @ Datumo', N'Inżynier danych oraz lider techniczny w Datumo. Swoją karierę zadedykował obszarom AI/ML, urządzeniom brzegowym oraz IoT. Zawodowo związany z projektowaniem oraz wdrażaniem rozwiązań opartych głównie na chmurze Azure. Zwolennik sztucznej inteligencji zorientowanej na dane (Data-centric AI). Prywatnie miłośnik zwierząt, gier komputerowych oraz majsterkowania.', N'https://www.linkedin.com/in/maciej-kepa/', NULL, N'https://www.datumo.io', N'https://maciejkepa.dev/', NULL, NULL),
(137, 3, N'Data Architect @ Datumo', N'Senior Data Engineer and Data Architect at Datumo. He has dedicated his career to the fields of AI/ML, edge devices, and IoT. Professionally focused on designing and implementing solutions primarily based on the Azure cloud. A strong advocate of data-centric AI. Privately, an animal lover, gaming enthusiast, and DIY hobbyist.', N'https://www.linkedin.com/in/maciej-kepa/', NULL, N'https://www.datumo.io', N'https://maciejkepa.dev/', NULL, NULL),
(137, 4, N'Cloud Data Engineer & Technical Leader @ Datumo', N'Inżynier danych oraz lider techniczny w Datumo. Swoją karierę zadedykował obszarom AI/ML, urządzeniom brzegowym oraz IoT. Zawodowo związany z projektowaniem oraz wdrażaniem rozwiązań opartych głównie na chmurze Azure. Zwolennik sztucznej inteligencji zorientowanej na dane (Data-centric AI). Prywatnie miłośnik zwierząt, gier komputerowych oraz majsterkowania.', NULL, NULL, NULL, NULL, NULL, NULL),
(137, 5, N'Cloud Data Engineer & Technical Leader @ Datumo', N'Inżynier danych oraz lider techniczny w Datumo. Swoją karierę zadedykował obszarom AI/ML, urządzeniom brzegowym oraz IoT. Zawodowo związany z projektowaniem oraz wdrażaniem rozwiązań opartych głównie na chmurze Azure. Zwolennik sztucznej inteligencji zorientowanej na dane (Data-centric AI). Prywatnie miłośnik zwierząt, gier komputerowych oraz majsterkowania.', NULL, NULL, NULL, NULL, NULL, NULL),
(137, 6, N'Data Architect @ Datumo', N'Senior Data Engineer and Data Architect at Datumo, specializing in production-grade data and AI platforms built primarily on Azure and Databricks. His work sits at the intersection of data engineering, MLOps, cloud architecture, and industrial IoT - from edge data collection to reliable ML systems in production.

He is particularly interested in data-centric AI, practical architecture patterns, and everything that happens beyond the notebook: deployment, observability, governance, and ownership. Maciej shares his experience through technical writing, conference talks, and community events. He writes about MLOps, production AI, and data architecture at https://maciejkepa.dev.

He is also one of the members of Data Community Poland and organization crew of SQLDay conference. Outside of technology, he is an animal lover, gaming enthusiast, and dedicated DIY hobbyist.', NULL, NULL, NULL, NULL, NULL, NULL),
(138, 1, N'Big Data/Data Warehouse Evangelist at Microsoft', N'James is a big data and data warehousing solution architect at Microsoft where he has been for most of the last eight years.  He is a thought leader in data architectures, big data, and advanced analytics.  Prior to that he was an independent consultant working as a Data Warehouse/Business Intelligence architect and developer.  He is a prior Microsoft SQL Server MVP with over 35 years of IT experience.  He has a popular blog at JamesSerra.com and presents at many major data platform events including SQLBits, PASS Summit, PASS Business Analytics conference and the Enterprise Data World conference.  He is the author of the book “Reporting with Microsoft SQL Server 2012”.', N'https://www.linkedin.com/in/JamesSerra/', N'https://twitter.com/JamesSerra', NULL, N'http://www.jamesserra.com/', NULL, NULL),
(139, 2, N'Project Leader', N'I''m a senior data engineer and team leader at Datumo, where we develop and manage big data platforms for clients representing various domains. My main fields of specialization are platform architecture and data-oriented software engineering', N'https://www.linkedin.com/in/wojciech-pratkowiecki/', NULL, N'https://www.datumo.io', NULL, NULL, NULL),
(140, 2, N'Senior Product Manager at Microsoft', N'Sasa Popovic is a Product Manager in Azure SQL team, with a focus on data mobility scenarios, distributed transactions and replication. Previously, for 10 years worked as a software engineer on SQL Server and Azure SQL features such as Window Functions, Query Store and SQL MI time zones. Sasa is active on LinkedIn (linkedin.com/in/sasapopovic/), Twitter (x.com/SasaPopovicMSFT) and BlueSky (bsky.app/profile/sasapopovicsql.bsky.social).', N'https://www.linkedin.com/in/sasapopovic/', N'https://twitter.com/SasaPopovicMSFT', N'https://azure.microsoft.com/en-us/', N'https://aka.ms/sasapopoblog', NULL, NULL),
(141, 5, N'BI Consultant', N'I work at Cogit as a consultant. I''m responsible for supporting clients in the design and implementation of business intelligence tools, databases, data warehouses, and data integration. I''ve been involved with data and its business applications since the beginning of my career, working as a data analyst. I currently work on projects for key Cogit clients, including application development and modeling.', NULL, NULL, NULL, NULL, NULL, NULL),
(141, 6, N'BI Consultant', N'I work at Cogit as a consultant. I''m responsible for supporting clients in the design and implementation of business intelligence tools, databases, data warehouses, and data integration. I''ve been involved with data and its business applications since the beginning of my career, working as a data analyst. I currently work on projects for key Cogit clients, including application development and modeling.', NULL, NULL, NULL, NULL, NULL, NULL),
(142, 1, N'Power BI Consultant & Trainer, Senior BI Developer at Kearney', N'Grzegorz (feel free to call him Greg) is a Senior BI Developer at Kearney Warsaw. He serves as a Power BI technical Team Lead for the Business Intelligence team in Poland.

He has proved his lecturing and teaching skills by running Power BI community events as well as internal trainings at Kearney at all levels, ranging in audience size from 5 to 250. Greg has been leading a number of Power BI workshops aimed at experienced professionals, students as well people willing to explore the art of possible in Business Intelligence. He has experience at conveying his knowledge at various levels, ranging from beginner to expert.

Greg holds a number of Microsoft Certifications including Power BI - related ones: PL-300, DA-100 and 70-778.', N'https://www.linkedin.com/in/grzegorz-strzymiński/', NULL, N'https://www.youtube.com/@GregWorksPowerBI', N'https://www.youtube.com/@GregWorksPowerBI', NULL, NULL),
(142, 2, N'Power BI Consultant & Trainer', N'Greg is a Senior BI Developer at Kearney Warsaw. He serves as a Power BI technical Team Lead for the Business Intelligence team in Poland.

He has proved his lecturing and teaching skills by running Power BI community events as well as internal trainings at Kearney at all levels, ranging in audience size from 5 to 250. Greg has been leading a number of Power BI workshops aimed at experienced professionals, students as well people willing to explore the art of possible in Business Intelligence. He has experience at conveying his knowledge at various levels, ranging from beginner to expert.

Greg holds a number of Microsoft Certifications including Power BI - related ones: PL-300, DA-100 and 70-778.', N'https://www.linkedin.com/in/grzegorz-strzymiński/', NULL, N'https://www.youtube.com/@GregWorksPowerBI', N'https://www.youtube.com/@GregWorksPowerBI', NULL, NULL),
(142, 5, N'Power BI Consultant & Trainer', N'Greg is a Business Intelligence Team Lead at Kearney Warsaw. He serves as a Power BI technical Lead for Kearney.

He has proved his lecturing and teaching skills by running Power BI community events as well as internal trainings at Kearney at all levels, ranging in audience size from 5 to 250. Greg has been leading a number of Power BI workshops aimed at experienced professionals, students as well people willing to explore the art of possible in Business Intelligence. He has experience at conveying his knowledge at various levels, ranging from beginner to expert.

Greg holds a number of Microsoft Certifications including those in Fabric: DP-600 and Power BI: PL-300, DA-100 and 70-778.', NULL, NULL, NULL, NULL, NULL, NULL),
(143, 2, N'Future Processing, Senior Cloud Data Engineer', N'Experienced Data Engineer specializing in designing and implementing advanced data processing, migration solutions and data warehouses. He works on complex projects that integrate various technologies such as Python, SQL Server, Snowflake, and Azure cloud.', N'https://www.linkedin.com/in/konrad-sarnecki-1b360380/', NULL, N'https://www.future-processing.com/', NULL, NULL, NULL),
(144, 1, N'Data Masterminds, PowerShell Underdog', N'Sander is a SQL Server DBA with over 20 years of experience in IT. He has worked with SQL Server since version 2000 and is a Cloud and Datacenter Management (CDM) MVP.
He is a huge PowerShell enthusiast and will try to automate processes as much as he can.', N'https://www.linkedin.com/in/sanderstad/', N'https://twitter.com/SQLStad', N'https://sqlstad.nl', N'https://sqlstad.nl', NULL, NULL),
(145, 2, N'Analytics Engineer @ Datumo', N'I’m a dbt and Snowflake advocate among Datumo and our clients. I use my analytics engineering and BI skills to transform the data and present meaningful insights to business users. Enthusiast of open source solutions and BI as a code. Certified dbt and Snowflake developer.', N'https://www.linkedin.com/in/przemys%C5%82aw-sapkowski-704769134', NULL, N'https://www.datumo.io/', N'https://www.datumo.io/blog', NULL, NULL),
(146, 1, N'Program Manager - Security & Governance Azure Database Platform', N'Pieter Vanhove is a Program Manager in the Security & Governance Azure Database Platform team at Microsoft. He is the feature PM for ledger and Always Encrypted which is all about bringing the power of Blockchain to SQL Server and data encryption. He has been working with SQL Server since 2000. Pieter has a profound knowledge in data security and loves the new Azure stuff. He is also a regular speaker at Belgian and international events.', NULL, N'https://twitter.com/Pieter_Vanhove', NULL, NULL, NULL, NULL),
(147, 1, N'Data Engineering manager', N'Data Engineering manager for Avanade Netherlands. Originally from the UK and now living in the Netherlands. Dual-category Microsoft MVP for both Data Platform and Developer Technologies.

Many years experience in the IT sector, and has supported platforms for companies in the top 10 of the fortune 500 list.

In addition to a lot of experience with the Microsoft Data Platform, also has over twenty Microsoft Certifications. Microsoft Certified Trainer and was probably the last ever person in the world to gain the MCSD Azure Architect certification.

Real life experience with Microsoft Data Platform and Azure Devops. Held various roles, including being SQL Server Product Owner of around 1,900 SQL Server instances. In addition, done various things for the Data Platform Community. Including blogs, MVP videos, event organizer and sharing public GitHub repos GitHub .', N'https://www.linkedin.com/in/kevin-r-chant', N'https://x.com/kevchant', NULL, N'https://www.kevinrchant.com', NULL, NULL),
(147, 4, N'Data Engineering manager', N'Data Engineering manager for Avanade Netherlands. Originally from the UK and now living in the Netherlands. Microsoft Certified Trainer and dual-category Microsoft MVP for both Data Platform and Developer Technologies.

Many years experience in the IT sector, including supporting companies in the top 10 of the fortune 500 list.

In addition to a lot of experience with the Microsoft Data Platform, also has over twenty Microsoft Certifications.

Real life experience with various Microsoft Data Platform offerings and Azure Devops. Held various roles; including Team Leader, SQL Server Product Owner, certification coach and Solution Architect.

In addition, involved with Data Platform Community in various ways. Including blogs, MVP videos, event organizer and sharing various repositories in GitHub.', NULL, NULL, NULL, NULL, NULL, NULL),
(148, 2, N'Suffers from chronic curiosity', N'Johan Ludvig Brattås is a director at Deloitte, and a dedicated community guy. He has worked with MS SQL server since late 1999, mostly with BI in one form or another. Since 2015, most of his work has been in the cloud working on data platform services such as Snowflake, Databricks and Synapse.

Combining his passion for MS SQL Server with his passion for sharing knowledge, he started speaking at various events in the SQL Community. This is also a way to give back to the community for all the things he has learned over the years. When not working, Johan Ludvig either spends his time with his kids, playing with new technology or  teaching coeliacs how to bake glutenfree food.', N'https://www.linkedin.com/in/johanludvig/', NULL, NULL, NULL, NULL, NULL),
(149, 6, N'Future Processing, Business Intelligence Consultant, PhD', N'Business Intelligence Consultant and Data Analytics leader with 15 years of experience bridging academic research and
commercial enterprise execution. Ph.D. in Business Intelligence area and published author of a scientific book on BI systems and profitability
optimization. Proven track record (15 years) of advising C-level stakeholders, defining enterprise data roadmaps, and leading
specialized technical teams to deliver scalable BI ecosystems. Highly experienced in translating complex financial and
operational metrics into actionable executive intelligence for large organizations across the USA and Europe. Leveraging
modern platforms (like Palantir AIP) to drive AI-powered operational efficiency. Married and father of two sons. Passionate about travel.', NULL, NULL, NULL, NULL, NULL, NULL),
(150, 4, N'High school student', N'IT profile student and conference volunteer', NULL, NULL, NULL, NULL, NULL, NULL),
(151, 2, N'Snowflake Evangelist, Snowflake Data SuperHero', N'Snowflake Evangelist at Infinite Services, Snowflake Data SuperHero.
Teacher at Warsaw School of Computer Science.
Specializes in the design and implementation of data warehouse solutions and ETL/ELT processes. Explorer and passionate about cloud solutions, speaker at conferences on data processing technologies, trainer. In love with the Snowflake platform from the first click. His activities in the Snowflake community earned him the title of Snowflake Community Data SuperHero. In his spare time, he loves tuning and optimizing database engines to their limits.', N'https://www.linkedin.com/in/michal-golos', NULL, N'https://infinite-services.com', N'https://www.youtube.com/channel/UCbLHJnpfviOpKNRiCh72brg', NULL, NULL),
(151, 3, N'Snowflake Evangelist, Snowflake Data SuperHero', N'Snowflake Evangelist at Infinite Services, Snowflake Data SuperHero.
Teacher at Warsaw School of Computer Science.
Specializes in the design and implementation of data warehouse solutions and ETL/ELT processes. Explorer and passionate about cloud solutions, speaker at conferences on data processing technologies, trainer. In love with the Snowflake platform from the first click. His activities in the Snowflake community earned him the title of Snowflake Community Data SuperHero. In his spare time, he loves tuning and optimizing database engines to their limits.', N'https://www.linkedin.com/in/michal-golos', NULL, N'https://infinite-services.com', N'https://www.youtube.com/channel/UCbLHJnpfviOpKNRiCh72brg', NULL, NULL),
(151, 4, N'Snowflake Evangelist, Snowflake Data SuperHero', N'Snowflake Evangelist at Infinite Services, Snowflake Data SuperHero.
Teacher at Warsaw School of Computer Science.
Specializes in the design and implementation of data warehouse solutions and ETL/ELT processes. Explorer and passionate about cloud solutions, speaker at conferences on data processing technologies, trainer. In love with the Snowflake platform from the first click. His activities in the Snowflake community earned him the title of Snowflake Community Data SuperHero. In his spare time, he loves tuning and optimizing database engines to their limits.', NULL, NULL, NULL, NULL, NULL, NULL),
(152, 6, N'C&F, Senior Azure Solution Architect', N'Od ponad 10 lat działam w obszarze danych, chmury i architektury rozwiązań. Specjalizuję się w projektowaniu platform danych opartych o Azure i Databricks, ze szczególnym naciskiem na bezpieczeństwo, governance, skalowalność, automatyzację oraz dobre praktyki inżynierii danych.

Jestem entuzjastą Azure, Databricks i szeroko pojętego świata Data & IT. Lubię łączyć perspektywę architekta i data engineera — od projektowania architektury, przez standardy i CI/CD, po realne wyzwania związane z utrzymaniem platform danych w dużych organizacjach. Szczególnie interesują mnie Lakehouse, Medallion Architecture, Unity Catalog, automatyzacja infrastruktury i governance w środowiskach danych.', NULL, NULL, NULL, NULL, NULL, NULL),
(153, 3, N'Data Architect at Intapp', N'Denis works as a Data Architect at Intapp, Inc. He has a wide experience in the development of the applications, databases and other solutions based on data. Denis is a Microsoft Data Platform MVP since 2010 and PASS Regional Mentor for Central and Eastern Europe since 2016. He loves to speak about SQL Server and Data at conferences and user-group meetings and actively participates in the development of SQL Community.', N'https://www.linkedin.com/in/denis-reznik-2345023/', N'https://twitter.com/DenisReznik', N'https://www.intapp.com/', NULL, N'https://www.facebook.com/denis.reznik.5', NULL),
(154, 3, N'SoftFit, CEO', N'Ponad 30 lat pracy w branży IT na stanowiskach CIO, CTO, CEO. Od 9 lat prowadzę własne firmy, w tym startup. Wytwarzamy systemy business intelligence w oparciu o Microsoft stack, oprogramowanie do wspierania branży e-commerce.', N'https://www.linkedin.com/in/s%C5%82awomir-malinowski-bb6459121/', NULL, NULL, NULL, NULL, NULL),
(155, 2, N'Senior Data Engineer', N'Senior Data Engineer, pasjonat danych i AI, zawodowo pracuje przy analizie danych, procesów ETL oraz implementacji hurtowni danych. Od 8 lat związany z serverami MS SQL Server, a od 5 lat z chmura Azure.', N'https://pl.linkedin.com/in/krzysztof-burejza', NULL, NULL, NULL, NULL, NULL),
(155, 4, N'Senior Data Engineer', N'Senior Data Engineer, pasjonat danych i AI, zawodowo pracuje przy analizie danych, procesów ETL oraz implementacji hurtowni danych. Od 8 lat związany z serverami MS SQL Server, a od 5 lat z chmura Azure.', NULL, NULL, NULL, NULL, NULL, NULL),
(155, 5, N'Azure Data Engineer', N'Specjalizuję się w inżynierii danych, projektowaniu procesów ETL oraz implementacji nowoczesnych hurtowni danych w ekosystemie Microsoft. Na co dzień pracuję jako Data Engineer i specjalista od baz danych, wykorzystując technologie takie jak Azure Data Factory, Synapse Analytics, Databricks, MS SQL Server i MS Fabric do tworzenia skalowalnych i wydajnych rozwiązań opartych na danych.

Aktywnie angażuję się w społeczność data & AI jako lider Data Community w Bielsku-Białej, organizując meetupy oraz dzieląc się wiedzą na temat analizy danych, chmury i sztucznej inteligencji.', NULL, NULL, NULL, NULL, NULL, NULL),
(155, 6, N'Senior Data Engineer & Solution Architect | Databricks, Azure & AI', N'Krzysztof Burejza is a Resident Solutions Architect at Databricks Professional Services and a Senior Data Engineer with over 10 years of experience designing, building and modernizing enterprise data platforms. He specializes in Databricks, Microsoft Fabric and Azure, helping organizations build scalable lakehouse architectures, high-performance data pipelines and AI-ready data platforms.

Throughout his career, he has delivered projects across finance, pharmaceuticals, automotive, manufacturing and media, covering large-scale cloud migrations, platform modernization, governance, performance optimization and advanced analytics. His work focuses on translating complex business requirements into secure, scalable and production-ready data solutions.

Krzysztof is a Microsoft Certified Trainer (MCT) and holds Databricks Professional and Generative AI certifications. As part of Databricks Professional Services, he supports enterprise customers in architecting and adopting modern Data Intelligence Platform solutions, while also sharing best practices around data engineering, governance and AI.

Beyond his consulting work, Krzysztof founded Data Community Podbeskidzie, where he organizes regular meetups and contributes to the local technology community. He is a frequent conference speaker, delivering sessions on Databricks, Microsoft Fabric, Azure, data engineering and applied AI. His current interests include lakehouse architecture, platform engineering, DataOps and building production-grade AI-powered data platforms.', NULL, NULL, NULL, NULL, NULL, NULL),
(156, 1, N'Senior Azure Solutions Engineer', N'Senior Azure Data Engineer and consultant specializing in building Business Intelligence solutions on the Microsoft platform. Member of the Data Community Poland board and leader of the Bydgoszcz & Toruń branch.', N'https://www.linkedin.com/in/mariusz-wojcik/', NULL, N'https://candf.com/', NULL, N'https://www.facebook.com/Wojcik.Mariusz', NULL),
(156, 2, N'Senior Azure Architect', N'Senior Azure Architect specializing in designing and implementing scalable, modern data platforms based on Microsoft Azure.
With extensive experience in database design, big data processing, and analytical solutions, he helps organizations build efficient and future-proof data infrastructures.
Actively engaged in the IT community, he serves as a board member of Data Community Poland and leads the Bydgoszcz and Toruń chapters.
He is involved in organizing industry events and speaks at conferences, sharing his expertise on databases, analytics, and cloud solutions.', N'https://www.linkedin.com/in/mariusz-wojcik/', NULL, N'https://candf.com/', NULL, N'https://www.facebook.com/Wojcik.Mariusz', NULL),
(156, 3, N'Senior Azure Architect | Board Member of Data Community Poland', N'Senior Azure Architect specializing in designing and implementing scalable, modern data platforms based on Microsoft Azure.
With extensive experience in database design, big data processing, and analytical solutions, he helps organizations build efficient and future-proof data infrastructures.
Actively engaged in the IT community, he serves as a board member of Data Community Poland and leads the Bydgoszcz and Toruń chapters.
He is involved in organizing industry events and speaks at conferences, sharing his expertise on databases, analytics, and cloud solutions.', N'https://www.linkedin.com/in/mariusz-wojcik/', NULL, N'https://candf.com/', NULL, N'https://www.facebook.com/Wojcik.Mariusz', NULL),
(156, 4, N'Azure Senior Data Engineer', N'Senior Azure Data Engineer and consultant specializing in building Business Intelligence solutions on the Microsoft platform. Member of the Data Community Poland board and leader of the Bydgoszcz & Toruń branch.', NULL, NULL, NULL, NULL, NULL, NULL),
(156, 5, N'Senior Azure Architect | Board Member of Data Community Poland', N'Senior Azure Architect specializing in designing and implementing scalable, modern data platforms based on Microsoft Azure.
With extensive experience in database design, big data processing, and analytical solutions, he helps organizations build efficient and future-proof data infrastructures.
Actively engaged in the IT community, he serves as a board member of Data Community Poland and leads the Bydgoszcz and Toruń chapters.
He is involved in organizing industry events and speaks at conferences, sharing his expertise on databases, analytics, and cloud solutions.', NULL, NULL, NULL, NULL, NULL, NULL),
(156, 6, N'Senior Azure Architect | Board Member of Data Community Poland', N'Senior Azure Architect specializing in designing and implementing scalable, modern data platforms based on Microsoft Azure.
With extensive experience in database design, big data processing, and analytical solutions, he helps organizations build efficient and future-proof data infrastructures.
Actively engaged in the IT community, he serves as a board member of Data Community Poland and leads the Bydgoszcz and Toruń chapters.
He is involved in organizing industry events and speaks at conferences, sharing his expertise on databases, analytics, and cloud solutions.', NULL, NULL, NULL, NULL, NULL, NULL),
(157, 5, N'SQL Server specialist, Data Platform MVP, SQL Community organizer. Paid work out of Transmokopter SQL AB.', N'Magnus works as an independent SQL Server consultant at his company Transmokopter SQL AB, with everything from on-premise to cloud databases, from database design and T-SQL programming to infrastructure planning and administration, from transaction intensive databases to data warehousing workloads.
When paid work stops, community work starts. Magnus is a long time co-leader for SQL Server User Group Sweden, he''s organising SQL Friday every Friday noon and he''s speaking and volunteering on data events, small and large. In October 2020, Magnus was awarded the Microsoft Data Platform MVP award.', NULL, NULL, NULL, NULL, NULL, NULL),
(158, 3, N'Erland Sommarskog SQL-Konsult AB', N'Erland Sommarskog is an independent consultant based in Stockholm. He has worked with SQL Server since 1991. He was first awarded SQL Server MVP in 2001, and he has been re-awarded every year since. His focus is on systems development with the SQL Server Database Engine and his passion is to help people to write better SQL Server applications.', NULL, NULL, N'https://www.sommarskog.se', N'https://www.sommarskog.se', NULL, NULL),
(158, 4, N'Erland Sommarskog SQL-Konsult AB', N'Erland Sommarskog is an independent consultant based in Stockholm. He has worked with SQL Server since 1991. He was first awarded SQL Server MVP in 2001, and he has been re-awarded every year since. His focus is on systems development with the SQL Server Database Engine and his passion is to help people to write better SQL Server applications.', NULL, NULL, NULL, NULL, NULL, NULL),
(158, 5, N'Erland Sommarskog SQL-Konsult AB', N'Erland Sommarskog is an independent consultant based in Stockholm. He has worked with SQL Server since 1991. He was first awarded SQL Server MVP in 2001, and he has been re-awarded every year since. His focus is on systems development with the SQL Server Database Engine and his passion is to help people to write better SQL Server applications.', NULL, NULL, NULL, NULL, NULL, NULL),
(158, 6, N'Erland Sommarskog SQL-Konsult AB', N'Erland Sommarskog is an independent consultant based in Stockholm. He has worked with SQL Server since 1991. He was first awarded SQL Server MVP in 2001, and he has been re-awarded every year since. His focus is on systems development with the SQL Server Database Engine and his passion is to help people to write better SQL Server applications.', NULL, NULL, NULL, NULL, NULL, NULL),
(159, 1, N'Senior Program Manager / PBICAT', N'Gabi Münster (she / her) started working with SQL Server technologies in 2005. After some short excursions into Web Application development and a long and inspiring time as a BI consultant / Data architect at oh22data AG (including experiencing being a Data Platform MVP), she joined Microsoft as a Senior Program Manager at the Fabric CAT team in March 2022.
She speaks at regional chapter meetings, national and international conferences. Since 2016 she also supports a regional chapter as co-lead.
Apart from BI topics she also supports Diversity topics.', N'https://www.linkedin.com/in/gabimuenster/', N'https://twitter.com/SQLMissSunshine', N'https://www.microsoft.com/de-de/about', NULL, NULL, NULL),
(160, 3, N'Team Leader Data Engineering, Phronesis Path', N'Inżynier danych specjalizujący się w budowie skalowalnych platform i automatyzacji procesów ETL. Tworzę rozwiązania, które przyspieszają dostęp do informacji, poprawiają ich jakość i wspierają rozwój produktów oraz usług. Dzięki doświadczeniu zdobytemu we współpracy z klientami z wielu branż oraz dogłębnemu zrozumieniu aspektów biznesowych i technicznych, potrafię projektować systemy, które są wydajne, przemyślane i odpowiadają rzeczywistym potrzebom organizacji.', N'https://www.linkedin.com/in/micha%C5%82-g%C3%B3ra-566497256/', NULL, N'https://www.phronesispath.com/pl/homepage-pl/', NULL, NULL, NULL);
COMMIT TRANSACTION;
GO



ALTER DATABASE SQLDayDemo
SET MULTI_USER;
GO

