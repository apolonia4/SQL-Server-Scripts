/*
Script:       BLITZ! 60 Minute Server Takeovers by Brent Ozar
Version:      1.4 - October 12, 2011
Source:       http://www.BrentOzar.com/blitz
License:      Creative Commons.  For more information, see
              http://www.brentozar.com/what-i-do/using-material-from-my-blog/
Description:  Shows what we look for when we take over existing servers.

              DON'T JUST RUN THIS WHOLE QUERY AT ONCE.
              Read through each step to learn what I'm checking for,
              and how to fix things when they indicate problems.
*/







/*
	Some people just fire up this script and run the whole thing without
	looking at what it does, so I have to put the below snippet in.  This way,
	SQL Server will bail out rather than execute the whole thing.  Later on in
	the script, some of the queries can be rather load-intensive on big
	servers, like when we query the procedure cache for servers with >64GB of
	memory.  Don't worry, I'll warn you in the notes for those queries.
*/
RAISERROR('DO NOT JUST EXECUTE THIS WHOLE QUERY BLINDLY.  RUN IT SECTION BY SECTION, READING INSTRUCTIONS AS YOU GO.', 20, -1) with log






/* 
   Backups!  First and foremost, before we touch anything, check backups.
   Check when each database has been backed up.  If databases are not being
   backed up, check the maintenance plans or scripts.  If you need scripts,
   check http://ola.hallengren.com.
*/

SELECT  d.name ,
        MAX(b.backup_finish_date) AS last_backup_finish_date
FROM    master.sys.databases d
        LEFT OUTER JOIN msdb.dbo.backupset b ON d.name = b.database_name
                                                AND b.type = 'D'
WHERE   d.database_id NOT IN ( 2, 3 )  /* Bonus points if you know what that means (Ans. TempDB(2) and Model(3) */
GROUP BY d.name
ORDER BY 2 DESC



/*
	Where are the backups going?  Ideally, we want them on a different server.
	If the backups are being taken to this same server, and the server's RAID
	card or motherboard goes bad, we're in trouble.
	Learn more: http://www.brentozar.com/go/networkbackups
*/
SELECT TOP 100
        physical_device_name ,
        *
FROM    msdb.dbo.backupmediafamily
ORDER BY media_set_id DESC







/*
   Transaction log backups - do we have any databases in full recovery mode
   that have not had t-log backups?  If so, we should think about putting it in
   simple recovery mode or doing t-log backups.  Otherwise, the transaction log
   will grow forever - yes, even if you're doing full backups.
   Learn more: http://www.brentozar.com/go/growinglogs
*/

SELECT  d.name ,
        d.recovery_model ,
        d.recovery_model_desc
FROM    master.sys.databases d
        LEFT OUTER JOIN msdb.dbo.backupset b ON d.name = b.database_name
                                                AND b.type = 'L'
WHERE   d.recovery_model IN ( 1, 2 )
        AND b.type IS NULL
        AND d.database_id NOT IN ( 2, 3 )







/* 
	Is the MSDB backup history cleaned up?  Probably not - when we take over a
	new server, we're lucky if it's got backups, let alone cleanup jobs.
   If you have data older than a couple of months, this may be a problem that
can cause backups to take longer and longer. For more information:
   http://www.brentozar.com/go/bigmsdb
*/
SELECT TOP 1
        backup_start_date
FROM    msdb.dbo.backupset WITH ( NOLOCK )
ORDER BY backup_set_id ASC







/*
   When was the last time DBCC finished successfully?  DBCC CHECKDB checks 
   databases for corruption.  Data corrupts at rest, when it sits on the disk,
   but we will not get an alert when corruption happens.  We only get alerted
   when someone reads a corrupt page from the database.  DBCC CHECKDB is our
   first line of defense.
   Script is from http://sqlserverpedia.com/wiki/Last_clean_DBCC_CHECKDB_date

	If any databases have never experienced the magic of DBCC, consider doing
	it as soon as it's practical.  DBCC CHECKDB is a CPU & IO intensive 
	operation, so consider doing it after business hours.  For info on how to
	break up DBCC into more digestible chunks for large (>1TB) databases, see:
	http://www.sqlskills.com/blogs/paul/post/CHECKDB-From-Every-Angle-Consistency-Checking-Options-for-a-VLDB.aspx
    
*/

CREATE TABLE #temp
    (
      ParentObject VARCHAR(255) ,
      [Object] VARCHAR(255) ,
      Field VARCHAR(255) ,
      [Value] VARCHAR(255)
    )   
   
