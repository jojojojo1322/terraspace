# 생성된 VPC ID
vpc_id = <%= output('base.vpc_id') %>
# 생성된 public subnet ids
public_subnet_ids = <%= output('base.public_subnet_ids') %>
# 생성된 private subnet ids
private_subnet_ids = <%= output('base.private_subnet_ids') %>
# 생성된 expand subnet ids
expand_subnet_ids = <%= output('base.expand_subnet_ids') %>
# 생성된 rds(private) subnet ids
rds_subnet_ids = <%= output('base.rds_subnet_ids') %>
# 생성된 KMS KEY ARN
kms_key_arn = <%= output('base.kms_key_arn') %>
# 생성된 Bastion Host Key Pair Name
key_name = <%= output('base.key_name') %>
# 생성된 Bastion Host Security Group ID
bastion_security_id = <%= output('base.bastion_security_id') %>
