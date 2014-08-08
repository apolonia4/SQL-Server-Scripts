--To reseed primary key can truncate table or run dbcc checkident
truncate table dbo.mytable
DBCC CHECKIDENT (MyTable, RESEED, 1)