--Contract Start Date select * from dbaciscoimport
DECLARE @RowCount INT
SET @RowCount = (select count(c.warrantycontractstart) from inv_contracts a
					inner join inv_ci b
					on a.ci_id = b.request_id
					inner join DBACiscoImport c
					on c.Serial = b.atr_serial_number
					WHERE c.ContractNumber is NOT NULL AND c.warrantyContractStart IS NOT NULL)

					declare @contractStart table
					(RowId int identity(1,1)
					, contractStartDate datetime
					, SerialNumber varchar(max)
					, contractnumber varchar(max)
					, request_id varchar(max))


INSERT INTO @contractStart
select c.warrantycontractStart, c.serial, c.contractnumber, b.request_id from inv_contracts a
					inner join inv_ci b
					on a.ci_id = b.request_id
					inner join DBACiscoImport c
					on c.Serial = b.atr_serial_number
					WHERE c.ContractNumber is NOT NULL AND c.warrantyContractStart IS NOT NULL

-- Declare an iterator
DECLARE @I INT
-- Initialize the iterator
SET @I = 1

		-- Loop through the rows of a table @myTable
		WHILE (@I <= @RowCount)
			BEGIN
			--SELECT C536870914 FROM T595
			DECLARE @Date datetime
			Set @Date = (Select contractstartdate from @contractstart where rowid = @I)
		
			DECLARE @SerialNumber varchar(max)
			SET @SerialNumber = (SELECT serialnumber from @contractstart where rowid = @I)
	

			DECLARE @RequestId varchar(max)
			SET @RequestId = (SELECT request_id from @contractstart where rowid = @I)
		

			DECLARE @ContractNumber varchar(max)
			SET @ContractNumber = (SELECT ContractNumber from @contractstart where rowid = @I)
			--Print CONVERT(VARCHAR, @Date, 120) + ' ' + @SerialNumber + ' ' + @RequestId + ' ' + @ContractNumber

			UPDATE a
			set C536870913 =  (DATEDIFF(s, '1970-01-01 00:00:00', DATEADD(HH, 4, @date)))
			FROM t595 a
			inner join inv_ci b
			on a.C536870950 = b.request_id
			inner join DBACiscoImport c
			on c.Serial =  @SerialNumber
			WHERE b.request_Id = @RequestId
	

			SET @I = @I  + 1
END