CREATE TABLE #DBCCResults
    (
      ServerName VARCHAR(255) ,
      DBName VARCHAR(255) ,
      LastCleanDBCCDate DATETIME
    )   
    
EXEC master.dbo.sp_MSforeachdb @command1 = 'USE ? INSERT INTO #temp EXECUTE (''DBCC DBINFO WITH TABLERESULTS'')',
    @command2 = 'INSERT INTO #DBCCResults SELECT @@SERVERNAME, ''?'', Value FROM #temp WHERE Field = ''dbi_dbccLastKnownGood''',
    @command3 = 'TRUNCATE TABLE #temp'   
   
   --Delete duplicates due to a bug in SQL Server 2008
   
   ;
WITH    DBCC_CTE
          AS ( SELECT   ROW_NUMBER() OVER ( PARTITION BY ServerName, DBName,
                                            LastCleanDBCCDate ORDER BY LastCleanDBCCDate ) RowID
               FROM     #DBCCResults
             )
    DELETE  FROM DBCC_CTE
    WHERE   RowID > 1 ;
   
SELECT  ServerName ,
        DBName ,
        CASE LastCleanDBCCDate
          WHEN '1900-01-01 00:00:00.000' THEN 'Never ran DBCC CHECKDB'
          ELSE CAST(LastCleanDBCCDate AS VARCHAR)
        END AS LastCleanDBCCDate
FROM    #DBCCResults
ORDER BY 3
   
DROP TABLE #temp, #DBCCResults ;



/*
	Has database mirroring automatically recovered any corrupt pages for us?
	Probably the least-known yet most-cool feature of the SQL Server engine,
	whenever SQL Server detects a corrupt page, it'll ask the database mirror
	for a good copy of that page.  It will repair corruption automatically,
	in the background, without a complaint.  However, we need to know about
	this ASAP so we can find out why our storage is going bad.
*/
SELECT *
FROM    sys.dm_db_mirroring_auto_page_repair
WHERE   modification_time >= DATEADD(dd, -30, GETDATE()) ;
            





/*
	Maybe there were DBCC jobs that are not running.
	Speaking of which, are jobs failing, and who owns them?
	If job owners are null, that means they're Windows authentication logins.
	If that login has been disabled or the domain controllers are unavailable
	when SQL Server Agent tries to start the job, the job will fail. For more
	reliable jobs, set the owner to be SA or another known-to-always-exist
	SQL Server login (rather than Windows auth).  Don't change existing jobs
	that have been failing, though - who knows what's inside those old jobs? 
*/

SET  NOCOUNT ON
DECLARE @MaxLength INT
SET @MaxLength = 50
 
DECLARE @xp_results TABLE
    (
      job_id UNIQUEIDENTIFIER NOT NULL ,
      last_run_date NVARCHAR(20) NOT NULL ,
      last_run_time NVARCHAR(20) NOT NULL ,
      next_run_date NVARCHAR(20) NOT NULL ,
      next_run_time NVARCHAR(20) NOT NULL ,
      next_run_schedule_id INT NOT NULL ,
      requested_to_run INT NOT NULL ,
      request_source INT NOT NULL ,
      request_source_id SYSNAME COLLATE database_default
                                NULL ,
      running INT NOT NULL ,
      current_step INT NOT NULL ,
      current_retry_attempt INT NOT NULL ,
      job_state INT NOT NULL
    )
 
DECLARE @job_owner SYSNAME
 
DECLARE @is_sysadmin INT
SET @is_sysadmin = ISNULL(IS_SRVROLEMEMBER('sysadmin'), 0)
SET @job_owner = SUSER_SNAME()
 
INSERT  INTO @xp_results
        EXECUTE sys.xp_sqlagent_enum_jobs @is_sysadmin, @job_owner
 
UPDATE  @xp_results
SET     last_run_time = RIGHT('000000' + last_run_time, 6) ,
        next_run_time = RIGHT('000000' + next_run_time, 6)
 
