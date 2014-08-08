ALTER DATABASE [SharePoint_AdminContent] set single_user with rollback immediate;
GO
DBCC CHECKDB('SharePoint_AdminContent',REPAIR_REBUILD);
go
ALTER DATABASE [SharePoint_AdminContent]
SET MULTI_USER;
GO
