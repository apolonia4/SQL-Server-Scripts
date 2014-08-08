SELECT st.name as TableName, si.name as IndexName, * FROM sys.dm_db_index_physical_stats
    (DB_ID(N'dbname'), NULL, NULL, NULL , 'LIMITED') IPS
   JOIN sys.tables ST WITH (nolock) ON IPS.object_id = ST.object_id
   JOIN sys.indexes SI WITH (nolock) ON IPS.object_id = SI.object_id AND IPS.index_id = SI.index_id
WHERE ST.is_ms_shipped = 0
AND page_count > 1000
order by avg_fragmentation_in_percent desc


select * from sys.tables where object_id = 6291082



select * FROM sys.dm_db_index_physical_stats
    (DB_ID(N'dbname'), NULL, NULL, NULL , 'SAMPLED') --option are LIMITED, DETAILED, SAMPLED 
	where page_count > 1000
	order by avg_fragmentation_in_percent desc
