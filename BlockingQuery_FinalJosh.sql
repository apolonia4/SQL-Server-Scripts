select 
db_name(r.database_id) as Databasename
, r.start_time
, r.command
, s.memory_usage
, s.host_name
, s.program_name
, s.login_name
, r.session_id as RequestingSPID
, h2.text as RequestingQuery 
, r.blocking_session_id as BlockingSPID
, hblocking.text as BlockingQuery
from sys.dm_exec_requests r
join sys.dm_exec_connections c on
r.session_id = c.session_id
join sys.dm_exec_connections c2 on
r.blocking_session_id = c2.session_id
join sys.dm_exec_sessions s 
on s.session_id = r.session_id
CROSS APPLY sys.dm_exec_sql_text (c2.most_recent_sql_handle) as hblocking
CROSS APPLY sys.dm_exec_sql_text (c.most_recent_sql_handle) as h2
where r.session_id > 50 and r.blocking_session_id > 1