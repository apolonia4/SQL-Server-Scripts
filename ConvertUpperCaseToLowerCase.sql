select
	ObjectGuid =
	-- Assuming that the length of DESCRIPTION is varchar(500)
	convert(varchar(500),
	--upper(substring(ObjectGuid,1,1))+
	lower(substring(ObjectGuid,1,499)))
from
	Masi.UserAccount