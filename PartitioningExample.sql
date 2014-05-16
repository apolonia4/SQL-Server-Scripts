USE Master;
GO
--- Step 1 : Create New Test Database with two different filegroups.
IF EXISTS (
SELECT name
FROM sys.databases
WHERE name = N'TestDB2')
DROP DATABASE TestDB2;
GO
CREATE DATABASE TestDB2
ON PRIMARY
(NAME='TestDB_Part1',
FILENAME=
'C:\Users\xxx\Documents\TestDB2_Part1.mdf',
SIZE=4,
MAXSIZE=100,
FILEGROWTH=1 ),
FILEGROUP TestDB_Part2
(NAME = 'TestDB_Part2',
FILENAME =
'C:\Users\xxx\Documents\TestDB2_Part2.ndf',
SIZE = 4,
MAXSIZE=100,
FILEGROWTH=1 );
GO


USE TestDB;
GO
--- Step 2 : Create Partition Range Function
CREATE PARTITION FUNCTION TestDB_PartitionRange (INT)
AS RANGE LEFT FOR
VALUES (10);
GO

USE TestDB;
GO
--- Step 3 : Attach Partition Scheme to FileGroups
CREATE PARTITION SCHEME TestDB_PartitionScheme
AS PARTITION TestDB_PartitionRange
TO ([PRIMARY], TestDB_Part2);
GO


USE TestDB2;
GO
--- Step 4 : Create Table with Partition Key and Partition Scheme
CREATE TABLE TestTable
(ID INT NOT NULL,
Date DATETIME)
ON TestDB_PartitionScheme (ID);
GO


USE TestDB2;
GO
--- Step 5 : (Optional/Recommended) Create Index on Partitioned Table
CREATE UNIQUE CLUSTERED INDEX IX_TestTable
ON TestTable(ID)
ON TestDB_PartitionScheme (ID);
GO

USE TestDB;
GO
--- Step 6 : Insert Data in Partitioned Table
INSERT INTO TestTable (ID, Date) -- Inserted in Partition 1
VALUES (1,GETDATE());
INSERT INTO TestTable (ID, Date) -- Inserted in Partition 2
VALUES (11,GETDATE());
INSERT INTO TestTable (ID, Date) -- Inserted in Partition 2
VALUES (12,GETDATE());
GO
INSERT INTO TestTable (ID, Date) -- Inserted in Partition 2
VALUES (10,GETDATE());
GO
INSERT INTO TestTable (ID, Date) -- Inserted in Partition 2
VALUES (9,GETDATE());
GO


USE TestDB;
GO
--- Step 7 : Test Data from TestTable
SELECT *
FROM TestTable;
GO

USE TestDB;
GO
--- Step 8 : Verify Rows Inserted in Partitions










