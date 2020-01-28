from functools import partial
from datetime import datetime, timedelta
from airflow.models import DAG
from airflow.contrib.operators.kubernetes_pod_operator import KubernetesPodOperator

from repo.dags.notifications import task_fail_slack_alert, task_success_slack_alert
from repo.dags.kubernetes_commons import my_affinity, my_tolerations, my_resources

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime.strptime('2020.01.28', '%Y.%m.%d'),
    'retry_delay': timedelta(minutes=5),
    'on_failure_callback': partial(task_fail_slack_alert, usr="ealebed"),
    'on_success_callback': partial(task_success_slack_alert, usr="ealebed"),
}

dag = DAG(
    dag_id='test_creatives_task',
    default_args=default_args,
    max_active_runs=1,
    schedule_interval="27,57 * * * *"
)

task = KubernetesPodOperator(
    namespace="default",
    image="ealebed/java:11",
    cmds=["java", "--version"],
    name="test-task",
    labels={"app": "test-creatives-task"},
    task_id="id-task",
    affinity=my_affinity,
    resources=my_resources,
    tolerations=my_tolerations,
    # Timeout to start up the Pod, default is 120.
    startup_timeout_seconds=30,
    get_logs=True,
    is_delete_operator_pod=False,
    hostnetwork=False,
    in_cluster=True,
    do_xcom_push=False,
    dag=dag
)