SELECT  j.name AS JobName ,
        j.enabled AS Enabled ,
        sl.name AS OwnerName ,
        CASE x.running
          WHEN 1 THEN 'Running'
          ELSE CASE h.run_status
                 WHEN 2 THEN 'Inactive'
                 WHEN 4 THEN 'Inactive'
                 ELSE 'Completed'
               END
        END AS CurrentStatus ,
        COALESCE(x.current_step, 0) AS CurrentStepNbr ,
        CASE WHEN x.last_run_date > 0
             THEN CONVERT (DATETIME, SUBSTRING(x.last_run_date, 1, 4) + '-'
                  + SUBSTRING(x.last_run_date, 5, 2) + '-'
                  + SUBSTRING(x.last_run_date, 7, 2) + ' '
                  + SUBSTRING(x.last_run_time, 1, 2) + ':'
                  + SUBSTRING(x.last_run_time, 3, 2) + ':'
                  + SUBSTRING(x.last_run_time, 5, 2) + '.000', 121)
             ELSE NULL
        END AS LastRunTime ,
        CASE h.run_status
          WHEN 0 THEN 'Fail'
          WHEN 1 THEN 'Success'
          WHEN 2 THEN 'Retry'
          WHEN 3 THEN 'Cancel'
          WHEN 4 THEN 'In progress'
        END AS LastRunOutcome ,
        CASE WHEN h.run_duration > 0
             THEN ( h.run_duration / 1000000 ) * ( 3600 * 24 )
                  + ( h.run_duration / 10000 % 100 ) * 3600 + ( h.run_duration
                                                              / 100 % 100 )
                  * 60 + ( h.run_duration % 100 )
             ELSE NULL
        END AS LastRunDuration
FROM    @xp_results x
        LEFT JOIN msdb.dbo.sysjobs j ON x.job_id = j.job_id
        LEFT OUTER JOIN msdb.dbo.syscategories c ON j.category_id = c.category_id
        LEFT OUTER JOIN msdb.dbo.sysjobhistory h ON x.job_id = h.job_id
                                                    AND x.last_run_date = h.run_date
                                                    AND x.last_run_time = h.run_time
                                                    AND h.step_id = 0
        LEFT OUTER JOIN sys.syslogins sl ON j.owner_sid = sl.sid
 









/*
	Right up there with data integrity, security is really important.
	Who else has sysadmin or securityadmin rights on this instance?
	I care about securityadmin users because they can add themselves to the SA
	role at any time to do their dirty work, then remove themselves back out.
	
	Do not think of them as other sysadmins.  
	Think of them as users who can get you fired.
*/

SELECT  l.name ,
        l.denylogin ,
        l.isntname ,
        l.isntgroup ,
        l.isntuser
FROM    master.sys.syslogins l
WHERE   l.sysadmin = 1
        OR l.securityadmin = 1
ORDER BY l.isntgroup ,
        l.isntname ,
        l.isntuser







/*
	Now would be an excellent time to open up a Word doc and start documenting
	your findings, which helps you prove your worth as a DBA.  And for every
	SQL authentication user in that list, try logging in with a blank password.

	In your Blitz document, if SA includes Builtin\Administrators, list the 
	server's local administrators.
*/






/*
	Time to review some server-level security & configuration settings.  You
	can check this with sp_configure or sys.configurations, and look for any
	setting that's been changed away from the default value.
	
	What, you don't remember all SQL Server's defaults?  No, me neither.
	Instead, let's use a really cool tool from Microsoft that's built into
	SSMS.  Go into the Object Explorer, then right-click on the server name.
	Click Reports, Standard Reports, Server Dashboard, and then expand the
	section Non Default Configuration Options.  It will show everything that
	deviates from the defaults.  You should be able to identify why anything
	was changed away from the default, and if not, question it.

	Server settings can be made outside of sp_configure too.  The easiest way
	to check out the service settings are to Remote Desktop into the server and
	go into Start, Programs, Microsoft SQL Server, Configuration Tools, 
	SQL Server Configuration Manager. Drill into SQL Server Services, then 
	right-click on each service and hit Properties.  The advanced properties
	for the SQL Server service itself can hide some startup parameters.

	Next, check Instant File Initialization.  Take a note of the service account
	SQL Server is using, and then run secpol.msc.  Go into Local Policy, User
	Rights Assignment, Perform Volume Maintenance Tasks.  Double-click on that
	and add the SQL Server service account.  This lets SQL Server grow data
	files instantly.  For more info:
	http://www.sqlskills.com/blogs/kimberly/post/Instant-Initialization-What-Why-and-How.aspx

	Let's do a few more checks at the server level.  Go into the Windows Event
	Logs and review any errors in the System and Application events.  This is
	where hardware-level errors can show up too, like failed hard drives.
	
	After that, we're done with remote desktop - go ahead and close out of
	that.  Make sure to close out by fully logging out - don't leave your
	remote desktop session open.
*/






/*
	SQL Server 2005 & newer: is database mail set up?  Let's test it by sending
	ourselves an email. Replace help@brentozar.com with your own email address.
*/
EXEC msdb.dbo.sp_send_dbmail @recipients = 'help@brentozar.com',
    @body = @@SERVERNAME,
    @subject = 'Testing SQL Server Database Mail - see body for server name' ;
