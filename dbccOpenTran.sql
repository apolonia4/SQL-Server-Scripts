kill 84 with statusonly
sp_spaceused
dbcc updateusage(0)
select * from sys.sysprocesses

dbcc opentran

select * from sys.dm_tran_database_transactions
select * from sys.dm_tran_session_transactions 

sp_who2