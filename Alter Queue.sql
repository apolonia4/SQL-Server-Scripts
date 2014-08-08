ALTER QUEUE dbo.EnterpriseServiceBusPrototypeInboundQueue
WITH ACTIVATION (STATUS=ON,
PROCEDURE_NAME = EnterpriseService.uspEnterpriseServiceBusProcessMessage,
MAX_QUEUE_READERS = 5,
EXECUTE AS SELF) 