GO






/*
	Are alerts set up?  Alerts email us automatically when things go bump in
	the night, like when drives run out of space.  The below query will list
	all alerts, but most of the time, it's going to return an empty result
	set, indicating the database server is in need of some lovin' from a
	talented and good-looking database administrator like yourself.
*/
SELECT  *
FROM    msdb.dbo.sysalerts
GO
SELECT  *
FROM    msdb.dbo.sysoperators
GO





/*
	If no alerts are set up, make sure Database Mail is configured, and then
	the below set of scripts will set up a default set of notifications for 
	problems.  In this section, replace these strings:
	- 'DBA' - your name goes here
	- 'YourEmailAddress@Hotmail.com' - your email
	- '8005551212@cingularme.com' - your phone/pager email address
*/


USE [msdb]
GO
EXEC msdb.dbo.sp_add_operator @name = N'DBA',
    @enabled = 1, @weekday_pager_start_time = 0,
    @weekday_pager_end_time = 235959, @saturday_pager_start_time = 0,
    @saturday_pager_end_time = 235959, @sunday_pager_start_time = 0,
    @sunday_pager_end_time = 235959, @pager_days = 127,
    @email_address = N'YourEmailAddress@Hotmail.com',
    @pager_address = N'8005551212@cingularme.com',
    @category_name = N'[Uncategorized]'
GO
EXEC msdb.dbo.sp_add_alert @name = N'Severity 016', @message_id = 0,
    @severity = 16, @enabled = 1, @delay_between_responses = 60,
    @include_event_description_in = 1,
    @job_id = N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name = N'Severity 016',
    @operator_name = N'DBA', @notification_method = 7
GO
EXEC msdb.dbo.sp_add_alert @name = N'Severity 017', @message_id = 0,
    @severity = 17, @enabled = 1, @delay_between_responses = 60,
    @include_event_description_in = 1,
    @job_id = N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name = N'Severity 017',
    @operator_name = N'DBA', @notification_method = 7
GO
EXEC msdb.dbo.sp_add_alert @name = N'Severity 018', @message_id = 0,
    @severity = 18, @enabled = 1, @delay_between_responses = 60,
    @include_event_description_in = 1,
    @job_id = N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name = N'Severity 018',
    @operator_name = N'DBA', @notification_method = 7
GO
EXEC msdb.dbo.sp_add_alert @name = N'Severity 019', @message_id = 0,
    @severity = 19, @enabled = 1, @delay_between_responses = 60,
    @include_event_description_in = 1,
    @job_id = N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name = N'Severity 019',
    @operator_name = N'DBA', @notification_method = 7
GO
EXEC msdb.dbo.sp_add_alert @name = N'Severity 020', @message_id = 0,
    @severity = 20, @enabled = 1, @delay_between_responses = 60,
    @include_event_description_in = 1,
    @job_id = N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name = N'Severity 020',
    @operator_name = N'DBA', @notification_method = 7
GO
EXEC msdb.dbo.sp_add_alert @name = N'Severity 021', @message_id = 0,
    @severity = 21, @enabled = 1, @delay_between_responses = 60,
    @include_event_description_in = 1,
    @job_id = N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name = N'Severity 021',
    @operator_name = N'DBA', @notification_method = 7
GO
EXEC msdb.dbo.sp_add_alert @name = N'Severity 022', @message_id = 0,
    @severity = 22, @enabled = 1, @delay_between_responses = 60,
    @include_event_description_in = 1,
    @job_id = N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name = N'Severity 022',
    @operator_name = N'DBA', @notification_method = 7
GO
EXEC msdb.dbo.sp_add_alert @name = N'Severity 023', @message_id = 0,
    @severity = 23, @enabled = 1, @delay_between_responses = 60,
    @include_event_description_in = 1,
    @job_id = N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name = N'Severity 023',
    @operator_name = N'DBA', @notification_method = 7
GO
EXEC msdb.dbo.sp_add_alert @name = N'Severity 024', @message_id = 0,
    @severity = 24, @enabled = 1, @delay_between_responses = 60,
    @include_event_description_in = 1,
    @job_id = N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name = N'Severity 024',
    @operator_name = N'DBA', @notification_method = 7
GO
EXEC msdb.dbo.sp_add_alert @name = N'Severity 025', @message_id = 0,
    @severity = 25, @enabled = 1, @delay_between_responses = 60,
    @include_event_description_in = 1,
    @job_id = N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name = N'Severity 025',
    @operator_name = N'DBA', @notification_method = 7
GO












