SELECT  
@@ServerName AS NetBiosName
, l.name
, l.denylogin 
, l.isntname
, l.isntgroup 
, l.isntuser
FROM master.sys.syslogins l
WHERE l.sysadmin = 1
AND l.name NOT IN ('NT AUTHORITY\SYSTEM', 'NT SERVICE\MSSQLSERVER','NT SERVICE\SQLSERVERAGENT','BUILTIN\Administrators')
ORDER BY 
 l.isntgroup
, l.isntname
, l.isntuser