--TempDB should have same number of files as cores/CPUs on server
ALTER DATABASE tempdb 
ADD FILE (NAME = tempdev2, FILENAME = 'C:\TempDBFiles\tempdb2.mdf', SIZE = 256); 
ALTER DATABASE tempdb 
ADD FILE (NAME = tempdev3, FILENAME = 'C:\TempDBFiles\tempdb3.mdf', SIZE = 256); 
ALTER DATABASE tempdb 
ADD FILE (NAME = tempdev4, FILENAME = 'C:\TempDBFiles\tempdb4.mdf', SIZE = 256); 
GO 
