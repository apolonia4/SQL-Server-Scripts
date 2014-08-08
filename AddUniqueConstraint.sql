ALTER TABLE Masi.UserPreferences ADD CONSTRAINT 
            uncidxMasiUserPreferencesUserSid UNIQUE NONCLUSTERED 
    ( 
                UserSid
    ) 

