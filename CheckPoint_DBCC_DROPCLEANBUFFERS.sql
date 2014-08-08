USE RunBook
SELECT * FROM dbo.FilerServerMapping
WHERE Filerlocation LIKE 'Martinsburg'

USE RunBook;
GO
CHECKPOINT;
GO
DBCC DROPCLEANBUFFERS;
GO