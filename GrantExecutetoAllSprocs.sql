
DECLARE @sql AS VARCHAR(MAX); 
DECLARE @newline AS VARCHAR(2); 
DECLARE @user_name AS VARCHAR(100); 
DECLARE @sproc_name_pattern AS VARCHAR(10); 

SET @sql = N''
SET @newline = NCHAR(13) + NCHAR(10); 
SET @user_name = 'MAIN\OSC-SVC-devMASIwcf'; 
-- escaping _ prevents it from matching any single character 
-- including the wildcard makes this much more portable between DBs 
SET @sproc_name_pattern = 'usp%'; 
 
-- using QUOTENAME will properly escape any object names with spaces 
-- or other funky characters 
SELECT @sql = @sql              
+ N'GRANT EXECUTE ON '
+ QUOTENAME(OBJECT_SCHEMA_NAME([object_id])) + '.'
+ QUOTENAME([name])         
+ N' TO '
+ QUOTENAME(@user_name)        
+ N';'
+ @newline 
FROM sys.procedures 
WHERE [name] LIKE 'usp%'
AND SCHEMA_ID = 11
--order by [name]
--select * from sys.procedures where [name] like 'usp%'
--28.-- this is my version of debug code, I usually run it once with the PRINT intact 
--29.-- before I actually use sp_executesql 
PRINT @sql; 
--31. 
 
--EXEC sp_executesql @sql;


select * from sys.schemas
