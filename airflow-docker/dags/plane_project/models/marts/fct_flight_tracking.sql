{{ config(materialized='table') }}

WITH staging_flights AS (
    SELECT * FROM {{ ref('stg_flights') }}
),

flight_tracking AS (
    SELECT
        icao24 AS aircraft_id,          
        extraction_timestamp,          
        longitude,
        latitude,
        altitude_meters,
        velocity_m_s
    FROM staging_flights
    WHERE icao24 IS NOT NULL
)

SELECT * FROM flight_tracking