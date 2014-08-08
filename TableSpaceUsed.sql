SET NOCOUNT ON DBCC UPDATEUSAGE(0) -- DB size.
EXEC sp_spaceused-- Table row counts and sizes.
DECLARE @TableSpace Table 
(
[name] NVARCHAR(128)
,[rows] CHAR(11)
,reserved VARCHAR(18)
,data VARCHAR(18)
,index_size VARCHAR(18)
,unused VARCHAR(18)
)

INSERT @TableSpace 
EXEC sp_msForEachTable 'EXEC sp_spaceused ''?''' 
SELECT * FROM @TableSpace
ORDER BY Data desc

-- # of rows.
SELECT SUM(CAST([rows] AS int)) AS [rows] FROM @TableSpace