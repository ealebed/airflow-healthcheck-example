#!/usr/bin/env bash

declare -a DEFAULT_CONNS=(
    "airflow_db"
    "slack"
    "cassandra_default"
    "azure_container_instances_default"
    "azure_cosmos_default"
    "azure_data_lake_default"
    "segment_default"
    "dingding_default"
    "qubole_default"
    "databricks_default"
    "emr_default"
    "sqoop_default"
    "redis_default"
    "druid_ingest_default"
    "druid_broker_default"
    "spark_default"
    "aws_default"
    "fs_default"
    "sftp_default"
    "ssh_default"
    "webhdfs_default"
    "wasb_default"
    "vertica_default"
    "local_mysql"
    "mssql_default"
    "http_default"
    "sqlite_default"
    "postgres_default"
    "mysql_default"
    "mongo_default"
    "metastore_default"
    "hiveserver2_default"
    "hive_cli_default"
    "opsgenie_default"
    "google_cloud_default"
    "presto_default"
    "bigquery_default"
    "beeline_default"
    "pig_cli_default"
)

case "$1" in
  webserver)
    airflow initdb
    airflow create_user \
      --role Admin \
      --username ${AIRFLOW_ADMIN_USER} \
      --password ${AIRFLOW_ADMIN_PASSWORD} \
      --firstname Air \
      --lastname Flow \
      --email air.flow@examle.com
    for CONN in "${DEFAULT_CONNS[@]}"
    do
      airflow connections --delete --conn_id ${CONN}
    done
    airflow connections \
      --add \
      --conn_id postgres_default \
      --conn_uri ${AIRFLOW_CONN_POSTGRES_DEFAULT}
    airflow connections \
      --add \
      --conn_id slack \
      --conn_type http \
      --conn_host https://hooks.slack.com/services \
      --conn_password ${AIRFLOW_SLACK_WEBHOOK_URL}
    if [ "$AIRFLOW__CORE__EXECUTOR" = "KubernetesExecutor" ]; then
      # With the "KubernetesExecutor" executors it should all run in one container.
      airflow scheduler &
    fi
    if [ "$AIRFLOW__CORE__EXECUTOR" = "LocalExecutor" ]; then
      # With the "Local" executor it should all run in one container.
      airflow scheduler &
    fi
    exec airflow worker &
    exec airflow webserver
    ;;
  worker|scheduler)
    # To give the webserver time to run initdb.
    sleep 10
    exec airflow "$@"
    ;;
  version)
    exec airflow "$@"
    ;;
  *)
    # The command is something like bash, not an airflow subcommand. Just run it in the right environment.
    exec "$@"
    ;;
esac