/*
	I hate surprises in the system databases.  Time to check the list of
	objects in master and model.  I do not want to see any rows returned from
	these four queries - if there are objects in the system databases, I want to
	ask why, and get them removed if possible.
*/

SELECT  *
FROM    master.sys.objects
WHERE   is_ms_shipped = 0
GO
SELECT  *
FROM    model.sys.objects
WHERE   is_ms_shipped = 0
GO
SELECT  *
FROM    msdb.sys.objects
WHERE   is_ms_shipped = 0
GO







/*
	Alright, all done with the server level!  Time to check databases.  We could
	right-click on each database and click Properties, but it can be easier to
	scan across the results of sys.databases.  I look for any variations - are
	there some databases that have different settings than others?
*/
SELECT  *
FROM    sys.databases








/*
	Data files - where are they?  Are any on the C drive?  We want to avoid that
	because if they grow, they can fill up the OS drive, and that can lead to a
	very nasty crash.  Check out where the databases live.  The undocumented
	stored proc sp_msforeachdb runs a query inside each database.  There are
	more elegant ways to get this info, but I just wanted to show off this
	useful stored proc.  For tips on how to move databases off the C drive:
	http://support.microsoft.com/kb/224071
	In the results, also check the number of data and log files for all databases.

	We're going to create a temp table and get all of the results from each
	database's sys.database_files records using the kinda-sorta-undocumented
	stored procedure sp_MSforeachdb.  This is a neat technique you can use to
	combine results from DMVs for several databases at once.  There's other
	ways to get this data, but we're using this one to teach you that trick.
	
	In the results, review each file's drive location and autogrowth settings.
*/
CREATE TABLE #DatabaseFiles
    (
      [database_name] [sysname] NOT NULL ,
      [file_id] [int] NOT NULL ,
      [file_guid] [uniqueidentifier] NULL ,
      [type] [tinyint] NOT NULL ,
      [type_desc] [nvarchar](60) NULL ,
      [data_space_id] [int] NOT NULL ,
      [name] [sysname] NOT NULL ,
      [physical_name] [nvarchar](260) NOT NULL ,
      [state] [tinyint] NULL ,
      [state_desc] [nvarchar](60) NULL ,
      [size] [int] NOT NULL ,
      [max_size] [int] NOT NULL ,
      [growth] [int] NOT NULL ,
      [is_media_read_only] [bit] NOT NULL ,
      [is_read_only] [bit] NOT NULL ,
      [is_sparse] [bit] NOT NULL ,
      [is_percent_growth] [bit] NOT NULL ,
      [is_name_reserved] [bit] NOT NULL ,
      [create_lsn] [numeric](25, 0) NULL ,
      [drop_lsn] [numeric](25, 0) NULL ,
      [read_only_lsn] [numeric](25, 0) NULL ,
      [read_write_lsn] [numeric](25, 0) NULL ,
      [differential_base_lsn] [numeric](25, 0) NULL ,
      [differential_base_guid] [uniqueidentifier] NULL ,
      [differential_base_time] [datetime] NULL ,
      [redo_start_lsn] [numeric](25, 0) NULL ,
      [redo_start_fork_guid] [uniqueidentifier] NULL ,
      [redo_target_lsn] [numeric](25, 0) NULL ,
      [redo_target_fork_guid] [uniqueidentifier] NULL ,
      [backup_lsn] [numeric](25, 0) NULL
    )
EXEC dbo.sp_MSforeachdb 'INSERT INTO #DatabaseFiles SELECT ''[?]'' AS database_name, * FROM [?].sys.database_files'
SELECT  *
FROM    #DatabaseFiles
ORDER BY database_name ,
        type_desc
DROP TABLE #DatabaseFiles




/*
	Do any databases have multiple log files on the same drive letter?
	Theoretically, all database log access is sequential - first file to last,
	start to finish, and we don't get a performance gain from multiple log
	files.  However, there are rare cases when we need two log files in order
	to prevent out-of-space issues on our primary log file drive.  Bottom line,
	though, is that we should never have two log files for the same database
	on the same drive.
*/
--***


/*
	Do databases have different growth settings for different files inside
	the same filegroup?  Ideally, these should be consistent so that files grow
	evenly and get evenly accessed.
*/
EXEC dbo.sp_MSforeachdb 'SELECT DISTINCT (''The ? database has multiple data files in one filegroup, but they are not all set up to grow in identical amounts.  This can lead to uneven file activity inside the filegroup.'') FROM [?].sys.database_files WHERE type_desc = ''ROWS'' GROUP BY data_space_id HAVING COUNT(DISTINCT growth) > 1 OR COUNT(DISTINCT is_percent_growth) > 1' ;





