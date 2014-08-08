
DECLARE @dbownerinfo TABLE(dbname VARCHAR(255), ServerName VARCHAR(255), UserName VARCHAR(255), RoleName VARCHAR(255))
INSERT INTO @dbownerinfo
EXEC sp_MSforeachdb 'Use [?]; SELECT ''?'' as dbname, @@ServerName, USER_NAME(memberuid) as UserName
, USER_NAME(groupuid) as Role FROM sys.sysmembers 
WHERE USER_NAME(groupuid) IN (''db_owner'') AND USER_NAME(memberuid) NOT IN (''dbo'', ''RSExecRole'')'
SELECT * FROM @dbownerinfo
