
DECLARE @idoc int;		
DECLARE @message_body varchar(max);
Set @message_body = '<?xml version="1.0" standalone="yes"?>
<ResourceList xsi:schemaLocation="http://almis.uscg.dhs.gov/1.0 AlmisResourceSchema.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://almis.uscg.dhs.gov/1.0">
  <Resource>
    <PublishDT>2010-05-11T10:39:50.697-04:00</PublishDT>
    <ID>299023</ID>
    <ResourceStatus operation="change">
      <StatusIndicator>UP</StatusIndicator>
      <StatusCode>Bravo</StatusCode>
      <EffectiveDate>2010-05-08T11:00:00Z</EffectiveDate>
      <Comments>
      </Comments>
      <LastChangeUser>BEAUPRE JEFFREY BMCM 9926</LastChangeUser>
      <LastChangeDate>2010-05-11T10:39:18Z</LastChangeDate>
    </ResourceStatus>
  </Resource>
</ResourceList>'

EXEC sp_xml_preparedocument @idoc OUTPUT, @message_body, '<root	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
				xmlns:ns2="http://almis.uscg.dhs.gov/1.0"/>';
		
		

SELECT AlmisResourceId, AircraftStatus, LastAlmisUpdate
FROM OPENXML(@idoc, N'/ns2:ResourceList/ns2:Resource/ns2:ResourceStatus', 2) 
				WITH (AlmisResourceId int '../ns2:ID',
						AircraftStatus varchar(20) './ns2:StatusCode',
					LastAlmisUpdate varchar(20) './ns2:EffectiveDate')
		
EXEC sp_xml_removedocument @idoc