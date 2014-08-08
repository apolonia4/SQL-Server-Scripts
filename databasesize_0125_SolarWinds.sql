SELECT m.file_id,@@ServerName, s.name, CONVERT(DECIMAL(10,2),(SUM(size * 8.00) / 1024.00 / 1024.00)) As UsedSpaceGB
FROM master.sys.master_files m
inner join sys.databases s
on s.database_id = m.database_id
group by s.name, m.file_id

select * from sys.master_Files