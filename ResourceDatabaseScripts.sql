SELECT OBJECT_DEFINITION(OBJECT_ID('sys.objects'))

-- on my test system this yields the following:
CREATE VIEW sys.objects AS SELECT name, object_id, principal_id, schema_id, parent_object_id,    type, type_desc, create_date, modify_date,    is_ms_shipped, is_published, is_schema_published   FROM sys.objects
    
SELECT SERVERPROPERTY('ResourceVersion');
GO

SELECT SERVERPROPERTY('ResourceLastUpdateDateTime');
GO


