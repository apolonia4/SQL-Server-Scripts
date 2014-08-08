--http://blogs.msdn.com/b/sqlserverstorageengine/archive/2006/06/10/625659.aspx
dbcc traceon (3604, -1)
go
DBCC
PAGE (master, 1, 1, 3); 
GO
dbcc traceoff (3604, -1)
GO
