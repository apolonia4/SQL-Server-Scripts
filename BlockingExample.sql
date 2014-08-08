--To simulate blocking, run query 1 in one window and then query 2 in another window
--Query 1
BEGIN TRAN
UPDATE TableA
SET id = 2
WHERE id = 1
WAITFOR delay '00:03:00'
ROLLBACK

--query 2
UPDATE TableA
SET id = 3
WHERE id = 1
