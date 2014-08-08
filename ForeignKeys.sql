ALTER TABLE [dbo].[tblSystem]  WITH CHECK ADD  CONSTRAINT [fktblSystem_tblUser_intCreatedByID] FOREIGN KEY([intCreatedByID])
REFERENCES [dbo].[tblUser] ([intUserID])
GO

ALTER TABLE [dbo].[tblSystem] CHECK CONSTRAINT [fktblSystem_tblUser_intCreatedByID]
GO

ALTER TABLE [dbo].[tblSystem]  WITH CHECK ADD  CONSTRAINT [fktblSystem_tblUser_intLastModifiedByUserLoginID] FOREIGN KEY([intLastModifiedByUserLoginID])
REFERENCES [dbo].[tblUser] ([intUserID])
GO

ALTER TABLE [dbo].[tblSystem] CHECK CONSTRAINT [fktblSystem_tblUser_intLastModifiedByUserLoginID]
GO

ALTER TABLE [dbo].[tblSystem]  WITH CHECK ADD  CONSTRAINT [fktblSystem_tblVendor_intVendorID] FOREIGN KEY([intVendorID])
REFERENCES [dbo].[tblVendor] ([intVendorID])
GO

ALTER TABLE [dbo].[tblSystem] CHECK CONSTRAINT [fktblSystem_tblVendor_intVendorID]
GO

ALTER TABLE [dbo].[tblSystem]  WITH CHECK ADD  CONSTRAINT [fktblSystem_LookupContractType_intContractTypeID] FOREIGN KEY([intContractTypeID])
REFERENCES [dbo].[LookupContractType] ([intContractTypeID])
GO

ALTER TABLE [dbo].[tblSystem] CHECK CONSTRAINT [fktblSystem_LookupContractType_intContractTypeID]
GO

ALTER TABLE [dbo].[tblSystem]  WITH CHECK ADD  CONSTRAINT [fktblSystem_LookupTollByPassEquipmentType_insTollByPassEquipTypeID] FOREIGN KEY([intTollByPassEquipTypeID])
REFERENCES [dbo].[LookupTollByPassEquipmentType] ([intTollByPassEquipTypeID])
GO

ALTER TABLE [dbo].[tblSystem] CHECK CONSTRAINT [fktblSystem_LookupTollByPassEquipmentType_insTollByPassEquipTypeID]
GO

ALTER TABLE [dbo].[tblSystem]  WITH CHECK ADD  CONSTRAINT [fktblSystem_LookupTollByPassType_intTollByPassTypeID] FOREIGN KEY([intTollByPassTypeID])
REFERENCES [dbo].[LookupTollByPassType] ([intTollByPassTypeID])
GO

ALTER TABLE [dbo].[tblSystem] CHECK CONSTRAINT [fktblSystem_LookupTollByPassType_intTollByPassTypeID]
GO

ALTER TABLE [dbo].[tblSystem]  WITH CHECK ADD  CONSTRAINT [fktblSystem_LookupEmergencyBypassEquipment_intEmergencyBypassEquipmentID] FOREIGN KEY([intEmergencyBypassEquipmentID])
REFERENCES [dbo].[LookupEmergencyBypassEquipment] ([intEmergencyBypassEquipmentID])
GO

ALTER TABLE [dbo].[tblSystem] CHECK CONSTRAINT [fktblSystem_LookupEmergencyBypassEquipment_intEmergencyBypassEquipmentID]
GO

ALTER TABLE [dbo].[tblSystem]  WITH CHECK ADD  CONSTRAINT [fktblSystem_LookupEmergencyPowerSource_intEmergencyPowerSourceID] FOREIGN KEY([intEmergencyPowerSourceID])
REFERENCES [dbo].[LookupEmergencyPowerSource] ([intEmergencyPowerSourceID])
GO

ALTER TABLE [dbo].[tblSystem] CHECK CONSTRAINT [fktblSystem_LookupEmergencyPowerSource_intEmergencyPowerSourceID]
GO


ALTER TABLE [dbo].[tblSystem]  WITH CHECK ADD  CONSTRAINT [fktblSystem_LookupMediaType_intMediaTypeID] FOREIGN KEY([intMediaTypeID])
REFERENCES [dbo].[LookupMediaType] ([intMediaTypeID])
GO

ALTER TABLE [dbo].[tblSystem] CHECK CONSTRAINT [fktblSystem_LookupMediaType_intMediaTypeID]
GO



ALTER TABLE [dbo].[tblSystem]  WITH CHECK ADD  CONSTRAINT [fktblSystem_LookupTelephoneSystemCommunicationType_intTelephoneSystemCommunicationTypeID] FOREIGN KEY([intTelephoneSystemCommunicationTypeID])
REFERENCES [dbo].[LookupTelephoneSystemCommunicationType] ([intTelephoneSystemCommunicationTypeID])
GO

ALTER TABLE [dbo].[tblSystem] CHECK CONSTRAINT [fktblSystem_LookupTelephoneSystemCommunicationType_intTelephoneSystemCommunicationTypeID]
GO

