select  COLUMN_NAME, 
        (select  count(*) + 1
        from    INFORMATION_SCHEMA.COLUMNS tx
        where   tx.TABLE_NAME = t1.TABLE_NAME 
            and tx.ORDINAL_POSITION < t1.ORDINAL_POSITION) ORDINAL_POSITION
from    INFORMATION_SCHEMA.COLUMNS t1
where   TABLE_NAME = 'sortiemissiontypelookup'
