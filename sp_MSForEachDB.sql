EXEC sp_MSforeachdb 'Use [?]; SELECT ''?'' as dbname,  * FROM sysobjects WHERE name LIKE ''%sp_smtpemail%'''