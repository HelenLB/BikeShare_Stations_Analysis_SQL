--2017
SELECT bs.id AS Station_id, bs.name AS Station_name,COUNT(bb17.end_station_id) AS popularity_in_2017
FROM bluebikes_stations bs
INNER JOIN bluebikes_2017 bb17 ON bb17.end_station_id=bs.id
GROUP BY bs.name, bs.id
ORDER BY Station_id;

--2018
SELECT bs.id AS Station_id, bs.name AS Station_name,COUNT(bb18.end_station_id) AS popularity_in_2018
FROM bluebikes_stations bs
INNER JOIN bluebikes_2018 bb18 ON bb18.end_station_id=bs.id
GROUP BY bs.name, bs.id
ORDER BY Station_id;

--2019
SELECT bs.id AS Station_id, bs.name AS Station_name,COUNT(bb19.end_station_id) AS popularity_in_2019
FROM bluebikes_stations bs
INNER JOIN bluebikes_2019 bb19 ON bb19.end_station_id=bs.id
GROUP BY bs.name, bs.id
ORDER BY Station_id;


--Combined the popularity of stations from 2017-19
SELECT sta.id AS Station_id, sta.name AS Station_name, sta.total_docks AS Number_docks, COUNT(big_table.start_station_id) AS Popularity
FROM (
    SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type
    FROM bluebikes_2019
    UNION
    SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type
    FROM bluebikes_2018
    UNION
    SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type
    FROM bluebikes_2017
    ) big_table
    INNER JOIN public.bluebikes_stations sta
    ON big_table.start_station_id = sta.id
GROUP BY 1, 2, 3
ORDER BY 4 DESC;

--The most popular routes to the most popular station

SELECT sta.id AS Station_id, sta.name AS Station_name, sta.total_docks AS Number_docks, COUNT(big_table.bike_id) AS Popularity
FROM (
    SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type 
    FROM bluebikes_2019
    UNION
    SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type
    FROM bluebikes_2018
    UNION
    SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type
    FROM bluebikes_2017
    ) big_table
    INNER JOIN public.bluebikes_stations sta
    ON big_table.start_station_id = sta.id
WHERE big_table.end_station_id=67
GROUP BY 1, 2, 3, 4
ORDER BY 5 DESC;

--The most popular routes from the most popular station

SELECT sta.id AS Station_id, sta.name AS Station_name, sta.total_docks AS Number_docks, COUNT(big_table.bike_id) AS Popularity
FROM (
    SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type 
    FROM bluebikes_2019
    UNION
    SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type
    FROM bluebikes_2018
    UNION
    SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type
    FROM bluebikes_2017
    ) big_table
    INNER JOIN public.bluebikes_stations sta
    ON big_table.end_station_id = sta.id
WHERE big_table.start_station_id=67
GROUP BY 1, 2, 3
ORDER BY 4 DESC;

--How long to earn back 75000 dollars from the new station, counting the relevant users
SELECT user_type, COUNT(bike_id)
FROM bluebikes_2019
GROUP BY user_type;

--Basic Facts
SELECT *
FROM bluebikes_stations;

--Statistics about the types of users, their age, the starting station to the most popular station MIT
WITH all_years AS (
	SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender
	FROM bluebikes_2017
	UNION
	SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender
	FROM bluebikes_2018
	UNION
	SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender
	FROM bluebikes_2019
)

SELECT bb_sta.name AS station_name, bb_sta.total_docks AS number_docks, (2019-all_years.user_birth_year::numeric) AS the_age
FROM all_years
INNER JOIN bluebikes_stations bb_sta ON all_years.start_station_id=bb_sta.id
WHERE end_station_id=67 AND NOT all_years.user_birth_year='\N'
GROUP BY 1,2,3
ORDER BY the_age,number_docks DESC;

--Statistics about the types of users, their age, the starting station from the most popular station MIT

WITH all_years AS (
	SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender
	FROM bluebikes_2017
	UNION
	SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender
	FROM bluebikes_2018
	UNION
	SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender
	FROM bluebikes_2019
)

SELECT bb_sta.name AS station_name, bb_sta.total_docks AS number_docks, (2019-all_years.user_birth_year::numeric) AS the_age
FROM all_years
INNER JOIN bluebikes_stations bb_sta ON all_years.end_station_id=bb_sta.id
WHERE all_years.start_station_id=67 AND NOT all_years.user_birth_year='\N'
GROUP BY 1,2,3
ORDER BY the_age,number_docks DESC;

--Grouping by the age and types of customers

WITH all_years AS (
	SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender
	FROM bluebikes_2017
	UNION
	SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender
	FROM bluebikes_2018
	UNION
	SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender
	FROM bluebikes_2019
)

SELECT (2019-user_birth_year::numeric) AS the_age, user_type AS the_membership, COUNT(*)
FROM all_years
WHERE NOT user_birth_year='\N' AND (2019-user_birth_year::numeric) < 100
GROUP BY 1,2
ORDER BY COUNT(*) DESC;


--Making different age groups

WITH all_years AS (
	SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender
	FROM bluebikes_2017
	UNION
	SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender
	FROM bluebikes_2018
	UNION
	SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender
	FROM bluebikes_2019
)

SELECT user_type AS the_membership,
	CASE
		WHEN (2019-user_birth_year::numeric) >= 65 THEN 'Seniors'
		WHEN (2019-user_birth_year::numeric) >= 25 THEN 'Adults'
		WHEN (2019-user_birth_year::numeric) >= 15 THEN 'Youth'
	END AS Age_groups,
	COUNT(*) AS the_amount
FROM all_years
WHERE NOT user_birth_year='\N' AND (2019-user_birth_year::numeric) < 100
GROUP BY 1,2
ORDER BY COUNT(*) DESC;


--Ages 2019

SELECT user_type AS the_membership,
	CASE
		WHEN (2019-user_birth_year::numeric) >= 65 THEN 'Seniors'
		WHEN (2019-user_birth_year::numeric) >= 25 THEN 'Adults'
		WHEN (2019-user_birth_year::numeric) >= 15 THEN 'Youth'
	END AS Age_groups,
	COUNT(*) AS the_amount
FROM bluebikes_2019
WHERE NOT user_birth_year='\N' AND (2019-user_birth_year::numeric) < 100
GROUP BY 1,2
ORDER BY COUNT(*) DESC;

