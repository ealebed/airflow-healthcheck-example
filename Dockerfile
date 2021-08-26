FROM python:3.9-slim-buster

LABEL maintainer="Yevhen Lebid <yevhen.lebid@loopme.com>"

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND=noninteractive \
    TERM=linux

# Airflow
ARG AIRFLOW_VERSION=2.1.2
ARG AIRFLOW_USER_HOME=/usr/local/airflow
ENV AIRFLOW_HOME=${AIRFLOW_USER_HOME}

RUN set -ex \
    && buildDeps=" \
        libsasl2-dev \
        libssl-dev \
        libffi-dev \
        libpq-dev \
        build-essential \
    " \
    && pipDeps=" \
       pytz \
       pyOpenSSL \
       ndg-httpsclient \
       pyasn1 \
       psycopg2-binary \
       SQLAlchemy \
    " \
    && apt-get update -yqq \
    && apt-get upgrade -yqq \
    && apt-get install -yqq --no-install-recommends git curl jq $buildDeps \
    && useradd -ms /bin/bash -d ${AIRFLOW_USER_HOME} -u 65533 airflow \
    && pip install -U pip setuptools wheel \
    && pip install $pipDeps \
    && pip install apache-airflow[async,http,postgres,cncf.kubernetes,password,slack]==${AIRFLOW_VERSION} airflow-code-editor \
    && apt-get purge --auto-remove -yqq $buildDeps \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base

COPY entrypoint.sh /entrypoint.sh
COPY airflow-healthcheck.sh /airflow-healthcheck.sh
COPY airflow.cfg ${AIRFLOW_USER_HOME}/airflow.cfg

RUN chown -R airflow:airflow ${AIRFLOW_USER_HOME}

EXPOSE 8080

USER airflow
WORKDIR ${AIRFLOW_USER_HOME}
ENTRYPOINT ["/entrypoint.sh"]
CMD ["webserver"]
