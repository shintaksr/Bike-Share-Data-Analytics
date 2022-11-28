SELECT * FROM raw_data

-- -------------------------------------------------------------------------------------
-- 7. users percentage
SELECT
	member_casual,
	COUNT(member_casual) AS total_users,
	ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(), 2) AS users_percentage
FROM raw_data
GROUP BY member_casual;

-- -------------------------------------------------------------------------------------
-- 8. count of rides in every month and season
-- 8a. count total month
SELECT
	EXTRACT(MONTH FROM started_at) AS month,
	COUNT(EXTRACT(MONTH FROM started_at)) AS month_total
FROM raw_data
GROUP BY month
ORDER BY month_total DESC

-- 8b. group the month to season
SELECT
	EXTRACT(MONTH FROM started_at) AS month,
	CASE
		WHEN EXTRACT(MONTH FROM started_at) BETWEEN 3 AND 5 THEN 'SPRING'
		WHEN EXTRACT(MONTH FROM started_at) BETWEEN 6 AND 8 THEN 'SUMMER'
		WHEN EXTRACT(MONTH FROM started_at) BETWEEN 9 AND 11 THEN 'AUTUMN'
		ELSE 'WINTER'
		END season
FROM raw_data
GROUP BY month
ORDER BY month ASC

-- 8c. season in percent
SELECT
	CASE
		WHEN EXTRACT(MONTH FROM started_at) BETWEEN 3 AND 5 THEN 'SPRING'
		WHEN EXTRACT(MONTH FROM started_at) BETWEEN 6 AND 8 THEN 'SUMMER'
		WHEN EXTRACT(MONTH FROM started_at) BETWEEN 9 AND 11 THEN 'AUTUMN'
		ELSE 'WINTER'
		END season,
	ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(), 2) AS users_percent_per_season
FROM raw_data
GROUP BY season
ORDER BY users_percent_per_season DESC

-- -------------------------------------------------------------------------------------
-- 9. count rides in every day and time
-- 9a. group the day and display the % of riders in every day
SELECT
	CASE
		WHEN EXTRACT(DOW FROM started_at)=1 THEN 'SUNDAY'
		WHEN EXTRACT(DOW FROM started_at)=2 THEN 'MONDAY'
		WHEN EXTRACT(DOW FROM started_at)=3 THEN 'TUESDAY'
		WHEN EXTRACT(DOW FROM started_at)=4 THEN 'WEDNESDAY'
		WHEN EXTRACT(DOW FROM started_at)=5 THEN 'THURSDAY'
		WHEN EXTRACT(DOW FROM started_at)=6 THEN 'FRIDAY'
		ELSE 'SATURDAY'
		END days,
	ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(), 2) AS users_percentage_per_day
FROM raw_data
GROUP BY days
ORDER BY users_percentage_per_day DESC

-- 9b. extract the start time and display the % of riders in each time
SELECT 
	CASE
		WHEN EXTRACT(HOUR FROM started_at) BETWEEN 5 AND 8 THEN 'EARLY MORNING'
		WHEN EXTRACT(HOUR FROM started_at) BETWEEN 9 AND 11 THEN 'LATE MORNING'
		WHEN EXTRACT(HOUR FROM started_at) BETWEEN 12 AND 14 THEN 'EARLY AFTERNOON'
		WHEN EXTRACT(HOUR FROM started_at) BETWEEN 15 AND 16 THEN 'LATE AFTERNOON'
		WHEN EXTRACT(HOUR FROM started_at) BETWEEN 17 AND 18 THEN 'EARLY EVENING'
		WHEN EXTRACT(HOUR FROM started_at) BETWEEN 19 AND 20 THEN 'LATE EVENING'
		ELSE 'NIGHT'
	END time_part,
	ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(), 2) AS users_percentage_per_time
FROM raw_data
GROUP BY time_part
ORDER BY users_percentage_per_time DESC

-- -------------------------------------------------------------------------------------
-- 10. ride duration
SELECT 
	ride_id,
	member_casual,
	started_at,
	ended_at,
	ended_at - started_at AS ride_duration,
	CEIL(EXTRACT(EPOCH FROM ended_at - started_at)/60) AS ride_duration_hour
FROM raw_data
ORDER BY ride_duration DESC

