--Backup db and log
USE master
GO
BACKUP DATABASE WSS_Acquisitions TO DISK ='C:\MSSQL\Backup\MasiStage\WSS_Acquisitions.bak' WITH FORMAT
GO
BACKUP LOG WSS_Acquisitions TO DISK ='C:\MSSQL\Backup\MasiStage\WSS_Acquisitions.trn' WITH FORMAT
GO

--Copy files to mirror server to restore

RESTORE DATABASE WSS_Acquisitions
    FROM DISK = 'C:\MSSQL\Backup\WSS_Acquisitions.bak' 
    WITH NORECOVERY
GO


RESTORE LOG WSS_Acquisitions
    FROM DISK = 'C:\MSSQL\Backup\WSS_Acquisitions.trn' 
    WITH NORECOVERY
GO

--Create Endpoints

/******  DB20 Object:  Endpoint [Mirroring]    Script Date: 02/08/2011 10:47:31 ******/
CREATE ENDPOINT [Mirroring] 
	AUTHORIZATION [MAIN\osc-svc-masi-stage]
	STATE=STARTED
	AS TCP (LISTENER_PORT = 5022, LISTENER_IP = ALL)
	FOR DATA_MIRRORING (ROLE = PARTNER, AUTHENTICATION = WINDOWS NEGOTIATE)
GO


/****** DB21 Object:  Endpoint [Mirroring]    Script Date: 02/08/2011 10:46:51 ******/
CREATE ENDPOINT [Mirroring] 
	AUTHORIZATION [MAIN\osc-svc-masi-stage]
	STATE=STARTED
	AS TCP (LISTENER_PORT = 5022, LISTENER_IP = ALL)
	FOR DATA_MIRRORING (ROLE = PARTNER, AUTHENTICATION = WINDOWS NEGOTIATE)
GO


/****** DB22\MasiStageWitness Object:  Endpoint [Mirroring]    Script Date: 02/08/2011 10:46:51 ******/
CREATE ENDPOINT [Mirroring] 
	AUTHORIZATION [MAIN\osc-svc-masi-stage]
	STATE=STARTED
	AS TCP (LISTENER_PORT = 5023, LISTENER_IP = ALL)
	FOR DATA_MIRRORING (ROLE = WITNESS, AUTHENTICATION = WINDOWS NEGOTIATE)
GO

--Must run from the Mirror database first
ALTER DATABASE MasiStage
SET PARTNER = 'TCP://oscms-masi-db20.main.ads.uscg.mil:5022';

--Run on the principal second
ALTER DATABASE MasiStage
SET PARTNER = 'TCP://oscms-masi-db21.main.ads.uscg.mil:5022'
    
--Run on the principal to set the witness third
ALTER DATABASE MasiStage
    SET WITNESS = 'TCP://oscms-masi-db21.main.ads.uscg.mil:5023'
    
      
--****TO REMOVE MIRRORING****---- ON Principal, set partner off  
--1)  
ALTER DATABASE MasiStage SET PARTNER OFF

--On the mirror, recover the database
--2)
RESTORE DATABASE MasiStage WITH RECOVERY;

--3) Drop endpoints on each instance
DROP ENDPOINT Mirroring

--To check endpoints
SELECT * FROM sys.endpoints




