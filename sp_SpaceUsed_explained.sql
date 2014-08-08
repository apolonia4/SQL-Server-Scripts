sp_spaceused
select * from sys.master_files
print ((18962944 * 8) /1024) /1024

106820784 KB --reserved Data Total amount of space allocated by objects in the database.
43830.83 MB --unallocated Space in the database that has not been reserved for database objects.

print (106820784/1024) + 43830.83

print 46605168 + 59690368 + 525248 = 106295536

print (106820784/1024) / 1024
