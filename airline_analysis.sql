
use airline;


show tables;

select * from `indian airlines`;

# count of the data in database

select count(*) from `indian airlines` ;

# q1 :- Which airline has the highest average ticket price?

select airline , avg(price) as avg_price from `indian airlines` group by airline order by avg_price desc limit 1;

# q2 :- How do average fares differ between Economy and Business class?

 select class ,round(avg(price),2) as avg_price from `indian airlines` group by class ;
 
 # q3 :- How does the number of stops affect ticket prices?
 
 select stops,count(*) as count , avg(price) as avg_price from `indian airlines`  group by stops;

# create table route 

create table route ( route  varchar(50) null);

# insert value by using python

select count(*) from route;

select * from `indian airlines`;

select * from route;

desc `indian airlines`;

desc route;

select * from `indian airlines` ;

alter table `indian airlines` add column route varchar(50);

SET @row_num = 0;

ALTER TABLE `indian airlines`
ADD COLUMN `index` INT;

UPDATE `indian airlines`
SET `index` = (@row_num := @row_num + 1);

commit;

ALTER TABLE `route`
ADD COLUMN `index` INT;

UPDATE `route`
SET `index` = (@row_num := @row_num + 1);

select * from route;

select * from `indian airlines`;

# q4:-  Which routes have the highest and lowest average fares
 
 #lowest avg fare route :-  
 # Hyderabad - Delhi
 
 with avg_price as (select route , avg(price)as AVG_fare from `indian airlines` as a inner join route as r 
 on a.`index` = r. `index` group by route) 
 (select * from avg_price order by AVG_fare asc limit 1); 
 
# route avg highest fare :-  
#Chennai - Bangalore

 with avg_price as (select route , avg(price)as AVG_fare from `indian airlines` as a inner join route as r 
 on a.`index` = r. `index` group by route) 
 (select * from avg_price order by AVG_fare desc limit 1);
 
 
 # q5 :-  How do listed fares vary with the number of days left before departure?
 
 SELECT
    days_left,
    COUNT(*) AS total_flights,
    ROUND(AVG(price), 2) AS avg_fare,
    MIN(price) AS min_fare,
    MAX(price) AS max_fare
FROM `indian airlines`
GROUP BY days_left
ORDER BY days_left;
 
 
 # q6 :- Are fares higher for last-minute listings than early listings ?
 
SELECT
    CASE
        WHEN days_left <= 7 THEN 'Last-Minute'
        WHEN days_left >= 30 THEN 'Early'
        ELSE 'Medium'
    END AS booking_period,
    COUNT(*) AS total_flights,
    ROUND(AVG(price), 2) AS avg_fare
FROM `indian airlines`
GROUP BY booking_period
ORDER BY avg_fare DESC;



# q 7 :-  Which departure-time category has the highest average fare?
# ans :-
# night 
# morning
# Evening

select departure_time , avg(price) as avg_price  from `indian airlines` group by departure_time order by avg_price desc;

# q8 :- Does arrival time show a similar pricing pattern to departure time?

# yes it show similar pattern 

select arrival_time , avg(price) as avg_price  from `indian airlines` group by arrival_time order by avg_price desc;
 
 
# q9 :- Do longer flights generally have higher ticket prices?

# almost yes 

select min(duration) , max(duration) from `indian airlines`;

SELECT
    CASE
        WHEN duration >= 0 AND duration < 5 THEN '1-5 Hours'
        WHEN duration >= 5 AND duration < 10 THEN '5-10 Hours'
        WHEN duration >= 10 AND duration < 15 THEN '10-15 Hours'
        WHEN duration >= 15 AND duration < 20 THEN '15-20 Hours'
        WHEN duration >= 20 AND duration < 25 THEN '20-25 Hours'
        WHEN duration >= 25 AND duration < 30 THEN '25-30 Hours'
        WHEN duration >= 30 AND duration < 35 THEN '30-35 Hours'
        WHEN duration >= 35 AND duration < 40 THEN '35-40 Hours'
        WHEN duration >= 40 AND duration < 45 THEN '40-45 Hours'
        WHEN duration >= 45 AND duration <= 50 THEN '45-50 Hours'
    END AS duration_bucket,
    COUNT(*) AS total_flights,
    ROUND(AVG(price), 2) AS avg_price
FROM `indian airlines`
GROUP BY duration_bucket
ORDER BY avg_price asc;
 
 
#  q10:-   Which airline offers the lowest average fare on each route?

WITH route_fares AS (
    SELECT
        source_city,
        destination_city,
        airline,
        ROUND(AVG(price), 2) AS avg_fare
    FROM `indian airlines`
    GROUP BY source_city, destination_city, airline
),
ranked_fares AS (
    SELECT *,
        DENSE_RANK() OVER (
            PARTITION BY source_city, destination_city
            ORDER BY avg_fare ASC
        ) AS fare_rank
    FROM route_fares
)
SELECT
    source_city,
    destination_city,
    airline,
    avg_fare
FROM ranked_fares
WHERE fare_rank = 1
ORDER BY source_city, destination_city;



 
#  q11  :-  Which airlines have the highest and lowest fares within the same route and class?

WITH airline_route_fares AS (
    SELECT
        source_city,
        destination_city,
        `class`,
        airline,
        COUNT(*) AS total_listings,
        ROUND(AVG(price), 2) AS avg_fare
    FROM `indian airlines`
    GROUP BY
        source_city,
        destination_city,
        `class`,
        airline
),
ranked_fares AS (
    SELECT
        *,
        RANK() OVER (
            PARTITION BY source_city, destination_city, `class`
            ORDER BY avg_fare DESC
        ) AS highest_fare_rank,

        RANK() OVER (
            PARTITION BY source_city, destination_city, `class`
            ORDER BY avg_fare ASC
        ) AS lowest_fare_rank
    FROM airline_route_fares
)
SELECT
    source_city,
    destination_city,
    `class`,
    airline,
    total_listings,
    avg_fare,
    CASE
        WHEN highest_fare_rank = 1 THEN 'Highest Average Fare'
        WHEN lowest_fare_rank = 1 THEN 'Lowest Average Fare'
    END AS fare_category
FROM ranked_fares
WHERE highest_fare_rank = 1
   OR lowest_fare_rank = 1
ORDER BY source_city, destination_city, `class`, avg_fare DESC;

# q12 :- How do airlines rank by average fare, and which airlines have similar rankings?

WITH airline_fares AS (
    SELECT
        airline,
        COUNT(*) AS total_listings,
        ROUND(AVG(price), 2) AS avg_fare
    FROM `indian airlines`
    GROUP BY airline
),
ranked_airlines AS (
    SELECT
        airline,
        total_listings,
        avg_fare,
        RANK() OVER (ORDER BY avg_fare DESC) AS fare_rank,
        DENSE_RANK() OVER (ORDER BY avg_fare DESC) AS dense_fare_rank
    FROM airline_fares
)
SELECT *
FROM ranked_airlines
ORDER BY fare_rank, airline;

# q13 :- Does the fare gap between Economy and Business vary across airlines?

SELECT
    airline,
    ROUND(AVG(CASE
        WHEN class = 'Economy' THEN price
    END), 2) AS economy_avg_fare,

    ROUND(AVG(CASE
        WHEN class = 'Business' THEN price
    END), 2) AS business_avg_fare,

    ROUND(
        AVG(CASE WHEN class = 'Business' THEN price END)
        - AVG(CASE WHEN class = 'Economy' THEN price END),
        2
    ) AS fare_gap

FROM `indian airlines`
GROUP BY airline
ORDER BY fare_gap DESC;

