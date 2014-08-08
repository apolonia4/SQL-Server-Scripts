USE AdventureWorks2012;
GO
-- Set up a login for the test user
CREATE LOGIN TestCreditRatingUser
   WITH PASSWORD = 'ASDECd2439587y'
GO
CREATE USER TestCreditRatingUser
FOR LOGIN TestCreditRatingUser;
GO


CREATE CERTIFICATE TestCreditRatingCer
   ENCRYPTION BY PASSWORD = 'pGFD4bb925DGvbd2439587y'
      WITH SUBJECT = 'Credit Rating Records Access', 
      EXPIRY_DATE = '12/05/2014';
GO

CREATE PROCEDURE TestCreditRatingSP
AS
BEGIN
   -- Show who is running the stored procedure
   SELECT SYSTEM_USER 'system Login'
   , USER AS 'Database Login'
   , NAME AS 'Context'
   , TYPE
   , USAGE 
   FROM sys.user_token   

   -- Now get the data
   SELECT AccountNumber, Name, CreditRating 
   FROM Purchasing.Vendor
   WHERE CreditRating = 1
END
GO

ADD SIGNATURE TO TestCreditRatingSP 
   BY CERTIFICATE TestCreditRatingCer
    WITH PASSWORD = 'pGFD4bb925DGvbd2439587y';
GO