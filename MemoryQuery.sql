SELECT cntr_value as Mem_KB, cntr_value/1024.0 as Mem_MB, (cntr_value/1048576.0) as Mem_GB FROM sys.dm_os_performance_counters  WHERE counter_name = 'Total Server Memory (KB)' 

--Total memory sql is allocated (also working set memory in resource monitor, some of this is shareable)
select physical_memory_in_use_kb/1024 as physical_memory_MB_working_set from sys.dm_os_process_memory
--Total memory sql is currently using (also private memory in task manager/resoure monitory
SELECT cntr_value as Mem_KB, cntr_value/1024.0 as Mem_MB, (cntr_value/1048576.0) as Mem_GB FROM sys.dm_os_performance_counters  WHERE counter_name = 'Total Server Memory (KB)' 
--Amount of memory sql would like to use to operate efficently
SELECT cntr_value as Mem_KB, cntr_value/1024.0 as Mem_MB, (cntr_value/1048576.0) as Mem_GB FROM sys.dm_os_performance_counters  WHERE counter_name = 'Target Server Memory (KB)' 


--max server memory configuration
SELECT [name] AS [Name], [value] AS [ConfigValue]
FROM [master].[sys].[configurations]
WHERE NAME ='Max server memory (MB)'