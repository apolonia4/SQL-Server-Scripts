/*Shrink TempDB
http://support.microsoft.com/kb/307487
Set target size, run script and restart sql server service
This will only shrink primary data file and log file.
Secondary data files will be reset automatically by the SQL restart.
*/

   ALTER DATABASE tempdb MODIFY FILE
   (NAME = 'tempdev', SIZE = 2048) 
   --Desired target size for the data file
   ALTER DATABASE tempdb MODIFY FILE
   (NAME = 'tempdev2', SIZE = 2048) 

   ALTER DATABASE tempdb MODIFY FILE
   (NAME = 'templog', SIZE = target_size_in_MB)
   --Desired target size for the log file