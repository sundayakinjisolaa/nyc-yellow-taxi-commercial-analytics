-- NYC Yellow Taxi Commercial Analytics
-- DuckDB analysis examples for the NYC TLC Yellow Taxi Parquet data.
-- Full project scope: 1 January 2025 through 31 July 2026.

-- 1. Read the Parquet files without loading the full dataset into Pandas.
CREATE OR REPLACE VIEW yellow_taxi AS
SELECT *
FROM read_parquet('yellow_tripdata_*.parquet', union_by_name = true);


-- 2. Create the analytical date scope.
CREATE OR REPLACE VIEW yellow_taxi_analysis AS
SELECT *
FROM yellow_taxi
WHERE tpep_pickup_datetime >= '2025-01-01'
  AND tpep_pickup_datetime < '2026-08-01'
  AND tpep_dropoff_datetime >= tpep_pickup_datetime;


-- 3. Main commercial view.
-- Payment types 3 (No Charge) and 4 (Dispute) are retained in the
-- analytical dataset but excluded from the main commercial KPI view.
CREATE OR REPLACE VIEW yellow_taxi_commercial AS
SELECT *
FROM yellow_taxi_analysis
WHERE payment_type NOT IN (3, 4);


-- 4. Core commercial KPIs.
SELECT
    COUNT(*) AS commercial_trips,
    SUM(total_amount) AS recorded_revenue,
    AVG(total_amount) AS avg_revenue_per_trip,
    AVG(fare_amount) AS avg_fare
FROM yellow_taxi_commercial;


-- 5. Monthly demand and revenue.
SELECT
    DATE_TRUNC('month', tpep_pickup_datetime) AS month,
    COUNT(*) AS trips,
    SUM(total_amount) AS revenue,
    AVG(total_amount) AS avg_revenue_per_trip
FROM yellow_taxi_commercial
GROUP BY 1
ORDER BY 1;


-- 6. Hourly demand and revenue.
SELECT
    EXTRACT(HOUR FROM tpep_pickup_datetime) AS pickup_hour,
    COUNT(*) AS trips,
    SUM(total_amount) AS revenue,
    AVG(total_amount) AS avg_revenue_per_trip
FROM yellow_taxi_commercial
GROUP BY 1
ORDER BY 1;


-- 7. Revenue yield by distance band.
-- Distances above 100 miles are excluded from distance-based commercial
-- metrics because extreme records can distort the analysis.
SELECT
    CASE
        WHEN trip_distance > 0 AND trip_distance <= 2 THEN '0-2 miles'
        WHEN trip_distance > 2 AND trip_distance <= 5 THEN '2-5 miles'
        WHEN trip_distance > 5 AND trip_distance <= 10 THEN '5-10 miles'
        WHEN trip_distance > 10 AND trip_distance <= 20 THEN '10-20 miles'
        WHEN trip_distance > 20 AND trip_distance <= 100 THEN '20-100 miles'
    END AS distance_band,
    COUNT(*) AS trips,
    AVG(trip_distance) AS avg_distance,
    AVG(fare_amount) AS avg_fare,
    AVG(total_amount) AS avg_total,
    SUM(fare_amount) / NULLIF(SUM(trip_distance), 0) AS fare_per_mile
FROM yellow_taxi_commercial
WHERE trip_distance > 0
  AND trip_distance <= 100
GROUP BY 1
ORDER BY
    CASE distance_band
        WHEN '0-2 miles' THEN 1
        WHEN '2-5 miles' THEN 2
        WHEN '5-10 miles' THEN 3
        WHEN '10-20 miles' THEN 4
        WHEN '20-100 miles' THEN 5
    END;


-- 8. Airport-related performance.
-- Airport_fee > 0 is used as the airport-related indicator.
SELECT
    CASE
        WHEN Airport_fee > 0 THEN 'Airport-related'
        ELSE 'Non-airport'
    END AS trip_type,
    COUNT(*) AS trips,
    AVG(trip_distance) AS avg_distance,
    AVG(fare_amount) AS avg_fare,
    AVG(total_amount) AS avg_total,
    SUM(fare_amount) / NULLIF(SUM(trip_distance), 0) AS fare_per_mile
FROM yellow_taxi_commercial
GROUP BY 1;


-- 9. Payment-type monitoring.
SELECT
    payment_type,
    COUNT(*) AS trips,
    SUM(total_amount) AS recorded_revenue,
    AVG(total_amount) AS avg_total,
    COUNT(*) FILTER (WHERE total_amount <= 0) AS non_positive_total
FROM yellow_taxi_analysis
GROUP BY 1
ORDER BY payment_type;


-- 10. Duration performance.
SELECT
    CASE
        WHEN DATE_DIFF('minute', tpep_pickup_datetime, tpep_dropoff_datetime) < 15
            THEN '<15 min'
        WHEN DATE_DIFF('minute', tpep_pickup_datetime, tpep_dropoff_datetime) < 30
            THEN '15-30 min'
        WHEN DATE_DIFF('minute', tpep_pickup_datetime, tpep_dropoff_datetime) < 60
            THEN '30-60 min'
        ELSE '60+ min'
    END AS duration_band,
    COUNT(*) AS trips,
    SUM(total_amount) AS revenue,
    AVG(total_amount) AS avg_revenue_per_trip
FROM yellow_taxi_commercial
GROUP BY 1
ORDER BY 1;


-- 11. Weekday vs weekend.
SELECT
    CASE
        WHEN DAYOFWEEK(tpep_pickup_datetime) IN (0, 6)
            THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(*) AS trips,
    SUM(total_amount) AS revenue,
    AVG(total_amount) AS avg_revenue_per_trip
FROM yellow_taxi_commercial
GROUP BY 1;


-- 12. Data-quality audit.
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE trip_distance <= 0) AS non_positive_distance,
    COUNT(*) FILTER (WHERE fare_amount <= 0) AS non_positive_fare,
    COUNT(*) FILTER (WHERE total_amount <= 0) AS non_positive_total,
    COUNT(*) FILTER (
        WHERE tpep_dropoff_datetime <= tpep_pickup_datetime
    ) AS invalid_duration
FROM yellow_taxi_analysis;
