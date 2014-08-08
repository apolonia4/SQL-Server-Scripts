/* 

**Masi ESB Object Creation Script**

 Message Types:

//Masi/EnterpriseServiceBusData/MessageType/Almis/Inbound/Subscriber/Initialize
//Masi/EnterpriseServiceBusData/MessageType/Almis/Inbound/Subscriber/Delta

*/


Create Message Type [//Masi/EnterpriseServiceBusData/MessageType/Almis/Inbound/Subscriber/Initialize]
Validation = WELL_FORMED_XML;

Create Message Type [//Masi/EnterpriseServiceBusData/MessageType/Almis/Inbound/Subscriber/Delta]
Validation = WELL_FORMED_XML;

CREATE CONTRACT [//Masi/EnterpriseServiceBusData/Contract/Almis]
      ([//Masi/EnterpriseServiceBusData/MessageType/Almis/Inbound/Subscriber/Initialize]
      
       SENT BY INITIATOR,
       [//Masi/EnterpriseServiceBusData/MessageType/Almis/Inbound/Subscriber/Delta]
       
       SENT BY INITIATOR
      );
GO

CREATE QUEUE EnterpriseServiceBusInboundQueue;

CREATE SERVICE
       [//Masi/EnterpriseServiceBusData/ProcessMessage]
       ON QUEUE EnterpriseServiceBusInboundQueue
       ([//Masi/EnterpriseServiceBusData/Contract/Almis]);
GO


