--Creates the credential called FilerCredential to be used for SQL Agent and Copying Audit Files to Filer. 
--!!!!!!!!!!!!!! ADD FILER PASSWORD BEFORE RUNNING SCRIPT !!!!!!!!!!!!!!!!!!!!!!!
USE master
GO
CREATE CREDENTIAL FilerCredential WITH IDENTITY = 'VHAMASTER\VACO-SDI-SQL-FILBKUP', 
    SECRET = '**ADD PWD***';
GO

--Create Agent Proxy
USE [msdb]
GO
EXEC msdb.dbo.sp_add_proxy @proxy_name=N'FilerCredential_Proxy',@credential_name=N'FilerCredential', 
		@enabled=1
GO
--subsystem_id = 3 is for Operating System Command (CMDExec)
EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'FilerCredential_Proxy', @subsystem_id=3
GO

