{{config(materialized='table')}}

WITH staging_weather AS (
    SELECT * FROM {{ ref('stg_weather') }}
),
weather_fact AS (
    SELECT
        city,
        latitude,
        longitude,
        measured_at,
        temperature_celsius,
        wind_speed_kmh,
        weather_code 
    FROM staging_weather
    WHERE city IS NOT NULL 
)
SELECT * FROM weather_fact
