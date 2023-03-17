serviceAccounts:
  alertmanager:
    create: true
    name: ${prometheus_k8s_sa_name}
    annotations:
      eks.amazonaws.com/role-arn: ${prometheus_iam_role_arn}
  nodeExporter:
    create: false
    name: ${prometheus_k8s_sa_name}
    annotations:
      eks.amazonaws.com/role-arn: ${prometheus_iam_role_arn}
  pushgateway:
    create: false
    name: ${prometheus_k8s_sa_name}
    annotations:
      eks.amazonaws.com/role-arn: ${prometheus_iam_role_arn}
  server:
    create: false
    name: ${prometheus_k8s_sa_name}
    annotations:
      eks.amazonaws.com/role-arn: ${prometheus_iam_role_arn}

alertmanager:
  persistentVolume:
    enabled: false
  emptyDir:
    sizeLimit: 2Gi

server:
  persistentVolume:
    enabled: false
  emptyDir:
    sizeLimit: 6Gi