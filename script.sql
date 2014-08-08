USE [RunBook]
GO

/****** Object:  StoredProcedure [dbo].[uspFilerCheck2]    Script Date: 1/30/2014 1:02:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspFilerCheck2]

	@CreatedDateTime datetime2

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DECLARE @CombinedDirectory TABLE
(
  chvDirectoryName varchar(100) NULL
  , chvDirectorySizeMB varchar(100) NULL
  , dtmDateTime datetime NULL
)

insert into @CombinedDirectory (chvDirectoryName, chvDirectorySizeMB, dtmDateTime)
select chvDirectoryName, chvDirectorySizeMB, dtmDateTime from FilerDirectorySize..tblMartinsburgDirResult m
union
select chvDirectoryName, chvDirectorySizeMB, dtmDateTime from FilerDirectorySize..tblHinesDirResult h
	

SELECT 
f.FilerDirectoryName
, f.ServerMappedTo
, f.FilerLocation
, f.ServerDatabaseCount
, f.ExpectedFilerCount
, d.DailyFullBackupCount
, d.CreatedDateTime 
, d.DirectoryCount
, d.ResourceDBCount
, d.TransactionLogCount
, f.Notes
, cast(replace(c.chvDirectorysizeMB, ',','') as decimal(9,2))/1024 DirectorySizeGB
FROM dbo.FilerServerMapping f
RIGHT OUTER JOIN dbo.DailyFilerCount d
ON d.FilerDirectory = f.FilerDirectoryName
LEFT OUTER JOIN @CombinedDirectory c
on f.FilerDirectoryName = c.chvDirectoryname
WHERE d.CreatedDateTime > @CreatedDateTime AND d.CreatedDateTime < CONVERT(VARCHAR(20), @CreatedDateTime, 110) + ' 23:59:59.997'
ORDER BY f.FilerLocation, FilerDirectoryName

END

GO


