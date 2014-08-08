USE master;
GO
--Create master key in the master database (Database Master Key in the Master Database must be created first)
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '1Passw0rd!';
go
--Create server certificate in the master database
CREATE CERTIFICATE MyServerCert WITH SUBJECT = 'My Test Certificate';
go
--Create a database encryption key
USE myTestDatabase;
GO
CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE MyServerCert;
GO
ALTER DATABASE myTestDatabase
SET ENCRYPTION ON;
GO

/*Backup Certificate*/
USE MASTER
go
BACKUP CERTIFICATE MyServerCert TO FILE = 'c:\myServerCert.cert'
 WITH PRIVATE KEY ( FILE = 'c:\myServerkey.pvk' , 
    ENCRYPTION BY PASSWORD = '1Password!' );
GO
/*TO RESTORE DB ON ANOTHER SERVER...Copy Certificate backup file and key file to server then
run the command below.  */
use master
go
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '1Passw0rd!';
go
CREATE CERTIFICATE myServerCert
    FROM FILE = 'c:\WorkSpace\myServerCert' 
    WITH PRIVATE KEY (FILE = 'c:\WorkSpace\myServerkey', 
    DECRYPTION BY PASSWORD = '1Password!');
GO 


/*To Cleanup After Testing*/
use myTestDatabase
go
DROP CERTIFICATE MyServerCert
GO
DROP MASTER KEY
GO
USE [master]
GO
DROP DATABASE myTestDatabase
GO