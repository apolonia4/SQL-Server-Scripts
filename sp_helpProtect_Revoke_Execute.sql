
--Check to see if public has execute permissions on xp_regread
exec sp_helprotect 'xp_regread', 'public'
--Revoke Permissions
REVOKE EXECUTE ON [xp_regread] FROM [PUBLIC]
--Grant Permissions
GRANT EXECUTE on [xp_regread] TO [PUBLIC]

--Check to see if public has execute permissions on xp_instance_regread
exec sp_helprotect 'xp_instance_regread', 'public'
--Revoke Permissions
REVOKE EXECUTE ON [xp_instance_regread] FROM [PUBLIC]
--Grant Permissions
GRANT EXECUTE on [xp_instance_regread] TO [PUBLIC]
