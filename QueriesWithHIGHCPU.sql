select * from sys.sysprocesses
-- HIGH CPU *******
    -- Get the most CPU intensive queries
    SET NOCOUNT ON;

    DECLARE @SpID smallint
    DECLARE spID_Cursor CURSOR
    FAST_FORWARD FOR
   
    SELECT TOP 25 spid
    FROM master..sysprocesses
    WHERE status = 'runnable'
    AND spid > 50   -- Eliminate system SPIDs
    AND spid <> @@SPID
    ORDER BY CPU DESC

    OPEN spID_Cursor

    FETCH NEXT FROM spID_Cursor
    INTO @spID
        WHILE @@FETCH_STATUS = 0
        BEGIN
            PRINT 'Spid #:' + STR(@spID)
            EXEC ('DBCC INPUTBUFFER (' + @spID + ')')

               FETCH NEXT FROM spID_Cursor
            INTO @spID
        END

    -- Close and deallocate the cursor
    CLOSE spID_Cursor
    DEALLOCATE spID_Cursor

 

 

 -- HIGH CPU *******
      -- Isolate top waits for server instance
      WITH Waits AS
      (
        SELECT
            wait_type,
            wait_time_ms / 1000. AS wait_time_s,
            100. * wait_time_ms / SUM(wait_time_ms) OVER() AS pct,
            ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS rn
        FROM sys.dm_os_wait_stats
        WHERE wait_type NOT LIKE '%SLEEP%'
      )
      SELECT
        W1.wait_type,
        CAST(W1.wait_time_s AS DECIMAL(12, 2)) AS wait_time_s,
        CAST(W1.pct AS DECIMAL(12, 2)) AS pct,
        CAST(SUM(W2.pct) AS DECIMAL(12, 2)) AS running_pct
      FROM Waits AS W1
      INNER JOIN Waits AS W2
      ON W2.rn <= W1.rn
      GROUP BY W1.rn, W1.wait_type, W1.wait_time_s, W1.pct
      HAVING SUM(W2.pct) - W1.pct < 90 -- percentage threshold
      ORDER BY W1.rn;