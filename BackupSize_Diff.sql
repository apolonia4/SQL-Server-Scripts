use tempdb
go
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('#localtemp') 
AND type = 'U')
DROP TABLE #localtemp
GO

use BackupsizeTracking
go
create table #localtemp
(
diff decimal(9,2)
, databasename varchar(100)
, ServerIP varchar(100)
)

declare @databases table
(
Id int identity(1,1)
, Name varchar(100)
, IP varchar(50)
)


INSERT INTO @databases
select distinct(chvdatabasename), chvServerIP from tbllogresult
group by chvserverip, chvdatabasename




DECLARE @RowCount INT
SET @RowCount = (SELECT COUNT(*) FROM @databases) 

-- Declare an iterator
DECLARE @I INT
-- Initialize the iterator
SET @I = 1

-- Loop through the rows of a table @myTable
WHILE (@I <= @RowCount)
BEGIN

DECLARE @mindate as datetime
DECLARE @maxdate as datetime

declare @database varchar(100) = (select name from @databases where id = @I)
declare @IP varchar(50) = (Select IP from @databases where id = @I)


SET @mindate = (select min(dtmstatistics) from tbllogresult where chvDatabaseName = @database and chvServerIP = @IP)
SET @maxdate = (select max(dtmstatistics) from tbllogresult where chvDatabaseName = @database and chvServerIP = @IP)

DECLARE @minsize as decimal(9,2)
DECLARE @maxsize as decimal(9,2)

SET @minsize = (select chvDatabaseBackupSizeMB from tblLogResult where dtmStatistics = @mindate AND (chvDatabaseName = @database and chvServerIP = @IP))
SET @maxsize = (select chvDatabaseBackupSizeMB from tblLogResult where dtmStatistics = @maxdate AND (chvDatabaseName = @database and chvServerIP = @IP))


insert into #localtemp
select @maxsize - @minsize, @database, @IP


        SET @I = @I  + 1
END


select top 20 * From #localtemp order by diff desc

--drop table #localtemp