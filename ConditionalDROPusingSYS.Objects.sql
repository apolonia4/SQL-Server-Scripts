IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('[dbo].[Activity]') 
AND type = 'U')
Print 'Exists'
--DROP TABLE dbo.Activity
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('[dbo].[Activity]') 
AND type = 'U')
Print 'Does not Exist'
--CREATE TABLE dbo.Activity
--(ActivityId int PRIMARY KEY,
--etc....)


