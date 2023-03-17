###################################################################################
# Amazon EC2 서비스 생성 :: Web Server & WAS Server
###################################################################################
module "web" {
  source = "../../modules/web"

  # 서비스 이름
  svr_nm = var.svr_nm
  # 생성여부
  create = true

  # VPC ID
  vpc_id = var.vpc_id
  # VPC CIDR Blocks
  cidr_block = var.cidr_block
  # public subnet ids
  public_subnet_ids = var.public_subnet_ids
  # private subnet ids
  private_subnet_ids = var.private_subnet_ids
  
  # rds subnet ids
  rds_subnet_ids = var.rds_subnet_ids

  # kms key arn
  kms_key_arn = var.kms_key_arn
  # bastion host key name
  key_name = var.key_name
  # bastion host 보안그룹 ID
  bastion_security_id = var.bastion_security_id

  # 보안그룹
  ports = var.ports
  rules = var.rules
  web_ingress_rules = ["ssh-tcp", "http-80-tcp", "https-443-tcp"]
  was_ingress_rules = ["ssh-tcp", "http-8080-tcp"]
  rds_ingress_rules = ["postgresql-tcp"]
  cidr_blocks = ["0.0.0.0/0"]

  # EC2 정보
  web_instance_type = var.web_instance_type
  was_instance_type = var.was_instance_type
  min_size = var.min_size
  max_size = var.max_size
  enable_autoscaling = var.enable_autoscaling

  # RDS 정보
  postgres_version = var.postgres_version
  instances = var.instances
  availability_zones = var.availability_zones
  port = var.port
  master_username = var.master_username
  master_password = var.master_password
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window
}
