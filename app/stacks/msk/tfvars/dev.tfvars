# 생성된 VPC ID
vpc_id = <%= output('base.vpc_id') %>
# 생성된 kafka subnet ids
kafka_subnet_ids = <%= output('base.expand_subnet_ids') %>
# 생성된 KMS KEY ARN
kms_key_arn = <%= output('base.kms_key_arn') %>
# 생성된 Bastion Host Security Group ID
bastion_security_id = <%= output('base.bastion_security_id') %>
