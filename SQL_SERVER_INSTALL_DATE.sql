SELECT  @@version, createdate as Sql_Server_Install_Date 
FROM    sys.syslogins 
where   sid = 0x010100000000000512000000 
and createdate > '2011-09-01'
