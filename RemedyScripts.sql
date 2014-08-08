sp_changedbowner ARAdmin
USE tempdb

CREATE DATABASE "ARSystem" 
ON (NAME = "ARSystem_data", FILENAME ='c:\data\ARSys.mdf', SIZE = 500MB) 
LOG ON (NAME ="ARSystempt_log", FILENAME = 'c:\data\ARSysLog.ldf', SIZE = 100MB)

CREATE LOGIN "ARAdmin" WITH PASSWORD = 'AR#Admin#', DEFAULT_DATABASE = ARSystem

use ARSystem
GO
CREATE USER "ARAdmin" FOR LOGIN "ARAdmin"
GO
sp_addrolemember 'db_owner', 'ARAdmin'
GO
