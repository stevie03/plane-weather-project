# Flight & Weather Data Pipeline (Modern Data Stack)

A fully automated, containerized ELT (Extract, Load, Transform) data pipeline integrating real-time aviation and weather data. This project is built on Modern Data Stack (MDS) industry standards.

## Architecture & Tech Stack

The project leverages the following technologies for robust and scalable data processing:

* **Orchestration:** Apache Airflow (Dockerized)
* **Data Extraction:** Custom Python scripts (`extract_flights.py`, `extract_weather.py`) via REST APIs.
* **Data Transformation:** dbt (Data Build Tool)
* **Data Warehouse:** Google Cloud Platform / BigQuery
* **Infrastructure as Code (IaC):** Terraform
* **Containerization:** Docker & Docker Compose

The pipeline follows the industry-standard **Medallion Architecture**, processing data through three distinct layers using Google Cloud Storage (Buckets) and BigQuery:

* **Bronze Layer (Raw Data in Buckets):** The Python extraction scripts fetch real-time data from external APIs and load the raw, unprocessed JSON/CSV files directly into **Google Cloud Storage (GCS) Buckets**. This acts as our secure Data Lake and immutable single source of truth.
* **Silver Layer (Staging/Cleansed):** Data is ingested into BigQuery where **dbt** takes over. The staging models (`models/staging/`) clean, deduplicate, and standardize the raw bucket data (`stg_flights`, `stg_weather`).
* **Gold Layer (Analytics/Marts):** Final business logic is applied using dbt to create structured dimension and fact tables (`models/marts/`). This layer produces the final `analytics_flight_weather` table, which is highly optimized for fast querying and Business Intelligence (BI) dashboards.


## Data Modeling (dbt)

Data transformation follows the Kimball methodology using dbt, structured into clear, logical layers:

* **Staging (`models/staging/`):** Cleaning, standardizing, and deduplicating raw data (`stg_flights`, `stg_weather`).
* **Marts (`models/marts/`):** Dimension and fact tables enriched with business logic.
  * `dim_aircraft`: Aircraft master data and specifications.
  * `fct_flight_tracking`, `fct_weather`: Measurable transactional events and telemetry data.
  * `analytics_flight_weather`: An integrated, analytics-ready view combining flight metrics with localized weather conditions.


## Quick Start (Local Setup)

### Prerequisites
* Docker Desktop and Docker Compose installed.
* A valid GCP Service Account key (`google-key.json`) placed in the right directory.
* Terraform installed (to provision the GCP infrastructure).

