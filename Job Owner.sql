select s.name,l.name
 from  msdb..sysjobs s 
 left join master.sys.syslogins l on s.owner_sid = l.sid