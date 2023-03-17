serviceAccount:
  create: true
  name:  ${loki_k8s_sa_name}
  annotations:
    eks.amazonaws.com/role-arn: ${loki_iam_role_arn}
  automountServiceAccountToken: true

loki:
  structuredConfig:
    auth_enabled: false

    compactor:
      shared_store: s3
    ingester:
      chunk_idle_period: 30m
      chunk_retain_period: 1m
    table_manager:
      retention_deletes_enabled: true
      retention_period: 672h
      creation_grace_period: 24h
    limits_config:
      enforce_metric_name: false
      reject_old_samples: true
      reject_old_samples_max_age: 168h
    schema_config:
      configs:
        - from: 2022-08-01
          store: aws
          object_store: s3
          schema: v11
          index:
            prefix: ${loki_index}
            period: 168h
    storage_config:
      aws:
        s3: s3://${aws_region}/${bucket_name}
        s3forcepathstyle: true
        dynamodb:
          dynamodb_url: dynamodb://${aws_region}

distributor:
  replicas: 2

ingester:
  replicas: 2

querier:
  replicas: 2

queryFrontend:
  replicas: 2

tableManager:
  enabled: true
  resources: {}
  extraVolumes:
    - name: data
      emptyDir: {}
  extraVolumeMounts:
    - name: data
      mountPath: /var/loki

analytics:
  reporting_enabled: false