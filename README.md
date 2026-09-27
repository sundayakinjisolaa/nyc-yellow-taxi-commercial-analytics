# NYC Yellow Taxi Commercial Analytics

Business analytics project analysing NYC Yellow Taxi demand, revenue, geographic and operational performance using Python, DuckDB and Power BI.

## Business Question

How can NYC Yellow Taxi operators use recent trip data to understand demand, revenue and operational performance and identify opportunities for improved commercial performance?

## Project Overview

This project analyses real NYC Taxi & Limousine Commission (TLC) Yellow Taxi trip data covering **1 January 2025 to 31 July 2026**.

The analysis focuses on:

- Demand patterns
- Revenue performance
- Geographic performance
- Airport activity
- Time-of-day patterns
- Distance and revenue yield
- Trip duration and revenue efficiency
- Payment and data-quality issues

The full dataset contains more than **75 million trips**, so DuckDB was used to query the Parquet files efficiently without loading the entire dataset into Pandas memory.

## Why Yellow Taxi?

Yellow Taxi was selected because it provides a clearly defined commercial market with detailed trip-level information covering demand, location, distance, fares, payment types and timing.

This makes it suitable for analysing revenue, demand patterns and operational performance within a focused and interpretable market.

## Key Findings

### 1. Revenue increased while trip volume declined

For the matched January–July period:

- 2025 revenue: **$736.3M**
- 2026 revenue: **$791.0M**
- Recorded revenue increased by **7.4%**
- Trips decreased by approximately **4.0%**
- Average recorded revenue per trip increased by **11.9%**

This indicates that the increase in recorded revenue was not driven by higher trip volume alone.

### 2. Airport trips are high-value

Airport-related trips represented approximately **4.69 million trips** and had substantially higher average recorded revenue per trip than non-airport trips.

JFK Airport and LaGuardia Airport together represented approximately **17.12% of recorded revenue among named pickup zones**.

### 3. Demand and revenue vary significantly by time

Demand was highest during the late afternoon and evening period, with **18:00 recording the highest trip volume**.

The highest total recorded hourly revenue occurred at **17:00**, while **16:00 had the highest average recorded revenue per trip**.

### 4. Geographic performance is concentrated

Manhattan generated the largest volume of recorded commercial revenue.

Major commercial pickup zones included JFK Airport, LaGuardia Airport, Midtown Center, Upper East Side South and Times Square/Theatre District.

However, high trip volume did not always correspond to the highest revenue per trip.

### 5. Trip duration affects revenue efficiency

Longer trips generated higher revenue per trip, but recorded revenue per trip-hour declined as trip duration increased.

This highlights the difference between **revenue per trip** and **revenue efficiency over time**.

## Data Quality

The project included a dedicated data-quality assessment.

Issues identified included:

- Non-positive trip distances
- Non-positive fares
- Non-positive total amounts
- Zero-duration trips
- Missing passenger counts
- Extreme distance records
- No Charge and Dispute transaction categories

Rather than deleting anomalous records indiscriminately, the analysis separated the main commercial KPI view from records requiring additional investigation.

## Methodology

1. Data acquisition from official NYC TLC trip records
2. Data validation and quality assessment
3. Date-range filtering
4. DuckDB analysis of Parquet data
5. Commercial KPI development
6. Geographic analysis using the NYC Taxi Zone Lookup
7. Time and operational analysis
8. Business interpretation
9. Visualisation
10. Recommendations for commercial decision-making

## Tools

- **Python**
- **DuckDB**
- **Pandas**
- **Matplotlib**
- **Power BI**
- **SQL**
- **Parquet**

## Repository Structure

```text
nyc-yellow-taxi-commercial-analytics/
│
├── README.md
├── yellow_tripdata_2025-01_sample_100k.parquet
├── NYC_Yellow_Taxi_Reproducible_Demo.ipynb
├── duckdb_analysis.sql
│
├── 01_executive_overview.png
├── 02_monthly_revenue_trend.png
├── 03_hourly_demand_revenue.png
├── 04_geographic_performance.png
├── 05_revenue_concentration_vs_trip_value.png
├── 06_airport_performance.png
├── 07_distance_revenue_yield.png
├── 08_duration_revenue_efficiency.png
│
└── NYC_Yellow_Taxi_Portfolio_Sunday_Akinlemibola_FINAL_v2.pdf
