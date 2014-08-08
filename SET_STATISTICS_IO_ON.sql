SET STATISTICS IO ON
SELECT * FROM person.address
SET STATISTICS IO OFF
DBCC IND('AdventureWorks2012', [person.address], -1)

