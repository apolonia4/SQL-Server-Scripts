DECLARE  @userId int  
DECLARE Users CURSOR FOR
SELECT    UserId

FROM      masi.[user]

 

OPEN Users
 

FETCH Users INTO @UserId

 

-- start the main processing loop.

WHILE @@Fetch_Status = 0

   BEGIN

	insert into dbo.MisleUserUnitXref(userid, DepartmentId, UnitLongName)
	Select top 10 @userId, DepartmentId, DepartmentName from Masi.Unit order by NEWID()

   FETCH Users INTO @UserId            

   END

CLOSE Users

DEALLOCATE Users

RETURN

