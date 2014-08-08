sp_configure 'show advanced options', 1
RECONFIGURE
GO

sp_configure 'awe enabled', 1
RECONFIGURE
GO

--set min memory to 1 GB
sp_configure 'min server memory', 1024
RECONFIGURE
GO

--set max memory to 6 GB
sp_configure 'max server memory', 6144
RECONFIGURE
GO