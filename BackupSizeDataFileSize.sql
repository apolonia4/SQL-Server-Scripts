select b.database_name, backup_size/1073741824 as BackupSizeGB, ((m.size*8.0)/1024.0)/1024.0 as DataFileSizeGB from msdb.dbo.backupset b
inner join sys.databases d
on b.database_name = d.name
AND d.database_id > 4 and b.type = 'D'
INNER join sys.master_files m
ON d.database_id = m.database_id
AND type_desc = 'ROWS'
where b.backup_start_date > DateAdd(DD, -1, GetDate()) 
group by backup_size, b.backup_start_date, b.database_name, m.size
order by backup_start_date desc
