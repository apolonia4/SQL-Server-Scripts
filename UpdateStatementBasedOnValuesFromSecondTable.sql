Update PortPartner.Organization
Set [State] = 
(Select state.StateId from dbo.State 
where PortPartner.Organization.state = state.Abbreviation)





UPDATE tbl1
SET col1 =
(SELECT col2
FROM tbl2
WHERE tbl1.[id] = tbl2.[id])

--Using an Inner Join
Update c
SET c.EOCOrionId = l.OrionId
, c.EOCRegionName = l.EOCRegionName
FROM NCA_NodesImport c
INNER JOIN Lookup_tblEOCOrionMapping l
ON c.DBServerName = l.OrionServerName

