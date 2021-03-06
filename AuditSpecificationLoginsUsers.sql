USE [master]
GO

/****** Object:  Audit [Audit-SQLServerLoginsUsers]    Script Date: 03/09/2012 13:40:18 ******/
CREATE SERVER AUDIT [Audit-SQLServerLoginsUsers]
TO FILE 
(	FILEPATH = N'C:\SQLServerAudit\'
	,MAXSIZE = 0 MB
	,MAX_ROLLOVER_FILES = 2147483647
	,RESERVE_DISK_SPACE = OFF
)
WITH
(	QUEUE_DELAY = 1000
	,ON_FAILURE = CONTINUE
	,AUDIT_GUID = '88b0d681-b474-4ac7-b075-11e97904aa10'
)
GO

USE [master]
GO

CREATE SERVER AUDIT SPECIFICATION [ServerAuditSpecification-ServerLogins]
FOR SERVER AUDIT [Audit-SQLServerLoginsUsers]
ADD (SERVER_ROLE_MEMBER_CHANGE_GROUP),
ADD (SERVER_PERMISSION_CHANGE_GROUP),
ADD (SERVER_PRINCIPAL_CHANGE_GROUP)
WITH (STATE = OFF)
GO


USE [ScanRegistration]
GO

CREATE DATABASE AUDIT SPECIFICATION [DatabaseAuditSpecification-DatabaseUsers]
FOR SERVER AUDIT [Audit-SQLServerLoginsUsers]
ADD (DATABASE_ROLE_MEMBER_CHANGE_GROUP),
ADD (DATABASE_PERMISSION_CHANGE_GROUP),
ADD (DATABASE_PRINCIPAL_CHANGE_GROUP)
WITH (STATE = OFF)
GO




