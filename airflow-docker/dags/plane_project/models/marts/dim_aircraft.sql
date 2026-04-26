{{ config(materialized='table') }}

WITH staging_flights AS (
    SELECT * FROM {{ ref('stg_flights') }}
),

unique_aircrafts AS (
    SELECT 
        icao24 AS aircraft_id,
        MAX(callsign) AS callsign,      
        MAX(origin_country) AS origin_country
    FROM staging_flights
    WHERE icao24 IS NOT NULL
    GROUP BY 1  
)

SELECT * FROM unique_aircrafts