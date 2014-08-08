USE AdventureWorks2008r2
GO
IF OBJECT_ID (N'ProductDocs', N'U') IS NOT NULL
DROP TABLE ProductDocs
GO
CREATE TABLE ProductDocs (
  DocID INT NOT NULL IDENTITY,
  DocTitle NVARCHAR(50) NOT NULL,
  DocFilename NVARCHAR(400) NOT NULL,
  FileExtension NVARCHAR(8) NOT NULL,
  DocSummary NVARCHAR(MAX) NULL,
  DocContent VARBINARY(MAX) NULL,
  CONSTRAINT [PK_ProductDocs_DocID] PRIMARY KEY CLUSTERED (DocID ASC)
)
GO
INSERT INTO ProductDocs
(DocTitle, DocFilename, FileExtension, DocSummary, DocContent)
SELECT Title, FileName, FileExtension, DocumentSummary, Document
FROM Production.Document
 
GO

--Create full text catalog
CREATE FULLTEXT CATALOG ProductFTS 
WITH ACCENT_SENSITIVITY = OFF

--Check Collation
SELECT name, collation_name FROM sys.databases 
WHERE name = 'AdventureWorks2008R2'

SELECT fulltext_catalog_id, name FROM sys.fulltext_catalogs

--Create fulltext index
CREATE FULLTEXT INDEX ON ProductDocs
(DocSummary, DocContent TYPE COLUMN FileExtension LANGUAGE 1033)
KEY INDEX PK_ProductDocs_DocID
ON ProductFTS
WITH STOPLIST = SYSTEM

SELECT t.name AS TableName, c.name AS FTCatalogName
FROM sys.tables t JOIN sys.fulltext_indexes i
  ON t.object_id = i.object_id
JOIN sys.fulltext_catalogs c
ON i.fulltext_catalog_id = c.fulltext_catalog_id

SELECT display_term, column_id, document_count 
FROM sys.dm_fts_index_keywords
(DB_ID('AdventureWorks2008R2'), OBJECT_ID('ProductDocs'))












