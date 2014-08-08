	DECLARE @StartDateTime as DateTime2
	DECLARE @EndDateTime as DateTime2


	--First and last Day of Previous Month

	SET @StartDateTime = CONVERT(DATETIME, CONVERT(CHAR(10), DATEADD(m,-1, Dateadd(d,1-DATEPART(d,getdate()),GETDATE())), 101))
	SET @EndDateTime = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0))
	
	SELECT @startDateTime
	SELECT @EndDateTime