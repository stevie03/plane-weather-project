import os
import requests
import json
from datetime import datetime
from dotenv import load_dotenv
from google.cloud import storage

load_dotenv()
CLIENT_ID = os.getenv('OPENSKY_CLIENT_ID')
CLIENT_SECRET = os.getenv('OPENSKY_CLIENT_SECRET')


os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "/opt/airflow/dags/google-key.json"
BUCKET_NAME = "raw_plane_data_stevie03"



CITIES = {
    "Budapest": (46.5, 18.0, 48.5, 20.0),
    "London": (50.5, -1.5, 52.5, 1.5),
    "Frankfurt": (49.0, 7.5, 51.0, 9.5),
    "Parizs": (48.0, 1.0, 49.5, 3.0),
    "Roma": (41.0, 11.5, 42.5, 13.5)
}

def get_token():
    url = "https://auth.opensky-network.org/auth/realms/opensky-network/protocol/openid-connect/token"
    payload = {"grant_type": "client_credentials", "client_id": CLIENT_ID, "client_secret": CLIENT_SECRET}
    response = requests.post(url, data=payload)
    return response.json().get("access_token") if response.status_code == 200 else None

def upload_to_gcs(bucket_name, destination_blob_name, json_data):
    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(destination_blob_name)

    blob.upload_from_string(
        data=json.dumps(json_data),
        content_type='application/json'
    )

def extract_and_load_to_datalake():
    token = get_token()
    if not token:
        return

    headers = {"Authorization": f"Bearer {token}"}
    

    for city, bbox in CITIES.items():
        url = f"https://opensky-network.org/api/states/all?lamin={bbox[0]}&lomin={bbox[1]}&lamax={bbox[2]}&lomax={bbox[3]}"
        
        response = requests.get(url, headers=headers)
        
        if response.status_code == 200:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            blob_name = f"raw/{city}/{city}_{timestamp}.json"  
            upload_to_gcs(BUCKET_NAME, blob_name, response.json())
        else:
            print(f" Error: {response.status_code}")

if __name__ == "__main__":
    extract_and_load_to_datalake()