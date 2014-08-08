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