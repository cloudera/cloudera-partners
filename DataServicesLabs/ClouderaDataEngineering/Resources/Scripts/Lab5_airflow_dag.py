from dateutil import parser
from datetime import datetime, timedelta, date
from datetime import timezone
from airflow import DAG
from airflow.operators.dummy_operator import DummyOperator
from cloudera.cdp.airflow.operators.cde_operator import CDEJobRunOperator


## Update the username
owner = "<ENTER YOUR USERNAME HERE>".replace("-", "_") # Example: "apac01"

DAG_name = owner + "_Airflow_Dag"
job_name_1 = owner + "_Lab3B1_Data_Extraction_Sub_150k"
job_name_2 = owner + "_Lab3B2_Data_Extraction_Over_150k"
job_name_3 = owner + "_Lab3B3_Create_Reports"

default_args = {
    'owner': owner,
    'retry_delay': timedelta(seconds=5),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 0
}

dag = DAG(
    DAG_name,
    default_args=default_args,
    start_date=datetime(2023,5,3),
    end_date=datetime(2023,5,18),
    schedule_interval='*/20 * * * *',
    catchup=False,
    is_paused_upon_creation=False
)


start = DummyOperator(task_id='start', dag=dag)

Data_Extraction_Sub_150k = CDEJobRunOperator(
    task_id=job_name_1,
    retries=3,
    dag=dag,
    job_name=job_name_1
)

Data_Extraction_Over_150k = CDEJobRunOperator(
    task_id=job_name_2,
    dag=dag,
    job_name=job_name_2
)

Final_Report = CDEJobRunOperator(
    task_id=job_name_3,
    dag=dag,
    job_name=job_name_3
)

end = DummyOperator(task_id='end', dag=dag)

start >> Data_Extraction_Sub_150k >> Data_Extraction_Over_150k >> Final_Report >> end
