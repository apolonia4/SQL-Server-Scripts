execute xp_regread

select * from sys.all_objects where type = 'x'
and name like 'xp_reg%'


exec sp_helprotect 'xp_regread', 'public'
revoke execute on [xp_regread] FROM [PUBLIC]

GRANT EXECUTE ON [xp_regread] TO [public]

SELECT * FROM fn_my_permissions('master..xp_instance_regread', 'OBJECT') 
where permission_name = 'EXECUTE'

