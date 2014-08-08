SELECT [name], database_id, is_cdc_enabled FROM sys.databases       
GO

EXEC sys.sp_cdc_enable_db
GO

EXEC sys.sp_cdc_disable_table
@source_schema = N'Masi',
@source_name   = N'UserRole',
@capture_instance = N'Masi_UserRole'
GO


exec sys.sp_cdc_enable_table 
    @source_schema = 'Masi', 
    @source_name = 'UserAccount' ,
    @role_name = 'Masi_UserAccount',
    @supports_net_changes = 1
    
    
SELECT name, type, type_desc, is_tracked_by_cdc FROM sys.tables
GO

declare @begin_lsn binary(10), @end_lsn binary(10)
-- get the first LSN for customer changes
select @begin_lsn = sys.fn_cdc_get_min_lsn('Masi_UserAccount')
-- get the last LSN for customer changes
select @end_lsn = sys.fn_cdc_get_max_lsn()
-- get net changes; group changes in the range by the pk
--print @begin_lsn
--print @end_lsn

update enterpriseservice.cdclsnlowerbound
set lsnlowerbound = @begin_lsn
where captureinstancename = 'Masi_UserAccount'


select * from enterpriseservice.cdclsnlowerbound


