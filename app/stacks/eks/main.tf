###################################################################################
# EKS cluster 생성
###################################################################################
module "cluster" {
  source = "../../modules/cluster"

  # 서비스 이름
  svr_nm = var.svr_nm
  # 클러스터 버전
  cluster_version = var.cluster_version
  # 클러스터 마스터에 접근하기 위한 workstation CIDR
  workstation_cidr = var.workstation_cidr
  # VPC ID
  vpc_id = var.vpc_id
  # subnet ids
  public_subnet_ids = var.public_subnet_ids
  private_subnet_ids = var.private_subnet_ids

  # kms key arn
  kms_key_arn = var.kms_key_arn
  # port 정보
  ports = var.ports
}

###################################################################################
# NodeGroup 생성
###################################################################################
module "nodegroup" {
  source = "../../modules/nodegroup"

  # nodegroup 생성여부
  count = var.enable_nodegroup ? 1 : 0

  # 서비스 이름
  svr_nm = var.svr_nm
  # VPC ID
  vpc_id = var.vpc_id

  # EKS cluster 이름
  cluster_name = module.cluster.cluster_name
  # EKS cluster security group id
  cluster_security_id = module.cluster.cluster_security_id
  # Bastion Host security group id
  bastion_security_id = var.bastion_security_id

  # Node Group 생성 대상 서브넷
  private_subnet_ids = var.private_subnet_ids

  # node instance profile
  instance_type = var.instance_type["instance"]
  key_name = var.key_name
  min_size = var.min_size
  max_size = var.max_size

  # port 정보
  ports = var.ports

  depends_on = [module.cluster]
}

###################################################################################
# Fargate 생성
###################################################################################
module "fargate" {
  source = "../../modules/fargate"

  # nodegroup 생성여부
  count = var.enable_fargate ? 1 : 0

  # 서비스 이름
  svr_nm = var.svr_nm
  # Fargate 생성 대상 서브넷
  private_subnet_ids = var.private_subnet_ids

  depends_on = [module.cluster]
}
