SELECT * 
FROM ::fn_trace_gettable(
'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\audittrace20111005131047.trc', default
)

--Failed login attempts
SELECT *
FROM ::fn_trace_gettable(
'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\audittrace20111005131047.trc', default
)
WHERE textdata like '%Login Failed%'

SELECT *
FROM ::fn_trace_gettable(
'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\audittrace20111005131047.trc', default
)
WHERE textdata like '%Drop%'