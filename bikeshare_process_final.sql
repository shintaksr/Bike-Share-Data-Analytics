-- DISPLAY TABLE
SELECT * FROM raw_data

-- ---------------------------------------------------------------------------------------------------
-- 4. HANDLING DUPLICATES (check and drop (if exist))
SELECT
	ride_id,
	count(*)
FROM raw_data
GROUP BY ride_id
HAVING COUNT(*)>1

-- ---------------------------------------------------------------------------------------------------
-- 6. DROP THE NULL VALUE
-- check how many null rows (USE THIS)
SELECT
	SUM(CASE WHEN start_lat IS NULL THEN 1 ELSE 0 END) AS start_lat_null,
	SUM(CASE WHEN start_lng IS NULL THEN 1 ELSE 0 END) AS start_lng_null,
	SUM(CASE WHEN end_lat IS NULL THEN 1 ELSE 0 END) AS end_lat_null,
	SUM(CASE WHEN end_lng IS NULL THEN 1 ELSE 0 END) AS end_lng_null
FROM raw_data
-- there are 5835 rows with nulls
-- drop all the rows with nulls in start_lat, start_lng, end_lat, and end_lng column
DELETE FROM raw_data
WHERE
	end_lat IS NULL OR 
	end_lng IS NULL;
-- 5835 rows are deleted