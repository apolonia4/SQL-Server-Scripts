select * from sys.procedures
select * from sys.databases
select * from sysobjects where xtype = 'p' and uid = 1

select t.sp_name, sum(t.lines_of_code) - 1 as lines_ofcode, t.type_desc from (     select o.name as sp_name,      (len(c.text) - len(replace(c.text, char(10), ''))) as lines_of_code,     case when o.xtype = 'P' then 'Stored Procedure'     when o.xtype in ('FN', 'IF', 'TF') then 'Function'     end as type_desc     from sysobjects o     inner join syscomments c     on c.id = o.id     where o.xtype in ('P', 'FN', 'IF', 'TF')     and o.category = 0     and o.name not in ('fn_diagramobjects', 'sp_alterdiagram', 'sp_creatediagram', 'sp_dropdiagram', 'sp_helpdiagramdefinition', 'sp_helpdiagrams', 'sp_renamediagram', 'sp_upgraddiagrams', 'sysdiagrams') ) t group by t.sp_name, t.type_desc order by 1 


EXEC dbo.sp_MSforeachdb 'USE [?]; select ''?'' as DatabaseName, count(*) from sysobjects where xtype = ''p'' and uid = 1'

select * from sys.procedures