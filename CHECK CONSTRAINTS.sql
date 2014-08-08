ALTER TABLE Masi.Appointment
DROP CONSTRAINT ckAppointmentAppointmentTypeLookupId

ALTER TABLE Masi.MasterAppointment
ADD CONSTRAINT ckMasterAppointmentAppointmentTypeLookupId CHECK (AppointmentTypeLookupId = 1)

ALTER TABLE Masi.Appointment
ADD CONSTRAINT ckAppointmentAppointmentTypeLookupId CHECK ((AppointmentTypeLookupId = 2 OR AppointmentTypeLookupId = 3
OR AppointmentTypeLookupId = 4) OR (AppointmentTypeLookupId = 5 AND ResourceId IS NOT NULL AND ResourceTypeLookupId IS NOT NULL))


ALTER TABLE Masi.MasterAppointment
ADD CONSTRAINT ckMasterAppointmentScheduledStartDateTimeScheduledEndDateTime
CHECK (ScheduledStartDateTime < ScheduledEndDateTime)

ALTER TABLE Masi.Appointment
ADD CONSTRAINT ckAppointmentScheduledStartDateTimeScheduledEndDateTime
CHECK (ScheduledStartDateTime < ScheduledEndDateTime)

select * from Masi.AppointmentTypeLookup
select * from Masi.Appointment where AppointmentTypeLookupId = 3

