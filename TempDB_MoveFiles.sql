USE TempDB
GO
EXEC sp_helpfile
GO


USE master
GO
ALTER DATABASE TempDB MODIFY FILE
(NAME = tempdev, FILENAME = 'J:\MSSQL2008\MSSQL10_50.MSSQLSERVER\MSSQL\Data\tempdb.mdf')
GO
ALTER DATABASE TempDB MODIFY FILE
(NAME = templog, FILENAME = 'J:\MSSQL2008\MSSQL10_50.MSSQLSERVER\MSSQL\TLogs\templog.ldf')
GO