/*
	Check for triggers in any database.  I may not change these right away, but I
	want to know if they are present, because knowing will help me troubleshoot faster.
	Without knowing the database has triggers, I probably will not think to look.
	
	We'll reuse our sp_MSforeachdb trick.  If you find yourself using this
	stored proc frequently, check out Aaron Bertrand's improvements to it:
	http://sqlblog.com/blogs/aaron_bertrand/archive/2010/12/29/a-more-reliable-and-more-flexible-sp-msforeachdb.aspx
*/
EXEC dbo.sp_MSforeachdb 'SELECT ''[?]'' AS database_name, o.name AS table_name, t.* FROM [?].sys.triggers t INNER JOIN [?].sys.objects o ON t.parent_id = o.object_id'



/*
	Check for disabled indexes.  Sometimes users disable indexes to improve insert
	performance during big loads, but they forget to enable the indexes again
	after the load finishes.
*/
EXEC dbo.sp_MSforeachdb 'SELECT DisabledIndexes = ''The index [?].['' + s.name + ''].['' + o.name + ''].['' + i.name + ''] is disabled.  This index is not actually helping performance and should either be enabled or removed.'' from [?].sys.indexes i INNER JOIN [?].sys.objects o ON i.object_id = o.object_id INNER JOIN [?].sys.schemas s ON o.schema_id = s.schema_id WHERE i.is_disabled = 1' ;





/*
	Non-trusted foreign keys and constraints - sometimes our users disable
	constraints temporarily to improve load performance, but they forget to
	enable them again, or don't enable them correctly.  You have to use the
	WITH CHECK CHECK CONSTRAINT parameter.  Otherwise, the engine doesn't really
	believe that all of the data will match your requirements, and you can get
	bad execution plans.					
	Learn more: http://sqlblog.com/blogs/hugo_kornelis/archive/2007/03/29/can-you-trust-your-constraints.aspx
*/
EXEC dbo.sp_MSforeachdb 'SELECT UntrustedForeignKeys = (''The foreign key [?].['' + s.name + ''].['' + o.name + ''].['' + i.name + ''] is not trusted - meaning, it was disabled, data was changed, and then the key was enabled again.  Simply enabling the key is not enough for the optimizer to use this key - we have to alter the table using the WITH CHECK CHECK CONSTRAINT parameter.'') from [?].sys.foreign_keys i INNER JOIN [?].sys.objects o ON i.parent_object_id = o.object_id INNER JOIN [?].sys.schemas s ON o.schema_id = s.schema_id WHERE i.is_not_trusted = 1' ;





/*
	SQL Server 2008 & newer only - check for plan guides.  These let us force an
	execution plan for a query.  If you've been struggling to tune a query and it
	just doesn't seem to get faster no matter what you do, there just might be a
	plan guide left over from a DBA who had too much time on their hands.
*/
EXEC dbo.sp_MSforeachdb 'SELECT ''[?]'' AS database_name, * FROM [?].sys.plan_guides WHERE is_disabled = 0'







/*
	Whew!  Now we've hit a lot of the major pain points around reliability.
	If you're under time pressure, you can stop here, because you've got a good
	idea of the basic challenges for this server.  
	
	Go back to the users and ask questions:
	- Can the business operate if this server is down?
	- How many employees have to stop working if this server goes down?
	- Who should I call when the server goes down?
	- Is this server covered by any security or compliance regulations?
	We can use their answers to build a good backup & recovery solution.
	
	If you've got more time, though, keep going, and we'll shift gears.
	Speaking of shifting gears, let's look at performance.  
*/






/* 
	How much memory does this server have available?  I get twitchy if the
	SQL Server has less than 256MB of memory available.  We might have set
	max server memory too high, although it'll take more research to know for
	sure.  Some people like to play it really close, but when they remote
	desktop into this SQL Server, they'll be using valuable memory for things
	like SSMS and IE, and might cause Windows to swap to disk. 2008 and above.
*/
SELECT  *
FROM    sys.dm_os_sys_memory m




