ALTER DATABASE dbCircuitUtilization set single_user with rollback immediate  
GO
USE [master]
GO
--Taking tail log
BACKUP LOG SharePoint_Config TO
DISK = N'K:\DBBackups\SharePoint_Config_TailLog.trn'
WITH NORECOVERY
GO
--alter database SharePoint_Config set single_user with rollback immediate  
--GO
RESTORE DATABASE SharePoint_Config
FROM DISK = 'K:\DBBackups\VANSMSQLSP_SharePoint_Config_FULL_20120925_041632.bak'
WITH NORECOVERY
GO
RESTORE DATABASE SharePoint_Config WITH RECOVERY