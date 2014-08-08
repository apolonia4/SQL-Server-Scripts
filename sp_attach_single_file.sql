USE [master]
GO
-- Method 1: I use this method
EXEC sp_attach_single_file_db @dbname='IMS',
@physname=N'F:\Microsoft SQL Server\MSSQL.1\MSSQL\Data\IMS.mdf'
GO