--The script for renaming any object (table, sp etc) :
sp_rename 'Masi.SystemOfRecord' , 'SystemOfRecordLookup'

alter schema Masi transfer CurrentUnitResourceStatusLookup

--CurrentUnitResourceStatusLookup
--Change column name
create table Masi.SystemOfRecord
(
SystemOfRecordId int PRIMARY KEY IDENTITY(1,1)
, Description varchar(50)
, ResourceType varchar(50)
, LastModifiedDateTime datetime2
, CreatedDateTime datetime2
)


sp_rename 'Masi.UnitStatusAppointmentLookup.UnitAppointmentStatusLookupId' , 'UnitStatusAppointmentLookupId', 'COLUMN'

select * from Masi.CurrentUnitResourceStatusLookup

Insert into Masi.CurrentUnitResourceStatusLookup ([Description], Color) VALUES ('Alpha', '00B050')
Insert into Masi.CurrentUnitResourceStatusLookup ([Description], Color) VALUES ('Bravo 0', 'FFFF00')
Insert into Masi.CurrentUnitResourceStatusLookup ([Description], Color) VALUES ('Bravo 2', 'FFFF00')
Insert into Masi.CurrentUnitResourceStatusLookup ([Description], Color) VALUES ('Bravo 4', 'FFFF00')
Insert into Masi.CurrentUnitResourceStatusLookup ([Description], Color) VALUES ('Bravo 6', 'FFFF00')
Insert into Masi.CurrentUnitResourceStatusLookup ([Description], Color) VALUES ('Bravo 12', 'FFFF00')
Insert into Masi.CurrentUnitResourceStatusLookup ([Description], Color) VALUES ('Bravo 24', 'FFFF00')
Insert into Masi.CurrentUnitResourceStatusLookup ([Description], Color) VALUES ('Bravo 48', 'FFFF00')
Insert into Masi.CurrentUnitResourceStatusLookup ([Description], Color) VALUES ('Bravo 96', 'FFFF00')
Insert into Masi.CurrentUnitResourceStatusLookup ([Description], Color) VALUES ('Charlie', 'FF0000')
Insert into Masi.CurrentUnitResourceStatusLookup ([Description], Color) VALUES ('Tango', 'B2A1C7')
Insert into Masi.CurrentUnitResourceStatusLookup ([Description], Color) VALUES ('Full Mission Capable', '00B050')
Insert into Masi.CurrentUnitResourceStatusLookup ([Description], Color) VALUES ('Degraded Capable', 'FFFF00')
Insert into Masi.CurrentUnitResourceStatusLookup ([Description], Color) VALUES ('Not Mission Capable', 'FF0000')
Insert into Masi.CurrentUnitResourceStatusLookup ([Description], Color) VALUES ('Not Applicable', '000000')






