DECLARE @DeleteDate datetime 
SET @DeleteDate = DateAdd(HOUR, -5, GetDate())  

EXECUTE master.sys.xp_delete_file 
0, -- FileTypeSelected (0 = FileBackup, 1 = FileReport) 
N'D:\DBBackups\', -- folder path (trailing slash) 
N'bak', -- file extension which needs to be deleted (no dot) 
@DeleteDate, -- date prior which to delete 
1 -- subfolder flag (1 = include files in first subfolder level, 0 = not)