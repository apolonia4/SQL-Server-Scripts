--select * from tblacsimporttest2
DECLARE @RowCount INT
SET @RowCount = (SELECT COUNT(*) from tblacsimporttest) 
DECLARE @I INT
-- Initialize the iterator
SET @I = 1

-- Loop through the rows of a table @myTable
WHILE (@I <= @RowCount)
	BEGIN
		--Declare variable to hold each column value
		DECLARE @AcctStatusType varchar(100)
		SET @AcctStatusType = (SELECT AcctStatusType FROM tblacsimporttest2 WHERE id = @I)

		--Use replace function to cleanup data in each column 
		UPDATE tblacsimporttest2
		SET AcctStatusType = REPLACE(@AcctStatusType, ' Acct-Status-Type=', '')
		WHERE id = @I

		SET @I = @I  + 1
	END
