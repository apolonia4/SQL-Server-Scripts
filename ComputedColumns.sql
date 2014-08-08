--Add Computed column *Do not specify data type
Alter TABLE MASI_SB2.DBO.NewTable
Add Speed as [miles]/[time] persisted

--Drop persisted property on Computed Column
Alter TABLE MASI_SB2.DBO.NewTable
Alter Column Speed DROP PERSISTED
