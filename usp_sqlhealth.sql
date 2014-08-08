USE [master]
GO

/****** Object:  StoredProcedure [dbo].[usp_sqlhealth]    Script Date: 12/27/2011 22:13:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[usp_sqlhealth]
as
  set nocount on 

  declare @min_server_memory_config int 
  declare @max_server_memory_config int 
  declare @min_server_memory_run int 
  declare @max_server_memory_run int 
  declare @NumberOfCPU int 
  declare @MemoryInMB int 
  declare @SQLServerVersion int 
  declare @MultiProtocol int 
  declare @TCPsockets int 

  create table #fr98e53
  ([Analysis Report] varchar(3000)) 

  create table #t_serverinfo
  ([Index] int, [Name] varchar(255), Internal_Value int, 
    Character_Value varchar(255)) create table #t ([name] varchar(128), 
    minimum int, maximum int, config_value int, run_value int) 

  insert into #t ([name], minimum, maximum, config_value, run_value) 
  Execute sp_configure 

  insert into #t_serverinfo( [Index] , [Name] , Internal_Value , Character_Value ) 
  exec master..xp_msver 

  select @NumberOfCPU = Internal_Value 
  from #t_serverinfo 
  where [Name] = 'ProcessorCount' 

  select @MemoryInMB = Internal_Value 
  from #t_serverinfo 
  where [Name] = 'PhysicalMemory' 

  select @SQLServerVersion = convert(int,substring(Character_Value,1,charindex('.',Character_Value)-1) 
    + substring(Character_Value,charindex('.',Character_Value) + 1,1)) 
  from #t_serverinfo 
  where [Name] = 'ProductVersion' 

  set @min_server_memory_config = 0 
  set @max_server_memory_config = 0 
  set @min_server_memory_run = 0 
  set @max_server_memory_run = 0 

  select @max_server_memory_config = config_value 
  from #t 
  where [name] = 'max server memory (MB)' 

  select @max_server_memory_run = run_value 
  from #t 
  where [name] = 'max server memory (MB)' 

  select @min_server_memory_config = config_value 
  from #t 
  where [name] = 'min server memory (MB)' 

  select @min_server_memory_run = run_value 
  from #t 
  where [name] = 'min server memory (MB)' 

  if exists (select 1 
             from #t 
             where [name] = 'affinity mask' 
               and (config_value <> 0 or run_value <> 0)) 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'ALERT! Recommend affinity mask value should be set to 0 ' 
        from #t 
        where name = 'affinity mask' 
    End 

  if @@rowcount = 0  
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'affinity mask - OK!' 
    End 

  if exists (select 1 
             from #t 
             where [name] = 'allow updates' 
               and (config_value <> 0 or run_value <> 0)) 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'ALERT! Recommend allow updates value should be set to 0 ' 
        from #t 
        where name = 'allow updates' 
    End 

  if @@rowcount = 0 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'allow updates is 0 - OK!' 
    End 

  if exists (select 1 
             from #t 
             where [name] = 'fill factor (%)' 
               and ((config_value between 1 and 49) 
               or (run_value between 1 and 49))) 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'ALERT! Recommend fill factor(%) value should be set to 0 or >= 50 ' 
        from #t 
        where name = 'fill factor (%)' 
    End 

  if @@rowcount =0 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'fill factor(%) - OK!' 
    End 

  if exists (select 1 
             from #t 
             where [name] = 'lightweight pooling' 
               and (config_value <> 0 or run_value <> 0)) 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'ALERT! Recommend lightweight pooling value should be set to 0 ' 
        from #t 
        where name = 'lightweight pooling' 
    End 

  if @@rowcount =0 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'lightweight pooling - OK!' 
    End 

  if exists (select 1 
             from #t 
             where [name] = 'locks' 
               and ((config_value between 1 and 9999) 
               or (run_value between 1 and 9999))) 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'ALERT! Recommend locks value should be set to 0(best) or >= 10000 ' 
        from #t 
        where name = 'locks' 
    End 

  If @@rowcount =0 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'locks - OK!' 
  End 

  if exists (select 1 
             from #t 
             where [name] = 'max async IO' 
               and (config_value < 32 or run_value < 32)) 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'ALERT! Recommend max async IO value should be set to 32 or more' 
        from #t 
        where name = 'max async IO' 
   End 
 
  if @@rowcount =0 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select  'max async IO - OK!' 
    End 

  if exists (select 1 
             from #t 
             where [name] = 'max server memory (MB)' 
               and ((config_value < 32 or run_value < 32) 
               or (config_value < @MemoryInMB - 48 
               or run_value < @MemoryInMB - 48))) 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'ALERT! Recommend max server memory(MB) value should be set to max_of( 32 or (total RAM - 48MB) ) ' 
        from #t 
        where name = 'max server memory (MB)' 
    End 

  if @@rowcount =0 
    begin 
      insert into #fr98e53([Analysis Report]) 
      select 'max server memory(MB) - OK!' 
    End 

  if exists (select 1 
             from #t 
             where [name] = 'min memory per query (KB)' 
               and (config_value < 1024 or run_value < 1024)) 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'ALERT! Recommend min memory per query(KB) value should be set at 1024' 
        from #t where name = 'min memory per query (KB)' 
    End 

  if @@rowcount =0 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'min memory per query(KB) - OK!' 
    End 

  if exists (select 1 
             from #t 
             where [name] = 'network packet size (B)' 
               and ((config_value < 4096 
               or config_value > 16384) 
               or (run_value < 4096 
               or run_value > 16384))) 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'ALERT! Recommend network packet size(B) value should be set to 4096(best) or <= 16Kb' 
        from #t 
        where name = 'network packet size (B)' 
    End 

  if @@rowcount = 0 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'network packet size - OK!' 
    End 

  if exists (select 1 
             from #t 
             where [name] = 'open objects' 
               and (config_value <> 0 
               or run_value <> 0)) 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'ALERT! Recommend open objects value should be set to 0 ' 
        from #t 
        where name = 'open objects' 
    End 

  if @@rowcount =0 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'open objects - OK!' 
    End 

  if exists (select 1 
             from #t 
             where [name] = 'priority boost' 
               and (config_value <> 0 or run_value <> 0)) 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'ALERT! Recommend priority boost value should be set to 0' 
        from #t 
        where name = 'priority boost' 
    End 

  if @@rowcount =0 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'priority boost - OK!' 
    End 

  if exists (select 1 
             from #t 
             where [name] = 'query governor cost limit' 
               and (config_value <> 0 or run_value <> 0)) 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'ALERT! Recommend query governor cost limit value should be set to 0' 
        from #t 
        where name = 'query governor cost limit' 
    End 

  if @@rowcount =0 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'query governor cost limit - OK!' 
    End 

  if exists (select 1 
             from #t 
             where [name] = 'query wait (s)' 
               and (config_value <> -1 or run_value <> -1)) 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'ALERT! Recommend query wait (s) value should be set to -1' 
        from #t 
        where name = 'query wait (s)' 
    End 

  if @@rowcount =0 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'query wait in seconds - OK!' 
    End 

  if exists (select 1 
             from #t 
             where [name] = 'recovery interval (min)' 
               and ( (config_value <> 0 or run_value <> 0) 
               or (config_value > 30 or run_value > 30) 
               or (config_value between 1 
               and 4 or run_value between 1 and 4))) 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'ALERT! Recommend recovery interval (min) value should be set to 0 or between 5 and 30 min' 
        from #t 
        where name = 'recovery interval (min)' 
    End 

  if @@rowcount =0 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'recovery interval (min) - OK!' 
    End 

  if exists (select 1 
             from #t 
             where [name] = 'resource timeout (s)' 
               and (config_value <> 10 or run_value <> 10)) 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'ALERT! Recommend resource timeout (s) value should be set to 10' 
        from #t 
        where name = 'resource timeout (s)' 
    End 

  if @@rowcount =0 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'resource timeout (seconds) - OK!' 
    End 

  if exists (select 1 
             from #t 
             where [name] = 'set working set size' 
               and (config_value <> 0 or run_value <> 0) 
               and ((@max_server_memory_config <> @min_server_memory_config) 
               or (@max_server_memory_run <> @min_server_memory_run))) 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'ALERT! Recommend set working set size value should be set to 0' 
        from #t 
        where name = 'set working set size' 
    End 

  if @@rowcount =0 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'working set size - OK!' 
    End 

  if @NumberOfCPU = 1 
    begin 
      if exists (select 1 
                 from #t 
                 where [name] = 'spin counter' 

                   and (config_value <> 0 or run_value <> 0)) 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'ALERT! Recommend spin counter value should be set to 0 (Mono-CPU)' 
        from #t 
        where name = 'spin counter' 
    End 

  if @@rowcount =0 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'spin counter for Single CPU computer - OK!' 
    End 

  End 

  if @NumberOfCPU > 1 
    begin 
      if exists (select 1 
                 from #t 
                 where [name] = 'spin counter' 
                   and (config_value <> 10000 or run_value <> 10000)) 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'ALERT! Recommend spin counter value should be set to 10000 (SMP)' 
        from #t 
        where name = 'spin counter' 
    End 

  if @@rowcount =0 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'spin counter for multiple CPU computer - OK!' 
    End 

  End 

  if exists (select 1 
             from #t 
             where [name] = 'time slice (ms)' 
               and ( (config_value < 100 or run_value < 100) 
               or (config_value > 300 or run_value > 300))) 
    begin  
      insert into #fr98e53([Analysis Report]) 
        select 'ALERT! Recommend time slice (ms) value should be set to approx 100' 
        from #t 
        where name = 'time slice (ms)' 
    End 

  if @@rowcount = 0 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'time slice - OK!' 
    End 

  if (@MultiProtocol = 0 and @TCPsockets = 0) 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'ALERT! Recommend using either Multiprotocol or TCP/IP sockets for best performance of SQL Server 7.x and above' 
    End 

  if @@rowcount = 0 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'Multiprotocol & TCP/IP sockets - OK!' 
    End 

  --if exists (select 1 
  --           from master.dbo.sysaltfiles a 
  --             inner join tempdb.dbo.sysfiles f 
  --             on a.fileid = f.fileid 
  --             where dbid = db_id('tempdb') 
  --             and a.size <> f.size) 
  --
 if exists     (select 1 from sys.master_files a 
                   inner join sys.database_files f 
                 on a.file_id = f.file_id 
                 where a.database_id = db_id('tempdb') 
                 and   f.name like 'temp%'
                 and a.size <> f.size)
    begin  
      insert into #fr98e53([Analysis Report]) 
        select 'ALERT! tempdb may need resizing for better performance.' 
    End  

  if @@rowcount = 0 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'tempdb sizing - OK!' 
    End 

  if @SQLServerVersion > 70 and exists (select 1 
                                        from master.dbo.sysaltfiles a 
                                          inner join msdb.dbo.sysfiles f 
                                            on a.fileid = f.fileid 
                                        where dbid = db_id('msdb') 
                                          and a.size <> f.size) 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'ALERT! msdb may need resizing for better performance.' 
    End 

  if @@rowcount = 0 
    begin 
      insert into #fr98e53([Analysis Report]) 
        select 'msdb sizing - OK!' 
    End 

  set nocount on 
  begin 
    set ansi_nulls off 
    insert into #fr98e53 
      select 'WARNING!! - SECURITY ALERT: The login ' 
        + substring(name,1,25)+', ' + 'does not have a password! It is HIGHLY recommended that logins use passwords.' as 'Analysis Report' 
      from master..syslogins 
      where password = null 
        and isntname = 0 
        and isntuser =0 
  end 

  begin 
    if exists (select 1 
               from sysobjects o  
                 cross join master.dbo.spt_values v 
               where o.xtype = 'U ' 
                 and v.type = 'TBO' 
                 and v.number <> 0 
                 and o.status & v.number <> 0) 
 
    if @@rowcount >0 
      begin 
        insert into #fr98e53 
          select 'ALERT!! Database table options are turned on. See Books online for details.' as 'Analysis Report' 
      End 

  begin 
    if @@rowcount =0 
       insert into #fr98e53 
         select 'Table options for the ' + db_name() 
           + ' database - OK!' as 'Analysis Report' 
  End 

  End 

  begin 
    if exists (select 1 
               from sysobjects o, 
                    master.dbo.spt_values v  
               where o.xtype = substring(v.name,1,2) 
                 and v.type = 'O9T'  
                 and not (user_name(uid) in ('dbo', 'INFORMATION_SCHEMA'))) 

    if @@rowcount >0 
      begin 
        insert into #fr98e53 select 'ALERT! The following objects are not owned by DBO' as 'Analysis Report' 
      End if @@rowcount = 0 

    insert into #fr98e53 
      select 'All objects in database ' + db_name() 
        + ' are owned by DBO - OK!' as 'Analysis Report' 
  End 


  begin 
    set nocount on 
    create table #tx22az0214
      ([Database Name] varchar(55),
       [Log Size (MB)] varchar(15), 
       [Log Space Used (%)] varchar(15), 
        status int) 

    declare @str varchar(500) 

    select @str = 'DBCC SQLPERF(LOGSPACE) WITH NO_INFOMSGS' 

    insert into #tx22az0214 
      exec (@str) 
 
    set nocount on 

    insert into #fr98e53 
      select 'WARNING!! The transaction log for database '
        + [Database Name] + ' is over 75% full. Consider backing up your transaction log to resolve this issue. ' 
        + 'Log Size:' + [Log Size (MB)] + '(mb)  Log Space Used(%) '
       + [Log Space Used (%)] as 'Analysis Report' 
      from #tx22az0214 
      where [Log Space Used (%)] >75.0000 
      order by [Log Space Used (%)] desc 

      drop table #tx22az0214 
  End 

  begin 
    if exists (select * 
               from sysindexes i 
               where i.lockflags <> 0) 
                                                                                                  
    if @@rowcount >0 
      begin 
        insert into #fr98e53 
          select 'ALERT! Indices have index options set. See Books online for details'  as 'Analysis Report' 
  End 

  If @@rowcount =0 
    insert into #fr98e53 
      select 'No indices in databases have index options set - OK!' as 'Analysis Report' 

  End 

  begin 
    insert into #fr98e53 
      select 'Number of network packet errors since last restart ' 
        + convert(char(10),@@packet_errors) 

    insert into #fr98e53 
      select 'Total disk read/write errors since last restart ' 
        + convert(char(10),@@TOTAL_ERRORS) 

    insert into #fr98e53 
      select 'Total number of connections or attempted connections since last restart ' 
        + convert(char(25),@@connections) 
  End 

  begin 
    DECLARE @test varchar(15),
            @test1 varchar(15),
            @value_name varchar(15) 
  
    EXEC master..xp_regread @rootkey='HKEY_LOCAL_MACHINE', 
      @key='SOFTWARE\Microsoft\DataAccess', @value_name='FullInstallVer', 
      @value=@test OUTPUT 

    EXEC master..xp_regread @rootkey='HKEY_LOCAL_MACHINE', 
      @key='SOFTWARE\Microsoft\DataAccess', @value_name='Version', 
      @value=@test1 OUTPUT 

    insert into #fr98e53 
      select 'The Full Installed Version for MDAC is '
        + @test 

    insert into #fr98e53 
      select 'The MDAC Version Registry Key is populated with '+@test1+' as the reg value' 
  End 

 -- begin 
 --  select * 
 --   from #fr98e53 
 -- End 

-- purge old information from history table
begin
delete from dbo.Server_Health_History
    where DATEDIFF(DAY,[Server Health Timestamp],Current_Timestamp) > 180
end


-- insert information into a history table of server health
  begin
  insert dbo.Server_Health_History 
    select current_timestamp, [Analysis Report] from #fr98e53
  end

  drop table #t_serverinfo 
  drop table #t 
  drop table #fr98e53 


GO

