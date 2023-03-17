serviceAccount:
  create: true
  name:  ${metrics_server_k8s_sa_name}
  annotations:
    eks.amazonaws.com/role-arn: ${metrics_server_iam_role_arn}
