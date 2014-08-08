select ss.next_run_date, ss.next_run_time, sj.name from msdb.dbo.sysjobschedules ss
inner join msdb.dbo.sysjobs sj
on sj.job_id = ss.job_id
where next_run_time = 220000
order by next_run_time