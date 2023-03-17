serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: ${loki_iam_role_arn}
rbac:
  pspEnabled: false
config:
  clients:
    - url: ${loki_address}
