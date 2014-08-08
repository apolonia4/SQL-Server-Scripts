select 
Count(T.[Message]) as NumberMessages
--, DATEPART(MONTH, t.CreatedDateTime) as [Month]
, DATENAME(MONTH, t.CreatedDateTime) as [MonthName]
, DATEPART(day, t.CreatedDateTime) as [Day]
FROM EnterpriseServiceBusAudit T
cross apply T.[Message].nodes('USCGDocument/Header') a(i)
WHERE a.i.value('type[1]', 'varchar(100)') = 'publication://uscg.mda.misle.activity'
AND t.CreatedDateTime > '2011-04-01'
Group by DATENAME(MONTH, t.CreatedDateTime), DATEPART(day, t.CreatedDateTime)
order by [MonthName], [day]


