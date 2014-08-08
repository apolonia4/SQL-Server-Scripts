SELECT @@servername
go
sp_dropserver 'fizzmo-pc'
go
sp_addserver 'fizzmopc', LOCAL
go