/*
	Backups are a great background performance test.  They run every night,
	they read a lot of data, they write a lot of data, and SQL Server tracks
	performance for us.  Let's trend backup data over time to see if it's
	getting better or worse overall.  You can compare these numbers against the
	other SQL Servers in your environment, but also be aware of where SQL is
	reading the data from and where it's being written.  If either of those is
	slow, it'll impact your backup performance.
*/
SELECT  @@SERVERNAME AS ServerName ,
        YEAR(backup_finish_date) AS backup_year ,
        MONTH(backup_finish_date) AS backup_month ,
        CAST(AVG(( backup_size / ( DATEDIFF(ss, bset.backup_start_date,
                                            bset.backup_finish_date) )
                   / 1048576 )) AS INT) AS throughput_mb_sec_avg ,
        CAST(MIN(( backup_size / ( DATEDIFF(ss, bset.backup_start_date,
                                            bset.backup_finish_date) )
                   / 1048576 )) AS INT) AS throughput_mb_sec_min ,
        CAST(MAX(( backup_size / ( DATEDIFF(ss, bset.backup_start_date,
                                            bset.backup_finish_date) )
                   / 1048576 )) AS INT) AS throughput_mb_sec_max
FROM    msdb.dbo.backupset bset
WHERE   bset.type = 'D' /* full backups only */
        AND bset.backup_size > 5368709120 /* 5GB or larger */
        AND DATEDIFF(ss, bset.backup_start_date, bset.backup_finish_date) > 1 /* backups lasting over a second */
GROUP BY YEAR(backup_finish_date) ,
        MONTH(backup_finish_date)
ORDER BY @@SERVERNAME ,
        YEAR(backup_finish_date) DESC ,
        MONTH(backup_finish_date) DESC




/* 
	Sometimes certain backups go faster or slower depending on when they occur,
	the speed of their source drives, speed of their backup targets, etc. Let's
	break out backup throughput by database over time:
*/
SELECT  @@SERVERNAME AS ServerName ,
        database_name ,
        YEAR(backup_finish_date) AS backup_year ,
        MONTH(backup_finish_date) AS backup_month ,
        CAST(AVG(( backup_size / ( DATEDIFF(ss, bset.backup_start_date,
                                            bset.backup_finish_date) )
                   / 1048576 )) AS INT) AS throughput_mb_sec_avg ,
        CAST(MIN(( backup_size / ( DATEDIFF(ss, bset.backup_start_date,
                                            bset.backup_finish_date) )
                   / 1048576 )) AS INT) AS throughput_mb_sec_min ,
        CAST(MAX(( backup_size / ( DATEDIFF(ss, bset.backup_start_date,
                                            bset.backup_finish_date) )
                   / 1048576 )) AS INT) AS throughput_mb_sec_max
FROM    msdb.dbo.backupset bset
WHERE   bset.type = 'D' /* full backups only */
        AND bset.backup_size > 5368709120 /* 5GB or larger */
        AND DATEDIFF(ss, bset.backup_start_date, bset.backup_finish_date) > 1 /* backups lasting over a second */
GROUP BY database_name ,
        YEAR(backup_finish_date) ,
        MONTH(backup_finish_date)
ORDER BY @@SERVERNAME ,
        database_name ,
        YEAR(backup_finish_date) DESC ,
        MONTH(backup_finish_date) DESC






/*
	If you're using backup compression (whether it's native or third party),
	you can gain more details about throughput by examining compression
	metrics.  These queries get server-level and database-level backup speeds
	from the Quest LiteSpeed repositories, for example.
	
	The two below queries hit the LiteSpeedLocal repository for just one server
	at a time.  If you've configured the Quest LiteSpeedCentral repository, 
	where multiple SQL Servers can report data into one database, change the
	LiteSpeedLocal references in the FROM clause to point to your 
	LiteSpeedCentral database instead.
*/

/* Quest LiteSpeed - Backup throughput history by database */
SELECT  db.ServerName ,
        db.DatabaseName ,
        YEAR(FinishTime) AS backup_year ,
        MONTH(FinishTime) AS backup_month ,
        COUNT(*) AS backups ,
        CAST(AVG(NativeSize / BackupTime) AS INT) AS throughput_raw_mb_sec_avg ,
        CAST(MIN(NativeSize / BackupTime) AS INT) AS throughput_raw_mb_sec_min ,
        CAST(MAX(NativeSize / BackupTime) AS INT) AS throughput_raw_mb_sec_max ,
        CAST(AVG(BackupSize / BackupTime) AS INT) AS throughput_compressed_mb_sec_avg ,
        CAST(MIN(BackupSize / BackupTime) AS INT) AS throughput_compressed_mb_sec_min ,
        CAST(MAX(BackupSize / BackupTime) AS INT) AS throughput_compressed_mb_sec_max
FROM    LiteSpeedLocal.dbo.LitespeedActivity bset
        INNER JOIN LiteSpeedLocal.dbo.LitespeedDatabase db ON bset.ServerName = db.ServerName
                                                              AND bset.DatabaseID = db.DatabaseID
