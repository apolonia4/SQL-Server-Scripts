CREATE FUNCTION dbo. fn_ResourceGovernorClassifier()
RETURNS sysname
WITH SCHEMABINDING
AS
BEGIN
    DECLARE @group sysname
    --Workl oad group name is case sensi tive, 
    --    regardless of server setting
     IF SUSER_SNAME() = ' Executive'
        SET @group = 'Executi veGroup'
    ELSE IF SUSER_SNAME() = ' Customer'
        SET @group = 'CustomerGroup'
    ELSE IF SUSER_SNAME() = ' AdHocReport'
        SET @group = 'AdHocReportGroup'
    ELSE
        SET @group = 'default'    
    RETURN @group        
END
GO

--Associate Classifier Code with Resource Governor
ALTER RESOURCE GOVERNOR 
WITH (CLASSIFIER_FUNCTION = dbo. fn_ResourceGovernorClassifier)
GO
--Execute the following code to make the classi?er function active: 
ALTER RESOURCE GOVERNOR RECONFIGURE
GO