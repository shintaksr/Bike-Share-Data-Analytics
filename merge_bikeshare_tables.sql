-- 1. CREATE TABLES
CREATE TABLE IF NOT EXISTS public.raw_data
(
    ride_id character varying COLLATE pg_catalog."default" NOT NULL,
    rideable_type character varying COLLATE pg_catalog."default",
    started_at timestamp without time zone,
    ended_at timestamp without time zone,
    started_station_name character varying COLLATE pg_catalog."default",
    start_station_id character varying COLLATE pg_catalog."default",
    end_station_name character varying COLLATE pg_catalog."default",
    end_station_id character varying COLLATE pg_catalog."default",
    start_lat numeric,
    start_lng numeric,
    end_lat numeric,
    end_lng numeric,
    member_casual character varying COLLATE pg_catalog."default"
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.raw_data
    OWNER to postgres;
	
-- DISPLAY TABLE
SELECT * FROM raw_data

-- -------------------------------------------------------------------------------------
-- 2. COMBINE TABLES IN ONE VIEW
CREATE VIEW trips_data_raw AS
	SELECT * FROM trips_2111
	UNION
	SELECT * FROM trips_2112
	UNION
	SELECT * FROM trips_2201
	UNION
	SELECT * FROM trips_2202
	UNION
	SELECT * FROM trips_2203
	UNION
	SELECT * FROM trips_2204
	UNION
	SELECT * FROM trips_2205
	UNION
	SELECT * FROM trips_2206
	UNION
	SELECT * FROM trips_2207
	UNION
	SELECT * FROM trips_2208
	UNION
	SELECT * FROM trips_2209
	UNION
	SELECT * FROM trips_2210
	
SELECT * FROM trips_data_raw
-- total of rows: 5,755,694

-- -------------------------------------------------------------------------------------
-- 3. Save table
COPY (SELECT * FROM trips_data_raw) TO 'D:\Belajar data analysis\PORTFOLIO\bike share - google data analytics\bikeshare sql final\raw_data.csv' DELIMITER ','CSV HEADER;