WHERE   bset.ActivityTypeID = 1 /* full backups only */
        AND bset.NativeSize > 5120 /* 5GB or larger */
        AND DATEDIFF(ss, bset.StartTime, bset.FinishTime) > 1 /* backups lasting over a second */
        AND bset.StatusTypeID = 2 /* Completed */
GROUP BY db.ServerName ,
        db.DatabaseName ,
        YEAR(FinishTime) ,
        MONTH(FinishTime)
ORDER BY db.ServerName ,
        db.DatabaseName ,
        YEAR(FinishTime) DESC ,
        MONTH(FinishTime) DESC



/* Quest LiteSpeed - Backup throughput history by server */
SELECT  db.ServerName ,
        YEAR(FinishTime) AS backup_year ,
        MONTH(FinishTime) AS backup_month ,
        COUNT(*) AS backups ,
        CAST(AVG(NativeSize / BackupTime) AS INT) AS throughput_raw_mb_sec_avg ,
        CAST(MIN(NativeSize / BackupTime) AS INT) AS throughput_raw_mb_sec_min ,
        CAST(MAX(NativeSize / BackupTime) AS INT) AS throughput_raw_mb_sec_max ,
        CAST(AVG(BackupSize / BackupTime) AS INT) AS throughput_compressed_mb_sec_avg ,
        CAST(MIN(BackupSize / BackupTime) AS INT) AS throughput_compressed_mb_sec_min ,
        CAST(MAX(BackupSize / BackupTime) AS INT) AS throughput_compressed_mb_sec_max
FROM    LiteSpeedLocal.dbo.LitespeedActivity bset
        INNER JOIN LiteSpeedLocal.dbo.LitespeedDatabase db ON bset.ServerName = db.ServerName
                                                              AND bset.DatabaseID = db.DatabaseID
WHERE   bset.ActivityTypeID = 1 /* full backups only */
        AND bset.NativeSize > 5120 /* 5GB or larger */
        AND DATEDIFF(ss, bset.StartTime, bset.FinishTime) > 1 /* backups lasting over a second */
        AND bset.StatusTypeID = 2 /* Completed */
GROUP BY db.ServerName ,
        YEAR(FinishTime) ,
        MONTH(FinishTime)
ORDER BY db.ServerName ,
        YEAR(FinishTime) DESC ,
        MONTH(FinishTime) DESC







/*
	SQL Server uses memory to cache database contents.  The more we can cache,
	the more we can make up for slow storage.  Unfortunately, we don't get to
	choose what SQL Server caches, and sometimes we can get surprised by what
	SQL chooses to cache.  Find out what databases are using the buffer pool
	by querying the sys.dm_os_buffer_descriptors DMV.  This query is based on
	Microsoft's example at:
	http://msdn.microsoft.com/en-us/library/ms173442.aspx
	For more information, check out Bill Graziano's post to show memory usage
	by table and index, too:
	http://www.sqlteam.com/article/what-data-is-in-sql-server-memory
	
	WARNING: this query can take time to run on servers with >64GB of memory.
*/
SELECT  CASE database_id
          WHEN 32767 THEN 'ResourceDb'
          ELSE DB_NAME(database_id)
        END AS database_name ,
        COUNT(*) AS cached_pages_count ,
        COUNT(*) * .0078125 AS cached_megabytes /* Each page is 8kb, which is .0078125 of an MB */
FROM    sys.dm_os_buffer_descriptors
GROUP BY DB_NAME(database_id) ,
        database_id
ORDER BY cached_pages_count DESC ;









/*
Index fragmentation is the leading cause of DBA heartburn. It is a lot like
file fragmentation, but it happens inside of the database.  The below script
shows fragmented objects that might be a concern.  BE WARY - this script can
take a great deal of time and be disruptive.  Consider running this only
after hours.
*/
SELECT  db.name AS databaseName ,
        ps.OBJECT_ID AS objectID ,
        ps.index_id AS indexID ,
        ps.partition_number AS partitionNumber ,
        ps.avg_fragmentation_in_percent AS fragmentation ,
        ps.page_count
FROM    sys.databases db
        INNER JOIN sys.dm_db_index_physical_stats(NULL, NULL, NULL, NULL,
                                                  N'Limited') ps ON db.database_id = ps.database_id
WHERE   ps.index_id > 0
        AND ps.page_count > 100
        AND ps.avg_fragmentation_in_percent > 30
OPTION  ( MAXDOP 1 ) ;






/*



   If you run across any query results that need some explanation,
   feel free to email us at Help@BrentOzar.com.  Enjoy the script!
*/