-- -------------------------------------------------------------------------------------
-- 11. most popular start point
SELECT
	started_station_name,
	COUNT(started_station_name) AS count_start_point,
	ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(), 4) AS start_point_percent
FROM raw_data
WHERE started_station_name IS NOT NULL
GROUP BY started_station_name
ORDER BY start_point_percent DESC

-- -------------------------------------------------------------------------------------
-- 12. CREATE A SIMPLIFIED TABLE 
-- create empty table first
CREATE TABLE IF NOT EXISTS final_data(
	ride_id VARCHAR,
	rideable_type VARCHAR,
	started_at TIMESTAMP WITHOUT TIME ZONE, 
	ended_at TIMESTAMP WITHOUT TIME ZONE,
	ride_duration_minute NUMERIC,
	time_part TEXT,
	days TEXT,
	season TEXT,
	started_station_name VARCHAR,
	end_station_name VARCHAR,
	start_lat NUMERIC,
	start_lng NUMERIC,
	end_lat NUMERIC,
	end_lng NUMERIC,
	member_casual VARCHAR)
	
-- create values to put in the new table
WITH
	ride_time AS
	(SELECT
	 	ride_id,
	 	EXTRACT(HOUR FROM started_at) AS start_hour,
	 	EXTRACT(DOW FROM started_at) AS start_dow,
	 	EXTRACT(MONTH FROM started_at) AS start_month
	FROM raw_data),
	
	ride_duration AS
	(SELECT
		ride_id,
	 	FLOOR(EXTRACT(EPOCH FROM ended_at-started_at)/60) AS ride_duration_minute
	FROM raw_data),
	
	ride_time_group AS
	(SELECT
	 	ride_id,
		CASE
	 		WHEN start_month BETWEEN 3 AND 5 THEN 'SPRING'
			WHEN start_month BETWEEN 6 AND 8 THEN 'SUMMER'
			WHEN start_month BETWEEN 9 AND 11 THEN 'AUTUMN'
			ELSE 'WINTER'
		END season,
	 	CASE
			WHEN start_dow=1 THEN 'SUNDAY'
			WHEN start_dow=2 THEN 'MONDAY'
			WHEN start_dow=3 THEN 'TUESDAY'
			WHEN start_dow=4 THEN 'WEDNESDAY'
			WHEN start_dow=5 THEN 'THURSDAY'
			WHEN start_dow=6 THEN 'FRIDAY'
			ELSE 'SATURDAY'
		END days,
	 	CASE
			WHEN start_hour BETWEEN 5 AND 8 THEN 'EARLY MORNING'
			WHEN start_hour BETWEEN 9 AND 11 THEN 'LATE MORNING'
			WHEN start_hour BETWEEN 12 AND 14 THEN 'EARLY AFTERNOON'
			WHEN start_hour BETWEEN 15 AND 16 THEN 'LATE AFTERNOON'
			WHEN start_hour BETWEEN 17 AND 18 THEN 'EARLY EVENING'
			WHEN start_hour BETWEEN 19 AND 20 THEN 'LATE EVENING'
			ELSE 'NIGHT'
		END time_part
	FROM ride_time),
		
	data_fix AS
	(SELECT
	 	raw_data.ride_id,
		rideable_type,
	 	started_at, ended_at,
	 	ride_duration_minute,
	 	time_part, days, season,
		started_station_name, end_station_name,
	 	start_lat, start_lng,
	 	end_lat, end_lng,
	 	member_casual
	FROM raw_data
	JOIN ride_time
		ON ride_time.ride_id = raw_data.ride_id
	JOIN ride_duration
		ON ride_duration.ride_id = raw_data.ride_id
	JOIN ride_time_group
		ON ride_time_group.ride_id = raw_data.ride_id
	WHERE ride_duration_minute >= 1)
INSERT INTO final_data(
	ride_id,
	rideable_type,
	started_at, ended_at,
	ride_duration_minute,
	time_part, days, season,
	started_station_name, end_station_name,
	start_lat, start_lng,
	end_lat, end_lng,
	member_casual)	
SELECT *
FROM data_fix

SELECT *
FROM final_data

-- -------------------------------------------------------------------------------------
-- 13. save table
COPY (SELECT * FROM final_data) TO 'D:\Belajar data analysis\PORTFOLIO\bike share - google data analytics\bikeshare sql final\final_data.csv' DELIMITER ','CSV HEADER;
