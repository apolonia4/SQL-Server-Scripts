--Logins for July
--LoginCount	UnitLongName
--599	Deployable Operations Group
--11	District 1
--1	District 1 (dp)
--15	District 1 (dpb)
--7	District 11 (dr)
--1	District 13 (dpw)
--1	District 5
--4	District 7
--5	District 7 (dp)
--1	District 7 (dr)
--2	District 8
--2	District 9 (dre)

--Successful:  649
--Unsuccessful Logins:  51

--Appointments created since release:  1707 New Appointments in Juy: 292 Operations created since release:  250 New Operations in July: 39 Appointments modified in July:  89 Operations modified in July:  12

--***Copy UserPreferences and UserSessionhistory over to masi2Devlocal to join against misle.unit table.
select count(u.Unitlongname) as LoginCount, u.UnitLongName  from masi.userpreferencestemp up
join misle.unit u
on up.defaultdistrictmisleunitid = u.unitid
join masi.usersessionhistorytemp mut
on mut.UserName = up.samaccountname
WHERE mut.sessionguid <> '00000000-0000-0000-0000-000000000000'
AND mut.LastModifiedDateTime > '2011-07-01 00:00:00.001' and 
mut.LastModifiedDateTime < '2011-07-31 11:59:59.999'
group by u.unitlongname


select * from masi.usersessionhistorytemp
where username Not in (select samaccountname from masi.userpreferencestemp)
AND lastmodifieddatetime > '2011-07-01T00:00:00.000'
and sessionguid <> '00000000-0000-0000-0000-000000000000'

select username from masi.usersessiontemp 
where username not in (select samaccountname from masi.userpreferencestemp)

select * from masi.usersessionhistory
where sessionGUID <> '00000000-0000-0000-0000-000000000000'

select defaultdistrictmisleunitid from masi.userPreferences


select * from masi.appointment 
where createddatetime > '2011-07-01T00:00:00.000'
order by createddatetime

select * from masi.masterappointment 
where createddatetime > '2011-07-01T00:00:00.000'
order by createdDatetime

select * from masi.masterappointment
where lastmodifieddatetime > '2011-07-01T00:00:00.000'