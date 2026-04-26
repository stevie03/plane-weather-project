{{ config(materialized='view') }}

WITH raw_flights AS (
    SELECT * FROM {{ source('raw_data', 'ext_raw_flights') }}
),
unnested_flights AS (
    SELECT 
        time AS extraction_timestamp,
        flight_state
    FROM raw_flights,
    UNNEST(JSON_QUERY_ARRAY(states)) AS flight_state
)

SELECT
    extraction_timestamp,
    JSON_VALUE(flight_state, '$[0]') AS icao24,
    TRIM(JSON_VALUE(flight_state, '$[1]')) AS callsign,
    JSON_VALUE(flight_state, '$[2]') AS origin_country,
    CAST(JSON_VALUE(flight_state, '$[5]') AS FLOAT64) AS longitude,
    CAST(JSON_VALUE(flight_state, '$[6]') AS FLOAT64) AS latitude,
    CAST(JSON_VALUE(flight_state, '$[7]') AS FLOAT64) AS altitude_meters,
    CAST(JSON_VALUE(flight_state, '$[9]') AS FLOAT64) AS velocity_m_s
FROM unnested_flights
WHERE JSON_VALUE(flight_state, '$[0]') IS NOT NULL