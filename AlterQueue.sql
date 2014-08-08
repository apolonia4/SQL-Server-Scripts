ALTER QUEUE [EnterpriseServiceBusInboundQueue]
WITH ACTIVATION (STATUS=ON,
PROCEDURE_NAME = masi.uspEnterpriseServiceBusProcessMessageAlmis,
MAX_QUEUE_READERS = 1,
EXECUTE AS SELF) 