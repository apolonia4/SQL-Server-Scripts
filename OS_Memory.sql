SELECT total_physical_memory_kb, available_physical_memory_kb,
 total_page_file_kb, available_page_file_kb,
 system_memory_state_desc
 FROM sys.dm_os_sys_memory WITH (NOLOCK) OPTION (RECOMPILE);
 