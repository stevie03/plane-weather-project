import requests
import json
from datetime import datetime
from google.cloud import storage
import os

os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "/opt/airflow/dags/google-key.json"
BUCKET_NAME = "raw_plane_data_stevie03"

CITIES = {
    "Budapest": (46.5, 18.0, 48.5, 20.0),
    "London": (50.5, -1.5, 52.5, 1.5),
    "Frankfurt": (49.0, 7.5, 51.0, 9.5),
    "Parizs": (48.0, 1.0, 49.5, 3.0),
    "Roma": (41.0, 11.5, 42.5, 13.5)
}

def fetch_weather_and_upload():
    storage_client = storage.Client()
    bucket = storage_client.bucket(BUCKET_NAME)

    all_weather_data = []
    timestamp_now = datetime.now().strftime("%Y%m%d_%H%M%S")

    for city, bbox in CITIES.items():
        center_lat = (bbox[0] + bbox[2]) / 2
        center_lon = (bbox[1] + bbox[3]) / 2

        url = f"https://api.open-meteo.com/v1/forecast?latitude={center_lat}&longitude={center_lon}&current=temperature_2m,wind_speed_10m,weather_code"
        response = requests.get(url)

        if response.status_code == 200:
            data = response.json()
            
            weather_record = {
                "city": city,
                "latitude": center_lat,
                "longitude": center_lon,
                "extraction_timestamp": timestamp_now,
                "temperature_celsius": data["current"]["temperature_2m"],
                "wind_speed_kmh": data["current"]["wind_speed_10m"],
                "weather_code": data["current"]["weather_code"]
            }
            all_weather_data.append(weather_record)

    if all_weather_data:
        ndjson_content = "\n".join([json.dumps(record) for record in all_weather_data])
        blob_name = f"weather/weather_{timestamp_now}.json"
        blob = bucket.blob(blob_name)
        blob.upload_from_string(ndjson_content, content_type="application/json")
        

if __name__ == "__main__":
    fetch_weather_and_upload()