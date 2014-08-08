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