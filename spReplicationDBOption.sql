
exec sp_replicationdboption @dbname = 'UserAccounts', @optname= 'publish', @value = 'false'
go