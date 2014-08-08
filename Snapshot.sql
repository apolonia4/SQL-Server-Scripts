USE master
 GO
 -- Create Regular Database
 CREATE DATABASE RegularDB
 GO
 USE RegularDB
 GO
 -- Populate Regular Database with Sample Table
 CREATE TABLE FirstTable (ID INT, Value VARCHAR(10))
 INSERT INTO FirstTable VALUES(1, 'First');
 INSERT INTO FirstTable VALUES(2, 'Second');
 INSERT INTO FirstTable VALUES(3, 'Third');
 GO
 -- Create Snapshot Database
 CREATE DATABASE SnapshotDB ON
 (Name ='RegularDB',
 FileName='c:\SSDB.ss1')
 AS SNAPSHOT OF RegularDB;
 GO
 -- Select from Regular and Snapshot Database
 SELECT * FROM RegularDB.dbo.FirstTable;
 SELECT * FROM SnapshotDB.dbo.FirstTable;
 GO
 -- Delete from Regular Database
 DELETE FROM RegularDB.dbo.FirstTable;
 GO
 -- Select from Regular and Snapshot Database
 SELECT * FROM RegularDB.dbo.FirstTable;
 SELECT * FROM SnapshotDB.dbo.FirstTable;
 GO
 -- Restore Data from Snapshot Database
 USE master
 GO
 RESTORE DATABASE RegularDB
 FROM DATABASE_SNAPSHOT = 'SnapshotDB';
 GO
 -- Select from Regular and Snapshot Database
 SELECT * FROM RegularDB.dbo.FirstTable;
 SELECT * FROM SnapshotDB.dbo.FirstTable;
 GO
 -- Clean up
 DROP DATABASE [SnapshotDB];
 DROP DATABASE [RegularDB];
 GO
 
Pinal Dave (http://blog.SQLAuthority.com)