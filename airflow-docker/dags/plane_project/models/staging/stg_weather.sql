{{ config(materialized='view') }}

WITH raw_weather AS (
    SELECT * FROM {{ source('raw_data', 'ext_raw_weather') }}
)

SELECT
    city,
    latitude,
    longitude,
    PARSE_TIMESTAMP('%Y%m%d_%H%M%S', extraction_timestamp) AS measured_at,
    temperature_celsius,
    wind_speed_kmh,
    weather_code
FROM raw_weather
