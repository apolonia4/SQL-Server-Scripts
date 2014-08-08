--Create UserDefined Data Type

CREATE TYPE [schema_name. ] type_name 
{ FROM base_type([precision] , [scale] ) 
[NULL | NOT NULL] 
}


CREATE TYPE PersonName 
FROM varchar(50) 
NOT NULL 
GO
CREATE TABLE TeamMembers 
(MemberId int PRIMARY KEY, 
MemberName PersonName, 
ManagerName PersonName) ; 
GO