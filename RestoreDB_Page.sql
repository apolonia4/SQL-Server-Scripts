DBCC TRACEON (3604, -1)
GO
DBCC PAGE('CorruptMe', 1, 3592, 3)
GO 
 

RESTORE DATABASE CorruptMe PAGE = '1:3592'
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\Backup\CorruptMe.bak'
WITH NORECOVERY
 
 
-- Need to complete roll forward. Backup the log tail...
BACKUP
LOG CorruptMe TO DISK = 'C:\CorruptMe_log.bak' WITH INIT;
GO
 
-- ... and restore it again.
RESTORE
LOG CorruptMe FROM DISK = 'C:\CorruptMe_log.bak';
GO

