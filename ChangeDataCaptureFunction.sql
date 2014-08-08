declare @rc int
exec @rc = sys.sp_cdc_enable_db
select @rc
-- new column added to sys.databases: is_cdc_enabled
select name, is_cdc_enabled from sys.databases
EXEC sys.sp_cdc_enable_db
GO
EXEC sys.sp_cdc_enable_table
@source_schema = N'dbo',
@source_name   = N'customer2',
@role_name     = 'CDCRole',
@supports_net_changes = 1
GO
select * from 

create table dbo.customer2
(
id int identity not null
, name varchar(50) not null
, state varchar(2) not null
, constraint pk_customer2 primary key clustered (id)
)

exec sys.sp_cdc_enable_table 
    @source_schema = 'dbo', 
    @source_name = 'State' ,
    @role_name = 'CDCRole',
    @supports_net_changes = 1
select name, type, type_desc, is_tracked_by_cdc from sys.tables


insert customer2 values ('abc company', 'md')
insert customer2 values ('xyz company', 'de')
insert customer2 values ('xox company', 'va')
update customer2 set state = 'WV' where id = 3
delete from customer2 where id = 3
select * from customer2


declare @begin_lsn binary(10), @end_lsn binary(10)
-- get the first LSN for customer changes
select @begin_lsn = sys.fn_cdc_get_min_lsn('Masi_UserAccount')
-- get the last LSN for customer changes
select @end_lsn = sys.fn_cdc_get_max_lsn()
-- get net changes; group changes in the range by the pk
print @begin_lsn
print @end_lsn

update enterpriseservice.cdclsnlowerbound
set lsnlowerbound = @begin_lsn
where captureinstancename = 'Masi_UserAccount'

select * from cdc.fn_cdc_get_net_changes_Masi_UserRole(@begin_lsn, @end_lsn, 'all'); 
-- get individual changes in the range
select * from cdc.fn_cdc_get_all_changes_Masi_UserRole(
 @begin_lsn, @end_lsn, 'all');


update dbo.[state]
set [description] = 'ZZ'
where name = 'west virginia'

select * from dberrorlog