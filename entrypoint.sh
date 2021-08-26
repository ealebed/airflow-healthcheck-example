#!/usr/bin/env bash

declare -a DEFAULT_CONNS=(
    "slack"
    "postgres_default"
)

case "$1" in
  webserver)
    airflow db init
    airflow users create \
      --role 'Admin' \
      --username ${AIRFLOW_ADMIN_USER} \
      --password ${AIRFLOW_ADMIN_PASSWORD} \
      --firstname 'Air' \
      --lastname 'Flow' \
      --email 'air.flow@examle.com'
    for CONN in "${DEFAULT_CONNS[@]}"
    do
      airflow connections delete ${CONN}
    done
    airflow connections add 'postgres_default' \
      --conn-uri ${AIRFLOW_CONN_POSTGRES_DEFAULT}
    airflow connections add 'slack' \
      --conn-type 'http' \
      --conn-host 'https://hooks.slack.com/services' \
      --conn-password ${AIRFLOW_SLACK_WEBHOOK_URL}
    exec airflow scheduler &
    exec airflow webserver
    ;;
  scheduler)
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
