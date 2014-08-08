select *, cast(replace(chvDirectorysizeMB, ',','') as decimal(18,4))/1024 DirectorySizeGB from tblMartinsburgDirResult
WHERE chvDirectoryname = 'SharePoint24118'
order by DirectorySizeGB desc


