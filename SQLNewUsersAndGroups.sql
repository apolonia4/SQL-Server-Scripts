select @@SERVERNAME, * from sys.server_principals where (create_date > (GetDate() - 30) or modify_date > (GetDate() - 30))
and type in ('U', 'G')