--Check to see if public has execute permissions on xp_regread
exec sp_helprotect 'xp_regread', 'public'
--Revoke Permissions
REVOKE EXECUTE ON [xp_regread] FROM [PUBLIC]


--Check to see if public has execute permissions on xp_instance_regread
exec sp_helprotect 'xp_instance_regread', 'public'
--Revoke Permissions
REVOKE EXECUTE ON [xp_instance_regread] FROM [PUBLIC]