select 
r.session_id as SPID,
r.start_time,
DBName = db_name(database_id),
r.Command,
substring(st.text,
r.statement_start_offset/2+1,
(case when r.statement_end_offset = -1 then len(convert(nvarchar(max), st.text)) * 2 else r.statement_end_offset end - r.statement_start_offset)/2+1) As BlockedQuery,
r.Blocking_session_id,
s.Memory_usage,
s.Host_name,
s.Program_name,
s.Login_name
from sys.dm_exec_requests r
join sys.dm_exec_connections c on r.session_id = c.session_id
join sys.dm_exec_sessions s on s.session_id = r.session_id
cross apply sys.dm_exec_sql_text(r.sql_handle) st
where r.session_id > 50 and r.blocking_session_id>1
order by r.session_id


SELECT * FROM sys.dm_exec_requests
sp_who2
