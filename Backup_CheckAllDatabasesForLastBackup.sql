SELECT 
T1.Name AS DatabaseName, 
COALESCE(CONVERT(VARCHAR(12), MAX(T2.backup_finish_date), 101),'Not Yet Taken') AS LastBackUpTaken
FROM sys.sysdatabases T1 LEFT OUTER JOIN msdb.dbo.backupset T2
ON T2.database_name = T1.name
GROUP BY T1.Name
ORDER BY T1.Name

 
