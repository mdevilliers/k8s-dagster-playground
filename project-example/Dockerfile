ARG BASE_IMAGE
FROM "${BASE_IMAGE}"

ARG DAGSTER_VERSION

# ==> Add Dagster layer
RUN \
# Cron
       apt-get update -yqq \
    && apt-get install -yqq cron \
# Dagster
    && pip install \
        dagster==${DAGSTER_VERSION} \
        dagster-aws==${DAGSTER_VERSION} \
        dagster-k8s==${DAGSTER_VERSION} \
        dagster-postgres==${DAGSTER_VERSION} \
# Cleanup
    &&  rm -rf /var \
    &&  rm -rf /root/.cache  \
    &&  rm -rf /usr/lib/python2.7 \
    &&  rm -rf /usr/lib/x86_64-linux-gnu/guile

# ==> Add user code layer
# Example pipelines
COPY ./ /project-example
