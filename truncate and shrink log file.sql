--****This is for SQL 2005 only
--****Does not work in SQL 2008,
--with TRUNCATE_ONLY has been removed in 2008

USE DatabaseName
GO
DBCC SHRINKFILE(<TransactionLogName>, 1)
BACKUP LOG <DatabaseName> WITH TRUNCATE_ONLY
DBCC SHRINKFILE(<TransactionLogName>, 1)
GO 


USE MasiDev
GO
DBCC SHRINKFILE(MasiDev_log, 1)
BACKUP LOG MasiDev_log WITH TRUNCATE_ONLY
DBCC SHRINKFILE(MasiDev_log, 1)
GO 
