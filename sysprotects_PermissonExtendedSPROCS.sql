SELECT sysusers.name
, Status = 
CASE protecttype 

             WHEN 204 THEN 'GRANT_W_GRANT'

             WHEN 205 THEN 'GRANT'

             WHEN 206 THEN 'REVOKE'

 ELSE 'Unknown'

END

, Permission = 

CASE action

             WHEN 193 THEN 'SELECT'

             WHEN 195 THEN 'INSERT'

             WHEN 196 THEN 'DELETE'

             WHEN 197 THEN 'UPDATE'

             WHEN 26 THEN 'REFERENCE'

             WHEN 224 THEN 'EXECUTE'

 ELSE 'Unknown'

END 

, sysobjects.name 

FROM sysprotects, sysobjects, sysusers

WHERE sysobjects.id = sysprotects.id 

AND sysprotects.action IN (193, 195, 196, 197, 224, 26) 

AND sysprotects.uid = sysusers.uid

AND sysusers.name = 'public'
AND (sysobjects.name = 'xp_instance_regread' OR sysobjects.name = 'xp_regread')
--AND (sysobjects.name like '%xp_%' OR sysobjects.name like '%sp_OA%')

