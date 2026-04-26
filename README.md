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

