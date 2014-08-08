DECLARE @idoc int;
DECLARE @MessageBody xml;
Set @MessageBody = '<ROOT><Id>1</Id><Description>Desc</Description><Title>Title</Title></ROOT>'

EXEC sp_xml_preparedocument @idoc OUTPUT, @MessageBody
			
			
			BULK INSERT INTO dbo.XMLInsert
			SELECT Id, [Description], Title
			FROM OPENXML(@idoc,'/ROOT', 2)
			WITH (
						Id int 'Id',
						[Description] varchar(20) 'Description',
						Title varchar(20) 'Title'
						
					);

			EXEC sp_xml_removedocument @idoc
			
			
select * from dbo.XMLInsert

--USE tempdb
--CREATE TABLE T (IntCol int, XmlCol xml)
--GO


INSERT INTO XMLInsert(XMLData)
SELECT * FROM OPENROWSET(
   BULK 'D:\Case.xml',
   SINGLE_BLOB) AS x
   GO
--select * from t
--drop table t

select * from xmlinsert

CREATE TABLE [dbo].[CaseActivityAssociation] (
    [CaseActivityId] INT NULL,
    [CaseId]         INT NULL,
    [ActivityId]     INT NULL
);

insert into CaseActivityAssociation 
(
CaseActivityId
, CaseId
, ActivityId
)
Select tab.col.value('/.id[1]', 'int') as id


FROM XMLInsert
			