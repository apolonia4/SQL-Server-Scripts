select count(u.Unitlongname), u.UnitLongName from masi.userpreferencestemp up
inner join misle.unit u
on up.defaultdistrictmisleunitid = u.unitid
inner join masi.usersessionhistorytemp mut
on mut.UserName = up.samaccountname
WHERE mut.sessionguid <> '00000000-0000-0000-0000-000000000000'
group by u.unitlongname


select * from masi.usersessionhistorytemp

select username from masi.usersessiontemp 
where username not in (select samaccountname from masi.userpreferencestemp)

select * from masi.usersessionhistory
where sessionGUID <> '00000000-0000-0000-0000-000000000000'

select defaultdistrictmisleunitid from masi.userPreferences


select * from masi.appointment 
where createddatetime > '2011-06-01T00:00:00.000'
order by createddatetime

select * from masi.masterappointment 
where createddatetime > '2011-06-01T00:00:00.000'
order by createdDatetime

select * from masi.masterappointment
where lastmodifieddatetime > '2011-06-01T00:00:00.000'