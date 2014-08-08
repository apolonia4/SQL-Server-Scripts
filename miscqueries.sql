select * from download
where description like '%wal-mart%'

update download
set BusinessName = 'MARTINS'
, Type = 'Grocery'
where description like '%martin''s%'


select sum(amount) from download
where BusinessName = 'subway'


select sum(amount) from download
where type = 'gas' OR type = 'Restaurant'

select sum(amount) as Total, BusinessName FROM download
where type = 'Restaurant'
Group By BusinessName
ORDER BY sum(amount) desc

select * from download where businessname = 'martins'