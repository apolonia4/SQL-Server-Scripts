USE master
GO

set ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--iterate through DBs
DECLARE @DbNames TABLE (
rowNum int identity (1,1),
dbname sysname NOT NULL )

INSERT INTO @DbNames
SELECT name
FROM sys.databases
WHERE state=0 AND user_access=0 and has_dbaccess(name) = 1
AND [name] NOT LIKE '%tempdb%'
ORDER BY [name]

DECLARE @EndCount int;
SELECT @EndCount = count(*) FROM @DbNames

DECLARE @RowCounter int;
SELECT @RowCounter = 1;

DECLARE @DbName varchar(20);
DECLARE @sql varchar(2000);

WHILE (@RowCounter <= @EndCount)
BEGIN
SELECT @DbName = dbname FROM @DbNames WHERE @RowCounter = rowNum;
Print @Dbname
--SELECT @sql ='use' + @DbName --do something here…
--EXEC (@sql)
--PRINT @sql
SELECT @RowCounter = @RowCounter + 1
END