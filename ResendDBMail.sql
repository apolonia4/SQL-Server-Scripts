--SELECT * FROM dbo.sysmail_log

DECLARE SYSMAIL_LOG_RESEND_CURSOR CURSOR READ_ONLY FOR
SELECT DISTINCT
l.mailitem_id
, p.name
, m.recipients
, m.subject
, m.body_format
, m.body
FROM msdb.dbo.sysmail_log l WITH (NOLOCK)
JOIN msdb.dbo.sysmail_mailitems m WITH (NOLOCK)
ON m.mailitem_id = l.mailitem_id
JOIN msdb.dbo.sysmail_profile p WITH (NOLOCK)
ON p.profile_id = m.profile_id
WHERE
l.event_type = 3
AND m.sent_status = 2
AND l.log_date > '2013-02-08 17:30:00.000'
ORDER BY
l.mailitem_id

OPEN SYSMAIL_LOG_RESEND_CURSOR

WHILE (1=1) BEGIN
DECLARE
@mailitem_id int
, @profile_name nvarchar(128)
, @recipients varchar(max)
, @subject nvarchar(255)
, @body_format varchar(20)
, @body nvarchar(max)
FETCH NEXT FROM SYSMAIL_LOG_RESEND_CURSOR INTO
@mailitem_id
, @profile_name
, @recipients
, @subject
, @body_format
, @body
IF NOT @@FETCH_STATUS = 0 BEGIN
BREAK
END

PRINT CONVERT(varchar, GETDATE(), 121) + CHAR(9) + CONVERT(varchar, @mailitem_id) + CHAR(9) + @recipients

EXEC msdb.dbo.sp_send_dbmail
@profile_name = @profile_name
, @recipients = @recipients
, @subject = @subject
, @body_format = @body_format
, @body = @body

UPDATE msdb.dbo.sysmail_mailitems
SET
sent_status = 3
WHERE
mailitem_id = @mailitem_id

END

CLOSE SYSMAIL_LOG_RESEND_CURSOR

DEALLOCATE SYSMAIL_LOG_RESEND_CURSOR

GO
