DECLARE @sql VARCHAR(2000)
DECLARE @BackupPath as VARCHAR(100)
DECLARE @BackupDate as VARCHAR(23) 
DECLARE @CreateDate as DATETIME

SET @CreateDate = GetDate()

SET @BackupDate = CONVERT(VARCHAR(23), @CreateDate, 126)
SET @BackupDate = LEFT(@BackupDate, LEN(@BackupDate) - 4)
SET @BackupDate = Replace(@backupdate, ':', '')

SET @BackupPath = 'ePO4_NSOCLITCAV1_' + @backupdate + '.sqb'
SET @sql = '-SQL "BACKUP DATABASE [ePO4_NSOCLITCAV1] TO DISK = ''D:\DBBackups\' + @backuppath +'''"'
EXEC [master].dbo.sqlbackup @sql