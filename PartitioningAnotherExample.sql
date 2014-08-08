create database SQL2008SBS

CREATE PARTITION FUNCTION partfunc (datetime )
AS
RANGE RIGHT
FOR VALUES ('1/1/2005','1/1/2006')
GO

alter database SQL2008SBS
add filegroup [FG1]
GO
alter database SQL2008SBS
add filegroup [FG2]
GO
alter database SQL2008SBS
add filegroup [FG3]
GO


CREATE PARTITION SCHEME partscheme
AS
PARTITION partfunc
TO
(FG1, FG2, FG3)
GO

CREATE TABLE dbo.orders (
    OrderID        int      identity(1,1),
    OrderDate      datetime NOT NULL,
    OrderAmount    money    NOT NULL
  CONSTRAINT pk_orders PRIMARY KEY CLUSTERED (OrderDate,OrderID))
ON partscheme(OrderDate)
GO

SET NOCOUNT ON
DECLARE @month  int = 1,
        @day    int = 1,
        @year   int = 2005

WHILE @year < 2007
BEGIN
    WHILE @month <= 12
    BEGIN
        WHILE @day <= 28
        BEGIN
            INSERT dbo.orders (OrderDate, OrderAmount)
            SELECT CAST(@month AS VARCHAR(2)) + '/' + CAST(@day AS VARCHAR(2)) + '/'
                    + CAST(@year AS VARCHAR(4)), @day * 20

            SET @day = @day + 1
        END

        SET @day = 1
        SET @month = @month + 1
    END
    SET @day = 1
    SET @month = 1
    SET @year = @year + 1
END
GO

SELECT * FROM dbo.orders
WHERE $partition.partfunc(OrderDate)=3
GO

--Alter the partition function to introduce a new range and set the 
--next used filegroup using the following code:
ALTER PARTITION SCHEME partscheme
NEXT USED FG1;
GO

ALTER PARTITION FUNCTION partfunc()
SPLIT RANGE ('1/1/2007');
GO

--Create a table to switch the 2005 data to and view the contents of both tables 
--by using the following code:
CREATE TABLE dbo.ordersarchive (
    OrderID        int      NOT NULL,
    OrderDate       datetime NOT NULL
         CONSTRAINT ck_orderdate CHECK (OrderDate<'1/1/2006'),
    OrderAmount    money     NOT NULL
  CONSTRAINT pk_ordersarchive PRIMARY KEY CLUSTERED (OrderDate,OrderID))
ON FG2
GO

SELECT * FROM dbo.orders
SELECT * FROM dbo.ordersarchive
GO

--Switch the 2005 data to the archive table and view the results by using the following code:
ALTER TABLE dbo.orders
SWITCH PARTITION 2 TO dbo.ordersarchive
GO

SELECT * FROM dbo.orders
SELECT * FROM dbo.ordersarchive
GO

--Remove the boundary point for 2005 by using the following code:
ALTER PARTITION FUNCTION partfunc()
MERGE RANGE ('1/1/2005');
GO


























