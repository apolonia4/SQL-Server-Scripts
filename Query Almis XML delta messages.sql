WITH XMLNAMESPACES	(
						'http://almis.uscg.dhs.gov/1.0' As ns2,
						'http://uscg/C21/InitialResourceList' As n
					)
select 
 *
from 
 EnterpriseServiceBusAudit
where 
  message.value('(/ns2:ResourceList/ns2:Resource/ns2:ID)[1]', 'int') = 298706