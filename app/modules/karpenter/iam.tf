########################################################################
# EKS NodeGroup IAM Role 정보
########################################################################
data "aws_iam_role" "node" {
  name = format("%s-%s", var.cluster_name, "node")
}

########################################################################
# Karpenter IAM Role
########################################################################
resource "aws_iam_role" "this" {
  count = var.create_role && var.attach_karpenter_controller_policy ? 1 : 0

  name = var.role_name
  assume_role_policy = data.aws_iam_policy_document.this[0].json
  force_detach_policies = true
}

########################################################################
# Karpenter IAM Policy Document
########################################################################
data "aws_iam_policy_document" "this" {
  count = var.create_role && var.attach_karpenter_controller_policy ? 1 : 0

  dynamic "statement" {
    for_each = var.oidc_providers

    content {
      effect  = "Allow"
      actions = ["sts:AssumeRoleWithWebIdentity"]

      principals {
        type = "Federated"
        identifiers = [statement.value.provider_arn]
      }

      condition {
        test     = var.assume_role_condition_test
        variable = "${replace(statement.value.provider_arn, "/^(.*provider/)/", "")}:sub"
        values   = [for sa in statement.value.namespace_service_accounts : "system:serviceaccount:${sa}"]
      }

      # https://aws.amazon.com/premiumsupport/knowledge-center/eks-troubleshoot-oidc-and-irsa/?nc1=h_ls
      condition {
        test     = var.assume_role_condition_test
        variable = "${replace(statement.value.provider_arn, "/^(.*provider/)/", "")}:aud"
        values   = ["sts.amazonaws.com"]
      }
    }
  }
}

########################################################################
# Karpenter IAM Instance Profile
########################################################################
resource "aws_iam_instance_profile" "karpenter" {
  count = var.create_role && var.attach_karpenter_controller_policy ? 1 : 0

  name = "KarpenterNodeInstanceProfile-${var.cluster_name}"
  role = data.aws_iam_role.node.name
}

################################################################################
# Karpenter Controller Policy
################################################################################
# curl -fsSL https://karpenter.sh/v0.6.1/getting-started/cloudformation.yaml
data "aws_iam_policy_document" "karpenter_controller" {
  count = var.create_role && var.attach_karpenter_controller_policy ? 1 : 0

  statement {
    actions = [
      "ec2:CreateLaunchTemplate",
      "ec2:CreateFleet",
      "ec2:CreateTags",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeInstances",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeInstanceTypeOfferings",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeSpotPriceHistory",
      "pricing:GetProducts",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "ec2:TerminateInstances",
      "ec2:DeleteLaunchTemplate",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/${var.karpenter_tag_key}"
      values   = [var.karpenter_controller_cluster_id]
    }
  }

  statement {
    actions = ["ec2:RunInstances"]
    resources = [
      "arn:${local.partition}:ec2:*:${local.account_id}:launch-template/*",
      "arn:${local.partition}:ec2:*:${local.account_id}:security-group/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/${var.karpenter_tag_key}"
      values   = [var.karpenter_controller_cluster_id]
    }
  }

  statement {
    actions = ["ec2:RunInstances"]
    resources = [
      "arn:${local.partition}:ec2:*::image/*",
      "arn:${local.partition}:ec2:*:${local.account_id}:instance/*",
      "arn:${local.partition}:ec2:*:${local.account_id}:volume/*",
      "arn:${local.partition}:ec2:*:${local.account_id}:network-interface/*",
      "arn:${local.partition}:ec2:*:${coalesce(var.karpenter_subnet_account_id, local.account_id)}:subnet/*",
    ]
  }

  statement {
    actions   = ["ssm:GetParameter"]
    resources = var.karpenter_controller_ssm_parameter_arns
  }

  statement {
    actions   = ["iam:PassRole"]
    resources = [data.aws_iam_role.node.arn]
  }
}

################################################################################
# Karpenter Controller Policy 생성
################################################################################
resource "aws_iam_policy" "karpenter_controller" {
  count = var.create_role && var.attach_karpenter_controller_policy ? 1 : 0

  name_prefix = "${var.policy_name_prefix}Karpenter_Controller_Policy-"
  description = "Provides permissions to handle node termination events via the Node Termination Handler"
  policy = data.aws_iam_policy_document.karpenter_controller[0].json
}

################################################################################
# Karpenter IAM Role Attachment
################################################################################
resource "aws_iam_role_policy_attachment" "karpenter_controller" {
  count = var.create_role && var.attach_karpenter_controller_policy ? 1 : 0

  role = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.karpenter_controller[0].arn
}