DECLARE @DeleteDate datetime 
SET @DeleteDate = DateAdd(HOUR, -19, '20120203 04:30:00.000')  
PRINT @deletedate


--Set Loan Amount
Declare @L as decimal(9, 3)
Set @L = 160000

--Set APR
Declare @APR as Decimal(9, 3)
Set @APR = .060

--Set Lenght of Loan in Months
Declare @M as int
Set @M = 360

Declare @Num as decimal(9, 3)
Set @Num = (select @L * (@APR/12))
Print @Num


Declare @exp as decimal(9, 3)
set @exp = (select (1 - power(1 + @APR/12, -@M)))
--print @exp

Declare @MPMT as decimal(9, 4)
Set @MPMT = (Select @Num/@Exp)


select @MPMT as Monthly_Payment, @MPMT * @M as Total_Paid_For_Vehicle, (@MPMT * @M) - @L as Total_Interest







