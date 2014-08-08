USE tempdb ;
GO 

--create a table for the demo
CREATE TABLE demo
        (
         column1 INT NOT NULL
                     IDENTITY
        ,column2 VARCHAR(10)
        ) ; 

--start a transaction
BEGIN TRANSACTION ; 

--insert a row into the transaction
INSERT
        demo ( column2 )
VALUES  ( 'something' ) ; 



USE tempdb ;
GO 

--what's the dbid for tempdb?
DECLARE @dbid INT ; 
SET @dbid = DB_ID() ; 

--what's objectid for our demo table?
DECLARE @objectid INT ;
SET @objectid = OBJECT_ID(N'tempdb.dbo.demo') ; 


--look at locking in the tempdb
SELECT
        resource_type
       ,resource_database_id
       ,resource_associated_entity_id
       ,request_mode
       ,request_type
       ,request_session_id
FROM
        sys.dm_tran_locks
WHERE
        resource_database_id = @dbid ; 

--limit the results to only the demo table
SELECT
        *
FROM
        sys.dm_tran_locks
WHERE
        resource_database_id = @dbid AND
        resource_associated_entity_id = @objectid ; 


select * from sys.dm_tran_locks

commit transaction


sp_who2
sp_lock
kill 76

select * from sys.dm_os_wait_stats
select * from sys.dm_os_wait_stats

select * from sys.dm_tran_locks
