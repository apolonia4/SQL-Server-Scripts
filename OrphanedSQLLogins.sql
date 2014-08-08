--Verify you have a problem
EXEC sp_change_users_login 'Report'

--If you already have a login id and password for this user, fix it by doing:
EXEC sp_change_users_login 'Auto_Fix', 'user'
 
--If you want to create a new login id and password for this user, fix it by doing:
EXEC sp_change_users_login 'Auto_Fix', 'user', 'login', 'passwordt'