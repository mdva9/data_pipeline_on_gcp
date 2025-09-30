# 🚖 NYC Yellow Taxi Data Pipeline on Google Cloud Platform

This project demonstrates the implementation of an end-to-end **ELT data pipeline** on **Google Cloud Platform (GCP)** using **Cloud Storage, BigQuery, and Cloud Composer (Apache Airflow)**.  
The pipeline ingests raw taxi trip data, stores it in GCS, loads and transforms it into BigQuery, and orchestrates workflows with Cloud Composer.

---

## 📂 Project Structure
nyc-yellow-taxi-trips-pipeline/
│
├── dags/                           # Airflow DAGs
│   └── elt_dag_pipeline.py         # Main ELT pipeline definition
│
├── data/                           # Reference data or small lookup files
│   └── taxi_zone_lookup.csv        # NYC taxi zones metadata
│
├── scripts/                        # Python scripts for ETL steps
│   ├── create_datasets.py          # Create BigQuery datasets
│   ├── download_taxi_data.py       # Download raw taxi trip data
│   ├── load_raw_trips_data.py      # Load raw data into BigQuery tables
│   └── transform_trips_data.py     # Clean and transform raw data
│
├── sql/                            # SQL scripts for analytics
│   └── analytics_views.sql         # Analytical views for reporting & dashboards
│
├── requirements.txt                # Python dependencies
├── README.md                       # Project documentation

---

## 🚀 Pipeline Architecture
![Pipeline Architecture](screenshots/architecture.png)

**Steps:**
1. Raw data ingested into **Google Cloud Storage (GCS)**  
2. Loaded into **BigQuery** as raw tables  
3. Transformed with **SQL scripts** and structured into datasets  
4. Orchestrated with **Cloud Composer (Airflow DAGs)**  
5. Views created for potential business use cases  
---

## ⚙️ Google Cloud Platform Setup

### 1. Prerequisites
- Active GCP account
- Project created
- Required services enabled: **Cloud Storage, BigQuery, Cloud Composer**

### 2. Clone the repo and set up the environment
```bash
git clone https://github.com/mdva9/data_pipeline_on_gcp.git
cd data_pipeline_on_gcp/

python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```
### 3. Google Cloud Storage (GCS)
Create a bucket via the GCP console, then upload the project files
```bash
export DESTINATION_BUCKET_NAME=<your-bucket-name>
gcloud storage cp -r nyc-yellow-taxi-trips/* gs://$DESTINATION_BUCKET_NAME/from-git/
```

### 4. BigQuery 
Create the necessary datasets:
```bash
python3 create_datasets.py
```
### 5. Airflow (Cloud Composer)

1. Create a Service Account with the following roles:
    - Storage Object Admin
    - Storage Object Viewer
    - Composer Worker
    - BigQuery Data Editor

2. Create a Cloud Composer environment via the GCP console.

3. Import the DAG into Cloud Composer:
```bash
gcloud composer environments storage dags import \
  --environment <your-composer-env> \
  --location us-central1 \
  --source dags/elt_dag_pipeline.py
```
4. If you modify DAG files, update them in GCS:
```bash
gsutil cp dags/*.py gs://$DESTINATION_BUCKET_NAME/from-git/
```


