from airflow.hooks.base_hook import BaseHook
from airflow.contrib.operators.slack_webhook_operator import SlackWebhookOperator

SLACK_CONN_ID = 'slack'

def get_users(usr):
    default = '@ealebed'
    return default if usr is None else "@{}".format(" @".join(usr)) if isinstance(usr, list) else "@{}".format(usr)

def task_fail_slack_alert(context, usr=None):
    slack_msg = """
        :skull: *Task Failure:* {usr}
        *Task*: {task}
        *Dag*: {dag}
        *Execution Time*: {exec_date}
        *Log Url*: {log_url}
    """.format(
        usr=get_users(usr),
        task=context.get('task_instance').task_id,
        dag=context.get('task_instance').dag_id,
        exec_date=context.get('execution_date'),
        log_url=context.get('task_instance').log_url,
    )

    slack_webhook_token = BaseHook.get_connection(SLACK_CONN_ID).password
    failed_alert = SlackWebhookOperator(
        task_id='slack_failure_notification',
        http_conn_id=SLACK_CONN_ID,
        webhook_token=slack_webhook_token,
        message=slack_msg,
        username='Airflow',
        link_names=True,
        icon_emoji=':robot_face:'
    )

    return failed_alert.execute(context=context)


def task_success_slack_alert(context, usr=None):
    slack_msg = """
        :scream_cat: *Task Success:* {usr}
        *Task*: {task}
        *Dag*: {dag}
        *Execution Time*: {exec_date}
        *Log Url*: {log_url}
    """.format(
        usr=get_users(usr),
        task=context.get('task_instance').task_id,
        dag=context.get('task_instance').dag_id,
        exec_date=context.get('execution_date'),
        log_url=context.get('task_instance').log_url,
    )
    
    slack_webhook_token = BaseHook.get_connection(SLACK_CONN_ID).password
    success_alert = SlackWebhookOperator(
        task_id='slack_success_notification',
        http_conn_id=SLACK_CONN_ID,
        webhook_token=slack_webhook_token,
        message=slack_msg,
        username='Airflow',
        link_names=True,
        icon_emoji=':robot_face:'
    )

    return success_alert.execute(context=context)
