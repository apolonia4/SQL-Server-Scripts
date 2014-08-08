/*This example is from the following blog post:
--See blog post for details:  
http://sqlserverpedia.com/blog/sql-server-bloggers/corrupting-databases-for-dummies-hex-editor-edition/
*/
USE master;
IF db_id('CorruptMe') IS NOT NULL
BEGIN
	ALTER DATABASE CorruptMe SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE CorruptMe
END

CREATE DATABASE CorruptMe;
GO

--Make sure we're using CHECKSUM as our page verify option
--I'll talk about other settings in a later post.

ALTER DATABASE CorruptMe SET PAGE_VERIFY CHECKSUM;

USE CorruptMe;

--Insert some dead birdies
CREATE TABLE dbo.DeadBirdies (
    birdId INT NOT NULL ,
    birdName NVARCHAR(256) NOT NULL,
    rowCreatedDate DATETIME2(0) NOT NULL )

;WITH
  Pass0 AS (SELECT 1 AS C UNION ALL SELECT 1),
  Pass1 AS (SELECT 1 AS C FROM Pass0 AS A, Pass0 AS B),
  Pass2 AS (SELECT 1 AS C FROM Pass1 AS A, Pass1 AS B),
  Pass3 AS (SELECT 1 AS C FROM Pass2 AS A, Pass2 AS B),
  Pass4 AS (SELECT 1 AS C FROM Pass3 AS A, Pass3 AS B),
  Pass5 AS (SELECT 1 AS C FROM Pass4 AS A, Pass4 AS B),
  Tally AS (SELECT ROW_NUMBER() OVER(ORDER BY C) AS NUMBER FROM Pass5)
INSERT dbo.DeadBirdies (birdId, birdName, rowCreatedDate)
SELECT NUMBER AS birdId ,
    'Tweetie9999999999' AS birdName ,
    DATEADD(mi, NUMBER, '2000-01-01')
FROM Tally
WHERE NUMBER <= 500000

--Cluster on BirdId.
CREATE UNIQUE CLUSTERED INDEX cxBirdsBirdId ON dbo.DeadBirdies(BirdId)
--Create a nonclustered index on BirdName
CREATE NONCLUSTERED INDEX ncBirds ON dbo.DeadBirdies(BirdName)
GO


DBCC IND ('CorruptMe', 'DeadBirdies', 0)
--Turn on a trace flag to have the output of DBCC PAGE return in management studio
--Otherwise it goes to the error log
DBCC TRACEON (3604);
GO
DBCC PAGE('CorruptMe', 1,3592,3);


--Take database offline
USE master;
ALTER DATABASE CorruptMe SET OFFLINE;


SELECT physical_name FROM sys.master_files WHERE name='CorruptMe';

--Determine page offset, this is page number multiplied by number of bytes on a page
SELECT 3592*8192 AS [My Offset]

--Open .mdf file in hex editor and corrupt a data page
--See blog post for details:  http://sqlserverpedia.com/blog/sql-server-bloggers/corrupting-databases-for-dummies-hex-editor-edition/

--Bring db back online
ALTER DATABASE CorruptMe SET ONLINE;

--Run a query that will use non clustered index
USE CorruptMe;
SELECT birdName FROM dbo.deadBirdies;


DBCC CHECKDB('CorruptMe') WITH PHYSICAL_ONLY