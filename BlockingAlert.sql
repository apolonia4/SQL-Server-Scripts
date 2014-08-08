Select * from sysprocesses where blocked>0
go
Select spid into #temp_blockedspid from sysprocesses where blocked > 0
go

DECLARE @RowCount INT
SET @RowCount = (SELECT COUNT(*) FROM #temp_blockedspid)

-- Declare an iterator
DECLARE @I INT
-- Initialize the iterator
SET @I = 1

-- Loop through the rows of a table @myTable
WHILE (@I <= @RowCount)
BEGIN
DECLARE @Handle binary(20)
SELECT @Handle = sql_handle FROM master.dbo.sysprocesses WHERE spid =  (SELECT spid FROM #temp_blockedspid)
SELECT spid FROM #temp_blockedspid
SELECT * FROM ::fn_get_sql(@Handle)

  SET @I = @I  + 1
  PRINT @I
END

DROP TABLE #temp_blockedspid

sp_who2

SELECT * FROM msdb.dbo.sysmail_allitems


SELECT tl.resource_type, tl.resource_database_id,
       tl.resource_associated_entity_id, tl.request_mode,
       tl.request_session_id, wt.blocking_session_id, 
       wt.wait_type, wt.wait_duration_ms
FROM sys.dm_tran_locks as tl
INNER JOIN sys.dm_os_waiting_tasks as wt
ON tl.lock_owner_address = wt.resource_address
ORDER BY wait_duration_ms DESC;

