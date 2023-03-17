###########################################################################
# 계정정보 조회
###########################################################################
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

###########################################################################
# Loki IAM Role 설정
###########################################################################
module "loki" {
  source = "../../modules/iam"

  create_role = true
  role_name = var.loki_iam_role_name
  oidc_providers = {
    ex = {
      provider_arn = var.cluster_oidc_arn
      namespace_service_accounts = ["${var.k8s_namespace}:${var.loki_k8s_sa_name}"]
    }
  }
}

###########################################################################
# Loki IAM role add S3, DynamoDB Policy
###########################################################################
data "aws_iam_policy_document" "loki_storage" {
  statement {
    sid = "s3crud"
    actions = [
      "s3:ListBucket",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.this.arn}",
      "${aws_s3_bucket.this.arn}/*"
    ]
  }
	
  statement {
    sid = "dynamolist"
    actions = [
      "dynamodb:ListTables"
    ]
    resources = ["*"]
  }

  statement {
    sid = "dynamocrd"
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:ListTagsOfResource",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:TagResource",
      "dynamodb:UntagResource",
      "dynamodb:UpdateItem",
      "dynamodb:UpdateTable",
      "dynamodb:CreateTable",
      "dynamodb:DeleteTable"
    ]
    resources = [
      "arn:aws:dynamodb:ap-northeast-2:${data.aws_caller_identity.current.account_id}:table/${var.loki_index}*"
    ]
  }

  statement {
    actions = [
      "application-autoscaling:DescribeScalableTargets",
      "application-autoscaling:DescribeScalingPolicies",
      "application-autoscaling:RegisterScalableTarget",
      "application-autoscaling:DeregisterScalableTarget",
      "application-autoscaling:PutScalingPolicy",
      "application-autoscaling:DeleteScalingPolicy"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "iam:GetRole",
      "iam:PassRole"
    ]
    resources = [
      "${module.loki.iam_role_arn}"
    ]
  }

  statement {
    sid = "AllowUseKey"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = [var.kms_key_arn]
  }
}

resource "aws_iam_role_policy" "loki" {
  name = "loki-permissions"
  role = module.loki.iam_role_id
  policy = data.aws_iam_policy_document.loki_storage.json
}

###########################################################################
# Grafana IAM 설정
###########################################################################
module "grafana" {
  source = "../../modules/iam"

  create_role = true
  role_name = var.grafana_iam_role_name
  oidc_providers = {
    ex = {
      provider_arn = var.cluster_oidc_arn
      namespace_service_accounts = ["${var.k8s_namespace}:${var.grafana_k8s_sa_name}"]
    }
  }
}

# Grafana IAM Policy 생성
resource "aws_iam_role_policy" "grafana_permissions" {
  name = "grafana-permissions"
  role = module.grafana.iam_role_id
  policy = file("${path.module}/policies/grafana-permissions.json")
}

###########################################################################
# Metrics Server IAM Role 설정
###########################################################################
module "metrics" {
  source = "../../modules/iam"

  create_role = true
  role_name = var.metrics_server_iam_role_name
  oidc_providers = {
    ex = {
      provider_arn = var.cluster_oidc_arn
      namespace_service_accounts = ["${var.k8s_namespace}:${var.metrics_server_k8s_sa_name}"]
    }
  }
}

###########################################################################
# Prometheus IAM Role 설정
###########################################################################
module "prometheus" {
  source = "../../modules/iam"

  create_role = true
  role_name = var.prometheus_iam_role_name
  oidc_providers = {
    ex = {
      provider_arn = var.cluster_oidc_arn
      namespace_service_accounts = ["${var.k8s_namespace}:${var.prometheus_k8s_sa_name}"]
    }
  }
}
