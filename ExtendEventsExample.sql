-- Extended Event for finding *long running query*
 IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='LongRunningQuery')
 DROP EVENT SESSION LongRunningQuery ON SERVER
 GO
 -- Create Event
 CREATE EVENT SESSION LongRunningQuery
 ON SERVER
 -- Add event to capture event
 ADD EVENT sqlserver.sql_statement_completed
 (
 -- Add action - event property
 ACTION (sqlserver.sql_text, sqlserver.tsql_stack)
 -- Predicate - time 1000 milisecond
 WHERE sqlserver.sql_statement_completed.duration > 1000
 )
 -- Add target for capturing the data - XML File
 ADD TARGET package0.asynchronous_file_target(
 SET filename='c:\LongRunningQuery.xet', metadatafile='c:\LongRunningQuery.xem'),
 -- Add target for capturing the data - Ring Bugger
 ADD TARGET package0.ring_buffer
 (SET max_memory = 4096)
 WITH (max_dispatch_latency = 1 seconds)
 GO
 -- Enable Event
 ALTER EVENT SESSION LongRunningQuery ON SERVER
 STATE=START
 GO
 -- Run long query (longer than 1000 ms)
 SELECT *
 FROM AdventureWorks.Sales.SalesOrderDetail
 ORDER BY UnitPriceDiscount DESC
 GO
 -- Stop the event
 ALTER EVENT SESSION LongRunningQuery ON SERVER
 STATE=STOP
 GO
 -- Read the data from Ring Buffer
 SELECT CAST(dt.target_data AS XML) AS xmlLockData
 FROM sys.dm_xe_session_targets dt
 JOIN sys.dm_xe_sessions ds ON ds.Address = dt.event_session_address
 JOIN sys.server_event_sessions ss ON ds.Name = ss.Name
 WHERE dt.target_name = 'ring_buffer'
 AND ds.Name = 'LongRunningQuery'
 GO
 -- Read the data from XML File
 SELECT event_data_XML.value('(event/data[1])[1]','VARCHAR(100)') AS Database_ID,
 event_data_XML.value('(event/data[2])[1]','INT') AS OBJECT_ID,
 event_data_XML.value('(event/data[3])[1]','INT') AS object_type,
 event_data_XML.value('(event/data[4])[1]','INT') AS cpu,
 event_data_XML.value('(event/data[5])[1]','INT') AS duration,
 event_data_XML.value('(event/data[6])[1]','INT') AS reads,
 event_data_XML.value('(event/data[7])[1]','INT') AS writes,
 event_data_XML.value('(event/action[1])[1]','VARCHAR(512)') AS sql_text,
 event_data_XML.value('(event/action[2])[1]','VARCHAR(512)') AS tsql_stack,
 CAST(event_data_XML.value('(event/action[2])[1]','VARCHAR(512)') AS XML).value('(frame/@handle)[1]','VARCHAR(50)') AS handle
 FROM
 (
 SELECT CAST(event_data AS XML) event_data_XML, *
 FROM sys.fn_xe_file_target_read_file
 ('c:\LongRunningQuery*.xet',
 'c:\LongRunningQuery*.xem',
 NULL, NULL)) T
 GO
 -- Clean up. Drop the event
 DROP EVENT SESSION LongRunningQuery
 ON SERVER
 GO