--SQL SERVER PLANNED RELOCATION PROCEDURE
--1 set db offline
ALTER DATABASE CGBIStage SET OFFLINE
--2 physically move files
--3 for each file moved run this
ALTER DATABASE CGBIStage MODIFY FILE (NAME = 'CGBIStage_log', FILENAME = 'D:\DBFilesTemp\CGBIStage_log.ldf')
--4 Run the following
ALTER DATABASE CGBIStage SET ONLINE
--5 Verify the file change
SELECT name, physical_name AS CurrentLocation, state_desc
FROM sys.master_files
WHERE database_id = DB_ID(N'<CGBIStage>');