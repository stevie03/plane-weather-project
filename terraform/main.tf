terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}
provider "google" {
  project = "arboreal-tracer-494111-h9"
  region  = "europe-west1" 
}

resource "google_storage_bucket" "data_lake_bronze" {
  name          = "raw_plane_data_stevie03" 
  location      = "EU"
  force_destroy = true
  uniform_bucket_level_access = true 
}

resource "google_bigquery_dataset" "data_warehouse" {
  dataset_id                  = "plane_datastorage" 
  description                 = "Star schema table"
  location                    = "EU"
  delete_contents_on_destroy  = true
}

resource "google_bigquery_table" "external_raw_flights" {
  dataset_id = google_bigquery_dataset.data_warehouse.dataset_id
  table_id   = "ext_raw_flights"


  deletion_protection = false


  schema = <<EOF
  [
    {
      "name": "time",
      "type": "INTEGER"
    },
    {
      "name": "states",
      "type": "JSON"
    }
  ]
  EOF
  
  external_data_configuration {
    autodetect    = true
    source_format = "NEWLINE_DELIMITED_JSON" 

    
    source_uris = [
      "gs://${google_storage_bucket.data_lake_bronze.name}/raw/*"
    ]
  }
}

resource "google_bigquery_table" "external_raw_weather" {
  dataset_id = google_bigquery_dataset.data_warehouse.dataset_id
  table_id   = "ext_raw_weather"


  schema = <<EOF
  [
    {"name": "city", "type": "STRING"},
    {"name": "latitude", "type": "FLOAT"},
    {"name": "longitude", "type": "FLOAT"},
    {"name": "extraction_timestamp", "type": "STRING"},
    {"name": "temperature_celsius", "type": "FLOAT"},
    {"name": "wind_speed_kmh", "type": "FLOAT"},
    {"name": "weather_code", "type": "INTEGER"}
  ]
  EOF
  external_data_configuration {
    autodetect    = false 
    source_format = "NEWLINE_DELIMITED_JSON" 
    
    source_uris = [
      "gs://${google_storage_bucket.data_lake_bronze.name}/weather/*"
    ]
  }
}