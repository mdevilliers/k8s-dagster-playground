ops:
  process_data_for_date:
    config:
      date: '2021-06-01'
resources:
  io_manager:
    config:
      s3_bucket: "dagster-data"
  s3:
    config:
      # This use of host.docker.internal is unique to Mac
      endpoint_url: http://minio.minio.svc.cluster.local:9000
      region_name: us-east-1
