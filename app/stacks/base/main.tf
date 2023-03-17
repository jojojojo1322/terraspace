###################################################################################
# 기본구조 생성 :: VPC, SUBNET, GATEWAY, ROUTE
###################################################################################
module "base" {
  source = "../../modules/base"

  # service names
  svr_nm = var.svr_nm
  # cidr blocks
  cidr_block = var.cidr_block
  # subnets info
  subnets = var.subnets
  # rds 생성여부 설정
  enable_rds_subnet = true
}

###################################################################################
# 생성된 기본구조 위에 Bastion Host 생성
###################################################################################
module "bastion" {
  source = "../../modules/bastion"

  # service names
  svr_nm = var.svr_nm

  # 생성된 vpc id
  vpc_id = module.base.vpc_id
  # 생성된 public subnet id 목록
  public_subnet_ids = module.base.public_subnet_ids

  # bastion host 인스턴스 정의
  ami = var.ami["bastion"]
  instance_type = var.instance_type["bastion"]
  # 사전 정의 포트정보
  ports = var.ports
}

###################################################################################
# 생성된 VPC의 CloudWatch기반 Flow Log 생성
###################################################################################
module "flowlog" {
  source = "../../modules/flowlog"

  # service names
  svr_nm = var.svr_nm

  # 생성된 vpc id
  vpc_id = module.base.vpc_id
}