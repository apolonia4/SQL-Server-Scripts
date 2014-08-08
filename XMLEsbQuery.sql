SELECT
T.[Message]
, T.CreatedDateTime
, a.i.value('Id[1]', 'int') as id 
FROM EnterpriseService.EnterpriseServiceBusAudit T
CROSS APPLY T.[Message].nodes('USCGDocument/Publication') a(i)
WHERE T.CreatedDateTime > '2011-08-14'
--WHERE CreatedDateTime > '2011-04-13T00:00:00.001'
--WHERE a.i.value('Id[1]', 'int') = 3863055



--Example returns all Activity Messages where owning unit id is 98 (osc).
select 
T.[Message]
, T.CreatedDateTime
, a.i.value('Id[1]', 'int') as id 
FROM EnterpriseServiceBusAudit T
cross apply T.[Message].nodes('USCGDocument/Publication/Activity') a(i)
where a.i.value('OwningUnitId[1]', 'int') = 98