ALTER DATABASE Masi2Dev
          ADD FILEGROUP FileStreamGroup CONTAINS FILESTREAM;
ALTER DATABASE Masi2Dev
          ADD FILE
                   (NAME = FileStreamData ,FILENAME = 'C:\MSSQL\Data'
          ) TO FILEGROUP FileStreamGroup;

USE TEST_DB
 GO
 CREATE TABLE FILETABLE
 (
 ID     INT IDENTITY,
 GUID    UNIQUEIDENTIFIER ROWGUIDCOL NOTNULL UNIQUE,
 DATA     VARBINARY(MAX) FILESTREAM
 );



select * from filestreamdatastorage


Use FileStreamDB
GO
INSERT INTO [FileStreamDataStorage] (FileStreamData) 
SELECT * FROM OPENROWSET(BULK N'D:\WorkSpace\Breslyn.jpg', SINGLE_BLOB) AS Document
GO 

uspFileStreamIns 




USE FileStreamDB
GO
SELECT ID, FileStreamData
, FileStreamDataGUID
, [DateTime]
FROM [FileStreamDataStorage]
GO

--Get Path name
DECLARE @filePath varchar(max)
SELECT @filePath = FileStreamData.PathName()
FROM FileStreamDataStorage
WHERE ID = 3
PRINT @filepath

--Get Transaction Context
DECLARE @txContext varbinary(max)
BEGIN TRANSACTION
SELECT @txContext = GET_FILESTREAM_TRANSACTION_CONTEXT()
PRINT @txContext
COMMIT





