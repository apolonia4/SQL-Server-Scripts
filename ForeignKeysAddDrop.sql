--Add Foreign Key
ALTER TABLE [PortPartner].[Organization]  WITH CHECK ADD CONSTRAINT [fkMasiUnitPortPartnerOrganizationUnitId] FOREIGN KEY([ParentUnitId])
REFERENCES [Masi].[Unit] ([UnitId])
GO

--Drop foreign key
alter table Misle.Activity
drop CONSTRAINT fkMisleActivityMisleActivityStatusLookup