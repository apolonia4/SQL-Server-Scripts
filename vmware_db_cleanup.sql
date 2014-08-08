--1.  Perform FULL backup of vmware_db database

--2.  Stop VMware VirtualCenter Server service on the vCenter Server

--3.  Get ID, this will be 1587 (select ID from VPX_ENTITY where name ='Test Snapshot restore')

--4.  Run Delete Statements
use vmware_db
GO
DELETE from VPX_DS_ASSIGNMENT where DS_ID=1587;
GO
DELETE from VPX_VM_DS_SPACE where DS_ID=1587;
GO
DELETE from VPX_DATASTORE where ID=1587;
GO
DELETE from VPX_ENTITY where ID=1587
GO

--5.  Verify datastore references removed
/*Run these queries to verify if the datastore has been removed 
from the VPX_ENTITY, VPX_DS_ASSIGNMENT, and VPX_DATASTORE tables:*/

select * from VPX_DS_ASSIGNMENT where DS_ID=1587;
select * from VPX_VM_DS_SPACE where DS_ID=1587;
select * from VPX_DATASTORE where ID=1587;
select * from VPX_ENTITY where ID=1587;

--6.  Start the VMware VirtualCenter Server service on the vCenter Server