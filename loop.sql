--select * from tblacsimporttest
DECLARE @RowCount INT
SET @RowCount = (SELECT COUNT(*) from tblacsimporttest) 
DECLARE @I INT
-- Initialize the iterator
SET @I = 1

-- Loop through the rows of a table @myTable
WHILE (@I <= @RowCount)
BEGIN
declare @col40 varchar(100)
set @col40 = (select col40 from tblacsimporttest where id = @I)
declare @intstart int
set @intstart = charindex('=', @col40)
Set @intstart = @intstart + 1


declare @length int
set @length = len(@col40)
Set @length = @length + 1

update tblacsimporttest
--set col40 = 'Device IP Address=' + col40
set col40 = substring(col40, @intstart, @length)
--set col40 = replace(col40, 'VendorSpecific:', 'VendorSpecific=')
where id = @I

  SET @I = @I  + 1
END
 

