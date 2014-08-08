DECLARE @Backupfiles VARCHAR(500)
DECLARE @dbname VARCHAR(150)
SET @dbname = 'Adventureworks'

SELECT @BackupFiles=COALESCE(@BackupFiles + ',', '') + 'DISK = N'''+physical_device_name+''''
FROM msdb.dbo.backupset S
JOIN msdb.dbo.backupmediafamily M ON M.media_set_id=S.media_set_id
WHERE backup_set_id = ( SELECT MAX(backup_set_id)
                   FROM msdb.dbo.backupset S
                   JOIN msdb.dbo.backupmediafamily M ON M.media_set_id=S.media_set_id
                   WHERE S.database_name = @DBName AND TYPE = 'D')

PRINT @BackupFiles