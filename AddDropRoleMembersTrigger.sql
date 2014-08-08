USE [master]
GO

/****** Object:  DdlTrigger [trg_AllServer_ALTER_LOGIN]    Script Date: 3/28/2013 12:17:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER TRIGGER [trg_AllServer_ADD_DROP_ROLE_MEMBER_LOGIN]
ON ALL SERVER
FOR DROP_SERVER_ROLE_MEMBER, ADD_SERVER_ROLE_MEMBER, ADD_ROLE_MEMBER, DROP_ROLE_MEMBER
AS
	-- Declare variables
	DECLARE @MailSubject varchar(100)
	DECLARE @MailBody varchar(MAX)
	DECLARE @Data XML;
	DECLARE @Text varchar(max);
	DECLARE @User varchar(max);
	DECLARE @NewUser NVARCHAR(MAX);
	DECLARE @EventType NVARCHAR(MAX);

	SET @Data = EVENTDATA();
    SET @NewUser = @data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'varchar(max)');
	SET @User = @data.value('(/EVENT_INSTANCE/LoginName)[1]', 'varchar(max)');
	SET @Text = @data.value('(/EVENT_INSTANCE/RoleName)[1]', 'varchar(max)');
	SET @EventType  = @data.value('(/EVENT_INSTANCE/EventType)[1]', 'varchar(max)');
	
	--SET EMAIL DATA
	SET @mailSubject = 'Login ALTERED On: ' + @@SERVERNAME
	SET @mailBody = 'A login within SQL has been modified.  The specifics of the change are listed below:  ' + CHAR(13) + CHAR(10) +
					'Server:  '  + @@SERVERNAME + CHAR(13)+ CHAR(10) +
					'Login:  ' + ISNULL(@newuser, 'Null Login') + CHAR(13)+ CHAR(10)+
					'Login responsible for change: ' + ISNULL(@user, 'Null') + CHAR(13)+ CHAR(10) +
					'Date:  ' + CONVERT(nvarchar, getdate(), 13) +  CHAR(13)+ CHAR(10) +
					'Event Type: ' + @EventType +  CHAR(13)+ CHAR(10) +
					'Role Name: ' + @Text
					
	
	--SEND MAIL
	EXEC msdb.dbo.sp_send_dbmail
		@recipients=N'VaNSOCSQLDbaJobs@va.gov',
		@subject=@MailSubject,
		@body = @MailBody,
		@profile_name = 'VANSOCWEBADMIN'
		

GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

ENABLE TRIGGER [trg_AllServer_ALTER_LOGIN] ON ALL SERVER
GO


