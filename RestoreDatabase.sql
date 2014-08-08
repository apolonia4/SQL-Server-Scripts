RESTORE DATABASE [SolarWindsRestore] 
FROM  DISK = N'C:\Program Files\SolarWinds\Orion\SQLExpress\MSSQL.1\MSSQL\Backup\SolarWindsOrion.bak' 
WITH  FILE = 1,  
MOVE N'SolarWindsOrion' TO N'C:\Program Files\SolarWinds\Orion\SQLExpress\MSSQL.1\MSSQL\DATA\SolarWindsRestore.mdf'  
, MOVE N'SolarWindsOrion_log' TO N'C:\Program Files\SolarWinds\Orion\SQLExpress\MSSQL.1\MSSQL\DATA\SolarWindsRestore_1.LDF'
,  NOUNLOAD
,  REPLACE
,  STATS = 10
GO

EXEC sp_change_users_login 'Report'

select * from sys.database_principals
select * from sysusers

create login SolarWindsOrionDatabaseUser with password = 'fizzmo0509' , sid = 0x19BA42E4E3543C44B00FC15470387E40
DROP LOGIN SolarWindsOrionDatabaseUser

EXEC sp_change_users_login 'Auto_Fix', 'SolarWindsOrionDatabaseUser', NULL, 'fizzmo0509';




