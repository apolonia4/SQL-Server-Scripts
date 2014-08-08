
DECLARE @myTable TABLE
(ServiceAccountName VARCHAR(250)
, ServiceName VARCHAR(250)
)
DECLARE @ServiceAccountNameMSSQLServerADHelper100 VARCHAR(250)
DECLARE @ServiceAccountNameMSSQLFDLauncher VARCHAR(250)
DECLARE @ServiceAccountNameMSSQLSERVER varchar(250)
DECLARE @ServiceAccountNameSQLSERVERAGENT VARCHAR(250)
DECLARE @ServiceAccountNameMSSQLServerOLAPService VARCHAR(250)
DECLARE @ServiceAccountNameSQLBrowser VARCHAR(250)
DECLARE @ServiceAccountNameMsDtsServer100 VARCHAR(250)
DECLARE @ServiceAccountNameReportServer VARCHAR(250)
DECLARE @ServiceAccountNameSQLWriter VARCHAR(250)
DECLARE @productversion SQL_VARIANT

SET @productversion = (SELECT SERVERPROPERTY('ProductVersion'))

IF @productversion < 10
	BEGIN
		EXECUTE master.dbo.xp_instance_regread 
		N'HKEY_LOCAL_MACHINE', 
		--2005
		N'SYSTEM\CurrentControlSet\Services\MSSQLServerADHelper', 
		--2008
		--N'SYSTEM\CurrentControlSet\Services\MSSQLServerADHelper100', 
		N'ObjectName', 
		@ServiceAccountNameMSSQLServerADHelper100 OUTPUT, 
		N'no_output'
		INSERT INTO @myTable
		SELECT @ServiceaccountNameMSSQLServerADHelper100 AS AccountName, 'MSSQLServerADHelper' AS ServiceName
	END
	ELSE
		IF @productversion > 10
			BEGIN
				EXECUTE master.dbo.xp_instance_regread 
				N'HKEY_LOCAL_MACHINE', 
				--2005
				--N'SYSTEM\CurrentControlSet\Services\MSSQLServerADHelper', 
				--2008
				N'SYSTEM\CurrentControlSet\Services\MSSQLServerADHelper100', 
				N'ObjectName', 
				@ServiceAccountNameMSSQLServerADHelper100 OUTPUT, 
				N'no_output'
				INSERT INTO @myTable
				SELECT @ServiceaccountNameMSSQLServerADHelper100 AS AccountName, 'MSSQLServerADHelper100' AS ServiceName
			END

		EXECUTE master.dbo.xp_instance_regread 
		N'HKEY_LOCAL_MACHINE', 
		--2005
		N'SYSTEM\CurrentControlSet\Services\msftesql', 
		--2008
		--N'SYSTEM\CurrentControlSet\Services\MSSQLFDLauncher', 
		N'ObjectName', 
		@ServiceAccountNameMSSQLFDLauncher OUTPUT, 
		N'no_output'
		INSERT INTO @myTable
		SELECT @ServiceaccountNameMSSQLFDLauncher AS AccountName, 'MSSQLFDLauncher' AS ServiceName


		EXECUTE master.dbo.xp_instance_regread 
		N'HKEY_LOCAL_MACHINE', 
		N'SYSTEM\CurrentControlSet\Services\MSSQLSERVER', 
		N'ObjectName', 
		@ServiceAccountNameMSSQLSERVER OUTPUT, 
		N'no_output'
		INSERT INTO @myTable
		SELECT @ServiceaccountNameMSSQLSERVER AS AccountName, 'MSSQLSERVER' AS ServiceName


		EXECUTE master.dbo.xp_instance_regread 
		N'HKEY_LOCAL_MACHINE', 
		N'SYSTEM\CurrentControlSet\Services\SQLSERVERAGENT', 
		N'ObjectName', 
		@ServiceaccountNameSQLSERVERAGENT OUTPUT, 
		N'no_output'
		INSERT @myTable
		SELECT @ServiceaccountNameSQLSERVERAGENT AS AccountName, 'SQLSERVERAGENT' AS ServiceName

		EXECUTE master.dbo.xp_instance_regread 
		N'HKEY_LOCAL_MACHINE', 
		N'SYSTEM\CurrentControlSet\Services\MSSQLServerOLAPService', 
		N'ObjectName', 
		@ServiceaccountNameMSSQLServerOLAPService OUTPUT, 
		N'no_output'
		INSERT @myTable
		SELECT @ServiceaccountNameMSSQLServerOLAPService AS AccountName, 'MSSQLServerOLAPService' AS ServiceName

		EXECUTE master.dbo.xp_instance_regread 
		N'HKEY_LOCAL_MACHINE', 
		N'SYSTEM\CurrentControlSet\Services\SQLBrowser', 
		N'ObjectName', 
		@ServiceaccountNameSQLBrowser OUTPUT, 
		N'no_output'
		INSERT @myTable
		SELECT @ServiceaccountNameSQLBrowser AS AccountName, 'SQLBrowser' AS ServiceName

IF @productversion < 10
	BEGIN
		EXECUTE master.dbo.xp_instance_regread 
		N'HKEY_LOCAL_MACHINE', 
		N'SYSTEM\CurrentControlSet\Services\MsDtsServer', 
		N'ObjectName', 
		@ServiceaccountNameMsDtsServer100 OUTPUT, 
		N'no_output'
		INSERT @myTable
		SELECT @ServiceaccountNameMsDtsServer100 AS AccountName, 'MsDtsServer' AS ServiceName
	END
	ELSE
		IF @productversion > 10
			BEGIN
				EXECUTE master.dbo.xp_instance_regread 
				N'HKEY_LOCAL_MACHINE', 
				N'SYSTEM\CurrentControlSet\Services\MsDtsServer100', 
				N'ObjectName', 
				@ServiceaccountNameMsDtsServer100 OUTPUT, 
				N'no_output'
				INSERT @myTable
				SELECT @ServiceaccountNameMsDtsServer100 AS AccountName, 'MsDtsServer100' AS ServiceName
			END

				EXECUTE master.dbo.xp_instance_regread 
				N'HKEY_LOCAL_MACHINE', 
				N'SYSTEM\CurrentControlSet\Services\ReportServer', 
				N'ObjectName', 
				@ServiceaccountNameReportServer OUTPUT, 
				N'no_output'
				INSERT @myTable
				SELECT @ServiceaccountNameReportServer AS AccountName, 'ReportServer' AS ServiceName

				EXECUTE master.dbo.xp_instance_regread 
				N'HKEY_LOCAL_MACHINE', 
				N'SYSTEM\CurrentControlSet\Services\SQLWriter', 
				N'ObjectName', 
				@ServiceaccountNameSQLWriter OUTPUT, 
				N'no_output'
				INSERT @myTable
				SELECT @ServiceaccountNameSQLWriter AS AccountName, 'SQLWriter' AS ServiceName

			SELECT ServiceAccountName, ServiceName FROM @myTable