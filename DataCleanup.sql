
DECLARE @RowCount INT
SET @RowCount = (SELECT COUNT(*) from tblacsimporttest3) 
DECLARE @I INT
-- Initialize the iterator
SET @I = 1

-- Loop through the rows of a table @myTable
WHILE (@I <= @RowCount)
	BEGIN
		--Declare variable to hold each column value
		DECLARE @col1 varchar(100)
		, @col30 varchar(100)
		, @col6 varchar(100)
		, @col17 varchar(100)
		, @col22 varchar(100)
		, @col18 varchar(100)
		, @col24 varchar(100)
		, @col9 varchar(100)
		, @col10 varchar(100)
		, @col20 varchar(100)
		, @col21 varchar(100)
		, @col25 varchar(100)
		, @col26 varchar(100)
		, @col11 varchar(100)
		, @col8 varchar(100)
		, @col7 varchar(100)
		, @col12 varchar(100)
		, @col27 varchar(100)
		, @col41 varchar(100)
		, @col23 varchar(100)
		, @col19 varchar(100)
		, @col38 varchar(100)
		, @col39 varchar(100)
		, @col40 varchar(100)
		, @col31 varchar(100)
		, @col32 varchar(100)
		, @col33 varchar(100)
		, @col34 varchar(100)
		, @col35 varchar(100)
		, @col36 varchar(100)
		, @col37 varchar(100)


		SET @col1 = (SELECT col1 FROM tblacsimporttest3 WHERE id = @I)
		SET @col30 = (SELECT col30 FROM tblacsimporttest3 WHERE id = @I)
		SET @col6 = (SELECT col6 FROM tblacsimporttest3 WHERE id = @I)
		SET @col17 = (SELECT col17 FROM tblacsimporttest3 WHERE id = @I)
		SET @col22 = (SELECT col22 FROM tblacsimporttest3 WHERE id = @I)
		SET @col18 = (SELECT col18 FROM tblacsimporttest3 WHERE id = @I)
		SET @col24 = (SELECT col24 FROM tblacsimporttest3 WHERE id = @I)
		SET @col9 = (SELECT col9 FROM tblacsimporttest3 WHERE id = @I)
		SET @col10 = (SELECT col10 FROM tblacsimporttest3 WHERE id = @I)
		SET @col20 = (SELECT col20 FROM tblacsimporttest3 WHERE id = @I)
		SET @col21 = (SELECT col21 FROM tblacsimporttest3 WHERE id = @I)
		SET @col25 = (SELECT col25 FROM tblacsimporttest3 WHERE id = @I)
		SET @col26 = (SELECT col26 FROM tblacsimporttest3 WHERE id = @I)
		SET @col11 = (SELECT col11 FROM tblacsimporttest3 WHERE id = @I)
		SET @col8 = (SELECT col8 FROM tblacsimporttest3 WHERE id = @I)
		SET @col7 = (SELECT col7 FROM tblacsimporttest3 WHERE id = @I)
		SET @col12 = (SELECT col12 FROM tblacsimporttest3 WHERE id = @I)
		SET @col27 = (SELECT col27 FROM tblacsimporttest3 WHERE id = @I)
		SET @col41 = (SELECT col41 FROM tblacsimporttest3 WHERE id = @I)
		SET @col23 = (SELECT col23 FROM tblacsimporttest3 WHERE id = @I)
		SET @col19 = (SELECT col19 FROM tblacsimporttest3 WHERE id = @I)
		SET @col38 = (SELECT col38 FROM tblacsimporttest3 WHERE id = @I)
		SET @col39 = (SELECT col39 FROM tblacsimporttest3 WHERE id = @I)
		SET @col40 = (SELECT col40 FROM tblacsimporttest3 WHERE id = @I)
		SET @col31 = (SELECT col31 FROM tblacsimporttest3 WHERE id = @I)
		SET @col32 = (SELECT col32 FROM tblacsimporttest3 WHERE id = @I)
		SET @col33 = (SELECT col33 FROM tblacsimporttest3 WHERE id = @I)
		SET @col34 = (SELECT col34 FROM tblacsimporttest3 WHERE id = @I)
		SET @col35 = (SELECT col35 FROM tblacsimporttest3 WHERE id = @I)
		SET @col36 = (SELECT col36 FROM tblacsimporttest3 WHERE id = @I)
		SET @col37 = (SELECT col37 FROM tblacsimporttest3 WHERE id = @I)

		--Use replace function to cleanup data in each column 
		UPDATE tblacsimporttest3
		--SET AcctStatusType = REPLACE(@AcctStatusType, ' Acct-Status-Type=', '')
		SET col1 = Substring(@col1, 1, 24)
		, col30 = REPLACE(@col30, ' AcsSessionID=', '')
		, col6 = REPLACE(@col6, ' User-Name=', '')
					--, col6 = REPLACE(@col6, '\\', '\') *Do this in a separate loop **col41 \\
		, col17 = REPLACE(@col17, ' Calling-Station-ID=', '')
		, col22 = REPLACE(@col22, ' Acct-Session-Id=', '')
		, col18 = REPLACE(@col18, ' Acct-Status-Type=', '') 
		, col24 = REPLACE(@col24, ' Acct-Session-Time=', '') 
		, col9 = REPLACE(@col9, ' Service-Type=', '')
		, col10 = REPLACE(@col10, ' Framed-Protocol=', '') 
		, col20 = REPLACE(@col20, ' Acct-Input-Octets=', '') 
		, col21 = REPLACE(@col21, ' Acct-Output-Octets=', '') 
		, col25 = REPLACE(@col25, ' Acct-Input-Packets=', '') 
		, col26 = REPLACE(@col26, ' Acct-Output-Packets=', '') 
		, col11 = REPLACE(@col11, ' Framed-IP-Address=', '') 
		, col8 = REPLACE(@col8, ' NAS-Port=', '')
		, col7 = REPLACE(@col7, ' NAS-IP-Address=', '')
		, col12 = REPLACE(@col12, ' Class=', '')
		, col27 = REPLACE(@col27, ' Acct-Terminate-Cause=', '')
		, col41 = REPLACE(@col41, ' AuditSessionId=', '')
		, col23 = REPLACE(@col23, ' Acct-Authentic=', '')
		, col19 = REPLACE(@col19, ' Acct-Delay-Time=', '')
		, col38 = REPLACE(@col38, ' NetworkDeviceName=', '')
		, col39 = REPLACE(@col39, ' NetworkDeviceGroups=', '')
		, col40 = REPLACE(@col40, ' NetworkDeviceGroups=', '')
		, col31 = REPLACE(@col31, ' Step=', '')
		, col32 = REPLACE(@col32, ' Step=', '')
		, col33 = REPLACE(@col33, ' Step=', '')
		, col34 = REPLACE(@col34, ' Step=', '')
		, col35 = REPLACE(@col35, ' Step=', '')
		, col36 = REPLACE(@col36, ' Step=', '')
		, col37 = REPLACE(@col37, ' Step=', '')

		WHERE id = @I

		SET @I = @I  + 1
	END



	
DECLARE @RowCount INT
SET @RowCount = (SELECT COUNT(*) from tblacsimporttest3) 
DECLARE @I INT
-- Initialize the iterator
SET @I = 1

-- Loop through the rows of a table @myTable
WHILE (@I <= @RowCount)
	BEGIN
		--Declare variable to hold each column value
		DECLARE @col6 varchar(100)
		, @col41 varchar(100)

		SET @col6 = (SELECT col6 FROM tblacsimporttest3 WHERE id = @I)
		SET @col41 = (SELECT col41 FROM tblacsimporttest3 WHERE id = @I)

		--Use replace function to cleanup data in each column 
		UPDATE tblacsimporttest3
		--SET AcctStatusType = REPLACE(@AcctStatusType, ' Acct-Status-Type=', '')
		SET col6 = REPLACE(@col6, '\\', '\')
		, col41 = REPLACE(@col41, '\\', '\')
	
		WHERE id = @I

		SET @I = @I  + 1
	END