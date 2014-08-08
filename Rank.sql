

SELECT train, dest, time FROM ( 
  SELECT train, dest, time,
    RANK() OVER (PARTITION BY train ORDER BY time DESC) as  dest_rank
    FROM traintable) As A
	WHERE dest_rank = 1





select train, max(time) as MostRecent from traintable
WHERE train = 'A'
GROUP BY train



