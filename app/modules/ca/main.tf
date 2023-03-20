########################################################################
# 생성된 EKS cluster 정보 조회
########################################################################
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}
data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

########################################################################
# Kubectl Provider 정의
########################################################################
# terraform required providers
terraform {
  required_version = "~> 1.0"

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
  }
}

# kubectl provider
provider "kubectl" {
  apply_retry_count = 5
  host = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token = data.aws_eks_cluster_auth.cluster.token
  load_config_file = false
}

###########################################################################
# Cluster Autoscaler IAM Role 생성
###########################################################################
module "ca" {
  source = "../../modules/iam"

  create_role = var.create_role
  role_name = var.ca_iam_role_name
  oidc_providers = {
    ex = {
      provider_arn = var.cluster_oidc_arn
      namespace_service_accounts = ["kube-system:${var.ca_k8s_sa_name}"]
    }
  }
}

###########################################################################
# Cluster Autoscaler IAM policy 생성
###########################################################################
data "aws_iam_policy_document" "ca" {
  statement {
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeLaunchTemplateVersions"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ca" {
  count = var.create_role ? 1 : 0

  name = "ca-permissions"
  role = module.ca.iam_role_id
  policy = data.aws_iam_policy_document.ca.json
}

###########################################################################
# Cluster Autoscaler 생성
###########################################################################
# data "template_file" "ca" {
#   template = file("${path.module}/manifests/cluster-autoscaler-autodiscover.yaml")

#   vars = {
#     cluster_name = var.cluster_name
#     cluster_role_arn = module.ca.iam_role_arn
#   }
# }

# data "kubectl_file_documents" "ca" {
#   content = data.template_file.ca.rendered
# }

# resource "kubectl_manifest" "ca" {
#   count = var.create_role ? length(data.kubectl_file_documents.ca.documents) : 0
#   yaml_body = element(data.kubectl_file_documents.ca.documents, count.index)
# }
data "kubectl_path_documents" "ca" {
  pattern = "${path.module}/manifests/*.yaml"

    vars = {
    cluster_name = var.cluster_name
    cluster_role_arn = module.ca.iam_role_arn
  }
}

resource "kubectl_manifest" "ca" {
  count = length(
    flatten(
      toset([
        for f in fileset(".", data.kubectl_path_documents.ca.pattern) : split("\n---\n", file(f))
        ]
      )
    )
  )
  yaml_body = element(data.kubectl_path_documents.ca.documents, count.index)
}