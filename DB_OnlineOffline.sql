--To determine if a database is offline check state_desc
SELECT Name, state_desc FROM sys.databases

--Take database offline
ALTER DATABASE myTestDB SET OFFLINE
--Bring database online
ALTER DATABASE myTestDB SET ONLINE


