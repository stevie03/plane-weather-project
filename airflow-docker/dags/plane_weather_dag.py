from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'istvan_orosz',
    'depends_on_past': False,
    'email_on_failure': False, 
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=1),
}


with DAG(
    'plane_weather_pipeline',
    default_args=default_args,
    description='Automated ELT pipeline for Flight and Weather data',
    schedule_interval='@hourly',
    start_date=datetime(2026, 4, 24),
    catchup=False,
    tags=['aviation', 'weather', 'dbt', 'bigquery']
) as dag:

    extract_flights_task = BashOperator(
        task_id='extract_flights_data',
        bash_command='python /opt/airflow/dags/extract_flights.py'
    )

    extract_weather_task = BashOperator(
        task_id='extract_weather_data',
        bash_command='python /opt/airflow/dags/extract_weather.py'
    )

    run_dbt_task = BashOperator(
        task_id='run_dbt_models_and_tests',
        bash_command='cd /opt/airflow/dags/plane_project && dbt build --profiles-dir .'
    )

    [extract_flights_task, extract_weather_task] >> run_dbt_task