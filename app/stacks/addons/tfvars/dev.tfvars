# 생성된 VPC ID
vpc_id = <%= output('base.vpc_id') %>
# 생성된 Cluster name
cluster_name = <%= output('eks.cluster_name') %>
# 생성된 Cluster oidc issur
cluster_oidc_issuer = <%= output('eks.cluster_oidc_issuer') %>
# 생성된 Cluster oidc arn
cluster_oidc_arn = <%= output('eks.oidc_arn') %>
# 생성된 KMS KEY ARN
kms_key_arn = <%= output('base.kms_key_arn') %>