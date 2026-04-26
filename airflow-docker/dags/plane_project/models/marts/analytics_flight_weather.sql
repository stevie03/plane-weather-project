{{ config(materialized='table') }}

WITH flights AS (
    SELECT 
        aircraft_id,
        velocity_m_s,
        altitude_meters,
        TIMESTAMP_TRUNC(TIMESTAMP_SECONDS(extraction_timestamp), HOUR) AS flight_hour,
        
        CASE
            WHEN latitude BETWEEN 46.5 AND 48.5 AND longitude BETWEEN 18.0 AND 20.0 THEN 'Budapest'
            WHEN latitude BETWEEN 50.5 AND 52.5 AND longitude BETWEEN -1.5 AND 1.5 THEN 'London'
            WHEN latitude BETWEEN 49.0 AND 51.0 AND longitude BETWEEN 7.5 AND 9.5 THEN 'Frankfurt'
            WHEN latitude BETWEEN 48.0 AND 49.5 AND longitude BETWEEN 1.0 AND 3.0 THEN 'Parizs'
            WHEN latitude BETWEEN 41.0 AND 42.5 AND longitude BETWEEN 11.5 AND 13.5 THEN 'Roma'
            ELSE 'Unknown'
        END AS current_city
    FROM {{ ref('fct_flight_tracking') }}
),

weather AS (
    SELECT 
        city,
        temperature_celsius,
        wind_speed_kmh,
        weather_code,
        TIMESTAMP_TRUNC(TIMESTAMP_SUB(measured_at, INTERVAL 2 HOUR), HOUR) AS weather_hour
    FROM {{ ref('fct_weather') }}
)


SELECT 
    f.aircraft_id,
    f.current_city,
    f.flight_hour,
    f.velocity_m_s,
    f.altitude_meters,
    w.temperature_celsius,
    w.wind_speed_kmh,
    w.weather_code
FROM flights f
LEFT JOIN weather w 
    ON f.current_city = w.city 
    AND f.flight_hour = w.weather_hour
WHERE f.current_city != 'Ismeretlen'