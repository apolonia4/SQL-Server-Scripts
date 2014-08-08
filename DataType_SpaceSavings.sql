/*=============================================
  File: check_datatype_int_memory.sql
 
  Author: Thomas LaRock, http://thomaslarock.com/contact-me/
 
  Summary: This script will verify defined datatypes to the data
           that currently exists. 
 
  Returns: Two (2) results sets. The first is for an estimate of 
           disk space savings. The second is for potential
           logical I/O savings.
 
  Date: September 11th, 2012
 
  SQL Server Versions: SQL2005, SQL2008, SQL2008R2, SQL2012
 
  You may alter this code for your own purposes. You may republish
  altered code as long as you give due credit. 
 
  THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY
  OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT
  LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR
  FITNESS FOR A PARTICULAR PURPOSE.
 
=============================================*/
 
--CHANGE TO WHATEVER DATABASE YOU WANT TO EVALUATE
USE RunBook
GO
 
SET NOCOUNT ON
SET ANSI_WARNINGS OFF
 
IF  EXISTS (SELECT * FROM tempdb.dbo.sysobjects 
WHERE id = OBJECT_ID(N'tempdb..#tmp_ValDT') 
AND type in (N'U'))
DROP TABLE #tmp_ValDT
GO
 
IF  EXISTS (SELECT * FROM tempdb.dbo.sysobjects 
WHERE id = OBJECT_ID(N'tempdb..#tmp_spTmp') 
AND type in (N'U'))
DROP TABLE #tmp_spTmp
GO
 
IF  EXISTS (SELECT * FROM tempdb.dbo.sysobjects 
WHERE id = OBJECT_ID(N'tempdb..#tmp_bufObj') 
AND type in (N'U'))
DROP TABLE #tmp_bufObj
GO
 
CREATE TABLE #tmp_ValDT
	(stmt nvarchar(max) NULL,
	min_val bigint NULL,
	max_val bigint NULL,
	rc bigint,
	table_name sysname,
	schema_name sysname,
	column_name sysname,
	TypeName sysname,
	recomm_DT sysname NULL,
	recomm_byte smallint NULL,
	max_length smallint,
	precision tinyint,
	scale tinyint)
GO
 
CREATE TABLE #tmp_spTmp
	(name nvarchar(128) NULL,
	rows char(11) NULL,
	reserved varchar(18) NULL,
	data varchar(18) NULL,
	index_size varchar(18) NULL,
	unused varchar(18))
GO
 
CREATE TABLE #tmp_bufObj
	(name nvarchar(128) NULL,
	objname sysname NULL,
	type nvarchar(60) NULL,
	Buffered_Page_Count int NULL,
	Buffer_MB int NULL
	)
GO
 
--find the tables currently in memory
INSERT INTO #tmp_bufObj
SELECT obj.[name] AS [TableName], --nvarchar(128)
	i.[name] AS [Objname], --sysname
	i.[type_desc] AS [Type], --nvarchar(60)
	COUNT_BIG(*) AS [Buffered_Page_Count], --int
	COUNT_BIG(*) * 8192 / (1024 * 1024) as [Buffer_MB] --int
FROM sys.dm_os_buffer_descriptors AS bd 
    INNER JOIN 
    (
        SELECT object_name(object_id) AS name 
            ,index_id ,allocation_unit_id, object_id
        FROM sys.allocation_units AS au
            INNER JOIN sys.partitions AS p 
                ON au.container_id = p.hobt_id 
                    AND (au.type = 1 OR au.type = 3)
        UNION ALL
        SELECT object_name(object_id) AS name   
            ,index_id, allocation_unit_id, object_id
        FROM sys.allocation_units AS au
            INNER JOIN sys.partitions AS p 
                ON au.container_id = p.hobt_id 
                    AND au.type = 2
    ) AS obj 
        ON bd.allocation_unit_id = obj.allocation_unit_id
LEFT JOIN sys.indexes i on i.object_id = obj.object_id 
	AND i.index_id = obj.index_id
INNER JOIN sys.objects o on i.object_id = o.object_id
WHERE database_id = db_id()
AND o.type <> 'S'
GROUP BY obj.name, obj.index_id , i.[name],i.[type_desc]
ORDER BY Buffered_Page_Count DESC
 
--build table by joining to what is in memory currently
INSERT INTO #tmp_ValDT
SELECT '' AS stmt
, NULL -- min value not known yet
, NULL -- max value not known yet
, NULL -- rowcount not known yet
, tbl.name AS table_name
, SCHEMA_NAME(tbl.schema_id) AS schema_name
, col.name AS column_name
, t.name AS TypeName
, NULL -- recommended DT not known yet
, NULL -- recommended DT bytes known yet
, col.max_length
, col.PRECISION
, col.scale
FROM sys.tables AS tbl
INNER JOIN sys.columns col ON tbl.OBJECT_ID = col.OBJECT_ID
INNER JOIN sys.types t ON col.user_type_id = t.user_type_id
--not evaluating user defined datatypes, or MAX types, at this time
INNER JOIN #tmp_bufObj bo ON tbl.name = bo.name COLLATE DATABASE_DEFAULT
WHERE t.is_user_defined = 0
AND t.is_assembly_type = 0
AND col.max_length <> -1
ORDER BY schema_name, table_name;
 
