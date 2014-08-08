select * from a
select * from b


select a.row_num, b.col_num, sum(a.value * b.value)
from a,b
where a.col_num= b.row_num
group by a.row_num, b.col_num


--Similarity Matrix
SELECT b.docid, b.term, SUM(a.count * b.count) 
FROM (SELECT * FROM Frequency
      UNION
      SELECT  'q' as docid, 'washington' as term, 1 as count 
      UNION
      SELECT  'q' as docid, 'taxes' as term, 1 as count
      UNION 
      SELECT  'q' as docid, 'treasury' as term, 1 as count 
     ) a, Frequency b
WHERE a.term = b.term 
AND a.docid = 'q'
GROUP BY b.docid, b.term
ORDER BY SUM(a.count * b.count);