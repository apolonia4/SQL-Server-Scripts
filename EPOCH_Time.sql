declare @date datetime 
set @date = '2010-04-17 01:00:00'

--TO EPOCH
select DATEDIFF(s, '1970-01-01 00:00:00', @date)

--FROM EPOCH
select dateadd(s, 1271466000, '19700101')