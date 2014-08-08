--Create Master Key on DB --must do this for service broker
use masi_sb2
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '12345P@s$w0rd8416'

--Backup Master Key
use masi_sb2
BACKUP MASTER KEY TO FILE = 'D:\MasterKey_MASI_SB\MASI_SB2_MasterKey' ENCRYPTION BY PASSWORD = '12345P@s$w0rd8416'

--Open Master Key
OPEN MASTER KEY DECRYPTION BY PASSWORD = '12345P@s$w0rd8416'



RESTORE MASTER KEY 
    FROM FILE = 'D:\MasterKey_MASI_SB\MASI_SB2_MasterKey' 
    DECRYPTION BY PASSWORD = '12345P@s$w0rd8416' 
    ENCRYPTION BY PASSWORD = '12345P@s$w0rd8416';
GO


