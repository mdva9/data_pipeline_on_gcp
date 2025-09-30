/*
==========================================================
📄 File: analytics_views.sql
Description:
This file contains the creation of three core analytical views
for the NYC Yellow Taxi Data Pipeline. These views transform
raw trip data into structured outputs that can be directly
consumed by analysts, business users, or dashboards.

Each view answers a specific business question related to
demand, pricing, and operational efficiency.
==========================================================
*/

-- ========================================================
-- I/ Market Demand & Seasonality
-- Question 1: How does the demand for yellow taxis fluctuate
-- over time (daily, weekly, monthly, and seasonally)?
--
-- This view aggregates trips by different time dimensions
-- (day, week, month, weekday) to analyze demand patterns
-- over time.
-- ========================================================

CREATE OR REPLACE VIEW `views_fordashboard.demand_over_time` AS
SELECT
    DATE(tpep_pickup_datetime) AS trip_date,
    EXTRACT(YEAR FROM tpep_pickup_datetime) AS year,
    EXTRACT(MONTH FROM tpep_pickup_datetime) AS month,
    EXTRACT(WEEK FROM tpep_pickup_datetime) AS week,
    EXTRACT(DAYOFWEEK FROM tpep_pickup_datetime) AS weekday,
    COUNT(*) AS total_trips
FROM `nyc-yellow-trips.transformed_data.cleaned_and_filtered`
GROUP BY trip_date, year, month, week, weekday
ORDER BY trip_date;

-- Quick check
SELECT * FROM `views_fordashboard.demand_over_time`;


-- ========================================================
-- II/ Financial & Pricing Analysis
-- Question 2: What is the average fare per trip, and how
-- does it vary by borough, time of day, and trip distance?
--
-- This view provides insights into pricing by calculating
-- average fares, total amounts, and distances, grouped by
-- pickup/dropoff borough and time of day.
-- ========================================================

CREATE OR REPLACE VIEW `views_fordashboard.avg_fare_analysis` AS
SELECT
    DATE(t.tpep_pickup_datetime) AS trip_date,
    EXTRACT(YEAR FROM t.tpep_pickup_datetime) AS year,
    EXTRACT(MONTH FROM t.tpep_pickup_datetime) AS month,
    EXTRACT(HOUR FROM t.tpep_pickup_datetime) AS pickup_hour,
    pz.Borough AS pickup_borough,
    dz.Borough AS dropoff_borough,
    ROUND(AVG(t.fare_amount), 2) AS avg_fare_per_trip,
    ROUND(AVG(t.total_amount), 2) AS avg_total_amount_per_trip,
    ROUND(AVG(t.trip_distance), 2) AS avg_trip_distance,
    COUNT(*) AS total_trips
FROM `nyc-yellow-trips.transformed_data.cleaned_and_filtered` t
JOIN `nyc-yellow-trips.raw_yellowtrips.taxi_zone` pz
    ON t.PULocationID = pz.LocationID
JOIN `nyc-yellow-trips.raw_yellowtrips.taxi_zone` dz
    ON t.DOLocationID = dz.LocationID
GROUP BY trip_date, year, month, pickup_hour, pickup_borough, dropoff_borough;

-- Quick check
SELECT * FROM `views_fordashboard.avg_fare_analysis` LIMIT 1000;


-- ========================================================
-- III/ Competitive Insights & Operational Efficiency
-- Question 3: How frequently do yellow taxis serve airports
-- (JFK, LaGuardia, Newark), and what is the average fare
-- for these trips?
--
-- This view isolates trips involving major airports and
-- calculates total volume, average fare, and average distance.
-- It is useful for understanding travel demand and pricing
-- patterns for strategic transport hubs.
-- ========================================================

CREATE OR REPLACE VIEW `views_fordashboard.airport_trips_analysis` AS
SELECT
    DATE(t.tpep_pickup_datetime) AS trip_date,
    EXTRACT(YEAR FROM t.tpep_pickup_datetime) AS year,
    EXTRACT(MONTH FROM t.tpep_pickup_datetime) AS month,
    CASE
        WHEN pz.Zone = 'JFK Airport' OR dz.Zone = 'JFK Airport' THEN 'JFK Airport'
        WHEN pz.Zone = 'LaGuardia Airport' OR dz.Zone = 'LaGuardia Airport' THEN 'LaGuardia Airport'
        WHEN pz.Zone = 'Newark Airport' OR dz.Zone = 'Newark Airport' THEN 'Newark Airport'
        ELSE 'Other'
    END AS airport,
    COUNT(*) AS total_trips,
    ROUND(AVG(t.total_amount), 2) AS avg_fare,
    ROUND(AVG(t.trip_distance), 2) AS avg_distance
FROM `nyc-yellow-trips.transformed_data.cleaned_and_filtered` t
JOIN `nyc-yellow-trips.raw_yellowtrips.taxi_zone` pz
    ON t.PULocationID = pz.LocationID
JOIN `nyc-yellow-trips.raw_yellowtrips.taxi_zone` dz
    ON t.DOLocationID = dz.LocationID
WHERE pz.Zone IN ('JFK Airport', 'LaGuardia Airport', 'Newark Airport')
   OR dz.Zone IN ('JFK Airport', 'LaGuardia Airport', 'Newark Airport')
GROUP BY trip_date, year, month, airport;

-- Quick check
SELECT * FROM `views_fordashboard.airport_trips_analysis` LIMIT 1000;
