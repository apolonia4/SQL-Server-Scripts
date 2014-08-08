select * from sys.dm_exec_requests


select salesperson.name, country, city, datepart(YYYY, saledate) as year, sum(amount) as total
from sale 
inner join salesperson on
sale.SalesPersonId = salesperson.SalesPersonId
group by grouping sets((salesperson.name, country, city, datepart(YYYY,saledate)), (country, city),(Country), ())

select salesperson.name, country, city, datepart(YYYY, saledate) as year, sum(amount) as total
from sale 
inner join salesperson on
sale.SalesPersonId = salesperson.SalesPersonId
group by cube(salesperson.name, country, city, datepart(yyyy, saledate))


select salesperson.name, country, city, datepart(YYYY, saledate) as year, sum(amount) as total
from sale 
inner join salesperson on
sale.SalesPersonId = salesperson.SalesPersonId
group by cube(salesperson.name, datepart(yyyy, saledate), city, country)

select salesperson.name, country, city, datepart(YYYY, saledate) as year, sum(amount) as total
from sale 
inner join salesperson on
sale.SalesPersonId = salesperson.SalesPersonId
group by rollup(salesperson.name, datepart(yyyy, saledate), city, country)