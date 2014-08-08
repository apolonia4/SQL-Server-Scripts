-- Create the table to accept the results
create table #output (dbname char(30),log_size real, usage real, status int)
-- execute the command, putting the results in the table
insert into #output
exec ('dbcc sqlperf(logspace)')
-- display the results
select *
from #output
go
--open cursor
declare output_cur cursor read_only for
select log_size
from #output
--make space computations
declare @v1 as real
declare @base_val as real
set @base_val = 0
open output_cur
FETCH NEXT FROM output_cur
INTO @v1
WHILE @@FETCH_STATUS = 0
BEGIN
set @base_val = @base_val + @v1

FETCH NEXT FROM output_cur
INTO @v1
END
set @base_val = @base_val + 15
PRINT 'BASE_VAL = ' + cast(@base_val as nvarchar) + ' MB'
--clean-up
close output_cur
drop table #output