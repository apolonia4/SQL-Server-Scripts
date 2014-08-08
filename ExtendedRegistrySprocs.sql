EXEC sp_helprotect 'xp_regaddmultistring', 'public'
go
EXEC sp_helprotect 'xp_regdeletekey', 'public'
go
EXEC sp_helprotect 'xp_regdeletevalue', 'public'
go
EXEC sp_helprotect 'xp_regenumvalues', 'public'
go
EXEC sp_helprotect 'xp_regenumkeys', 'public'
go
EXEC sp_helprotect 'xp_regremovemultistring', 'public'
go
EXEC sp_helprotect 'xp_regwrite', 'public'
go
EXEC sp_helprotect 'xp_instance_regaddmultistring', 'public'
go
EXEC sp_helprotect 'xp_instance_regdeletekey', 'public'
go
EXEC sp_helprotect 'xp_instance_regdeletevalue', 'public'
go
EXEC sp_helprotect 'xp_instance_regenumvalues', 'public'
go
EXEC sp_helprotect 'xp_instance_regenumkeys', 'public'
go
EXEC sp_helprotect 'xp_instance_regremovemultistring', 'public'
go
EXEC sp_helprotect 'xp_instance_regwrite', 'public'
go
EXEC sp_helprotect 'xp_regread', 'public'
go
EXEC sp_helprotect 'xp_instance_regread', 'public'
GO

REVOKE EXECUTE ON [xp_regread] FROM [PUBLIC]
go
REVOKE EXECUTE ON [xp_instance_regread] FROM [PUBLIC]
go