declare @X xml
set @X = '<USCGDocument>
  <Publication>
    <Sortie>
      <MessageAction>update</MessageAction>
      <Id>263775</Id>
      <ActivityId>3475900</ActivityId>
      <IsApportioned>false</IsApportioned>
      <InvolvedResourceId nil="true" />
      <MissionTypeId>24</MissionTypeId>
    </Sortie>
  </Publication>
</USCGDocument>'


select *, Message.value('/USCGDocument[1]/Publication[1]/Activity[1]/Id[1]', 'varchar(50)') 
as MessageAction from EnterpriseServiceBusAudit

select *, Message.query('/USCGDocument[1]/Publication[1]/Activity[1]/Id[1]') As ActivityId from EnterpriseServiceBusAudit
where Message.value('/USCGDocument[1]/Publication[1]/Activity[1]/Id[1]', 'int') = 3475899

select Message.value('/USCGDocument[1]/Publication[1]/Activity[1]/Id[1]', 'int') as id from EnterpriseServiceBusAudit
WHERE Message.value('/USCGDocument[1]/Publication[1]/Activity[1]/Id[1]', 'int') = 3475899


declare @T table (ID int identity, [xml] xml)  

insert into @T ([xml]) 
values ('<root><item><id>1</id><name>Name 1</name></item>
<item><id>2</id><name>Name 2</name>
</item> </root> ')  
insert into @T ([xml]) 
values (' <root><item><id>1</id><name>Name 1</name></item><item><id>3</id><name>Name 3</name></item></root>')


select 
r.i.value('id[1]', 'int') as id
, r.i.value('name[1]', 'varchar(10)') as name 
from @T as T 
cross apply T.[xml].nodes('root/item') r(i)

--******************Use this to query elements directly
select T.Message, T.CreatedDateTime, a.i.value('Id[1]', 'int') as id from EnterpriseServiceBusAudit T
cross apply T.Message.nodes('USCGDocument/Publication/Activity') a(i)
where a.i.value('Id[1]', 'int') = 1