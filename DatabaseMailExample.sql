sp_CONFIGURE 'show advanced', 1
 GO
 RECONFIGURE
 GO
 sp_CONFIGURE 'Database Mail XPs', 1
 GO
 RECONFIGURE
 GO 
 
 USE msdb
 GO
 EXEC sp_send_dbmail @profile_name='PinalProfile',
 @recipients='test@Example.com',
 @subject='Test message',
 @body='This is the body of the test message.
 Congrates Database Mail Received By you Successfully.' 
 
 
SELECT * FROM sysmail_mailitems
GO
SELECT * FROM sysmail_log
GO 
SELECT * FROM sysmail_sentitems
GO 
SELECT * FROM sysmail_unsentitems
GO 
SELECT * FROM sysmail_allitems
GO 
SELECT * FROM sysmail_faileditems
GO 

