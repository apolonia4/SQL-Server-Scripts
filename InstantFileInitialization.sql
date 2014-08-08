--This can be used to verify that instant file initialization is on.
--SQL Service account needs to be in local sec policy "
DBCC TRACEON(3004,3605,-1) 
GO 
CREATE DATABASE TestFileZero 
GO 
EXEC sp_readerrorlog 
GO 
DROP DATABASE TestFileZero
GO 
DBCC TRACEOFF(3004,3605,-1) 
