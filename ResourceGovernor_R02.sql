-- Step 1 Create Workload Group
BEGIN TRAN;

CREATE WORKLOAD GROUP NetFlowService;

GO
COMMIT TRAN;

-- Step 2 Create a classification function.
-- Note that any request that does not get classified goes into 
-- the 'default' group.

CREATE FUNCTION dbo.rgclassifier_v1() RETURNS sysname 
WITH SCHEMABINDING
AS
BEGIN
    DECLARE @grp_name sysname
     
      IF (APP_NAME() LIKE '%NetFlowService%')
         
          SET @grp_name = 'NetFlowService'
    
    RETURN @grp_name
END;
GO
-- Register the classifier function with Resource Governor
ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION= dbo.rgclassifier_v1);
GO
-- Start Resource Governor
ALTER RESOURCE GOVERNOR RECONFIGURE;
GO

--Step 3 -- Create a new resource pool and set a maximum CPU limit.

BEGIN TRAN;

CREATE RESOURCE POOL NetFlow
WITH (MAX_CPU_PERCENT = 60);
-- Configure the workload group so it uses the new resource pool. 
-- The following statement moves 'GroupAdhoc' from the 'default' pool --- to 'PoolAdhoc'
ALTER WORKLOAD GROUP NetFlowService
USING NetFlow;
COMMIT TRAN;
GO
-- Apply the changes to the Resource Governor in-memory configuration.
ALTER RESOURCE GOVERNOR RECONFIGURE;
GO
