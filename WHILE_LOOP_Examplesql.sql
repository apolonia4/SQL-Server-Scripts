--DECLARE @id int = 1
--WHILE (@id < 500001)
--BEGIN
--    INSERT INTO MongoCompare VALUES (newid(), @id)
--    SET @id+=1
--END
--GO


DECLARE @RowCount INT
SET @RowCount = (SELECT COUNT(Resource.Description) FROM Resource) 

-- Declare an iterator
DECLARE @I INT
-- Initialize the iterator
SET @I = 1

-- Loop through the rows of a table @myTable
WHILE (@I <= @RowCount)
BEGIN
        -- Declare variables to hold the data which we get after looping each record 
        DECLARE @ResourceDescription VARCHAR(100)--, @iPassword VARCHAR(50), @iEmail VARCHAR(50)    
        DECLARE @Category varchar(100)
        -- Get the data from table and set to variables
        --SELECT @iUserName = [USER_NAME], @iPassword = MISLEUser.LDAPSID, @iEmail = MISLEUser.Change_Unit_Ind FROM misleuser WHERE [User_Id] = @I
        -- Display the looped data
        
        
        Set @ResourceDescription = (Select description from Resource where ResourceId = @I)
        
        Set @Category = (Select c.[Description] from [Resource] r
		inner join Kind k
		on r.KindId = k.KindId
		inner join Category c
		on c.CategoryId = r.CategoryId
		where (r.Description = @ResourceDescription and r.ResourceId = @I))
        
        
        --PRINT 'Row No = ' + CONVERT(VARCHAR(2), @I)
        PRINT @Category + '      ' + @ResourceDescription + '    '  + Convert(varchar(20),  @i)
        -- Increment the iterator
        SET @I = @I  + 1
END
