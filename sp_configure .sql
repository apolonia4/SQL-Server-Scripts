EXEC sp_configure 'show advanced options',1
GO
RECONFIGURE WITH OVERRIDE
GO
EXEC sp_configure
GO

EXEC sp_configure 'xp_cmdshell', 1
GO
-- To update the currently configured value for this feature.
RECONFIGURE
GO