DECLARE @SQL nvarchar(max)
DECLARE DT CURSOR
FOR 
SELECT table_name, schema_name, column_name, TypeName, max_length 
FROM #tmp_ValDT
 
DECLARE @table_name sysname, @schema_name sysname
DECLARE @column_name sysname, @TypeName sysname
DECLARE @min_val nvarchar(max), @max_val nvarchar(max)
DECLARE @max_length nvarchar(max), @rc nvarchar(max), @max_lenOUT nvarchar(max)
OPEN DT
 
FETCH NEXT FROM DT INTO @table_name, @schema_name, @column_name, @TypeName, @max_length
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
 
		IF @TypeName IN ('tinyint', 'smallint', 'int', 'bigint')
		BEGIN
 
			SET @SQL = 'SELECT @min_val = MIN(['+@column_name+']), @max_val = MAX(['+@column_name+']), @rc = COUNT(*) FROM ['+@schema_name+'].['+@table_name+']'		
			EXEC sp_executesql @SQL, N'@min_val bigint OUTPUT
			, @max_val bigint OUTPUT
			, @rc bigint OUTPUT', @min_val = @min_val OUTPUT, @max_val = @max_val OUTPUT, @rc = @rc OUTPUT
 
			IF CONVERT(BIGINT, @min_val) < -2147483648 OR CONVERT(BIGINT, @max_val) > 2147483648
				BEGIN
					UPDATE #tmp_ValDT
					SET stmt = @SQL, min_val = @min_val, max_val = @max_val, rc = @rc,
						recomm_DT = 'bigint', recomm_byte = 8
					WHERE CURRENT OF DT
				END
			ELSE IF @min_val < -32768 OR @max_val > 32768
				BEGIN
					UPDATE #tmp_ValDT
					SET stmt = @SQL, min_val = @min_val, max_val = @max_val, rc = @rc,
						recomm_DT = 'int', recomm_byte = 4
					WHERE CURRENT OF DT
				END
			ELSE IF @min_val < 0 OR @max_val > 255
				BEGIN
					UPDATE #tmp_ValDT
					SET stmt = @SQL, min_val = @min_val, max_val = @max_val, rc = @rc,
						recomm_DT = 'smallint', recomm_byte = 2
					WHERE CURRENT OF DT
				END
			ELSE IF @min_val >= 0 AND @min_val <= 255 AND @max_val >= 0 AND @max_val <= 255
				BEGIN
					UPDATE #tmp_ValDT
					SET stmt = @SQL, min_val = @min_val, max_val = @max_val, rc = @rc,
						recomm_DT = 'tinyint', recomm_byte = 1
					WHERE CURRENT OF DT
				END
			ELSE IF @min_val IS NULL OR @max_val IS NULL
				BEGIN
					PRINT 'empty tables: ' + @SQL
				END
			ELSE
				BEGIN
					PRINT 'how did i get here int?'
				END
		END
 
	END
	FETCH NEXT FROM DT INTO @table_name, @schema_name, @column_name, @TypeName, @max_length
END
 
CLOSE DT
DEALLOCATE DT
GO
 
INSERT INTO #tmp_spTmp
EXEC sp_MSforeachtable 'EXECUTE sp_spaceused [?];'
 
--summarize the possible space savings
SELECT schema_name + '.' + table_name AS [Tablename]
, column_name AS [ColumnName], TypeName AS [CurrentDT]
, max_length AS [Length], recomm_DT AS [RecommendedDT]
, recomm_byte AS [RecommendedLength]
, CASE WHEN recomm_DT NOT IN ('varchar', 'char')
	THEN ((max_length - recomm_byte) * rc)/(1024.0*1024.0) 
	ELSE (recomm_byte * 2)/(1024.0*1024.0) 
	END AS [Space_Saved_MB]
FROM #tmp_ValDT
WHERE TypeName <> recomm_DT
AND recomm_byte <> 0
ORDER BY [Space_Saved_MB] DESC
 
--summarize the possible logical i/o savings
SELECT vdt.table_name, SUM(vdt.max_length-vdt.recomm_byte) AS [row_savings_bytes] 
, SUM(vdt.max_length-vdt.recomm_byte) * spt.rows / 8192 AS [LIO_savings_pages]
FROM #tmp_ValDT vdt INNER JOIN #tmp_spTmp spt ON vdt.table_name = spt.name
GROUP BY vdt.table_name, spt.rows
ORDER BY 3 DESC