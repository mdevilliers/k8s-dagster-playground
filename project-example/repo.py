from dagster import job, op, graph, repository
from dagster import daily_partitioned_config
from datetime import datetime
from dagster_aws.s3 import s3_pickle_io_manager, s3_resource
from dagster_k8s import k8s_job_executor

@op(config_schema={"date": str})
def process_data_for_date(context):
    date = context.op_config["date"]
    context.log.info(f"processing data for {date}")

@daily_partitioned_config(start_date=datetime(2021, 6, 1))
def my_partitioned_config(start: datetime, _end: datetime):
    return {
            "ops": {
                "process_data_for_date": {
                    "config": {
                        "date": start.strftime("%Y-%m-%d")},
                    },
                },
            "resources":{
                "io_manager": {
                    "config": {
                        "s3_bucket": "dagster-data"
                        },
                    },
                "s3":{
                    "config": {
                        "endpoint_url": "http://minio.minio.svc.cluster.local:9000",
                        "region_name": "us-east-1"
                        },
                    },
                },
            }

@graph
def example_graph():
    process_data_for_date()

step_isolated_job = example_graph.to_job(
    name="step_isolated_job",
    resource_defs={"s3": s3_resource, "io_manager": s3_pickle_io_manager},
    executor_def=k8s_job_executor,
    config=my_partitioned_config,
)

@repository
def example_repo():
    return [step_isolated_job]
