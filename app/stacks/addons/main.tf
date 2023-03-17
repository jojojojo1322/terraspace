###################################################################################
# EKS ADD-ON 생성 & AWS-AUTH ConfigMap 설정
###################################################################################
module "addon" {
  source = "../../modules/addon"

  # 서비스 이름
  svr_nm = var.svr_nm
  # 클러스터 이름
  cluster_name = var.cluster_name
  # 클러스터 Add-On 상세
  addons = var.addons
}

###################################################################################
# AWS Load Balancer Controller 생성
###################################################################################
module "alb" {
  source = "../../modules/alb"

  # 서비스 이름
  svr_nm = var.svr_nm
  # 클러스터 이름
  cluster_name = var.cluster_name
  # VPC ID
  vpc_id = var.vpc_id

  # AWS Load Balancer Controller 변수
  create_role = true
  role_name = var.lb_controller_iam_role_name
  role_path = "/"
  role_description = "Used by AWS Load Balancer Controller for EKS"

  provider_url  = var.cluster_oidc_issuer
  provider_urls = [var.cluster_oidc_issuer]

  role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
  ]

  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:${var.lb_controller_service_account_name}"]
  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]
}

###################################################################################
# Cluster Autoscaler 생성
###################################################################################
module "autoscaler" {
  source = "../../modules/ca"

  create_role = var.autoscaler_mode == "ca" ? true : false
  # 클러스터 이름
  cluster_name = var.cluster_name
  # Autoscaler 변수
  ca_iam_role_name = "cluster-autoscaler-${var.cluster_name}"
  cluster_oidc_arn = var.cluster_oidc_arn
}

###################################################################################
# Karpenter 생성
###################################################################################
module "karpenter" {
  source = "../../modules/karpenter"

  # 클러스터 이름
  cluster_name = var.cluster_name
  # karpente 변수
  create_role = var.autoscaler_mode == "karpenter" ? true : false
  role_name = "karpenter-controller-${var.cluster_name}"
  attach_karpenter_controller_policy = true
  karpenter_controller_cluster_id = var.cluster_name

  oidc_providers = {
    ex = {
      provider_arn = var.cluster_oidc_arn
      namespace_service_accounts = ["karpenter:karpenter"]
    }
  }
}

###################################################################################
# Grafana Stack 생성
###################################################################################
module "monitoring" {
  source = "../../modules/grafana"

  # 서비스 이름
  svr_nm = var.svr_nm
  # loki index 이름
  loki_index = var.loki_index
  
  # 클러스터 이름
  cluster_name = var.cluster_name
  cluster_oidc_provider = var.cluster_oidc_issuer
  cluster_oidc_arn = var.cluster_oidc_arn

  # kms key arn
  kms_key_arn = var.kms_key_arn
  
  # helm chart role 정보
  metrics_server_iam_role_name = "metrics-server-${var.cluster_name}"
  prometheus_iam_role_name = "prometheus-${var.cluster_name}"
  loki_iam_role_name = "loki-${var.cluster_name}"
  grafana_iam_role_name = "grafana-${var.cluster_name}"

  # helm chart 정보
  chart_version_loki_distributed = var.chart_version_loki_distributed
  chart_version_promtail = var.chart_version_promtail
  chart_version_grafana = var.chart_version_grafana
  chart_version_metrics_server = var.chart_version_metrics_server
  chart_version_prometheus = var.chart_version_prometheus
}
